#!/usr/bin/env pwsh
# Docker Container Management for BMAD Projects
# Assumes all projects run in Docker containers

param(
    [string]$Action = "status",
    [string]$Service = "all",
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$PROJECT_NAME = "BMAD-CC"
$PROJECT_TYPE = "other"
$DOCKER_COMPOSE_FILE = ""
$FRONTEND_PORT = "3000"
$BACKEND_PORT = "8001"

# Docker compose file detection
function Get-DockerComposeFile {
    if ($DOCKER_COMPOSE_FILE -and (Test-Path $DOCKER_COMPOSE_FILE)) {
        return $DOCKER_COMPOSE_FILE
    }
    
    # Check common locations
    $possibleFiles = @(
        "docker-compose.yml",
        "docker-compose.yaml", 
        "compose.yml",
        "compose.yaml",
        "docker-compose.dev.yml",
        "docker-compose.local.yml"
    )
    
    foreach ($file in $possibleFiles) {
        if (Test-Path $file) {
            return $file
        }
    }
    
    return $null
}

# Check Docker installation
function Test-DockerAvailable {
    try {
        $version = docker --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
    } catch {}
    return $false
}

# Check Docker Compose installation
function Test-DockerComposeAvailable {
    try {
        # Try docker compose (v2)
        $version = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return "docker compose"
        }
        
        # Try docker-compose (v1)
        $version = docker-compose --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return "docker-compose"
        }
    } catch {}
    return $null
}

# Get container status
function Get-ContainerStatus {
    param([string]$ServiceName = "")
    
    $composeFile = Get-DockerComposeFile
    if (-not $composeFile) {
        return @{
            Status = "no-compose"
            Message = "No docker-compose file found"
        }
    }
    
    $composeCmd = Test-DockerComposeAvailable
    if (-not $composeCmd) {
        return @{
            Status = "no-compose-cli"
            Message = "Docker Compose not installed"
        }
    }
    
    try {
        if ($ServiceName) {
            $status = & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile ps $ServiceName --format json 2>&1 | ConvertFrom-Json
        } else {
            $status = & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile ps --format json 2>&1 | ConvertFrom-Json
        }
        
        return @{
            Status = "running"
            Containers = $status
        }
    } catch {
        return @{
            Status = "stopped"
            Message = "Containers not running"
        }
    }
}

# Start Docker containers
function Start-DockerContainers {
    param([string]$ServiceName = "")
    
    Write-Host "🐳 Starting Docker containers..." -ForegroundColor Cyan
    
    $composeFile = Get-DockerComposeFile
    if (-not $composeFile) {
        Write-Error "No docker-compose file found"
        return $false
    }
    
    $composeCmd = Test-DockerComposeAvailable
    if (-not $composeCmd) {
        Write-Error "Docker Compose not installed"
        return $false
    }
    
    try {
        # Build images if needed
        Write-Host "Building Docker images..." -ForegroundColor Gray
        if ($ServiceName) {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile build $ServiceName
        } else {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile build
        }
        
        # Start containers
        Write-Host "Starting containers..." -ForegroundColor Gray
        if ($ServiceName) {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile up -d $ServiceName
        } else {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile up -d
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker containers started successfully" -ForegroundColor Green
            
            # Wait for services to be healthy
            Start-Sleep -Seconds 3
            Test-ServiceHealth
            
            return $true
        }
    } catch {
        Write-Error "Failed to start Docker containers: $_"
    }
    
    return $false
}

# Stop Docker containers
function Stop-DockerContainers {
    param([string]$ServiceName = "")
    
    Write-Host "🛑 Stopping Docker containers..." -ForegroundColor Cyan
    
    $composeFile = Get-DockerComposeFile
    if (-not $composeFile) {
        return $true  # Nothing to stop
    }
    
    $composeCmd = Test-DockerComposeAvailable
    if (-not $composeCmd) {
        return $true  # Can't stop without compose
    }
    
    try {
        if ($ServiceName) {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile stop $ServiceName
        } else {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile stop
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker containers stopped" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Warning "Failed to stop containers: $_"
    }
    
    return $false
}

# Restart Docker containers
function Restart-DockerContainers {
    param([string]$ServiceName = "")
    
    Write-Host "🔄 Restarting Docker containers..." -ForegroundColor Cyan
    
    Stop-DockerContainers -ServiceName $ServiceName
    Start-Sleep -Seconds 2
    Start-DockerContainers -ServiceName $ServiceName
}

# Test service health
function Test-ServiceHealth {
    Write-Host "🏥 Checking service health..." -ForegroundColor Cyan
    
    $healthy = $true
    
    # Check frontend health
    if ($FRONTEND_PORT -and $FRONTEND_PORT -ne "0") {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$FRONTEND_PORT" -TimeoutSec 5 -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ Frontend healthy on port $FRONTEND_PORT" -ForegroundColor Green
            }
        } catch {
            Write-Warning "⚠️ Frontend not responding on port $FRONTEND_PORT"
            $healthy = $false
        }
    }
    
    # Check backend health
    if ($BACKEND_PORT -and $BACKEND_PORT -ne "0") {
        try {
            # Try common health endpoints
            $healthEndpoints = @("/health", "/api/health", "/", "/api")
            $backendHealthy = $false
            
            foreach ($endpoint in $healthEndpoints) {
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:$BACKEND_PORT$endpoint" -TimeoutSec 5 -UseBasicParsing
                    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 204) {
                        Write-Host "✅ Backend healthy on port $BACKEND_PORT" -ForegroundColor Green
                        $backendHealthy = $true
                        break
                    }
                } catch {}
            }
            
            if (-not $backendHealthy) {
                Write-Warning "⚠️ Backend not responding on port $BACKEND_PORT"
                $healthy = $false
            }
        } catch {
            Write-Warning "⚠️ Backend health check failed"
            $healthy = $false
        }
    }
    
    return $healthy
}

# View Docker logs
function Get-DockerLogs {
    param(
        [string]$ServiceName = "",
        [int]$Lines = 50
    )
    
    $composeFile = Get-DockerComposeFile
    if (-not $composeFile) {
        Write-Error "No docker-compose file found"
        return
    }
    
    $composeCmd = Test-DockerComposeAvailable
    if (-not $composeCmd) {
        Write-Error "Docker Compose not installed"
        return
    }
    
    try {
        if ($ServiceName) {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile logs --tail=$Lines $ServiceName
        } else {
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile logs --tail=$Lines
        }
    } catch {
        Write-Error "Failed to get logs: $_"
    }
}

# Execute command in container
function Invoke-DockerExec {
    param(
        [string]$ServiceName,
        [string]$Command
    )
    
    if (-not $ServiceName) {
        Write-Error "Service name required for exec"
        return
    }
    
    $composeFile = Get-DockerComposeFile
    if (-not $composeFile) {
        Write-Error "No docker-compose file found"
        return
    }
    
    $composeCmd = Test-DockerComposeAvailable
    if (-not $composeCmd) {
        Write-Error "Docker Compose not installed"
        return
    }
    
    try {
        & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile exec $ServiceName $Command
    } catch {
        Write-Error "Failed to execute command: $_"
    }
}

# Clean Docker resources
function Clear-DockerResources {
    Write-Host "🧹 Cleaning Docker resources..." -ForegroundColor Cyan
    
    $composeFile = Get-DockerComposeFile
    if ($composeFile) {
        $composeCmd = Test-DockerComposeAvailable
        if ($composeCmd) {
            Write-Host "Removing containers and networks..." -ForegroundColor Gray
            & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile down
        }
    }
    
    # Clean dangling images
    Write-Host "Cleaning dangling images..." -ForegroundColor Gray
    docker image prune -f
    
    # Clean unused volumes (with confirmation)
    if ($Force) {
        Write-Host "Cleaning unused volumes..." -ForegroundColor Gray
        docker volume prune -f
    }
    
    Write-Host "✅ Docker cleanup complete" -ForegroundColor Green
}

# Troubleshoot Docker issues
function Invoke-DockerTroubleshoot {
    Write-Host "`n🔧 Docker Troubleshooting" -ForegroundColor Cyan
    Write-Host "=" * 50
    
    # Check Docker daemon
    Write-Host "`n1️⃣ Docker Daemon Status:" -ForegroundColor Yellow
    if (Test-DockerAvailable) {
        Write-Host "✅ Docker daemon is running" -ForegroundColor Green
        docker version --format "Server: {{.Server.Version}}, Client: {{.Client.Version}}"
    } else {
        Write-Host "❌ Docker daemon not running" -ForegroundColor Red
        Write-Host "Fix: Start Docker Desktop or run: sudo service docker start" -ForegroundColor Yellow
    }
    
    # Check Docker Compose
    Write-Host "`n2️⃣ Docker Compose Status:" -ForegroundColor Yellow
    $composeCmd = Test-DockerComposeAvailable
    if ($composeCmd) {
        Write-Host "✅ Docker Compose available: $composeCmd" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker Compose not installed" -ForegroundColor Red
        Write-Host "Fix: Install with: pip install docker-compose" -ForegroundColor Yellow
    }
    
    # Check compose file
    Write-Host "`n3️⃣ Compose File Status:" -ForegroundColor Yellow
    $composeFile = Get-DockerComposeFile
    if ($composeFile) {
        Write-Host "✅ Found: $composeFile" -ForegroundColor Green
    } else {
        Write-Host "❌ No docker-compose file found" -ForegroundColor Red
        Write-Host "Fix: Create docker-compose.yml in project root" -ForegroundColor Yellow
    }
    
    # Check port availability
    Write-Host "`n4️⃣ Port Availability:" -ForegroundColor Yellow
    $portsToCheck = @($FRONTEND_PORT, $BACKEND_PORT) | Where-Object { $_ -and $_ -ne "0" }
    foreach ($port in $portsToCheck) {
        $tcpConnection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
        if ($tcpConnection.TcpTestSucceeded) {
            Write-Host "✅ Port $port is accessible" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Port $port may be blocked or service not running" -ForegroundColor Yellow
        }
    }
    
    # Check disk space
    Write-Host "`n5️⃣ Docker Disk Usage:" -ForegroundColor Yellow
    docker system df
    
    # Check running containers
    Write-Host "`n6️⃣ Running Containers:" -ForegroundColor Yellow
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Common fixes
    Write-Host "`n💡 Common Fixes:" -ForegroundColor Cyan
    Write-Host "1. Restart Docker: docker-compose restart" -ForegroundColor Gray
    Write-Host "2. Rebuild images: docker-compose build --no-cache" -ForegroundColor Gray
    Write-Host "3. View logs: docker-compose logs -f [service]" -ForegroundColor Gray
    Write-Host "4. Clean resources: docker system prune -a" -ForegroundColor Gray
    Write-Host "5. Reset completely: docker-compose down -v && docker-compose up -d" -ForegroundColor Gray
    
    Write-Host "=" * 50
}

# Main execution
switch ($Action) {
    "start" {
        Start-DockerContainers -ServiceName $Service
    }
    
    "stop" {
        Stop-DockerContainers -ServiceName $Service
    }
    
    "restart" {
        Restart-DockerContainers -ServiceName $Service
    }
    
    "status" {
        Write-Host "`n🐳 Docker Status for $PROJECT_NAME" -ForegroundColor Cyan
        Write-Host "=" * 50
        
        if (-not (Test-DockerAvailable)) {
            Write-Host "❌ Docker not available" -ForegroundColor Red
            Write-Host "Please install Docker Desktop" -ForegroundColor Yellow
            exit 1
        }
        
        $status = Get-ContainerStatus
        if ($status.Status -eq "running") {
            Write-Host "✅ Containers running" -ForegroundColor Green
            $status.Containers | ForEach-Object {
                Write-Host "  - $($_.Service): $($_.State)" -ForegroundColor Gray
            }
        } else {
            Write-Host "⚠️ Containers not running: $($status.Message)" -ForegroundColor Yellow
            Write-Host "Start with: /bmad:docker start" -ForegroundColor Cyan
        }
        
        Write-Host "=" * 50
    }
    
    "health" {
        Test-ServiceHealth
    }
    
    "logs" {
        Get-DockerLogs -ServiceName $Service -Lines 100
    }
    
    "exec" {
        if ($Service -eq "all") {
            Write-Error "Must specify service for exec command"
        } else {
            Invoke-DockerExec -ServiceName $Service -Command "sh"
        }
    }
    
    "clean" {
        Clear-DockerResources
    }
    
    "troubleshoot" {
        Invoke-DockerTroubleshoot
    }
    
    "build" {
        Write-Host "🔨 Building Docker images..." -ForegroundColor Cyan
        $composeFile = Get-DockerComposeFile
        $composeCmd = Test-DockerComposeAvailable
        
        if ($composeFile -and $composeCmd) {
            if ($Service -eq "all") {
                & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile build
            } else {
                & $composeCmd.Split()[0] $composeCmd.Split()[1] -f $composeFile build $Service
            }
        }
    }
    
    default {
        Write-Error "Unknown action: $Action"
        Write-Host "Valid actions: start, stop, restart, status, health, logs, exec, clean, troubleshoot, build"
    }
}

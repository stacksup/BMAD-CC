# BMAD-CC Docker Development Helper Script (PowerShell)
param(
    [Parameter(Position=0)]
    [ValidateSet('build', 'start', 'stop', 'restart', 'shell', 'logs', 'status', 'taskmaster', 'clean', 'help')]
    [string]$Command = 'help'
)

$ErrorActionPreference = "Stop"

# Project configuration
$ProjectName = "bmad-cc"
$ContainerName = "bmad-cc-dev"

# Helper functions
function Write-Header {
    Write-Host "🐳 BMAD-CC Docker Development Environment" -ForegroundColor Blue
    Write-Host "=========================================" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Command functions
function Invoke-Build {
    Write-Header
    Write-Host "Building BMAD-CC development container..."
    docker-compose build --no-cache
    Write-Success "Container built successfully"
}

function Invoke-Start {
    Write-Header
    Write-Host "Starting BMAD-CC development environment..."
    docker-compose up -d
    
    # Wait for services to be healthy
    Write-Host "Waiting for services to start..."
    Start-Sleep 5
    
    # Check health status
    $status = docker-compose ps
    if ($status -match "healthy|Up") {
        Write-Success "BMAD-CC development environment is running"
        Write-Host ""
        Write-Host "Available services:"
        Write-Host "  🚀 BMAD-CC Dev Container: http://localhost:3000"
        Write-Host "  🗄️  PostgreSQL: localhost:5433"
        Write-Host "  🔴 Redis: localhost:6380"
        Write-Host ""
        Write-Host "To enter the container: .\docker-dev.ps1 shell"
        Write-Host "To view logs: .\docker-dev.ps1 logs"
    } else {
        Write-Error "Some services failed to start properly"
        Invoke-Logs
    }
}

function Invoke-Stop {
    Write-Header
    Write-Host "Stopping BMAD-CC development environment..."
    docker-compose down
    Write-Success "Environment stopped"
}

function Invoke-Restart {
    Invoke-Stop
    Start-Sleep 2
    Invoke-Start
}

function Invoke-Shell {
    Write-Header
    Write-Host "Entering BMAD-CC development container..."
    Write-Warning "Note: Task Master is pre-installed and ready to use"
    docker-compose exec bmad-cc /bin/bash
}

function Invoke-Logs {
    Write-Header
    Write-Host "Showing BMAD-CC container logs..."
    docker-compose logs -f bmad-cc
}

function Invoke-Status {
    Write-Header
    Write-Host "BMAD-CC Development Environment Status:"
    Write-Host ""
    
    $containerStatus = docker-compose ps
    if ($containerStatus -match "$ContainerName.*Up") {
        Write-Success "BMAD-CC container is running"
        
        # Check Task Master availability
        $tmStatus = docker-compose exec -T bmad-cc task-master --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Task Master is available"
        } else {
            Write-Warning "Task Master may not be properly installed"
        }
    } else {
        Write-Warning "BMAD-CC container is not running"
    }
    
    Write-Host ""
    Write-Host "Container status:"
    docker-compose ps
}

function Invoke-TaskmasterInit {
    Write-Header
    Write-Host "Initializing Task Master in BMAD-CC container..."
    
    $initScript = @"
if [ ! -d '.taskmaster' ]; then
    echo 'Initializing Task Master...'
    task-master init -y
    task-master models --set-main opus
    task-master models --set-fallback sonnet
    echo 'Task Master initialized successfully'
else
    echo 'Task Master already initialized'
fi
"@
    
    docker-compose exec bmad-cc bash -c $initScript
    Write-Success "Task Master setup complete"
}

function Invoke-Clean {
    Write-Header
    Write-Host "Cleaning up BMAD-CC development environment..."
    docker-compose down -v --remove-orphans
    docker system prune -f
    Write-Success "Environment cleaned"
}

function Show-Help {
    Write-Header
    Write-Host "Available commands:"
    Write-Host ""
    Write-Host "  build     - Build the BMAD-CC development container"
    Write-Host "  start     - Start the development environment"
    Write-Host "  stop      - Stop the development environment"
    Write-Host "  restart   - Restart the development environment"
    Write-Host "  shell     - Enter the BMAD-CC development container"
    Write-Host "  logs      - Show container logs"
    Write-Host "  status    - Show environment status"
    Write-Host "  taskmaster - Initialize Task Master in container"
    Write-Host "  clean     - Clean up environment and volumes"
    Write-Host "  help      - Show this help message"
    Write-Host ""
    Write-Host "Example usage:"
    Write-Host "  .\docker-dev.ps1 build"
    Write-Host "  .\docker-dev.ps1 start"
    Write-Host "  .\docker-dev.ps1 shell"
}

# Main command dispatcher
try {
    switch ($Command) {
        'build' { Invoke-Build }
        'start' { Invoke-Start }
        'stop' { Invoke-Stop }
        'restart' { Invoke-Restart }
        'shell' { Invoke-Shell }
        'logs' { Invoke-Logs }
        'status' { Invoke-Status }
        'taskmaster' { Invoke-TaskmasterInit }
        'clean' { Invoke-Clean }
        'help' { Show-Help }
        default { 
            Write-Error "Unknown command: $Command"
            Write-Host ""
            Show-Help
            exit 1
        }
    }
} catch {
    Write-Error "Command failed: $($_.Exception.Message)"
    exit 1
}
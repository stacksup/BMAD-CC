#!/usr/bin/env pwsh
# Simple self-installation script for BMAD-CC
param()

$ErrorActionPreference = "Stop"

Write-Host "🚀 Installing BMAD-CC framework on itself..." -ForegroundColor Cyan

# Project configuration
$ProjectName = "BMAD-CC"
$ProjectType = "other"
$PRDPath = ""
$FrontendDir = "frontend"  
$BackendDir = "backend"
$FrontendPort = 3000
$BackendPort = 8001
$DockerComposeFile = ""
$TaskmasterCLI = "task-master"

# Create token replacement map
$map = @{
    "{{PROJECT_NAME}}" = $ProjectName
    "{{PROJECT_TYPE}}" = $ProjectType
    "{{PRD_PATH}}" = $PRDPath
    "{{SECONDARY_PRD_PATH}}" = ""
    "{{FRONTEND_DIR}}" = $FrontendDir
    "{{BACKEND_DIR}}" = $BackendDir
    "{{FRONTEND_PORT}}" = $FrontendPort
    "{{BACKEND_PORT}}" = $BackendPort
    "{{DOCKER_COMPOSE_FILE}}" = $DockerComposeFile
    "{{TASKMASTER_CLI}}" = $TaskmasterCLI
}

# Function to replace tokens
function Replace-Tokens {
    param([string]$Content, [hashtable]$TokenMap)
    
    foreach ($key in $TokenMap.Keys) {
        $Content = $Content -replace [regex]::Escape($key), $TokenMap[$key]
    }
    return $Content
}

# Function to copy and process template files
function Copy-Templates {
    param([string]$SourceDir, [string]$DestDir)
    
    if (-not (Test-Path $SourceDir)) {
        Write-Warning "Source directory not found: $SourceDir"
        return
    }
    
    $templates = Get-ChildItem -Path $SourceDir -Recurse -Filter "*.tmpl"
    foreach ($template in $templates) {
        $relativePath = $template.FullName.Substring($SourceDir.Length + 1)
        $destPath = $relativePath -replace "\.tmpl$", ""
        $fullDestPath = Join-Path $DestDir $destPath
        
        # Create destination directory if needed
        $destDirPath = Split-Path $fullDestPath -Parent
        if (-not (Test-Path $destDirPath)) {
            New-Item -ItemType Directory -Force -Path $destDirPath | Out-Null
        }
        
        # Read, process, and write template
        $content = Get-Content $template.FullName -Raw -Encoding UTF8
        $processed = Replace-Tokens -Content $content -TokenMap $map
        Set-Content -Path $fullDestPath -Value $processed -Encoding UTF8
        
        Write-Host "✅ $relativePath → $destPath" -ForegroundColor Green
    }
}

# Copy templates
Write-Host "`n📁 Copying templates..." -ForegroundColor Cyan
Copy-Templates -SourceDir "templates" -DestDir "."

# Create .claude directory if it doesn't exist
if (-not (Test-Path ".claude")) {
    New-Item -ItemType Directory -Force -Path ".claude" | Out-Null
}

# Create docs directories
$docsDirs = @("docs/templates", "docs/validation", "docs/changes", "docs/lessons", "docs/story-notes")
foreach ($dir in $docsDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

Write-Host "`n✅ BMAD-CC framework installed on itself!" -ForegroundColor Green
Write-Host "🔄 Restart Claude Code to load new commands" -ForegroundColor Yellow
Write-Host "🎯 Try: /bmad:smart-cycle" -ForegroundColor Cyan
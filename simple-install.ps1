# Simple BMAD-CC self-installation
param()

$ErrorActionPreference = "Stop"

Write-Host "Installing BMAD-CC framework on itself..." -ForegroundColor Cyan

# Project configuration
$ProjectName = "BMAD-CC"
$ProjectType = "other"

# Create token replacement map
$map = @{
    "{{PROJECT_NAME}}" = $ProjectName
    "{{PROJECT_TYPE}}" = $ProjectType
    "{{PRD_PATH}}" = ""
    "{{SECONDARY_PRD_PATH}}" = ""
    "{{FRONTEND_DIR}}" = "frontend"
    "{{BACKEND_DIR}}" = "backend"
    "{{FRONTEND_PORT}}" = "3000"
    "{{BACKEND_PORT}}" = "8001"
    "{{DOCKER_COMPOSE_FILE}}" = ""
    "{{TASKMASTER_CLI}}" = "task-master"
}

# Function to replace tokens
function Replace-Tokens {
    param([string]$Content, [hashtable]$TokenMap)
    
    foreach ($key in $TokenMap.Keys) {
        $Content = $Content -replace [regex]::Escape($key), $TokenMap[$key]
    }
    return $Content
}

# Create .claude directory if needed
if (-not (Test-Path ".claude")) {
    New-Item -ItemType Directory -Force -Path ".claude" | Out-Null
}

# Process templates/.claude directory
if (Test-Path "templates/.claude") {
    $templates = Get-ChildItem -Path "templates/.claude" -Recurse -Filter "*.tmpl"
    foreach ($template in $templates) {
        $relativePath = $template.FullName.Substring((Resolve-Path "templates/.claude").Path.Length + 1)
        $destPath = $relativePath -replace "\.tmpl$", ""
        $fullDestPath = Join-Path ".claude" $destPath
        
        # Create destination directory
        $destDirPath = Split-Path $fullDestPath -Parent
        if (-not (Test-Path $destDirPath)) {
            New-Item -ItemType Directory -Force -Path $destDirPath | Out-Null
        }
        
        # Process template
        $content = Get-Content $template.FullName -Raw -Encoding UTF8
        $processed = Replace-Tokens -Content $content -TokenMap $map
        Set-Content -Path $fullDestPath -Value $processed -Encoding UTF8
        
        Write-Host "Processed: $destPath" -ForegroundColor Green
    }
}

# Create docs directories
$docsDirs = @("docs/templates", "docs/validation", "docs/changes", "docs/lessons", "docs/story-notes")
foreach ($dir in $docsDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# Process templates/docs directory
if (Test-Path "templates/docs") {
    $templates = Get-ChildItem -Path "templates/docs" -Recurse -Filter "*.tmpl"
    foreach ($template in $templates) {
        $relativePath = $template.FullName.Substring((Resolve-Path "templates/docs").Path.Length + 1)
        $destPath = $relativePath -replace "\.tmpl$", ""
        $fullDestPath = Join-Path "docs" $destPath
        
        # Create destination directory
        $destDirPath = Split-Path $fullDestPath -Parent
        if (-not (Test-Path $destDirPath)) {
            New-Item -ItemType Directory -Force -Path $destDirPath | Out-Null
        }
        
        # Process template
        $content = Get-Content $template.FullName -Raw -Encoding UTF8
        $processed = Replace-Tokens -Content $content -TokenMap $map
        Set-Content -Path $fullDestPath -Value $processed -Encoding UTF8
        
        Write-Host "Processed docs: $destPath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "BMAD-CC framework installed on itself!" -ForegroundColor Green
Write-Host "Restart Claude Code to load new commands" -ForegroundColor Yellow
Write-Host "Try: /bmad:smart-cycle" -ForegroundColor Cyan
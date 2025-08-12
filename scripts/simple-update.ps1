#!/usr/bin/env pwsh
param(
    [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

Write-Host "🔄 BMAD Framework Simple Update" -ForegroundColor Cyan

# Check if we're in a BMAD project
if (-not (Test-Path ".claude\agents")) {
    Write-Host "❌ Not a BMAD project directory." -ForegroundColor Red
    exit 1
}

$ProjectName = Split-Path (Get-Location) -Leaf
Write-Host "📁 Project: $ProjectName" -ForegroundColor White

# Check current version
$currentVersion = "unknown"
if (Test-Path ".bmad-version") {
    $currentVersion = Get-Content ".bmad-version" -Raw | ForEach-Object { $_.Trim() }
}
Write-Host "📋 Current version: $currentVersion" -ForegroundColor Gray

# Check for updates from GitHub
Write-Host "🔍 Checking GitHub for updates..." -ForegroundColor Yellow

try {
    $githubApi = "https://api.github.com/repos/stacksup/BMAD-CC/commits/main"
    $response = Invoke-RestMethod -Uri $githubApi -ErrorAction Stop
    $latestVersion = $response.sha.Substring(0, 8)
    $latestMessage = $response.commit.message.Split("`n")[0]
    
    Write-Host "🚀 Latest version: $latestVersion" -ForegroundColor Green
    Write-Host "   $latestMessage" -ForegroundColor Gray
    
} catch {
    Write-Host "⚠️  Could not check GitHub: $($_.Exception.Message)" -ForegroundColor Yellow
    $latestVersion = "unknown"
}

# Check if update is needed
$updateNeeded = ($currentVersion -ne $latestVersion -and $latestVersion -ne "unknown")

if (-not $updateNeeded) {
    Write-Host "✅ BMAD framework is up to date!" -ForegroundColor Green
    exit 0
}

if ($CheckOnly) {
    Write-Host "📦 Updates available!" -ForegroundColor Yellow
    Write-Host "   Run without -CheckOnly to apply updates." -ForegroundColor Gray
    exit 0
}

# Apply updates
Write-Host "📦 Installing lessons system..." -ForegroundColor Cyan

# Create lesson directories
$lessonDirs = @(
    "docs\lessons",
    "docs\lessons\templates", 
    "docs\lessons\project-implementation",
    "docs\lessons\bmad-workflow",
    "docs\lessons\technology-patterns", 
    "docs\lessons\troubleshooting",
    "scripts\lessons"
)

foreach ($dir in $lessonDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "   ✅ Created: $dir" -ForegroundColor Green
    }
}

# Simple token replacement function
function Apply-SimpleTemplate {
    param($Content, $Destination)
    
    $Content = $Content -replace "{{PROJECT_NAME}}", $ProjectName
    $Content = $Content -replace "{{DATE}}", (Get-Date -Format "yyyy-MM-dd")
    $Content = $Content -replace "{{PROJECT_TYPE}}", "other"
    $Content = $Content -replace "{{AGENT_NAME}}", "Framework Update"
    
    Set-Content -Path $Destination -Value $Content -Encoding UTF8
}

# Download and install key lesson files
$lessonFiles = @{
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/index.md.tmpl" = "docs\lessons\index.md"
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/README.md.tmpl" = "docs\lessons\README.md"
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/scripts/lessons/search-lessons.ps1.tmpl" = "scripts\lessons\search-lessons.ps1"
}

$updated = 0
foreach ($url in $lessonFiles.Keys) {
    try {
        $destination = $lessonFiles[$url]
        $content = Invoke-RestMethod -Uri $url
        
        Apply-SimpleTemplate -Content $content -Destination $destination
        Write-Host "   ✅ Installed: $destination" -ForegroundColor Green
        $updated++
        
    } catch {
        Write-Host "   ❌ Failed: $destination - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Initialize metadata files if they don't exist
$metadataFiles = @{
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/project-implementation/metadata.json.tmpl" = "docs\lessons\project-implementation\metadata.json"
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/bmad-workflow/metadata.json.tmpl" = "docs\lessons\bmad-workflow\metadata.json"
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/technology-patterns/metadata.json.tmpl" = "docs\lessons\technology-patterns\metadata.json"
    "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/troubleshooting/metadata.json.tmpl" = "docs\lessons\troubleshooting\metadata.json"
}

foreach ($url in $metadataFiles.Keys) {
    try {
        $destination = $metadataFiles[$url]
        if (-not (Test-Path $destination)) {
            $content = Invoke-RestMethod -Uri $url
            Apply-SimpleTemplate -Content $content -Destination $destination
            Write-Host "   ✅ Initialized: $destination" -ForegroundColor Green
            $updated++
        }
    } catch {
        Write-Host "   ⚠️  Could not initialize: $destination" -ForegroundColor Yellow
    }
}

# Update version
$latestVersion | Set-Content -Path ".bmad-version" -NoNewline

# Summary
Write-Host "`n✅ Update Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor White
Write-Host "   Updated: $updated files" -ForegroundColor Green
Write-Host "   Version: $currentVersion → $latestVersion" -ForegroundColor Cyan

Write-Host "`n💡 New Features Available:" -ForegroundColor Cyan
Write-Host "   📚 Lessons System - Extract insights from development challenges" -ForegroundColor White
Write-Host "   🔍 Search Tool - scripts\lessons\search-lessons.ps1" -ForegroundColor White
Write-Host "   🤖 Smart Agents - Agents now leverage organizational knowledge" -ForegroundColor White

Write-Host "`n🚀 Your BMAD framework is up to date!" -ForegroundColor Green
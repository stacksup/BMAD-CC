#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Simple, seamless BMAD framework update from GitHub
.DESCRIPTION
    Checks GitHub for BMAD updates and applies them while preserving
    local customizations. Designed to be run from any BMAD project.
.PARAMETER Force
    Force update even if no changes detected
.PARAMETER CheckOnly
    Only check for updates, don't apply them
.EXAMPLE
    .\scripts\update-framework.ps1
    Check for and apply updates
.EXAMPLE
    powershell -c "iwr https://raw.githubusercontent.com/YOUR_USERNAME/BMAD-CC/main/scripts/update-framework.ps1 | iex"
    Update from anywhere via web
#>

param(
    [switch]$Force,
    [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

Write-Host "🔄 BMAD Framework Update" -ForegroundColor Cyan
Write-Host "=" * 30 -ForegroundColor Cyan

# Check if we're in a BMAD project
if (-not (Test-Path ".claude\agents")) {
    Write-Host "❌ Not a BMAD project directory." -ForegroundColor Red
    Write-Host "   Run this from a project with BMAD framework installed." -ForegroundColor Yellow
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
    # Get latest commit hash as version
    $githubApi = "https://api.github.com/repos/stacksup/BMAD-CC/commits/main"
    $response = Invoke-RestMethod -Uri $githubApi -ErrorAction Stop
    $latestVersion = $response.sha.Substring(0, 8)
    $latestMessage = $response.commit.message.Split("`n")[0]
    
    Write-Host "🚀 Latest version: $latestVersion" -ForegroundColor Green
    Write-Host "   $latestMessage" -ForegroundColor Gray
    
} catch {
    Write-Host "⚠️  Could not check GitHub. Using fallback method..." -ForegroundColor Yellow
    $latestVersion = "unknown"
}

# Check if update is needed
$updateNeeded = $Force -or ($currentVersion -ne $latestVersion -and $latestVersion -ne "unknown")

if (-not $updateNeeded) {
    Write-Host "✅ BMAD framework is up to date!" -ForegroundColor Green
    exit 0
}

if ($CheckOnly) {
    Write-Host "📦 Updates available!" -ForegroundColor Yellow
    Write-Host "   Run without -CheckOnly to apply updates." -ForegroundColor Gray
    exit 0
}

Write-Host "📦 Applying updates..." -ForegroundColor Cyan

# Simple approach: Download specific files we know we need
$filesToUpdate = @(
    @{ 
        url = "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/.claude/agents/learnings-agent.md.tmpl"
        dest = ".claude\agents\learnings-agent.md"
        desc = "Learnings Agent"
        backup = $true
    },
    @{ 
        url = "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/README.md.tmpl"
        dest = "docs\lessons\README.md"
        desc = "Lessons System README"
        backup = $false
    }
)

# Function to apply template with smart preservation
function Apply-Template {
    param($Content, $Destination, $PreserveCustomizations = $true)
    
    # Simple token replacement
    $tokens = @{
        "{{PROJECT_NAME}}" = $ProjectName
        "{{DATE}}" = (Get-Date -Format "yyyy-MM-dd")
        "{{PROJECT_TYPE}}" = "other"
        "{{AGENT_NAME}}" = "Framework Update"
    }
    
    foreach ($token in $tokens.Keys) {
        $Content = $Content -replace [regex]::Escape($token), $tokens[$token]
    }
    
    # Smart preservation for agent files
    if ($PreserveCustomizations -and (Test-Path $Destination) -and $Destination -like "*.claude\agents\*") {
        $Content = Merge-AgentFile -NewContent $Content -ExistingFile $Destination
    }
    
    $destDir = Split-Path $Destination -Parent
    if ($destDir -and -not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    Set-Content -Path $Destination -Value $Content -Encoding UTF8
}

# Function to merge agent files preserving customizations
function Merge-AgentFile {
    param($NewContent, $ExistingFile)
    
    $existing = Get-Content $ExistingFile -Raw
    
    # Extract YAML frontmatter from both files
    if ($existing -match '^---\s*\n(.*?)\n---\s*\n(.*)$') {
        $existingYaml = $Matches[1]
        $existingBody = $Matches[2]
    } else {
        Write-Host "   ⚠️  Could not parse existing agent file - using new version" -ForegroundColor Yellow
        return $NewContent
    }
    
    if ($NewContent -match '^---\s*\n(.*?)\n---\s*\n(.*)$') {
        $newYaml = $Matches[1]
        $newBody = $Matches[2]
    } else {
        Write-Host "   ⚠️  Could not parse new agent template - using existing file" -ForegroundColor Yellow
        return $existing
    }
    
    # Parse YAML frontmatter to preserve user customizations
    $preservedFields = @{}
    $existingYaml -split "`n" | ForEach-Object {
        if ($_ -match '^(\w+):\s*(.+)$') {
            $field = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            
            # Fields that users commonly customize - preserve these
            if ($field -in @('color', 'name', 'description')) {
                $preservedFields[$field] = $value
            }
        }
    }
    
    # Build merged YAML frontmatter
    $mergedYaml = ""
    $newYaml -split "`n" | ForEach-Object {
        if ($_ -match '^(\w+):\s*(.+)$') {
            $field = $Matches[1].Trim()
            $defaultValue = $Matches[2].Trim()
            
            if ($preservedFields.ContainsKey($field)) {
                # Use preserved user customization
                $mergedYaml += "$field`: $($preservedFields[$field])`n"
                Write-Host "   🎨 Preserved customization: $field = $($preservedFields[$field])" -ForegroundColor Cyan
            } else {
                # Use new template value
                $mergedYaml += "$_`n"
            }
        } else {
            $mergedYaml += "$_`n"
        }
    }
    
    # Combine preserved YAML with new body content
    return "---`n$mergedYaml---`n$newBody"
}

# Update files
$updated = 0
$skipped = 0

foreach ($file in $filesToUpdate) {
    try {
        $shouldUpdate = $Force
        
        if (-not $shouldUpdate) {
            if (-not (Test-Path $file.dest)) {
                $shouldUpdate = $true
                $action = "CREATE"
            } else {
                Write-Host "❓ Update $($file.desc)? (Y/n)" -ForegroundColor Yellow
                $response = Read-Host
                if ($response -notmatch '^[Nn]') {
                    $shouldUpdate = $true
                    $action = "UPDATE"
                }
            }
        } else {
            $action = "FORCE"
        }
        
        if ($shouldUpdate) {
            Write-Host "   $action : $($file.desc)" -ForegroundColor Green
            
            # Backup if requested
            if ($file.backup -and (Test-Path $file.dest)) {
                $backupPath = "$($file.dest).backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Copy-Item $file.dest $backupPath
                Write-Host "     💾 Backup: $backupPath" -ForegroundColor Gray
            }
            
            # Download and apply
            $content = Invoke-RestMethod -Uri $file.url
            Apply-Template -Content $content -Destination $file.dest
            $updated++
            
        } else {
            Write-Host "   SKIP: $($file.desc)" -ForegroundColor Gray
            $skipped++
        }
        
    } catch {
        Write-Host "   ❌ FAILED: $($file.desc) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Install lessons system if missing
if (-not (Test-Path "docs\lessons")) {
    Write-Host "   📚 Installing Lessons System..." -ForegroundColor Cyan
    
    # Create directories
    @(
        "docs\lessons",
        "docs\lessons\templates", 
        "docs\lessons\project-implementation",
        "docs\lessons\bmad-workflow",
        "docs\lessons\technology-patterns", 
        "docs\lessons\troubleshooting",
        "scripts\lessons"
    ) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
    
    # Download key lesson files
    $lessonFiles = @(
        "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/docs/lessons/index.md.tmpl",
        "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/templates/scripts/lessons/search-lessons.ps1.tmpl"
    )
    
    $lessonFiles | ForEach-Object {
        try {
            $content = Invoke-RestMethod -Uri $_
            $fileName = Split-Path $_ -Leaf
            $destination = if ($fileName.EndsWith(".ps1.tmpl")) {
                "scripts\lessons\search-lessons.ps1"
            } else {
                "docs\lessons\index.md" 
            }
            
            Apply-Template -Content $content -Destination $destination
            Write-Host "     ✅ $fileName" -ForegroundColor Green
            $updated++
            
        } catch {
            Write-Host "     ❌ Failed: $fileName" -ForegroundColor Red
        }
    }
}

# Update version file
$latestVersion | Set-Content -Path ".bmad-version" -NoNewline

# Summary
Write-Host "`n✅ Update Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor White
Write-Host "   Updated: $updated files" -ForegroundColor Green
Write-Host "   Skipped: $skipped files" -ForegroundColor Yellow
Write-Host "   Version: $currentVersion → $latestVersion" -ForegroundColor Cyan

if (Test-Path "docs\lessons") {
    Write-Host "`n💡 New Features Available:" -ForegroundColor Cyan
    Write-Host "   📚 Lessons System - Extract insights from development challenges" -ForegroundColor White
    Write-Host "   🔍 Search Tool - scripts\lessons\search-lessons.ps1" -ForegroundColor White
    Write-Host "   🤖 Smart Agents - Agents now leverage organizational knowledge" -ForegroundColor White
}

Write-Host "`n🚀 Your BMAD framework is up to date!" -ForegroundColor Green
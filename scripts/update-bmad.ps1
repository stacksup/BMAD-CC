#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update current BMAD installation with latest framework changes
.DESCRIPTION
    This script updates the current BMAD-CC installation by re-applying
    templates and adding new features without overwriting existing content.
.PARAMETER Force
    Force overwrite of existing files (use with caution)
.PARAMETER DryRun
    Show what would be updated without making changes
.PARAMETER Component
    Update specific component: agents, commands, hooks, lessons, all
.EXAMPLE
    .\scripts\update-bmad.ps1
    Update all BMAD components with safe defaults
.EXAMPLE
    .\scripts\update-bmad.ps1 -Component lessons -Force
    Force update just the lessons system
#>

param(
    [switch]$Force,
    [switch]$DryRun,
    [ValidateSet("agents", "commands", "hooks", "lessons", "all")]
    [string]$Component = "all"
)

$ErrorActionPreference = "Stop"

Write-Host "🔄 BMAD Framework Update Tool" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# Detect current project settings
$ProjectDir = Get-Location
$ProjectName = Split-Path $ProjectDir -Leaf

# Auto-detect project type (same logic as setup.ps1)
$ProjectType = "other"
if (Test-Path "frontend/package.json" -and Test-Path "backend") { 
    $ProjectType = "saas" 
    Write-Host "📦 Detected SaaS project" -ForegroundColor Green
} elseif (Test-Path "src/client" -or Test-Path "package.json") { 
    $ProjectType = "phaser" 
    Write-Host "🎮 Detected Phaser project" -ForegroundColor Green
} else { 
    Write-Host "📁 Using 'other' project type" -ForegroundColor Yellow
}

# Check if this is a BMAD-enabled project
if (-not (Test-Path ".claude/agents")) {
    Write-Host "❌ This doesn't appear to be a BMAD-enabled project." -ForegroundColor Red
    Write-Host "Run setup.ps1 first to initialize BMAD framework." -ForegroundColor Yellow
    exit 1
}

Write-Host "🎯 Updating: $ProjectName ($ProjectType)" -ForegroundColor White
if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}

# Template application function
function Apply-UpdateTemplate {
    param($TemplatePath, $DestPath, $Description)

    if (-not (Test-Path $TemplatePath)) {
        Write-Host "⚠️  Template not found: $TemplatePath" -ForegroundColor Yellow
        return
    }

    $shouldUpdate = $false
    $action = ""

    if (-not (Test-Path $DestPath)) {
        $shouldUpdate = $true
        $action = "CREATE"
    } elseif ($Force) {
        $shouldUpdate = $true
        $action = "OVERWRITE"
    } else {
        # Check if template is newer than existing file
        $templateTime = (Get-Item $TemplatePath).LastWriteTime
        $destTime = (Get-Item $DestPath).LastWriteTime
        
        if ($templateTime -gt $destTime) {
            Write-Host "🤔 $Description is newer in templates. Update? (y/N)" -ForegroundColor Yellow
            $response = Read-Host
            if ($response -match '^[Yy]') {
                $shouldUpdate = $true
                $action = "UPDATE"
            }
        }
    }

    if ($shouldUpdate) {
        if ($DryRun) {
            Write-Host "   Would $action`: $Description" -ForegroundColor Cyan
            return
        }

        Write-Host "   $action`: $Description" -ForegroundColor Green

        # Apply template with token replacement
        $content = Get-Content $TemplatePath -Raw
        
        $tokens = @{
            "{{PROJECT_NAME}}" = $ProjectName
            "{{PROJECT_TYPE}}" = $ProjectType
            "{{DATE}}" = (Get-Date -Format "yyyy-MM-dd")
            "{{AGENT_NAME}}" = "Update System"
        }

        foreach ($token in $tokens.Keys) {
            $content = $content -replace [regex]::Escape($token), $tokens[$token]
        }

        $destDir = Split-Path $DestPath -Parent
        if (-not (Test-Path $destDir)) { 
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null 
        }
        
        Set-Content -Path $DestPath -Value $content -Encoding UTF8
    } else {
        Write-Host "   SKIP: $Description (already current)" -ForegroundColor Gray
    }
}

# Create directories if needed
function Ensure-Directory {
    param($Path, $Description)
    
    if (-not (Test-Path $Path)) {
        if ($DryRun) {
            Write-Host "   Would CREATE DIR: $Description" -ForegroundColor Cyan
        } else {
            Write-Host "   CREATE DIR: $Description" -ForegroundColor Green
            New-Item -ItemType Directory -Force -Path $Path | Out-Null
        }
    }
}

# Update functions by component
function Update-Agents {
    Write-Host "`n🤖 Updating BMAD Agents..." -ForegroundColor Cyan
    
    $agentUpdates = @(
        @{ template = "templates/.claude/agents/learnings-agent.md.tmpl"; dest = ".claude/agents/learnings-agent.md"; desc = "Learnings Agent" },
        @{ template = "templates/.claude/agents/dev-agent.md.tmpl"; dest = ".claude/agents/dev-agent.md"; desc = "Development Agent" },
        @{ template = "templates/.claude/agents/architect-agent.md.tmpl"; dest = ".claude/agents/architect-agent.md"; desc = "System Architect Agent" },
        @{ template = "templates/.claude/agents/qa-agent.md.tmpl"; dest = ".claude/agents/qa-agent.md"; desc = "QA Agent" }
    )

    foreach ($update in $agentUpdates) {
        Apply-UpdateTemplate -TemplatePath $update.template -DestPath $update.dest -Description $update.desc
    }
}

function Update-Lessons {
    Write-Host "`n📚 Updating Lessons System..." -ForegroundColor Cyan
    
    # Ensure lesson directories exist
    $lessonDirs = @(
        "docs/lessons",
        "docs/lessons/templates", 
        "docs/lessons/project-implementation",
        "docs/lessons/bmad-workflow",
        "docs/lessons/technology-patterns",
        "docs/lessons/troubleshooting",
        "scripts/lessons"
    )

    foreach ($dir in $lessonDirs) {
        Ensure-Directory -Path $dir -Description "Lessons: $dir"
    }

    # Update lesson system files
    $lessonUpdates = @(
        @{ template = "templates/docs/lessons/index.md.tmpl"; dest = "docs/lessons/index.md"; desc = "Lessons Index" },
        @{ template = "templates/docs/lessons/README.md.tmpl"; dest = "docs/lessons/README.md"; desc = "Lessons README" },
        @{ template = "templates/docs/lessons/templates/project-lesson.md.tmpl"; dest = "docs/lessons/templates/project-lesson.md.tmpl"; desc = "Project Lesson Template" },
        @{ template = "templates/docs/lessons/templates/workflow-lesson.md.tmpl"; dest = "docs/lessons/templates/workflow-lesson.md.tmpl"; desc = "Workflow Lesson Template" },
        @{ template = "templates/docs/lessons/templates/technology-lesson.md.tmpl"; dest = "docs/lessons/templates/technology-lesson.md.tmpl"; desc = "Technology Lesson Template" },
        @{ template = "templates/docs/lessons/templates/troubleshooting-lesson.md.tmpl"; dest = "docs/lessons/templates/troubleshooting-lesson.md.tmpl"; desc = "Troubleshooting Lesson Template" },
        @{ template = "templates/scripts/lessons/search-lessons.ps1.tmpl"; dest = "scripts/lessons/search-lessons.ps1"; desc = "Lesson Search Tool" }
    )

    foreach ($update in $lessonUpdates) {
        Apply-UpdateTemplate -TemplatePath $update.template -DestPath $update.dest -Description $update.desc
    }

    # Initialize metadata files if they don't exist
    $metadataFiles = @(
        @{ template = "templates/docs/lessons/project-implementation/metadata.json.tmpl"; dest = "docs/lessons/project-implementation/metadata.json"; desc = "Project Implementation Metadata" },
        @{ template = "templates/docs/lessons/bmad-workflow/metadata.json.tmpl"; dest = "docs/lessons/bmad-workflow/metadata.json"; desc = "BMAD Workflow Metadata" },
        @{ template = "templates/docs/lessons/technology-patterns/metadata.json.tmpl"; dest = "docs/lessons/technology-patterns/metadata.json"; desc = "Technology Patterns Metadata" },
        @{ template = "templates/docs/lessons/troubleshooting/metadata.json.tmpl"; dest = "docs/lessons/troubleshooting/metadata.json"; desc = "Troubleshooting Metadata" }
    )

    foreach ($metadata in $metadataFiles) {
        if (-not (Test-Path $metadata.dest)) {
            Apply-UpdateTemplate -TemplatePath $metadata.template -DestPath $metadata.dest -Description $metadata.desc
        } else {
            Write-Host "   SKIP: $($metadata.desc) (preserving existing data)" -ForegroundColor Gray
        }
    }
}

function Update-Hooks {
    Write-Host "`n🪝 Updating BMAD Hooks..." -ForegroundColor Cyan
    
    $hookUpdates = @(
        @{ template = "templates/.claude/hooks/lesson-extraction-gate.ps1.tmpl"; dest = ".claude/hooks/lesson-extraction-gate.ps1"; desc = "Lesson Extraction Gate" }
    )

    foreach ($update in $hookUpdates) {
        Apply-UpdateTemplate -TemplatePath $update.template -DestPath $update.dest -Description $update.desc
    }
}

function Update-Commands {
    Write-Host "`n⚡ Checking BMAD Commands..." -ForegroundColor Cyan
    Write-Host "   Commands are typically project-specific and preserved during updates" -ForegroundColor Gray
    
    # Could add command updates here if needed
    # For now, commands are left as-is to preserve project customizations
}

# Main execution
$scriptPath = $PSCommandPath
$bmadRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)

# Change to BMAD framework directory if we're in a project
if ((Split-Path $bmadRoot -Leaf) -ne "BMAD-CC") {
    Write-Host "🔍 Looking for BMAD framework..." -ForegroundColor Yellow
    
    # Common locations to check
    $possibleLocations = @(
        "C:\Users\$env:USERNAME\AI-Projects\BMAD-CC",
        "$env:USERPROFILE\AI-Projects\BMAD-CC",
        "$env:HOME\AI-Projects\BMAD-CC"
    )
    
    $bmadFound = $false
    foreach ($location in $possibleLocations) {
        if (Test-Path "$location\scripts\setup.ps1") {
            Push-Location $location
            $bmadRoot = $location
            $bmadFound = $true
            Write-Host "✅ Found BMAD framework at: $location" -ForegroundColor Green
            break
        }
    }
    
    if (-not $bmadFound) {
        Write-Host "❌ Could not locate BMAD framework directory." -ForegroundColor Red
        Write-Host "Please run this script from within the BMAD-CC repository." -ForegroundColor Yellow
        exit 1
    }
}

# Execute updates based on component selection
switch ($Component) {
    "agents" { Update-Agents }
    "commands" { Update-Commands }
    "hooks" { Update-Hooks }
    "lessons" { Update-Lessons }
    "all" {
        Update-Agents
        Update-Lessons
        Update-Hooks
        Update-Commands
    }
}

if ((Split-Path $bmadRoot -Leaf) -eq "BMAD-CC") {
    Pop-Location
}

Write-Host "`n✅ BMAD Update Complete!" -ForegroundColor Green

if (-not $DryRun) {
    Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Review updated files for any conflicts" -ForegroundColor White
    Write-Host "   2. Test agents and lesson system functionality" -ForegroundColor White  
    Write-Host "   3. Commit changes to preserve your updates" -ForegroundColor White
    
    if ($Component -eq "lessons" -or $Component -eq "all") {
        Write-Host "`n💡 Lessons System:" -ForegroundColor Cyan
        Write-Host "   • Start extracting lessons from completed stories" -ForegroundColor White
        Write-Host "   • Use: scripts/lessons/search-lessons.ps1 to find lessons" -ForegroundColor White
        Write-Host "   • Check: docs/lessons/index.md for lesson catalog" -ForegroundColor White
    }
}

Write-Host "`n🚀 Your BMAD installation is now up to date!" -ForegroundColor Green
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy BMAD updates to multiple projects
.DESCRIPTION
    This script deploys the latest BMAD framework changes to specified projects
    or automatically discovers BMAD-enabled projects and updates them.
.PARAMETER ProjectPaths
    Comma-separated list of project paths to update
.PARAMETER AutoDiscover
    Automatically discover BMAD projects in common locations
.PARAMETER Component
    Update specific component: agents, commands, hooks, lessons, all
.PARAMETER Force
    Force overwrite existing files in target projects
.EXAMPLE
    .\scripts\deploy-to-projects.ps1 -AutoDiscover
    Find and update all BMAD projects automatically
.EXAMPLE
    .\scripts\deploy-to-projects.ps1 -ProjectPaths "C:\Projects\MyApp,C:\Projects\AnotherApp" -Component lessons
    Update lessons system in specific projects
#>

param(
    [string[]]$ProjectPaths = @(),
    [switch]$AutoDiscover,
    [ValidateSet("agents", "commands", "hooks", "lessons", "all")]
    [string]$Component = "all",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 BMAD Multi-Project Deployment Tool" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# Ensure we're in the BMAD framework directory
if (-not (Test-Path "scripts/setup.ps1")) {
    Write-Host "❌ This script must be run from the BMAD-CC framework directory." -ForegroundColor Red
    exit 1
}

$bmadRoot = Get-Location

# Function to check if a directory contains a BMAD project
function Test-BMADProject {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) { return $false }
    
    return (Test-Path "$Path\.claude\agents") -and 
           (Test-Path "$Path\.claude\commands") -and
           (Test-Path "$Path\.claude\hooks")
}

# Function to discover BMAD projects
function Find-BMADProjects {
    Write-Host "🔍 Discovering BMAD-enabled projects..." -ForegroundColor Yellow
    
    $searchPaths = @(
        "$env:USERPROFILE\AI-Projects",
        "$env:USERPROFILE\Projects", 
        "$env:USERPROFILE\Development",
        "$env:USERPROFILE\Code",
        "C:\Projects",
        "C:\Development",
        "C:\Code"
    )
    
    $foundProjects = @()
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            Write-Host "   Searching: $searchPath" -ForegroundColor Gray
            
            Get-ChildItem -Path $searchPath -Directory | ForEach-Object {
                if (Test-BMADProject -Path $_.FullName) {
                    $foundProjects += $_.FullName
                    Write-Host "   ✅ Found: $($_.Name)" -ForegroundColor Green
                }
            }
        }
    }
    
    if ($foundProjects.Count -eq 0) {
        Write-Host "   No BMAD projects found in common locations." -ForegroundColor Yellow
        Write-Host "   Try specifying project paths manually with -ProjectPaths" -ForegroundColor Gray
    } else {
        Write-Host "   Discovered $($foundProjects.Count) BMAD project(s)" -ForegroundColor Green
    }
    
    return $foundProjects
}

# Function to update a single project
function Update-Project {
    param(
        [string]$ProjectPath,
        [string]$Component,
        [switch]$Force
    )
    
    $projectName = Split-Path $ProjectPath -Leaf
    Write-Host "`n📁 Updating: $projectName" -ForegroundColor White
    Write-Host "   Path: $ProjectPath" -ForegroundColor Gray
    
    if (-not (Test-BMADProject -Path $ProjectPath)) {
        Write-Host "   ❌ Not a BMAD project - skipping" -ForegroundColor Red
        return $false
    }
    
    try {
        Push-Location $ProjectPath
        
        # Build the update command
        $updateScript = "$bmadRoot\scripts\update-bmad.ps1"
        $arguments = @("-Component", $Component)
        if ($Force) { $arguments += "-Force" }
        
        Write-Host "   🔄 Running update..." -ForegroundColor Cyan
        
        # Execute the update
        & $updateScript @arguments
        
        Write-Host "   ✅ Update completed" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "   ❌ Update failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
        
    } finally {
        Pop-Location
    }
}

# Main execution
$projectsToUpdate = @()

if ($AutoDiscover) {
    $projectsToUpdate = Find-BMADProjects
} elseif ($ProjectPaths.Count -gt 0) {
    $projectsToUpdate = $ProjectPaths
} else {
    Write-Host "❌ Please specify either -AutoDiscover or -ProjectPaths" -ForegroundColor Red
    Write-Host "`nUsage examples:" -ForegroundColor Yellow
    Write-Host "   .\scripts\deploy-to-projects.ps1 -AutoDiscover" -ForegroundColor Gray
    Write-Host "   .\scripts\deploy-to-projects.ps1 -ProjectPaths 'C:\Projects\MyApp'" -ForegroundColor Gray
    exit 1
}

if ($projectsToUpdate.Count -eq 0) {
    Write-Host "❌ No projects to update" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 Deployment Plan:" -ForegroundColor Cyan
Write-Host "   Component: $Component" -ForegroundColor White
Write-Host "   Force: $Force" -ForegroundColor White
Write-Host "   Projects: $($projectsToUpdate.Count)" -ForegroundColor White

foreach ($project in $projectsToUpdate) {
    Write-Host "   • $(Split-Path $project -Leaf)" -ForegroundColor Gray
}

Write-Host "`n❓ Proceed with deployment? (Y/n)" -ForegroundColor Yellow
$response = Read-Host
if ($response -match '^[Nn]') {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Execute deployments
$successCount = 0
$failureCount = 0

foreach ($projectPath in $projectsToUpdate) {
    $success = Update-Project -ProjectPath $projectPath -Component $Component -Force:$Force
    if ($success) {
        $successCount++
    } else {
        $failureCount++
    }
}

# Summary
Write-Host "`n📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "   ✅ Successful: $successCount" -ForegroundColor Green
Write-Host "   ❌ Failed: $failureCount" -ForegroundColor Red
Write-Host "   📁 Total: $($projectsToUpdate.Count)" -ForegroundColor White

if ($successCount -eq $projectsToUpdate.Count) {
    Write-Host "`n🎉 All projects updated successfully!" -ForegroundColor Green
} elseif ($successCount -gt 0) {
    Write-Host "`n⚠️  Some projects updated successfully, check failures above" -ForegroundColor Yellow
} else {
    Write-Host "`n💥 All deployments failed - check error messages above" -ForegroundColor Red
}

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Test updated projects to ensure functionality" -ForegroundColor White
Write-Host "   2. Commit changes in each updated project" -ForegroundColor White
Write-Host "   3. Start using new features (like lessons system)" -ForegroundColor White
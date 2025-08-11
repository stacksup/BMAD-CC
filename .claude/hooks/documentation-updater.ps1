#!/usr/bin/env pwsh
# Documentation Updater Hook for BMAD-CC
# Automatically updates documentation when tasks are completed

param(
    [string]$Action = "update",
    [string]$TaskId = "",
    [string]$TaskTitle = "",
    [string]$ChangeType = "feature"  # feature, fix, docs, refactor, test, chore
)

$ProjectRoot = Get-Location
$ChangelogPath = Join-Path $ProjectRoot "CHANGELOG.md"
$ReadmePath = Join-Path $ProjectRoot "README.md"
$StoryNotesDir = Join-Path $ProjectRoot "docs\story-notes"
$TaskmasterCLI = "task-master"

# Ensure story-notes directory exists
if (-not (Test-Path $StoryNotesDir)) {
    New-Item -ItemType Directory -Force -Path $StoryNotesDir | Out-Null
}

function Get-CurrentDate {
    return (Get-Date).ToString("yyyy-MM-dd")
}

function Get-TaskDetails {
    param([string]$TaskId)
    
    if ([string]::IsNullOrEmpty($TaskId)) {
        # Try to get current task from Task Master
        try {
            $currentTask = & $TaskmasterCLI current --json 2>$null | ConvertFrom-Json
            if ($currentTask) {
                return @{
                    Id = $currentTask.id
                    Title = $currentTask.title
                    Description = $currentTask.description
                    Status = $currentTask.status
                }
            }
        } catch {
            Write-Verbose "Could not get current task from Task Master"
        }
    }
    
    return @{
        Id = $TaskId
        Title = $TaskTitle
        Description = ""
        Status = "done"
    }
}

function Get-GitChanges {
    # Get list of changed files
    $changes = git diff --name-only HEAD~1 2>$null
    if (-not $changes) {
        $changes = git diff --name-only --cached 2>$null
    }
    
    return $changes
}

function Get-LastCommit {
    $commitSha = git rev-parse HEAD 2>$null
    $commitMessage = git log -1 --pretty=%B 2>$null
    
    return @{
        Sha = $commitSha
        Message = $commitMessage
    }
}

function Update-Changelog {
    param(
        [hashtable]$Task,
        [string]$ChangeType,
        [string]$CommitSha
    )
    
    Write-Host "📝 Updating CHANGELOG.md..." -ForegroundColor Cyan
    
    if (-not (Test-Path $ChangelogPath)) {
        # Create initial CHANGELOG
        $changelogContent = @"
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

"@
        Set-Content -Path $ChangelogPath -Value $changelogContent -Encoding UTF8
    }
    
    # Read current changelog
    $changelog = Get-Content $ChangelogPath -Raw
    
    # Determine section based on change type
    $section = switch ($ChangeType) {
        "feature" { "Added" }
        "fix" { "Fixed" }
        "docs" { "Documentation" }
        "refactor" { "Changed" }
        "test" { "Testing" }
        "chore" { "Maintenance" }
        default { "Changed" }
    }
    
    # Create entry
    $entry = "- [$($Task.Id)] $($Task.Title)"
    if ($CommitSha) {
        $shortSha = $CommitSha.Substring(0, 7)
        $entry += " (${shortSha})"
    }
    
    # Find or create section under [Unreleased]
    if ($changelog -match "## \[Unreleased\]") {
        if ($changelog -match "### $section") {
            # Add to existing section
            $changelog = $changelog -replace "(### $section\r?\n)", "`$1$entry`n"
        } else {
            # Create new section
            $changelog = $changelog -replace "(## \[Unreleased\]\r?\n)", "`$1`n### $section`n$entry`n"
        }
    }
    
    Set-Content -Path $ChangelogPath -Value $changelog -Encoding UTF8
    Write-Host "✅ CHANGELOG.md updated" -ForegroundColor Green
}

function Update-Readme {
    param([hashtable]$Task)
    
    $changes = Get-GitChanges
    $needsUpdate = $false
    $updates = @()
    
    # Check if README needs updating based on changes
    if ($changes -match "package\.json") {
        $updates += "dependencies"
        $needsUpdate = $true
    }
    
    if ($changes -match "docker|Dockerfile") {
        $updates += "docker"
        $needsUpdate = $true
    }
    
    if ($changes -match "\.env|config") {
        $updates += "configuration"
        $needsUpdate = $true
    }
    
    if ($changes -match "api|routes|endpoints") {
        $updates += "api"
        $needsUpdate = $true
    }
    
    if ($needsUpdate) {
        Write-Host "📝 README.md may need updates for: $($updates -join ', ')" -ForegroundColor Yellow
        Write-Host "   Please review and update manually if needed" -ForegroundColor Gray
    }
}

function Create-StoryDocumentation {
    param(
        [hashtable]$Task,
        [hashtable]$Commit
    )
    
    Write-Host "📝 Creating story documentation..." -ForegroundColor Cyan
    
    $date = Get-CurrentDate
    $storyFile = Join-Path $StoryNotesDir "$($Task.Id)-$(($Task.Title -replace '[^\w\s-]', '') -replace '\s+', '-').md"
    
    # Get changed files
    $changedFiles = Get-GitChanges
    
    # Get test results if available
    $testResults = "Tests not run"
    if (Test-Path "test-results.json") {
        $testResults = "See test-results.json"
    }
    
    $storyContent = @"
# Story: [$($Task.Id)] - $($Task.Title)

## Overview
$($Task.Description)

## Context
- **Task ID**: $($Task.Id)
- **Date Completed**: $date
- **Status**: $($Task.Status)

## Implementation

### Key Files Modified
$(if ($changedFiles) {
    $changedFiles | ForEach-Object { "- ``$_``" }
} else {
    "- No files tracked"
})

### Testing
$testResults

## Decisions & Trade-offs
_To be documented by development team_

## Lessons Learned
_To be documented by development team_

## Follow-up Items
- [ ] Review documentation completeness
- [ ] Update API documentation if needed
- [ ] Update deployment guide if needed

## References
- Commit: $($Commit.Sha)
- Message: $($Commit.Message)
"@
    
    Set-Content -Path $storyFile -Value $storyContent -Encoding UTF8
    Write-Host "✅ Story documentation created: $storyFile" -ForegroundColor Green
}

function Update-ApiDocumentation {
    $changes = Get-GitChanges
    
    if ($changes -match "api|routes|endpoints|controllers") {
        Write-Host "📝 API changes detected - documentation may need updating" -ForegroundColor Yellow
        
        $apiDocsPath = Join-Path $ProjectRoot "docs\api"
        if (-not (Test-Path $apiDocsPath)) {
            New-Item -ItemType Directory -Force -Path $apiDocsPath | Out-Null
        }
        
        # Create API change notice
        $noticeFile = Join-Path $apiDocsPath "CHANGES-$(Get-CurrentDate).md"
        $notice = @"
# API Changes - $(Get-CurrentDate)

## Changed Files
$(($changes | Where-Object { $_ -match "api|routes|endpoints|controllers" }) -join "`n")

## Action Required
- Review and update API documentation
- Update OpenAPI/Swagger specification if applicable
- Add examples for new endpoints
- Update SDK documentation if applicable
"@
        
        Set-Content -Path $noticeFile -Value $notice -Encoding UTF8
        Write-Host "✅ API change notice created: $noticeFile" -ForegroundColor Green
    }
}

function Show-DocumentationSummary {
    param([hashtable]$Task)
    
    Write-Host "`n📚 Documentation Update Summary" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Task: [$($Task.Id)] $($Task.Title)" -ForegroundColor White
    Write-Host ""
    Write-Host "Updated:" -ForegroundColor Green
    Write-Host "  ✅ CHANGELOG.md" -ForegroundColor Green
    Write-Host "  ✅ Story documentation" -ForegroundColor Green
    
    $changes = Get-GitChanges
    if ($changes -match "api|routes|endpoints") {
        Write-Host "  ⚠️  API documentation needs review" -ForegroundColor Yellow
    }
    if ($changes -match "docker|Dockerfile") {
        Write-Host "  ⚠️  Docker documentation needs review" -ForegroundColor Yellow
    }
    if ($changes -match "\.env|config") {
        Write-Host "  ⚠️  Configuration documentation needs review" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review generated documentation" -ForegroundColor White
    Write-Host "  2. Update README.md if needed" -ForegroundColor White
    Write-Host "  3. Add implementation details to story notes" -ForegroundColor White
    Write-Host "  4. Update API docs if endpoints changed" -ForegroundColor White
}

# Main execution
switch ($Action) {
    "update" {
        Write-Host "🚀 Starting documentation update..." -ForegroundColor Cyan
        
        # Get task details
        $task = Get-TaskDetails -TaskId $TaskId
        if (-not $task.Id) {
            Write-Warning "No task ID found. Skipping documentation update."
            exit 0
        }
        
        # Get commit information
        $commit = Get-LastCommit
        
        # Update documentation
        Update-Changelog -Task $task -ChangeType $ChangeType -CommitSha $commit.Sha
        Update-Readme -Task $task
        Create-StoryDocumentation -Task $task -Commit $commit
        Update-ApiDocumentation
        
        # Show summary
        Show-DocumentationSummary -Task $task
    }
    
    "check" {
        Write-Host "🔍 Checking documentation status..." -ForegroundColor Cyan
        
        $issues = @()
        
        if (-not (Test-Path $ChangelogPath)) {
            $issues += "CHANGELOG.md is missing"
        }
        
        if (-not (Test-Path $ReadmePath)) {
            $issues += "README.md is missing"
        }
        
        if (-not (Test-Path $StoryNotesDir)) {
            $issues += "Story notes directory is missing"
        }
        
        if ($issues.Count -eq 0) {
            Write-Host "✅ Documentation structure is complete" -ForegroundColor Green
        } else {
            Write-Host "❌ Documentation issues found:" -ForegroundColor Red
            $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        }
    }
    
    default {
        Write-Host "Usage: documentation-updater.ps1 -Action [update|check] -TaskId <id> -TaskTitle <title> -ChangeType <type>"
    }
}

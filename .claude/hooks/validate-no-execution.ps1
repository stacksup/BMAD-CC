# Validate No Execution During Planning - Ensures planning phase remains analysis-only
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,
    
    [Parameter(Mandatory=$true)]
    [string]$Phase
)

function Test-NoExecutionDuringPlanning {
    param($TaskId, $Phase)
    
    Write-Host "🔍 Validating no execution occurred during $Phase phase..." -ForegroundColor Cyan
    
    $executionViolations = @()
    
    # Check 1: Git repository status
    $gitChanges = git status --porcelain 2>$null
    if ($gitChanges) {
        $executionViolations += @{
            Type = "Git Changes"
            Details = "Modified files detected during planning phase"
            Files = ($gitChanges -split "`n" | ForEach-Object { $_.Trim() })
        }
    }
    
    # Check 2: Recently created/modified files (last 30 minutes)
    $recentFiles = Get-ChildItem -Recurse -File | Where-Object { 
        $_.LastWriteTime -gt (Get-Date).AddMinutes(-30) -and
        $_.Name -notmatch "^(\.git|node_modules|\.claude)" -and
        $_.Extension -in @('.js', '.ts', '.py', '.php', '.java', '.cs', '.cpp', '.c', '.go', '.rs')
    }
    
    if ($recentFiles) {
        $executionViolations += @{
            Type = "Recent Code Files"
            Details = "Code files modified in last 30 minutes during planning"
            Files = $recentFiles.FullName
        }
    }
    
    # Check 3: Planning documents for execution language
    $planningFiles = @(
        "docs/market-analysis.md",
        "docs/product-strategy.md",
        "docs/technical-architecture.md", 
        "docs/ux-design-spec.md",
        "docs/planning-summary.md"
    )
    
    foreach ($file in $planningFiles) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw
            
            # Look for execution verbs
            $executionVerbs = @(
                "implemented", "deployed", "created file", "modified file",
                "executed", "ran script", "built", "compiled", "installed",
                "configured", "set up", "launched", "started"
            )
            
            foreach ($verb in $executionVerbs) {
                if ($content -match "(?i)$verb") {
                    $executionViolations += @{
                        Type = "Execution Language"
                        Details = "Planning document contains execution language: '$verb'"
                        Files = @($file)
                    }
                    break
                }
            }
            
            # Look for implementation code blocks
            if ($content -match '```[\s\S]*?(function|class|def |public |private |const |let |var )') {
                $executionViolations += @{
                    Type = "Implementation Code"
                    Details = "Planning document contains implementation code"
                    Files = @($file)
                }
            }
        }
    }
    
    # Check 4: Task Master history for execution activities
    try {
        $taskHistory = & task-master get-history --id=$TaskId 2>$null | Out-String
        $executionIndicators = @(
            "file created", "code implemented", "deployment", 
            "execution", "build", "test run", "script executed"
        )
        
        foreach ($indicator in $executionIndicators) {
            if ($taskHistory -match "(?i)$indicator") {
                $executionViolations += @{
                    Type = "Task History"
                    Details = "Task history shows execution activity: '$indicator'"
                    Files = @("Task Master history")
                }
                break
            }
        }
    }
    catch {
        Write-Host "⚠️  Could not retrieve task history for validation" -ForegroundColor Yellow
    }
    
    # Check 5: Docker activity during planning (if applicable)
    try {
        $dockerPs = docker ps --format "table {{.Names}}\t{{.Status}}" 2>$null
        if ($dockerPs -and $Phase -eq "planning") {
            # Check if containers were started recently (planning shouldn't start containers)
            $recentContainers = docker ps --filter "status=running" --format "{{.Names}}" 2>$null
            if ($recentContainers) {
                $executionViolations += @{
                    Type = "Docker Activity"
                    Details = "Docker containers running during planning phase"
                    Files = ($recentContainers -split "`n")
                }
            }
        }
    }
    catch {
        # Docker not available or accessible - skip check
    }
    
    # Report violations
    if ($executionViolations.Count -gt 0) {
        Write-Host "❌ EXECUTION VIOLATIONS DETECTED DURING PLANNING:" -ForegroundColor Red
        Write-Host "" -ForegroundColor Red
        
        foreach ($violation in $executionViolations) {
            Write-Host "🚫 $($violation.Type):" -ForegroundColor Red
            Write-Host "   Details: $($violation.Details)" -ForegroundColor Red
            if ($violation.Files) {
                Write-Host "   Files/Items:" -ForegroundColor Red
                foreach ($file in $violation.Files) {
                    Write-Host "     - $file" -ForegroundColor Red
                }
            }
            Write-Host "" -ForegroundColor Red
        }
        
        Write-Host "COMPLIANCE REQUIREMENT:" -ForegroundColor Yellow
        Write-Host "Planning phase must be ANALYSIS ONLY - no execution allowed" -ForegroundColor Yellow
        Write-Host "Use orchestrator handoff to authorize execution workflows" -ForegroundColor Yellow
        
        return $false
    } else {
        Write-Host "✅ No execution detected during planning phase" -ForegroundColor Green
        Write-Host "   - No git changes found" -ForegroundColor Green
        Write-Host "   - No recent code modifications" -ForegroundColor Green
        Write-Host "   - Planning documents contain analysis only" -ForegroundColor Green
        Write-Host "   - Task history shows no execution activities" -ForegroundColor Green
        return $true
    }
}

# Main execution
try {
    $validationPassed = Test-NoExecutionDuringPlanning $TaskId $Phase
    
    if ($validationPassed) {
        Write-Host "🎯 NO-EXECUTION VALIDATION: PASSED" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "🚫 NO-EXECUTION VALIDATION: FAILED" -ForegroundColor Red
        Write-Host "" -ForegroundColor Red
        Write-Host "REQUIRED ACTION:" -ForegroundColor Yellow
        Write-Host "1. Complete planning handoff through orchestrator" -ForegroundColor Yellow
        Write-Host "2. Get execution authorization before making changes" -ForegroundColor Yellow
        Write-Host "3. Use proper execution workflows for implementation" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "❌ ERROR during no-execution validation: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
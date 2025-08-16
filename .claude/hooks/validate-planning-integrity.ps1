# Validate Planning Integrity - Ensures no execution occurred during planning phase
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,
    
    [Parameter(Mandatory=$false)]
    [string]$Phase = "planning"
)

function Test-PlanningIntegrity {
    param($TaskId, $Phase)
    
    Write-Host "🔍 Validating planning integrity for task $TaskId..." -ForegroundColor Cyan
    
    $violations = @()
    
    # Check 1: No git changes during planning phase
    $gitStatus = git status --porcelain 2>$null
    if ($gitStatus -and $Phase -eq "planning") {
        $violations += "Git changes detected during planning phase"
        Write-Host "❌ Git changes found during planning:" -ForegroundColor Red
        git status --short
    }
    
    # Check 2: No execution artifacts in planning documents
    $planningDocs = @(
        "docs/market-analysis.md",
        "docs/product-strategy.md", 
        "docs/technical-architecture.md",
        "docs/ux-design-spec.md",
        "docs/planning-summary.md"
    )
    
    foreach ($doc in $planningDocs) {
        if (Test-Path $doc) {
            $content = Get-Content $doc -Raw
            
            # Check for execution indicators
            if ($content -match "(?i)(implemented|deployed|executed|created file|modified)") {
                $violations += "Execution language found in planning document: $doc"
            }
            
            # Check for code implementations 
            if ($content -match "```[\s\S]*?(function|class|def |public |private )") {
                $violations += "Implementation code found in planning document: $doc"
            }
        }
    }
    
    # Check 3: Task history for execution activities
    $taskHistory = & task-master get-history --id=$TaskId 2>$null
    if ($taskHistory -match "(?i)(file created|code implemented|deployment|execution)") {
        $violations += "Execution activities found in task history"
    }
    
    # Check 4: Workflow phase consistency
    $workflowPhase = Get-Content ".workflow-phase" -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($workflowPhase -and $workflowPhase.phase -eq "planning" -and $gitStatus) {
        $violations += "Git changes detected while workflow phase is set to planning"
    }
    
    # Report results
    if ($violations.Count -gt 0) {
        Write-Host "❌ PLANNING INTEGRITY VIOLATIONS DETECTED:" -ForegroundColor Red
        foreach ($violation in $violations) {
            Write-Host "   - $violation" -ForegroundColor Red
        }
        Write-Host "" -ForegroundColor Red
        Write-Host "COMPLIANCE FAILURE: Planning phase must be analysis-only" -ForegroundColor Red
        Write-Host "Required: Planning cannot execute, implement, or modify code" -ForegroundColor Red
        return $false
    } else {
        Write-Host "✅ Planning integrity validation passed" -ForegroundColor Green
        Write-Host "   - No execution detected during planning phase" -ForegroundColor Green
        Write-Host "   - Planning documents contain analysis only" -ForegroundColor Green
        Write-Host "   - Task history shows no implementation activities" -ForegroundColor Green
        return $true
    }
}

function Test-TaskMasterIntegration {
    param($TaskId)
    
    # Verify task exists
    $taskInfo = & task-master show $TaskId 2>$null
    if (-not $taskInfo) {
        Write-Host "❌ Task $TaskId not found in Task Master" -ForegroundColor Red
        return $false
    }
    
    # Verify task status is appropriate for planning completion
    $taskStatus = & task-master get-status --id=$TaskId 2>$null
    $validStatuses = @("planning-complete", "in-progress", "execution-authorized")
    
    if ($taskStatus -notin $validStatuses) {
        Write-Host "❌ Invalid task status for planning handoff: $taskStatus" -ForegroundColor Red
        Write-Host "   Expected: planning-complete, in-progress, or execution-authorized" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Main execution
try {
    $integrityPassed = Test-PlanningIntegrity $TaskId $Phase
    $taskMasterPassed = Test-TaskMasterIntegration $TaskId
    
    if ($integrityPassed -and $taskMasterPassed) {
        Write-Host "🎯 PLANNING INTEGRITY VALIDATION: PASSED" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "🚫 PLANNING INTEGRITY VALIDATION: FAILED" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ ERROR during planning integrity validation: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
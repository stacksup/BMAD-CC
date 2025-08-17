#!/bin/bash
# Validate Planning Integrity - Ensures no execution occurred during planning phase

set -euo pipefail

# Parse command line arguments
TASK_ID=""
PHASE="planning"

while [[ $# -gt 0 ]]; do
    case $1 in
        --task-id=*)
            TASK_ID="${1#*=}"
            shift
            ;;
        --phase=*)
            PHASE="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

if [[ -z "$TASK_ID" ]]; then
    echo "Usage: $0 --task-id=<task_id> [--phase=<phase>]"
    exit 1
fi

test_planning_integrity() {
    local task_id="$1"
    local phase="$2"
    
    echo -e "\033[36m🔍 Validating planning integrity for task $task_id...\033[0m"
    
    local violations=()
    
    # Check 1: No git changes during planning phase
    local git_status
    git_status=$(git status --porcelain 2>/dev/null || true)
    if [[ -n "$git_status" && "$phase" == "planning" ]]; then
        violations+=("Git changes detected during planning phase")
        echo -e "\033[31m❌ Git changes found during planning:\033[0m"
        git status --short
    fi
    
    # Check 2: No execution artifacts in planning documents
    local planning_docs=(
        "docs/market-analysis.md"
        "docs/product-strategy.md"
        "docs/technical-architecture.md"
        "docs/ux-design-spec.md"
        "docs/planning-summary.md"
    )
    
    for doc in "${planning_docs[@]}"; do
        if [[ -f "$doc" ]]; then
            local content
            content=$(cat "$doc")
            
            # Check for execution indicators
            if echo "$content" | grep -iq '\(implemented\|deployed\|executed\|created file\|modified\)'; then
                violations+=("Execution language found in planning document: $doc")
            fi
            
            # Check for code implementations
            if echo "$content" | grep -Pzoq '```[\s\S]*?(function|class|def |public |private )'; then
                violations+=("Implementation code found in planning document: $doc")
            fi
        fi
    done
    
    # Check 3: Task history for execution activities
    local task_history
    if task_history=$(task-master get-history --id="$task_id" 2>/dev/null); then
        if echo "$task_history" | grep -iq '\(file created\|code implemented\|deployment\|execution\)'; then
            violations+=("Execution activities found in task history")
        fi
    fi
    
    # Check 4: Workflow phase consistency
    if [[ -f ".workflow-phase" ]]; then
        local workflow_phase
        if workflow_phase=$(cat ".workflow-phase" 2>/dev/null); then
            # Simple JSON parsing for phase field
            local current_phase
            current_phase=$(echo "$workflow_phase" | grep -o '"phase"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 2>/dev/null || true)
            if [[ "$current_phase" == "planning" && -n "$git_status" ]]; then
                violations+=("Git changes detected while workflow phase is set to planning")
            fi
        fi
    fi
    
    # Report results
    if [[ ${#violations[@]} -gt 0 ]]; then
        echo -e "\033[31m❌ PLANNING INTEGRITY VIOLATIONS DETECTED:\033[0m"
        for violation in "${violations[@]}"; do
            echo -e "\033[31m   - $violation\033[0m"
        done
        echo ""
        echo -e "\033[31mCOMPLIANCE FAILURE: Planning phase must be analysis-only\033[0m"
        echo -e "\033[31mRequired: Planning cannot execute, implement, or modify code\033[0m"
        return 1
    else
        echo -e "\033[32m✅ Planning integrity validation passed\033[0m"
        echo -e "\033[32m   - No execution detected during planning phase\033[0m"
        echo -e "\033[32m   - Planning documents contain analysis only\033[0m"
        echo -e "\033[32m   - Task history shows no implementation activities\033[0m"
        return 0
    fi
}

test_taskmaster_integration() {
    local task_id="$1"
    
    # Verify task exists
    local task_info
    if ! task_info=$(task-master show "$task_id" 2>/dev/null); then
        echo -e "\033[31m❌ Task $task_id not found in Task Master\033[0m"
        return 1
    fi
    
    # Verify task status is appropriate for planning completion
    local task_status
    task_status=$(task-master get-status --id="$task_id" 2>/dev/null || echo "unknown")
    local valid_statuses=("planning-complete" "in-progress" "execution-authorized")
    
    local status_valid=false
    for valid_status in "${valid_statuses[@]}"; do
        if [[ "$task_status" == "$valid_status" ]]; then
            status_valid=true
            break
        fi
    done
    
    if [[ "$status_valid" == "false" ]]; then
        echo -e "\033[31m❌ Invalid task status for planning handoff: $task_status\033[0m"
        echo -e "\033[31m   Expected: planning-complete, in-progress, or execution-authorized\033[0m"
        return 1
    fi
    
    return 0
}

# Main execution
if test_planning_integrity "$TASK_ID" "$PHASE" && test_taskmaster_integration "$TASK_ID"; then
    echo -e "\033[32m🎯 PLANNING INTEGRITY VALIDATION: PASSED\033[0m"
    exit 0
else
    echo -e "\033[31m🚫 PLANNING INTEGRITY VALIDATION: FAILED\033[0m"
    exit 1
fi
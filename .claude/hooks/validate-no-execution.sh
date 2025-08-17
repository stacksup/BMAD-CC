#!/bin/bash
# Validate No Execution During Planning - Ensures planning phase remains analysis-only

set -euo pipefail

# Parse command line arguments
TASK_ID=""
PHASE=""

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

if [[ -z "$TASK_ID" || -z "$PHASE" ]]; then
    echo "Usage: $0 --task-id=<task_id> --phase=<phase>"
    exit 1
fi

test_no_execution_during_planning() {
    local task_id="$1"
    local phase="$2"
    
    echo -e "\033[36m🔍 Validating no execution occurred during $phase phase...\033[0m"
    
    local violations=()
    
    # Check 1: Git repository status
    local git_changes
    git_changes=$(git status --porcelain 2>/dev/null || true)
    if [[ -n "$git_changes" ]]; then
        violations+=("Git Changes|Modified files detected during planning phase|$git_changes")
    fi
    
    # Check 2: Recently created/modified files (last 30 minutes)
    local recent_files
    recent_files=$(find . -type f -newermt "30 minutes ago" \
        ! -path "./.git/*" ! -path "./node_modules/*" ! -path "./.claude/*" \
        \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.php" \
        -o -name "*.java" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" \
        -o -name "*.go" -o -name "*.rs" \) 2>/dev/null || true)
    
    if [[ -n "$recent_files" ]]; then
        violations+=("Recent Code Files|Code files modified in last 30 minutes during planning|$recent_files")
    fi
    
    # Check 3: Planning documents for execution language
    local planning_files=(
        "docs/market-analysis.md"
        "docs/product-strategy.md"
        "docs/technical-architecture.md"
        "docs/ux-design-spec.md"
        "docs/planning-summary.md"
    )
    
    local execution_verbs=(
        "implemented" "deployed" "created file" "modified file"
        "executed" "ran script" "built" "compiled" "installed"
        "configured" "set up" "launched" "started"
    )
    
    for file in "${planning_files[@]}"; do
        if [[ -f "$file" ]]; then
            local content
            content=$(cat "$file")
            
            # Look for execution verbs
            for verb in "${execution_verbs[@]}"; do
                if echo "$content" | grep -iq "$verb"; then
                    violations+=("Execution Language|Planning document contains execution language: '$verb'|$file")
                    break
                fi
            done
            
            # Look for implementation code blocks
            if echo "$content" | grep -Pzoq '```[\s\S]*?(function|class|def |public |private |const |let |var )'; then
                violations+=("Implementation Code|Planning document contains implementation code|$file")
            fi
        fi
    done
    
    # Check 4: Task Master history for execution activities
    local task_history
    if task_history=$(task-master get-history --id="$task_id" 2>/dev/null); then
        local execution_indicators=(
            "file created" "code implemented" "deployment"
            "execution" "build" "test run" "script executed"
        )
        
        for indicator in "${execution_indicators[@]}"; do
            if echo "$task_history" | grep -iq "$indicator"; then
                violations+=("Task History|Task history shows execution activity: '$indicator'|Task Master history")
                break
            fi
        done
    else
        echo -e "\033[33m⚠️  Could not retrieve task history for validation\033[0m"
    fi
    
    # Check 5: Docker activity during planning (if applicable)
    if command -v docker >/dev/null 2>&1; then
        local docker_ps
        if docker_ps=$(docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null); then
            if [[ -n "$docker_ps" && "$phase" == "planning" ]]; then
                # Check if containers were started recently (planning shouldn't start containers)
                local recent_containers
                recent_containers=$(docker ps --filter "status=running" --format "{{.Names}}" 2>/dev/null || true)
                if [[ -n "$recent_containers" ]]; then
                    violations+=("Docker Activity|Docker containers running during planning phase|$recent_containers")
                fi
            fi
        fi
    fi
    
    # Report violations
    if [[ ${#violations[@]} -gt 0 ]]; then
        echo -e "\033[31m❌ EXECUTION VIOLATIONS DETECTED DURING PLANNING:\033[0m"
        echo ""
        
        for violation in "${violations[@]}"; do
            IFS='|' read -r type details files <<< "$violation"
            echo -e "\033[31m🚫 $type:\033[0m"
            echo -e "\033[31m   Details: $details\033[0m"
            if [[ -n "$files" ]]; then
                echo -e "\033[31m   Files/Items:\033[0m"
                echo "$files" | while IFS= read -r file; do
                    [[ -n "$file" ]] && echo -e "\033[31m     - $file\033[0m"
                done
            fi
            echo ""
        done
        
        echo -e "\033[33mCOMPLIANCE REQUIREMENT:\033[0m"
        echo -e "\033[33mPlanning phase must be ANALYSIS ONLY - no execution allowed\033[0m"
        echo -e "\033[33mUse orchestrator handoff to authorize execution workflows\033[0m"
        
        return 1
    else
        echo -e "\033[32m✅ No execution detected during planning phase\033[0m"
        echo -e "\033[32m   - No git changes found\033[0m"
        echo -e "\033[32m   - No recent code modifications\033[0m"
        echo -e "\033[32m   - Planning documents contain analysis only\033[0m"
        echo -e "\033[32m   - Task history shows no execution activities\033[0m"
        return 0
    fi
}

# Main execution
if ! test_no_execution_during_planning "$TASK_ID" "$PHASE"; then
    echo -e "\033[31m🚫 NO-EXECUTION VALIDATION: FAILED\033[0m"
    echo ""
    echo -e "\033[33mREQUIRED ACTION:\033[0m"
    echo -e "\033[33m1. Complete planning handoff through orchestrator\033[0m"
    echo -e "\033[33m2. Get execution authorization before making changes\033[0m"
    echo -e "\033[33m3. Use proper execution workflows for implementation\033[0m"
    exit 1
else
    echo -e "\033[32m🎯 NO-EXECUTION VALIDATION: PASSED\033[0m"
    exit 0
fi
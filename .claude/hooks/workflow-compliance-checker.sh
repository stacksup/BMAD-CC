#!/bin/bash
chmod +x "$0" 2>/dev/null || true

# Workflow Compliance Checker - Enforces proper workflow transitions and prevents compliance violations
# Usage: ./workflow-compliance-checker.sh <check-type> <task-id> [workflow-phase] [execution-authorized]

set -e

CHECK_TYPE=${1:-"pre-workflow"}
TASK_ID=${2:-""}
WORKFLOW_PHASE=${3:-"unknown"}
EXECUTION_AUTHORIZED=${4:-"false"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 BMAD-CC Workflow Compliance Checker${NC}"
echo -e "${BLUE}Check Type: $CHECK_TYPE | Task: $TASK_ID | Phase: $WORKFLOW_PHASE${NC}"
echo ""

# Function to validate Task Master integration
validate_task_master() {
    local task_id=$1
    
    echo -e "${BLUE}📋 Validating Task Master integration...${NC}"
    
    if [ -z "$task_id" ]; then
        echo -e "${RED}❌ COMPLIANCE VIOLATION: Task ID required${NC}"
        echo -e "${YELLOW}Required: All workflow operations must be tracked in Task Master${NC}"
        return 1
    fi
    
    # Check if task exists
    if ! task-master show "$task_id" >/dev/null 2>&1; then
        echo -e "${RED}❌ COMPLIANCE VIOLATION: Task $task_id not found in Task Master${NC}"
        echo -e "${YELLOW}Required: Create task before starting workflow${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Task Master integration validated${NC}"
    return 0
}

# Function to validate planning phase compliance
validate_planning_compliance() {
    local task_id=$1
    
    echo -e "${BLUE}📝 Validating planning phase compliance...${NC}"
    
    # Check for execution during planning
    local git_changes=$(git status --porcelain 2>/dev/null || echo "")
    if [ -n "$git_changes" ] && [ "$WORKFLOW_PHASE" == "planning" ]; then
        echo -e "${RED}❌ COMPLIANCE VIOLATION: Git changes detected during planning phase${NC}"
        echo -e "${YELLOW}Planning phase must be analysis-only - no file modifications allowed${NC}"
        echo "Changed files:"
        git status --short
        return 1
    fi
    
    # Check for planning handoff summary if planning is complete
    if [ "$CHECK_TYPE" == "planning-complete" ]; then
        if [ ! -f "docs/planning-handoff-summary.md" ]; then
            echo -e "${RED}❌ COMPLIANCE VIOLATION: Planning handoff summary missing${NC}"
            echo -e "${YELLOW}Required: Planning cycle must generate handoff summary${NC}"
            return 1
        fi
        
        echo -e "${GREEN}✅ Planning handoff summary found${NC}"
    fi
    
    echo -e "${GREEN}✅ Planning phase compliance validated${NC}"
    return 0
}

# Function to validate execution authorization
validate_execution_authorization() {
    local task_id=$1
    local execution_authorized=$2
    
    echo -e "${BLUE}🔒 Validating execution authorization...${NC}"
    
    # Check execution workflows require authorization
    local execution_workflows=("maintenance-cycle" "story-cycle" "saas-cycle" "greenfield-fullstack" "architecture-cycle")
    
    for workflow in "${execution_workflows[@]}"; do
        if [ "$WORKFLOW_PHASE" == "$workflow" ]; then
            if [ "$execution_authorized" != "true" ]; then
                echo -e "${RED}❌ COMPLIANCE VIOLATION: $workflow requires execution authorization${NC}"
                echo -e "${YELLOW}Required: Must be routed from orchestrator with --execution-authorized=true${NC}"
                echo -e "${YELLOW}Proper usage: /bmad:$workflow --task-id=$task_id --execution-authorized=true${NC}"
                return 1
            fi
            
            # Check task status
            local task_status=$(task-master get-status --id="$task_id" 2>/dev/null || echo "unknown")
            if [[ "$task_status" != "execution-authorized" && "$task_status" != "in-progress" ]]; then
                echo -e "${RED}❌ COMPLIANCE VIOLATION: Task $task_id not authorized for execution${NC}"
                echo -e "${YELLOW}Current status: $task_status${NC}"
                echo -e "${YELLOW}Required status: execution-authorized or in-progress${NC}"
                return 1
            fi
            
            echo -e "${GREEN}✅ Execution authorization validated for $workflow${NC}"
            return 0
        fi
    done
    
    echo -e "${GREEN}✅ No execution authorization required for $WORKFLOW_PHASE${NC}"
    return 0
}

# Function to validate orchestrator handoff
validate_orchestrator_handoff() {
    local task_id=$1
    
    echo -e "${BLUE}🤖 Validating orchestrator handoff...${NC}"
    
    # Check if coming from planning cycle
    if [ "$CHECK_TYPE" == "post-planning" ]; then
        # Verify planning documents exist
        local required_docs=("docs/market-analysis.md" "docs/product-strategy.md" "docs/technical-architecture.md" "docs/ux-design-spec.md" "docs/planning-summary.md")
        
        for doc in "${required_docs[@]}"; do
            if [ ! -f "$doc" ]; then
                echo -e "${RED}❌ COMPLIANCE VIOLATION: Required planning document missing: $doc${NC}"
                return 1
            fi
        done
        
        # Check for execution authorization document
        if [ ! -f "docs/execution-authorization-$task_id.md" ]; then
            echo -e "${RED}❌ COMPLIANCE VIOLATION: Execution authorization document missing${NC}"
            echo -e "${YELLOW}Required: Orchestrator must generate execution authorization${NC}"
            return 1
        fi
        
        echo -e "${GREEN}✅ Orchestrator handoff validated${NC}"
    fi
    
    return 0
}

# Function to validate workflow sequence
validate_workflow_sequence() {
    local task_id=$1
    local current_phase=$2
    
    echo -e "${BLUE}🔄 Validating workflow sequence...${NC}"
    
    # Get previous workflow phase from task history
    local task_history=$(task-master get-history --id="$task_id" 2>/dev/null || echo "")
    
    # Define valid transitions
    case "$current_phase" in
        "planning")
            echo -e "${GREEN}✅ Planning phase - valid workflow start${NC}"
            ;;
        "orchestrator")
            if echo "$task_history" | grep -q "planning.*complete"; then
                echo -e "${GREEN}✅ Valid transition: Planning → Orchestrator${NC}"
            else
                echo -e "${RED}❌ COMPLIANCE VIOLATION: Orchestrator must follow planning completion${NC}"
                return 1
            fi
            ;;
        "maintenance-cycle"|"story-cycle"|"saas-cycle"|"greenfield-fullstack"|"architecture-cycle")
            if echo "$task_history" | grep -q "orchestrator.*authorized"; then
                echo -e "${GREEN}✅ Valid transition: Orchestrator → $current_phase${NC}"
            else
                echo -e "${RED}❌ COMPLIANCE VIOLATION: Execution workflows must be authorized by orchestrator${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown workflow phase: $current_phase${NC}"
            ;;
    esac
    
    return 0
}

# Function to generate compliance report
generate_compliance_report() {
    local task_id=$1
    local status=$2
    
    echo ""
    echo -e "${BLUE}📊 COMPLIANCE VALIDATION REPORT${NC}"
    echo "================================"
    echo "Task ID: $task_id"
    echo "Check Type: $CHECK_TYPE"
    echo "Workflow Phase: $WORKFLOW_PHASE"
    echo "Execution Authorized: $EXECUTION_AUTHORIZED"
    echo "Timestamp: $(date -Iseconds)"
    echo "Status: $status"
    echo ""
    
    if [ "$status" == "PASSED" ]; then
        echo -e "${GREEN}🎯 COMPLIANCE VALIDATION: PASSED${NC}"
        echo -e "${GREEN}All workflow compliance requirements met${NC}"
    else
        echo -e "${RED}🚫 COMPLIANCE VALIDATION: FAILED${NC}"
        echo -e "${RED}Workflow compliance violations detected${NC}"
        echo ""
        echo -e "${YELLOW}REQUIRED ACTIONS:${NC}"
        echo -e "${YELLOW}1. Review compliance violations above${NC}"
        echo -e "${YELLOW}2. Follow proper workflow handoff procedures${NC}"
        echo -e "${YELLOW}3. Ensure Task Master integration is complete${NC}"
        echo -e "${YELLOW}4. Get proper authorization before execution${NC}"
    fi
}

# Main compliance validation logic
main() {
    echo -e "${BLUE}Starting compliance validation...${NC}"
    echo ""
    
    local validation_passed=true
    
    # Validate Task Master integration
    if ! validate_task_master "$TASK_ID"; then
        validation_passed=false
    fi
    
    # Validate planning compliance (if relevant)
    if [[ "$CHECK_TYPE" =~ ^(planning|planning-complete)$ ]]; then
        if ! validate_planning_compliance "$TASK_ID"; then
            validation_passed=false
        fi
    fi
    
    # Validate execution authorization (if relevant)
    if [[ "$CHECK_TYPE" =~ ^(pre-execution|execution)$ ]]; then
        if ! validate_execution_authorization "$TASK_ID" "$EXECUTION_AUTHORIZED"; then
            validation_passed=false
        fi
    fi
    
    # Validate orchestrator handoff (if relevant)
    if [[ "$CHECK_TYPE" =~ ^(post-planning|pre-execution)$ ]]; then
        if ! validate_orchestrator_handoff "$TASK_ID"; then
            validation_passed=false
        fi
    fi
    
    # Validate workflow sequence
    if ! validate_workflow_sequence "$TASK_ID" "$WORKFLOW_PHASE"; then
        validation_passed=false
    fi
    
    # Generate report and exit
    if [ "$validation_passed" == true ]; then
        generate_compliance_report "$TASK_ID" "PASSED"
        exit 0
    else
        generate_compliance_report "$TASK_ID" "FAILED"
        exit 1
    fi
}

# Help function
show_help() {
    echo "BMAD-CC Workflow Compliance Checker"
    echo ""
    echo "Usage: $0 <check-type> <task-id> [workflow-phase] [execution-authorized]"
    echo ""
    echo "Check Types:"
    echo "  pre-workflow       - Basic workflow validation"
    echo "  planning           - Planning phase compliance"
    echo "  planning-complete  - Planning completion validation"
    echo "  post-planning      - Post-planning handoff validation"
    echo "  pre-execution      - Pre-execution authorization check"
    echo "  execution          - Execution workflow validation"
    echo ""
    echo "Examples:"
    echo "  $0 planning-complete 123"
    echo "  $0 pre-execution 123 maintenance-cycle true"
    echo "  $0 post-planning 123 orchestrator"
}

# Script entry point
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
    exit 0
fi

if [ -z "$CHECK_TYPE" ] || [ -z "$TASK_ID" ]; then
    echo -e "${RED}❌ ERROR: Missing required parameters${NC}"
    echo ""
    show_help
    exit 1
fi

main
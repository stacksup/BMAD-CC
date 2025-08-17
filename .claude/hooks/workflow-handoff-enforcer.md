# Workflow Handoff Enforcement Protocol

## MANDATORY HANDOFF REQUIREMENTS

### Critical Handoff Commands
Every workflow phase MUST end with one of these explicit handoff commands:

```bash
# Route to specific workflow with context
bmad-handoff --from=planning-cycle --to=maintenance-cycle --task-id=<id> --context="<planning_summary>"

# Route to orchestrator for workflow selection
bmad-handoff --from=planning-cycle --to=orchestrator --task-id=<id> --decision-required="workflow_selection"

# Complete workflow with no further action
bmad-handoff --from=maintenance-cycle --to=complete --task-id=<id> --status=done
```

### Handoff Validation Gates
```bash
# Pre-handoff validation (BLOCKING)
./.claude/hooks/validate-handoff.sh -Source "planning-cycle" -TaskId <id>
# Validates:
# - All planning documents exist and are complete
# - Task status is accurate in Task Master
# - No direct execution has occurred
# - Proper workflow sequence followed

# Post-handoff validation
./.claude/hooks/confirm-handoff.sh -Target "maintenance-cycle" -TaskId <id>
# Validates:
# - Target workflow received context properly
# - Task ownership transferred correctly
# - Compliance tracking updated
```

## COMPLIANCE ENFORCEMENT RULES

### 1. Planning Authority vs Execution Authority
- **PLANNING AUTHORITY**: Can analyze, design, and approve plans
- **EXECUTION AUTHORITY**: Can modify code, create files, deploy changes
- **STRICT SEPARATION**: Planning agents CANNOT execute; Execution agents CANNOT plan

### 2. Workflow Transition Gates
```bash
# BLOCKING validation before any code changes
function validate-execution-authority() {
    local current_workflow=$1
    local task_id=$2
    
    if [[ "$current_workflow" == "planning-cycle" ]]; then
        echo "❌ COMPLIANCE VIOLATION: Planning cycle cannot execute code changes"
        echo "Required: Use bmad-handoff to route to execution workflow"
        exit 1
    fi
    
    # Verify task is properly routed through orchestrator
    local handoff_status=$(task-master get-handoff-status --id=$task_id)
    if [[ "$handoff_status" != "execution-authorized" ]]; then
        echo "❌ COMPLIANCE VIOLATION: Execution not authorized for task $task_id"
        echo "Required: Complete proper workflow handoff sequence"
        exit 1
    fi
}
```

### 3. Automatic Workflow Routing Prevention
```bash
# Prevent direct manual execution after planning
function block-manual-execution() {
    local git_status=$(git status --porcelain)
    local current_phase=$(cat .workflow-phase 2>/dev/null || echo "unknown")
    
    if [[ "$current_phase" == "planning" ]] && [[ -n "$git_status" ]]; then
        echo "❌ COMPLIANCE VIOLATION: Manual execution detected during planning phase"
        echo "Required: Complete planning handoff before making changes"
        git reset --hard HEAD  # Revert unauthorized changes
        exit 1
    fi
}
```

## ORCHESTRATOR INTEGRATION

### Automatic Workflow Detection
```javascript
// .claude/hooks/workflow-detector.js
function detectRequiredWorkflow(planningOutputs, taskComplexity) {
    const workflows = [];
    
    // Analyze planning outputs to determine execution needs
    if (hasMaintenanceTasks(planningOutputs)) {
        workflows.push({
            type: 'maintenance-cycle',
            priority: 1,
            reason: 'Cleanup and maintenance tasks identified'
        });
    }
    
    if (hasFeatureDevelopment(planningOutputs)) {
        workflows.push({
            type: 'story-cycle',
            priority: 2,
            reason: 'New feature development required'
        });
    }
    
    if (hasArchitecturalChanges(planningOutputs)) {
        workflows.push({
            type: 'architecture-cycle',
            priority: 3,
            reason: 'System architecture modifications needed'
        });
    }
    
    return workflows.sort((a, b) => a.priority - b.priority);
}
```

### Mandatory Orchestrator Routing
```bash
# End of planning cycle - MANDATORY orchestrator involvement
function complete-planning-phase() {
    local task_id=$1
    local planning_summary=$2
    
    echo "🎯 Planning phase complete for task $task_id"
    echo "📋 Planning summary: $planning_summary"
    echo ""
    echo "🤖 ROUTING TO ORCHESTRATOR for execution workflow selection..."
    
    # MANDATORY: Route to orchestrator for workflow determination
    bmad-handoff \
        --from=planning-cycle \
        --to=orchestrator \
        --task-id=$task_id \
        --context="$planning_summary" \
        --decision-required="execution_workflow_selection"
    
    # Block any further action until orchestrator routes to execution
    echo "⏸️  EXECUTION BLOCKED until orchestrator authorizes execution workflow"
}
```

## IMPLEMENTATION IN WORKFLOWS

### Updated Planning Cycle Handoff
Replace the ambiguous ending in planning-cycle.md:

```markdown
## PHASE 4: MANDATORY ORCHESTRATOR HANDOFF

### 4A) Planning Completion Validation
**Pre-Handoff Quality Gates:**
```bash
# Validate all planning documents are complete
./.claude/hooks/validate-planning-complete.sh --task-id=$TASK_ID

# Ensure no execution has occurred during planning
./.claude/hooks/validate-no-execution.sh --task-id=$TASK_ID
```

### 4B) Mandatory Orchestrator Routing
**REQUIRED: Route to orchestrator for execution workflow selection**
```bash
# Complete planning and route to orchestrator
bmad-handoff \
    --from=planning-cycle \
    --to=orchestrator \
    --task-id=$TASK_ID \
    --context="$(cat docs/planning-summary.md)" \
    --decision-required="execution_workflow_selection" \
    --planning-complete=true

echo "✅ Planning cycle complete"
echo "🤖 Routed to orchestrator for execution workflow selection"
echo "⏸️  EXECUTION AUTHORITY: Transferred to orchestrator"
```

**COMPLIANCE ENFORCEMENT:**
- Planning cycle CANNOT execute code changes
- Planning cycle CANNOT modify files directly
- Planning cycle MUST route through orchestrator
- No manual execution allowed after planning completion
```

### Enhanced Orchestrator Responsibilities
Add to orchestrator-agent.md:

```markdown
## MANDATORY WORKFLOW HANDOFF MANAGEMENT

### Planning-to-Execution Handoff Protocol
When receiving handoff from planning cycle:

1. **Validate Planning Completeness**
```bash
# Verify planning quality gates passed
task-master validate-planning --id=$TASK_ID --min-score=8

# Confirm no execution occurred during planning
./.claude/hooks/validate-planning-integrity.sh --task-id=$TASK_ID
```

2. **Analyze Execution Requirements**
```bash
# Determine optimal execution workflow
node .claude/hooks/workflow-detector.js \
    --planning-output="docs/planning-summary.md" \
    --task-id=$TASK_ID \
    --output="execution-plan.json"
```

3. **Authorize Execution Workflow**
```bash
# Route to appropriate execution workflow with authorization
bmad-handoff \
    --from=orchestrator \
    --to=$SELECTED_WORKFLOW \
    --task-id=$TASK_ID \
    --authorization="execution-approved" \
    --context="$(cat execution-plan.json)"

# Update task status to execution-authorized
task-master set-status --id=$TASK_ID --status=execution-authorized
```

### Execution Workflow Selection Matrix
```
Planning Outputs → Execution Workflow

✅ Cleanup/maintenance tasks → `/bmad:maintenance-cycle`
✅ New feature requirements → `/bmad:story-cycle` or `/bmad:saas-cycle`  
✅ Architecture changes → `/bmad:architecture-cycle`
✅ Multiple complex changes → Sequential workflow execution
✅ Greenfield project → `/bmad:greenfield-fullstack`
✅ Integration work → `/bmad:integration-cycle`
```
```

## TECHNICAL IMPLEMENTATION

### 1. Workflow Phase Tracking
```bash
# .claude/hooks/track-workflow-phase.sh
#!/bin/bash

function set-workflow-phase() {
    local phase=$1
    local task_id=$2
    local timestamp=$(date -Iseconds)
    
    echo "{\"phase\":\"$phase\",\"task_id\":\"$task_id\",\"timestamp\":\"$timestamp\"}" > .workflow-phase
    task-master update-task --id=$task_id --status="workflow-phase:$phase"
}

function validate-workflow-transition() {
    local from_phase=$1
    local to_phase=$2
    local task_id=$3
    
    # Validate legitimate workflow transitions
    case "$from_phase:$to_phase" in
        "planning:orchestrator") 
            echo "✅ Valid transition: Planning to Orchestrator"
            ;;
        "orchestrator:maintenance")
            echo "✅ Valid transition: Orchestrator to Maintenance"
            ;;
        "orchestrator:story")
            echo "✅ Valid transition: Orchestrator to Story Development"
            ;;
        "planning:maintenance"|"planning:story"|"planning:execution")
            echo "❌ INVALID: Planning cannot directly route to execution"
            echo "Required: Route through orchestrator"
            exit 1
            ;;
        *)
            echo "⚠️  Unrecognized workflow transition: $from_phase → $to_phase"
            echo "Requires manual validation"
            ;;
    esac
}
```

### 2. Automated Compliance Checking
```bash
# .claude/hooks/compliance-enforcer.sh
#!/bin/bash

TASK_ID=""
CHECK_TYPE=""
WORKFLOW_PHASE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --task-id)
            TASK_ID="$2"
            shift 2
            ;;
        --check-type)
            CHECK_TYPE="$2"
            shift 2
            ;;
        --workflow-phase)
            WORKFLOW_PHASE="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$TASK_ID" || -z "$CHECK_TYPE" ]]; then
    echo "Usage: $0 --task-id <id> --check-type <pre-handoff|post-handoff|execution-check> [--workflow-phase <phase>]"
    exit 1
fi

function test_workflow_compliance() {
    local task_id="$1"
    local check_type="$2"
    local workflow_phase="$3"
    local violations=0
    
    # Test task tracking integration
    if ! test_task_master_integration "$task_id"; then
        echo "❌ Task tracking compliance failed"
        violations=$((violations + 1))
    fi
    
    # Test workflow sequence
    if ! test_workflow_sequence "$task_id" "$workflow_phase"; then
        echo "❌ Workflow sequence compliance failed"
        violations=$((violations + 1))
    fi
    
    # Test execution authority
    if ! test_execution_authority "$task_id" "$workflow_phase"; then
        echo "❌ Execution authority compliance failed"
        violations=$((violations + 1))
    fi
    
    # Test documentation compliance
    if ! test_documentation_compliance "$task_id"; then
        echo "❌ Documentation compliance failed"
        violations=$((violations + 1))
    fi
    
    if [[ $violations -gt 0 ]]; then
        echo "❌ COMPLIANCE VIOLATIONS DETECTED:"
        echo "   Total violations: $violations"
        exit 1
    else
        echo "✅ All compliance checks passed"
        return 0
    fi
}

function test_execution_authority() {
    local task_id="$1"
    local workflow_phase="$2"
    
    # Check if execution is authorized for current phase
    local handoff_status
    handoff_status=$(task-master get-handoff-status --id="$task_id" 2>/dev/null)
    
    case "$workflow_phase" in
        "planning")
            # Planning phase should never have execution authority
            [[ "$handoff_status" != "execution-authorized" ]]
            ;;
        "maintenance")
            # Maintenance phase requires execution authority
            [[ "$handoff_status" == "execution-authorized" ]]
            ;;
        "story")
            # Story development requires execution authority
            [[ "$handoff_status" == "execution-authorized" ]]
            ;;
        *)
            echo "Warning: Unknown workflow phase: $workflow_phase" >&2
            return 1
            ;;
    esac
}
```

### 3. Orchestrator Enhanced Routing Logic
```markdown
## ENHANCED ORCHESTRATOR WORKFLOW SELECTION

### Intelligent Workflow Routing Algorithm
```python
# .claude/hooks/intelligent-routing.py
import json
import re
from pathlib import Path

def analyze_planning_outputs(planning_dir="docs/"):
    """Analyze planning documents to determine optimal execution workflow"""
    
    routing_score = {
        'maintenance-cycle': 0,
        'story-cycle': 0,
        'architecture-cycle': 0,
        'greenfield-fullstack': 0
    }
    
    # Analyze planning summary
    summary_path = Path(planning_dir) / "planning-summary.md"
    if summary_path.exists():
        content = summary_path.read_text()
        
        # Score based on content analysis
        if re.search(r'\b(cleanup|fix|bug|maintenance)\b', content, re.I):
            routing_score['maintenance-cycle'] += 3
            
        if re.search(r'\b(feature|story|enhancement|user)\b', content, re.I):
            routing_score['story-cycle'] += 3
            
        if re.search(r'\b(architecture|system|infrastructure|database)\b', content, re.I):
            routing_score['architecture-cycle'] += 3
            
        if re.search(r'\b(new application|greenfield|from scratch)\b', content, re.I):
            routing_score['greenfield-fullstack'] += 5
    
    # Analyze technical architecture
    arch_path = Path(planning_dir) / "technical-architecture.md"
    if arch_path.exists():
        content = arch_path.read_text()
        
        if re.search(r'\b(refactor|redesign|rebuild)\b', content, re.I):
            routing_score['architecture-cycle'] += 2
            
        if re.search(r'\b(docker|container|microservice)\b', content, re.I):
            routing_score['architecture-cycle'] += 1
    
    # Return highest scoring workflow
    best_workflow = max(routing_score.items(), key=lambda x: x[1])
    
    return {
        'recommended_workflow': best_workflow[0],
        'confidence_score': best_workflow[1],
        'all_scores': routing_score,
        'reasoning': generate_routing_reasoning(routing_score, best_workflow)
    }

def generate_routing_reasoning(scores, best_choice):
    """Generate human-readable reasoning for workflow selection"""
    workflow_name, score = best_choice
    
    reasoning = f"Selected {workflow_name} with confidence score {score}/10\n"
    reasoning += "Reasoning:\n"
    
    for workflow, points in scores.items():
        if points > 0:
            reasoning += f"- {workflow}: {points} points\n"
    
    return reasoning
```

## COMPLIANCE VALIDATION IMPLEMENTATION

### Pre-Flight Compliance Checks
```bash
# .claude/hooks/pre-flight-check.sh
#!/bin/bash

function run-pre-flight-compliance() {
    local task_id=$1
    local workflow=$2
    
    echo "🔍 Running pre-flight compliance checks for $workflow..."
    
    # Check 1: Task Master integration
    if ! task-master show $task_id >/dev/null 2>&1; then
        echo "❌ Task $task_id not found in Task Master"
        return 1
    fi
    
    # Check 2: Workflow authorization
    local auth_status=$(task-master get-field --id=$task_id --field=authorization 2>/dev/null)
    if [[ "$workflow" =~ (maintenance|story|development) ]] && [[ "$auth_status" != "execution-authorized" ]]; then
        echo "❌ Execution not authorized for task $task_id"
        echo "Required: Complete orchestrator handoff first"
        return 1
    fi
    
    # Check 3: Documentation requirements
    local phase=$(task-master get-field --id=$task_id --field=phase 2>/dev/null)
    if [[ "$phase" == "planning" ]] && [[ "$workflow" =~ (maintenance|story|development) ]]; then
        echo "❌ Cannot execute during planning phase"
        echo "Required: Complete planning handoff first"
        return 1
    fi
    
    echo "✅ Pre-flight compliance checks passed"
    return 0
}

# Add to beginning of all execution workflows
if ! run-pre-flight-compliance $TASK_ID $WORKFLOW_NAME; then
    echo "🚫 Compliance validation failed - blocking workflow execution"
    exit 1
fi
```

## SUMMARY: COMPLIANCE FAILURE PREVENTION

These improvements address the root causes:

1. **Explicit Handoff Commands**: Every workflow ends with specific routing commands
2. **Compliance Gates**: Automated validation prevents workflow bypasses  
3. **Clear Execution Authority**: Strict separation between planning and execution phases
4. **Automated Orchestrator Routing**: Intelligent workflow selection prevents manual shortcuts
5. **Task Master Integration**: Consistent tracking and status management
6. **Quality Gate Enforcement**: Blocking validations at critical transition points

The enhanced framework ensures that:
- Planning cycles CANNOT execute code changes
- All transitions go through the orchestrator
- Execution requires explicit authorization
- Compliance violations are automatically detected and blocked
- Proper documentation and git procedures are enforced

This systematic approach prevents the compliance failure you experienced while maintaining workflow efficiency and quality standards.
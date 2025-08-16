# Orchestrator Handoff Protocol

## COMPLIANCE-DRIVEN WORKFLOW HANDOFF SYSTEM

This document defines the mandatory handoff procedures that prevent compliance failures by enforcing proper workflow transitions and execution authorization.

## ROOT CAUSE ANALYSIS: PREVIOUS COMPLIANCE FAILURE

**What Happened:**
- Planning cycle completed strategic analysis correctly
- Instead of routing to execution workflows, manual cleanup was performed directly
- This bypassed Task Master tracking, git procedures, and documentation requirements
- Root cause: Ambiguous handoff procedures allowed direct execution after planning

**Impact:**
- Violated workflow compliance standards
- Bypassed quality gates and documentation requirements
- Lost traceability and audit trail
- Undermined systematic framework approach

## SOLUTION: MANDATORY ORCHESTRATOR HANDOFF

### Core Principle: Separation of Planning and Execution Authority

| Phase | Authority | Allowed Actions | Prohibited Actions |
|-------|-----------|----------------|-------------------|
| **Planning** | Analysis Only | Research, design, document | File changes, code implementation, deployment |
| **Execution** | Implementation | Code changes, file creation, deployment | Strategic planning, requirements analysis |

### Handoff Enforcement Mechanism

#### 1. Planning Cycle Termination Protocol
```bash
# END OF PLANNING CYCLE - MANDATORY ORCHESTRATOR ROUTING
echo "🎯 Planning phase complete for task $TASK_ID"
echo "📋 All strategic documents generated and validated"
echo ""
echo "🤖 ROUTING TO ORCHESTRATOR for execution workflow selection..."
echo "⚠️  EXECUTION AUTHORITY: Planning cycle CANNOT execute - routing to orchestrator"
echo ""
echo "ORCHESTRATOR: Analyze planning outputs and select execution workflow"
echo "COMPLIANCE: Only orchestrator can authorize execution workflows"
```

#### 2. Orchestrator Analysis and Routing
```bash
# ORCHESTRATOR DECISION MATRIX
PLANNING_OUTPUTS=$(cat docs/planning-handoff-summary.md)

# Intelligent workflow selection based on planning outputs
if grep -qi "maintenance\|cleanup\|fix" <<< "$PLANNING_OUTPUTS"; then
    WORKFLOW="maintenance-cycle"
elif grep -qi "feature\|story\|enhancement" <<< "$PLANNING_OUTPUTS"; then
    WORKFLOW="story-cycle"  
elif grep -qi "greenfield\|new application" <<< "$PLANNING_OUTPUTS"; then
    WORKFLOW="greenfield-fullstack"
else
    WORKFLOW="story-cycle"  # Default fallback
fi

# AUTHORIZE EXECUTION
task-master set-status --id=$TASK_ID --status=execution-authorized
echo "✅ EXECUTION AUTHORIZED: $WORKFLOW"
echo "🚀 ROUTING: /bmad:$WORKFLOW --task-id=$TASK_ID --execution-authorized=true"
```

#### 3. Execution Workflow Authorization Validation
```bash
# EXECUTION WORKFLOW ENTRY VALIDATION
if [ "$EXECUTION_AUTHORIZED" != "true" ]; then
    echo "❌ COMPLIANCE VIOLATION: Execution not authorized"
    echo "Required: Must be routed from orchestrator with authorization"
    exit 1
fi

# VERIFY TASK STATUS
TASK_STATUS=$(task-master get-status --id=$TASK_ID)
if [ "$TASK_STATUS" != "execution-authorized" ]; then
    echo "❌ COMPLIANCE VIOLATION: Task not authorized for execution"
    exit 1
fi

echo "✅ Execution authorization validated - proceeding with implementation"
```

## WORKFLOW TRANSITION MATRIX

### Planning → Orchestrator → Execution Workflows

| Planning Outputs | Execution Workflow | Orchestrator Routing |
|-----------------|-------------------|---------------------|
| Maintenance tasks, cleanup, bug fixes | `/bmad:maintenance-cycle` | `--execution-authorized=true` |
| Feature requirements, user stories | `/bmad:story-cycle` | `--execution-authorized=true` |
| New application development | `/bmad:greenfield-fullstack` | `--execution-authorized=true` |
| Architecture changes | `/bmad:architecture-cycle` | `--execution-authorized=true` |
| Multiple complex requirements | Sequential workflow execution | Chain workflows with authorization |

### Prohibited Transitions (COMPLIANCE VIOLATIONS)

❌ **Planning → Direct Execution** (BLOCKED)
❌ **Planning → Manual Implementation** (BLOCKED)  
❌ **Planning → File Modifications** (BLOCKED)
❌ **Any Workflow → Direct User Action** (BLOCKED)

## COMPLIANCE VALIDATION GATES

### Pre-Handoff Validation
```powershell
# Validate planning integrity before handoff
./.claude/hooks/validate-planning-integrity.ps1 -TaskId $TASK_ID -Phase "planning"

# Ensure no execution occurred during planning
./.claude/hooks/validate-no-execution.ps1 -TaskId $TASK_ID -Phase "planning"

# Verify all planning documents are complete
./.claude/hooks/validation-enforcer.ps1 -EventType "pre-planning-handoff" -TaskId $TASK_ID
```

### Post-Handoff Validation
```bash
# Verify orchestrator properly authorized execution
if [ ! -f "docs/execution-authorization-$TASK_ID.md" ]; then
    echo "❌ Missing execution authorization document"
    exit 1
fi

# Confirm task status updated to execution-authorized
TASK_STATUS=$(task-master get-status --id=$TASK_ID)
if [ "$TASK_STATUS" != "execution-authorized" ]; then
    echo "❌ Task status not updated to execution-authorized"
    exit 1
fi
```

### Execution Workflow Entry Validation
```bash
# Mandatory validation at start of all execution workflows
function validate-execution-authority() {
    local task_id=$1
    local execution_authorized=$2
    
    # Check authorization flag
    if [ "$execution_authorized" != "true" ]; then
        echo "❌ COMPLIANCE VIOLATION: Execution not authorized"
        echo "Required: Route through orchestrator first"
        return 1
    fi
    
    # Check task status
    local status=$(task-master get-status --id=$task_id)
    if [ "$status" != "execution-authorized" ]; then
        echo "❌ COMPLIANCE VIOLATION: Task $task_id not authorized"
        echo "Current status: $status, Required: execution-authorized"
        return 1
    fi
    
    return 0
}
```

## AUTOMATED COMPLIANCE ENFORCEMENT

### Workflow Phase Tracking
```bash
# Track current workflow phase to prevent violations
echo '{"phase":"planning","task_id":"'$TASK_ID'","timestamp":"'$(date -Iseconds)'"}' > .workflow-phase

# Block execution during planning phase
function block-execution-during-planning() {
    local current_phase=$(jq -r '.phase' .workflow-phase 2>/dev/null || echo "unknown")
    
    if [ "$current_phase" == "planning" ]; then
        echo "❌ COMPLIANCE VIOLATION: Cannot execute during planning phase"
        echo "Required: Complete orchestrator handoff first"
        return 1
    fi
    
    return 0
}
```

### Git Hook Integration
```bash
# .git/hooks/pre-commit - Prevent commits during planning
#!/bin/bash
WORKFLOW_PHASE=$(jq -r '.phase' .workflow-phase 2>/dev/null || echo "unknown")

if [ "$WORKFLOW_PHASE" == "planning" ]; then
    echo "❌ COMPLIANCE VIOLATION: Cannot commit during planning phase"
    echo "Required: Complete orchestrator handoff to execution workflow"
    exit 1
fi
```

## TASK MASTER INTEGRATION

### Status Lifecycle Management
```
Task Status Flow:
todo → planning → planning-complete → execution-authorized → in-progress → done

Validation Points:
- planning → planning-complete: All planning docs must exist
- planning-complete → execution-authorized: Only orchestrator can set this
- execution-authorized → in-progress: Only execution workflows can set this
```

### Audit Trail Requirements
```bash
# Track all workflow transitions in Task Master
task-master update-task --id=$TASK_ID --prompt="Planning phase completed, routing to orchestrator"
task-master update-task --id=$TASK_ID --prompt="Orchestrator authorized execution via $WORKFLOW"
task-master update-task --id=$TASK_ID --prompt="Execution workflow $WORKFLOW started with authorization"
```

## IMPLEMENTATION ROLLOUT

### Phase 1: Enhanced Planning Cycle (✅ COMPLETE)
- Added mandatory orchestrator handoff
- Implemented planning integrity validation
- Created compliance violation detection

### Phase 2: Enhanced Orchestrator Agent (✅ COMPLETE)
- Added execution workflow selection algorithm
- Implemented authorization protocol
- Created execution authorization documents

### Phase 3: Enhanced Execution Workflows (✅ COMPLETE)
- Added execution authorization validation
- Implemented blocking mechanisms for unauthorized execution
- Enhanced Task Master integration

### Phase 4: Validation Scripts (✅ COMPLETE)
- Created planning integrity validation
- Implemented no-execution detection
- Added compliance enforcement scripts

## SUCCESS METRICS

### Compliance Metrics
- **Zero Manual Execution**: No direct implementation after planning
- **100% Orchestrator Routing**: All planning phases route through orchestrator
- **Complete Authorization Trail**: All execution workflows have authorization
- **Full Task Tracking**: All work tracked in Task Master

### Quality Metrics
- **Documentation Compliance**: All required docs generated
- **Git Procedure Compliance**: All changes follow proper git workflow
- **Audit Trail Completeness**: Full traceability from planning to deployment

### Efficiency Metrics
- **Reduced Rework**: Fewer compliance violations requiring fixes
- **Faster Handoffs**: Streamlined transition between workflow phases
- **Clear Accountability**: Unambiguous ownership at each phase

## TROUBLESHOOTING COMPLIANCE VIOLATIONS

### Common Violations and Solutions

#### Violation: Direct execution after planning
**Solution**: Reset to planning-complete status, route through orchestrator
```bash
task-master set-status --id=$TASK_ID --status=planning-complete
# Route through orchestrator for proper authorization
```

#### Violation: Missing execution authorization
**Solution**: Get orchestrator authorization before proceeding
```bash
echo "❌ Execution not authorized - routing to orchestrator"
# Orchestrator must analyze and authorize execution workflow
```

#### Violation: Bypassing Task Master tracking
**Solution**: Create task and establish proper tracking
```bash
TASK_ID=$(task-master create --title="Emergency Fix" --type="maintenance")
# Follow proper workflow from creation
```

## CONCLUSION

This enhanced handoff protocol ensures:

1. **Clear Separation**: Planning and execution are strictly separated
2. **Mandatory Routing**: All transitions go through orchestrator
3. **Explicit Authorization**: Execution requires orchestrator approval
4. **Automated Compliance**: Violations are automatically detected and blocked
5. **Complete Traceability**: Full audit trail through Task Master

The system prevents the compliance failure you experienced while maintaining workflow efficiency and ensuring consistent quality standards across all BMAD-CC framework operations.
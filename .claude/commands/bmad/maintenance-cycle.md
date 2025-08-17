---
description: Streamlined maintenance workflow for BMAD-CC (Framework) - Efficient cycle for bug fixes and small improvements.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(task-master:*), Bash(npx task-master:*), Bash(pytest:*), Bash(docker:*), Bash(docker-compose:*)
---

# /bmad:maintenance-cycle

## STREAMLINED MAINTENANCE WORKFLOW

Efficient workflow for bug fixes, small improvements, and maintenance tasks that don't require strategic planning or complex coordination.

**When to Use:**
- Bug fixes and defect resolution (< 4 hours)
- Small improvements to existing functionality
- Configuration changes and updates
- Performance optimization tweaks
- Documentation updates
- Code refactoring and cleanup

## 0) MANDATORY: EXECUTION AUTHORIZATION VALIDATION

**COMPLIANCE ENFORCEMENT: Validate execution authority before proceeding**
```bash
# CRITICAL: Validate this workflow has execution authorization
TASK_ID=${1:-$(task-master current-task-id 2>/dev/null)}
EXECUTION_AUTHORIZED=${2:-false}

if [ "$EXECUTION_AUTHORIZED" != "true" ]; then
    echo "❌ COMPLIANCE VIOLATION: Maintenance cycle requires execution authorization"
    echo "Required: Must be routed from orchestrator with --execution-authorized=true"
    echo ""
    echo "Proper usage: /bmad:maintenance-cycle --task-id=<id> --execution-authorized=true"
    echo ""
    echo "If this is a direct maintenance request (not from planning):"
    echo "1. Create task: task-master create --title='Maintenance: [description]'"
    echo "2. Route through orchestrator for authorization"
    exit 1
fi

# Validate task exists and is properly tracked
if [ -z "$TASK_ID" ]; then
    echo "❌ COMPLIANCE VIOLATION: Task ID required for maintenance workflow"
    echo "Required: All maintenance work must be tracked in Task Master"
    exit 1
fi

# Verify task status allows execution
TASK_STATUS=$(task-master get-status --id=$TASK_ID 2>/dev/null)
if [[ "$TASK_STATUS" != "execution-authorized" && "$TASK_STATUS" != "in-progress" ]]; then
    echo "❌ COMPLIANCE VIOLATION: Task $TASK_ID not authorized for execution"
    echo "Current status: $TASK_STATUS"
    echo "Required status: execution-authorized or in-progress"
    exit 1
fi

# Set task status to in-progress
task-master set-status --id=$TASK_ID --status=in-progress

echo "✅ Execution authorization validated for maintenance cycle"
echo "📋 Task ID: $TASK_ID"
echo "🔧 Maintenance workflow authorized to proceed"
```

**Task Master Integration (MANDATORY):**
```bash
# Initialize or update task tracking
if [ -n "$TASK_ID" ]; then
    # Update existing task
    task-master update-task --id=$TASK_ID --prompt="Maintenance cycle started - execution authorized"
else
    # Create new maintenance task if none provided
    TASK_ID=$(task-master create --title="Maintenance: [Auto-generated]" --type="maintenance" --status="in-progress")
    echo "📝 Created maintenance task: $TASK_ID"
fi

# Set maintenance-specific metadata
task-master set-field --id=$TASK_ID --field="workflow" --value="maintenance-cycle"
task-master set-field --id=$TASK_ID --field="execution-start" --value="$(date -Iseconds)"
```

## 1) DEVELOPER IMPLEMENTATION

**STEP 1 TRIGGER: Use Task tool to invoke dev-agent**
```
/task dev-agent "Implement maintenance fix with comprehensive testing"
```

**MANDATORY: Wait for dev-agent completion confirmation before proceeding to step 2.**

**Implementation Process:**
1. **Issue Analysis**
   - Understand the specific problem or improvement needed
   - Identify root cause for bugs or optimal approach for improvements
   - Assess impact scope (which files/components affected)

2. **Direct Implementation**
   - Make minimal, focused changes to resolve the issue
   - Follow existing code patterns and standards
   - Ensure changes don't introduce side effects

3. **Testing Strategy by Project Type:**
{{#if PROJECT_TYPE.saas}}
   **SaaS Testing:**
   - Backend: `cd backend && python -m pytest -xvs`
   - Frontend: `cd frontend && npm run lint && npm run typecheck`
   - Integration: Test affected API endpoints and UI components
{{/if}}
{{#if PROJECT_TYPE.phaser}}
   **Game Testing:**
   - Run game in development mode and test affected functionality
   - Check for performance impacts on frame rate
   - Validate game state and asset loading
{{/if}}
{{#if PROJECT_TYPE.mobile}}
   **Mobile Testing:**
   - Run unit tests for affected components
   - Test on target platform simulators/devices
   - Validate offline functionality if applicable
{{/if}}

4. **Change Documentation**
   - Update inline code comments if logic changed
   - Note any configuration changes needed
   - Document any breaking changes (rare for maintenance)

**Quality Gates:**
- [ ] All existing tests continue to pass
- [ ] New/modified code follows project standards
- [ ] No regressions introduced
- [ ] Change is minimal and focused on the specific issue

**STEP 1 COMPLETION VALIDATION:**
- ✅ Implementation completed by dev-agent
- ✅ All tests pass
- ✅ Quality gates met
- ✅ Agent reports completion confirmation

**After implementation complete, proceed to QA ENGINEER REVIEW (step 2) or DOCUMENTATION (step 3) if QA skipped.**

## 2) QA ENGINEER REVIEW (OPTIONAL)

**STEP 2 TRIGGER: Use Task tool to invoke qa-agent (if needed)**
```
/task qa-agent "Review maintenance implementation for quality and risks"
```

**MANDATORY: Wait for qa-agent completion confirmation before proceeding to step 3.**

Note: This step is optional for simple changes but recommended for complex or high-risk modifications.

**When QA Review is Recommended:**
- Changes affect critical system functionality
- Bug fixes in security-sensitive areas
- Performance optimization changes
- Changes with potential for side effects

**QA Review Process:**
1. **Code Review**
   - Verify fix addresses root cause, not just symptoms
   - Check for potential side effects or edge cases
   - Validate testing approach is adequate

2. **Testing Validation**
   - Run comprehensive test suite
   - Test edge cases and error conditions
   - Validate performance impact (positive or neutral)

3. **Quality Assessment**
   - **QA_APPROVED**: Change meets quality standards, proceed to DOCUMENTATION (step 3)
   - **NEEDS_REVISION**: Issues found, return to DEVELOPER IMPLEMENTATION (step 1) with specific feedback

**STEP 2 COMPLETION VALIDATION:**
- ✅ QA review completed by qa-agent
- ✅ Quality assessment provided (APPROVED/NEEDS_REVISION)
- ✅ Agent reports completion confirmation

**After QA review complete, proceed to DOCUMENTATION & CHANGE LOG (step 3).**

## 3) DOCUMENTATION & CHANGE LOG

**STEP 3 TRIGGER: Use Task tool to invoke doc-agent**
```
/task doc-agent "Update documentation and changelog for maintenance task completion"
```

**MANDATORY: Wait for doc-agent completion confirmation before proceeding to step 4.**

**Automatic Documentation Updates:**
```bash
# Determine change type
CHANGE_TYPE="fix"  # or "chore" for maintenance tasks

# Run documentation updater
./.claude/hooks/documentation-updater.sh -Action update \
    -TaskId "$TASK_ID" \
    -TaskTitle "$TASK_TITLE" \
    -ChangeType "$CHANGE_TYPE"
```

**Documentation Requirements:**

1. **Code Documentation**
   - Update inline comments if logic changed significantly
   - Update README if configuration or usage changed
   - Update API documentation if endpoints modified

2. **Change Tracking**
   - Add entry to CHANGELOG.md with format:
     ```
     ### [Bug Fix] - YYYY-MM-DD
     - Fixed: [Brief description of issue resolved]
     - Files: [List of modified files]
     - Impact: [User-facing impact description]
     ```

3. **Knowledge Capture**
   - If bug was tricky to diagnose, add to `docs/lessons/`
   - Document any gotchas or important context for future developers
   - Note any technical debt discovered but not addressed

**STEP 3 COMPLETION VALIDATION:**
- ✅ Documentation updated by doc-agent
- ✅ CHANGELOG.md updated
- ✅ All required documentation complete
- ✅ Agent reports completion confirmation

**After documentation complete, proceed to USER APPROVAL GATE (step 4).**

## 4) USER APPROVAL GATE

**MANDATORY: Get user approval before proceeding to git operations.**

```
STOP - USER APPROVAL REQUIRED

Before proceeding with git commit and deployment:

1. Present summary of changes made
2. Show which files were modified
3. Confirm testing results
4. Get explicit user approval to proceed with git operations

DO NOT PROCEED until user approves the changes.
```

**User Approval Process:**
1. **Change Summary**: List all files modified and nature of changes
2. **Testing Results**: Report on all tests run and their outcomes
3. **Impact Assessment**: Describe what the changes fix/improve
4. **Risk Analysis**: Note any potential risks or side effects
5. **Approval Request**: Explicitly ask "Do you approve proceeding with git commit and deployment?"

**Only proceed to step 5 after receiving explicit user approval.**

## 5) GIT COMMIT & DEPLOYMENT

**STEP 5 TRIGGER: Use Task tool to invoke git-agent (ONLY after user approval)**
```
/task git-agent "Handle git operations for maintenance task completion"
```

**MANDATORY: Only proceed after explicit user approval in step 4.**

**Version Control Process:**
1. **Stage Changes**
   ```bash
   git add --all
   git status
   ```

2. **Commit with Descriptive Message**
   ```bash
   git commit -m "fix: [Brief description of fix]
   
   - Resolves: [Issue description]  
   - Files modified: [Key files changed]
   - Testing: [Testing performed]
   
   ðŸ¤– Generated with [Claude Code](https://claude.ai/code)
   
   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

3. **Deployment Coordination**
   {{#if PROJECT_TYPE.saas}}
   **SaaS Deployment:**
   - Push changes: `git push origin [branch]`
   - Create PR if required by team process
   - Monitor deployment and health checks
   - **Post-Deploy Validation**: 
     - docker-compose\.yml health check if applicable
     - Verify fix in production/staging environment
   {{/if}}
   
   {{#if PROJECT_TYPE.phaser}}
   **Game Deployment:**  
   - Push changes: `git push origin [branch]`
   - Test build process: `npm run build`
   - Validate game loads and functions correctly
   {{/if}}
   
   {{#if PROJECT_TYPE.mobile}}
   **Mobile Deployment:**
   - Push changes: `git push origin [branch]`  
   - Run platform-specific build tests
   - Coordinate with app deployment process
   {{/if}}

## 6) OPTIONAL: Task Master Completion

**Task Tracking Completion:**
```
If using task management:
- task-master update-task --status="complete" --notes="Fix deployed successfully"
- task-master set-resolution --type="fixed|improved|updated"
```

## MAINTENANCE CYCLE METRICS

### Efficiency Metrics
- **Time to Resolution**: From issue identification to deployment
- **First-Time Fix Rate**: Percentage of issues resolved without rework
- **Regression Rate**: Percentage of fixes that introduce new issues

### Quality Metrics  
- **Test Coverage**: Ensure existing tests continue to pass
- **Code Quality**: Maintain or improve code quality metrics
- **Documentation**: Keep documentation current and accurate

### Process Metrics
- **Cycle Time**: Total time from start to deployment
- **Handoff Efficiency**: Smooth transitions between agents
- **Stakeholder Satisfaction**: Issue resolution meets expectations

## ESCALATION TRIGGERS

### When to Exit Maintenance Cycle
- **Scope Creep**: Issue requires architectural changes or major refactoring
- **Complex Dependencies**: Fix impacts multiple systems or requires coordination
- **Requirements Unclear**: Need product owner or stakeholder input
- **High Risk**: Changes could impact critical system functionality

### Escalation Options
- **Feature Development**: If improvement becomes a larger feature â†’ `/bmad:story-cycle`
- **Strategic Planning**: If architectural changes needed â†’ `/bmad:planning-cycle`
- **Specialized Workflow**: If project type specific needs â†’ specialized workflow

## SUCCESS PATTERNS

### Ideal Maintenance Cycle
```
Issue Identified â†’ Dev Analysis & Fix â†’ Optional QA Review â†’ 
Documentation Update â†’ Git Commit â†’ Deployment â†’ Issue Resolved
Total Time: 30 minutes - 4 hours
```

### Common Anti-Patterns to Avoid
- **Over-Engineering**: Making changes larger than necessary
- **Under-Testing**: Skipping validation because "it's just a small change"
- **Poor Documentation**: Not updating change logs or leaving unclear commit messages
- **Scope Expansion**: Trying to fix multiple unrelated issues in one cycle

## USAGE EXAMPLES

### Example 1: Simple Bug Fix
```
Issue: "Login button doesn't show loading state"
Process: Dev fix CSS/JS â†’ Test login flow â†’ Update CHANGELOG â†’ Commit & deploy
Time: ~45 minutes
```

### Example 2: Configuration Update
```
Issue: "Update API timeout from 30s to 60s" 
Process: Dev update config â†’ Test API calls â†’ Document change â†’ Commit & deploy
Time: ~20 minutes
```

### Example 3: Performance Tweak
```
Issue: "Database query is slow on user dashboard"
Process: Dev optimize query â†’ QA review â†’ Test performance â†’ Update docs â†’ Deploy  
Time: ~2-3 hours
```

Remember: Maintenance cycles should be fast and focused. If the issue becomes complex or requires strategic thinking, escalate to the appropriate workflow rather than trying to force it through maintenance.
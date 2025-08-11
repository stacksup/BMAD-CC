---
description: Streamlined maintenance workflow for BMAD-CC (other) - Efficient cycle for bug fixes and small improvements.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(powershell:*), Bash(pwsh:*), Bash(task-master:*), Bash(npx task-master:*), Bash(pytest:*), Bash(docker:*), Bash(docker-compose:*)
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

## 0) OPTIONAL: Task Master Integration

**Task Tracking (Optional):**
```
If using task management:
- task-master start-maintenance --type="bug-fix|improvement|config|docs"
- task-master set-priority --level="low|medium|high"
```

## 1) DEVELOPER IMPLEMENTATION

**Load Developer Agent:**
```
Load the dev-agent for direct implementation of maintenance task.
```

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

## 2) QA ENGINEER REVIEW (OPTIONAL)

**Load QA Engineer Agent:**
```
OPTIONAL: Load the qa-agent for quality review if the change is complex or high-risk.
```

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
   - **QA_APPROVED**: Change meets quality standards, proceed to documentation
   - **NEEDS_REVISION**: Issues found, return to developer with specific feedback

## 3) DOCUMENTATION & CHANGE LOG

**Load Documentation Agent:**
```
Load the doc-agent to ensure all documentation is updated.
```

**Automatic Documentation Updates:**
```bash
# Determine change type
CHANGE_TYPE="fix"  # or "chore" for maintenance tasks

# Run documentation updater
./.claude/hooks/documentation-updater.ps1 -Action update \
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

## 4) GIT COMMIT & DEPLOYMENT

**Load Git Agent:**
```
Load the git-agent for change management and deployment.
```

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
   
   🤖 Generated with [Claude Code](https://claude.ai/code)
   
   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

3. **Deployment Coordination**
   {{#if PROJECT_TYPE.saas}}
   **SaaS Deployment:**
   - Push changes: `git push origin [branch]`
   - Create PR if required by team process
   - Monitor deployment and health checks
   - **Post-Deploy Validation**: 
     -  health check if applicable
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

## 5) OPTIONAL: Task Master Completion

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
- **Feature Development**: If improvement becomes a larger feature → `/bmad:story-cycle`
- **Strategic Planning**: If architectural changes needed → `/bmad:planning-cycle`
- **Specialized Workflow**: If project type specific needs → specialized workflow

## SUCCESS PATTERNS

### Ideal Maintenance Cycle
```
Issue Identified → Dev Analysis & Fix → Optional QA Review → 
Documentation Update → Git Commit → Deployment → Issue Resolved
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
Process: Dev fix CSS/JS → Test login flow → Update CHANGELOG → Commit & deploy
Time: ~45 minutes
```

### Example 2: Configuration Update
```
Issue: "Update API timeout from 30s to 60s" 
Process: Dev update config → Test API calls → Document change → Commit & deploy
Time: ~20 minutes
```

### Example 3: Performance Tweak
```
Issue: "Database query is slow on user dashboard"
Process: Dev optimize query → QA review → Test performance → Update docs → Deploy  
Time: ~2-3 hours
```

Remember: Maintenance cycles should be fast and focused. If the issue becomes complex or requires strategic thinking, escalate to the appropriate workflow rather than trying to force it through maintenance.

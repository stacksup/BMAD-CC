# BMAD Intelligent Workflow Testing Scenarios

## Test Scenario 1: Bug Fix Request (Should Route to maintenance-cycle)
**User Request:** "There's a bug in the login form where validation errors don't show properly"
**Expected Classification:** Maintenance Request
**Expected Route:** `/bmad:maintenance-cycle`
**Expected Process:** Developer → QA Engineer → Documentation → Git
**Expected Duration:** < 4 hours

## Test Scenario 2: Feature Addition (Should Route to story-cycle)
**User Request:** "Add a user profile page with avatar upload and account settings"
**Expected Classification:** Feature Development
**Expected Route:** `/bmad:story-cycle` or `/bmad:saas-cycle`
**Expected Process:** SM → PO → Dev → QA → Doc → Learnings → Git
**Expected Duration:** 4-40 hours

## Test Scenario 3: Strategic Initiative (Should Route to planning-cycle)
**User Request:** "We want to build a mobile app version of our web application"
**Expected Classification:** Strategic Planning Required
**Expected Route:** `/bmad:planning-cycle` → development workflow
**Expected Process:** Analyst → PM → Architect → UX → PO → Development cycles
**Expected Duration:** > 40 hours, multi-week

## Test Scenario 4: New Project (Should Route to greenfield-fullstack)
**User Request:** "Create a new project management tool for remote teams"
**Expected Classification:** Greenfield Project
**Expected Route:** `/bmad:greenfield-fullstack`
**Expected Process:** Strategic planning → Development execution
**Expected Duration:** Multi-week project

## Test Scenario 5: Existing System Enhancement (Should Route to brownfield-enhancement)
**User Request:** "Add real-time notifications to our existing customer service platform"
**Expected Classification:** Brownfield Enhancement
**Expected Route:** `/bmad:brownfield-enhancement`
**Expected Process:** System analysis → Enhancement planning → Development cycles
**Expected Duration:** Multi-story enhancement

## Testing Instructions

1. **Install Framework in Test Project:**
   ```powershell
   powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/YOUR-USERNAME/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
   ```

2. **Restart Claude Code:**
   ```
   /quit
   claude
   /settings
   ```

3. **Test Intelligent Routing:**
   ```
   /bmad:smart-cycle
   ```

4. **Present Test Scenarios:**
   - Present each test scenario above to the smart-cycle command
   - Validate that orchestrator correctly classifies the request
   - Confirm routing to expected workflow
   - Verify appropriate agent sequence recommendation

## Expected Orchestrator Analysis Process

For each scenario, the orchestrator should:

1. **Ask Classification Questions:**
   - "Can you describe what you're trying to accomplish?"
   - "Do you have clear requirements, or do we need to research and plan?"
   - "Will this require changes to the system architecture?"
   - "Is this for an existing project or a new application?"

2. **Apply Decision Tree:**
   - Assess complexity and scope
   - Determine strategic planning needs
   - Evaluate architectural impact
   - Consider timeline and resources

3. **Provide Routing Decision:**
   - Clear explanation of classification rationale
   - Specific workflow recommendation
   - Expected timeline and agent involvement
   - Success criteria and quality gates

## Success Criteria

✅ **Routing Accuracy**: Correct workflow selection for each scenario type
✅ **Classification Logic**: Sound reasoning for routing decisions
✅ **User Experience**: Clear explanations and expectations
✅ **Process Efficiency**: Appropriate resource allocation for request complexity
✅ **Quality Assurance**: Adequate quality gates for each workflow type

## Validation Checklist

- [ ] maintenance-cycle routes simple fixes efficiently
- [ ] story-cycle handles standard feature development
- [ ] planning-cycle engages strategic agents for complex initiatives
- [ ] greenfield-fullstack provides comprehensive new project planning
- [ ] brownfield-enhancement safely handles existing system changes
- [ ] Orchestrator asks appropriate clarifying questions
- [ ] Classification decisions are well-reasoned and explained
- [ ] Workflow transitions are smooth and well-documented
---
description: Intelligent BMAD workflow routing for BMAD-CC (other) - Analyzes requests and routes to optimal workflow.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(powershell:*), Bash(pwsh:*), Bash(task-master:*), Bash(npx task-master:*), Bash(pytest:*), Bash(docker:*), Bash(docker-compose:*), Read, Grep, Glob, Edit, Write, Task
---

# /bmad:smart-cycle

## INTELLIGENT WORKFLOW ORCHESTRATION

This command analyzes your request and routes it to the most appropriate BMAD workflow for optimal efficiency and results.

**VIBE CEO PHILOSOPHY**: You are the strategic leader with unlimited resources. The orchestrator empowers you with advanced elicitation tools to refine your vision before committing to a workflow. Think big, challenge assumptions, maximize value.

## 0) INFRASTRUCTURE CHECKS & ROUTING

**CRITICAL: Task Master Availability Check:**
```bash
# MUST succeed or workflow cannot proceed
./.claude/hooks/taskmaster-check.ps1 check
if ($LASTEXITCODE -ne 0) { 
    Write-Error "❌ BMAD requires Task Master AI. Install with: npm install -g task-master-ai"
    exit 1
}
```

**Docker Environment Check:**
```bash
# Ensure Docker is running (required for all development)
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Docker is not running. Starting Docker Desktop..."
    # Attempt to start Docker Desktop (platform specific)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open -a Docker
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    fi
    
    echo "⏳ Waiting for Docker to start (30 seconds)..."
    sleep 30
    
    docker info > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ Docker failed to start. Please start Docker Desktop manually."
        exit 1
    fi
fi

# Start containers if not running
./.claude/hooks/docker-manager.ps1 status
if [ $? -ne 0 ]; then
    echo "🐳 Starting Docker containers..."
    ./.claude/hooks/docker-manager.ps1 start
    
    # Wait for health checks
    echo "⏳ Waiting for services to be healthy..."
    sleep 5
    ./.claude/hooks/docker-manager.ps1 health
fi
```

**Task Master Project Initialization (First Time Only):**
```bash
# Check if Task Master is initialized for this project
if [ ! -d ".taskmaster" ]; then
    echo "📋 Task Master not initialized. Setting up now..."
    task-master init -y
    task-master models --set-main opus
    task-master models --set-fallback sonnet
    
    # Look for PRD or requirements to parse
    if [ -f "" ]; then
        echo "Found PRD at , parsing into tasks..."
        task-master parse-prd --input= --force
    elif [ -f "CLAUDE.md" ]; then
        echo "Found CLAUDE.md, parsing into tasks..."
        task-master parse-prd --input=CLAUDE.md --force
    elif [ -f "requirements.md" ]; then
        echo "Found requirements.md, parsing into tasks..."
        task-master parse-prd --input=requirements.md --force
    elif [ -f "README.md" ] && grep -q "Requirements\|Features\|Tasks" README.md; then
        echo "Found requirements in README.md, parsing into tasks..."
        task-master parse-prd --input=README.md --force
    else
        echo "No PRD found. Creating initial task from your request..."
        # Will create task from user input below
    fi
fi
```

**Task Context Loading:**
```bash
# Check if working on specific task or need to get next task
CURRENT_TASK=$(task-master next --json)
if [[ -z "$CURRENT_TASK" ]]; then
    # Check if tasks exist at all
    TASK_COUNT=$(task-master list --json | jq '. | length')
    
    if [[ "$TASK_COUNT" -eq 0 ]]; then
        echo "📝 No tasks exist yet. Initializing from your request..."
        # Orchestrator will handle initial task creation
    else
        echo "All tasks complete! Options:"
        echo "1. task-master parse-prd --input=<new-prd>"
        echo "2. Create new task from your request"
    fi
fi
```

**Load Orchestrator Agent:**
```
Load the orchestrator-agent with Task Master context to determine optimal workflow routing.
If no tasks exist, orchestrator will create initial tasks from user request.
```

**Initial Project Setup (First Time Only):**
```
For new projects or major initiatives:
1. GitHub Integration Check:
   - Check if GitHub remote configured
   - If not: Suggest running /bmad:github-setup
   - Auto-backup will be disabled until configured
   
2. Project Validation:
   - Load po-agent → Use validate-project-setup capability
   - Auto-detect project type and characteristics
   - Validate against 6-section master checklist
   - If BLOCKED: Address critical setup issues first
   - Save validation: docs/validation/project-setup-[date].md
```

**Enhanced Intelligence Layer**

### Project Context Analysis
```bash
# Document Size Detection
echo "📊 Analyzing project documents..."
if [ -f "docs/PRD.md" ]; then
    PRD_SIZE=$(stat -c%s "docs/PRD.md" 2>/dev/null || stat -f%z "docs/PRD.md" 2>/dev/null || echo 0)
    if [ $PRD_SIZE -gt 5242880 ]; then  # 5MB
        echo "📚 Large PRD detected (>5MB) - Document sharding recommended"
        export BMAD_ENABLE_SHARDING=1
    fi
fi

if [ -f "docs/architecture.md" ]; then
    ARCH_SIZE=$(stat -c%s "docs/architecture.md" 2>/dev/null || stat -f%z "docs/architecture.md" 2>/dev/null || echo 0)
    if [ $ARCH_SIZE -gt 5242880 ]; then  # 5MB
        echo "📚 Large architecture document detected - Sharding recommended"
        export BMAD_ENABLE_SHARDING=1
    fi
fi

# Brownfield Detection  
echo "🔍 Detecting project type..."
if [ -f "package.json" ] || [ -f "requirements.txt" ] || [ -f "go.mod" ] || [ -d "src/" ]; then
    if [ ! -f "docs/PRD.md" ] && [ ! -f "docs/product-requirements-document.md" ]; then
        echo "🏗️ Existing codebase detected without PRD - Brownfield project"
        export BMAD_BROWNFIELD_MODE=1
    fi
fi

# Change Request Detection
echo "🔍 Checking for pending changes..."
./.claude/hooks/change-detector.ps1 -EventType "check-pending-changes"

if [ -f "docs/change-request.md" ] || [ -f ".bmad-change-pending" ]; then
    echo "🔄 Change request detected - Change management activated"
    export BMAD_CHANGE_MANAGEMENT=1
    
    # Check if change validation is complete
    if [ -f ".bmad-change-pending" ]; then
        CHANGE_ID=$(cat .bmad-change-pending)
        echo "⚠️ Pending change: $CHANGE_ID requires validation before proceeding"
        echo "Run Product Owner change management process to resolve"
    fi
fi

# Interactive Enhancement Detection
if [ "$BMAD_ENABLE_SHARDING" = "1" ] || [ "$BMAD_BROWNFIELD_MODE" = "1" ]; then
    echo "✨ Enhanced capabilities activated:"
    [ "$BMAD_ENABLE_SHARDING" = "1" ] && echo "   📄 Document Sharding"
    [ "$BMAD_BROWNFIELD_MODE" = "1" ] && echo "   🏗️ Brownfield Analysis"
fi
```

**Request Classification Process:**
1. **Analyze Request Characteristics**
   - Complexity and scope assessment
   - Requirements clarity evaluation  
   - Technical change impact analysis
   - Timeline and resource estimation
   - Document size and brownfield detection

2. **Apply Enhanced Classification Decision Tree**
   ```
   Is this a bug fix or small improvement? → maintenance-cycle
   Clear requirements, no architecture changes? → story-cycle/saas-cycle
   Existing codebase without clear docs? → brownfield-enhancement
   Large documents detected (>5MB)? → Enable document sharding
   New project or major enhancement? → greenfield/planning workflows
   Need business/UX/architecture planning? → planning-cycle + elicitation
   ```

3. **Route to Appropriate Enhanced Workflow**
   - **Maintenance:** Simple fixes requiring minimal coordination
   - **Feature Development:** Standard story-based development with validation
   - **Strategic Planning:** Multi-phase planning with interactive elicitation
   - **Brownfield Enhancement:** Existing system analysis and improvement
   - **Document Management:** Sharding for large documents

## WORKFLOW ROUTING OPTIONS

### Route A: Maintenance Cycle (`/bmad:maintenance-cycle`)
**When to Use:**
- Bug fixes and defect resolution
- Small improvements (< 4 hours)
- Configuration changes
- Documentation updates

**Process:** Developer → QA Engineer → Documentation → Git

### Route B: Standard Development (`/bmad:story-cycle` or `/bmad:saas-cycle`)
**When to Use:**
- Clear feature requirements
- Moderate complexity (4-40 hours)
- No architectural changes
- Integration with existing systems

**Process:** Scrum Master → Product Owner → Developer → QA Engineer → Documentation → Learnings → Git

### Route C: Strategic Planning (`/bmad:planning-cycle`)
**When to Use:**
- Major features or capabilities
- Requirements unclear or need validation
- Architectural changes required
- Business/market research needed
- UX design required

**Enhanced Process:** 
1. **Planning Phase** - Strategic Agents with Interactive Elicitation
2. **Document Sharding** - If large documents detected (>5MB)
3. **AI Frontend Generation** - UX Expert creates AI tool prompts
4. **Development Phase** - Systematic Story Creation with Validation

### Route D: Brownfield Enhancement (`/bmad:brownfield-enhancement`)
**When to Use:**
- Existing codebase detected (package.json, requirements.txt, etc.)
- No clear PRD or requirements documentation
- Legacy system improvements
- Technical debt management
- System analysis required

**Enhanced Process:**
1. **Brownfield Analysis** - Architect performs comprehensive system analysis
2. **Document Generation** - Create architecture, technical debt, and integration maps
3. **Enhancement Planning** - Strategic planning based on analysis
4. **Phased Implementation** - Prioritized improvement roadmap

### Route E: Specialized Project Workflows
**When to Use:**
- New application development (`/bmad:greenfield-fullstack`)
- Service/API development (`/bmad:service-development`)
- UI/Frontend development (`/bmad:ui-development`)
- Document management (`/bmad:shard-document` for large docs)

## ORCHESTRATOR DECISION QUESTIONS

The orchestrator will ask clarifying questions to ensure proper routing:

**Request Analysis:**
1. "Can you describe what you're trying to accomplish? Is this a bug fix, new feature, or major enhancement?"
2. "Do you have clear requirements, or do we need to research and plan the approach?"
3. "Will this require changes to the system architecture or technology stack?"
4. "Is this for an existing project or a new application?"

**Scope Assessment:**
- "Is this a small fix that could be completed in a few hours?"
- "Do you need market research, competitive analysis, or business validation?"
- "Will this require user experience design or major interface changes?"
- "Are there integrations with other systems or major technical decisions needed?"

**Timeline & Resources:**
- "What's your expected timeline for this work?"
- "How many people do you expect will be working on this?"
- "What's the complexity level - simple, moderate, or complex?"

### ADVANCED ELICITATION OPTIONS

**When requirements need refinement, orchestrator offers:**

**Brainstorming Techniques** (`docs/data/brainstorming-techniques.md`):
- **"Let's explore alternatives"** → SCAMPER method for systematic variations
- **"What if scenarios"** → Explore different approaches and constraints
- **"Find the core need"** → Five Whys to drill down to fundamentals
- **"Think bigger/smaller"** → Scale exploration techniques

**Elicitation Methods** (`docs/data/elicitation-methods.md`):
- **"Break this down"** → Tree of Thoughts for complex decomposition
- **"All perspectives"** → Stakeholder Round Table analysis
- **"Risk assessment"** → Identify potential challenges and mitigation
- **"Challenge approach"** → Red Team vs Blue Team critical analysis

**Interactive Commands:**
- Say "brainstorm" to activate creative expansion
- Say "clarify" for structured elicitation
- Say "challenge" for critical analysis
- Say "explore" for alternative approaches

## ORCHESTRATOR ROUTING LOGIC

### Classification Criteria

**Maintenance Route Triggers:**
- Keywords: "bug", "fix", "small improvement", "configuration", "update"
- Estimated effort: < 4 hours
- Clear scope with existing functionality
- No strategic planning needed

**Feature Development Route Triggers:**
- Keywords: "new feature", "add functionality", "integrate", "enhance"
- Estimated effort: 4-40 hours  
- Clear requirements available
- No major architectural changes

**Strategic Planning Route Triggers:**
- Keywords: "major", "new capability", "research", "architecture", "design"
- Estimated effort: > 40 hours or multi-week
- Requirements unclear or need validation
- Multiple stakeholders or complex coordination

**Project-Specific Route Triggers:**
- Keywords: "new application", "greenfield", "existing system", "brownfield"
- Project type identification needed
- Specialized workflow requirements

## POST-ROUTING EXECUTION

Once the orchestrator determines the optimal route:

1. **Communicate Routing Decision**
   - Explain why this route was selected
   - Set expectations for the workflow process
   - Identify key stakeholders and timeline

2. **Execute Selected Workflow**
   - Route to the appropriate `/bmad:*` command
   - Pass context and classification results
   - Monitor progress and adjust if needed

3. **Context Preservation**
   - Maintain request context across workflow phases
   - Ensure smooth handoffs between agents
   - Document decisions and rationale

## WORKFLOW MONITORING & ADJUSTMENT

**During Execution:**
- Monitor progress against expected timeline
- Identify when workflow adjustments are needed
- Escalate blockers or scope changes

**Change Management Integration:**
- **Requirement Changes**: Use change-checklist template for systematic analysis
- **Scope Evolution**: Apply change management process before major pivots  
- **Course Correction**: Load po-agent → Use change management capability when needed
- **Impact Assessment**: Evaluate changes against epics, artifacts, and timelines
- Coordinate cross-workflow dependencies

**Quality Assurance:**
- Validate that selected workflow is appropriate
- Ensure all necessary agents are involved
- Confirm outputs meet quality standards
- Gather feedback for routing improvement

## SUCCESS METRICS

**Routing Accuracy:**
- Percentage of requests routed to optimal workflow on first attempt
- Reduction in workflow changes mid-process
- User satisfaction with workflow efficiency

**Time to Value:**
- Reduced time from request to first meaningful progress
- Faster completion for appropriately-scoped work
- Improved resource utilization across workflows

**Quality Outcomes:**
- Better alignment between request complexity and resources applied
- Reduced rework and scope creep
- Higher stakeholder satisfaction with results

## USAGE EXAMPLES

**Example 1: Bug Fix Request**
```
User: "There's a bug in the login form where validation errors don't show properly"
Orchestrator Analysis: Clear bug fix, existing functionality, < 4 hours
Routing Decision: `/bmad:maintenance-cycle`
```

**Example 2: New Feature Request**  
```
User: "Add a user profile page with avatar upload and account settings"
Orchestrator Analysis: New feature, clear scope, moderate complexity, ~16 hours
Routing Decision: `/bmad:story-cycle`
```

**Example 3: Strategic Initiative**
```
User: "We want to build a mobile app version of our web application"
Orchestrator Analysis: Major project, needs planning, architecture, UX design
Routing Decision: `/bmad:planning-cycle` → `/bmad:greenfield-mobile`
```

Remember: The smart-cycle is your intelligent entry point into the BMAD system. Trust the orchestrator's analysis and routing decisions - they're designed to optimize your workflow efficiency and project success.

---
description: Strategic planning workflow for BMAD-CC (other) - Coordinates strategic agents for comprehensive project planning.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(powershell:*), Bash(pwsh:*), Bash(task-master:*), Bash(npx task-master:*), Bash(docker:*), Bash(docker-compose:*), Read, Grep, Glob, Edit, Write, WebSearch, WebFetch, Task
---

# /bmad:planning-cycle

## STRATEGIC PLANNING WORKFLOW

This workflow coordinates strategic agents to create comprehensive project plans before development begins. Use when requirements are unclear, architectural planning is needed, or business validation is required.

## VIBE CEO PHILOSOPHY

As the **Vibe CEO**, you are directing a team of specialized AI agents through strategic planning. Your role:
- **Vision**: Provide clear strategic direction and objectives
- **Refinement**: Challenge outputs and iterate for quality
- **Oversight**: Maintain alignment across all planning phases
- **Decision**: Make key strategic choices when agents present options

Remember: You think like a CEO with unlimited resources. Push agents to deliver their best work.

## PHASE 0: INFRASTRUCTURE READINESS

### 0A) Docker Environment Setup
**Ensure development infrastructure is ready:**
```bash
# Check Docker availability
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️ Docker not running. Strategic planning includes container architecture."
    echo "Start Docker Desktop to enable container validation during planning."
fi

# If docker-compose.yml exists, validate it
if [ -f "" ] || [ -f "docker-compose.yml" ]; then
    docker-compose config > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Docker compose configuration valid"
    else
        echo "⚠️ Docker compose configuration has errors - will need fixing during planning"
    fi
fi
```

### 0B) Task Master Integration
**Initialize task tracking for planning outputs:**
```bash
# Ensure Task Master is available
task-master --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Task Master required for planning workflow"
    exit 1
fi

# Create planning epic if not exists
task-master create-task --title="Strategic Planning Phase" --type=epic
```

## PHASE 1: BUSINESS CONTEXT & ANALYSIS

### 1A) Business Analyst → Market Research & Requirements Analysis
**Load Business Analyst Agent:**
```
Load the analyst-agent to conduct market research and business analysis using the project brief template with advanced elicitation.
```

**Brainstorming & Elicitation Techniques:**
The analyst will use techniques from `docs/data/brainstorming-techniques.md` and `docs/data/elicitation-methods.md`:
- **What If Scenarios**: Explore alternate market conditions
- **Analogical Thinking**: Find patterns from other industries  
- **Stakeholder Round Table**: Analyze from multiple perspectives
- **Risk Identification**: Market risks and competitive threats
- **Five Whys**: Drill down to core market problems

**Deliverables:**
- Market research and competitive analysis
- Business requirements and constraints
- User needs and pain point analysis
- Strategic business context and rationale

**Quality Gate - Business Analysis Validation:**
```bash
# Automated business analysis validation
./.claude/hooks/validation-enforcer.ps1 -EventType "business-analysis-complete" -DocumentPath "docs/market-analysis.md"

# Validates:
# - Market research completeness
# - Competitive analysis depth
# - Business case strength
# - Risk assessment quality
echo "✅ Business analysis validation completed"
```

**Output Location:** Save completed analysis as `docs/market-analysis.md`

### 1B) Product Manager → Product Strategy & Vision
**Load Product Manager Agent:**
```
Load the pm-agent to create comprehensive PRD using the PRD template with advanced elicitation.
```

**Brainstorming & Elicitation Techniques:**
The PM will apply structured ideation methods:
- **SCAMPER Method**: Systematically explore feature variations
- **Six Thinking Hats**: Evaluate features from multiple perspectives
- **Tree of Thoughts**: Break complex features into discrete paths
- **"Yes, And..." Building**: Iteratively expand on product ideas
- **Innovation Tournament**: Compare competing feature approaches

**Input:** Market analysis from Business Analyst
**Deliverables:**
- Product vision and strategic objectives
- Feature prioritization and roadmap
- Success metrics and KPIs
- User personas and use cases
- Business case and ROI projections

**Output Location:** Save completed strategy as `docs/product-strategy.md`

**Quality Gate - PRD Validation:**
```
After PRD completion:
1. PM uses validate-prd capability
2. Reviews against 8-section checklist
3. Minimum score requirement: 8/10 for approval
4. If score < 8: Address critical gaps before proceeding
5. Save validation: docs/validation/prd-validation-[date].md
```

## PHASE 2: TECHNICAL PLANNING & ARCHITECTURE

### 2A) System Architect → Technical Architecture & Implementation Strategy
**Load System Architect Agent:**
```
Load the architect-agent to create comprehensive architecture specification using the architecture template with advanced elicitation.
```

**Brainstorming & Elicitation Techniques:**
The Architect will use advanced exploration methods:
- **First Principles Thinking**: Break down to technical fundamentals
- **Morphological Analysis**: Explore component combinations
- **Red Team vs Blue Team**: Challenge architectural decisions
- **Resource Constraints**: Design within technical limitations
- **Self-Consistency Validation**: Compare multiple architecture approaches

**Input:** Product strategy from Product Manager
**Deliverables:**
- System architecture and component design
- Technology stack selection and rationale
- API specifications and service boundaries
- Data architecture and storage strategy
- **Docker container architecture and orchestration strategy**
- **Service containerization approach and docker-compose configuration**
- Performance, scalability, and security considerations
- Implementation approach and technical roadmap

**Output Location:** Save completed architecture as `docs/technical-architecture.md`

**Quality Gate - Architecture Validation:**
```
After architecture completion:
1. Architect uses validate-architecture capability
2. Reviews against 10-section checklist
3. Minimum score requirement: 8/10 for approval
4. If score < 8: Address critical issues before proceeding
5. Save validation: docs/validation/architect-validation-[date].md
```

### 2B) UX Expert → User Experience Design & Interface Planning
**Load UX Expert Agent:**
```
Load the ux-agent to design user experience and interface specifications.
```

**Input:** Product strategy and technical architecture
**Deliverables:**
- User experience design and user journeys
- Interface specifications and wireframes
- Design system and visual standards
- Accessibility requirements and guidelines
- Usability testing plan and success criteria

**Output Location:** Save completed UX design as `docs/ux-design-spec.md`

## PHASE 3: INTEGRATION & VALIDATION

### 3A) Product Owner → Requirements Integration & Validation
**Load Product Owner Agent:**
```
Load the po-agent to validate and integrate all planning outputs.
```

**Input:** All planning documents from previous phases
**Deliverables:**
- Integrated requirements document
- Acceptance criteria for all features
- Risk assessment and mitigation strategies
- Dependency mapping and sequencing
- Quality gates and validation checkpoints

**Validation Process:**
- [ ] Business objectives align with technical approach
- [ ] UX design supports product vision
- [ ] Architecture enables required functionality
- [ ] Success metrics are measurable
- [ ] Risks are identified with mitigation plans

### 3B) Master Orchestrator → Planning Summary & Development Readiness
**Load Master Orchestrator Agent:**
```
Load the orchestrator-agent to assess planning completeness and readiness.
```

**Planning Assessment:**
1. **Completeness Check**
   - All strategic documents completed
   - Cross-document consistency validated
   - No critical gaps or conflicts identified

2. **Development Readiness Assessment**
   - Requirements sufficiently detailed for development
   - Technical approach validated and approved
   - Resource and timeline expectations aligned

3. **Development Workflow Recommendation**
   - Recommended development workflow based on planning outputs
   - Agent sequence and handoff protocols
   - Success metrics and quality gates

**Output Location:** Save assessment as `docs/planning-summary.md`

## PHASE 4: DEVELOPMENT PREPARATION

### 4A) Task Master Integration → Development Backlog Preparation
**Task Master Integration:**
```
Integrate planning outputs with task management system:
- task-master create-epic --from-planning docs/planning-summary.md
- task-master break-down-stories --source docs/
```

**Development Backlog:**
- Import strategic planning into development backlog
- Create epics based on planning outputs
- Estimate story complexity and dependencies
- Sequence development work based on priorities

### 4B) Documentation Handoff → Development Team Briefing
**Documentation Package:**
- `docs/market-analysis.md` - Business context and requirements
- `docs/product-strategy.md` - Product vision and priorities  
- `docs/technical-architecture.md` - Technical approach and standards
- `docs/ux-design-spec.md` - User experience requirements
- `docs/planning-summary.md` - Integration and next steps

**Development Team Handoff:**
- Schedule planning review session with development team
- Ensure all agents have context for upcoming development work
- Establish success metrics and quality checkpoints
- Plan first development iteration based on planning outputs

## WORKFLOW TRANSITION TO DEVELOPMENT

### Option A: Standard Development Cycles
**For well-defined features with clear scope:**
- Transition to `/bmad:story-cycle` or `/bmad:saas-cycle`
- Use planning documents as context for story creation
- Follow standard development workflow

### Option B: Greenfield Project Development  
**For new application development:**
- Transition to `/bmad:greenfield-fullstack` workflow
- Use planning outputs as foundation for development
- Follow specialized greenfield development process

### Option C: Brownfield Enhancement
**For existing system enhancement:**
- Transition to `/bmad:brownfield-enhancement` workflow
- Integrate planning with existing system analysis
- Follow specialized brownfield development process

## QUALITY GATES & SUCCESS CRITERIA

**Quality Gate - Pre-Development Handoff:**
```bash
# Comprehensive planning validation before development
./.claude/hooks/validation-enforcer.ps1 -EventType "pre-planning-handoff"

# Validates all planning documents exist and meet quality standards:
# - docs/market-analysis.md (Business validation)
# - docs/product-strategy.md (Product strategy)  
# - docs/technical-architecture.md (Technical feasibility)
# - docs/ux-design-spec.md (User experience)
# - Cross-document consistency check
# - Development readiness assessment
echo "✅ All planning phase quality gates passed"
```

### Planning Phase Quality Gates
- [x] **Business Validation**: Market research validates business case
- [x] **Product Strategy**: Vision and priorities clearly defined
- [x] **Technical Feasibility**: Architecture approach validated
- [x] **User Experience**: UX design supports product objectives
- [x] **Integration Check**: All documents consistent and complete
- [x] **Development Readiness**: Requirements sufficient for development

### Success Metrics
**Planning Quality:**
- Stakeholder approval of strategic documents
- Cross-document consistency score
- Requirements completeness assessment

**Development Preparation:**
- Development team readiness and understanding
- Task breakdown accuracy and completeness
- Reduced scope changes during development

**Business Outcomes:**
- Strategic objectives alignment
- Risk mitigation effectiveness  
- Time-to-market optimization

## PROJECT TYPE SPECIFIC CONSIDERATIONS

{{#if PROJECT_TYPE.saas}}
### SaaS Planning Focus
- Multi-tenant architecture considerations
- Subscription and billing model planning
- User onboarding and retention strategy
- Enterprise feature requirements
- Scalability and performance planning
{{/if}}

{{#if PROJECT_TYPE.phaser}}
### Game Development Planning Focus
- Gameplay mechanics and progression design
- Asset creation and management strategy
- Platform distribution and monetization
- Player engagement and retention planning
- Performance optimization for target platforms
{{/if}}

{{#if PROJECT_TYPE.mobile}}
### Mobile Development Planning Focus
- Platform-specific requirements (iOS/Android)
- Offline capability and data synchronization
- App store optimization and distribution
- Mobile UX patterns and constraints
- Performance and battery optimization
{{/if}}

## ESCALATION & EXCEPTION HANDLING

### When to Escalate
- **Conflicting Requirements**: Strategic documents contain contradictions
- **Technical Infeasibility**: Architecture cannot support product vision
- **Resource Constraints**: Timeline or budget conflicts with scope
- **Stakeholder Disagreement**: Business objectives not aligned

### Exception Workflows
- **Scope Reduction**: Reduce project scope to fit constraints
- **Timeline Extension**: Extend timeline to accommodate requirements
- **Resource Addition**: Add resources to meet timeline and scope
- **Strategic Pivot**: Modify product strategy based on technical constraints

## USAGE EXAMPLES

### Example 1: New SaaS Application
```
User: "We want to build a project management tool for remote teams"
Planning Outcome: 
- Market analysis of PM tools and remote work trends
- Product strategy for competitive differentiation
- SaaS architecture with real-time collaboration
- UX design for distributed team workflows
Transition: → `/bmad:greenfield-fullstack`
```

### Example 2: Mobile App Addition
```
User: "Add mobile app support to our existing web application"
Planning Outcome:
- Analysis of mobile user needs vs web functionality
- Mobile-first product strategy and feature prioritization
- API architecture for mobile client support
- Mobile UX design optimized for touch interfaces
Transition: → `/bmad:brownfield-enhancement` + mobile development
```

Remember: Strategic planning prevents costly rework and ensures development efforts align with business objectives. Invest time in planning to accelerate development and improve outcomes.

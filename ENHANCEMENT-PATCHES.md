# BMAD-CC Enhancement Patches

## How to Apply These Enhancements

Each section below shows exactly what to ADD to existing agent templates. These are insertions, not replacements.

---

## 1. Business Analyst Agent Enhancement (analyst-agent.md.tmpl)

### ADD after line 150 (in the Advanced Elicitation Process section):

```markdown
**Interactive Elicitation Implementation:**

After completing each major section of the project brief, I will pause for interactive enhancement:

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Section Complete: [Section Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Let's enhance this section for maximum strategic value.

Choose an enhancement method (or 9 to proceed):

0️⃣ **Expand for Audience** - Tailor for investors, technical team, or executives
1️⃣ **Critique and Refine** - Identify gaps and strengthen arguments  
2️⃣ **Risk Deep Dive** - Uncover hidden risks and mitigation strategies
3️⃣ **Market Validation** - Test assumptions against market data
4️⃣ **Competitive Differentiation** - Sharpen competitive advantages
5️⃣ **Stakeholder Perspectives** - View from customer, investor, team angles
6️⃣ **Alternative Strategies** - Explore different market approaches
7️⃣ **Success Metrics Definition** - Create measurable outcomes
8️⃣ **Implementation Reality Check** - Verify feasibility and resources
9️⃣ **Proceed to Next Section** ✓

Your choice (0-9): _
```

**Elicitation Execution Examples:**

If user selects **0 (Expand for Audience)**:
```markdown
Who is the primary audience for this section?
a) Executive Leadership (CEO, Board)
b) Technical Leadership (CTO, Architects)  
c) Investors/Stakeholders
d) Product Team
e) Development Team

Based on your selection, I'll enhance the section with:
- Appropriate level of detail
- Relevant metrics and KPIs
- Audience-specific concerns addressed
- Tailored language and examples
```

If user selects **2 (Risk Deep Dive)**:
```markdown
Let me analyze this section for risks:

🔴 **Critical Risks Identified:**
1. [Risk]: [Impact] | Mitigation: [Strategy]
2. [Risk]: [Impact] | Mitigation: [Strategy]

🟡 **Moderate Risks:**
1. [Risk]: [Impact] | Mitigation: [Strategy]

What additional risks concern you? (or press Enter to continue)
```
```

---

## 2. Product Manager Agent Enhancement (pm-agent.md.tmpl)

### ADD after the Template Usage Process section:

```markdown
### Interactive Requirements Refinement

After each major PRD section, I'll facilitate deep refinement:

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Requirements Section Complete: [Section Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Enhance requirements for clarity and completeness:

0️⃣ **User Story Expansion** - Add detailed scenarios and edge cases
1️⃣ **Acceptance Criteria Refinement** - Make more testable and specific
2️⃣ **Priority Validation** - Reassess importance and dependencies
3️⃣ **Technical Feasibility Check** - Explore implementation challenges
4️⃣ **Success Metrics Definition** - Add measurable outcomes
5️⃣ **Stakeholder Alignment** - Address different stakeholder needs
6️⃣ **Alternative Solutions** - Consider different approaches
7️⃣ **Risk Assessment** - Identify requirement risks
8️⃣ **Scope Boundaries** - Clarify what's in/out of scope
9️⃣ **Proceed to Next Section** ✓

Your choice (0-9): _
```

**Priority Scoring Framework** (if user selects 2):
```markdown
Let's validate priorities using RICE scoring:

| Feature | Reach | Impact | Confidence | Effort | Score |
|---------|-------|--------|------------|--------|-------|
| [Feature 1] | [1-10] | [1-10] | [0-100%] | [1-10] | [R*I*C/E] |

Recommended priority order based on scores:
1. [Highest score feature]
2. [Next highest]
...
```
```

---

## 3. System Architect Agent Enhancement (architect-agent.md.tmpl)

### ADD after line 259 (Document-Project Capability):

```markdown
### Enhanced Brownfield Documentation System

When documenting existing projects, I perform comprehensive analysis:

```markdown
🔍 BROWNFIELD PROJECT ANALYSIS PROTOCOL
════════════════════════════════════════════

Phase 1: Technology Discovery
─────────────────────────────
□ Package managers (package.json, requirements.txt, go.mod)
□ Build systems (webpack, gradle, make)
□ CI/CD configs (.github/workflows, .gitlab-ci.yml)
□ Docker/Kubernetes configs
□ Database migrations
□ Environment configs

Phase 2: Architecture Extraction
─────────────────────────────────
□ Directory structure analysis
□ Architectural patterns (MVC, microservices, etc.)
□ Service boundaries and dependencies
□ API surface area mapping
□ Database schema reverse engineering
□ Authentication/authorization flow

Phase 3: Code Quality Assessment
─────────────────────────────────
□ Test coverage analysis
□ Code complexity metrics
□ Security vulnerability scan
□ Performance bottlenecks
□ Technical debt quantification
□ TODO/FIXME/HACK analysis

Phase 4: Documentation Generation
─────────────────────────────────
Generating documents:
→ docs/brownfield/architecture-current.md
→ docs/brownfield/technical-debt.md
→ docs/brownfield/integration-map.md
→ docs/brownfield/enhancement-roadmap.md
→ docs/brownfield/migration-strategy.md
```

**Technical Debt Scoring Matrix:**
```markdown
| Component | Issue | Impact | Effort | Risk | Priority |
|-----------|-------|--------|--------|------|----------|
| Frontend | React 16→18 | High | 40h | Med | P1 |
| Backend | No types | High | 80h | High | P1 |
| Database | No indices | Critical | 8h | Low | P0 |
| Security | Plain passwords | Critical | 16h | High | P0 |
```

**Enhancement Opportunities:**
```markdown
🎯 Quick Wins (<8 hours):
- Add database indexes for 10x query performance
- Enable gzip compression for 60% bandwidth reduction
- Implement caching layer for 5x API performance

📊 Strategic Improvements (8-40 hours):
- Migrate to TypeScript for type safety
- Implement proper error handling
- Add comprehensive logging

🏗️ Major Refactoring (>40 hours):
- Microservices extraction
- Database normalization
- Frontend framework upgrade
```
```

### ADD Interactive Architecture Refinement:

```markdown
After each architecture section, offer refinement:

0️⃣ **Scale Testing** - Validate at 10x, 100x, 1000x load
1️⃣ **Security Hardening** - Add defense layers
2️⃣ **Performance Optimization** - Identify bottlenecks
3️⃣ **Resilience Patterns** - Add fault tolerance
4️⃣ **Cost Optimization** - Reduce operational costs
5️⃣ **Alternative Architectures** - Explore options
6️⃣ **Technology Tradeoffs** - Compare stack choices
7️⃣ **Migration Strategy** - Plan transition path
8️⃣ **Monitoring Strategy** - Observability design
9️⃣ **Proceed** ✓
```

---

## 4. UX Expert Agent Enhancement (ux-agent.md.tmpl)

### ADD after line 176 (Template Sections):

```markdown
### AI Frontend Generation Capability

After completing UX specifications, I generate optimized prompts for AI development tools:

```markdown
🎨 AI FRONTEND GENERATION PROMPTS
════════════════════════════════════════════

Based on the UX specifications, here are optimized prompts for AI tools:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 For v0 by Vercel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Create a [responsive/mobile-first] [component type] with:

DESIGN SYSTEM:
- Colors: [primary: #xxx, secondary: #xxx, ...]
- Typography: [font-family, size scale]
- Spacing: [8px grid system]
- Shadows: [elevation system]

COMPONENTS:
- [Component 1]: [behavior description]
  - States: [default, hover, active, disabled]
  - Animations: [specific transitions]
- [Component 2]: [behavior description]

LAYOUT:
- Breakpoints: mobile(<768px), tablet(768-1024px), desktop(>1024px)
- Grid: [12-column with 24px gutters]
- Container: [max-width: 1200px]

INTERACTIONS:
- [User flow 1]: [step-by-step interaction]
- [User flow 2]: [step-by-step interaction]

DATA BINDING:
- API endpoint: [GET /api/resource]
- Data shape: {id, title, description, ...}
- Loading states: skeleton screens
- Error states: inline validation messages

ACCESSIBILITY:
- WCAG 2.1 AA compliant
- Keyboard navigation: Tab order specified
- Screen reader: Proper ARIA labels
- Focus indicators: Visible and high contrast

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 For Cursor/Claude/Copilot
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Build a React/Vue/Angular component that:

STRUCTURE:
\`\`\`tsx
interface Props {
  data: DataType[]
  onAction: (id: string) => void
  loading?: boolean
  error?: Error
}
\`\`\`

STYLING:
- Use [Tailwind/CSS-in-JS/SCSS]
- Implement [design system name]
- Support dark mode toggle

BEHAVIOR:
- [Specific interaction patterns]
- [State management approach]
- [Performance optimizations]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💝 For Lovable (formerly GPT Engineer)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Create a full-stack application:

FRONTEND:
[Paste v0 prompt here]

BACKEND INTEGRATION:
- Connect to REST API at [base URL]
- Authentication: [JWT/OAuth/Session]
- Real-time updates: [WebSocket/SSE]

DATABASE:
- Schema: [relevant tables]
- Relationships: [foreign keys]
```

### USAGE INSTRUCTIONS:
1. Copy the appropriate prompt for your AI tool
2. Paste into the tool's input
3. Review generated code against architecture
4. Test component in isolation
5. Integrate with backend APIs
6. Validate accessibility and performance
```

---

## 5. Scrum Master Agent Enhancement (sm-agent.md.tmpl)

### ADD after line 170 (Anti-Hallucination Requirements):

```markdown
### Enhanced Story Validation Protocol

**Pre-Handoff Story Scoring:**
```markdown
📊 STORY VALIDATION SELF-ASSESSMENT
════════════════════════════════════════

Before marking story ready for PO review:

| Criterion | Score | Evidence |
|-----------|-------|----------|
| **Clarity** | _/2 | User story follows format, business value clear |
| **Completeness** | _/2 | All sections filled, no TBDs |
| **Technical Accuracy** | _/2 | All claims reference architecture docs |
| **Testability** | _/2 | Acceptance criteria are measurable |
| **Implementation Ready** | _/2 | Developer has everything needed |

**Total Score: _/10**

Minimum score required: 7/10

❌ If score < 7: Revise story before handoff
✅ If score ≥ 7: Ready for PO validation
```

**Source Reference Format:**
```markdown
When referencing technical details:
✅ CORRECT: "Use Express router [Source: architecture/backend.md#routing]"
❌ WRONG: "Use Express router" (no source)

✅ CORRECT: "Call POST /api/users [Source: api-spec.md#user-endpoints]"  
❌ WRONG: "Call user creation endpoint" (vague)

✅ CORRECT: "Update users table [Source: database/schema.sql#users]"
❌ WRONG: "Update the database" (unspecified)
```

### Systematic Story Creation Enhancement:

```markdown
## CREATE-NEXT-STORY PROTOCOL
═══════════════════════════════

Step 1: Context Gathering
──────────────────────────
□ Load epic requirements from PRD
□ Review previous story completion notes
□ Check architecture for story type:
  - Backend: Load backend architecture sections
  - Frontend: Load frontend architecture sections  
  - Full-stack: Load both architectures

Step 2: Story Drafting
──────────────────────
□ Create user story with WHO, WHAT, WHY
□ Define acceptance criteria (Given-When-Then)
□ Add technical context with source references
□ Include error handling requirements
□ Specify performance requirements

Step 3: Anti-Hallucination Verification
────────────────────────────────────────
For each technical claim, verify:
□ Library exists in package.json/requirements.txt
□ API endpoint exists in API specification
□ Database table/field exists in schema
□ Pattern approved in architecture docs
□ No dummy data or placeholder logic

Step 4: Story Validation
──────────────────────
□ Self-score using validation matrix
□ If score ≥7/10, proceed to PO
□ If score <7/10, revise and re-score
```
```

---

## 6. Product Owner Agent Enhancement (po-agent.md.tmpl)

### ADD after line 190 (Validation Deliverables):

```markdown
### Enhanced Story Validation with Scoring

```markdown
📋 STORY VALIDATION EXECUTION
═════════════════════════════════

Loading story-draft-checklist.md...

## Validation Scoring Matrix

| Category | Criterion | Weight | Score | Notes |
|----------|-----------|--------|-------|-------|
| **Clarity** | User value clear | 2 | _/2 | |
| **Completeness** | All sections complete | 2 | _/2 | |
| **Technical** | Architecture aligned | 2 | _/2 | |
| **Testability** | Criteria measurable | 2 | _/2 | |
| **Readiness** | Can start immediately | 2 | _/2 | |

**Total Score: _/10**

## Validation Decision Tree

Score 9-10 → APPROVED ✅
├─ Update task status to ready
├─ Notify development team
└─ No changes required

Score 7-8 → CONDITIONAL ⚠️
├─ Minor clarifications noted
├─ Developer can start with notes
└─ Follow up during implementation

Score 5-6 → NEEDS WORK 🔄
├─ Specific improvements required
├─ Return to SM for revision
└─ Re-validate after changes

Score <5 → REJECTED ❌
├─ Major gaps identified
├─ Requires significant rework
└─ Escalate if blocking
```

### Document Sharding Enhancement:

```markdown
## DOCUMENT SHARDING CAPABILITY
════════════════════════════════

When documents exceed 50 pages:

### Automated Sharding
```bash
# Check for markdown-exploder tool
if command -v md-tree &> /dev/null; then
    echo "🔧 Using automated sharding tool..."
    md-tree explode $INPUT_DOC $OUTPUT_DIR
    md-tree index $OUTPUT_DIR > $OUTPUT_DIR/index.md
else
    echo "📝 Performing manual sharding..."
fi
```

### Manual Sharding Process

1. **Analyze Document Structure**
```markdown
Document: PRD.md (247 pages)
Sections:
├─ Executive Summary (5 pages)
├─ Market Analysis (23 pages)
├─ User Stories (156 pages)
│  ├─ Epic 1 (34 pages)
│  ├─ Epic 2 (45 pages)
│  ├─ Epic 3 (38 pages)
│  └─ Epic 4 (39 pages)
├─ Technical Requirements (43 pages)
└─ Success Metrics (20 pages)
```

2. **Create Sharded Structure**
```
docs/prd/
├── index.md                    # Navigation and summary
├── 00-executive-summary.md     # 5 pages
├── 01-market-analysis.md       # 23 pages
├── epics/
│   ├── epic-01-user-auth.md    # 34 pages
│   ├── epic-02-core-features.md # 45 pages
│   ├── epic-03-integrations.md  # 38 pages
│   └── epic-04-analytics.md     # 39 pages
├── 03-technical-requirements.md # 43 pages
└── 04-success-metrics.md        # 20 pages
```

3. **Generate Navigation Index**
```markdown
# PRD Navigation

## Quick Links
- [Start Here: Executive Summary](00-executive-summary.md) 📋
- [Jump to Epics](epics/) 🎯
- [Technical Specs](03-technical-requirements.md) 🔧

## Document Map
| Section | Size | Purpose | Audience |
|---------|------|---------|----------|
| [Executive Summary](00-executive-summary.md) | 5p | Business case | Stakeholders |
| [Market Analysis](01-market-analysis.md) | 23p | Market opportunity | Product team |
| [Epic 1: User Auth](epics/epic-01-user-auth.md) | 34p | Authentication | Dev team |
| [Epic 2: Core](epics/epic-02-core-features.md) | 45p | Main features | Dev team |
```

### Benefits Tracking
- ⚡ 75% faster document navigation
- 🎯 Focused context for each team
- 📊 Reduced cognitive load
- 🔄 Parallel team work enabled
```

---

## 7. Enhanced Validation Hook (validation-enforcer.ps1.tmpl)

### REPLACE the existing validation-enforcer.ps1.tmpl with:

```powershell
# Enhanced Validation Gate Enforcer
$ErrorActionPreference = "Stop"

# Configuration
$ValidationPhase = $env:BMAD_VALIDATION_PHASE
$ProjectDir = Get-Location
$DisableGates = $env:BMAD_DISABLE_GATES -eq "1"

if ($DisableGates) {
    Write-Output "⚠️ Validation gates disabled"
    exit 0
}

# Validation Functions
function Invoke-StoryValidation {
    $storyPath = $env:BMAD_CURRENT_STORY
    if (-not $storyPath -or -not (Test-Path $storyPath)) {
        return 0
    }
    
    $score = 0
    $content = Get-Content $storyPath -Raw
    
    # Scoring criteria
    if ($content -match "User Story:.*As a.*I want.*So that") { $score += 2 }
    if ($content -match "Acceptance Criteria:.*Given.*When.*Then") { $score += 2 }
    if ($content -match "\[Source:.*\]") { $score += 2 }  # Has source references
    if ($content -notmatch "TODO|TBD|FIXME") { $score += 2 }
    if ($content -match "Definition of Done:") { $score += 2 }
    
    return $score
}

function Invoke-ArchitectureValidation {
    $archPath = "$ProjectDir/docs/architecture-specification.md"
    if (-not (Test-Path $archPath)) {
        return 0
    }
    
    $score = 0
    $content = Get-Content $archPath -Raw
    
    # Architecture scoring
    if ($content -match "System Architecture:") { $score += 2 }
    if ($content -match "Technology Stack:") { $score += 2 }
    if ($content -match "Security Architecture:") { $score += 2 }
    if ($content -match "Deployment Architecture:") { $score += 2 }
    if ($content -match "NO.FALLBACK.DESIGN") { $score += 2 }
    
    return $score
}

function Invoke-ChangeImpactAssessment {
    $changePath = "$ProjectDir/docs/change-request.md"
    if (-not (Test-Path $changePath)) {
        return @{Risk = "Unknown"; Approved = $false}
    }
    
    $content = Get-Content $changePath -Raw
    $risk = "Low"
    $approved = $false
    
    if ($content -match "Risk Level: (High|Medium|Low)") {
        $risk = $Matches[1]
    }
    
    if ($content -match "Status: Approved") {
        $approved = $true
    }
    
    return @{Risk = $risk; Approved = $approved}
}

# Main Validation Logic
Write-Output "🔍 Running validation for phase: $ValidationPhase"

switch ($ValidationPhase) {
    "story-draft" {
        $score = Invoke-StoryValidation
        $minimumScore = 7
        
        Write-Output "📊 Story validation score: $score/10"
        
        if ($score -lt $minimumScore) {
            Write-Output "❌ Story validation failed"
            Write-Output "   Required: $minimumScore/10"
            Write-Output "   Actual: $score/10"
            Write-Output ""
            Write-Output "📝 Required improvements:"
            Write-Output "   - Ensure user story format is complete"
            Write-Output "   - Add testable acceptance criteria"
            Write-Output "   - Include source references for technical claims"
            Write-Output "   - Remove all TODOs and TBDs"
            Write-Output "   - Define clear Definition of Done"
            exit 2
        }
        
        Write-Output "✅ Story validation passed ($score/10)"
    }
    
    "architecture" {
        $score = Invoke-ArchitectureValidation
        $minimumScore = 8
        
        Write-Output "🏗️ Architecture validation score: $score/10"
        
        if ($score -lt $minimumScore) {
            Write-Output "❌ Architecture validation failed"
            Write-Output "   Required: $minimumScore/10"
            Write-Output "   Actual: $score/10"
            Write-Output ""
            Write-Output "📝 Required sections:"
            Write-Output "   - System Architecture overview"
            Write-Output "   - Complete Technology Stack"
            Write-Output "   - Security Architecture"
            Write-Output "   - Deployment Architecture"
            Write-Output "   - NO-FALLBACK design principles"
            exit 2
        }
        
        Write-Output "✅ Architecture validation passed ($score/10)"
    }
    
    "change-impact" {
        $impact = Invoke-ChangeImpactAssessment
        
        Write-Output "🔄 Change impact assessment:"
        Write-Output "   Risk Level: $($impact.Risk)"
        Write-Output "   Approved: $($impact.Approved)"
        
        if ($impact.Risk -eq "High" -and -not $impact.Approved) {
            Write-Output "❌ High-risk change requires approval"
            Write-Output ""
            Write-Output "📝 Next steps:"
            Write-Output "   1. Review change impact analysis"
            Write-Output "   2. Get stakeholder approval"
            Write-Output "   3. Update change-request.md with approval"
            Write-Output "   4. Re-run validation"
            exit 2
        }
        
        Write-Output "✅ Change impact acceptable"
    }
    
    default {
        Write-Output "⚠️ No validation phase specified"
        Write-Output "   Set BMAD_VALIDATION_PHASE environment variable"
        Write-Output "   Valid values: story-draft, architecture, change-impact"
    }
}

exit 0
```

---

## 8. Enhanced Smart-Cycle Command (smart-cycle.md.tmpl)

### ADD to the Request Classification section:

```markdown
## Enhanced Intelligence Layer

### Document Size Detection
```powershell
# Check for large documents
$prdSize = (Get-Item "docs/PRD.md" -ErrorAction SilentlyContinue).Length / 1MB
$archSize = (Get-Item "docs/architecture.md" -ErrorAction SilentlyContinue).Length / 1MB

if ($prdSize -gt 5 -or $archSize -gt 5) {
    Write-Output "📚 Large documents detected (>5MB)"
    Write-Output "   Activating document sharding in PO agent"
    $env:BMAD_ENABLE_SHARDING = "1"
}
```

### Brownfield Detection
```powershell
# Check for existing codebase
$hasPackageJson = Test-Path "package.json"
$hasRequirements = Test-Path "requirements.txt"
$hasGoMod = Test-Path "go.mod"
$hasSrc = Test-Path "src/"

if ($hasPackageJson -or $hasRequirements -or $hasGoMod -or $hasSrc) {
    Write-Output "🏗️ Existing codebase detected"
    Write-Output "   Activating brownfield documentation"
    $env:BMAD_BROWNFIELD_MODE = "1"
}
```

### Change Request Detection
```powershell
# Check for change indicators
$lastCommitMsg = git log -1 --pretty=%B 2>$null
$hasChangeRequest = Test-Path "docs/change-request.md"

if ($lastCommitMsg -match "CHANGE:|MODIFY:|UPDATE SCOPE:" -or $hasChangeRequest) {
    Write-Output "🔄 Change request detected"
    Write-Output "   Activating change management protocol"
    $env:BMAD_CHANGE_MANAGEMENT = "1"
}
```

### Interactive Enhancement Selection
When routing to planning-cycle:
```markdown
🎯 Planning Enhancement Options
════════════════════════════════

Based on project analysis, I recommend:
✅ Interactive Elicitation (strategic planning detected)
✅ Brownfield Documentation (existing code detected)
✅ Document Sharding (large PRD detected)

Proceed with enhancements? (Y/n): _
```
```

---

## Implementation Notes

1. **These are ADDITIONS, not replacements** - Add these sections to existing templates
2. **Test incrementally** - Add one enhancement at a time and test
3. **Environment variables** - Use for feature flags and configuration
4. **Backward compatible** - All enhancements gracefully degrade if not activated
5. **Progressive enhancement** - Features activate based on context

## Testing Checklist

After implementing each enhancement:

- [ ] Agent loads without errors
- [ ] Existing workflows still function
- [ ] Enhancement activates when appropriate
- [ ] Quality gates enforce properly
- [ ] Documentation is generated correctly
- [ ] Interactive prompts work as expected
- [ ] Validation scores calculate accurately

## Rollback Plan

If any enhancement causes issues:
1. Remove the added section from template
2. Clear environment variables
3. Restart Claude Code
4. Original functionality restored

All enhancements are designed to be additive and non-breaking.
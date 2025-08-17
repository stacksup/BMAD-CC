---
description: Brownfield enhancement workflow for BMAD-CC (Framework) - Comprehensive workflow for enhancing existing systems.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(task-master:*), Bash(npx task-master:*), Bash(pytest:*), Bash(docker:*), Bash(docker-compose:*), Read, Grep, Glob, Edit, Write, WebSearch, WebFetch, Task
---

# /bmad:brownfield-enhancement

## BROWNFIELD ENHANCEMENT WORKFLOW

Comprehensive workflow for enhancing existing systems with new features, modernization, or significant improvements. Handles existing system analysis, safe integration, and coordinated enhancement execution.

**When to Use:**
- Adding major features to existing applications
- System modernization and refactoring projects
- Integration with external systems or services
- Performance improvements and scalability enhancements
- UI/UX redesigns for existing applications

## PHASE 0: ENHANCEMENT CLASSIFICATION & ROUTING

### 0A) Business Analyst â†' Enhancement Scope Analysis
**STEP 1 TRIGGER: Use Task tool to invoke analyst-agent**
```
Use Task tool to invoke analyst-agent to classify and scope the enhancement request.
```

**MANDATORY: Wait for analyst-agent completion confirmation before proceeding to routing decision.**

**Classification Process:**
Analyze enhancement complexity and route to appropriate path:

**Single Story Enhancement (< 4 hours):**
- Simple feature additions to existing functionality
- Bug fixes that require coordination
- Configuration or integration changes
- **Route to**: Direct story creation with brownfield context

**Small Feature Enhancement (1-3 stories):**
- Focused feature additions with clear scope
- Minor integrations or workflow improvements
- UI improvements within existing design system
- **Route to**: Epic creation with focused planning

**Major Enhancement (Multiple epics):**
- Significant new capabilities or system changes
- Architectural modifications or technology updates
- Complex integrations affecting multiple systems
- **Route to**: Continue with comprehensive planning workflow

**Classification Questions:**
1. "Can you describe the enhancement scope? Is this a small fix, feature addition, or major enhancement requiring architectural changes?"
2. "How many existing system components will be affected?"
3. "Do you need new architectural patterns or can we extend existing approaches?"
4. "Will this require changes to user workflows or system integrations?"

### 0B) Routing Decision Based on Classification

#### Route A: Single Story Path
**For simple enhancements < 4 hours:**
```
STEP 2A TRIGGER: Use Task tool to invoke pm-agent
Use brownfield-create-story task → Exit to development
MANDATORY: Wait for pm-agent completion confirmation
```

#### Route B: Small Feature Path  
**For focused enhancements 1-3 stories:**
```
STEP 2B TRIGGER: Use Task tool to invoke pm-agent
Use brownfield-create-epic task → Exit to story development
MANDATORY: Wait for pm-agent completion confirmation
```

#### Route C: Major Enhancement Path
**For complex multi-story enhancements:**
Continue with comprehensive planning workflow below.

## PHASE 1: EXISTING SYSTEM ANALYSIS

### 1A) Documentation Assessment
**Business Analyst â†’ Existing Documentation Review:**
```
Check if adequate project documentation exists for enhancement planning.
```

**Documentation Assessment:**
- Look for existing architecture docs, API specs, coding standards
- Assess if documentation is current and comprehensive enough for planning
- **If Adequate**: Skip system analysis, proceed directly to enhancement PRD
- **If Inadequate**: Run comprehensive system documentation before PRD

### 1B) CONDITIONAL: System Architecture Analysis
**System Architect â†' Comprehensive System Documentation:**
```
ONLY if documentation inadequate: 
STEP 3 TRIGGER: Use Task tool to invoke architect-agent
Use document-project capability to create comprehensive brownfield documentation
MANDATORY: Wait for architect-agent completion confirmation before proceeding
```

**System Analysis Deliverables:**
- Current system architecture and technical debt assessment
- Integration points and dependency mapping
- Performance bottlenecks and scalability constraints
- Security considerations and compliance requirements
- Refactoring opportunities and modernization candidates

**Output Location:** Multiple documents per document-project template

## PHASE 2: ENHANCEMENT PLANNING

### 2A) Product Manager â†' Enhancement PRD
**STEP 4 TRIGGER: Use Task tool to invoke pm-agent**
```
Use Task tool to invoke pm-agent to create comprehensive enhancement PRD.
```

**MANDATORY: Wait for pm-agent completion confirmation before proceeding to architecture planning.**

**Input:** Existing documentation or system analysis
**Enhancement PRD Focus:**
- Enhancement objectives and success criteria
- Integration strategy with existing functionality
- User impact analysis and migration planning
- Risk assessment for existing system stability
- Rollout and deployment strategy

**Key Considerations:**
- Avoid re-analyzing aspects covered in system documentation
- Reference existing architecture and constraints
- Plan for backward compatibility and migration paths

**Output Location:** Save as `docs/enhancement-prd.md`

### 2B) CONDITIONAL: Architecture Planning
**Architecture Decision Assessment:**
```
Review PRD to determine if architectural planning needed:
- New architectural patterns â†’ Create architecture doc
- New libraries/frameworks â†’ Create architecture doc  
- Platform/infrastructure changes â†’ Create architecture doc
- Following existing patterns â†’ Skip to validation
```

**System Architect â†' Enhancement Architecture:**
```
ONLY if architectural changes needed: 
STEP 5 TRIGGER: Use Task tool to invoke architect-agent
MANDATORY: Wait for architect-agent completion confirmation before proceeding
```

**Enhancement Architecture Focus:**
- Integration approach with existing architecture
- Migration strategy for affected components
- New component design within existing patterns
- Technical debt remediation opportunities
- Performance and scalability improvements

**Output Location:** Save as `docs/enhancement-architecture.md`

## PHASE 3: VALIDATION & INTEGRATION

### 3A) Product Owner â†' Enhancement Validation
**STEP 6 TRIGGER: Use Task tool to invoke po-agent**
```
Use Task tool to invoke po-agent to validate enhancement planning for integration safety.
```

**MANDATORY: Wait for po-agent completion confirmation before proceeding to development preparation.**

**Brownfield-Specific Validation:**
- [ ] Enhancement approach minimizes existing system disruption
- [ ] Backward compatibility maintained for existing users
- [ ] Integration points clearly defined and tested
- [ ] Risk mitigation strategies for system stability
- [ ] Rollout plan supports safe deployment

**Integration Safety Assessment:**
- Cross-reference with existing system documentation
- Validate compatibility with current architecture
- Assess impact on existing user workflows
- Confirm testing strategy covers regression scenarios

### 3B) Planning Issue Resolution
**If PO Identifies Issues:**
```
Return to relevant agent (PM/Architect) to fix identified issues.
Re-export updated documents to docs/ folder after fixes.
```

## PHASE 4: DEVELOPMENT PREPARATION

### 4A) Document Sharding for Development
**Product Owner â†' Documentation Preparation:**
```
STEP 7 TRIGGER: Use Task tool to invoke po-agent
Use document sharding capability to prepare enhancement documents for development consumption.
MANDATORY: Wait for po-agent completion confirmation before proceeding
```

**Sharding Options:**
- **Option A**: Use PO agent: Load po-agent â†’ ask to shard docs/enhancement-prd.md
- **Option B**: Manual: Use shard-doc task + docs/enhancement-prd.md
- **Output**: Creates `docs/prd/` and `docs/architecture/` folders

**Brownfield Documentation Package:**
- Sharded enhancement requirements
- Existing system context and constraints
- Integration specifications and testing requirements

### 4B) Story Creation with Brownfield Context
**STEP 8 TRIGGER: Use Task tool to invoke sm-agent**
```
Use Task tool to invoke sm-agent to use systematic story creation process from available documentation.
```

**MANDATORY: Wait for sm-agent completion confirmation before proceeding to development execution.**

**Story Creation Approach:**
- **For Sharded PRD**: Use standard create-next-story task
- **For Brownfield Docs**: Use create-brownfield-story task for varied documentation

**Brownfield Story Considerations:**
- Include existing system integration requirements
- Define regression testing and validation approach
- Plan for incremental rollout and feature flags
- Address backward compatibility requirements

**Quality Gate - Story Validation:**
```
After story creation:
1. SM uses validate-story-draft capability
2. Validates brownfield integration approach
3. Minimum score: 8/10 for brownfield stories
4. Save validation: docs/validation/story-draft-[epic.story]-[date].md
```

## PHASE 5: DEVELOPMENT EXECUTION

### 5A) OPTIONAL: Story Review & Approval
**STEP 9 TRIGGER: Use Task tool to invoke analyst-agent or pm-agent**
```
OPTIONAL: Use Task tool to invoke analyst-agent or pm-agent to review draft stories for enhancement completeness and safety.
NOTE: story-review task coming in future releases.
MANDATORY: If invoked, wait for agent completion confirmation before proceeding
```

**Brownfield Story Review Focus:**
- Validate enhancement scope doesn't exceed safe change boundaries
- Ensure integration approach minimizes system risk
- Confirm rollback and recovery procedures defined
- Validate testing coverage for existing functionality

### 5B) Developer Implementation
**STEP 10 TRIGGER: Use Task tool to invoke dev-agent (New Chat Session)**
```
Use Task tool to invoke dev-agent for enhancement implementation with brownfield considerations.
```

**MANDATORY: Wait for dev-agent completion confirmation before proceeding to QA review.**

**Brownfield Development Process:**
1. **Existing Code Analysis**: Understand current implementation patterns
2. **Integration Planning**: Design enhancement integration with minimal disruption
3. **Incremental Implementation**: Build changes in testable increments
4. **Regression Testing**: Ensure existing functionality remains intact
5. **Migration Support**: Implement data/user migration if needed

**Development Standards:**
- Follow existing code patterns and conventions
- Maintain backward compatibility where possible
- Implement feature flags for safe rollout
- Comprehensive testing of affected workflows

**Quality Gate - Definition of Done:**
```
Before marking story complete:
1. Developer uses validate-story-completion capability
2. Reviews against 8-section DoD checklist
3. Minimum score: 9/10 for production readiness
4. Save validation: docs/validation/story-dod-[epic.story]-[date].md
```

### 5C) OPTIONAL: QA Engineer Review
**STEP 11 TRIGGER: Use Task tool to invoke qa-agent (New Chat Session)**
```
OPTIONAL: Use Task tool to invoke qa-agent for senior review with brownfield quality focus.
MANDATORY: If invoked, wait for qa-agent completion confirmation before proceeding
```

**Brownfield QA Process:**
1. **Integration Testing**: Validate enhancement integrates safely
2. **Regression Validation**: Comprehensive testing of existing functionality
3. **Performance Impact**: Assess enhancement impact on system performance
4. **Deployment Safety**: Validate rollout and rollback procedures

**QA Decision:**
- **QA_APPROVED**: Enhancement safe for deployment
- **NEEDS_DEV_WORK**: Issues identified, return to development

### 5D) Development Cycle Continuation
**Multi-Story Enhancement Management:**
```
Repeat development cycle (SM â†’ Dev â†’ QA) for all enhancement stories.
Continue until all enhancement objectives completed.
```

**Brownfield Coordination:**
- Coordinate changes across multiple system components
- Manage dependencies between enhancement stories
- Maintain system stability throughout development process

## PHASE 6: DEPLOYMENT & VALIDATION

### 6A) CONDITIONAL: Docker Validation (SaaS Projects)
**USER APPROVAL GATE - Deployment Authorization:**
```
🛡️ SECURITY CHECKPOINT: Before proceeding with deployment operations:
1. Confirm all QA validations passed
2. Verify enhancement scope and safety assessment complete
3. User authorization required for git commit and deployment operations
4. Type "APPROVED" to proceed with Docker validation and deployment

MANDATORY: Wait for explicit user approval before any git or deployment operations
```

**For SaaS/Docker-based Projects:**
```
{{#if PROJECT_TYPE.saas}}
Post-commit Docker validation:
- Build: docker-compose -f docker-compose\.yml build (or docker-compose build)
- Restart: docker-compose down && docker-compose up -d
- Health Check: Backend http://localhost:8001/health, Frontend http://localhost:3000
{{/if}}
```

### 6B) OPTIONAL: Enhancement Retrospective
**STEP 12 TRIGGER: Use Task tool to invoke po-agent**
```
OPTIONAL: Use Task tool to invoke po-agent after enhancement completion to conduct retrospective analysis.
NOTE: epic-retrospective task coming in future releases.
MANDATORY: If invoked, wait for po-agent completion confirmation
```

**Retrospective Focus:**
- Enhancement objectives achievement assessment
- System integration success validation
- Lessons learned for future brownfield enhancements
- Technical debt and modernization opportunities identified

## ENHANCEMENT TYPE SPECIFIC CONSIDERATIONS

### Feature Addition Enhancements
- **Integration Strategy**: Seamless addition to existing user workflows
- **Data Migration**: User data compatibility and migration planning
- **UI Integration**: Consistent design and navigation patterns
- **API Evolution**: Backward-compatible API changes and versioning

### Modernization Enhancements
- **Technology Migration**: Gradual migration strategy for new technologies
- **Architecture Evolution**: Modernization without breaking existing functionality
- **Performance Improvement**: Optimization without workflow disruption
- **Code Quality**: Refactoring and technical debt remediation

### System Integration Enhancements
- **External Service Integration**: Third-party service integration and error handling
- **Data Synchronization**: Cross-system data consistency and conflict resolution
- **Authentication/Authorization**: Security integration with existing user management
- **Monitoring and Observability**: Enhanced system visibility and debugging

## WORKFLOW SUCCESS METRICS

### Enhancement Quality Metrics
- **Integration Success**: Smooth integration with existing system
- **Regression Prevention**: No disruption to existing functionality
- **User Adoption**: Positive user response to enhancements
- **Performance Impact**: Neutral or positive performance effects

### Development Efficiency Metrics
- **Planning Accuracy**: Enhancement scope and timeline accuracy
- **Change Safety**: Minimal rollbacks or production issues
- **Team Coordination**: Effective coordination across system components
- **Documentation Quality**: Clear guidance for future enhancements

### Business Value Metrics
- **Objective Achievement**: Enhancement meets stated business objectives
- **User Satisfaction**: Improved user experience and satisfaction
- **System Reliability**: Enhanced system stability and reliability
- **Technical Debt**: Reduction in technical debt and maintenance burden

## USAGE EXAMPLES

### Example 1: E-commerce Recommendation Engine
```
Enhancement: Add AI-powered product recommendations to existing store
Analysis: Existing system has product catalog, user accounts, purchase history
Planning: Integration points identified, recommendation API designed, UI components planned
Implementation: Backend ML service â†’ Frontend recommendation components â†’ A/B testing
Outcome: Increased sales without disrupting existing shopping experience
```

### Example 2: Mobile App for Existing Web Platform
```
Enhancement: Create mobile app for existing web-based project management tool
Analysis: Existing APIs, user authentication, data models documented
Planning: Mobile-specific features planned, API extensions identified, offline capabilities designed
Implementation: Mobile app development â†’ API enhancements â†’ Cross-platform synchronization
Outcome: Mobile experience that extends web platform capabilities
```

Remember: Brownfield enhancements require careful balance between innovation and stability. Respect existing system patterns while strategically introducing improvements that enhance user value and system capabilities.
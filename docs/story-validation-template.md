# Story Validation Report

**Project:** BMAD-CC (other)  
**Story:** [Epic.Story] - [Story Title]  
**Validation Date:** {{DATE}}  
**Validator:** Product Owner Agent  

## Validation Overview

**Story File:** `[path to story file]`  
**Story Status:** [Current status from file]  
**Validation Trigger:** [Why validation was requested]  

## Section 1: Template Completeness Validation

### 1.1 Required Sections Check
- [ ] **Story Overview**
  - [ ] Story title present and descriptive
  - [ ] User story statement complete (As a... I want... So that...)
  - [ ] Business value clearly stated
  - [ ] Priority and complexity assigned

- [ ] **Requirements & Acceptance Criteria**
  - [ ] Functional requirements specified
  - [ ] Acceptance criteria in Given-When-Then format
  - [ ] Definition of done checklist complete
  - [ ] Success criteria measurable

- [ ] **Design & Technical Specifications**
  - [ ] UI/UX requirements specified (if applicable)
  - [ ] Technical implementation notes provided
  - [ ] Performance requirements defined
  - [ ] Security considerations addressed

- [ ] **Agent Permissions & Ownership**
  - [ ] Primary agent assigned with permissions
  - [ ] Secondary agents identified with roles
  - [ ] Escalation hierarchy defined
  - [ ] Approval authority specified

- [ ] **Story Breakdown & Tasks**
  - [ ] Implementation tasks listed
  - [ ] Task dependencies identified
  - [ ] Testing strategy defined
  - [ ] Timeline estimates provided

### 1.2 Placeholder and Template Issues
**Unfilled Placeholders Found:**
- [ ] None found ✅
- [ ] Issues found ❌: [List specific placeholders or template variables not filled]

**Template Structure Issues:**
- [ ] None found ✅  
- [ ] Issues found ❌: [List formatting, section, or structural problems]

## Section 2: Technical Accuracy Validation

### 2.1 Architecture Alignment Check
- [ ] **Technology Stack Consistency**
  - [ ] Referenced technologies match architecture specification
  - [ ] Version requirements align with project standards
  - [ ] Framework choices consistent with existing patterns
  - Conflicts Found: [None/List specific conflicts]

- [ ] **Data Model References**
  - [ ] Database schemas referenced correctly
  - [ ] API endpoints align with specifications  
  - [ ] Data structures match architecture documents
  - Conflicts Found: [None/List specific conflicts]

- [ ] **Component and File References**
  - [ ] File paths match project structure
  - [ ] Component specifications align with architecture
  - [ ] Integration points correctly identified
  - Conflicts Found: [None/List specific conflicts]

### 2.2 Anti-Hallucination Verification
**Source Reference Audit:**
- [ ] All technical claims include source references
- [ ] Source references are accurate and accessible  
- [ ] No invented libraries, patterns, or standards
- [ ] References use format: `[Source: architecture/{filename}.md#{section}]`

**Unverifiable Claims Found:**
- [ ] None found ✅
- [ ] Claims found ❌: [List specific technical claims that cannot be verified against source documents]

**Missing Source References:**
- [ ] None found ✅
- [ ] Missing references ❌: [List technical details that need source references]

## Section 3: Implementation Readiness Assessment

### 3.1 Self-Contained Context Check
- [ ] **Technical Context Completeness**
  - [ ] All required technical details present in Dev Notes
  - [ ] Integration approach clearly specified
  - [ ] Required libraries and dependencies identified
  - [ ] Configuration requirements specified

- [ ] **Implementation Guidance Quality**
  - [ ] Step-by-step tasks are actionable
  - [ ] File creation locations specified
  - [ ] Code patterns and examples provided
  - [ ] Error handling approaches defined

### 3.2 Development Agent Readiness
**Can Developer implement without external research?**
- [ ] Yes - Story is fully self-contained ✅
- [ ] No - Additional context needed ❌

**Missing Information for Implementation:**
- [ ] None identified ✅
- [ ] Information gaps ❌: [List specific information developer would need to seek externally]

**Implementation Blockers:**
- [ ] None identified ✅
- [ ] Blockers found ❌: [List issues that would prevent or delay implementation]

## Section 4: Acceptance Criteria Assessment

### 4.1 Coverage Analysis
- [ ] **Functional Requirements Coverage**
  - [ ] All stated requirements have corresponding acceptance criteria
  - [ ] Acceptance criteria are specific and testable
  - [ ] Edge cases and error conditions covered
  - [ ] Integration scenarios addressed

- [ ] **Testing Completeness**
  - [ ] Unit testing requirements specified
  - [ ] Integration testing approach defined
  - [ ] User acceptance testing scenarios provided
  - [ ] Performance testing criteria included (if applicable)

### 4.2 Quality Assessment
**Acceptance Criteria Quality:**
- [ ] All criteria use testable language
- [ ] Success conditions are measurable
- [ ] Failure conditions are identified
- [ ] Prerequisites and assumptions stated

**Missing or Weak Criteria:**
- [ ] None identified ✅
- [ ] Improvements needed ❌: [List specific acceptance criteria that need strengthening]

## Section 5: Task Sequence and Dependencies

### 5.1 Task Logic Validation
- [ ] **Implementation Order**
  - [ ] Tasks follow logical implementation sequence
  - [ ] Prerequisites completed before dependent tasks
  - [ ] Integration tasks properly scheduled
  - [ ] Testing tasks appropriately placed

- [ ] **Task Granularity**
  - [ ] Tasks are appropriately sized (not too large/small)
  - [ ] Each task has clear completion criteria
  - [ ] Task complexity is manageable
  - [ ] Tasks map clearly to acceptance criteria

### 5.2 Dependency Analysis
**Task Dependencies:**
- [ ] All dependencies explicitly identified
- [ ] No circular dependencies present
- [ ] External dependencies noted and manageable
- [ ] Resource dependencies specified

**Blocking Issues:**
- [ ] None identified ✅
- [ ] Issues found ❌: [List tasks that would block others or create implementation problems]

## Section 6: Validation Summary

### 6.1 Critical Issues (Must Fix - Story Blocked)
- [ ] No critical issues found ✅
- [ ] Critical issues identified ❌:
  1. [Issue description with specific location and fix needed]
  2. [Additional critical issues]

### 6.2 Should-Fix Issues (Important Quality Improvements)
- [ ] No important issues found ✅
- [ ] Important issues identified ❌:
  1. [Issue description with improvement recommendation]
  2. [Additional important issues]

### 6.3 Nice-to-Have Improvements (Optional Enhancements)
- [ ] No improvements suggested
- [ ] Improvements suggested:
  1. [Enhancement description]
  2. [Additional improvements]

## Section 7: Final Assessment

### 7.1 Implementation Readiness Score
**Overall Score:** [1-10 scale]

**Score Breakdown:**
- Template Completeness: [1-10]
- Technical Accuracy: [1-10]  
- Implementation Readiness: [1-10]
- Acceptance Criteria Quality: [1-10]
- Task Sequence Logic: [1-10]

### 7.2 Validation Decision

**Final Status:**
- [ ] **GO** - Story ready for implementation (Score 8-10) ✅
- [ ] **NO-GO** - Story requires fixes before implementation (Score < 8) ❌

**Confidence Level:**
- [ ] **High** - Very confident in successful implementation
- [ ] **Medium** - Generally confident with minor concerns
- [ ] **Low** - Significant concerns about implementation success

### 7.3 Recommendations

**Immediate Actions Required:**
1. [Specific action needed before implementation can begin]
2. [Additional required actions]

**Recommended Improvements:**
1. [Improvement that would enhance implementation success]
2. [Additional recommended improvements]

**Next Steps:**
- [ ] Story approved for development - hand off to Developer Agent
- [ ] Story returned to Scrum Master for fixes - see issues above
- [ ] Story requires stakeholder review - escalate for clarification
- [ ] Story needs architectural guidance - consult System Architect

---

**Validation Control**
- **Validation Started:** {{DATE}}
- **Validation Completed:** [Completion timestamp]
- **Total Validation Time:** [Duration]
- **Validator Confidence:** [High/Medium/Low]
- **Recommended for Implementation:** [Yes/No]

### Validation History
| Date | Validator | Action | Outcome |
|------|-----------|--------|---------|
| {{DATE}} | PO Agent | Initial validation | [Status and key findings] |

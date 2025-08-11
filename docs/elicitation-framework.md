# Interactive Elicitation Framework

**Project:** BMAD-CC (other)  
**Created:** {{DATE}}  

## Purpose
This framework provides structured question sets for agents to systematically gather information when creating documents from templates. Use these elicitation patterns to ensure comprehensive information gathering.

## Universal Elicitation Principles

### 1. Start with Context
- **Current State**: "Can you describe the current situation or starting point?"
- **Desired Outcome**: "What does success look like for this project/feature/initiative?"
- **Stakeholders**: "Who are the key people involved or affected by this?"
- **Timeline**: "What are the key deadlines or time constraints?"

### 2. Use Progressive Disclosure
- Start with broad, open-ended questions
- Follow up with specific, detailed questions
- Ask clarifying questions based on responses
- Confirm understanding before moving forward

### 3. Validate and Confirm
- Summarize what you've learned periodically
- Ask for confirmation: "Did I understand correctly that...?"
- Identify gaps: "What haven't I asked about that's important?"
- Check assumptions: "I'm assuming X, is that correct?"

## Project Brief Elicitation (Business Analyst)

### Business Context Questions
1. **Problem/Opportunity**: "What specific business problem or opportunity are we addressing?"
2. **Market Context**: "What market conditions or trends make this important now?"
3. **Success Metrics**: "How will we measure success? What are the key KPIs?"
4. **Business Impact**: "What happens if we don't do this project?"

### User & Market Questions
1. **Target Users**: "Who are our primary users? What are their key characteristics?"
2. **User Problems**: "What specific problems do these users face today?"
3. **Market Size**: "How large is the potential market or user base?"
4. **Competition**: "Who else is solving this problem? How are they doing it?"

### Constraints & Resources
1. **Budget**: "What budget constraints do we need to work within?"
2. **Timeline**: "What are the critical dates or launch windows?"
3. **Resources**: "What team members or skills do we have available?"
4. **Technical**: "Are there any technical platforms or constraints to consider?"

## PRD Elicitation (Product Manager)

### Product Vision Questions
1. **Product Vision**: "In one sentence, what will this product do for users?"
2. **Strategic Alignment**: "How does this align with broader company strategy?"
3. **Differentiation**: "What will make this product unique or better?"
4. **User Value**: "What's the core value proposition for users?"

### Functional Requirements
1. **Core Features**: "What are the must-have features for launch?"
2. **User Workflows**: "Can you walk me through the main user workflows?"
3. **Integration Needs**: "What systems or services does this need to integrate with?"
4. **Data Requirements**: "What data do we need to collect, store, or display?"

### Quality & Constraints
1. **Performance**: "What are the performance requirements (speed, capacity, etc.)?"
2. **Security**: "What security or privacy requirements do we have?"
3. **Compliance**: "Are there any regulatory or compliance requirements?"
4. **Scalability**: "How many users do we expect initially and long-term?"

## Architecture Elicitation (System Architect)

### Technical Context Questions
1. **Existing Systems**: "What existing systems or technologies are we building on?"
2. **Technical Constraints**: "Are there any technology preferences or restrictions?"
3. **Team Skills**: "What technologies is the development team most comfortable with?"
4. **Infrastructure**: "What hosting or infrastructure do we have available?"

### System Design Questions
1. **Scale Requirements**: "How many users, transactions, or data volume do we expect?"
2. **Integration Points**: "What external systems do we need to connect to?"
3. **Data Flow**: "How does data move through the system?"
4. **Security Needs**: "What are the authentication, authorization, and data protection needs?"

### Implementation Planning
1. **Phases**: "Does this need to be built in phases or all at once?"
2. **Risk Areas**: "What are the highest technical risks or unknowns?"
3. **Dependencies**: "What external dependencies or decisions do we need?"
4. **Quality Standards**: "What are the code quality, testing, and documentation requirements?"

## UX Design Elicitation (UX Expert)

### User Experience Questions
1. **User Goals**: "What are users trying to accomplish with this product?"
2. **User Context**: "Where and when will users be using this?"
3. **User Skills**: "What's the technical skill level of our users?"
4. **Device Usage**: "What devices will users primarily use?"

### Design Requirements
1. **Brand Guidelines**: "Are there existing brand or design standards to follow?"
2. **Accessibility**: "What accessibility requirements do we need to meet?"
3. **Design Preferences**: "Are there any specific design styles or approaches preferred?"
4. **Content Strategy**: "What kind of content will we be displaying?"

### Interaction Design
1. **Key User Flows**: "What are the most important user workflows to optimize?"
2. **Error Scenarios**: "What happens when things go wrong? How should we handle errors?"
3. **Feedback Needs**: "How do users know when actions are successful or complete?"
4. **Navigation**: "How should users move between different parts of the product?"

## Story Elicitation (Scrum Master)

### Story Context Questions
1. **User Perspective**: "From the user's point of view, what are they trying to accomplish?"
2. **Business Value**: "Why is this story important to the business?"
3. **Priority**: "How does this compare in priority to other pending work?"
4. **Dependencies**: "What other work needs to be done first?"

### Acceptance Criteria
1. **Success Scenarios**: "What does success look like for this story?"
2. **Edge Cases**: "What are the edge cases or error conditions to consider?"
3. **Data Scenarios**: "What different data states or conditions need to be handled?"
4. **User Validation**: "How will we know users can actually use this successfully?"

### Implementation Details
1. **Technical Approach**: "Are there any specific technical requirements or preferences?"
2. **UI/UX Needs**: "What user interface elements or interactions are needed?"
3. **Testing Strategy**: "How should this be tested? What test scenarios are critical?"
4. **Completion Criteria**: "What needs to be done before this story is considered complete?"

## Elicitation Best Practices

### Question Techniques
- **Open-ended first**: "Tell me about..." vs "Is it true that..."
- **Follow the 5 Whys**: Keep asking "why" to get to root causes
- **Use scenarios**: "What would happen if..." or "Walk me through..."
- **Seek examples**: "Can you give me an example of..."

### Active Listening
- **Reflect back**: "So what I'm hearing is..."
- **Probe deeper**: "That's interesting, tell me more about..."
- **Notice omissions**: "I noticed you didn't mention X, is that not relevant?"
- **Ask about assumptions**: "It sounds like you're assuming Y, is that correct?"

### Information Organization
- **Take notes**: Document key points as you gather information
- **Group related items**: Organize information into logical categories
- **Identify patterns**: Look for themes and connections across responses
- **Flag uncertainties**: Mark areas that need more research or clarification

### Validation Techniques
- **Summarize regularly**: "Let me summarize what we've covered..."
- **Check completeness**: "What haven't I asked about that's important?"
- **Confirm priorities**: "Of everything we've discussed, what's most critical?"
- **Test understanding**: "If I were to explain this to someone else, would I say..."

## Using This Framework

### For Agents
1. **Select relevant question set** based on the document type you're creating
2. **Start with context questions** to establish the foundation
3. **Progress through specific areas** systematically
4. **Use follow-up questions** based on responses
5. **Validate understanding** before finalizing the document

### For Users
- Be prepared to provide context and background
- Think through specific examples and scenarios
- Identify stakeholders who might need to provide input
- Consider both short-term and long-term perspectives
- Don't hesitate to say "I don't know" - it helps identify research needs

### Integration with Templates
1. **Load the appropriate template** first
2. **Use elicitation questions** to gather information for each template section
3. **Fill in template sections** as you gather information
4. **Review completed sections** with stakeholders for validation
5. **Iterate and refine** based on feedback and new information

---

**Usage Notes:**
- Adapt questions to your specific project context
- Don't feel obligated to ask every question if the answer is already known
- Follow interesting threads that emerge during elicitation
- Document assumptions when information isn't available
- Schedule follow-up sessions for complex topics

**Document Control:**
- This framework should be referenced by all strategic agents
- Update questions based on lessons learned from real projects
- Customize for specific project types or industries as needed

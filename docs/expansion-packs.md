# BMAD Framework Expansion Packs

## Overview

Expansion packs extend the BMAD Framework beyond traditional software development into specialized domains. They provide domain-specific agent teams, templates, workflows, and tools while keeping the core framework lean and focused.

## Philosophy

### Core Framework vs Expansion Packs

**Core Framework (What's Included)**:
- Software development agents (PM, Dev, QA, etc.)
- Standard Agile workflows
- Docker and Task Master integration
- General-purpose templates

**Expansion Packs (Domain Extensions)**:
- Specialized industry agents
- Domain-specific workflows
- Custom templates and checklists
- Specialized quality gates

### Design Principles

1. **Keep Core Lean**: Development agents need maximum context for coding
2. **Domain Expertise**: Deep, specialized knowledge without bloating core
3. **Modular Architecture**: Install only what you need
4. **Community Driven**: Anyone can create and share packs

## Available Expansion Pack Categories

### Technical Domains

#### Infrastructure & DevOps Pack
**Agents**: Cloud Architect, SRE Expert, Security Specialist, Cost Optimizer
**Use Cases**: 
- Cloud migration planning
- Infrastructure as Code development
- Security hardening
- Cost optimization

#### Data Science & ML Pack
**Agents**: ML Engineer, Data Scientist, MLOps Specialist
**Use Cases**:
- Model development workflows
- Data pipeline architecture
- Experiment tracking
- Model deployment

#### Game Development Pack
**Agents**: Game Designer, Level Designer, Narrative Writer, Audio Engineer
**Use Cases**:
- Game mechanics design
- Level progression planning
- Story development
- Asset management

#### Mobile Development Pack
**Agents**: iOS Specialist, Android Expert, Mobile UX Designer
**Use Cases**:
- Platform-specific optimization
- App store submission
- Native feature integration
- Performance tuning

### Business Domains

#### Marketing & Growth Pack
**Agents**: Marketing Strategist, Growth Hacker, Content Creator, SEO Expert
**Use Cases**:
- Marketing campaign planning
- Content strategy
- Growth experiments
- Analytics setup

#### Legal & Compliance Pack
**Agents**: Contract Analyst, Compliance Officer, Privacy Expert
**Use Cases**:
- Contract review
- GDPR compliance
- Terms of service
- Privacy policies

#### Finance & Analytics Pack
**Agents**: Financial Analyst, Budget Planner, ROI Calculator
**Use Cases**:
- Financial modeling
- Budget planning
- Investment analysis
- Cost-benefit analysis

### Creative Domains

#### Content Creation Pack
**Agents**: Copy Writer, Technical Writer, Blog Strategist
**Use Cases**:
- Documentation writing
- Blog content creation
- Marketing copy
- Technical tutorials

#### Design System Pack
**Agents**: Brand Designer, Icon Designer, Animation Specialist
**Use Cases**:
- Brand identity development
- Design system creation
- Animation planning
- Asset creation

## Creating Custom Expansion Packs

### Pack Structure

```
expansion-packs/
â””â”€â”€ my-custom-pack/
    â”œâ”€â”€ manifest.yaml           # Pack metadata and configuration
    â”œâ”€â”€ agents/                 # Specialized agents
    â”‚   â”œâ”€â”€ agent-1.md
    â”‚   â””â”€â”€ agent-2.md
    â”œâ”€â”€ workflows/              # Domain-specific workflows
    â”‚   â””â”€â”€ custom-cycle.md
    â”œâ”€â”€ templates/              # Specialized templates
    â”‚   â””â”€â”€ domain-template.md
    â”œâ”€â”€ hooks/                  # Custom quality gates
    â”‚   â””â”€â”€ domain-check.ps1
    â””â”€â”€ README.md              # Pack documentation
```

### Manifest File (manifest.yaml)

```yaml
name: my-custom-pack
version: 1.0.0
description: Specialized pack for [domain]
author: Your Name
compatibility: bmad-framework-v1

agents:
  - name: specialist-1
    description: Domain expert for X
    color: blue
    
  - name: specialist-2  
    description: Domain expert for Y
    color: green

workflows:
  - name: custom-cycle
    description: Specialized workflow for domain
    
templates:
  - name: domain-template
    description: Template for domain artifacts

dependencies:
  - core-framework: ">=1.0.0"
  - task-master: optional
```

### Agent Template

```markdown
---
name: domain-specialist
color: purple
description: Specialist for BMAD-CC - Domain expertise
tools: Read, Write, Edit, Grep
---

# Domain Specialist Agent

## ROLE
You are [Name], the Domain Specialist responsible for...

## CORE RESPONSIBILITIES
- Responsibility 1
- Responsibility 2
- Responsibility 3

## DOMAIN EXPERTISE
### Specialized Knowledge
- Deep understanding of...
- Experience with...
- Best practices for...

## WORKFLOW INTEGRATION
### With Core Agents
- How you work with PM agent
- How you work with Dev agent
- How you support QA agent

## DELIVERABLES
- Deliverable 1
- Deliverable 2
- Deliverable 3
```

## Installation & Usage

### Installing an Expansion Pack

```bash
# Future CLI command (not yet implemented)
bmad-framework install-pack [pack-name]

# Manual installation
1. Download pack to expansion-packs/ directory
2. Run setup script to integrate
3. Restart Claude Code to load new agents
```

### Using Expansion Pack Agents

Once installed, expansion pack agents work like core agents:

```
# In Claude Code
/domain-specialist help
/custom-workflow start

# In workflows
Load the domain-specialist agent for specialized analysis
```

## Best Practices

### When to Create an Expansion Pack

âœ… **Good Candidates**:
- Specialized industry knowledge (healthcare, finance, etc.)
- Non-software domains (marketing, legal, creative)
- Platform-specific expertise (Salesforce, SAP, etc.)
- Methodology-specific approaches (Six Sigma, TOGAF, etc.)

âŒ **Keep in Core**:
- General software development
- Standard Agile practices
- Common programming patterns
- Basic project management

### Pack Development Guidelines

1. **Single Responsibility**: Each pack should focus on one domain
2. **Self-Contained**: Minimize dependencies on other packs
3. **Well-Documented**: Include examples and use cases
4. **Tested**: Validate with real projects
5. **Versioned**: Use semantic versioning

### Integration with Core Framework

Expansion packs should:
- Complement, not replace core agents
- Use consistent naming conventions
- Follow BMAD workflow patterns
- Integrate with Task Master when applicable
- Respect the no-fallback policy

## Future Roadmap

### Planned Expansion Packs

**Q1 2025**:
- Healthcare & Medical
- E-commerce & Retail
- Education & Training

**Q2 2025**:
- Real Estate
- Manufacturing
- Non-profit

### Pack Marketplace

Future plans include:
- Central registry for discovering packs
- Rating and review system
- Automated installation via CLI
- Pack dependencies management
- Version compatibility checking

## Contributing

### How to Contribute a Pack

1. Fork the BMAD Framework repository
2. Create your pack in expansion-packs/
3. Test with real projects
4. Submit PR with:
   - Pack files
   - Documentation
   - Example usage
   - Test results

### Pack Certification

Certified packs meet quality standards:
- âœ… Complete documentation
- âœ… Tested on 3+ projects
- âœ… Peer reviewed
- âœ… Maintains compatibility
- âœ… Active maintenance

## Support

### Getting Help

- **Discord**: #expansion-packs channel
- **GitHub**: expansion-packs label
- **Docs**: expansion-packs/README.md

### Requesting New Packs

Submit requests via GitHub issues with:
- Domain description
- Use cases
- Agent roles needed
- Workflow requirements
- Business justification

---

*Expansion packs democratize expertise by making specialized knowledge accessible through AI agents. Build once, benefit forever.*
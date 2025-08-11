# BMAD-CC Customization Guide

## Overview

BMAD-CC is designed to adapt to your specific needs, technology stack, and development practices. This guide covers how to customize the framework for your project, team, and preferences.

## Technical Preferences

### Setting Up Your Preferences

The `docs/data/technical-preferences.md` file stores your technology choices and development practices. This ensures all agents generate consistent, relevant outputs.

#### Initial Configuration

1. Open `docs/data/technical-preferences.md`
2. Fill in each section with your choices
3. Save the file
4. Agents will automatically use these preferences

#### Key Sections to Configure

**Programming Languages**:
```markdown
- **Primary Language**: TypeScript
- **Language Version**: 5.0+
- **Secondary Languages**: SQL, Python
```

**Frameworks & Libraries**:
```markdown
#### Frontend
- **UI Framework**: React 18
- **CSS Framework**: Tailwind CSS
- **State Management**: Zustand
- **Form Handling**: React Hook Form

#### Backend
- **API Framework**: Express with TypeScript
- **ORM/Database**: Prisma
- **Authentication**: JWT with refresh tokens
- **Testing**: Jest, Supertest
```

**Code Style**:
```markdown
- **Indentation**: 2 spaces
- **Quote Style**: Single quotes
- **Semicolons**: Always
- **Line Length**: 100 characters
- **File Naming**: kebab-case
```

### Impact on Agents

Your preferences affect how agents work:

| Agent | How Preferences Are Used |
|-------|-------------------------|
| Developer | Writes code in your style and stack |
| Architect | Designs with your technology constraints |
| QA Engineer | Tests using your frameworks |
| PM | Considers your tech capabilities |

### Updating Preferences

As your project evolves:
1. Update the preferences file
2. Commit changes to Git
3. All agents immediately use new preferences
4. No restart required

---

## Project Type Customization

### Supported Project Types

BMAD-CC auto-detects and adapts to:

| Type | Detection | Customizations |
|------|-----------|----------------|
| `saas` | Has `frontend/` and `backend/` | Multi-tenant features, API focus |
| `phaser` | Has game files | Game dev workflows, performance focus |
| `mobile` | Has iOS/Android dirs | Platform-specific, offline capable |
| `other` | Default | Generic workflows |

### Custom Project Types

To add a new project type:

1. **Update Detection Logic** in `bootstrap.ps1`:
```powershell
if (Test-Path "$ProjectDir/your-indicator") {
    $ProjectType = "custom-type"
}
```

2. **Create Type-Specific Templates**:
```
templates/
└── custom-type/
    ├── agents/
    ├── workflows/
    └── templates/
```

3. **Update Agent Behaviors**:
```markdown
{{#if PROJECT_TYPE.custom-type}}
- Custom type specific instructions
- Special considerations
- Unique workflows
{{/if}}
```

---

## Workflow Customization

### Creating Custom Workflows

1. **Create Workflow File**:
```
.claude/commands/bmad/custom-workflow.md
```

2. **Define Workflow Structure**:
```markdown
---
description: Custom workflow for specific needs
allowed-tools: Read, Write, Edit, Bash
---

# /bmad:custom-workflow

## Phase 1: Custom Analysis
Load appropriate agents...

## Phase 2: Custom Implementation
Execute custom steps...
```

3. **Register in Smart Cycle**:
Add routing logic to detect when to use your workflow

### Modifying Existing Workflows

1. Edit workflow files in `.claude/commands/bmad/`
2. Adjust phase sequences
3. Add/remove quality gates
4. Customize agent involvement

### Workflow Parameters

Customize through environment variables:
```powershell
# Skip certain phases
$env:BMAD_SKIP_VALIDATION = "1"

# Adjust timeouts
$env:BMAD_TIMEOUT = "600"

# Change quality thresholds
$env:BMAD_MIN_QUALITY_SCORE = "7"
```

---

## Agent Customization

### Modifying Agent Behavior

1. **Edit Agent Files** in `.claude/agents/`:
```markdown
## CUSTOM INSTRUCTIONS
Add your specific requirements here...
```

2. **Add Capabilities**:
```markdown
## ADDITIONAL CAPABILITIES
### Custom Analysis
When asked to "analyze-custom":
1. Load custom template
2. Execute custom logic
3. Generate custom report
```

3. **Adjust Permissions**:
```yaml
tools: Read, Write, Edit, Bash, WebSearch
```

### Creating Custom Agents

1. **Create Agent File**:
```
.claude/agents/custom-agent.md
```

2. **Define Agent Structure**:
```markdown
---
name: custom-agent
color: teal
description: Specialized for your needs
tools: Read, Write
---

# Custom Agent

## ROLE
You are...

## RESPONSIBILITIES
- Responsibility 1
- Responsibility 2

## WORKFLOW INTEGRATION
How you work with other agents...
```

---

## Expansion Packs

### Understanding Expansion Packs

Expansion packs extend BMAD into specialized domains without bloating the core framework.

### Available Expansion Packs

| Pack | Domain | Agents Included |
|------|--------|-----------------|
| Infrastructure | DevOps | Cloud Architect, SRE, Security |
| Data Science | ML/AI | Data Scientist, ML Engineer |
| Marketing | Growth | Marketing Strategist, SEO Expert |
| Legal | Compliance | Contract Analyst, Privacy Expert |

### Installing Expansion Packs

1. **Download Pack**:
```bash
git clone https://github.com/community/bmad-pack-infrastructure.git
```

2. **Install Pack**:
```powershell
.\install-pack.ps1 -PackDir "bmad-pack-infrastructure"
```

3. **Verify Installation**:
```bash
ls .claude/agents/
# Should show new specialized agents
```

### Creating Your Own Expansion Pack

#### Pack Structure
```
my-expansion-pack/
├── manifest.yaml       # Pack metadata
├── agents/            # Specialized agents
├── workflows/         # Domain workflows
├── templates/         # Domain templates
├── hooks/            # Custom automation
└── README.md         # Documentation
```

#### Manifest File
```yaml
name: my-domain-pack
version: 1.0.0
description: Specialized for my domain
compatibility: bmad-cc-2.1+

agents:
  - name: domain-expert
    description: Expert in domain
    
workflows:
  - name: domain-workflow
    description: Domain-specific process
    
dependencies:
  - core-framework: ">=2.1.0"
```

#### Distribution
1. Create GitHub repository
2. Tag releases
3. Share with community
4. Submit to pack registry

---

## Docker Customization

### Custom Docker Configuration

1. **Modify `docker-compose.yml`**:
```yaml
services:
  custom-service:
    build: ./custom
    ports:
      - "9000:9000"
    environment:
      - CUSTOM_VAR=value
```

2. **Add Health Checks**:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:9000/health"]
  interval: 30s
```

3. **Custom Networks**:
```yaml
networks:
  custom-net:
    driver: bridge
```

### Environment-Specific Configs

```yaml
# docker-compose.dev.yml
services:
  backend:
    environment:
      - DEBUG=true

# docker-compose.prod.yml
services:
  backend:
    environment:
      - DEBUG=false
```

---

## Hook Customization

### Creating Custom Hooks

1. **Create Hook File**:
```
.claude/hooks/custom-hook.ps1
```

2. **Define Hook Logic**:
```powershell
param(
    [string]$Event,
    [string]$Data
)

if ($Event -eq "post-commit") {
    # Custom post-commit logic
    Write-Host "Running custom hook..."
}
```

3. **Register in Settings**:
```json
{
  "hooks": {
    "custom-hook": {
      "events": ["post-commit"],
      "script": ".claude/hooks/custom-hook.ps1"
    }
  }
}
```

### Hook Events

| Event | Trigger | Use Case |
|-------|---------|----------|
| `post-tool-use` | After any tool | Logging, validation |
| `pre-commit` | Before Git commit | Code formatting |
| `post-commit` | After Git commit | Backup, notification |
| `quality-gate` | Quality check | Enforce standards |

---

## Quality Gate Customization

### Adjusting Thresholds

1. **Edit Checklist Files** in `docs/templates/`:
```markdown
**Minimum Score**: 7/10  # Change from 8/10
```

2. **Environment Override**:
```powershell
$env:BMAD_PRD_MIN_SCORE = "6"
$env:BMAD_STORY_MIN_SCORE = "7"
```

### Custom Validation Rules

1. **Add to Checklists**:
```markdown
#### Custom Section (Score: 1-10)
- [ ] Custom requirement 1
- [ ] Custom requirement 2
```

2. **Create Custom Validator**:
```powershell
# .claude/hooks/custom-validator.ps1
function Validate-Custom {
    # Custom validation logic
    return $score
}
```

---

## Task Master Customization

### Custom Task Types

```bash
# Define custom task type
task-master config --add-type "research"

# Create tasks with custom type
task-master create --type=research --title="Market analysis"
```

### Custom Workflows

```bash
# Create custom task workflow
task-master workflow create --name="custom-flow"

# Define workflow steps
task-master workflow add-step --workflow="custom-flow" --step="research"
```

### Integration Points

```javascript
// Custom task integration
const taskMaster = require('task-master-ai');

taskMaster.on('task-complete', (task) => {
  // Custom completion logic
});
```

---

## Settings Customization

### Local Settings Override

`.claude/settings.local.json`:
```json
{
  "permissions": {
    "git": ["*"],
    "docker": ["*"],
    "custom": ["specific-command"]
  },
  "preferences": {
    "autoSave": true,
    "verboseLogging": false,
    "customSetting": "value"
  }
}
```

### User-Specific Settings

`~/.claude/global-settings.json`:
```json
{
  "defaultProjectType": "saas",
  "preferredLanguage": "typescript",
  "githubUsername": "your-username"
}
```

---

## Best Practices

### Customization Guidelines

1. **Document Changes**: Keep README updated
2. **Version Control**: Commit customizations
3. **Test Thoroughly**: Verify workflows still function
4. **Share Back**: Contribute useful customizations

### Maintaining Upgradability

1. **Isolate Customizations**: Keep in separate files
2. **Use Overrides**: Rather than modifying core
3. **Document Dependencies**: Note what requires your changes
4. **Create Patches**: For core modifications

### Team Customization

1. **Agree on Standards**: Document in technical-preferences
2. **Share Settings**: Commit to repository
3. **Training**: Ensure team knows customizations
4. **Review Regular**: Update as project evolves

---

## Troubleshooting Customizations

### Common Issues

| Issue | Solution |
|-------|----------|
| Agents ignore preferences | Check file path and format |
| Workflows break | Validate syntax, check tools |
| Hooks don't run | Verify permissions, check events |
| Packs conflict | Check version compatibility |

### Validation Commands

```bash
# Validate preferences
cat docs/data/technical-preferences.md

# Check agent loading
/bmad:smart-cycle
# Should acknowledge preferences

# Test hooks
./.claude/hooks/custom-hook.ps1 -Event "test"

# Verify pack installation
ls .claude/agents/ | grep pack-
```

---

*For more help, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or [DOCUMENTATION-MAP.md](DOCUMENTATION-MAP.md).*
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Framework Overview

This is the BMAD Framework (Universal) - a portable framework that installs a complete development loop (agents, hooks, slash commands, Docker checks, Taskmaster integration, and self-learning loop) into any project with a single PowerShell command.

## Core Architecture

The framework uses a template-based approach with token replacement:

- **bootstrap.ps1**: Remote installer script that clones this repo and runs setup
- **scripts/setup.ps1**: Templating engine that copies and customizes templates
- **templates/**: Template files with tokens like `{{PROJECT_NAME}}` that get replaced during installation

### Key Components

1. **Strategic Agents**: Business Analyst, Product Manager, System Architect, UX Expert, Master Orchestrator
2. **Development Agents**: Scrum Master, Product Owner, Developer, QA Engineer, Documentation, Learnings, Git
3. **Slash Commands**: `/bmad:story-cycle` and `/bmad:saas-cycle` for orchestrated workflows
4. **Hooks**: PowerShell scripts that run on tool use and stop events
5. **Settings**: Local Claude Code configuration with permissions and hook definitions

## Project Type Detection

The framework auto-detects project types based on file structure:
- **saas**: Has `frontend/package.json` AND `backend/` directory
- **phaser**: Has `src/client` OR root `package.json`
- **other**: Default fallback

## Installation Commands

### Remote Installation (one-liner)
```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
```

### Manual Setup for Development
```powershell
# Clone and modify this framework
git clone https://github.com/<YOU>/bmad-framework.git
# Replace <YOU> with actual GitHub username in bootstrap.ps1
# Commit and push changes
```

## Template Token System

Templates use these tokens that get replaced during setup:
- `{{PROJECT_NAME}}`: Target project name
- `{{PROJECT_TYPE}}`: saas, phaser, mobile, other
- `{{PRD_PATH}}`: Path to primary planning document
- `{{FRONTEND_DIR}}`, `{{BACKEND_DIR}}`: Directory names
- `{{FRONTEND_PORT}}`, `{{BACKEND_PORT}}`: Port numbers
- `{{DOCKER_COMPOSE_FILE}}`: Docker compose file path
- `{{TASKMASTER_CLI}}`: Task Master command

## File Structure Created

When installed in target projects, creates:
```
.claude/
├── agents/           # Complete agent ecosystem:
│   ├── Strategic Layer: analyst-agent.md, pm-agent.md, architect-agent.md, ux-agent.md
│   ├── Orchestration: orchestrator-agent.md
│   ├── Development: sm-agent.md, po-agent.md, dev-agent.md, qa-agent.md
│   └── Support: doc-agent.md, learnings-agent.md, git-agent.md
├── commands/bmad/    # Cycle commands (story-cycle, saas-cycle)
├── hooks/           # PowerShell hooks for quality gates
└── settings.local.json  # Claude Code configuration

docs/
├── lessons/         # Extracted learnings per story
└── story-notes/     # Implementation notes per story

CHANGELOG.md         # Updated each cycle
```

## Intelligent Workflow System

The framework provides intelligent workflow routing based on request complexity and project needs:

### **Primary Workflow Router**
- **`/bmad:smart-cycle`** - Analyzes requests and routes to optimal workflow automatically

### **Strategic Planning Workflows**  
- **`/bmad:planning-cycle`** - Multi-phase planning using Business Analyst → Product Manager → System Architect → UX Expert
- **`/bmad:greenfield-fullstack`** - Complete new application development from concept to deployment
- **`/bmad:brownfield-enhancement`** - Existing system enhancement with safe integration planning

### **Development Execution Workflows**
- **`/bmad:story-cycle`** - Standard story development: SM → PO → Dev → QA → Doc → Learnings → Git  
- **`/bmad:saas-cycle`** - SaaS development with Docker integration and health checks
- **`/bmad:maintenance-cycle`** - Streamlined workflow for bug fixes and small improvements

### **Workflow Classification Logic**
1. **Maintenance** (< 4 hours) → `maintenance-cycle` (Dev → QA → Git)
2. **Feature Development** (4-40 hours) → `story-cycle` or `saas-cycle` 
3. **Strategic Planning Required** (> 40 hours) → `planning-cycle` → development cycles
4. **New Projects** → `greenfield-fullstack` with comprehensive planning
5. **System Enhancements** → `brownfield-enhancement` with integration analysis

## Quality Gates

Gates are enforced via hooks and prevent progression without:
- **Tests**: All tests passing (pytest for backend, jest/lint for frontend)
- **Documentation**: CHANGELOG.md and story-notes updated
- **Learnings**: Lessons extracted to docs/lessons/

Gates can be temporarily disabled with: `$env:BMAD_DISABLE_GATES = "1"`

## PowerShell Script Security

All PowerShell scripts in this framework use:
- `$ErrorActionPreference = "Stop"` for fail-fast behavior
- `-ExecutionPolicy Bypass` for remote execution
- Template token replacement for customization
- Directory creation with `-Force` flag

## Customization Points

### Adding New Project Types
1. Modify project type detection in both bootstrap.ps1 and setup.ps1
2. Add project-specific templates
3. Create new cycle commands if needed

### Adding New Templates
1. Create `.tmpl` files in appropriate templates/ subdirectory
2. Add mapping in setup.ps1 `$map` array
3. Use `{{TOKEN}}` format for replaceable values

### Modifying Workflows
- Edit cycle commands in templates/.claude/commands/bmad/
- Modify agent behaviors in templates/.claude/agents/
- Adjust quality gates in templates/.claude/hooks/

## Important Notes

- Framework is designed to be portable across any project type
- Uses PowerShell for cross-platform compatibility on Windows
- Requires restart of Claude Code after installation to load new commands
- Template files should maintain the `.tmpl` extension
- All paths use Windows path separators in PowerShell scripts
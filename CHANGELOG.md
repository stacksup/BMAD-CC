# Changelog

All notable changes to BMAD-CC (Business Model Accelerated Development for Claude Code) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2024-12-19

### Added

#### Task Master AI Integration (REQUIRED)
- Made Task Master AI an absolute requirement for all workflows
- Implemented automatic Task Master initialization for new projects
- Added automatic PRD parsing into tasks during project setup
- Integrated task tracking throughout all development cycles
- Added task status updates at every workflow phase
- Created `/bmad:init-taskmaster` command for Task Master setup
- Added `taskmaster-check.ps1` hook to enforce Task Master availability

#### GitHub Auto-Backup System
- Implemented forced GitHub backup after task completion
- Added dynamic GitHub user detection (not hardcoded)
- Created `github-backup.ps1` hook for automatic pushing
- Added `/bmad:github-setup` command for repository configuration
- Integrated GitHub CLI (gh) for pull request creation
- Added commit linking to Task Master tasks

#### Docker Container Integration (REQUIRED)
- Made Docker a requirement for all development workflows
- Created comprehensive Docker management system
- Added `docker-manager.ps1` hook for container lifecycle
- Created `/bmad:docker` command for container operations
- Added automatic container startup in workflows
- Implemented health checks before operations
- Created Docker compose templates for different project types:
  - `docker-compose.saas.yml.tmpl` - Full stack with PostgreSQL, Redis
  - `docker-compose.phaser.yml.tmpl` - Game development setup
  - `docker-compose.generic.yml.tmpl` - Generic project setup
- Added Dockerfile templates for frontend and backend
- Integrated Docker MCP commands support
- Updated all agents to use Docker-first development

#### Comprehensive Documentation System
- Enhanced Documentation Agent (doc-agent) with full capabilities
- Created `documentation-updater.ps1` hook for automatic updates
- Added automatic CHANGELOG.md updates on task completion
- Implemented story documentation in `docs/story-notes/`
- Added smart documentation detection based on file changes
- Created `/bmad:generate-changelog` command
- Integrated documentation updates in all workflows
- Added documentation health checks
- Implemented Keep a Changelog format compliance

#### Agent Color System
- Added automatic color assignment to all agents
- Each agent has a unique color for visual distinction
- No manual configuration required in Claude Code
- Colors embedded in agent templates

#### Validation System with BMAD Checklists
- Implemented 5 comprehensive validation checklists:
  - Architecture validation (10 sections, min score 8/10)
  - PRD validation (8 sections, min score 8/10)
  - Project setup validation (6 sections, min score 7/10)
  - Story draft validation (8 sections, min score 7/10)
  - Story completion validation (8 sections, min score 9/10)
- Created `validation-enforcer.ps1` hook
- Added validation gates at workflow transitions
- Integrated validation capabilities into agents
- Added validation reporting in `docs/validation/`

### Changed

#### Enhanced Agents
- **All Agents**: Added Docker-first development approach
- **All Agents**: Added Task Master integration requirements
- **All Agents**: Added color assignments for visual distinction
- **dev-agent**: Enhanced with Docker commands and container-based testing
- **qa-agent**: Updated with Docker-based testing strategies
- **doc-agent**: Complete rewrite as comprehensive Documentation Manager
- **architect-agent**: Added Docker architecture planning
- **po-agent**: Added validation capabilities for multiple checklists

#### Updated Workflows
- **smart-cycle**: Added Task Master and Docker environment checks
- **story-cycle**: Complete Docker-centric rewrite with documentation phase
- **planning-cycle**: Added infrastructure readiness checks
- **greenfield-fullstack**: Added Docker environment setup phase
- **maintenance-cycle**: Added documentation requirements
- **All workflows**: Integrated automatic documentation updates

#### Enhanced Hooks
- **on-posttooluse.ps1**: Added documentation reminders and health checks
- **gate-enforcer.ps1**: Enhanced with validation requirements
- Updated all hooks to support Docker and Task Master

### Fixed
- Task Master initialization for new projects
- GitHub user detection to work with any authenticated user
- Documentation updates to be automatic rather than manual
- Workflow continuity with proper task tracking

### Security
- Added GitHub token validation
- Implemented secure Docker container management
- Added validation gates to prevent incomplete work

## [2.0.0] - 2024-12-18

### Added
- Initial BMAD-CC framework implementation
- Strategic planning workflows
- Development execution workflows
- Agent system with specialized roles
- Template-based documentation
- Claude Code integration with slash commands
- Hook system for automation
- Token replacement system for customization

### Changed
- Transformed original BMAD concept for Claude Code
- Adapted workflows for AI-assisted development

## [1.0.0] - 2024-12-01

### Added
- Original BMAD framework concept
- Basic agent definitions
- Initial workflow structures

---

*BMAD-CC represents a paradigm shift in AI-assisted software development, combining strategic intelligence with tactical excellence.*
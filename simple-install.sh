#!/usr/bin/env bash
# Simple installation script for BMAD-CC
# Minimal setup for quick starts

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${CYAN}🚀 BMAD-CC Simple Installation${NC}"

# Create essential directories
echo -e "${GRAY}Creating directory structure...${NC}"
mkdir -p .claude/{commands/bmad,agents,hooks}
mkdir -p docs/{story-notes,lessons,validation,changes}
mkdir -p scripts

# Create minimal settings.local.json
echo -e "${GRAY}Creating minimal Claude Code settings...${NC}"
cat > .claude/settings.local.json <<'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(node:*)",
      "Bash(npm:*)",
      "Bash(docker:*)",
      "Bash(docker-compose:*)",
      "Bash(task-master:*)",
      "Bash(npx task-master:*)",
      "Bash(python:*)",
      "Bash(pytest:*)",
      "Bash(jest:*)"
    ],
    "deny": []
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'BMAD-CC: Use full installation for complete hooks'"
          }
        ]
      }
    ]
  }
}
EOF

# Create minimal CLAUDE.md if it doesn't exist
if [ ! -f "CLAUDE.md" ]; then
    echo -e "${GRAY}Creating minimal CLAUDE.md...${NC}"
    cat > CLAUDE.md <<'EOF'
# Project Documentation

## Quick Start
This project uses BMAD-CC framework for development.

### Commands
- Run `/bmad:smart-cycle` to start development
- Run `/bmad:init-taskmaster` to set up task management

### Documentation Policy
- Update CHANGELOG.md for significant changes
- Create story notes in docs/story-notes/
- Document lessons in docs/lessons/
EOF
fi

# Create basic README if it doesn't exist
if [ ! -f "README.md" ]; then
    echo -e "${GRAY}Creating basic README.md...${NC}"
    local project_name=$(basename "$(pwd)")
    cat > README.md <<EOF
# $project_name

## Getting Started

This project uses the BMAD-CC framework for enhanced development workflow.

### Development Setup

1. Install dependencies (if applicable)
2. Run \`/bmad:init-taskmaster\` to initialize task management
3. Use \`/bmad:smart-cycle\` to start development

### Project Structure

- \`.claude/\` - Claude Code configuration and commands
- \`docs/\` - Project documentation
  - \`story-notes/\` - Development story documentation
  - \`lessons/\` - Lessons learned
  - \`validation/\` - Quality validation reports

## Development Workflow

This project follows the BMAD (Best Methodology for Agile Development) workflow:

1. **Planning** - Define requirements and architecture
2. **Development** - Implement features with validation
3. **Quality Assurance** - Test and review
4. **Documentation** - Update docs and capture lessons

## Commands

- \`/bmad:smart-cycle\` - Intelligent workflow orchestration
- \`/bmad:init-taskmaster\` - Initialize task management
- \`/bmad:planning-cycle\` - Strategic planning workflow
- \`/bmad:story-cycle\` - Feature development workflow

## Support

For BMAD-CC framework documentation, visit the [official repository](https://github.com/stacksup/BMAD-CC).
EOF
fi

# Create minimal CHANGELOG if it doesn't exist
if [ ! -f "CHANGELOG.md" ]; then
    echo -e "${GRAY}Creating CHANGELOG.md...${NC}"
    cat > CHANGELOG.md <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial BMAD-CC framework setup
- Basic project structure
- Development workflow configuration

### Changed

### Fixed

### Removed
EOF
fi

echo -e "${GREEN}✅ BMAD-CC simple installation complete!${NC}"
echo -e "${CYAN}💡 Restart Claude Code to load the framework.${NC}"

echo -e "\n${YELLOW}📋 Next Steps:${NC}"
echo -e "${GRAY}1. Restart Claude Code${NC}"
echo -e "${GRAY}2. Run: /bmad:init-taskmaster${NC}"
echo -e "${GRAY}3. For full features, run the complete installation${NC}"
echo -e "${GRAY}4. Start development: /bmad:smart-cycle${NC}"

echo -e "\n${CYAN}📝 Note: This is a minimal installation.${NC}"
echo -e "${GRAY}For complete hooks, agents, and templates, use the full bootstrap installation.${NC}"
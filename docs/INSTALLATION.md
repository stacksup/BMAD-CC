# BMAD-CC Installation Guide

## Prerequisites

### Required Software
- **Claude Code**: Anthropic's official IDE with AI agent support
- **Docker Desktop**: Container runtime for development environment
- **Node.js**: v16+ for Task Master AI
- **Git**: Version control system
- **Bash**: Shell for installation scripts (WSL on Windows)

### System Requirements
- **OS**: Windows 10/11, macOS 10.15+, Linux (Ubuntu 20.04+)
- **RAM**: Minimum 8GB, recommended 16GB
- **Storage**: 10GB free space for containers and dependencies
- **Network**: Internet connection for package downloads

## Quick Installation

### One-Line Remote Installation

```bash
# WSL/Linux/macOS
curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/bmad-cc/main/bootstrap.sh | bash -s -- --project-dir . --project-type auto

# Or using wget
wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/bmad-cc/main/bootstrap.sh | bash -s -- --project-dir . --project-type auto
```

### Manual Installation

1. **Clone the Framework**
```bash
git clone https://github.com/YOUR-USERNAME/bmad-cc.git bmad-framework
cd bmad-framework
```

2. **Run Setup Script**
```bash
# WSL/Linux/macOS
./scripts/setup.sh --project-dir "/path/to/your/project" --project-type auto

# With custom parameters
./scripts/setup.sh \
  --project-dir "/projects/my-app" \
  --project-type "saas" \
  --project-name "MyApp" \
  --frontend-dir "client" \
  --backend-dir "server" \
  --frontend-port 3000 \
  --backend-port 8080
```

## Project Type Detection

The installer automatically detects your project type:

| Detection Criteria | Project Type | Description |
|-------------------|--------------|-------------|
| Has `frontend/package.json` AND `backend/` | `saas` | Full-stack SaaS application |
| Has `src/client` OR root `package.json` | `phaser` | Phaser game development |
| Has `ios/` OR `android/` | `mobile` | Mobile application |
| None of the above | `other` | Generic project |

## Installation Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ProjectDir` | Target project directory | Current directory |
| `ProjectType` | Project type (auto/saas/phaser/mobile/other) | `auto` |
| `ProjectName` | Project name for templates | Directory name |
| `PRDPath` | Path to existing PRD | Auto-detected |
| `FrontendDir` | Frontend directory name | `frontend` |
| `BackendDir` | Backend directory name | `backend` |
| `FrontendPort` | Frontend dev server port | `3000` |
| `BackendPort` | Backend API port | `8001` |
| `DockerComposeFile` | Docker compose file | Auto-detected |
| `TaskmasterCLI` | Task Master command | `task-master` |

## Post-Installation Setup

### 1. Install Task Master AI (Required)

```bash
# Global installation (recommended)
npm install -g task-master-ai

# Or local installation
npm install task-master-ai

# Initialize Task Master
task-master init -y
task-master models --set-main opus
task-master models --set-fallback sonnet
```

### 2. Configure Docker

```bash
# Start Docker Desktop
# Windows: Start from Start Menu
# macOS: open -a Docker
# Linux: sudo systemctl start docker

# Verify Docker
docker --version
docker-compose --version

# Test containers
docker run hello-world
```

### 3. Setup GitHub Integration (Optional but Recommended)

```bash
# In Claude Code
/bmad:github-setup

# Or manually
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
git branch -M main
git push -u origin main
```

### 4. Configure Technical Preferences

Edit `docs/data/technical-preferences.md` with your stack:
- Programming languages and versions
- Frameworks and libraries
- Infrastructure preferences
- Testing strategies
- Code style preferences

## Directory Structure Created

```
your-project/
├── .claude/
│   ├── agents/              # 12 specialized AI agents
│   ├── commands/bmad/       # 10+ workflow commands
│   ├── hooks/              # 7 automation hooks
│   └── settings.local.json # Claude Code configuration
├── docs/
│   ├── data/               # Elicitation methods, preferences
│   ├── lessons/            # Extracted learnings
│   ├── story-notes/        # Implementation notes
│   ├── templates/          # 15+ document templates
│   ├── validation/         # Validation reports
│   ├── expansion-packs.md  # Extension guide
│   └── no-fallback-policy.md # Critical coding policy
├── .taskmaster/            # Task Master workspace
├── docker-compose.yml      # Container configuration
└── CHANGELOG.md           # Version history
```

## Verification

### Check Installation

```bash
# Verify directory structure
ls -la .claude/
ls -la docs/

# Check Task Master
task-master --version
task-master list

# Test Docker
docker-compose ps

# Test in Claude Code
/bmad:smart-cycle
```

### Common Installation Issues

| Issue | Solution |
|-------|----------|
| Permission denied | Make scripts executable: `chmod +x *.sh scripts/*.sh .claude/hooks/*.sh` |
| Task Master not found | Install globally: `npm install -g task-master-ai` |
| Docker not running | Start Docker Desktop manually |
| Permission denied | Windows: Run as Administrator<br>Unix: Use `sudo` |
| Port already in use | Change ports in setup parameters |

## Updating BMAD-CC

### Update Framework
```bash
cd bmad-framework
git pull origin main
./scripts/setup.sh --project-dir "/path/to/project" --project-type auto
```

### Update Dependencies
```bash
npm update task-master-ai
docker-compose pull
```

## Uninstallation

### Remove BMAD-CC
```bash
# Remove directories
rm -rf .claude
rm -rf docs/templates
rm -rf docs/data

# Remove Task Master (if desired)
npm uninstall -g task-master-ai
rm -rf .taskmaster
```

## Next Steps

1. **Read the Documentation Map**: [docs/DOCUMENTATION-MAP.md](DOCUMENTATION-MAP.md)
2. **Understand Agents**: [docs/AGENTS-GUIDE.md](AGENTS-GUIDE.md)
3. **Learn Workflows**: [docs/WORKFLOWS-GUIDE.md](WORKFLOWS-GUIDE.md)
4. **Start Development**: Run `/bmad:smart-cycle` in Claude Code

## Getting Help

- **Documentation**: [docs/DOCUMENTATION-MAP.md](DOCUMENTATION-MAP.md)
- **Troubleshooting**: [docs/TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Issues**: [GitHub Issues](https://github.com/YOUR-USERNAME/bmad-cc/issues)
- **Community**: [Discord Server](https://discord.gg/bmad-cc)

---

*Installation typically takes 5-10 minutes. For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).*
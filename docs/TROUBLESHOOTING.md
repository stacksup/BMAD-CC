# BMAD-CC Troubleshooting Guide

## Quick Fixes

### Most Common Issues

| Symptom | Solution |
|---------|----------|
| `/bmad:smart-cycle` not found | Restart Claude Code after installation |
| Task Master errors | Run `npm install -g task-master-ai` |
| Docker not running | Start Docker Desktop manually |
| Permission denied | Windows: Run as Admin, Unix: Use sudo |
| Agents not loading | Check `.claude/agents/` directory exists |

---

## Installation Issues

### Script Execution Permissions

**Error**: `Permission denied` when running scripts

**Solution**:
```bash
# Make all scripts executable
chmod +x *.sh
chmod +x scripts/*.sh
chmod +x .claude/hooks/*.sh

# For WSL users, ensure proper line endings
dos2unix *.sh scripts/*.sh .claude/hooks/*.sh
```

### Task Master Not Found

**Error**: `command not found: task-master`

**Solutions**:
```bash
# Install globally (recommended)
npm install -g task-master-ai

# Or install locally
npm install task-master-ai
npx task-master init

# Verify installation
task-master --version
```

### Docker Issues

**Error**: `Cannot connect to Docker daemon`

**Solutions**:
```bash
# Windows
# Start Docker Desktop from Start Menu

# macOS
open -a Docker

# Linux
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in
```

### Port Conflicts

**Error**: `Port 3000 is already in use`

**Solutions**:
```bash
# Find process using port
# Windows
netstat -ano | findstr :3000

# Unix
lsof -i :3000

# Kill process or change port in setup
./scripts/setup.sh --frontend-port 3001 --backend-port 8002
```

---

## Claude Code Issues

### Slash Commands Not Working

**Error**: Command `/bmad:smart-cycle` not recognized

**Solutions**:
1. Restart Claude Code completely
2. Verify installation:
```bash
ls .claude/commands/bmad/
# Should show: smart-cycle.md, story-cycle.md, etc.
```
3. Check settings:
```bash
cat .claude/settings.local.json
# Should have proper configuration
```

### Agent Loading Failures

**Error**: Agent not found or fails to load

**Solutions**:
1. Verify agent files exist:
```bash
ls .claude/agents/
# Should show all 12 agent files
```
2. Check agent syntax:
```bash
# Agent files should start with ---
head -5 .claude/agents/dev-agent.md
```
3. Clear Claude Code cache and restart

### Hook Execution Errors

**Error**: Hooks not running or failing

**Solutions**:
1. Check hook permissions:
```bash
# Check permissions
ls -la .claude/hooks/*.sh
```
2. Test hook manually:
```bash
# Test hook execution
./.claude/hooks/gate-enforcer.sh
```
3. Check bash version:
```bash
bash --version
# Need bash 4.0+ for full compatibility
```

---

## Task Master Issues

### Initialization Failed

**Error**: `Task Master not initialized`

**Solution**:
```bash
# Initialize Task Master
task-master init -y

# Configure models
task-master models --set-main opus
task-master models --set-fallback sonnet

# Verify
task-master list
```

### No Tasks Available

**Error**: `No tasks found`

**Solutions**:
1. Parse PRD if exists:
```bash
task-master parse-prd --input=docs/prd.md --force
```
2. Create initial task:
```bash
task-master create --title="Initial Setup" --description="Setup project"
```
3. Check task visibility:
```bash
task-master list --all
```

### Task Status Not Updating

**Error**: Tasks stuck in wrong status

**Solution**:
```bash
# Force status update
task-master set-status --id=123 --status=done --force

# Clear cache
rm -rf .taskmaster/cache/*

# Rebuild task index
task-master rebuild-index
```

---

## Docker Issues

### Containers Not Starting

**Error**: `docker-compose up` fails

**Solutions**:
1. Check Docker daemon:
```bash
docker version
docker-compose version
```
2. Clean Docker system:
```bash
docker system prune -a
docker volume prune
```
3. Rebuild containers:
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Health Check Failures

**Error**: Containers unhealthy

**Solutions**:
1. Check logs:
```bash
docker-compose logs backend
docker-compose logs frontend
```
2. Verify ports:
```bash
docker-compose ps
netstat -an | grep LISTEN
```
3. Restart services:
```bash
docker-compose restart
```

### Permission Issues in Containers

**Error**: Permission denied in container

**Solutions**:
```bash
# Fix ownership
docker-compose exec backend chown -R node:node /app

# Run as root temporarily
docker-compose exec -u root backend bash
```

---

## Workflow Issues

### Smart Cycle Not Routing Correctly

**Error**: Wrong workflow selected

**Solutions**:
1. Be more specific in request
2. Use explicit keywords:
   - "bug fix" → Maintenance
   - "new feature" → Story Cycle
   - "need planning" → Planning Cycle
3. Override routing:
```bash
# Use specific workflow directly
/bmad:story-cycle
/bmad:planning-cycle
```

### Quality Gates Failing

**Error**: Validation score too low

**Solutions**:
1. Review checklist details:
```bash
cat docs/validation/latest-validation.md
```
2. Address specific issues:
   - Add missing sections
   - Clarify requirements
   - Complete documentation
3. Re-run validation:
```bash
# In agent
validate-prd
validate-architecture
```

### Workflow Stuck

**Error**: Workflow not progressing

**Solutions**:
1. Check current phase:
```bash
task-master show current
```
2. Clear blockers:
```bash
task-master set-status --id=123 --status=in-progress
```
3. Skip optional phases (with caution):
```bash
# Set environment variable
$env:BMAD_SKIP_VALIDATION = "1"
```

---

## No-Fallback Policy Violations

### Dummy Data Detected

**Error**: `Quality gate failed: dummy data found`

**Solutions**:
1. Find violations:
```bash
./.claude/hooks/quality-gate-no-dummies.sh
```
2. Common fixes:
```javascript
// Replace
return mockData; // ❌
// With
throw new Error('Data unavailable'); // ✅

// Replace
catch { return []; } // ❌
// With
catch (e) { logger.error(e); throw e; } // ✅
```
3. Temporarily disable (emergency only):
```bash
export BMAD_DISABLE_GATES="1"
```

---

## Performance Issues

### Slow Installation

**Solutions**:
1. Use local cache:
```bash
npm config set cache C:\npm-cache
```
2. Parallel installation:
```bash
npm install --parallel
```
3. Skip optional dependencies:
```bash
npm install --no-optional
```

### Large Context Window Usage

**Solutions**:
1. Shard large documents:
```bash
/bmad:shard-document docs/prd.md
```
2. Clear context between agents
3. Use focused agents instead of orchestrator
4. Remove unnecessary files from context

### Docker Performance

**Solutions**:
1. Allocate more resources:
   - Docker Desktop → Settings → Resources
   - Increase CPU and Memory
2. Use volumes efficiently:
```yaml
volumes:
  - .:/app:cached  # macOS
  - .:/app:delegated  # Better performance
```
3. Reduce logging:
```yaml
logging:
  driver: "none"
```

---

## Git/GitHub Issues

### Auto-Backup Not Working

**Error**: Changes not pushed to GitHub

**Solutions**:
1. Configure remote:
```bash
git remote add origin https://github.com/USER/REPO.git
```
2. Set credentials:
```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
3. Test manually:
```bash
./.claude/hooks/github-backup.sh
```

### Commit Linking Failed

**Error**: Commits not linked to tasks

**Solution**:
```bash
# Use correct format
git commit -m "feat: implement feature [task: 123]"

# Update task manually
task-master update-task --id=123 --prompt="commit: abc123"
```

---

## Environment-Specific Issues

### Windows-Specific

**Path Issues**:
```bash
# Use proper separators for WSL
path="$HOME/projects/my-app"

# Or Windows paths in WSL
path="/mnt/c/Users/$USER/projects/my-app"
```

**Line Endings**:
```bash
# Configure Git
git config --global core.autocrlf true
```

### macOS-Specific

**Permissions**:
```bash
# Fix permissions
chmod +x .claude/hooks/*.sh
```

**Docker Desktop**:
- Enable virtualization in Docker settings
- Allocate sufficient resources

### Linux-Specific

**Docker Permissions**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

**Bash Compatibility**:
```bash
# Check bash version
bash --version

# Update if needed (should be 4.0+)
sudo apt-get update && sudo apt-get install bash
```

---

## Recovery Procedures

### Complete Reset

```bash
# Backup current state
cp -r .claude .claude.backup
cp -r .taskmaster .taskmaster.backup

# Remove and reinstall
rm -rf .claude .taskmaster
./scripts/setup.sh --project-dir . --project-type auto

# Restore customizations
cp .claude.backup/settings.local.json .claude/
```

### Partial Recovery

```bash
# Fix specific component
./scripts/setup.sh --component-only agents
./scripts/setup.sh --component-only hooks
./scripts/setup.sh --component-only commands
```

### Emergency Bypass

```bash
# Disable all gates (temporary!)
export BMAD_DISABLE_GATES="1"
export BMAD_SKIP_VALIDATION="1"
export BMAD_NO_DOCKER="1"

# Remember to re-enable!
unset BMAD_DISABLE_GATES
unset BMAD_SKIP_VALIDATION
unset BMAD_NO_DOCKER
```

---

## Getting Help

### Diagnostic Information

Collect this for support:
```bash
# System info
bash --version
docker version
npm version
task-master --version

# Installation check
ls -la .claude/
ls -la .taskmaster/
cat .claude/settings.local.json

# Recent errors
docker-compose logs --tail=50
cat .taskmaster/logs/latest.log
```

### Support Channels

1. **Documentation**: [docs/DOCUMENTATION-MAP.md](DOCUMENTATION-MAP.md)
2. **GitHub Issues**: Include diagnostic info
3. **Discord**: Real-time help
4. **Stack Overflow**: Tag with `bmad-cc`

### Debug Mode

Enable verbose logging:
```bash
export BMAD_DEBUG="1"
export TASK_MASTER_DEBUG="1"
```

---

*Can't find your issue? Check [GitHub Issues](https://github.com/YOUR-USERNAME/bmad-cc/issues) or ask on [Discord](https://discord.gg/bmad-cc).*
# BMAD-CC Installation Guide

## Quick Installation (Recommended)

For immediate installation in your project directory:

```bash
# Option 1: Simple one-liner (primary method)
git clone --depth 1 https://github.com/stacksup/BMAD-CC.git temp-bmad && cd temp-bmad && bash simple-install.sh .. && cd .. && rm -rf temp-bmad

# Option 2: Bootstrap script (if you prefer)
curl -sSL https://raw.githubusercontent.com/stacksup/BMAD-CC/main/bootstrap.sh | bash -s -- . auto
```

## Manual Installation Steps

If the automated scripts fail, you can install manually:

### 1. Download Framework
```bash
git clone --depth 1 https://github.com/stacksup/BMAD-CC.git bmad-temp
```

### 2. Copy Core Files
```bash
# Create directories
mkdir -p .claude/agents
mkdir -p .claude/commands/bmad
mkdir -p .claude/hooks
mkdir -p docs/lessons/templates
mkdir -p docs/story-notes

# Copy agents
cp bmad-temp/templates/.claude/agents/*.md .claude/agents/
cp bmad-temp/templates/.claude/commands/bmad/*.md .claude/commands/bmad/
cp bmad-temp/templates/.claude/hooks/*.sh .claude/hooks/
cp bmad-temp/templates/.claude/settings.local.json .claude/

# Copy lesson templates
cp bmad-temp/templates/docs/lessons/templates/*.tmpl docs/lessons/templates/

# Copy CLAUDE.md if you don't have one
if [ ! -f CLAUDE.md ]; then
    cp bmad-temp/templates/CLAUDE.md.tmpl CLAUDE.md
fi
```

### 3. Customize for Your Project
```bash
# Replace tokens in copied files
project_name=$(basename "$(pwd)")
find . -type f -name "*.md" -o -name "*.json" -o -name "*.sh" | xargs sed -i "s/{{PROJECT_NAME}}/$project_name/g"
find . -type f -name "*.md" -o -name "*.json" -o -name "*.sh" | xargs sed -i "s/{{PROJECT_TYPE}}/auto/g"
```

### 4. Clean Up
```bash
rm -rf bmad-temp
```

## Verification

After installation, verify these files exist:
- `.claude/agents/` (11 agent files)
- `.claude/commands/bmad/` (cycle commands)
- `.claude/settings.local.json`
- `docs/lessons/templates/`
- `CLAUDE.md` (if not existing)

## Restart Claude Code

After installation, restart Claude Code to load the new slash commands:
- `/bmad:smart-cycle`
- `/bmad:story-cycle`
- `/bmad:saas-cycle`
- `/bmad:planning-cycle`

## Troubleshooting

### Parameter Passing Issues
If you see argument parsing errors:
```bash
# Use the manual installation method with explicit parameters
git clone --depth 1 https://github.com/stacksup/BMAD-CC.git temp-bmad
cd temp-bmad
bash scripts/setup.sh --project-dir=".." --project-type="saas" --project-name="MyProject" --prd-path="CLAUDE.md"
cd .. && rm -rf temp-bmad
```

### Agent Recognition Issues
If agents don't appear in Claude Code:
1. Check for BOM characters: `head -1 .claude/agents/dev-agent.md | od -c`
2. Should show `--- \n`, not `357 273 277 --- \n` 
3. Reinstall if BOM characters are present

### General Issues
**Permission Errors:**
```bash
# Ensure you have write permissions in the project directory
chmod +w .
sudo chown -R $USER:$USER .
```

**Git Clone Failures:**
Download the ZIP from GitHub instead and extract it manually.

**Script Execution Errors:**
```bash
# Make scripts executable
chmod +x scripts/setup.sh
chmod +x .claude/hooks/*.sh
```

**Empty .claude/agents/ Directory:**
The bootstrap script may have parameter issues. Use the manual installation method instead.

**WSL/Linux Compatibility:**
This framework is now fully compatible with WSL, Linux, and macOS. No PowerShell dependencies remain.
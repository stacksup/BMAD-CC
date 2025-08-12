# BMAD-CC Installation Guide

## Quick Installation (Recommended)

For immediate installation in your project directory:

```powershell
# Option 1: One-liner (if bootstrap works)
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/stacksup/BMAD-CC/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"

# Option 2: Manual download if remote fails
git clone --depth 1 https://github.com/stacksup/BMAD-CC.git bmad-temp
powershell -ExecutionPolicy Bypass -File .\bmad-temp\scripts\setup.ps1 -ProjectDir . -ProjectType auto -ProjectName "YourProject"
Remove-Item -Recurse -Force bmad-temp
```

## Manual Installation Steps

If the automated scripts fail, you can install manually:

### 1. Download Framework
```powershell
git clone --depth 1 https://github.com/stacksup/BMAD-CC.git bmad-temp
```

### 2. Copy Core Files
```powershell
# Create directories
New-Item -ItemType Directory -Force -Path .claude\agents
New-Item -ItemType Directory -Force -Path .claude\commands\bmad
New-Item -ItemType Directory -Force -Path .claude\hooks
New-Item -ItemType Directory -Force -Path docs\lessons\templates
New-Item -ItemType Directory -Force -Path docs\story-notes

# Copy agents
Copy-Item bmad-temp\templates\.claude\agents\*.md .claude\agents\
Copy-Item bmad-temp\templates\.claude\commands\bmad\*.md .claude\commands\bmad\
Copy-Item bmad-temp\templates\.claude\hooks\*.ps1 .claude\hooks\
Copy-Item bmad-temp\templates\.claude\settings.local.json .claude\

# Copy lesson templates
Copy-Item bmad-temp\templates\docs\lessons\templates\*.tmpl docs\lessons\templates\

# Copy CLAUDE.md if you don't have one
if (!(Test-Path CLAUDE.md)) { Copy-Item bmad-temp\templates\CLAUDE.md.tmpl CLAUDE.md }
```

### 3. Customize for Your Project
```powershell
# Replace tokens in copied files
$projectName = Split-Path (Get-Location) -Leaf
Get-ChildItem -Recurse -File | ForEach-Object {
    (Get-Content $_.FullName) -replace '{{PROJECT_NAME}}', $projectName | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace '{{PROJECT_TYPE}}', 'auto' | Set-Content $_.FullName
}
```

### 4. Clean Up
```powershell
Remove-Item -Recurse -Force bmad-temp
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

**PowerShell Execution Policy Errors:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Git Clone Failures:**
Download the ZIP from GitHub instead and extract it manually.

**Permission Errors:**
Run PowerShell as Administrator or use `-Force` flag on file operations.
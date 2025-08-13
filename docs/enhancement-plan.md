# BMAD-CC Framework Enhancement Plan

## Overview
Two critical enhancements to modernize BMAD-CC framework for better cross-platform compatibility and correct project type identification.

## Enhancement 1: PowerShell to Bash Conversion

### Objective
Convert all PowerShell scripts to Bash for WSL/Linux compatibility while maintaining Windows support.

### Scope
- **23 PowerShell files** in active project
- **9 PowerShell templates** for future projects
- **All functionality preserved** with improved cross-platform support

### Implementation Strategy

#### Phase 1: Hook Scripts (Priority: High)
Convert .claude/hooks/ scripts that are critical for workflow automation:
1. `taskmaster-check.ps1` → `taskmaster-check.sh`
2. `docker-manager.ps1` → `docker-manager.sh`
3. `gate-enforcer.ps1` → `gate-enforcer.sh`
4. `validation-enforcer.ps1` → `validation-enforcer.sh`
5. `github-backup.ps1` → `github-backup.sh`
6. `documentation-updater.ps1` → `documentation-updater.sh`
7. `on-posttooluse.ps1` → `on-posttooluse.sh`
8. `change-detector.ps1` → `change-detector.sh`
9. `quality-gate-no-dummies.ps1` → `quality-gate-no-dummies.sh`
10. `lesson-extraction-gate.ps1` → `lesson-extraction-gate.sh`

#### Phase 2: Installation Scripts
Convert root and scripts/ directory installers:
1. `bootstrap.ps1` → `bootstrap.sh`
2. `install-self.ps1` → `install-self.sh`
3. `simple-install.ps1` → `simple-install.sh`
4. `apply-enhancements.ps1` → `apply-enhancements.sh`
5. `scripts/setup.ps1` → `scripts/setup.sh`
6. Update remaining scripts/ utilities

#### Phase 3: Templates
Update templates/.claude/ for future projects:
- Convert all .ps1.tmpl to .sh.tmpl
- Update template variable substitution
- Ensure cross-platform compatibility

### Conversion Guidelines

#### PowerShell → Bash Mapping
```bash
# Variables
$var = "value"          →  var="value"
$env:VAR                →  $VAR or ${VAR}

# Conditionals  
if ($condition) {}      →  if [ condition ]; then fi
Test-Path               →  [ -f file ] or [ -d dir ]

# Functions
function Name {}        →  Name() {}
param()                 →  Handle with positional parameters or getopts

# Commands
Write-Host              →  echo
Write-Error             →  echo >&2
Get-Content             →  cat
Select-String           →  grep
ForEach-Object          →  for loop or xargs

# Error Handling
$ErrorActionPreference  →  set -e
$LASTEXITCODE          →  $?
try/catch              →  trap or || error handling
```

### Testing Requirements
1. Syntax validation with `shellcheck`
2. WSL environment testing
3. Cross-platform compatibility verification
4. Error handling validation
5. Template substitution testing

## Enhancement 2: Fix "Phaser" Project Type References

### Objective
Remove incorrect game development references and fix project type detection logic.

### Root Cause
`bootstrap.ps1` line 30 incorrectly identifies any project with `package.json` as a game project:
```powershell
elseif ((Test-Path "$ProjectDir/src/client") -or (Test-Path "$ProjectDir/package.json")) { $ProjectType = "phaser" }
```

### Scope
- **51 files** containing "Phaser" references
- **10 agent files** with game-specific logic
- **Multiple command files** with incorrect context
- **Templates** with phaser conditionals

### Implementation Strategy

#### Step 1: Fix Detection Logic
Update bootstrap script to properly detect:
- BMAD-CC framework itself → "framework"
- SaaS applications → "saas"
- Game projects → "phaser" (only if explicitly game-related)
- Other projects → "other"

#### Step 2: Update Agent Files
Replace in all .claude/agents/*.md:
- "BMAD-CC (Framework)" → "BMAD-CC"
- Remove game-specific workflow sections
- Maintain template placeholders for actual game projects

#### Step 3: Update Commands
Fix .claude/commands/bmad/*.md files:
- Remove incorrect "Phaser" references
- Update project context sections
- Preserve game project support where appropriate

#### Step 4: Template Cleanup
- Review conditional blocks: `{{#if PROJECT_TYPE.phaser}}`
- Ensure framework projects get correct type
- Maintain game project support in templates

### Expected Outcomes
1. BMAD-CC correctly identified as framework/methodology
2. No confusion in agent behaviors
3. Proper workflow routing
4. Game projects still supported when appropriate

## Development Execution Plan

### Task 11: PowerShell → Bash (First Priority)
1. Start with critical hooks (taskmaster-check, docker-manager)
2. Test each conversion in WSL environment
3. Maintain parallel versions during transition
4. Update documentation and references
5. Complete template conversions

### Task 12: Phaser Fixes (Second Priority)
1. Fix bootstrap detection logic
2. Bulk update agent descriptions
3. Update command files
4. Clean template conditionals
5. Test with various project types

## Rollback Plan
- Keep all .ps1 files until .sh versions proven stable
- Version control allows instant rollback
- Test in isolated environment first
- Gradual rollout with monitoring

## Success Metrics
- ✅ All scripts work in WSL/Linux
- ✅ No "Phaser" references in BMAD-CC context
- ✅ Framework correctly identified
- ✅ Cross-platform compatibility achieved
- ✅ No functionality regression

## Risk Mitigation
- Extensive testing before removing PowerShell versions
- Maintain backward compatibility
- Document all changes thoroughly
- Provide migration guide for existing users
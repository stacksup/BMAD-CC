# CHANGELOG

## 2025-08-16 - Maintenance Workflow Enhancement

### ✅ Maintenance Cycle Workflow Critical Fix
- **COMPLETED**: Fixed workflow definition gaps that prevented automated execution
- **ROOT CAUSE**: Workflow had descriptive text instead of prescriptive Task tool invocations
- **FIXES IMPLEMENTED**:
  - Added explicit Task tool triggers for each step (/task dev-agent, /task qa-agent, etc.)
  - Added mandatory completion validation checkpoints between steps
  - Enhanced USER APPROVAL GATE with explicit approval requirements
  - Added agent hand-off confirmation requirements
- **IMPACT**: Maintenance cycles now have enforced workflow execution rather than documentation-only guidance
- **FILES MODIFIED**: `.claude/commands/bmad/maintenance-cycle.md`, `.claude/agents/sm-agent.md`
- **TECHNICAL DEBT RESOLVED**: Framework value of "define workflows once and follow them" now properly enforced

## 2025-08-16 - Documentation Updates

### ✅ Workflow Invocation Guide Enhancement
- **COMPLETED**: Added comprehensive workflow invocation examples to WORKFLOWS-GUIDE.md
- **ENHANCEMENT**: Clear "wrong way vs right way" examples for proper BMAD workflow usage
- **SCOPE**: Added trigger word patterns, common mistakes, and Smart Cycle usage guidance
- **IMPACT**: Users now have clear guidance on how to properly invoke BMAD workflows
- **MAINTENANCE**: 30-minute documentation enhancement to improve user experience

### ✅ PowerShell Reference Cleanup in Documentation
- **COMPLETED**: Updated all documentation to reflect bash scripts
- **FILES UPDATED**: README.md, docs/INSTALLATION.md, docs/TROUBLESHOOTING.md
- **IMPACT**: Documentation now accurately reflects the bash-based infrastructure
- **SCOPE**: Removed outdated PowerShell references from installation and troubleshooting guides

## 2025-08-13 - Major Infrastructure Completion

### ✅ PowerShell to Bash Migration (Task #11)
- **COMPLETED**: Converted all 32 PowerShell scripts to bash for WSL/Linux compatibility
- **IMPACT**: Full cross-platform support, no more PowerShell execution errors
- **FILES**: All .ps1 scripts → .sh scripts in hooks/, scripts/, and root directory
- **TEMPLATES**: Converted 11 PowerShell templates to bash templates

### ✅ Project Type Detection Fix (Task #12) 
- **COMPLETED**: Fixed incorrect "Phaser" project type detection throughout codebase
- **IMPACT**: BMAD-CC now properly identified as a framework/methodology
- **SCOPE**: Updated 59+ files across agents, commands, and templates
- **ROOT CAUSE**: bootstrap.ps1 incorrectly auto-detected any package.json as game project

### ✅ Hook System Stabilization
- **COMPLETED**: All hooks now use bash scripts with proper error handling
- **IMPACT**: No more PowerShell execution policy errors in WSL/Linux
- **VALIDATION**: All 10 hook scripts tested and working properly

### ✅ Git Integration
- **COMPLETED**: All changes committed to version control
- **STATUS**: Clean working directory with all new bash scripts tracked

### Infrastructure Status
- **Task Master**: Task #12 marked as complete, Task #11 in final stages
- **Platform**: Full WSL/Linux compatibility achieved
- **Quality**: No dummy data policy maintained throughout migration
- **Documentation**: All changes properly tracked and versioned

---

## Previous Entries
- Initial BMAD framework installed for BMAD-CC (Framework)
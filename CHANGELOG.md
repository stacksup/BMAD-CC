# CHANGELOG

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
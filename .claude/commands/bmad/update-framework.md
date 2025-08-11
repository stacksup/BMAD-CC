---
description: Update BMAD Framework to latest version from GitHub
allowed-tools: Bash(powershell:*), Bash(curl:*), Read
---

# /bmad:update-framework

Updates your BMAD framework installation with the latest features while preserving local customizations.

## Simple One-Command Update

```powershell
# Check if update script exists locally
if (Test-Path "scripts\update-framework.ps1") {
    Write-Host "🔄 Running local update script..." -ForegroundColor Cyan
    .\scripts\update-framework.ps1
} else {
    Write-Host "🔄 Downloading and running update from GitHub..." -ForegroundColor Cyan
    
    # Download and run update script directly from GitHub
    try {
        $updateScript = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/scripts/update-framework.ps1"
        
        # Execute the update script
        Invoke-Expression $updateScript
        
    } catch {
        Write-Host "❌ Failed to download update script: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Try updating manually or check your internet connection." -ForegroundColor Yellow
    }
}
```

## What This Command Does

1. **🔍 Checks GitHub** for the latest BMAD framework version
2. **💾 Backs up** your customizations (lessons, story notes, settings)
3. **📦 Downloads** only the updated framework files
4. **🔄 Applies** updates while preserving your content
5. **✅ Validates** everything works correctly

## Safe Update Process

- **Preserves**: Your lessons, story notes, project settings
- **Updates**: Agent capabilities, templates, new features  
- **Prompts**: Before overwriting any customized files
- **Backs up**: Everything important before making changes
- **Restores**: Your content after framework updates

## Manual Update

If automatic update fails, you can also update manually:

```powershell
# Check for updates only
.\scripts\update-framework.ps1 -CheckOnly

# Force update all files
.\scripts\update-framework.ps1 -Force
```

## Auto-Update Notifications

BMAD can notify you when updates are available. Add this to your project hooks or run occasionally:

```powershell
# Quick update check (no changes made)
if (Test-Path "scripts\update-framework.ps1") {
    .\scripts\update-framework.ps1 -CheckOnly
}
```

This keeps your BMAD framework current with the latest improvements while keeping all your project-specific customizations intact.
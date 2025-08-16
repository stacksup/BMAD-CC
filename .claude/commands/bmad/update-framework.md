---
description: Update BMAD Framework to latest version from GitHub
allowed-tools: Bash(bash:*), Bash(curl:*), Bash(git:*), Read
---

# /bmad:update-framework

Updates your BMAD framework installation with the latest features while preserving local customizations.

## Simple One-Command Update

```bash
# Check if update script exists locally
if [ -f "scripts/update-framework.sh" ]; then
    echo "🔄 Running local update script..."
    bash scripts/update-framework.sh
else
    echo "🔄 Downloading and running update from GitHub..."
    
    # Download and run update script directly from GitHub
    if curl -fsSL "https://raw.githubusercontent.com/stacksup/BMAD-CC/main/scripts/update-framework.sh" -o /tmp/update-framework.sh; then
        # Execute the update script
        bash /tmp/update-framework.sh
        rm -f /tmp/update-framework.sh
    else
        echo "❌ Failed to download update script"
        echo "💡 Try updating manually or check your internet connection."
    fi
fi
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

```bash
# Check for updates only
bash scripts/update-framework.sh --check-only

# Force update all files
bash scripts/update-framework.sh --force
```

## Auto-Update Notifications

BMAD can notify you when updates are available. Add this to your project hooks or run occasionally:

```bash
# Quick update check (no changes made)
if [ -f "scripts/update-framework.sh" ]; then
    bash scripts/update-framework.sh --check-only
fi
```

This keeps your BMAD framework current with the latest improvements while keeping all your project-specific customizations intact.
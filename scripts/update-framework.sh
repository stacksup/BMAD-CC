#!/usr/bin/env bash
# Update BMAD-CC Framework from GitHub repository
# Preserves local customizations while updating framework components

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/stacksup/BMAD-CC.git"
TEMP_DIR="/tmp/bmad-update-$$"
BACKUP_DIR=".bmad-backup-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
CHECK_ONLY=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to check for updates
check_updates() {
    echo -e "${CYAN}🔍 Checking for updates...${NC}"
    
    # Get current version
    CURRENT_VERSION=""
    if [ -f ".bmad-version" ]; then
        CURRENT_VERSION=$(cat .bmad-version)
    fi
    
    # Get latest version from GitHub
    LATEST_COMMIT=$(git ls-remote $REPO_URL HEAD | awk '{print $1}' | cut -c1-7)
    
    if [ "$CURRENT_VERSION" = "$LATEST_COMMIT" ]; then
        echo -e "${GREEN}✅ Framework is up to date (version: $CURRENT_VERSION)${NC}"
        return 1
    else
        echo -e "${YELLOW}📦 Update available!${NC}"
        echo -e "${GRAY}  Current: ${CURRENT_VERSION:-unknown}${NC}"
        echo -e "${GRAY}  Latest:  $LATEST_COMMIT${NC}"
        return 0
    fi
}

# Function to backup local customizations
backup_customizations() {
    echo -e "${CYAN}💾 Backing up local customizations...${NC}"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup directories that contain user content
    for dir in "docs/lessons" "docs/story-notes" ".taskmaster/tasks" ".taskmaster/docs"; do
        if [ -d "$dir" ]; then
            echo -e "${GRAY}  Backing up $dir...${NC}"
            cp -r "$dir" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    # Backup local configuration files
    for file in "CLAUDE.md" ".bmad-version" ".taskmaster/config.json"; do
        if [ -f "$file" ]; then
            echo -e "${GRAY}  Backing up $file...${NC}"
            cp "$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}✅ Backup created in $BACKUP_DIR${NC}"
}

# Function to download latest framework
download_framework() {
    echo -e "${CYAN}📥 Downloading latest framework...${NC}"
    
    # Clone repository to temp directory
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to download framework${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Framework downloaded${NC}"
}

# Function to update framework files
update_files() {
    echo -e "${CYAN}🔄 Updating framework files...${NC}"
    
    # Directories to update (framework components)
    FRAMEWORK_DIRS=(".claude/agents" ".claude/commands" ".claude/hooks" ".claude/playbooks" "templates" "scripts")
    
    for dir in "${FRAMEWORK_DIRS[@]}"; do
        if [ -d "$TEMP_DIR/$dir" ]; then
            echo -e "${GRAY}  Updating $dir...${NC}"
            
            # Create directory if it doesn't exist
            mkdir -p "$dir"
            
            # Copy new files, preserving structure
            if [ "$FORCE" = true ]; then
                cp -r "$TEMP_DIR/$dir"/* "$dir/" 2>/dev/null || true
            else
                # Interactive mode - prompt for overwrites
                cp -ri "$TEMP_DIR/$dir"/* "$dir/" 2>/dev/null || true
            fi
        fi
    done
    
    # Update root-level framework files (selective)
    FRAMEWORK_FILES=("README.md" "CHANGELOG.md" ".gitignore")
    
    for file in "${FRAMEWORK_FILES[@]}"; do
        if [ -f "$TEMP_DIR/$file" ]; then
            if [ "$FORCE" = true ] || [ ! -f "$file" ]; then
                echo -e "${GRAY}  Updating $file...${NC}"
                cp "$TEMP_DIR/$file" . 2>/dev/null || true
            fi
        fi
    done
    
    echo -e "${GREEN}✅ Framework files updated${NC}"
}

# Function to restore customizations
restore_customizations() {
    echo -e "${CYAN}🔄 Restoring customizations...${NC}"
    
    # Restore user content directories
    for dir in "docs/lessons" "docs/story-notes" ".taskmaster/tasks" ".taskmaster/docs"; do
        if [ -d "$BACKUP_DIR/$(basename $dir)" ]; then
            echo -e "${GRAY}  Restoring $dir...${NC}"
            cp -r "$BACKUP_DIR/$(basename $dir)"/* "$dir/" 2>/dev/null || true
        fi
    done
    
    # Restore configuration files if they don't conflict
    if [ -f "$BACKUP_DIR/CLAUDE.md" ]; then
        echo -e "${GRAY}  Preserving local CLAUDE.md...${NC}"
        # Keep local version
    fi
    
    if [ -f "$BACKUP_DIR/.taskmaster/config.json" ]; then
        echo -e "${GRAY}  Preserving local .taskmaster/config.json...${NC}"
        # Keep local version
    fi
    
    echo -e "${GREEN}✅ Customizations restored${NC}"
}

# Function to update version file
update_version() {
    LATEST_COMMIT=$(cd "$TEMP_DIR" && git rev-parse --short HEAD)
    echo "$LATEST_COMMIT" > .bmad-version
    echo -e "${GREEN}✅ Version updated to $LATEST_COMMIT${NC}"
}

# Function to clean up
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Main execution
main() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     BMAD-CC Framework Update Tool      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo
    
    # Check for updates
    if check_updates; then
        if [ "$CHECK_ONLY" = true ]; then
            echo -e "${YELLOW}Run without --check-only to install update${NC}"
            exit 0
        fi
        
        # Confirm update
        if [ "$FORCE" != true ]; then
            echo
            read -p "Do you want to update? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Update cancelled${NC}"
                exit 0
            fi
        fi
        
        # Perform update
        backup_customizations
        download_framework
        update_files
        restore_customizations
        update_version
        cleanup
        
        echo
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║      Framework Update Complete! 🎉      ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
        echo
        echo -e "${CYAN}Backup saved in: $BACKUP_DIR${NC}"
        echo -e "${YELLOW}Review changes and test your project${NC}"
    else
        exit 0
    fi
}

# Set up trap to clean up on exit
trap cleanup EXIT

# Run main function
main
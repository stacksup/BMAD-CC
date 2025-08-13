#!/usr/bin/env bash
# Update BMAD-CC framework to latest version

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
BACKUP_DIR="bmad-backup-$(date +%Y%m%d-%H%M%S)"

echo -e "${CYAN}🔄 BMAD-CC Framework Update${NC}"

# Function to backup current installation
backup_current() {
    echo -e "${GRAY}Creating backup of current installation...${NC}"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup key directories and files
    local items_to_backup=(
        ".claude/commands/bmad"
        ".claude/agents"
        ".claude/hooks"
        "scripts"
        "CLAUDE.md"
        "CHANGELOG.md"
    )
    
    for item in "${items_to_backup[@]}"; do
        if [ -e "$item" ]; then
            cp -r "$item" "$BACKUP_DIR/"
            echo -e "${GRAY}  ✓ Backed up: $item${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ Backup created: $BACKUP_DIR${NC}"
}

# Function to fetch latest version
fetch_latest() {
    echo -e "${CYAN}📥 Fetching latest BMAD-CC version...${NC}"
    
    local temp_dir=$(mktemp -d)
    
    if ! git clone --depth 1 "$REPO_URL" "$temp_dir" &>/dev/null; then
        echo -e "${RED}❌ Failed to fetch latest version${NC}" >&2
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo "$temp_dir"
}

# Function to update framework files
update_framework() {
    local source_dir="$1"
    
    echo -e "${CYAN}🔄 Updating framework files...${NC}"
    
    # Update commands
    if [ -d "$source_dir/.claude/commands/bmad" ]; then
        mkdir -p ".claude/commands"
        cp -r "$source_dir/.claude/commands/bmad" ".claude/commands/"
        echo -e "${GRAY}  ✓ Updated BMAD commands${NC}"
    fi
    
    # Update agents
    if [ -d "$source_dir/.claude/agents" ]; then
        mkdir -p ".claude"
        cp -r "$source_dir/.claude/agents" ".claude/"
        echo -e "${GRAY}  ✓ Updated agents${NC}"
    fi
    
    # Update hooks (preserve local customizations)
    if [ -d "$source_dir/.claude/hooks" ]; then
        mkdir -p ".claude/hooks"
        
        # Copy new hooks, but don't overwrite if local versions exist
        find "$source_dir/.claude/hooks" -name "*.sh" | while read -r hook; do
            local hook_name=$(basename "$hook")
            local local_hook=".claude/hooks/$hook_name"
            
            if [ ! -f "$local_hook" ]; then
                cp "$hook" "$local_hook"
                chmod +x "$local_hook"
                echo -e "${GRAY}  ✓ Added new hook: $hook_name${NC}"
            else
                echo -e "${YELLOW}  ⚠️ Skipped existing hook: $hook_name${NC}"
            fi
        done
    fi
    
    # Update scripts
    if [ -d "$source_dir/scripts" ]; then
        mkdir -p "scripts"
        
        # Copy scripts, preserving local modifications
        find "$source_dir/scripts" -name "*.sh" | while read -r script; do
            local script_name=$(basename "$script")
            local local_script="scripts/$script_name"
            
            if [ ! -f "$local_script" ]; then
                cp "$script" "$local_script"
                chmod +x "$local_script"
                echo -e "${GRAY}  ✓ Added new script: $script_name${NC}"
            else
                # Create .new version for comparison
                cp "$script" "$local_script.new"
                echo -e "${YELLOW}  ⚠️ Script update available: $script_name (saved as $script_name.new)${NC}"
            fi
        done
    fi
    
    # Update templates (for future use)
    if [ -d "$source_dir/templates" ]; then
        cp -r "$source_dir/templates" "."
        echo -e "${GRAY}  ✓ Updated templates${NC}"
    fi
    
    echo -e "${GREEN}✅ Framework files updated${NC}"
}

# Function to update documentation
update_documentation() {
    local source_dir="$1"
    
    echo -e "${CYAN}📝 Updating documentation...${NC}"
    
    # Update docs directory (preserve local files)
    if [ -d "$source_dir/docs" ]; then
        mkdir -p docs
        
        # Copy documentation templates and guides
        find "$source_dir/docs" -name "*.md" -path "*/templates/*" | while read -r doc; do
            local relative_path="${doc#$source_dir/docs/}"
            local local_doc="docs/$relative_path"
            
            mkdir -p "$(dirname "$local_doc")"
            cp "$doc" "$local_doc"
            echo -e "${GRAY}  ✓ Updated: $relative_path${NC}"
        done
    fi
    
    echo -e "${GREEN}✅ Documentation updated${NC}"
}

# Function to show update summary
show_summary() {
    echo -e "\n${CYAN}📊 Update Summary${NC}"
    echo "============================="
    
    # Show backup location
    echo -e "${GRAY}📎 Backup created: $BACKUP_DIR${NC}"
    
    # Show new files
    echo -e "\n${YELLOW}🆕 New files to review:${NC}"
    find scripts -name "*.new" 2>/dev/null | while read -r file; do
        echo -e "${GRAY}  - $file${NC}"
    done
    
    # Show next steps
    echo -e "\n${YELLOW}📋 Next Steps:${NC}"
    echo -e "${GRAY}1. Review any .new files and merge changes${NC}"
    echo -e "${GRAY}2. Test your workflows to ensure compatibility${NC}"
    echo -e "${GRAY}3. Restart Claude Code to load updates${NC}"
    echo -e "${GRAY}4. Check release notes for breaking changes${NC}"
    
    echo "============================="
}

# Function to rollback update
rollback_update() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}❌ No backup found for rollback${NC}" >&2
        return 1
    fi
    
    echo -e "${YELLOW}↩️ Rolling back update...${NC}"
    
    # Restore from backup
    if [ -d "$BACKUP_DIR/.claude" ]; then
        rm -rf .claude
        cp -r "$BACKUP_DIR/.claude" .
        echo -e "${GRAY}  ✓ Restored .claude directory${NC}"
    fi
    
    if [ -d "$BACKUP_DIR/scripts" ]; then
        rm -rf scripts
        cp -r "$BACKUP_DIR/scripts" .
        echo -e "${GRAY}  ✓ Restored scripts directory${NC}"
    fi
    
    # Set permissions
    find .claude/hooks -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    echo -e "${GREEN}✅ Rollback completed${NC}"
}

# Main update process
main() {
    case "${1:-update}" in
        update)
            # Check if we're in a BMAD project
            if [ ! -f "CLAUDE.md" ] && [ ! -d ".claude" ]; then
                echo -e "${RED}❌ This doesn't appear to be a BMAD-CC project${NC}" >&2
                echo -e "${GRAY}Run this script from a project with BMAD-CC installed${NC}" >&2
                exit 1
            fi
            
            # Create backup
            backup_current
            
            # Fetch latest version
            local temp_dir
            if ! temp_dir=$(fetch_latest); then
                echo -e "${RED}❌ Update failed${NC}" >&2
                exit 1
            fi
            
            # Update framework
            update_framework "$temp_dir"
            
            # Update documentation
            update_documentation "$temp_dir"
            
            # Cleanup
            rm -rf "$temp_dir"
            
            # Show summary
            show_summary
            
            echo -e "\n${GREEN}✅ BMAD-CC framework updated successfully!${NC}"
            ;;
            
        rollback)
            rollback_update
            ;;
            
        --help|-h)
            echo "Usage: $0 [command]"
            echo "Commands:"
            echo "  update   - Update BMAD-CC framework (default)"
            echo "  rollback - Rollback to previous version"
            echo "  --help   - Show this help message"
            ;;
            
        *)
            echo "Unknown command: $1" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
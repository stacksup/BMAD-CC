#!/usr/bin/env bash
# Simple self-installation script for BMAD-CC

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${CYAN}🚀 Installing BMAD-CC framework on itself...${NC}"

# Project configuration
PROJECT_NAME="BMAD-CC"
PROJECT_TYPE="framework"  # Fixed from "other"
PRD_PATH=""
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
FRONTEND_PORT="3000"
BACKEND_PORT="8001"
DOCKER_COMPOSE_FILE=""
TASKMASTER_CLI="task-master"

# Function to replace tokens in content
replace_tokens() {
    local content="$1"
    
    # Replace all template tokens
    content=$(echo "$content" | sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g")
    content=$(echo "$content" | sed "s|{{PROJECT_TYPE}}|$PROJECT_TYPE|g")
    content=$(echo "$content" | sed "s|{{PRD_PATH}}|$PRD_PATH|g")
    content=$(echo "$content" | sed "s|{{SECONDARY_PRD_PATH}}||g")
    content=$(echo "$content" | sed "s|{{FRONTEND_DIR}}|$FRONTEND_DIR|g")
    content=$(echo "$content" | sed "s|{{BACKEND_DIR}}|$BACKEND_DIR|g")
    content=$(echo "$content" | sed "s|{{FRONTEND_PORT}}|$FRONTEND_PORT|g")
    content=$(echo "$content" | sed "s|{{BACKEND_PORT}}|$BACKEND_PORT|g")
    content=$(echo "$content" | sed "s|{{DOCKER_COMPOSE_FILE}}|$DOCKER_COMPOSE_FILE|g")
    content=$(echo "$content" | sed "s|{{TASKMASTER_CLI}}|$TASKMASTER_CLI|g")
    
    echo "$content"
}

# Function to copy and process template files
copy_templates() {
    local source_dir="$1"
    local dest_dir="$2"
    
    if [ ! -d "$source_dir" ]; then
        echo -e "${YELLOW}⚠️ Source directory not found: $source_dir${NC}"
        return 1
    fi
    
    echo -e "${GRAY}Processing templates from $source_dir to $dest_dir...${NC}"
    
    # Find all template files
    find "$source_dir" -name "*.tmpl" -type f | while read -r template_file; do
        # Calculate relative path and remove .tmpl extension
        local relative_path="${template_file#$source_dir/}"
        local dest_file="$dest_dir/${relative_path%.tmpl}"
        
        # Create destination directory
        mkdir -p "$(dirname "$dest_file")"
        
        # Process template
        local content=$(cat "$template_file")
        local processed_content=$(replace_tokens "$content")
        
        # Write processed content
        echo "$processed_content" > "$dest_file"
        
        echo -e "${GRAY}  ✓ $relative_path → ${dest_file#$dest_dir/}${NC}"
    done
    
    # Copy non-template files
    find "$source_dir" -type f ! -name "*.tmpl" | while read -r file; do
        local relative_path="${file#$source_dir/}"
        local dest_file="$dest_dir/$relative_path"
        
        # Create destination directory
        mkdir -p "$(dirname "$dest_file")"
        
        # Copy file
        cp "$file" "$dest_file"
        
        echo -e "${GRAY}  ✓ $relative_path (copied)${NC}"
    done
}

# Function to set permissions
set_permissions() {
    echo -e "${GRAY}Setting executable permissions...${NC}"
    
    # Make shell scripts executable
    find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Make specific script directories executable
    [ -d "scripts" ] && find scripts -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    [ -d ".claude/hooks" ] && find .claude/hooks -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
}

# Main installation process
main() {
    echo -e "${CYAN}📋 Processing templates...${NC}"
    
    # Process templates
    if [ -d "templates" ]; then
        copy_templates "templates" "."
        echo -e "${GREEN}✅ Templates processed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️ No templates directory found${NC}"
    fi
    
    # Set permissions
    set_permissions
    
    # Create any missing directories
    mkdir -p docs/story-notes docs/lessons docs/validation docs/changes
    
    echo -e "${GREEN}✅ BMAD-CC framework installed successfully!${NC}"
    echo -e "${CYAN}💡 Restart Claude Code to load new commands.${NC}"
    
    # Show next steps
    echo -e "\n${YELLOW}📋 Next Steps:${NC}"
    echo -e "${GRAY}1. Restart Claude Code${NC}"
    echo -e "${GRAY}2. Run: /bmad:init-taskmaster${NC}"
    echo -e "${GRAY}3. Start development: /bmad:smart-cycle${NC}"
}

# Check if running in correct directory
if [ ! -f "CLAUDE.md" ] && [ ! -f "README.md" ]; then
    echo -e "${YELLOW}⚠️ Warning: This doesn't appear to be a BMAD-CC project directory${NC}"
    echo -e "${GRAY}Continuing anyway...${NC}"
fi

# Run main installation
main
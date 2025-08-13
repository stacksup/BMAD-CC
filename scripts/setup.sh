#!/usr/bin/env bash
# Enhanced setup script for BMAD-CC template processing
# Processes templates with proper variable substitution

set -e

# Default values
PROJECT_DIR="."
PROJECT_NAME=""
PROJECT_TYPE="auto"
PRD_PATH=""
SECONDARY_PRD_PATH=""
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"
FRONTEND_PORT="3000"
BACKEND_PORT="8001"
DOCKER_COMPOSE_FILE=""
TASKMASTER_CLI="task-master"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project-dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --project-type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        --prd-path)
            PRD_PATH="$2"
            shift 2
            ;;
        --secondary-prd-path)
            SECONDARY_PRD_PATH="$2"
            shift 2
            ;;
        --frontend-dir)
            FRONTEND_DIR="$2"
            shift 2
            ;;
        --backend-dir)
            BACKEND_DIR="$2"
            shift 2
            ;;
        --frontend-port)
            FRONTEND_PORT="$2"
            shift 2
            ;;
        --backend-port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        --docker-compose-file)
            DOCKER_COMPOSE_FILE="$2"
            shift 2
            ;;
        --taskmaster-cli)
            TASKMASTER_CLI="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --project-dir DIR          Target project directory"
            echo "  --project-name NAME        Project name"
            echo "  --project-type TYPE        Project type (auto|saas|phaser|mobile|other)"
            echo "  --prd-path PATH           Path to PRD file"
            echo "  --secondary-prd-path PATH Secondary PRD path"
            echo "  --frontend-dir DIR        Frontend directory name"
            echo "  --backend-dir DIR         Backend directory name"
            echo "  --frontend-port PORT      Frontend port number"
            echo "  --backend-port PORT       Backend port number"
            echo "  --docker-compose-file FILE Docker compose file name"
            echo "  --taskmaster-cli CLI      Task Master CLI command"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Derive project name from directory if not provided
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename "$(cd "$PROJECT_DIR" && pwd)")
fi

echo -e "${CYAN}🛠️ Setting up BMAD-CC for project: $PROJECT_NAME${NC}"
echo -e "${GRAY}Project type: $PROJECT_TYPE${NC}"
echo -e "${GRAY}Target directory: $PROJECT_DIR${NC}"

# Function to replace template variables
replace_template_vars() {
    local content="$1"
    
    # Replace all template variables
    content=$(echo "$content" | sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g")
    content=$(echo "$content" | sed "s|{{PROJECT_TYPE}}|$PROJECT_TYPE|g")
    content=$(echo "$content" | sed "s|{{PRD_PATH}}|$PRD_PATH|g")
    content=$(echo "$content" | sed "s|{{SECONDARY_PRD_PATH}}|$SECONDARY_PRD_PATH|g")
    content=$(echo "$content" | sed "s|{{FRONTEND_DIR}}|$FRONTEND_DIR|g")
    content=$(echo "$content" | sed "s|{{BACKEND_DIR}}|$BACKEND_DIR|g")
    content=$(echo "$content" | sed "s|{{FRONTEND_PORT}}|$FRONTEND_PORT|g")
    content=$(echo "$content" | sed "s|{{BACKEND_PORT}}|$BACKEND_PORT|g")
    content=$(echo "$content" | sed "s|{{DOCKER_COMPOSE_FILE}}|$DOCKER_COMPOSE_FILE|g")
    content=$(echo "$content" | sed "s|{{TASKMASTER_CLI}}|$TASKMASTER_CLI|g")
    
    echo "$content"
}

# Function to process templates
process_templates() {
    local templates_dir="templates"
    local target_dir="$PROJECT_DIR"
    
    if [ ! -d "$templates_dir" ]; then
        echo -e "${RED}❌ Templates directory not found: $templates_dir${NC}" >&2
        return 1
    fi
    
    echo -e "${CYAN}📋 Processing templates...${NC}"
    
    local processed_count=0
    local copied_count=0
    
    # Process .tmpl files
    find "$templates_dir" -name "*.tmpl" -type f | while read -r template_file; do
        # Calculate target path (remove templates/ prefix and .tmpl suffix)
        local relative_path="${template_file#$templates_dir/}"
        local target_file="$target_dir/${relative_path%.tmpl}"
        
        # Create target directory
        mkdir -p "$(dirname "$target_file")"
        
        # Read and process template
        local content=$(cat "$template_file")
        local processed_content=$(replace_template_vars "$content")
        
        # Write processed content
        echo "$processed_content" > "$target_file"
        
        echo -e "${GRAY}  ✓ Processed: ${relative_path%.tmpl}${NC}"
        ((processed_count++))
    done
    
    # Copy non-template files
    find "$templates_dir" -type f ! -name "*.tmpl" | while read -r source_file; do
        local relative_path="${source_file#$templates_dir/}"
        local target_file="$target_dir/$relative_path"
        
        # Create target directory
        mkdir -p "$(dirname "$target_file")"
        
        # Copy file
        cp "$source_file" "$target_file"
        
        echo -e "${GRAY}  ✓ Copied: $relative_path${NC}"
        ((copied_count++))
    done
    
    echo -e "${GREEN}✅ Template processing complete${NC}"
    echo -e "${GRAY}Processed: $processed_count templates, Copied: $copied_count files${NC}"
}

# Function to set proper permissions
set_permissions() {
    echo -e "${CYAN}🔒 Setting executable permissions...${NC}"
    
    cd "$PROJECT_DIR"
    
    # Make scripts executable
    find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Specific directories
    [ -d "scripts" ] && find scripts -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    [ -d ".claude/hooks" ] && find .claude/hooks -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    echo -e "${GREEN}✅ Permissions set${NC}"
}

# Function to create missing directories
create_directories() {
    echo -e "${CYAN}📁 Creating project directories...${NC}"
    
    cd "$PROJECT_DIR"
    
    # Essential directories
    mkdir -p docs/{story-notes,lessons,validation,changes}
    mkdir -p .claude/{commands/bmad,agents,hooks}
    mkdir -p scripts
    
    # Project-specific directories
    case "$PROJECT_TYPE" in
        "saas")
            mkdir -p "$FRONTEND_DIR" "$BACKEND_DIR"
            ;;
        "phaser")
            mkdir -p src/{client,server} assets
            ;;
        "mobile")
            mkdir -p src/{components,screens,services} assets
            ;;
    esac
    
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Function to validate setup
validate_setup() {
    echo -e "${CYAN}🔍 Validating setup...${NC}"
    
    cd "$PROJECT_DIR"
    
    local issues=()
    
    # Check essential files
    [ ! -f ".claude/settings.local.json" ] && issues+=("Missing .claude/settings.local.json")
    [ ! -f "CLAUDE.md" ] && issues+=("Missing CLAUDE.md")
    [ ! -f "CHANGELOG.md" ] && issues+=("Missing CHANGELOG.md")
    
    # Check directories
    [ ! -d "docs" ] && issues+=("Missing docs directory")
    [ ! -d ".claude/commands/bmad" ] && issues+=("Missing BMAD commands directory")
    
    if [ ${#issues[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Setup validation passed${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Setup validation found issues:${NC}"
        for issue in "${issues[@]}"; do
            echo -e "${YELLOW}  - $issue${NC}"
        done
        return 1
    fi
}

# Main setup process
main() {
    # Ensure target directory exists
    mkdir -p "$PROJECT_DIR"
    
    # Change to templates directory (assuming we're in BMAD-CC repo)
    if [ ! -d "templates" ]; then
        echo -e "${RED}❌ Error: templates directory not found${NC}" >&2
        echo -e "${GRAY}Make sure you're running this from the BMAD-CC repository root${NC}" >&2
        exit 1
    fi
    
    # Process templates
    process_templates
    
    # Create directories
    create_directories
    
    # Set permissions
    set_permissions
    
    # Validate setup
    if validate_setup; then
        echo -e "\n${GREEN}✅ BMAD-CC setup completed successfully for $PROJECT_NAME!${NC}"
        
        echo -e "\n${YELLOW}📋 Next Steps:${NC}"
        echo -e "${GRAY}1. cd $PROJECT_DIR${NC}"
        echo -e "${GRAY}2. Restart Claude Code${NC}"
        echo -e "${GRAY}3. Run: /bmad:init-taskmaster${NC}"
        if [ -n "$PRD_PATH" ]; then
            echo -e "${GRAY}4. Parse PRD: task-master parse-prd --input=$PRD_PATH${NC}"
        fi
        echo -e "${GRAY}5. Start development: /bmad:smart-cycle${NC}"
    else
        echo -e "\n${YELLOW}⚠️ Setup completed with warnings${NC}"
        echo -e "${GRAY}Please review the issues above${NC}"
    fi
}

# Run main function
main
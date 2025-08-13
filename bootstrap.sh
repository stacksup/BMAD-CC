#!/usr/bin/env bash
# bootstrap.sh — remote installer
# Usage (from any project):
# curl -fsSL https://raw.githubusercontent.com/stacksup/BMAD-CC/main/bootstrap.sh | bash -s -- --project-dir . --project-type auto

set -e

# Default parameters
PROJECT_DIR="."
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
        --project-type)
            case "$2" in
                auto|saas|phaser|mobile|other)
                    PROJECT_TYPE="$2"
                    ;;
                *)
                    echo "Invalid project type: $2" >&2
                    exit 1
                    ;;
            esac
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
            echo "  --project-dir DIR          Project directory (default: .)"
            echo "  --project-type TYPE        Project type: auto|saas|phaser|mobile|other (default: auto)"
            echo "  --prd-path PATH           Path to PRD file"
            echo "  --secondary-prd-path PATH Secondary PRD path"
            echo "  --frontend-dir DIR        Frontend directory (default: frontend)"
            echo "  --backend-dir DIR         Backend directory (default: backend)"
            echo "  --frontend-port PORT      Frontend port (default: 3000)"
            echo "  --backend-port PORT       Backend port (default: 8001)"
            echo "  --docker-compose-file FILE Docker compose file"
            echo "  --taskmaster-cli CLI      Task Master CLI command (default: task-master)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Function to install BMAD
install_bmad() {
    local repo="https://github.com/stacksup/BMAD-CC.git"
    
    # Get absolute path and project name
    local project_path=$(cd "$PROJECT_DIR" && pwd)
    local project_name=$(basename "$project_path")
    
    echo -e "${CYAN}🚀 Installing BMAD-CC Framework for $project_name${NC}"
    
    # Auto-detect project type
    if [ "$PROJECT_TYPE" = "auto" ]; then
        if [ -f "$PROJECT_DIR/frontend/package.json" ] && [ -d "$PROJECT_DIR/backend" ]; then
            PROJECT_TYPE="saas"
        elif [ -d "$PROJECT_DIR/src/client" ] || [ -f "$PROJECT_DIR/package.json" ]; then
            # Fixed: Don't assume package.json = game project
            # Check for game-specific indicators
            if [ -f "$PROJECT_DIR/package.json" ]; then
                local content=$(cat "$PROJECT_DIR/package.json" 2>/dev/null || echo "")
                if echo "$content" | grep -qE '"phaser"|"game"|"pixi"|"babylon"'; then
                    PROJECT_TYPE="phaser"
                else
                    PROJECT_TYPE="other"
                fi
            else
                PROJECT_TYPE="other"
            fi
        else
            PROJECT_TYPE="other"
        fi
    fi
    
    echo -e "${GRAY}Detected project type: $PROJECT_TYPE${NC}"
    
    # Auto-detect PRD path
    if [ -z "$PRD_PATH" ]; then
        if [ -f "$PROJECT_DIR/planning_docs/DEVELOPMENT_PLAN_PART1.md" ]; then
            PRD_PATH="planning_docs/DEVELOPMENT_PLAN_PART1.md"
        elif [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
            PRD_PATH="CLAUDE.md"
        fi
    fi
    
    # Auto-detect Docker Compose file
    if [ -z "$DOCKER_COMPOSE_FILE" ]; then
        if [ -f "$PROJECT_DIR/docker-compose.full.yml" ]; then
            DOCKER_COMPOSE_FILE="docker-compose.full.yml"
        elif [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
            DOCKER_COMPOSE_FILE="docker-compose.yml"
        fi
    fi
    
    # Create temporary directory
    local tmp_dir=$(mktemp -d)
    
    echo -e "${GRAY}Cloning BMAD-CC repository...${NC}"
    if ! git clone --depth 1 "$repo" "$tmp_dir" &>/dev/null; then
        echo -e "${RED}❌ Failed to clone BMAD-CC repository${NC}" >&2
        exit 1
    fi
    
    # Template variable map
    local map_file="$tmp_dir/template_map.tmp"
    cat > "$map_file" <<EOF
{{PROJECT_NAME}}|$project_name
{{PROJECT_TYPE}}|$PROJECT_TYPE
{{PRD_PATH}}|$PRD_PATH
{{SECONDARY_PRD_PATH}}|$SECONDARY_PRD_PATH
{{FRONTEND_DIR}}|$FRONTEND_DIR
{{BACKEND_DIR}}|$BACKEND_DIR
{{FRONTEND_PORT}}|$FRONTEND_PORT
{{BACKEND_PORT}}|$BACKEND_PORT
{{DOCKER_COMPOSE_FILE}}|$DOCKER_COMPOSE_FILE
{{TASKMASTER_CLI}}|$TASKMASTER_CLI
EOF
    
    echo -e "${CYAN}📋 Installing templates with project configuration...${NC}"
    
    # Process templates
    if [ -d "$tmp_dir/templates" ]; then
        cd "$tmp_dir"
        
        # Use the enhanced setup script if available
        if [ -f "scripts/setup.sh" ]; then
            chmod +x scripts/setup.sh
            ./scripts/setup.sh \
                --project-dir "$project_path" \
                --project-name "$project_name" \
                --project-type "$PROJECT_TYPE" \
                --prd-path "$PRD_PATH" \
                --frontend-dir "$FRONTEND_DIR" \
                --backend-dir "$BACKEND_DIR" \
                --frontend-port "$FRONTEND_PORT" \
                --backend-port "$BACKEND_PORT" \
                --docker-compose-file "$DOCKER_COMPOSE_FILE" \
                --taskmaster-cli "$TASKMASTER_CLI"
        else
            # Fallback: manual template processing
            echo -e "${YELLOW}⚠️ Using fallback template processing${NC}"
            
            # Copy and process templates manually
            find templates -type f -name "*.tmpl" | while read -r template; do
                local target_file="$project_path/${template#templates/}"
                target_file="${target_file%.tmpl}"
                
                # Create target directory
                mkdir -p "$(dirname "$target_file")"
                
                # Process template
                local temp_content=$(cat "$template")
                while IFS='|' read -r placeholder value; do
                    temp_content=$(echo "$temp_content" | sed "s|$placeholder|$value|g")
                done < "$map_file"
                
                echo "$temp_content" > "$target_file"
            done
            
            # Copy non-template files
            find templates -type f ! -name "*.tmpl" | while read -r file; do
                local target_file="$project_path/${file#templates/}"
                mkdir -p "$(dirname "$target_file")"
                cp "$file" "$target_file"
            done
        fi
    fi
    
    # Cleanup
    rm -rf "$tmp_dir"
    
    echo -e "${GREEN}✅ BMAD installed and tailored for '$project_name' ($PROJECT_TYPE).${NC}"
    echo -e "${CYAN}💡 Restart Claude Code to load new commands.${NC}"
    
    # Show next steps
    echo -e "\n${YELLOW}📋 Next Steps:${NC}"
    echo -e "${GRAY}1. Restart Claude Code${NC}"
    echo -e "${GRAY}2. Initialize Task Master: /bmad:init-taskmaster${NC}"
    if [ -n "$PRD_PATH" ]; then
        echo -e "${GRAY}3. Parse your PRD: task-master parse-prd --input=$PRD_PATH${NC}"
    fi
    echo -e "${GRAY}4. Start development: /bmad:smart-cycle${NC}"
}

# Check if running as sourced script or direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Direct execution
    install_bmad
else
    # Sourced - function is now available
    echo "BMAD installation function loaded. Call install_bmad to proceed."
fi
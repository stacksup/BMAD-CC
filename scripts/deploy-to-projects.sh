#!/usr/bin/env bash
# Deploy BMAD-CC updates to multiple projects
# Useful for updating all your projects at once

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Configuration
PROJECTS_FILE="bmad-projects.txt"
LOG_FILE="deployment-$(date +%Y%m%d-%H%M%S).log"
DRY_RUN=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --projects-file)
            PROJECTS_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --projects-file FILE  File containing project paths (default: bmad-projects.txt)"
            echo "  --dry-run            Show what would be done without making changes"
            echo "  --force              Force update even if project has uncommitted changes"
            echo "  --help               Show this help message"
            echo ""
            echo "Projects file format (one path per line):"
            echo "  /path/to/project1"
            echo "  /path/to/project2"
            echo "  # Comments start with #"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

echo -e "${CYAN}🚀 BMAD-CC Multi-Project Deployment${NC}"

# Function to check if directory is a BMAD project
is_bmad_project() {
    local project_dir="$1"
    
    if [ -f "$project_dir/CLAUDE.md" ] || [ -d "$project_dir/.claude" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if project has uncommitted changes
has_uncommitted_changes() {
    local project_dir="$1"
    
    cd "$project_dir"
    
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        if [ -n "$(git status --porcelain)" ]; then
            return 0
        fi
    fi
    
    return 1
}

# Function to backup project
backup_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")
    local backup_dir="$project_dir/bmad-backup-$(date +%Y%m%d-%H%M%S)"
    
    mkdir -p "$backup_dir"
    
    cd "$project_dir"
    
    # Backup BMAD-specific files
    local items_to_backup=(
        ".claude"
        "scripts"
        "CLAUDE.md"
        "CHANGELOG.md"
    )
    
    for item in "${items_to_backup[@]}"; do
        if [ -e "$item" ]; then
            cp -r "$item" "$backup_dir/"
        fi
    done
    
    echo "$backup_dir"
}

# Function to deploy to single project
deploy_to_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")
    
    echo -e "\n${CYAN}📎 Deploying to: $project_name${NC}"
    echo -e "${GRAY}Path: $project_dir${NC}"
    
    # Check if project exists
    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}❌ Project directory not found${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # Check if it's a BMAD project
    if ! is_bmad_project "$project_dir"; then
        echo -e "${YELLOW}⚠️ Not a BMAD project, skipping${NC}" | tee -a "$LOG_FILE"
        return 0
    fi
    
    # Check for uncommitted changes
    if has_uncommitted_changes "$project_dir" && [ "$FORCE" != "true" ]; then
        echo -e "${YELLOW}⚠️ Project has uncommitted changes, skipping (use --force to override)${NC}" | tee -a "$LOG_FILE"
        return 0
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        echo -e "${GRAY}[DRY RUN] Would deploy BMAD-CC to $project_name${NC}"
        return 0
    fi
    
    # Create backup
    local backup_dir
    backup_dir=$(backup_project "$project_dir")
    echo -e "${GRAY}  ✓ Backup created: $(basename "$backup_dir")${NC}"
    
    # Copy current BMAD-CC files
    cd "$(dirname "$0")/.."
    local bmad_root=$(pwd)
    
    cd "$project_dir"
    
    # Update .claude directory
    if [ -d "$bmad_root/.claude" ]; then
        rm -rf .claude
        cp -r "$bmad_root/.claude" .
        echo -e "${GRAY}  ✓ Updated .claude directory${NC}"
    fi
    
    # Update scripts directory
    if [ -d "$bmad_root/scripts" ]; then
        rm -rf scripts
        cp -r "$bmad_root/scripts" .
        chmod +x scripts/*.sh 2>/dev/null || true
        echo -e "${GRAY}  ✓ Updated scripts directory${NC}"
    fi
    
    # Set proper permissions
    find .claude/hooks -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    # Update project-specific files if they don't exist
    if [ ! -f "CLAUDE.md" ] && [ -f "$bmad_root/templates/root/CLAUDE_APPEND.md.tmpl" ]; then
        # Create basic CLAUDE.md from template
        sed "s/{{PROJECT_NAME}}/$project_name/g" "$bmad_root/templates/root/CLAUDE_APPEND.md.tmpl" > CLAUDE.md
        echo -e "${GRAY}  ✓ Created CLAUDE.md${NC}"
    fi
    
    echo -e "${GREEN}  ✅ Successfully deployed to $project_name${NC}" | tee -a "$LOG_FILE"
    return 0
}

# Function to load projects list
load_projects() {
    if [ ! -f "$PROJECTS_FILE" ]; then
        echo -e "${YELLOW}⚠️ Projects file not found: $PROJECTS_FILE${NC}"
        echo -e "${GRAY}Creating sample projects file...${NC}"
        
        cat > "$PROJECTS_FILE" <<EOF
# BMAD-CC Projects List
# Add one project path per line
# Lines starting with # are comments

# Example:
# /home/user/projects/my-app
# /home/user/projects/another-project
EOF
        
        echo -e "${YELLOW}Please edit $PROJECTS_FILE with your project paths${NC}"
        return 1
    fi
    
    # Read projects, skip comments and empty lines
    local projects=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
            continue
        fi
        
        # Expand tilde and resolve path
        local project_path=$(eval echo "$line")
        projects+=("$project_path")
    done < "$PROJECTS_FILE"
    
    if [ ${#projects[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️ No projects found in $PROJECTS_FILE${NC}"
        return 1
    fi
    
    echo "${projects[@]}"
}

# Function to show deployment summary
show_summary() {
    echo -e "\n${CYAN}📊 Deployment Summary${NC}"
    echo "============================"
    
    if [ -f "$LOG_FILE" ]; then
        local successful=$(grep -c "Successfully deployed" "$LOG_FILE" 2>/dev/null || echo "0")
        local total=$(grep -c "Deploying to:" "$LOG_FILE" 2>/dev/null || echo "0")
        
        echo -e "${GRAY}Total projects: $total${NC}"
        echo -e "${GREEN}Successful deployments: $successful${NC}"
        
        if [ $successful -ne $total ]; then
            local failed=$((total - successful))
            echo -e "${RED}Failed deployments: $failed${NC}"
        fi
        
        echo -e "\n${GRAY}Full log: $LOG_FILE${NC}"
    fi
    
    echo "============================"
}

# Main deployment process
main() {
    # Check if we're in BMAD-CC root directory
    if [ ! -f "CLAUDE.md" ] || [ ! -d ".claude" ]; then
        echo -e "${RED}❌ This script must be run from the BMAD-CC repository root${NC}" >&2
        exit 1
    fi
    
    echo -e "${GRAY}Projects file: $PROJECTS_FILE${NC}"
    echo -e "${GRAY}Log file: $LOG_FILE${NC}"
    echo -e "${GRAY}Dry run: $DRY_RUN${NC}"
    echo -e "${GRAY}Force: $FORCE${NC}"
    
    # Load projects list
    local projects_array
    if ! projects_array=($(load_projects)); then
        exit 1
    fi
    
    echo -e "\n${CYAN}Found ${#projects_array[@]} projects to deploy${NC}"
    
    # Initialize log file
    echo "BMAD-CC Deployment Log - $(date)" > "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
    
    # Deploy to each project
    local success_count=0
    for project_dir in "${projects_array[@]}"; do
        if deploy_to_project "$project_dir"; then
            ((success_count++))
        fi
    done
    
    # Show summary
    show_summary
    
    if [ $success_count -eq ${#projects_array[@]} ]; then
        echo -e "\n${GREEN}✅ All deployments completed successfully!${NC}"
    else
        echo -e "\n${YELLOW}⚠️ Some deployments had issues. Check the log file for details.${NC}"
    fi
}

# Run main function
main
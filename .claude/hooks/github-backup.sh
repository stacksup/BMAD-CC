#!/usr/bin/env bash
# GitHub Automatic Backup Hook for BMAD
# Ensures all completed work is backed up to GitHub

set -e

# Parameters
ACTION="${1:-backup}"
BRANCH="${2:-main}"
FORCE="${3:-false}"

# Configuration
PROJECT_NAME="BMAD-CC"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Function to get GitHub user
get_github_user() {
    # Try GitHub CLI first (most reliable)
    if command -v gh &> /dev/null; then
        local gh_user=$(gh api user --jq '.login' 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$gh_user" ]; then
            echo "$gh_user"
            return 0
        fi
    fi
    
    # Try git config
    local git_user=$(git config --get user.name 2>/dev/null)
    if [ -n "$git_user" ]; then
        echo "$git_user"
        return 0
    fi
    
    # Try to extract from remote URL
    local remote_url=$(git config --get remote.origin.url 2>/dev/null)
    if echo "$remote_url" | grep -qE 'github\.com[:/]([^/]+)/'; then
        echo "$remote_url" | sed -E 's/.*github\.com[:/]([^/]+).*/\1/'
        return 0
    fi
    
    return 1
}

# Function to test GitHub connection
test_github_connection() {
    # Check if we have a remote
    if ! git remote -v | grep -q "origin.*github.com"; then
        echo "false|No GitHub remote configured"
        return 1
    fi
    
    # Check if we can reach GitHub
    if ! git ls-remote --heads origin &>/dev/null; then
        echo "false|Cannot connect to GitHub (check credentials)"
        return 1
    fi
    
    echo "true|GitHub connection OK"
    return 0
}

# Function to get current branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"
}

# Function to ensure GitHub remote
ensure_github_remote() {
    repo_name="$1"
    
    local remote_url=$(git config --get remote.origin.url 2>/dev/null)
    
    if [ -z "$remote_url" ]; then
        echo -e "${YELLOW}⚠️ No GitHub remote configured${NC}"
        
        # Try to get GitHub username
        local gh_user
        if ! gh_user=$(get_github_user); then
            echo -e "${YELLOW}Cannot determine GitHub username. Please set up remote manually:${NC}"
            echo -e "${CYAN}  git remote add origin https://github.com/YOUR_USERNAME/$repo_name.git${NC}"
            return 1
        fi
        
        # Check if repo exists on GitHub
        echo -e "${CYAN}Checking if repo exists on GitHub...${NC}"
        if command -v gh &> /dev/null; then
            if ! gh repo view "$gh_user/$repo_name" &>/dev/null; then
                echo -e "${YELLOW}Repository doesn't exist on GitHub. Creating...${NC}"
                
                # Create repo
                if gh repo create "$repo_name" --private --source=. --remote=origin; then
                    echo -e "${GREEN}✅ Created GitHub repository: $gh_user/$repo_name${NC}"
                    return 0
                else
                    echo -e "${RED}Failed to create GitHub repository${NC}"
                    return 1
                fi
            else
                # Repo exists, add remote
                echo -e "${CYAN}Adding GitHub remote...${NC}"
                git remote add origin "https://github.com/$gh_user/$repo_name.git"
                return 0
            fi
        fi
    fi
    
    return 0
}

# Function to backup to GitHub
backup_to_github() {
    local commit_message="${1:-backup: Auto-backup completed work}"
    local create_pr="${2:-false}"
    
    echo -e "\n${CYAN}📄 GitHub Backup Process Starting...${NC}"
    
    # Check GitHub connection
    local connection_result=$(test_github_connection)
    local connected=$(echo "$connection_result" | cut -d'|' -f1)
    local message=$(echo "$connection_result" | cut -d'|' -f2)
    
    if [ "$connected" != "true" ]; then
        echo -e "${YELLOW}GitHub not connected: $message${NC}"
        
        # Try to set up remote
        repo_name=$(basename "$(pwd)")
        if ! ensure_github_remote "$repo_name"; then
            echo -e "${RED}Cannot establish GitHub connection${NC}"
            return 1
        fi
    fi
    
    # Get current branch
    local current_branch=$(get_current_branch)
    echo -e "${GRAY}Current branch: $current_branch${NC}"
    
    # Check for uncommitted changes
    local status=$(git status --porcelain 2>/dev/null)
    if [ -n "$status" ]; then
        echo -e "${YELLOW}📝 Uncommitted changes detected. Committing...${NC}"
        
        git add -A
        git commit -m "$commit_message [auto-backup]"
        
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}Failed to commit changes${NC}"
            return 1
        fi
    fi
    
    # Pull latest from remote to avoid conflicts
    echo -e "${CYAN}📥 Pulling latest from GitHub...${NC}"
    git pull origin "$current_branch" --rebase --autostash &>/dev/null || true
    
    # Push to GitHub
    echo -e "${CYAN}📤 Pushing to GitHub...${NC}"
    if ! git push origin "$current_branch"; then
        echo -e "${YELLOW}⚠️ Direct push failed. Trying with upstream...${NC}"
        if ! git push --set-upstream origin "$current_branch"; then
            echo -e "${RED}Failed to push to GitHub${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}✅ Successfully backed up to GitHub!${NC}"
    
    # Show GitHub URL
    local remote_url=$(git config --get remote.origin.url 2>/dev/null)
    if [ -n "$remote_url" ]; then
        local web_url
        if echo "$remote_url" | grep -q "git@github.com:"; then
            web_url=$(echo "$remote_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
        else
            web_url=$(echo "$remote_url" | sed 's/\.git$//')
        fi
        echo -e "${CYAN}🔗 View on GitHub: $web_url${NC}"
    fi
    
    # Create PR if requested
    if [ "$create_pr" = "true" ] && command -v gh &> /dev/null; then
        if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
            echo -e "${CYAN}🔀 Creating pull request...${NC}"
            if gh pr create --title "Auto-backup: $commit_message" --body "Automated backup of completed work" --head "$current_branch" --base main; then
                echo -e "${GREEN}✅ Pull request created${NC}"
            fi
        fi
    fi
    
    return 0
}

# Function to show backup status
show_backup_status() {
    echo -e "\n${CYAN}📊 GitHub Backup Status for $PROJECT_NAME${NC}"
    echo "=================================================="
    
    # Check connection
    local connection_result=$(test_github_connection)
    local connected=$(echo "$connection_result" | cut -d'|' -f1)
    local message=$(echo "$connection_result" | cut -d'|' -f2)
    
    if [ "$connected" = "true" ]; then
        echo -e "${GREEN}✅ GitHub Connection: $message${NC}"
    else
        echo -e "${RED}❌ GitHub Connection: $message${NC}"
    fi
    
    # Show remote info
    local remote_url=$(git config --get remote.origin.url 2>/dev/null)
    if [ -n "$remote_url" ]; then
        echo -e "${GRAY}📍 Remote: $remote_url${NC}"
    else
        echo -e "${YELLOW}📍 Remote: Not configured${NC}"
    fi
    
    # Show current branch
    local current_branch=$(get_current_branch)
    echo -e "${GRAY}🌿 Branch: $current_branch${NC}"
    
    # Show uncommitted changes
    local status=$(git status --porcelain 2>/dev/null)
    if [ -n "$status" ]; then
        local change_count=$(echo "$status" | wc -l)
        echo -e "${YELLOW}📝 Uncommitted Changes: $change_count files${NC}"
    else
        echo -e "${GREEN}📝 Uncommitted Changes: None${NC}"
    fi
    
    # Show last commit
    if git log --oneline -1 &>/dev/null; then
        local last_commit=$(git log --oneline -1)
        echo -e "${GRAY}📅 Last Commit: $last_commit${NC}"
    fi
    
    echo "=================================================="
}

# Main execution
case "$ACTION" in
    backup)
        backup_to_github
        ;;
    
    status)
        show_backup_status
        ;;
    
    force-backup)
        backup_to_github "force: Manual backup initiated" "$FORCE"
        ;;
    
    setup)
        repo_name=$(basename "$(pwd)")
        ensure_github_remote "$repo_name"
        ;;
    
    *)
        echo -e "${RED}Unknown action: $ACTION${NC}" >&2
        echo "Valid actions: backup, status, force-backup, setup"
        exit 1
        ;;
esac
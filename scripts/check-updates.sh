#!/usr/bin/env bash
# Check for BMAD-CC framework updates

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${CYAN}🔍 Checking for BMAD-CC updates...${NC}"

# Check if we're in a git repository
if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${GRAY}Fetching latest changes...${NC}"
    git fetch origin &>/dev/null || true
    
    # Check if there are updates
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null || echo "$local_commit")
    
    if [ "$local_commit" != "$remote_commit" ]; then
        echo -e "${YELLOW}🆕 Updates available!${NC}"
        echo -e "${GRAY}Run 'git pull' or './scripts/update-bmad.sh' to update${NC}"
    else
        echo -e "${GREEN}✅ Framework is up to date${NC}"
    fi
else
    echo -e "${GRAY}Not a git repository - cannot check for updates${NC}"
fi
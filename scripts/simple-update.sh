#!/usr/bin/env bash
# Simple update script for BMAD-CC

set -e

# Color codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${CYAN}🔄 Simple BMAD-CC Update${NC}"

# Pull latest changes if in git repo
if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${GRAY}Pulling latest changes...${NC}"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
fi

# Update permissions
echo -e "${GRAY}Updating permissions...${NC}"
find .claude/hooks -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

echo -e "${GREEN}✅ Simple update complete${NC}"
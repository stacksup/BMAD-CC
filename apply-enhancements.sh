#!/usr/bin/env bash
# Apply enhancements to BMAD-CC project

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${CYAN}✨ Applying BMAD-CC Enhancements${NC}"

# Run the install-self script to apply latest templates
if [ -f "install-self.sh" ]; then
    echo -e "${GRAY}Running self-installation...${NC}"
    ./install-self.sh
else
    echo -e "${YELLOW}⚠️ install-self.sh not found${NC}"
fi

# Set permissions
echo -e "${GRAY}Setting permissions...${NC}"
find .claude/hooks -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find scripts -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
chmod +x *.sh 2>/dev/null || true

echo -e "${GREEN}✅ Enhancements applied${NC}"
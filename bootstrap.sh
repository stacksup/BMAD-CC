#!/usr/bin/env bash
# Bootstrap script for BMAD-CC Framework Installation
# Usage: curl -sSL https://raw.githubusercontent.com/stacksup/BMAD-CC/main/bootstrap.sh | bash -s -- <project-dir> <project-type>

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Default values
PROJECT_DIR="${1:-.}"
PROJECT_TYPE="${2:-auto}"
REPO_URL="https://github.com/stacksup/BMAD-CC.git"
TEMP_DIR="bmad-temp-$(date +%s)"

echo -e "${CYAN}🚀 BMAD-CC Framework Bootstrap${NC}"
echo -e "${GRAY}Project Directory: $(realpath "$PROJECT_DIR")${NC}"
echo -e "${GRAY}Project Type: $PROJECT_TYPE${NC}"

# Ensure project directory exists and is writable
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Project directory does not exist: $PROJECT_DIR${NC}" >&2
    exit 1
fi

if [ ! -w "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Project directory is not writable: $PROJECT_DIR${NC}" >&2
    exit 1
fi

# Convert to absolute path
PROJECT_DIR=$(realpath "$PROJECT_DIR")

echo -e "${CYAN}📦 Cloning BMAD-CC framework...${NC}"

# Clone repository to temporary directory
if ! git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR"; then
    echo -e "${RED}❌ Failed to clone repository${NC}" >&2
    exit 1
fi

echo -e "${GREEN}✅ Repository cloned successfully${NC}"

# Change to temporary directory
cd "$TEMP_DIR"

# Derive project name from directory
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo -e "${CYAN}🛠️ Installing framework components...${NC}"

# Run simple installer
if ! bash simple-install.sh "$PROJECT_DIR"; then
    echo -e "${RED}❌ Installation failed${NC}" >&2
    cd ..
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}✅ Framework installation completed${NC}"

# Cleanup
cd ..
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}🎉 BMAD-CC Framework installed successfully!${NC}"
echo -e "\n${YELLOW}📋 Next Steps:${NC}"
echo -e "${GRAY}1. Restart Claude Code to load new commands${NC}"
echo -e "${GRAY}2. Run: /bmad:init-taskmaster${NC}"
echo -e "${GRAY}3. Start development: /bmad:smart-cycle${NC}"
echo -e "\n${CYAN}Available Commands:${NC}"
echo -e "${GRAY}• /bmad:smart-cycle     - Intelligent development cycle${NC}"
echo -e "${GRAY}• /bmad:story-cycle     - Story-driven development${NC}"
echo -e "${GRAY}• /bmad:saas-cycle      - SaaS-focused development${NC}"
echo -e "${GRAY}• /bmad:planning-cycle  - Planning and architecture${NC}"
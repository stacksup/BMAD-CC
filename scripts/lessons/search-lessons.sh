#!/usr/bin/env bash
# Search lessons learned database

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Default values
SEARCH_TERM="${1:-}"
LESSONS_DIR="docs/lessons"
MAX_RESULTS=10

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --lessons-dir)
            LESSONS_DIR="$2"
            shift 2
            ;;
        --max-results)
            MAX_RESULTS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [search_term] [options]"
            echo "Options:"
            echo "  --lessons-dir DIR     Directory to search (default: docs/lessons)"
            echo "  --max-results N      Maximum results to show (default: 10)"
            echo "  --help               Show this help message"
            exit 0
            ;;
        *)
            if [ -z "$SEARCH_TERM" ]; then
                SEARCH_TERM="$1"
            fi
            shift
            ;;
    esac
done

echo -e "${CYAN}🔍 Searching Lessons Database${NC}"

if [ ! -d "$LESSONS_DIR" ]; then
    echo -e "${YELLOW}⚠️ Lessons directory not found: $LESSONS_DIR${NC}"
    exit 1
fi

if [ -z "$SEARCH_TERM" ]; then
    echo -e "${GRAY}Showing all lessons...${NC}"
    find "$LESSONS_DIR" -name "*.md" -type f | head -n "$MAX_RESULTS" | while read -r lesson; do
        local title=$(grep -m1 "^# " "$lesson" 2>/dev/null | sed 's/^# //' || basename "$lesson" .md)
        echo -e "${GREEN}✓ $title${NC} ${GRAY}($(basename "$lesson"))${NC}"
    done
else
    echo -e "${GRAY}Searching for: '$SEARCH_TERM'${NC}"
    
    local count=0
    grep -r -l -i "$SEARCH_TERM" "$LESSONS_DIR" 2>/dev/null | head -n "$MAX_RESULTS" | while read -r lesson; do
        local title=$(grep -m1 "^# " "$lesson" 2>/dev/null | sed 's/^# //' || basename "$lesson" .md)
        local context=$(grep -i -n "$SEARCH_TERM" "$lesson" | head -1 | cut -d: -f2- | sed 's/^[[:space:]]*//')
        
        echo -e "${GREEN}✓ $title${NC} ${GRAY}($(basename "$lesson"))${NC}"
        if [ -n "$context" ]; then
            echo -e "${GRAY}   $context${NC}"
        fi
        echo
        ((count++))
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}⚠️ No lessons found matching '$SEARCH_TERM'${NC}"
    fi
fi
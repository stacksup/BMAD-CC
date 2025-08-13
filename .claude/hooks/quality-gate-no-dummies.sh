#!/usr/bin/env bash
# Quality Gate: No Dummy Data/Content Hook for BMAD-CC
# Prevents commits with placeholder or dummy content

set -e

# Configuration
PROJECT_NAME="BMAD-CC"
DISABLE_GATES="${BMAD_DISABLE_GATES:-0}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Function to check for dummy content
check_dummy_content() {
    local file="$1"
    local content="$2"
    local issues=()
    
    # Common dummy patterns
    local dummy_patterns=(
        "TODO.*implement"
        "FIXME.*placeholder"
        "dummy.*data"
        "placeholder.*text"
        "lorem ipsum"
        "test.*test.*test"
        "example.*example"
        "sample.*content"
        "<your.*here>"
        "\[your.*here\]"
        "\[TODO\]"
        "\[FIXME\]"
        "\[PLACEHOLDER\]"
        "asdf.*asdf"
        "qwerty.*qwerty"
        "123.*456.*789"
    )
    
    for pattern in "${dummy_patterns[@]}"; do
        if echo "$content" | grep -qiE "$pattern"; then
            issues+=("Contains dummy/placeholder content: $pattern")
        fi
    done
    
    # Check for repeated characters (likely placeholder)
    if echo "$content" | grep -qE "(.)\1{10,}"; then
        issues+=("Contains repeated characters (possible placeholder)")
    fi
    
    # Check for obvious test data
    if echo "$content" | grep -qiE "(test.*user|john.*doe|jane.*doe|foo.*bar|hello.*world)"; then
        issues+=("Contains obvious test/example data")
    fi
    
    # Return issues count
    echo "${#issues[@]}"
    
    # Print issues if any
    for issue in "${issues[@]}"; do
        echo "❌ $issue" >&2
    done
}

# Function to check specific file types
check_file_type() {
    local file="$1"
    local issues=0
    
    if [ ! -f "$file" ]; then
        return 0
    fi
    
    local content=$(cat "$file")
    
    case "$file" in
        *.md)
            # Markdown files
            issues=$(check_dummy_content "$file" "$content")
            
            # Check for empty headers
            if echo "$content" | grep -qE "^#+\s*$"; then
                echo -e "${RED}❌ Empty headers found in $file${NC}" >&2
                ((issues++))
            fi
            
            # Check for incomplete lists
            if echo "$content" | grep -qE "^-\s*$|^\*\s*$"; then
                echo -e "${RED}❌ Empty list items found in $file${NC}" >&2
                ((issues++))
            fi
            ;;
            
        *.json)
            # JSON files
            issues=$(check_dummy_content "$file" "$content")
            
            # Check for invalid JSON
            if ! python -m json.tool "$file" &>/dev/null; then
                echo -e "${RED}❌ Invalid JSON in $file${NC}" >&2
                ((issues++))
            fi
            ;;
            
        *.js|*.ts|*.jsx|*.tsx)
            # JavaScript/TypeScript files
            issues=$(check_dummy_content "$file" "$content")
            
            # Check for console.log statements
            if echo "$content" | grep -qE "console\.log|console\.debug"; then
                echo -e "${YELLOW}⚠️ Console statements found in $file (review before production)${NC}" >&2
            fi
            
            # Check for debugger statements
            if echo "$content" | grep -qE "debugger;"; then
                echo -e "${RED}❌ Debugger statements found in $file${NC}" >&2
                ((issues++))
            fi
            ;;
            
        *.py)
            # Python files
            issues=$(check_dummy_content "$file" "$content")
            
            # Check for print statements
            if echo "$content" | grep -qE "print\("; then
                echo -e "${YELLOW}⚠️ Print statements found in $file (review before production)${NC}" >&2
            fi
            
            # Check for pdb statements
            if echo "$content" | grep -qE "import pdb|pdb\.set_trace"; then
                echo -e "${RED}❌ Debugger statements found in $file${NC}" >&2
                ((issues++))
            fi
            ;;
            
        *.sql)
            # SQL files
            issues=$(check_dummy_content "$file" "$content")
            
            # Check for DROP statements without conditions
            if echo "$content" | grep -qiE "DROP\s+(TABLE|DATABASE|SCHEMA)\s+(?!IF\s+EXISTS)"; then
                echo -e "${RED}❌ Unsafe DROP statements found in $file${NC}" >&2
                ((issues++))
            fi
            ;;
    esac
    
    return $issues
}

# Function to check all changed files
check_changed_files() {
    local total_issues=0
    
    # Get changed files
    local changed_files
    if ! changed_files=$(git diff --name-only --cached 2>/dev/null); then
        changed_files=$(git diff --name-only 2>/dev/null || true)
    fi
    
    if [ -z "$changed_files" ]; then
        echo -e "${GRAY}No changed files to check${NC}"
        return 0
    fi
    
    echo -e "${CYAN}🔍 Checking files for dummy content...${NC}"
    
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        
        echo -e "${GRAY}Checking: $file${NC}"
        
        local file_issues=0
        if ! file_issues=$(check_file_type "$file"); then
            file_issues=$?
        fi
        
        ((total_issues += file_issues))
        
        if [ $file_issues -eq 0 ]; then
            echo -e "${GREEN}✅ $file: Clean${NC}"
        else
            echo -e "${RED}❌ $file: $file_issues issues found${NC}"
        fi
    done <<< "$changed_files"
    
    return $total_issues
}

# Function to show quality gate status
show_quality_status() {
    echo -e "\n${CYAN}🎯 Quality Gate Status for $PROJECT_NAME${NC}"
    echo "=========================================="
    
    if [ "$DISABLE_GATES" = "1" ]; then
        echo -e "${YELLOW}⚠️ Quality gates are DISABLED${NC}"
    else
        echo -e "${GREEN}✅ Quality gates are ENABLED${NC}"
    fi
    
    # Check for common quality issues in the project
    local total_todos=$(find . -type f \( -name "*.md" -o -name "*.js" -o -name "*.ts" -o -name "*.py" \) -exec grep -l "TODO\|FIXME" {} \; 2>/dev/null | wc -l)
    echo -e "${GRAY}📝 Files with TODOs/FIXMEs: $total_todos${NC}"
    
    local total_files=$(find . -type f \( -name "*.md" -o -name "*.js" -o -name "*.ts" -o -name "*.py" \) | wc -l)
    echo -e "${GRAY}📄 Total tracked files: $total_files${NC}"
    
    echo "=========================================="
}

# Function to fix common issues automatically
auto_fix_issues() {
    echo -e "${CYAN}🔧 Auto-fixing common quality issues...${NC}"
    
    local fixed=0
    
    # Remove trailing whitespace
    if command -v sed &> /dev/null; then
        find . -type f \( -name "*.md" -o -name "*.js" -o -name "*.ts" -o -name "*.py" \) -exec sed -i 's/[[:space:]]*$//' {} \; 2>/dev/null && ((fixed++))
    fi
    
    # Fix empty list items in markdown
    find . -name "*.md" -exec sed -i 's/^-\s*$/-/' {} \; 2>/dev/null && ((fixed++))
    find . -name "*.md" -exec sed -i 's/^\*\s*$/\*/' {} \; 2>/dev/null && ((fixed++))
    
    if [ $fixed -gt 0 ]; then
        echo -e "${GREEN}✅ Applied $fixed automatic fixes${NC}"
    else
        echo -e "${GRAY}No automatic fixes applied${NC}"
    fi
}

# Main execution
case "${1:-check}" in
    check)
        if [ "$DISABLE_GATES" = "1" ]; then
            echo -e "${YELLOW}⚠️ Quality gates disabled (BMAD_DISABLE_GATES=1)${NC}"
            exit 0
        fi
        
        echo -e "${CYAN}🎯 Running Quality Gate: No Dummy Content${NC}"
        
        if ! check_changed_files; then
            echo -e "\n${RED}❌ Quality Gate FAILED: Dummy content detected${NC}"
            echo -e "${YELLOW}Please remove placeholder/dummy content before committing${NC}"
            echo -e "${GRAY}Run with 'auto-fix' to attempt automatic fixes${NC}"
            exit 1
        fi
        
        echo -e "\n${GREEN}✅ Quality Gate PASSED: No dummy content detected${NC}"
        ;;
    
    status)
        show_quality_status
        ;;
    
    auto-fix)
        auto_fix_issues
        ;;
    
    *)
        echo "Unknown command: $1" >&2
        echo "Valid commands: check, status, auto-fix"
        exit 1
        ;;
esac
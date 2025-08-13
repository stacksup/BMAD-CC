#!/usr/bin/env bash
# Documentation Updater Hook for BMAD-CC
# Automatically updates documentation when tasks are completed

set -e

# Parameters
ACTION="${1:-update}"
TASK_ID="${2:-}"
TASK_TITLE="${3:-}"
CHANGE_TYPE="${4:-feature}"  # feature, fix, docs, refactor, test, chore

PROJECT_ROOT="$(pwd)"
CHANGELOG_PATH="$PROJECT_ROOT/CHANGELOG.md"
README_PATH="$PROJECT_ROOT/README.md"
STORY_NOTES_DIR="$PROJECT_ROOT/docs/story-notes"
TASKMASTER_CLI="task-master"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Ensure story-notes directory exists
mkdir -p "$STORY_NOTES_DIR"

# Function to get current date
get_current_date() {
    date "+%Y-%m-%d"
}

# Function to get task details
get_task_details() {
    local task_id="$1"
    
    if [ -z "$task_id" ]; then
        # Try to get current task from Task Master
        if command -v "$TASKMASTER_CLI" &> /dev/null; then
            local current_task=$($TASKMASTER_CLI current --json 2>/dev/null || true)
            if [ -n "$current_task" ] && [ "$current_task" != "No current task" ]; then
                # Parse JSON (basic extraction)
                local id=$(echo "$current_task" | grep -o '"id"[[:space:]]*:[[:space:]]*[^,}]*' | head -1 | sed 's/.*: *\([^,}]*\).*/\1/' | tr -d '"')
                local title=$(echo "$current_task" | grep -o '"title"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/')
                local description=$(echo "$current_task" | grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/')
                local status=$(echo "$current_task" | grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/')
                
                echo "$id|$title|$description|$status"
                return 0
            fi
        fi
    fi
    
    echo "$task_id|$TASK_TITLE||done"
}

# Function to get git changes
get_git_changes() {
    # Get list of changed files
    local changes=$(git diff --name-only HEAD~1 2>/dev/null || git diff --name-only --cached 2>/dev/null || true)
    echo "$changes"
}

# Function to get last commit
get_last_commit() {
    local commit_sha=$(git rev-parse HEAD 2>/dev/null || echo "")
    local commit_message=$(git log -1 --pretty=%B 2>/dev/null || echo "")
    
    echo "$commit_sha|$commit_message"
}

# Function to update changelog
update_changelog() {
    local task_info="$1"
    local change_type="$2"
    local commit_sha="$3"
    
    local task_id=$(echo "$task_info" | cut -d'|' -f1)
    local task_title=$(echo "$task_info" | cut -d'|' -f2)
    
    echo -e "${CYAN}📝 Updating CHANGELOG.md...${NC}"
    
    if [ ! -f "$CHANGELOG_PATH" ]; then
        # Create new changelog
        cat > "$CHANGELOG_PATH" <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
EOF
    fi
    
    # Ensure [Unreleased] section exists
    if ! grep -q "\[Unreleased\]" "$CHANGELOG_PATH"; then
        # Add unreleased section after first ## line
        sed -i '/^## /a\\n## [Unreleased]\n\n### Added\n### Changed\n### Fixed\n### Removed' "$CHANGELOG_PATH"
    fi
    
    # Determine the appropriate section
    local section
    case "$change_type" in
        "feature"|"feat") section="### Added" ;;
        "fix"|"bugfix") section="### Fixed" ;;
        "docs"|"documentation") section="### Changed" ;;
        "refactor"|"perf") section="### Changed" ;;
        "test") section="### Changed" ;;
        "chore") section="### Changed" ;;
        *) section="### Added" ;;
    esac
    
    # Create changelog entry
    local entry="- "
    if [ -n "$task_title" ]; then
        entry+="$task_title"
    else
        entry+="Task completed"
    fi
    
    if [ -n "$task_id" ]; then
        entry+=" (#$task_id)"
    fi
    
    if [ -n "$commit_sha" ]; then
        local short_sha=$(echo "$commit_sha" | cut -c1-7)
        entry+=" [$short_sha]"
    fi
    
    # Add entry to appropriate section
    local temp_file=$(mktemp)
    local found_section=false
    local added_entry=false
    
    while IFS= read -r line; do
        echo "$line" >> "$temp_file"
        
        if [ "$found_section" = false ] && echo "$line" | grep -q "^$section"; then
            found_section=true
        elif [ "$found_section" = true ] && [ "$added_entry" = false ]; then
            if echo "$line" | grep -q "^### " && ! echo "$line" | grep -q "^$section"; then
                # Found next section, add entry before it
                echo "$entry" >> "$temp_file"
                added_entry=true
            elif [ -z "$line" ]; then
                # Empty line in our section, add entry here
                echo "$entry" >> "$temp_file"
                added_entry=true
            fi
        fi
    done < "$CHANGELOG_PATH"
    
    # If we never added the entry, add it at the end
    if [ "$added_entry" = false ]; then
        echo "$entry" >> "$temp_file"
    fi
    
    mv "$temp_file" "$CHANGELOG_PATH"
    echo -e "${GREEN}✅ CHANGELOG.md updated${NC}"
}

# Function to create story notes
create_story_notes() {
    local task_info="$1"
    local commit_info="$2"
    
    local task_id=$(echo "$task_info" | cut -d'|' -f1)
    local task_title=$(echo "$task_info" | cut -d'|' -f2)
    local task_description=$(echo "$task_info" | cut -d'|' -f3)
    
    if [ -z "$task_id" ]; then
        echo -e "${YELLOW}⚠️ No task ID available for story notes${NC}"
        return 0
    fi
    
    local story_file="$STORY_NOTES_DIR/TASK-$task_id.md"
    local current_date=$(get_current_date)
    local commit_sha=$(echo "$commit_info" | cut -d'|' -f1)
    local commit_message=$(echo "$commit_info" | cut -d'|' -f2)
    
    echo -e "${CYAN}📋 Creating story notes: TASK-$task_id.md${NC}"
    
    cat > "$story_file" <<EOF
# Task $task_id: $task_title

**Completion Date:** $current_date
**Status:** Completed

## Task Summary
$task_description

## Implementation Notes
- Task completed successfully
- All requirements fulfilled
- Code changes committed

## Files Changed
\`\`\`
$(get_git_changes)
\`\`\`

## Commit Information
- **SHA:** $commit_sha
- **Message:** $commit_message

## Next Steps
- Task marked as complete
- Documentation updated
- Ready for testing/review

---
*Generated by BMAD Documentation Updater*
EOF
    
    echo -e "${GREEN}✅ Story notes created: $story_file${NC}"
}

# Function to update README if needed
update_readme_if_needed() {
    local task_info="$1"
    local changes="$2"
    
    local task_title=$(echo "$task_info" | cut -d'|' -f2)
    
    # Check if changes affect core functionality
    if echo "$changes" | grep -qE "(package\.json|requirements\.txt|README|docker|config)"; then
        echo -e "${YELLOW}💡 Consider updating README.md - core files were modified${NC}"
        
        # Check if README mentions recent updates
        if [ -f "$README_PATH" ]; then
            local last_update=$(grep -i "last updated\|updated:" "$README_PATH" | head -1 || true)
            if [ -z "$last_update" ]; then
                echo -e "${YELLOW}💡 Consider adding 'Last Updated' section to README.md${NC}"
            fi
        fi
    fi
}

# Function to show documentation status
show_documentation_status() {
    echo -e "\n${CYAN}📊 Documentation Status${NC}"
    echo "=================================="
    
    # Check CHANGELOG
    if [ -f "$CHANGELOG_PATH" ]; then
        if grep -q "\[Unreleased\]" "$CHANGELOG_PATH"; then
            echo -e "${GREEN}✅ CHANGELOG.md: Has [Unreleased] section${NC}"
        else
            echo -e "${YELLOW}⚠️ CHANGELOG.md: Missing [Unreleased] section${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ CHANGELOG.md: Missing${NC}"
    fi
    
    # Check README
    if [ -f "$README_PATH" ]; then
        echo -e "${GREEN}✅ README.md: Exists${NC}"
    else
        echo -e "${YELLOW}⚠️ README.md: Missing${NC}"
    fi
    
    # Check story notes
    local story_count=$(find "$STORY_NOTES_DIR" -name "TASK-*.md" 2>/dev/null | wc -l)
    echo -e "${GRAY}📋 Story Notes: $story_count files${NC}"
    
    echo "=================================="
}

# Main execution
case "$ACTION" in
    update)
        echo -e "${CYAN}🔄 Starting documentation update...${NC}"
        
        # Get task details
        local task_info=$(get_task_details "$TASK_ID")
        local commit_info=$(get_last_commit)
        local changes=$(get_git_changes)
        local commit_sha=$(echo "$commit_info" | cut -d'|' -f1)
        
        # Update documentation
        update_changelog "$task_info" "$CHANGE_TYPE" "$commit_sha"
        create_story_notes "$task_info" "$commit_info"
        update_readme_if_needed "$task_info" "$changes"
        
        echo -e "${GREEN}✅ Documentation update complete${NC}"
        ;;
    
    status)
        show_documentation_status
        ;;
    
    changelog)
        local task_info=$(get_task_details "$TASK_ID")
        local commit_info=$(get_last_commit)
        local commit_sha=$(echo "$commit_info" | cut -d'|' -f1)
        update_changelog "$task_info" "$CHANGE_TYPE" "$commit_sha"
        ;;
    
    story-notes)
        local task_info=$(get_task_details "$TASK_ID")
        local commit_info=$(get_last_commit)
        create_story_notes "$task_info" "$commit_info"
        ;;
    
    *)
        echo "Unknown action: $ACTION" >&2
        echo "Valid actions: update, status, changelog, story-notes"
        exit 1
        ;;
esac
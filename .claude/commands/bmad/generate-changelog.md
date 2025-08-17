---
description: Generate or update CHANGELOG.md for BMAD-CC based on git history and task completions
allowed-tools: Bash(git:*), Bash(task-master:*), Read, Write, Edit
---

# /bmad:generate-changelog

## CHANGELOG GENERATION & MAINTENANCE

This command generates or updates the project's CHANGELOG.md file based on git history, Task Master completions, and semantic versioning best practices.

## AUTOMATIC CHANGELOG GENERATION

### Analyze Git History
```bash
# Get commits since last release tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "initial")
if [ "$LAST_TAG" = "initial" ]; then
    COMMITS=$(git log --pretty=format:"%h|%s|%an|%ad" --date=short)
else
    COMMITS=$(git log ${LAST_TAG}..HEAD --pretty=format:"%h|%s|%an|%ad" --date=short)
fi

echo "ðŸ“ Analyzing commits since: $LAST_TAG"
```

### Categorize Changes
```bash
# Parse commits by conventional commit type
FEATURES=""
FIXES=""
DOCS=""
REFACTORS=""
TESTS=""
CHORES=""

while IFS='|' read -r sha message author date; do
    case "$message" in
        feat:*|feature:*)
            FEATURES="${FEATURES}- ${message#*:} ($sha)\\n"
            ;;
        fix:*|bugfix:*)
            FIXES="${FIXES}- ${message#*:} ($sha)\\n"
            ;;
        docs:*)
            DOCS="${DOCS}- ${message#*:} ($sha)\\n"
            ;;
        refactor:*)
            REFACTORS="${REFACTORS}- ${message#*:} ($sha)\\n"
            ;;
        test:*)
            TESTS="${TESTS}- ${message#*:} ($sha)\\n"
            ;;
        chore:*)
            CHORES="${CHORES}- ${message#*:} ($sha)\\n"
            ;;
        *)
            # Check for task references
            if echo "$message" | grep -q "\[task:"; then
                FEATURES="${FEATURES}- ${message} ($sha)\\n"
            else
                CHORES="${CHORES}- ${message} ($sha)\\n"
            fi
            ;;
    esac
done <<< "$COMMITS"
```

### Integration with Task Master
```bash
# Get completed tasks since last release
if command -v task-master &> /dev/null; then
    echo "ðŸ“‹ Fetching completed tasks from Task Master..."
    
    # Get tasks completed since last tag date
    if [ "$LAST_TAG" != "initial" ]; then
        TAG_DATE=$(git log -1 --format=%ai $LAST_TAG | cut -d' ' -f1)
        COMPLETED_TASKS=$(task-master list --status=done --since="$TAG_DATE" --json)
    else
        COMPLETED_TASKS=$(task-master list --status=done --json)
    fi
    
    # Add task completions to changelog
    if [ ! -z "$COMPLETED_TASKS" ]; then
        echo "âœ… Found completed tasks to include"
    fi
fi
```

## CHANGELOG FORMAT

### Generate Changelog Entry
**Load Documentation Agent:**
```
Load the doc-agent to generate professional changelog entries following Keep a Changelog format.
```

**Changelog Structure:**
```markdown
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features and capabilities
- [TASK-123] Feature description (commit-sha)

### Changed
- Changes in existing functionality
- Refactoring and improvements

### Deprecated
- Soon-to-be removed features
- Migration warnings

### Removed
- Removed features and files
- Deleted deprecated code

### Fixed
- Bug fixes and corrections
- [BUG-456] Issue resolution (commit-sha)

### Security
- Security patches and updates
- Vulnerability fixes

## [X.Y.Z] - YYYY-MM-DD
Previous releases...
```

## VERSION MANAGEMENT

### Determine Next Version
```bash
# Analyze changes to suggest version bump
determine_version_bump() {
    local current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
    local major=$(echo $current_version | cut -d. -f1)
    local minor=$(echo $current_version | cut -d. -f2)
    local patch=$(echo $current_version | cut -d. -f3)
    
    # Check for breaking changes
    if git log ${current_version}..HEAD --grep="BREAKING CHANGE" --oneline | grep -q .; then
        echo "$((major + 1)).0.0"
        return
    fi
    
    # Check for new features
    if git log ${current_version}..HEAD --grep="^feat" --oneline | grep -q .; then
        echo "${major}.$((minor + 1)).0"
        return
    fi
    
    # Default to patch
    echo "${major}.${minor}.$((patch + 1))"
}

NEXT_VERSION=$(determine_version_bump)
echo "ðŸ“¦ Suggested next version: $NEXT_VERSION"
```

## RELEASE PREPARATION

### Create Release Entry
When preparing a release:

1. **Move Unreleased to Version**
   ```bash
   # Update CHANGELOG.md with release version
   DATE=$(date +%Y-%m-%d)
   sed -i "s/## \[Unreleased\]/## [$NEXT_VERSION] - $DATE\n\n## [Unreleased]/" CHANGELOG.md
   ```

2. **Generate Release Notes**
   ```bash
   # Extract release notes for GitHub/GitLab
   awk "/## \[$NEXT_VERSION\]/,/## \[.*\]/" CHANGELOG.md > release-notes.md
   ```

3. **Create Git Tag**
   ```bash
   git add CHANGELOG.md
   git commit -m "chore: release version $NEXT_VERSION"
   git tag -a "v$NEXT_VERSION" -m "Release version $NEXT_VERSION"
   ```

## AUTOMATION OPTIONS

### Git Hook Integration
Add to `.git/hooks/post-commit`:
```bash
#!/bin/bash
# Auto-update CHANGELOG on commit
if [ -f ".claude/hooks/documentation-updater.sh" ]; then
    ./.claude/hooks/documentation-updater.sh -Action update
fi
```

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Update Changelog
  run: |
    claude-code /bmad:generate-changelog
    git add CHANGELOG.md
    git commit -m "docs: update changelog [skip ci]"
```

## INTERACTIVE MODE

### Review & Edit
**Process:**
1. Generate changelog entries automatically
2. Present to user for review
3. Allow manual edits and additions
4. Validate against Keep a Changelog format
5. Commit updated CHANGELOG.md

```bash
echo "ðŸ“ Changelog generated. Review and edit as needed."
echo "Press Enter to continue after review..."
read

# Validate changelog format
if grep -q "\[Unreleased\]" CHANGELOG.md; then
    echo "âœ… Changelog format validated"
else
    echo "âš ï¸  Missing [Unreleased] section"
fi
```

## BEST PRACTICES

### Commit Message Standards
Encourage conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `chore:` Maintenance tasks

### Task References
Include task IDs in commits:
- `feat: add user authentication [task: 23.1]`
- `fix: resolve login timeout [bug: 456]`

### Breaking Changes
Mark breaking changes clearly:
- Use `BREAKING CHANGE:` in commit body
- Document migration path
- Update major version

## SUCCESS METRICS

**Well-Maintained Changelog:**
- [ ] All user-visible changes documented
- [ ] Proper categorization (Added/Changed/Fixed/etc.)
- [ ] Links to issues and PRs included
- [ ] Follows semantic versioning
- [ ] Updated with every release
- [ ] Clear, concise descriptions
- [ ] Migration guides for breaking changes

Remember: A good CHANGELOG tells the story of your project's evolution and helps users understand what changed and why.
#!/usr/bin/env bash
# Simple, reliable BMAD-CC installer
# Usage: ./simple-install.sh /path/to/project

PROJECT_DIR="${1:-.}"
PROJECT_NAME="$(basename "$(realpath "$PROJECT_DIR")")"

echo "🚀 Installing BMAD-CC Framework"
echo "Target: $PROJECT_DIR"
echo "Project: $PROJECT_NAME"

# Ensure target directory exists and has .claude
mkdir -p "$PROJECT_DIR/.claude"/{agents,commands/bmad,hooks}
mkdir -p "$PROJECT_DIR/docs"/{lessons,story-notes}
mkdir -p "$PROJECT_DIR/scripts"

# Process templates directory by directory
echo "📦 Installing agents..."
for template in templates/.claude/agents/*.tmpl; do
    if [ -f "$template" ]; then
        target="$PROJECT_DIR/.claude/agents/$(basename "$template" .tmpl)"
        sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$template" > "$target"
        echo "  ✓ $(basename "$target")"
    fi
done

echo "📦 Installing commands..."
for template in templates/.claude/commands/bmad/*.tmpl; do
    if [ -f "$template" ]; then
        target="$PROJECT_DIR/.claude/commands/bmad/$(basename "$template" .tmpl)"
        sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$template" > "$target"
        echo "  ✓ $(basename "$target")"
    fi
done

echo "📦 Installing hooks..."
for template in templates/.claude/hooks/*.tmpl; do
    if [ -f "$template" ]; then
        target="$PROJECT_DIR/.claude/hooks/$(basename "$template" .tmpl)"
        sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$template" > "$target"
        chmod +x "$target"
        echo "  ✓ $(basename "$target")"
    fi
done

echo "📦 Installing settings..."
if [ -f "templates/.claude/settings.local.json.tmpl" ]; then
    sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" templates/.claude/settings.local.json.tmpl > "$PROJECT_DIR/.claude/settings.local.json"
    echo "  ✓ settings.local.json"
fi

echo "📦 Installing root files..."
for template in templates/root/*.tmpl; do
    if [ -f "$template" ]; then
        filename=$(basename "$template" .tmpl)
        # Handle special case for CLAUDE_APPEND.md -> append to CLAUDE.md
        if [ "$filename" = "CLAUDE_APPEND.md" ]; then
            if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
                echo "" >> "$PROJECT_DIR/CLAUDE.md"
                sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$template" >> "$PROJECT_DIR/CLAUDE.md"
                echo "  ✓ Appended to CLAUDE.md"
            else
                sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$template" > "$PROJECT_DIR/CLAUDE.md"
                echo "  ✓ Created CLAUDE.md"
            fi
        else
            target="$PROJECT_DIR/$filename"
            sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$template" > "$target"
            echo "  ✓ $filename"
        fi
    fi
done

# Count installed files
agents=$(find "$PROJECT_DIR/.claude/agents" -name "*.md" | wc -l)
commands=$(find "$PROJECT_DIR/.claude/commands/bmad" -name "*.md" | wc -l)
hooks=$(find "$PROJECT_DIR/.claude/hooks" -name "*.sh" | wc -l)

echo ""
echo "✅ BMAD-CC Framework installed successfully!"
echo "📊 Installed: $agents agents, $commands commands, $hooks hooks"
echo ""
echo "📋 Next steps:"
echo "1. Restart Claude Code"
echo "2. Run: /bmad:init-taskmaster"
echo "3. Start: /bmad:smart-cycle"
---
description: Initialize Task Master AI for BMAD-CC - Set up Task Master and parse initial requirements into tasks.
allowed-tools: Bash(task-master:*), Bash(npx task-master:*), Read, Grep, Glob, Write
---

# /bmad:init-taskmaster

## TASK MASTER INITIALIZATION FOR NEW PROJECTS

This command sets up Task Master AI for a new project and parses any existing requirements into an initial task backlog.

## PHASE 1: INSTALLATION CHECK

### 1A) Verify Task Master Installation
```bash
# Check if Task Master CLI is available
if ! command -v task-master &> /dev/null; then
    echo "❌ Task Master AI not installed. Installing now..."
    
    # Try global installation first
    npm install -g task-master-ai
    
    if [ $? -ne 0 ]; then
        echo "Global installation failed, trying local..."
        npm install task-master-ai
        
        # Use npx for local installation
        alias task-master="npx task-master"
    fi
fi

# Verify installation
task-master --version
if [ $? -ne 0 ]; then
    echo "❌ FATAL: Could not install Task Master AI"
    echo "Please install manually: npm install -g task-master-ai"
    exit 1
fi
```

## PHASE 2: PROJECT INITIALIZATION

### 2A) Initialize Task Master Project
```bash
# Check if already initialized
if [ -d ".taskmaster" ]; then
    echo "✅ Task Master already initialized"
    
    # Check if tasks exist
    TASK_COUNT=$(task-master list --json | jq '. | length')
    echo "Current tasks in backlog: $TASK_COUNT"
    
    if [ "$TASK_COUNT" -gt 0 ]; then
        echo "Tasks already exist. Use '/bmad:smart-cycle' to work on them."
        exit 0
    fi
else
    echo "📋 Initializing Task Master for BMAD-CC..."
    task-master init -y
    
    # Configure models per user's CLAUDE.md instructions
    task-master models --set-main opus
    task-master models --set-fallback sonnet
    
    echo "✅ Task Master initialized successfully"
fi
```

### 2B) Git Integration Check
```bash
# Ensure .taskmaster is tracked in git
if [ -f ".gitignore" ]; then
    # Check if tasks.json is ignored
    if grep -q "tasks.json" .gitignore; then
        echo "📝 Updating .gitignore to track Task Master tasks..."
        
        # Remove problematic ignores
        sed -i '/^tasks\.json$/d' .gitignore
        sed -i '/^tasks\/$/d' .gitignore
        
        # Add specific ignores for Task Master
        echo "" >> .gitignore
        echo "# Task Master - track tasks, ignore cache/reports" >> .gitignore
        echo ".taskmaster/reports/" >> .gitignore
        echo ".taskmaster/cache/" >> .gitignore
    fi
fi
```

## PHASE 3: REQUIREMENTS DISCOVERY

### 3A) Search for Requirements Documents
```bash
echo "🔍 Searching for requirements documents..."

# Priority order for PRD discovery
PRD_FOUND=""
PRD_FILE=""

# Check configured PRD path first
if [ -f "" ]; then
    PRD_FOUND="true"
    PRD_FILE=""
    echo "✅ Found configured PRD: $PRD_FILE"
    
# Check for secondary PRD
elif [ -f "" ] && [ "" != "" ]; then
    PRD_FOUND="true"
    PRD_FILE=""
    echo "✅ Found secondary PRD: $PRD_FILE"
    
# Check common PRD locations
elif [ -f "CLAUDE.md" ]; then
    PRD_FOUND="true"
    PRD_FILE="CLAUDE.md"
    echo "✅ Found CLAUDE.md with requirements"
    
elif [ -f "requirements.md" ]; then
    PRD_FOUND="true"
    PRD_FILE="requirements.md"
    echo "✅ Found requirements.md"
    
elif [ -f "docs/requirements.md" ]; then
    PRD_FOUND="true"
    PRD_FILE="docs/requirements.md"
    echo "✅ Found docs/requirements.md"
    
elif [ -f "docs/prd.md" ]; then
    PRD_FOUND="true"
    PRD_FILE="docs/prd.md"
    echo "✅ Found docs/prd.md"
    
elif [ -f "planning_docs/DEVELOPMENT_PLAN_PART1.md" ]; then
    PRD_FOUND="true"
    PRD_FILE="planning_docs/DEVELOPMENT_PLAN_PART1.md"
    echo "✅ Found development plan"
    
# Check if README has substantial requirements
elif [ -f "README.md" ]; then
    if grep -q "## Requirements\|## Features\|## User Stories\|## Tasks" README.md; then
        PRD_FOUND="true"
        PRD_FILE="README.md"
        echo "✅ Found requirements section in README.md"
    fi
fi

if [ -z "$PRD_FOUND" ]; then
    echo "⚠️ No requirements document found"
fi
```

## PHASE 4: TASK CREATION

### 4A) Parse PRD into Tasks
```bash
if [ ! -z "$PRD_FOUND" ]; then
    echo "📋 Parsing $PRD_FILE into Task Master tasks..."
    
    # Use force flag to ensure Opus model is used
    task-master parse-prd --input="$PRD_FILE" --force
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully parsed PRD into tasks"
        
        # Show task summary
        TASK_COUNT=$(task-master list --json | jq '. | length')
        echo "Created $TASK_COUNT tasks from PRD"
        
        # List top-level tasks
        echo ""
        echo "📋 Top-level tasks created:"
        task-master list --depth=1
        
    else
        echo "⚠️ Failed to parse PRD. Creating manual task..."
        task-master create --title="Parse and implement $PRD_FILE requirements" \
                                --description="Review $PRD_FILE and implement all requirements"
    fi
else
    echo "📝 No PRD found. Let's create initial tasks..."
fi
```

### 4B) Create Initial Tasks (No PRD)
**When no PRD exists, help create initial structure:**
```
If no PRD was found:
1. Ask user: "What type of project is this? (webapp/api/library/game/other)"
2. Ask user: "What is the main goal of this project?"
3. Create initial epic based on response
4. Suggest creating a PRD: "Should I help you create a requirements document first?"
```

```bash
# If no PRD, create initial project setup tasks
if [ -z "$PRD_FOUND" ]; then
    echo "Creating initial project setup tasks..."
    
    # Create setup epic
    task-master create --title="Project Setup and Planning" \
                            --description="Initial setup for BMAD-CC (other)" \
                            --type="epic" \
                            --priority=1
    
    # Get the created task ID
    SETUP_ID=$(task-master list --json | jq -r '.[0].id')
    
    # Expand into standard setup tasks
    task-master expand --id=$SETUP_ID --num=5 \
                            --prompt="Create tasks for: 1) Requirements gathering, 2) Architecture planning, 3) Development environment setup, 4) Initial implementation, 5) Testing setup"
    
    echo "✅ Created initial setup tasks"
fi
```

## PHASE 5: TASK EXPANSION

### 5A) Expand Complex Tasks
```bash
echo "🔍 Checking for tasks that need expansion..."

# Get all tasks that might need expansion
COMPLEX_TASKS=$(task-master list --json | jq -r '.[] | select(.complexity == "high" or .estimated_hours > 8) | .id')

if [ ! -z "$COMPLEX_TASKS" ]; then
    echo "Found complex tasks that should be broken down:"
    
    for TASK_ID in $COMPLEX_TASKS; do
        TASK_TITLE=$(task-master show $TASK_ID --json | jq -r '.title')
        echo "  - Task $TASK_ID: $TASK_TITLE"
        
        read -p "Expand this task into subtasks? (y/n): " EXPAND_CONFIRM
        if [ "$EXPAND_CONFIRM" = "y" ]; then
            read -p "How many subtasks? (3-10): " NUM_SUBTASKS
            task-master expand --id=$TASK_ID --num=$NUM_SUBTASKS
            echo "✅ Expanded task $TASK_ID into $NUM_SUBTASKS subtasks"
        fi
    done
fi
```

## PHASE 6: VERIFICATION & NEXT STEPS

### 6A) Verify Setup
```bash
echo ""
echo "========================================="
echo "✅ TASK MASTER SETUP COMPLETE"
echo "========================================="

# Show current status
TASK_COUNT=$(task-master list --json | jq '. | length')
TODO_COUNT=$(task-master list --status=todo --json | jq '. | length')

echo "📊 Project Status:"
echo "  - Total tasks: $TASK_COUNT"
echo "  - Ready to start: $TODO_COUNT"
echo "  - Task Master initialized: ✅"
echo "  - Models configured: Opus (main), Sonnet (fallback)"

# Show next task
NEXT_TASK=$(task-master next --json | jq -r '.title')
if [ ! -z "$NEXT_TASK" ] && [ "$NEXT_TASK" != "null" ]; then
    echo ""
    echo "📋 Next task: $NEXT_TASK"
fi
```

### 6B) Provide Next Actions
```bash
echo ""
echo "🚀 NEXT STEPS:"
echo "----------------------------------------"

if [ ! -z "$PRD_FOUND" ]; then
    echo "1. Review parsed tasks: task-master list --with-subtasks"
    echo "2. Start working: /bmad:smart-cycle"
    echo "3. Check progress: task-master stats"
else
    echo "1. Consider creating a PRD: /bmad:planning-cycle"
    echo "2. Or start with current tasks: /bmad:smart-cycle"
    echo "3. Add more tasks: task-master create --title='...'"
fi

echo ""
echo "📚 Useful Commands:"
echo "  - Work on next task: /bmad:smart-cycle"
echo "  - View all tasks: task-master list --with-subtasks"
echo "  - Get next task: task-master next"
echo "  - Update status: task-master set-status --id=X --status=Y"
echo "  - Track progress: task-master stats"
```

## ERROR HANDLING

### Installation Failures
```bash
# If npm install fails
if [ $? -ne 0 ]; then
    echo "❌ Failed to install Task Master AI"
    echo ""
    echo "Try these alternatives:"
    echo "1. Install globally with sudo: sudo npm install -g task-master-ai"
    echo "2. Use yarn: yarn global add task-master-ai"
    echo "3. Use local install: npm install task-master-ai"
    echo "4. Check npm/node installation: node --version && npm --version"
    exit 1
fi
```

### PRD Parsing Failures
```bash
# If parse-prd fails
if [ $? -ne 0 ]; then
    echo "⚠️ Failed to parse PRD automatically"
    echo "This might be because:"
    echo "1. The document format is not recognized"
    echo "2. The document is too large (>10000 tokens)"
    echo "3. The document lacks clear requirements"
    echo ""
    echo "Options:"
    echo "1. Create tasks manually: task-master create --title='...'"
    echo "2. Break PRD into sections and parse separately"
    echo "3. Create a simplified requirements.md and parse that"
fi
```

## SUCCESS CRITERIA

**Successful initialization means:**
- [ ] Task Master AI is installed and accessible
- [ ] Project is initialized with .taskmaster directory
- [ ] Models are configured (Opus main, Sonnet fallback)
- [ ] If PRD exists, it's parsed into tasks
- [ ] If no PRD, initial setup tasks are created
- [ ] Git is configured to track tasks
- [ ] User knows next steps to start working

Remember: This initialization only needs to run once per project. After this, use `/bmad:smart-cycle` for all development work.

---
description: Task Master AI integrated workflow for BMAD-CC - Work through tasks systematically with full BMAD agent coordination.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(task-master:*), Bash(npx task-master:*), Read, Grep, Glob, Edit, Write, Task
---

# /bmad:taskmaster-workflow

## TASK MASTER DRIVEN DEVELOPMENT

This workflow ensures all work is tracked and managed through Task Master AI as the single source of truth.

## PHASE 0: TASK MASTER INITIALIZATION

### 0A) Verify Task Master Installation
```bash
# Check Task Master availability (REQUIRED)
task-master --version
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Task Master AI is REQUIRED for BMAD workflows"
    echo "Install with: npm install -g task-master-ai"
    echo "Or locally: npm install task-master-ai"
    exit 1
fi
```

### 0B) Initialize Project (First Time Only)
```bash
# Check if .taskmaster directory exists
if [ ! -d ".taskmaster" ]; then
    echo "Initializing Task Master for project..."
    task-master init -y
    task-master models --set-main opus
    task-master models --set-fallback sonnet
fi
```

### 0C) Load Task Context
```bash
# Get current task or allow selection
CURRENT_TASK=$(task-master next --json)

if [ -z "$CURRENT_TASK" ]; then
    echo "No tasks available. Options:"
    echo "1. Parse PRD: task-master parse-prd --input=<file>"
    echo "2. Create task: task-master create --title='...'"
    echo "3. List all: task-master list --with-subtasks"
    
    # Allow user to specify task
    read -p "Enter task ID to work on (or 'new' to create): " TASK_INPUT
    
    if [ "$TASK_INPUT" = "new" ]; then
        # Create new task from user input
        echo "Creating new task..."
        # Orchestrator will handle task creation
    else
        CURRENT_TASK=$(task-master show $TASK_INPUT --json)
    fi
fi
```

## PHASE 1: TASK ANALYSIS & ROUTING

### 1A) Load Orchestrator with Task Context
**Load Master Orchestrator Agent:**
```
Load the orchestrator-agent with current task context from Task Master.
Pass CURRENT_TASK JSON to orchestrator for analysis.
```

**Task Complexity Assessment:**
1. **Simple Task (< 4 hours)**
   - Single story, no expansion needed
   - Route directly to implementation
   - Status: todo → in-progress → done

2. **Complex Task (4-40 hours)**
   - May need expansion into subtasks
   - Route through story creation
   - Status tracking per subtask

3. **Epic Task (> 40 hours)**
   - Requires expansion into multiple stories
   - Route through planning cycle first
   - Parent/child task tracking

### 1B) Task Expansion Decision
```bash
# For complex tasks, expand into subtasks
if [[ COMPLEXITY == "complex" || COMPLEXITY == "epic" ]]; then
    echo "Expanding task into subtasks..."
    task-master expand --id=$TASK_ID --num=$SUGGESTED_SUBTASKS
    
    # Get expanded subtasks
    task-master list --parent=$TASK_ID --with-subtasks
fi
```

## PHASE 2: STORY CREATION WITH TASK CONTEXT

### 2A) Scrum Master → Story Creation from Task
**Load Scrum Master Agent:**
```
Load the sm-agent with task details from Task Master.
```

**Story Creation Process:**
1. Extract requirements from task description
2. Reference task ID in story header
3. Create acceptance criteria from task details
4. Map subtasks to implementation tasks
5. Update task with story reference

**Task Status Update:**
```bash
# Mark task as in-progress when story creation starts
task-master set-status --id=$TASK_ID --status=in-progress
task-master update-task --id=$TASK_ID --prompt="Story creation started by SM agent"
```

### 2B) Story Validation with Task Reference
**Validation includes:**
- Task ID properly referenced
- Requirements match task description
- Subtasks properly mapped
- Acceptance criteria align with task

## PHASE 3: DEVELOPMENT WITH TASK TRACKING

### 3A) Developer → Implementation with Task Updates
**Load Developer Agent:**
```
Load the dev-agent with task ID and story reference.
```

**Development Process:**
```bash
# Set task to in-progress
task-master set-status --id=$TASK_ID --status=in-progress
task-master update-task --id=$TASK_ID --prompt="Development started"

# Implement feature
# ... development work ...

# Update task with progress
task-master update-task --id=$TASK_ID --prompt="Core functionality complete, writing tests"

# Link commit to task
git commit -m "feat: implement feature [task: $TASK_ID]"
COMMIT_SHA=$(git rev-parse HEAD)
task-master update-task --id=$TASK_ID --prompt="commit: $COMMIT_SHA"
```

### 3B) Subtask Management During Development
**For tasks with subtasks:**
```bash
# Work through subtasks systematically
for SUBTASK_ID in $(task-master list --parent=$TASK_ID --json | jq -r '.[].id'); do
    echo "Working on subtask: $SUBTASK_ID"
    
    # Set subtask in-progress
    task-master set-status --id=$SUBTASK_ID --status=in-progress
    
    # Implement subtask
    # ... implementation ...
    
    # Mark subtask done
    task-master set-status --id=$SUBTASK_ID --status=done
    task-master update-task --id=$SUBTASK_ID --prompt="Implementation complete"
done
```

## PHASE 4: TESTING & QUALITY ASSURANCE

### 4A) QA Engineer → Testing with Task Context
**Load QA Engineer Agent:**
```
Load the qa-agent with task and implementation details.
```

**QA Process:**
1. Review implementation against task requirements
2. Execute test suite
3. Validate acceptance criteria from task
4. Update task with QA results

```bash
# Update task with QA status
task-master update-task --id=$TASK_ID --prompt="QA Review: All tests passing, code quality approved"
```

## PHASE 5: COMPLETION & DOCUMENTATION

### 5A) Documentation Updates
**Documentation includes task reference:**
- Update CHANGELOG with task ID
- Reference task in story notes
- Link task in lessons learned

```bash
# Update task with documentation
task-master update-task --id=$TASK_ID --prompt="Documentation updated: CHANGELOG, story notes"
```

### 5B) Task Completion & GitHub Backup
```bash
# Mark task as done only when EVERYTHING is complete
task-master set-status --id=$TASK_ID --status=done
task-master update-task --id=$TASK_ID --prompt="Task complete. PR: #$PR_NUMBER merged"

# For parent tasks, ensure all subtasks are done
SUBTASKS=$(task-master list --parent=$TASK_ID --status=todo,in-progress,blocked)
if [ ! -z "$SUBTASKS" ]; then
    echo "⚠️ WARNING: Parent task has incomplete subtasks"
    echo "Complete all subtasks before marking parent done"
fi

# Automatic GitHub backup
echo "🔄 Backing up completed work to GitHub..."
./.claude/hooks/github-backup.ps1 backup
if [ $? -eq 0 ]; then
    echo "✅ Work backed up to GitHub"
else
    echo "⚠️ GitHub backup failed - run manually: git push origin main"
fi
```

## PHASE 6: CONTINUOUS TASK MANAGEMENT

### 6A) Get Next Task
```bash
# After completing current task, get next
NEXT_TASK=$(task-master next --json)

if [ ! -z "$NEXT_TASK" ]; then
    echo "Next task ready: $(echo $NEXT_TASK | jq -r '.title')"
    echo "Continue with: /bmad:taskmaster-workflow"
else
    echo "✅ All tasks complete! Current backlog is empty."
    echo "Options:"
    echo "1. Parse new PRD: task-master parse-prd --input=<file>"
    echo "2. Review completed: task-master list --status=done"
    echo "3. Check velocity: task-master stats"
fi
```

### 6B) Task Master Metrics
```bash
# Track progress and velocity
task-master stats
task-master list --status=done --since="1 week ago"
task-master list --status=blocked
```

## WORKFLOW COMMANDS REFERENCE

### Task Creation & Management
- `task-master create --title="..." --description="..."` - Create new task
- `task-master expand --id=<id> --num=<n>` - Break into subtasks
- `task-master set-status --id=<id> --status=<status>` - Update status
- `task-master update-task --id=<id> --prompt="..."` - Add notes

### Task Querying
- `task-master next` - Get next available task
- `task-master show <id>` - Show specific task
- `task-master list --with-subtasks` - List all tasks
- `task-master list --parent=<id>` - List subtasks
- `task-master list --status=<status>` - Filter by status

### PRD Integration
- `task-master parse-prd --input=<file>` - Parse PRD into tasks
- `task-master parse-prd --force` - Reparse with Opus model

### Metrics & Reporting
- `task-master stats` - Show velocity and metrics
- `task-master list --status=done --since="<date>"` - Completed tasks

## ERROR HANDLING

### Task Master Not Available
```bash
if ! command -v task-master &> /dev/null; then
    echo "❌ FATAL: Task Master AI is required but not installed"
    echo "This workflow cannot proceed without Task Master"
    echo "Install: npm install -g task-master-ai"
    exit 1
fi
```

### Task Blocked
```bash
# When encountering blockers
task-master set-status --id=$TASK_ID --status=blocked
task-master update-task --id=$TASK_ID --prompt="Blocked: [Describe blocker]"

# Create task for blocker resolution
task-master create --title="Resolve blocker for task $TASK_ID" \
                        --description="[Blocker details]" \
                        --priority=1
```

### Invalid Task State
```bash
# Validate task state before marking done
TASK_STATE=$(task-master show $TASK_ID --json | jq -r '.status')
if [[ "$TASK_STATE" != "in-progress" ]]; then
    echo "⚠️ WARNING: Task not in progress, may have been worked outside workflow"
    task-master update-task --id=$TASK_ID --prompt="State inconsistency detected"
fi
```

## SUCCESS CRITERIA

**Task Completion Requirements:**
- [ ] Task status is 'done' in Task Master
- [ ] All subtasks (if any) are 'done'
- [ ] Code is committed with task reference
- [ ] Tests are passing
- [ ] Documentation is updated
- [ ] PR is created/merged (if applicable)
- [ ] Task notes include implementation details

Remember: Task Master is the single source of truth. No work should be done without a task, and all tasks must be properly tracked through their lifecycle.

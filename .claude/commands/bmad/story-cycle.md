---
description: BMAD story development cycle for BMAD-CC (Framework) - Complete story implementation with Docker container management.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(task-master:*), Bash(npx task-master:*), Bash(pytest:*), Bash(docker:*), Bash(docker-compose:*), mcp__docker__list_containers, mcp__docker__get_container_logs, mcp__docker__execute_command
---

# /bmad:story-cycle

## DOCKER-BASED STORY DEVELOPMENT WORKFLOW

Complete story implementation from task assignment to deployment, with all development happening in Docker containers.

## PHASE 0: INFRASTRUCTURE SETUP

### 0A) Task Master Integration
```bash
# Get next task or specific task
STORY_ID=$(task-master next --field=id)
STORY_TITLE=$(task-master next --field=title)
echo "ðŸ“‹ Working on: $STORY_TITLE (ID: $STORY_ID)"

# Set task to in-progress
task-master set-status --id=$STORY_ID --status=in-progress
```

### 0B) Docker Environment Setup
```bash
# Ensure Docker is running
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "âŒ Docker not running. Starting Docker Desktop..."
    ./.claude/hooks/docker-manager.sh start
fi

# Start development containers
docker-compose up -d --build
echo "â³ Waiting for services to be healthy..."
sleep 5

# Verify health
./.claude/hooks/docker-manager.sh health
```

## PHASE 1: STORY CREATION & REFINEMENT

### 1A) Scrum Master â†’ Story Creation
**STEP 1 TRIGGER: Use Task tool to invoke sm-agent**
```
Use Task tool to invoke sm-agent to create or refine the user story.
Story must reference Task Master ID: $STORY_ID
```

**MANDATORY: Wait for SM agent completion confirmation before proceeding to validation.**

**Story Creation Process:**
1. Understand requirements from task description
2. Create comprehensive user story with acceptance criteria
3. Define Docker-based implementation approach
4. Identify container-specific dependencies
5. Update task with story location

**Quality Gate - Story Validation:**
```bash
# Automated validation hook with scoring
./.claude/hooks/validation-enforcer.sh -EventType "pre-story-development" -Context @{StoryId=$STORY_ID}

# Hook will:
# - Check for existing story validation report
# - Run automated validation if no report exists
# - Enforce minimum score of 7/10
# - Block workflow if validation fails
echo "âœ… Story validation passed - proceeding to development"
```

## PHASE 2: PRODUCT OWNER VALIDATION

### 2A) Product Owner â†’ Story Approval
**STEP 2 TRIGGER: Use Task tool to invoke po-agent**
```
Use Task tool to invoke po-agent to validate story completeness and alignment.
```

**MANDATORY: Wait for PO agent completion confirmation before proceeding to development.**

**Product Owner Validation Process:**
```bash
# Automated PO validation with comprehensive scoring
./.claude/hooks/validation-enforcer.sh -EventType "pre-story-development" -Context @{StoryId=$STORY_ID} -DocumentPath "docs/stories/story-$STORY_ID.md"

# Validation includes:
# - Docker environment requirements specified
# - Container health checks defined  
# - Test approach includes container testing
# - Deployment strategy considers containerization
# - Acceptance criteria completeness (automated scoring)
# - Technical feasibility assessment
echo "âœ… Product Owner validation completed"
```

## PHASE 3: DEVELOPMENT IN CONTAINERS

### 3A) Developer â†’ Implementation
**STEP 3 TRIGGER: Use Task tool to invoke dev-agent**
```
Use Task tool to invoke dev-agent for Docker-based implementation.
```

**MANDATORY: Wait for dev-agent completion confirmation before proceeding to QA.**

**CRITICAL DEVELOPMENT REMINDER:**
```
âš ï¸ NO DUMMY DATA OR FALLBACK IMPLEMENTATIONS ALLOWED!
- All features must use REAL data connections
- Failures must be VISIBLE, not hidden
- No catch blocks returning fake success
- No hardcoded test data in production code
```

**Docker Development Process:**
```bash
# All development happens in containers
echo "ðŸ³ Starting Docker-based development..."

# Install dependencies in container
docker-compose exec backend npm install [required-packages]
docker-compose exec frontend npm install [required-packages]

# Run development servers
docker-compose up -d

# Watch logs during development
docker-compose logs -f &
```

**Implementation Steps:**
1. **Code Development**:
   ```bash
   # Edit files on host, hot-reload in containers
   # Volumes mount source code into containers
   ```

2. **Run Tests in Containers**:
   ```bash
   docker-compose exec backend npm test
   docker-compose exec frontend npm test
   ```

3. **Database Operations**:
   ```bash
   docker-compose exec backend npm run migrate
   docker-compose exec db psql -U postgres
   ```

4. **Debug in Containers**:
   ```bash
   docker-compose exec backend /bin/bash
   docker-compose logs backend --tail=100
   ```

**Quality Gate - Implementation Validation:**
```bash
# Check for dummy data patterns FIRST
echo "ðŸ” Running no-dummy-data quality gate..."
./.claude/hooks/quality-gate-no-dummies.sh
if [ $? -ne 0 ]; then
    echo "âŒ Dummy data or fallback patterns detected!"
    echo "Fix all issues before proceeding"
    exit 1
fi

# Before marking development complete
docker-compose exec backend npm test
docker-compose exec backend npm run lint
docker-compose ps  # All containers healthy
```

## PHASE 4: QUALITY ASSURANCE IN DOCKER

### 4A) QA Engineer â†’ Docker-Based Testing
**STEP 4 TRIGGER: Use Task tool to invoke qa-agent**
```
Use Task tool to invoke qa-agent for containerized quality assurance.
```

**MANDATORY: Wait for qa-agent completion confirmation before proceeding to documentation.**

**Docker QA Process:**
```bash
# FIRST: Validate no dummy data patterns
echo "ðŸ” QA: Checking for dummy data and fallback patterns..."
./.claude/hooks/quality-gate-no-dummies.sh
if [ $? -ne 0 ]; then
    echo "âŒ QA FAILED: Dummy data or fallback implementations found!"
    echo "Returning to developer for fixes"
    exit 1
fi

# Run comprehensive tests in containers
docker-compose exec backend npm run test:unit
docker-compose exec backend npm run test:integration
docker-compose exec frontend npm run test:e2e

# Check container health
mcp__docker__list_containers
mcp__docker__get_container_stats --container_id=BMAD-CC_backend_1

# Review logs for errors
docker-compose logs --since 1h | grep -i error
```

**Performance Testing:**
```bash
# Load testing in containers
docker-compose exec backend npm run test:load

# Monitor resource usage
docker stats --no-stream
```

**Quality Gate - Definition of Done:**
```bash
# Automated DoD validation before story completion
./.claude/hooks/validation-enforcer.sh -EventType "pre-story-completion" -Context @{StoryId=$STORY_ID}

# Validation enforces:
# - All tests pass (minimum score 9/10)
# - No dummy data patterns detected
# - Docker health checks pass
# - Documentation updated
# - Acceptance criteria fully met
echo "âœ… Definition of Done validation passed"
```

**QA Decision:**
- **APPROVED**: All tests pass AND no dummy data patterns found AND DoD score â‰¥9/10
- **NEEDS_WORK**: Issues found, return to dev
- **AUTOMATIC REJECTION**: Any dummy data, mock implementations, or silent failures

## PHASE 5: DOCUMENTATION & LEARNINGS

### 5A) Documentation Agent â†’ Update Docs
**Load Documentation Agent:**
```
Load the doc-agent to update project documentation.
```

**Documentation Updates:**
- Update README with Docker setup instructions
- Document container architecture changes
- Update API documentation
- Add Docker troubleshooting guides

### 5B) Learnings Agent â†’ Capture Insights
**Load Learnings Agent:**
```
Load the learnings-agent to extract lessons learned.
```

**Capture Docker-specific learnings:**
- Container optimization techniques discovered
- Performance improvements found
- Docker troubleshooting solutions

## PHASE 6: GIT INTEGRATION & BACKUP

### 6A) Git Agent â†’ Commit and Push
**MANDATORY: Get user approval before proceeding to git operations.**
**STOP - USER APPROVAL REQUIRED**

**STEP 6 TRIGGER: Use Task tool to invoke git-agent**
```
Use Task tool to invoke git-agent for version control with Task Master integration.
```

**MANDATORY: Wait for git-agent completion confirmation before marking task complete.**

**Git Process with Docker:**
```bash
# Stage changes
git add -A

# Commit with task reference
git commit -m "feat: $STORY_TITLE [task: $STORY_ID]"

# Get commit SHA
COMMIT_SHA=$(git rev-parse HEAD)

# Push to GitHub
git push origin main

# Update task with commit
task-master update-task --id=$STORY_ID --prompt="commit: $COMMIT_SHA"
```

## PHASE 7: DOCKER DEPLOYMENT PREPARATION

### 7A) Build Production Images
```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Run production tests
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml exec backend npm test

# Tag images for deployment
docker tag BMAD-CC_backend:latest BMAD-CC_backend:$STORY_ID
docker tag BMAD-CC_frontend:latest BMAD-CC_frontend:$STORY_ID
```

### 7B) Container Health Verification
```bash
# Final health check
./.claude/hooks/docker-manager.sh health

# Verify all services responding
curl http://localhost:3000
curl http://localhost:8001/health
```

## PHASE 8: DOCUMENTATION & COMPLETION

### 8A) Automatic Documentation Updates
**Load Documentation Agent:**
```
Load the doc-agent to update all project documentation.
```

**Documentation Process:**
1. **Update CHANGELOG.md** with task completion
2. **Create story documentation** in docs/story-notes/
3. **Update README.md** if features added
4. **Update API docs** if endpoints changed
5. **Run documentation hook** for automation

**Automated Documentation Update:**
```bash
# Run documentation updater hook
./.claude/hooks/documentation-updater.sh -Action update \
    -TaskId "$STORY_ID" \
    -TaskTitle "$STORY_TITLE" \
    -ChangeType "feature"

echo "ðŸ“š Documentation updated automatically"
```

### 8B) Mark Task Complete
```bash
# Update task status
task-master set-status --id=$STORY_ID --status=done
task-master update-task --id=$STORY_ID --prompt="Story complete. Commit: $COMMIT_SHA. Docs updated."

# Clean up Docker resources
docker-compose down

echo "âœ… Story $STORY_ID complete with documentation!"
```

### 8C) Get Next Task
```bash
# Check for next task
NEXT_TASK=$(task-master next)
if [ ! -z "$NEXT_TASK" ]; then
    echo "ðŸ“‹ Next task available. Run: /bmad:story-cycle"
else
    echo "ðŸŽ‰ No more tasks! All caught up."
fi
```

## DOCKER TROUBLESHOOTING

### Common Issues During Development

**Container Won't Start:**
```bash
docker-compose logs [service]
docker-compose down -v
docker-compose up -d --build
```

**Tests Fail in Container:**
```bash
# Debug in container
docker-compose exec backend /bin/bash
npm test -- --verbose

# Check environment
docker-compose exec backend env
```

**Port Conflicts:**
```bash
# Find conflicting process
lsof -i :3000
lsof -i :8001

# Change ports in docker-compose.yml
```

**Performance Issues:**
```bash
# Check resource usage
docker stats
docker system df

# Clean up
docker system prune -a
```

## SUCCESS CRITERIA

**Story is complete when:**
- [ ] All acceptance criteria met
- [ ] Tests pass in Docker containers
- [ ] Container health checks pass
- [ ] Documentation updated
- [ ] Code committed with task reference
- [ ] Task marked done in Task Master
- [ ] GitHub backup complete
- [ ] Production images built and tested

## WORKFLOW COMMANDS

### Quick Commands
- `docker-compose up -d` - Start development
- `docker-compose logs -f` - Watch logs
- `docker-compose exec [service] [command]` - Run in container
- `docker-compose down` - Stop everything
- `./.claude/hooks/docker-manager.sh health` - Check health
- `./.claude/hooks/docker-manager.sh troubleshoot` - Debug issues

Remember: All development, testing, and validation happens inside Docker containers. Never install dependencies on the host machine.
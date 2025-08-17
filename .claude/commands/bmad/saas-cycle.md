---
description: BMAD cycle for BMAD-CC (Framework) with Docker start/verify.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(docker:*), Bash(docker-compose:*), Bash(task-master:*), Bash(npx task-master:*), Bash(pytest:*)
---

# /bmad:saas-cycle

## 0) Task Master (Start)
- task-master next (or show <ID>, list)
Capture STORY_ID/title/desc.

## 1) Docker Start
- If "docker-compose\.yml": docker-compose -f docker-compose\.yml up -d
  else: docker-compose up -d
- Health:
  - backend: http://localhost:8001/health (retry)
  - frontend: http://localhost:3000

## 2) SM â†’ 3) PO â†’ 4) User â†’ 5) Dev â†’ 6) QA

Follow standard story development flow as per story-cycle.

## 7) Documentation Updates

**Load Documentation Agent:**
```
Load the doc-agent to ensure comprehensive documentation updates.
```

**Automatic Documentation:**
```bash
# Run documentation updater
./.claude/hooks/documentation-updater.sh -Action update \
    -TaskId "$STORY_ID" \
    -TaskTitle "$STORY_TITLE" \
    -ChangeType "feature"
```

**Documentation Checklist:**
- [ ] CHANGELOG.md updated with task completion
- [ ] README.md updated if new features/dependencies
- [ ] Story notes created in docs/story-notes/
- [ ] API documentation updated if endpoints changed
- [ ] Docker documentation updated if containers modified

## 8) Learnings â†’ 9) Git

Capture lessons and commit changes with proper documentation.

## 10) Docker Verify & Restart
- Build:
  - if file set: docker-compose -f docker-compose\.yml build
  - else: docker-compose build
- Down/Up:
  - if file set: docker-compose -f docker-compose\.yml down && docker-compose -f docker-compose\.yml up -d
  - else: docker-compose down && docker-compose up -d
- Health:
  - backend: http://localhost:8001/health
  - frontend: http://localhost:3000

## 11) Task Master (End)
- task-master set-status --id=${STORY_ID} --status=done
- task-master update-task --id=${STORY_ID} --prompt="commit:${COMMIT_SHA}; pr:${PR_URL}"
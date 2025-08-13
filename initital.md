Here’s a single **copy-paste Markdown** you can save as your repo’s README and use to set everything up. It includes:

* The **repo layout**
* All **essential files** (with full contents)
* How to **bootstrap** any existing project (one-liner)
* How to **run** the tailored workflow afterward

> Replace `<YOU>` with your GitHub username or org.

---

# BMAD Framework (Universal) — Setup & Usage

A portable framework to install your BMAD development loop (agents, hooks, slash commands, Docker checks, Taskmaster integration, and the self-learning loop) into **any** project with a single command. After the first install, you run your normal `/bmad:*` commands inside the project.

---

## 0) Repo Structure

Create a new GitHub repo (e.g., `bmad-framework`) with this layout:

```
bmad-framework/
├── bootstrap.ps1
├── scripts/
│   └── setup.ps1
├── templates/
│   ├── .claude/
│   │   ├── agents/
│   │   │   ├── sm-agent.md.tmpl
│   │   │   ├── po-agent.md.tmpl
│   │   │   ├── dev-agent.md.tmpl
│   │   │   ├── qa-agent.md.tmpl
│   │   │   ├── doc-agent.md.tmpl
│   │   │   ├── learnings-agent.md.tmpl
│   │   │   └── git-agent.md.tmpl
│   │   ├── commands/
│   │   │   └── bmad/
│   │   │       ├── story-cycle.md.tmpl
│   │   │       └── saas-cycle.md.tmpl
│   │   ├── hooks/
│   │   │   ├── on-posttooluse.ps1.tmpl
│   │   │   └── gate-enforcer.ps1.tmpl
│   │   └── settings.local.json.tmpl
│   ├── docs/
│   │   ├── README_APPEND.md.tmpl
│   │   ├── lessons/README.md.tmpl
│   │   └── story-notes/README.md.tmpl
│   └── root/
│       ├── CLAUDE_APPEND.md.tmpl
│       └── CHANGELOG.md.tmpl
└── README.md
```

> The `.tmpl` files use simple tokens like `{{PROJECT_NAME}}` that the setup script replaces.

---

## 1) File: `bootstrap.ps1` (remote installer)

```powershell
<# bootstrap.ps1 — remote installer
   Usage (from any project):
   powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
#>

param()

function Install-BMAD {
  param(
    [string]$ProjectDir = ".",
    [ValidateSet("auto","saas","phaser","mobile","other")]
    [string]$ProjectType = "auto",
    [string]$PRDPath = "",
    [string]$SecondaryPRDPath = "",
    [string]$FrontendDir = "frontend",
    [string]$BackendDir = "backend",
    [int]$FrontendPort = 3000,
    [int]$BackendPort = 8001,
    [string]$DockerComposeFile = "",
    [string]$TaskmasterCLI = "task-master"
  )

  $ErrorActionPreference = "Stop"
  $repo = "https://github.com/<YOU>/bmad-framework.git"

  $ProjectName = Split-Path (Resolve-Path $ProjectDir) -Leaf

  if ($ProjectType -eq "auto") {
    if (Test-Path "$ProjectDir/frontend/package.json" -and (Test-Path "$ProjectDir/backend")) { $ProjectType = "saas" }
    elseif (Test-Path "$ProjectDir/src/client" -or Test-Path "$ProjectDir/package.json") { $ProjectType = "phaser" }
    else { $ProjectType = "other" }
  }

  if (-not $PRDPath) {
    if (Test-Path "$ProjectDir/planning_docs/DEVELOPMENT_PLAN_PART1.md") { $PRDPath = "planning_docs/DEVELOPMENT_PLAN_PART1.md" }
    elseif (Test-Path "$ProjectDir/CLAUDE.md") { $PRDPath = "CLAUDE.md" }
  }

  if (-not $DockerComposeFile) {
    if (Test-Path "$ProjectDir/docker-compose.full.yml") { $DockerComposeFile = "docker-compose.full.yml" }
    elseif (Test-Path "$ProjectDir/docker-compose.yml") { $DockerComposeFile = "docker-compose.yml" }
  }

  $tmp = Join-Path $env:TEMP ("bmadfw_" + [guid]::NewGuid().ToString("N"))
  git clone --depth 1 $repo $tmp | Out-Null

  $setup = Join-Path $tmp "scripts\setup.ps1"
  & powershell -ExecutionPolicy Bypass -NoProfile -File $setup `
    -ProjectDir $ProjectDir `
    -ProjectType $ProjectType `
    -ProjectName $ProjectName `
    -PRDPath $PRDPath `
    -SecondaryPRDPath $SecondaryPRDPath `
    -FrontendDir $FrontendDir `
    -BackendDir $BackendDir `
    -FrontendPort $FrontendPort `
    -BackendPort $BackendPort `
    -DockerComposeFile $DockerComposeFile `
    -TaskmasterCLI $TaskmasterCLI

  Remove-Item -Recurse -Force $tmp
  Write-Host "BMAD installed and tailored for '$ProjectName' ($ProjectType). Restart Claude Code to load new commands."
}

Export-ModuleMember -Function Install-BMAD
```

---

## 2) File: `scripts/setup.ps1` (templating copier)

```powershell
param(
  [string]$ProjectDir = ".",
  [string]$ProjectType,
  [string]$ProjectName,
  [string]$PRDPath,
  [string]$SecondaryPRDPath = "",
  [string]$FrontendDir = "frontend",
  [string]$BackendDir = "backend",
  [int]$FrontendPort = 3000,
  [int]$BackendPort = 8001,
  [string]$DockerComposeFile = "",
  [string]$TaskmasterCLI = "task-master"
)

$ErrorActionPreference = "Stop"

function Resolve-Default {
  param($val, $fallback) 
  if ([string]::IsNullOrWhiteSpace($val)) { return $fallback } else { return $val }
}

if (-not $ProjectName) { $ProjectName = Split-Path (Resolve-Path $ProjectDir) -Leaf }

if (-not $ProjectType) {
  if (Test-Path "$ProjectDir/frontend/package.json" -and Test-Path "$ProjectDir/backend") { $ProjectType = "saas" }
  elseif (Test-Path "$ProjectDir/src/client" -or Test-Path "$ProjectDir/package.json") { $ProjectType = "phaser" }
  else { $ProjectType = "other" }
}

if (-not $PRDPath) {
  if (Test-Path "$ProjectDir/planning_docs/DEVELOPMENT_PLAN_PART1.md") { $PRDPath = "planning_docs/DEVELOPMENT_PLAN_PART1.md" }
  elseif (Test-Path "$ProjectDir/CLAUDE.md") { $PRDPath = "CLAUDE.md" }
  else { $PRDPath = "" }
}

$FrontendPort = Resolve-Default $FrontendPort 3000
$BackendPort = Resolve-Default $BackendPort 8001

if (-not $DockerComposeFile) {
  if (Test-Path "$ProjectDir/docker-compose.full.yml") { $DockerComposeFile = "docker-compose.full.yml" }
  elseif (Test-Path "$ProjectDir/docker-compose.yml") { $DockerComposeFile = "docker-compose.yml" }
  else { $DockerComposeFile = "" }
}

$claudeDir = Join-Path $ProjectDir ".claude"
New-Item -ItemType Directory -Force -Path (Join-Path $claudeDir "agents") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $claudeDir "commands\bmad") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $claudeDir "hooks") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\lessons") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\story-notes") | Out-Null

function Apply-Template {
  param($TemplatePath, $DestPath)

  $content = Get-Content $TemplatePath -Raw

  $map = @{
    "{{PROJECT_NAME}}"       = $ProjectName
    "{{PROJECT_TYPE}}"       = $ProjectType
    "{{PRD_PATH}}"           = $PRDPath
    "{{SECONDARY_PRD_PATH}}" = $SecondaryPRDPath
    "{{FRONTEND_DIR}}"       = $FrontendDir
    "{{BACKEND_DIR}}"        = $BackendDir
    "{{FRONTEND_PORT}}"      = "$FrontendPort"
    "{{BACKEND_PORT}}"       = "$BackendPort"
    "{{DOCKER_COMPOSE_FILE}}"= $DockerComposeFile
    "{{TASKMASTER_CLI}}"     = $TaskmasterCLI
  }

  foreach ($k in $map.Keys) {
    $content = $content -replace [regex]::Escape($k), [regex]::Escape($map[$k]).Replace('\','\\')
  }

  $destDir = Split-Path $DestPath
  if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
  Set-Content -Path $DestPath -Value $content -Encoding UTF8
}

$frameworkRoot = Split-Path -Parent $PSCommandPath
$templatesRoot = Join-Path (Split-Path $frameworkRoot) "templates"

$map = @(
  @{ src = Join-Path $templatesRoot ".claude\agents\sm-agent.md.tmpl";        dst = Join-Path $claudeDir "agents\sm-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\po-agent.md.tmpl";        dst = Join-Path $claudeDir "agents\po-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\dev-agent.md.tmpl";       dst = Join-Path $claudeDir "agents\dev-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\qa-agent.md.tmpl";        dst = Join-Path $claudeDir "agents\qa-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\doc-agent.md.tmpl";       dst = Join-Path $claudeDir "agents\doc-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\learnings-agent.md.tmpl"; dst = Join-Path $claudeDir "agents\learnings-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\git-agent.md.tmpl";       dst = Join-Path $claudeDir "agents\git-agent.md" },

  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\story-cycle.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\story-cycle.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\saas-cycle.md.tmpl";  dst = Join-Path $claudeDir "commands\bmad\saas-cycle.md" },

  @{ src = Join-Path $templatesRoot ".claude\hooks\on-posttooluse.ps1.tmpl";  dst = Join-Path $claudeDir "hooks\on-posttooluse.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\gate-enforcer.ps1.tmpl";   dst = Join-Path $claudeDir "hooks\gate-enforcer.ps1" },

  @{ src = Join-Path $templatesRoot ".claude\settings.local.json.tmpl";       dst = Join-Path $claudeDir "settings.local.json" },

  @{ src = Join-Path $templatesRoot "root\CLAUDE_APPEND.md.tmpl";             dst = Join-Path $ProjectDir "CLAUDE.md" },
  @{ src = Join-Path $templatesRoot "root\CHANGELOG.md.tmpl";                 dst = Join-Path $ProjectDir "CHANGELOG.md" },

  @{ src = Join-Path $templatesRoot "docs\README_APPEND.md.tmpl";             dst = Join-Path $ProjectDir "docs\README.md" },
  @{ src = Join-Path $templatesRoot "docs\lessons\README.md.tmpl";            dst = Join-Path $ProjectDir "docs\lessons\README.md" },
  @{ src = Join-Path $templatesRoot "docs\story-notes\README.md.tmpl";        dst = Join-Path $ProjectDir "docs\story-notes\README.md" }
)

foreach ($item in $map) { if (Test-Path $item.src) { Apply-Template -TemplatePath $item.src -DestPath $item.dst } }

Write-Host "BMAD framework applied to $ProjectDir"
```

---

## 3) Templates (minimal, but functional)

### 3.1 `.claude/settings.local.json.tmpl`

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(node:*)",
      "Bash(npm:*)",
      "Bash(docker:*)",
      "Bash(docker-compose:*)",
      "Bash(powershell:*)",
      "Bash(pwsh:*)",
      "Bash({{TASKMASTER_CLI}}:*)",
      "Bash(npx task-master:*)",
      "Bash(python:*)",
      "Bash(pytest:*)",
      "Bash(jest:*)"
    ],
    "deny": []
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/on-posttooluse.ps1" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/gate-enforcer.ps1" }
        ]
      }
    ]
  }
}
```

### 3.2 `.claude/hooks/on-posttooluse.ps1.tmpl`

```powershell
$ErrorActionPreference = "SilentlyContinue"
Set-Location -Path (Get-Location)

if (Test-Path "{{FRONTEND_DIR}}\package.json") {
  Push-Location "{{FRONTEND_DIR}}"
  try { npm run -s lint | Out-Host } catch {}
  try { npm run -s typecheck | Out-Host } catch {}
  Pop-Location
}

if (Test-Path "{{BACKEND_DIR}}") {
  try { python --version | Out-Host } catch {}
}
exit 0
```

### 3.3 `.claude/hooks/gate-enforcer.ps1.tmpl`

```powershell
$ErrorActionPreference = "Stop"
if ($env:BMAD_DISABLE_GATES -eq "1") { Write-Output "Gates disabled."; exit 0 }

function Get-ChangedFiles {
  if (-not (git rev-parse --is-inside-work-tree 2>$null)) { return @() }
  $out = git diff --name-only
  if ($LASTEXITCODE -ne 0) { return @() }
  return $out -split "`n" | Where-Object { $_ -ne "" }
}

# TESTS + LINT
if ("{{PROJECT_TYPE}}" -eq "saas") {
  if (Test-Path "{{BACKEND_DIR}}") {
    Push-Location "{{BACKEND_DIR}}"
    python -m pytest -q
    if ($LASTEXITCODE -ne 0) { Write-Output "Backend tests failed"; exit 2 }
    Pop-Location
  }
  if (Test-Path "{{FRONTEND_DIR}}\package.json") {
    Push-Location "{{FRONTEND_DIR}}"
    npm run lint;      if ($LASTEXITCODE -ne 0) { Write-Output "Frontend lint failed"; exit 2 }
    npm run typecheck; if ($LASTEXITCODE -ne 0) { Write-Output "Frontend typecheck failed"; exit 2 }
    Pop-Location
  }
} else {
  if (Test-Path "package.json") {
    npm test
    if ($LASTEXITCODE -ne 0) { Write-Output "Tests failed"; exit 2 }
  }
}

# DOCS + LESSONS gates
$changed = Get-ChangedFiles
$codeChanged = $false
foreach ($f in $changed) {
  if ($f -match '^(backend|frontend|src|apps|packages)/') { $codeChanged = $true; break }
}

if ($codeChanged) {
  $hasDocs = $false
  foreach ($f in $changed) {
    if ($f -match '(^|/)CHANGELOG\.md' -or $f -match '^docs/story-notes/') { $hasDocs = $true; break }
  }
  if (-not $hasDocs) { Write-Output "Docs Gate failed."; exit 2 }

  $hasLesson = $false
  foreach ($f in $changed) {
    if ($f -match '^docs/lessons/') { $hasLesson = $true; break }
  }
  if (-not $hasLesson) { Write-Output "Learning Gate failed."; exit 2 }
}
exit 0
```

### 3.4 Agents (examples)

**`sm-agent.md.tmpl`**

```md
---
name: sm-agent
description: SM planning agent for {{PROJECT_NAME}} ({{PROJECT_TYPE}}).
tools: Read, Grep, Glob
---

ROLE
- Produce ONE Story package: STORY_ID, TITLE, SCOPE (≤ 1–2 days), ACCEPTANCE_CRITERIA (testable),
  DEV-TASKS (≤ 8 steps with file paths), VALIDATION-CHECKLIST (Gate 1), RELEVANT_LESSONS.

PLANNING (skim only if present)
- {{PRD_PATH}}
- {{SECONDARY_PRD_PATH}}

OUTPUT
- STORY_ID, TITLE, EPIC/DEPENDENCIES, SCOPE, ACCEPTANCE_CRITERIA, DEV-TASKS (backend/frontend paths),
  VALIDATION-CHECKLIST, RELEVANT_LESSONS (1–5 bullets with links).
```

**`po-agent.md.tmpl`**

```md
---
name: po-agent
description: Product Owner validator ({{PROJECT_NAME}}).
tools: Read, Grep, Glob
---

CHECKS
- Priorities respected; security/perf constraints OK; ACs testable.
- If architecture/policy changes: confirm no contradictions with {{PRD_PATH}} (skim relevant headings).

DECISION
- PO_APPROVED (notes) OR CHANGES_NEEDED (edits to SM).
```

**`dev-agent.md.tmpl`**

```md
---
name: dev-agent
description: Implement DEV-TASKS with tests; consult lessons first.
tools: Read, Edit, Write, Bash
---

PROCESS
1) Edit minimal code per DEV-TASKS.
2) Tests by type:
   - saas: backend pytest in {{BACKEND_DIR}}; frontend lint/typecheck in {{FRONTEND_DIR}}.
   - phaser: jest/ts-jest in repo root (or as configured).
   - mobile: unit/build tests as configured.
3) Fix red before next task.

NOTE
- Docker compile/health verification occurs post-commit in the cycle command.
```

**`qa-agent.md.tmpl`**

```md
---
name: qa-agent
description: Senior review; targeted refactor; strengthen tests; QA_NOTES.
tools: Read, Edit, Write, Bash
---

STEPS
- Run tests per project type.
- Strengthen tests in impacted areas.
- QA_NOTES: issues found, fixes applied, prevent-next-time bullets.

DECISION
- QA_APPROVED (with notes) OR NEEDS_DEV_WORK (explicit diffs/tests).
```

**`doc-agent.md.tmpl`**

```md
---
name: doc-agent
description: Update CHANGELOG, README (if needed), and docs/story-notes/STORY_ID.md.
tools: Read, Edit, Write
---

ACTIONS
1) CHANGELOG.md: [STORY_ID] TITLE — summary, modules touched, test summary.
2) README: update if behavior changed.
3) docs/story-notes/STORY_ID.md: context, decisions, links (commit/PR placeholders), follow-ups.
```

**`learnings-agent.md.tmpl`**

```md
---
name: learnings-agent
description: Extract actionable lessons; write docs/lessons/ID.md; propose systemic edits.
tools: Read, Edit, Write, Grep, Glob
---

INPUTS
- QA_NOTES, failing test outputs, gate failures, CHANGELOG delta, story notes, paths touched, test names.

OUTPUTS
1) docs/lessons/STORY_ID.md:
   - Title, Summary, Triggers (tags), Anti-pattern, Correct pattern, Snippets, References.
   - Where to surface: {when:["SM","DEV"], contexts:["backend/*","frontend/*","tests/*","src/*"]}

2) Optional: proposed patches for CLAUDE.md or .claude/playbooks/* when systemic.
```

**`git-agent.md.tmpl`**

```md
---
name: git-agent
description: Stage & commit; optional push/PR; output commit SHA and PR URL.
tools: Bash
---

STEPS
- git add -A
- git status
- git commit -m "STORY ${STORY_ID}: ${TITLE} (docs/lessons & changelog updated)"
- $BRANCH = $(git rev-parse --abbrev-ref HEAD)
- [Optional] git push origin "$BRANCH"
- [Optional] gh pr create -t "STORY ${STORY_ID}: ${TITLE}" -b "See CHANGELOG and docs/story-notes/${STORY_ID}.md; lessons at docs/lessons/${STORY_ID}.md"

OUTPUT
- Print commit SHA and PR URL (if created).
```

### 3.5 Commands (two variants)

**`story-cycle.md.tmpl`** (generic/Framework/etc.)

```md
---
description: BMAD cycle for {{PROJECT_NAME}} ({{PROJECT_TYPE}}).
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(powershell:*), Bash(pwsh:*), Bash({{TASKMASTER_CLI}}:*), Bash(npx task-master:*), Bash(pytest:*), Bash(docker:*), Bash(docker-compose:*)
---

# /bmad:story-cycle

## 0) Task Master (Start)
- {{TASKMASTER_CLI}} next (or show <ID>, list)
Capture STORY_ID/title/desc.

## 1) SM → 2) PO → 3) User → 4) Dev → 5) QA → 6) Docs → 7) Learnings → 8) Git (per agents)

## 9) Task Master (End)
- {{TASKMASTER_CLI}} set-status --id=${STORY_ID} --status=done
- {{TASKMASTER_CLI}} update-task --id=${STORY_ID} --prompt="commit:${COMMIT_SHA}; pr:${PR_URL}"
```

**`saas-cycle.md.tmpl`** (Docker start + end verify)

```md
---
description: BMAD cycle for {{PROJECT_NAME}} ({{PROJECT_TYPE}}) with Docker start/verify.
allowed-tools: Bash(git:*), Bash(node:*), Bash(npm:*), Bash(powershell:*), Bash(pwsh:*), Bash(docker:*), Bash(docker-compose:*), Bash({{TASKMASTER_CLI}}:*), Bash(npx task-master:*), Bash(pytest:*)
---

# /bmad:saas-cycle

## 0) Task Master (Start)
- {{TASKMASTER_CLI}} next (or show <ID>, list)
Capture STORY_ID/title/desc.

## 1) Docker Start
- If "{{DOCKER_COMPOSE_FILE}}": docker-compose -f {{DOCKER_COMPOSE_FILE}} up -d
  else: docker-compose up -d
- Health:
  - backend: http://localhost:{{BACKEND_PORT}}/health (retry)
  - frontend: http://localhost:{{FRONTEND_PORT}}

## 2) SM → 3) PO → 4) User → 5) Dev → 6) QA → 7) Docs → 8) Learnings → 9) Git

## 10) Docker Verify & Restart
- Build:
  - if file set: docker-compose -f {{DOCKER_COMPOSE_FILE}} build
  - else: docker-compose build
- Down/Up:
  - if file set: docker-compose -f {{DOCKER_COMPOSE_FILE}} down && docker-compose -f {{DOCKER_COMPOSE_FILE}} up -d
  - else: docker-compose down && docker-compose up -d
- Health:
  - backend: http://localhost:{{BACKEND_PORT}}/health
  - frontend: http://localhost:{{FRONTEND_PORT}}

## 11) Task Master (End)
- {{TASKMASTER_CLI}} set-status --id=${STORY_ID} --status=done
- {{TASKMASTER_CLI}} update-task --id=${STORY_ID} --prompt="commit:${COMMIT_SHA}; pr:${PR_URL}"
```

### 3.6 Docs templates

**`root/CLAUDE_APPEND.md.tmpl`**

```md
## Documentation Policy (MANDATORY)
- Update CHANGELOG.md each cycle.
- Update README if behavior changed.
- Create/refresh docs/story-notes/<STORY_ID>.md.

## Learnings Policy (MANDATORY)
- Write docs/lessons/<STORY_ID>.md each cycle.
- If systemic, propose patches to CLAUDE.md or .claude/playbooks/*.

## Plan Docs (light touch)
- If available, skim {{PRD_PATH}} {{SECONDARY_PRD_PATH}} for relevant headings only.
```

**`root/CHANGELOG.md.tmpl`**

```md
# CHANGELOG

- Initial BMAD framework installed for {{PROJECT_NAME}} ({{PROJECT_TYPE}})
```

**`docs/README_APPEND.md.tmpl`**

```md
# docs/

- story-notes/: per-story implementation notes
- lessons/: short, actionable lessons captured each cycle
```

**`docs/lessons/README.md.tmpl`**

```md
# lessons

Each file: <STORY_ID>.md
- Summary, Triggers (tags), Anti-pattern, Correct pattern, Snippets, References.
- Where to surface: { when: ["SM","DEV"], contexts: [...] }
```

**`docs/story-notes/README.md.tmpl`**

```md
# story-notes

Per-story context/decisions, plus links to commit/PR.
```

---

## 4) Commit & push your framework repo

```bash
git init
git add .
git commit -m "BMAD framework initial commit"
git branch -M main
git remote add origin https://github.com/<YOU>/bmad-framework.git
git push -u origin main
```

---

## 5) Apply BMAD to any existing project (first time)

Open the target project folder and run **one of these** in PowerShell (inside Claude Code terminal or your system terminal):

**Auto-detect project type:**

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
```

**Explicit SaaS example:**

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType saas -PRDPath CLAUDE.md -FrontendDir frontend -BackendDir backend -FrontendPort 3000 -BackendPort 8001 -DockerComposeFile docker-compose.full.yml -TaskmasterCLI 'npx task-master'"
```

This will:

* Copy `.claude/agents`, `.claude/commands/bmad`, `.claude/hooks`, `.claude/settings.local.json`
* Create `docs/lessons`, `docs/story-notes`, `CHANGELOG.md`, `CLAUDE.md` (appending policies)
* Tailor content based on variables and heuristics

**Then restart Claude Code** so it picks up the new commands:

```
/quit
claude
/settings
```

---

## 6) Daily usage in the project

* SaaS (Docker start & end verify):

  ```
  /bmad:saas-cycle
  ```
* Generic/Framework/etc.:

  ```
  /bmad:story-cycle
  ```

The cycle performs:

* Taskmaster → SM → PO → User approve → Dev (tests/linters) → QA → Docs (CHANGELOG + story-notes) → Learnings (docs/lessons) → Git (commit/+PR) → (SaaS: Docker build/down/up + health) → Taskmaster done.

> Gates enforce tests+lint and docs+lessons whenever code changes.

---

## 7) Optional: add a local “init” slash command for future repos

If you like, your framework can also drop this file so later you can run `/bmad:init`:

**(in target repo after first run)**
`.claude/commands/bmad/init.md`:

```md
---
description: Initialize BMAD framework (remote bootstrap).
allowed-tools: Bash(git:*), Bash(powershell:*), Bash(pwsh:*)
---

# /bmad:init
- powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
```

---

## 8) Notes

* This pattern is **per-repo** (Claude Code reads commands from `.claude/commands`), so the remote bootstrap is the cleanest way to make it “universal” without copying files first.
* If your ports or compose files differ, pass parameters in the one-liner.
* You can expand templates to add a `mobile-cycle` or any project-type-specific commands easily.

---

**Done.** If you want me to pre-fill the templates with your exact defaults (ports, compose file names, Taskmaster CLI alias), say the word and I’ll customize them.

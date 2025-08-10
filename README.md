# BMAD Framework (Universal) — Setup & Usage

A portable framework to install your BMAD development loop (agents, hooks, slash commands, Docker checks, Taskmaster integration, and the self-learning loop) into **any** project with a single command. After the first install, you run your normal `/bmad:*` commands inside the project.

> **IMPORTANT**: Replace `<YOU>` throughout this document with your GitHub username or organization name.

---

## 0) Repo Structure

This repository contains:

```
bmad-framework/
├── bootstrap.ps1                    # Remote installer script
├── scripts/
│   └── setup.ps1                    # Templating engine
├── templates/
│   ├── .claude/
│   │   ├── agents/                 # Agent templates (SM, PO, Dev, QA, Doc, Learnings, Git)
│   │   ├── commands/bmad/          # Slash command templates
│   │   ├── hooks/                  # Hook scripts
│   │   └── settings.local.json.tmpl
│   ├── docs/                       # Documentation templates
│   └── root/                       # Root file templates
└── README.md                        # This file
```

---

## 1) Initial Setup (Fork and Configure)

1. **Fork this repository** or create your own copy
2. **Clone your fork locally**:
   ```bash
   git clone https://github.com/<YOU>/bmad-framework.git
   cd bmad-framework
   ```

3. **Update the GitHub references**:
   - In `bootstrap.ps1`, replace both occurrences of `<YOU>` with your GitHub username
   - Commit and push your changes:
   ```bash
   git add .
   git commit -m "Configure for my GitHub account"
   git push origin main
   ```

---

## 2) Apply BMAD to Any Project

Open the target project folder and run **one of these** in PowerShell (inside Claude Code terminal or your system terminal):

### Auto-detect project type:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
```

### Explicit SaaS example:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType saas -PRDPath CLAUDE.md -FrontendDir frontend -BackendDir backend -FrontendPort 3000 -BackendPort 8001 -DockerComposeFile docker-compose.full.yml -TaskmasterCLI 'npx task-master'"
```

### Available Parameters:

- `ProjectDir`: Target project directory (default: current directory)
- `ProjectType`: `auto`, `saas`, `phaser`, `mobile`, `other`
- `PRDPath`: Path to primary planning document
- `SecondaryPRDPath`: Path to secondary planning document
- `FrontendDir`: Frontend directory name (default: `frontend`)
- `BackendDir`: Backend directory name (default: `backend`)
- `FrontendPort`: Frontend port (default: `3000`)
- `BackendPort`: Backend port (default: `8001`)
- `DockerComposeFile`: Docker compose file to use
- `TaskmasterCLI`: Task Master CLI command (default: `task-master`)

### What happens:

- Copies and customizes `.claude/agents`, `.claude/commands/bmad`, `.claude/hooks`, `.claude/settings.local.json`
- Creates `docs/lessons`, `docs/story-notes`, `CHANGELOG.md`, `CLAUDE.md` (appending policies)
- Tailors content based on project type and configuration

**Then restart Claude Code** to load the new commands:

```
/quit
claude
/settings
```

---

## 3) Daily Usage

Once installed in a project, use these commands:

### SaaS Projects (with Docker):
```
/bmad:saas-cycle
```

### Other Projects:
```
/bmad:story-cycle
```

### The cycle performs:

1. **Task Master** → Get next task
2. **SM Agent** → Story planning
3. **PO Agent** → Product validation
4. **User Approval** → Manual checkpoint
5. **Dev Agent** → Implementation with tests
6. **QA Agent** → Review and strengthen
7. **Doc Agent** → Update CHANGELOG and story notes
8. **Learnings Agent** → Extract lessons
9. **Git Agent** → Commit and optional PR
10. **Docker** (SaaS only) → Build, restart, health check
11. **Task Master** → Mark complete

### Gates enforce:
- Tests and linting on all code changes
- Documentation updates (CHANGELOG, story-notes)
- Lesson extraction (docs/lessons)

---

## 4) Project Types

### SaaS
- Frontend/backend architecture
- Docker compose integration
- Separate test runners (pytest, jest)
- Health check endpoints

### Phaser
- Game development focused
- Single package.json
- Jest/ts-jest testing

### Mobile
- React Native or similar
- Build and unit tests

### Other
- Generic project structure
- Flexible testing approach

---

## 5) Customization

### Adding New Agents

1. Create new template in `templates/.claude/agents/`
2. Update `scripts/setup.ps1` to include it
3. Reference in cycle commands as needed

### Adding New Commands

1. Create template in `templates/.claude/commands/bmad/`
2. Update `scripts/setup.ps1` to include it
3. Restart Claude Code after installation

### Modifying Hooks

Edit templates in `templates/.claude/hooks/`:
- `on-posttooluse.ps1.tmpl`: Runs after file edits
- `gate-enforcer.ps1.tmpl`: Enforces quality gates

---

## 6) Troubleshooting

### Command not found after installation
- Restart Claude Code: `/quit` then `claude`

### Gates failing
- Set `$env:BMAD_DISABLE_GATES = "1"` to temporarily disable
- Ensure tests pass and docs are updated

### Docker issues (SaaS)
- Verify Docker Desktop is running
- Check port availability
- Review docker-compose file path

---

## 7) Contributing

Feel free to:
- Add new project type templates
- Enhance agent behaviors
- Improve gate logic
- Add more slash commands

Submit PRs with:
- Clear description of changes
- Test coverage where applicable
- Documentation updates

---

## 8) License

MIT - Use freely, modify as needed

---

## 9) Quick Reference

```powershell
# Install (first time, from target project)
powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/<YOU>/bmad-framework/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"

# Daily workflow (after installation)
/bmad:saas-cycle    # For SaaS projects
/bmad:story-cycle   # For other projects

# Environment variables
$env:BMAD_DISABLE_GATES = "1"  # Disable quality gates temporarily
```

---

**Remember**: Replace `<YOU>` with your actual GitHub username before using!
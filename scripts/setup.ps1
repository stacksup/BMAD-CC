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
  if ((Test-Path "$ProjectDir/frontend/package.json") -and (Test-Path "$ProjectDir/backend")) { $ProjectType = "saas" }
  elseif ((Test-Path "$ProjectDir/src/client") -or (Test-Path "$ProjectDir/package.json")) { $ProjectType = "phaser" }
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
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\lessons\templates") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\lessons\project-implementation") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\lessons\bmad-workflow") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\lessons\technology-patterns") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\lessons\troubleshooting") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "scripts\lessons") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\story-notes") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\templates") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\validation") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir "docs\data") | Out-Null

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
    "{{DATE}}"               = (Get-Date -Format "yyyy-MM-dd")
    "{{AGENT_NAME}}"         = "System Setup"
  }

  foreach ($k in $map.Keys) {
    $content = $content -replace [regex]::Escape($k), [regex]::Escape($map[$k])
  }

  $destDir = Split-Path $DestPath
  if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
  Set-Content -Path $DestPath -Value $content -Encoding UTF8NoBOM
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
  @{ src = Join-Path $templatesRoot ".claude\agents\architect-agent.md.tmpl"; dst = Join-Path $claudeDir "agents\architect-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\pm-agent.md.tmpl";        dst = Join-Path $claudeDir "agents\pm-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\ux-agent.md.tmpl";        dst = Join-Path $claudeDir "agents\ux-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\analyst-agent.md.tmpl";   dst = Join-Path $claudeDir "agents\analyst-agent.md" },
  @{ src = Join-Path $templatesRoot ".claude\agents\orchestrator-agent.md.tmpl"; dst = Join-Path $claudeDir "agents\orchestrator-agent.md" },

  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\story-cycle.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\story-cycle.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\saas-cycle.md.tmpl";  dst = Join-Path $claudeDir "commands\bmad\saas-cycle.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\smart-cycle.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\smart-cycle.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\planning-cycle.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\planning-cycle.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\maintenance-cycle.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\maintenance-cycle.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\greenfield-fullstack.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\greenfield-fullstack.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\brownfield-enhancement.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\brownfield-enhancement.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\taskmaster-workflow.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\taskmaster-workflow.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\init-taskmaster.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\init-taskmaster.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\github-setup.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\github-setup.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\docker.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\docker.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\generate-changelog.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\generate-changelog.md" },
  @{ src = Join-Path $templatesRoot ".claude\commands\bmad\shard-document.md.tmpl"; dst = Join-Path $claudeDir "commands\bmad\shard-document.md" },

  @{ src = Join-Path $templatesRoot ".claude\hooks\on-posttooluse.ps1.tmpl";  dst = Join-Path $claudeDir "hooks\on-posttooluse.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\gate-enforcer.ps1.tmpl";   dst = Join-Path $claudeDir "hooks\gate-enforcer.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\validation-enforcer.ps1.tmpl"; dst = Join-Path $claudeDir "hooks\validation-enforcer.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\taskmaster-check.ps1.tmpl"; dst = Join-Path $claudeDir "hooks\taskmaster-check.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\github-backup.ps1.tmpl"; dst = Join-Path $claudeDir "hooks\github-backup.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\docker-manager.ps1.tmpl"; dst = Join-Path $claudeDir "hooks\docker-manager.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\documentation-updater.ps1.tmpl"; dst = Join-Path $claudeDir "hooks\documentation-updater.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\quality-gate-no-dummies.ps1.tmpl"; dst = Join-Path $claudeDir "hooks\quality-gate-no-dummies.ps1" },

  @{ src = Join-Path $templatesRoot ".claude\settings.local.json.tmpl";       dst = Join-Path $claudeDir "settings.local.json" },

  @{ src = Join-Path $templatesRoot "root\CLAUDE_APPEND.md.tmpl";             dst = Join-Path $ProjectDir "CLAUDE.md" },
  @{ src = Join-Path $templatesRoot "root\CHANGELOG.md.tmpl";                 dst = Join-Path $ProjectDir "CHANGELOG.md" },

  @{ src = Join-Path $templatesRoot "docs\README_APPEND.md.tmpl";             dst = Join-Path $ProjectDir "docs\README.md" },
  @{ src = Join-Path $templatesRoot "docs\lessons\README.md.tmpl";            dst = Join-Path $ProjectDir "docs\lessons\README.md" },
  @{ src = Join-Path $templatesRoot "docs\story-notes\README.md.tmpl";        dst = Join-Path $ProjectDir "docs\story-notes\README.md" },

  @{ src = Join-Path $templatesRoot "docs\project-brief.md.tmpl";             dst = Join-Path $ProjectDir "docs\templates\project-brief.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\product-requirements-document.md.tmpl"; dst = Join-Path $ProjectDir "docs\templates\product-requirements-document.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\architecture-specification.md.tmpl"; dst = Join-Path $ProjectDir "docs\templates\architecture-specification.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\ux-design-specification.md.tmpl";   dst = Join-Path $ProjectDir "docs\templates\ux-design-specification.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\story-template.md.tmpl";            dst = Join-Path $ProjectDir "docs\templates\story-template.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\elicitation-framework.md.tmpl";     dst = Join-Path $ProjectDir "docs\templates\elicitation-framework.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\change-checklist.md.tmpl";          dst = Join-Path $ProjectDir "docs\templates\change-checklist.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\story-validation-template.md.tmpl"; dst = Join-Path $ProjectDir "docs\templates\story-validation-template.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\bmad-tasks-integration.md.tmpl";    dst = Join-Path $ProjectDir "docs\templates\bmad-tasks-integration.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\architect-checklist.md.tmpl";       dst = Join-Path $ProjectDir "docs\templates\architect-checklist.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\pm-checklist.md.tmpl";              dst = Join-Path $ProjectDir "docs\templates\pm-checklist.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\po-master-checklist.md.tmpl";       dst = Join-Path $ProjectDir "docs\templates\po-master-checklist.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\story-draft-checklist.md.tmpl";     dst = Join-Path $ProjectDir "docs\templates\story-draft-checklist.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\story-dod-checklist.md.tmpl";       dst = Join-Path $ProjectDir "docs\templates\story-dod-checklist.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\no-fallback-policy.md.tmpl";        dst = Join-Path $ProjectDir "docs\no-fallback-policy.md" },
  @{ src = Join-Path $templatesRoot "docs\expansion-packs.md.tmpl";           dst = Join-Path $ProjectDir "docs\expansion-packs.md" },
  
  @{ src = Join-Path $templatesRoot "data\elicitation-methods.md.tmpl";       dst = Join-Path $ProjectDir "docs\data\elicitation-methods.md" },
  @{ src = Join-Path $templatesRoot "data\brainstorming-techniques.md.tmpl"; dst = Join-Path $ProjectDir "docs\data\brainstorming-techniques.md" },
  @{ src = Join-Path $templatesRoot "data\technical-preferences.md.tmpl";     dst = Join-Path $ProjectDir "docs\data\technical-preferences.md" },

  # Lessons Learned System Templates
  @{ src = Join-Path $templatesRoot "docs\lessons\index.md.tmpl";             dst = Join-Path $ProjectDir "docs\lessons\index.md" },
  @{ src = Join-Path $templatesRoot "docs\lessons\templates\project-lesson.md.tmpl";     dst = Join-Path $ProjectDir "docs\lessons\templates\project-lesson.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\lessons\templates\workflow-lesson.md.tmpl";    dst = Join-Path $ProjectDir "docs\lessons\templates\workflow-lesson.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\lessons\templates\technology-lesson.md.tmpl";  dst = Join-Path $ProjectDir "docs\lessons\templates\technology-lesson.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\lessons\templates\troubleshooting-lesson.md.tmpl"; dst = Join-Path $ProjectDir "docs\lessons\templates\troubleshooting-lesson.md.tmpl" },
  @{ src = Join-Path $templatesRoot "docs\lessons\project-implementation\metadata.json.tmpl"; dst = Join-Path $ProjectDir "docs\lessons\project-implementation\metadata.json" },
  @{ src = Join-Path $templatesRoot "docs\lessons\bmad-workflow\metadata.json.tmpl";     dst = Join-Path $ProjectDir "docs\lessons\bmad-workflow\metadata.json" },
  @{ src = Join-Path $templatesRoot "docs\lessons\technology-patterns\metadata.json.tmpl"; dst = Join-Path $ProjectDir "docs\lessons\technology-patterns\metadata.json" },
  @{ src = Join-Path $templatesRoot "docs\lessons\troubleshooting\metadata.json.tmpl";   dst = Join-Path $ProjectDir "docs\lessons\troubleshooting\metadata.json" },
  @{ src = Join-Path $templatesRoot "scripts\lessons\search-lessons.ps1.tmpl";           dst = Join-Path $ProjectDir "scripts\lessons\search-lessons.ps1" },
  @{ src = Join-Path $templatesRoot ".claude\hooks\lesson-extraction-gate.ps1.tmpl";    dst = Join-Path $claudeDir "hooks\lesson-extraction-gate.ps1" }
)

foreach ($item in $map) { if (Test-Path $item.src) { Apply-Template -TemplatePath $item.src -DestPath $item.dst } }

# Deploy Docker templates based on project type
if (-not (Test-Path "$ProjectDir\docker-compose.yml")) {
    Write-Host "`nDeploying Docker configuration for $ProjectType project..." -ForegroundColor Cyan
    
    $dockerTemplate = switch ($ProjectType) {
        "saas" { Join-Path $templatesRoot "root\docker-compose.saas.yml.tmpl" }
        "phaser" { Join-Path $templatesRoot "root\docker-compose.phaser.yml.tmpl" }
        default { Join-Path $templatesRoot "root\docker-compose.generic.yml.tmpl" }
    }
    
    if (Test-Path $dockerTemplate) {
        Apply-Template -TemplatePath $dockerTemplate -DestPath (Join-Path $ProjectDir "docker-compose.yml")
        Write-Host "✅ Created docker-compose.yml for $ProjectType project" -ForegroundColor Green
    }
    
    # Deploy Dockerfiles if frontend/backend directories exist
    if (Test-Path "$ProjectDir\$FrontendDir") {
        $frontendDockerfile = Join-Path $templatesRoot "root\Dockerfile.frontend.tmpl"
        if (Test-Path $frontendDockerfile) {
            Apply-Template -TemplatePath $frontendDockerfile -DestPath (Join-Path $ProjectDir "$FrontendDir\Dockerfile")
            Write-Host "✅ Created frontend Dockerfile" -ForegroundColor Green
        }
    }
    
    if (Test-Path "$ProjectDir\$BackendDir") {
        $backendDockerfile = Join-Path $templatesRoot "root\Dockerfile.backend.tmpl"
        if (Test-Path $backendDockerfile) {
            Apply-Template -TemplatePath $backendDockerfile -DestPath (Join-Path $ProjectDir "$BackendDir\Dockerfile")
            Write-Host "✅ Created backend Dockerfile" -ForegroundColor Green
        }
    }
} else {
    Write-Host "Docker compose file already exists, skipping Docker template deployment" -ForegroundColor Yellow
}

Write-Host "`nBMAD framework applied to $ProjectDir" -ForegroundColor Green

# Check for Task Master installation
Write-Host "`nChecking Task Master AI installation..." -ForegroundColor Cyan
try {
    $tmVersion = & $TaskmasterCLI --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Task Master AI found: $tmVersion" -ForegroundColor Green
    } else {
        throw "Task Master not found"
    }
} catch {
    Write-Warning "⚠️ Task Master AI is REQUIRED for BMAD workflows!"
    Write-Host "Install globally with:" -ForegroundColor Yellow
    Write-Host "  npm install -g task-master-ai" -ForegroundColor Cyan
    Write-Host "Or locally with:" -ForegroundColor Yellow
    Write-Host "  npm install task-master-ai" -ForegroundColor Cyan
    Write-Host "`nAfter installation, initialize with:" -ForegroundColor Yellow
    Write-Host "  $TaskmasterCLI init -y" -ForegroundColor Cyan
    Write-Host "  $TaskmasterCLI models --set-main opus" -ForegroundColor Cyan
    Write-Host "  $TaskmasterCLI models --set-fallback sonnet" -ForegroundColor Cyan
}

# Check for Task Master project initialization
if (Test-Path "$ProjectDir\.taskmaster") {
    Write-Host "✅ Task Master project found" -ForegroundColor Green
} else {
    Write-Host "📋 Task Master not initialized in project" -ForegroundColor Yellow
    Write-Host "Initialize with: $TaskmasterCLI init -y" -ForegroundColor Cyan
}

# Check GitHub integration
Write-Host "`nChecking GitHub integration..." -ForegroundColor Cyan
try {
    Push-Location $ProjectDir
    $gitRemote = git config --get remote.origin.url 2>$null
    if ($gitRemote) {
        Write-Host "✅ GitHub remote configured: $gitRemote" -ForegroundColor Green
    } else {
        Write-Host "📦 GitHub not configured" -ForegroundColor Yellow
        Write-Host "Set up with: /bmad:github-setup" -ForegroundColor Cyan
        Write-Host "This enables automatic backup of completed work" -ForegroundColor Gray
    }
    
    # Check GitHub CLI
    $ghVersion = gh --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHub CLI available" -ForegroundColor Green
    } else {
        Write-Host "📦 GitHub CLI not installed (optional but recommended)" -ForegroundColor Yellow
        Write-Host "Install from: https://cli.github.com" -ForegroundColor Cyan
    }
    Pop-Location
} catch {
    Write-Host "Git not configured in project" -ForegroundColor Gray
}

# Check Docker installation
Write-Host "`nChecking Docker installation..." -ForegroundColor Cyan
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
        
        # Check if Docker daemon is running
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker daemon is running" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Docker daemon is not running" -ForegroundColor Yellow
            Write-Host "Start Docker Desktop to enable containerized development" -ForegroundColor Cyan
        }
    } else {
        throw "Docker not found"
    }
} catch {
    Write-Warning "⚠️ Docker is REQUIRED for BMAD development workflows!"
    Write-Host "Install Docker Desktop from:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    Write-Host "`nAll development happens in Docker containers for consistency and isolation" -ForegroundColor Gray
}

# Check for docker-compose.yml
if (Test-Path "$ProjectDir\docker-compose.yml") {
    Write-Host "✅ docker-compose.yml found" -ForegroundColor Green
} elseif (Test-Path "$ProjectDir\docker-compose.full.yml") {
    Write-Host "✅ docker-compose.full.yml found" -ForegroundColor Green
} else {
    Write-Host "📦 No docker-compose.yml file found" -ForegroundColor Yellow
    Write-Host "Create one based on your project type or use /bmad:docker to generate" -ForegroundColor Cyan
}

# Check Docker MCP installation
Write-Host "Checking Docker MCP installation..." -ForegroundColor Cyan
if (Test-Path "$env:APPDATA\Claude\claude_desktop_config.json") {
    try {
        $configContent = Get-Content "$env:APPDATA\Claude\claude_desktop_config.json" -Raw | ConvertFrom-Json
        if ($configContent.mcpServers.'docker') {
            Write-Host "Docker MCP configured" -ForegroundColor Green
        } else {
            Write-Host "Docker MCP not configured" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Could not parse Claude settings" -ForegroundColor Yellow
    }
} else {
    Write-Host "Claude settings not found" -ForegroundColor Gray
}

Write-Host "BMAD Framework setup complete!" -ForegroundColor Green
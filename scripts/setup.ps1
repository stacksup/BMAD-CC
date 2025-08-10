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
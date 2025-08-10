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
<# bootstrap.ps1 — remote installer
   Usage (from any project):
   powershell -ExecutionPolicy Bypass -NoProfile -Command "iwr https://raw.githubusercontent.com/stacksup/BMAD-CC/main/bootstrap.ps1 -UseBasicParsing | iex; Install-BMAD -ProjectDir . -ProjectType auto"
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
  $repo = "https://github.com/stacksup/BMAD-CC.git"

  $ProjectName = Split-Path (Resolve-Path $ProjectDir) -Leaf

  if ($ProjectType -eq "auto") {
    if ((Test-Path "$ProjectDir/frontend/package.json") -and (Test-Path "$ProjectDir/backend")) { $ProjectType = "saas" }
    elseif ((Test-Path "$ProjectDir/src/client") -or (Test-Path "$ProjectDir/package.json")) { $ProjectType = "phaser" }
    else { $ProjectType = "other" }
  }

  if (-not $PRDPath) {
    if (Test-Path "$ProjectDir/planning_docs/DEVELOPMENT_PLAN_PART1.md") { $PRDPath = "planning_docs/DEVELOPMENT_PLAN_PART1.md" }
    elseif (Test-Path "$ProjectDir/CLAUDE.md") { $PRDPath = "CLAUDE.md" }
    else { $PRDPath = "" }
  }

  if (-not $DockerComposeFile) {
    if (Test-Path "$ProjectDir/docker-compose.full.yml") { $DockerComposeFile = "docker-compose.full.yml" }
    elseif (Test-Path "$ProjectDir/docker-compose.yml") { $DockerComposeFile = "docker-compose.yml" }
    else { $DockerComposeFile = "" }
  }

  $tmp = Join-Path $env:TEMP ("bmadfw_" + [guid]::NewGuid().ToString("N"))
  git clone --depth 1 $repo $tmp | Out-Null

  # Ensure all parameters have values to avoid PowerShell parameter passing issues
  if ([string]::IsNullOrEmpty($PRDPath)) { $PRDPath = "" }
  if ([string]::IsNullOrEmpty($SecondaryPRDPath)) { $SecondaryPRDPath = "" }
  if ([string]::IsNullOrEmpty($DockerComposeFile)) { $DockerComposeFile = "" }
  
  $setup = Join-Path $tmp "scripts\setup.ps1"
  
  # Use splatting with explicit parameter handling to avoid empty string issues
  $params = @{
    ProjectDir = $ProjectDir
    ProjectType = $ProjectType 
    ProjectName = $ProjectName
    FrontendDir = $FrontendDir
    BackendDir = $BackendDir
    FrontendPort = $FrontendPort
    BackendPort = $BackendPort
    TaskmasterCLI = $TaskmasterCLI
  }
  
  # Only add these parameters if they have values
  if ($PRDPath) { $params.PRDPath = $PRDPath }
  if ($SecondaryPRDPath) { $params.SecondaryPRDPath = $SecondaryPRDPath }
  if ($DockerComposeFile) { $params.DockerComposeFile = $DockerComposeFile }
  
  & powershell -ExecutionPolicy Bypass -NoProfile -File $setup @params

  Remove-Item -Recurse -Force $tmp
  Write-Host "BMAD installed and tailored for '$ProjectName' ($ProjectType). Restart Claude Code to load new commands."
}

# Export-ModuleMember -Function Install-BMAD  # Not needed for direct execution
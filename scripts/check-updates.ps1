#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick BMAD version check
.DESCRIPTION
    Checks if BMAD framework updates are available from GitHub
#>

$ErrorActionPreference = "SilentlyContinue"

# Only check if we haven't checked today
$lastCheckFile = ".bmad-last-check"
$today = Get-Date -Format "yyyy-MM-dd"

if ((Test-Path $lastCheckFile) -and ((Get-Content $lastCheckFile -Raw).Trim() -eq $today)) {
    # Already checked today
    exit 0
}

# Check versions
$currentVersion = if (Test-Path ".bmad-version") { (Get-Content ".bmad-version" -Raw).Trim() } else { "unknown" }

try {
    $githubApi = "https://api.github.com/repos/stacksup/BMAD-CC/commits/main"
    $response = Invoke-RestMethod -Uri $githubApi -TimeoutSec 5
    $latestVersion = $response.sha.Substring(0, 8)
    
    if ($currentVersion -ne $latestVersion) {
        Write-Host "🚀 BMAD updates available! ($currentVersion → $latestVersion)" -ForegroundColor Yellow
        Write-Host "   Run: /bmad:update-framework" -ForegroundColor Cyan
    } else {
        Write-Host "✅ BMAD is up to date ($currentVersion)" -ForegroundColor Green
    }
    
    # Mark as checked today
    $today | Set-Content -Path $lastCheckFile -NoNewline
    
} catch {
    # Network error - skip silently
    exit 0
}
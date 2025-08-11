#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quality gate to detect and prevent dummy data and fallback implementations
.DESCRIPTION
    Scans code for patterns indicating dummy data, mock implementations, or silent failures
    that could hide real issues. This hook enforces the no-fallback policy.
#>

param(
    [string]$ProjectDir = ".",
    [switch]$FixIssues = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Error-Color { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Warning-Color { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Success-Color { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info-Color { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }

Write-Info-Color "🔍 Scanning for dummy data and fallback patterns..."

# Define patterns that indicate dummy/fallback implementations
$suspiciousPatterns = @(
    # Catch blocks returning fake success
    @{
        Pattern = 'catch.*\{[^}]*return[^}]*success.*true'
        Description = "Catch block returning fake success"
        Severity = "HIGH"
    },
    @{
        Pattern = 'catch.*\{[^}]*return[^}]*\[\]'
        Description = "Catch block returning empty array (possible fallback)"
        Severity = "HIGH"
    },
    @{
        Pattern = 'catch.*\{[^}]*return[^}]*\{\}'
        Description = "Catch block returning empty object (possible fallback)"
        Severity = "HIGH"
    },
    # Dummy/mock data indicators
    @{
        Pattern = 'dummy|DUMMY|Dummy'
        Description = "Dummy data reference"
        Severity = "HIGH"
    },
    @{
        Pattern = 'mock(?!ito)|MOCK|Mock(?!ito)'  # Exclude Mockito
        Description = "Mock data in production code"
        Severity = "MEDIUM"
    },
    @{
        Pattern = 'placeholder|PLACEHOLDER|Placeholder'
        Description = "Placeholder data"
        Severity = "MEDIUM"
    },
    @{
        Pattern = 'fallback|FALLBACK|Fallback'
        Description = "Fallback implementation"
        Severity = "HIGH"
    },
    # Hardcoded test data
    @{
        Pattern = 'test.*user|Test.*User|TEST.*USER'
        Description = "Hardcoded test user data"
        Severity = "MEDIUM"
    },
    @{
        Pattern = 'Lorem ipsum|lorem ipsum'
        Description = "Lorem ipsum placeholder text"
        Severity = "LOW"
    },
    # Silent failure patterns
    @{
        Pattern = '//.*TODO.*real|//.*FIXME.*dummy|//.*HACK.*mock'
        Description = "TODO/FIXME comment indicating incomplete implementation"
        Severity = "HIGH"
    }
)

$issuesFound = @()
$fileExtensions = @("*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.java", "*.cs", "*.go", "*.rb")

# Directories to exclude from scanning
$excludeDirs = @("node_modules", ".git", "dist", "build", "coverage", "test", "tests", "__tests__", "spec", ".claude")

# Build exclude pattern for find command
$excludePattern = ($excludeDirs | ForEach-Object { "-not -path '*/$_/*'" }) -join " "

foreach ($pattern in $suspiciousPatterns) {
    if ($Verbose) {
        Write-Info-Color "Checking for: $($pattern.Description)"
    }
    
    # Search for pattern in all relevant files
    foreach ($ext in $fileExtensions) {
        $searchCmd = "find `"$ProjectDir`" -name `"$ext`" $excludePattern -type f 2>/dev/null | xargs grep -l -E `"$($pattern.Pattern)`" 2>/dev/null"
        
        # Use appropriate command based on OS
        if ($IsWindows) {
            # Windows: Use Git Bash's grep if available, otherwise use Select-String
            $files = Get-ChildItem -Path $ProjectDir -Filter $ext -Recurse -File -ErrorAction SilentlyContinue |
                     Where-Object { 
                         $path = $_.FullName
                         $excluded = $false
                         foreach ($dir in $excludeDirs) {
                             if ($path -like "*\$dir\*" -or $path -like "*/$dir/*") {
                                 $excluded = $true
                                 break
                             }
                         }
                         -not $excluded
                     } |
                     Select-String -Pattern $pattern.Pattern -List -ErrorAction SilentlyContinue |
                     Select-Object -ExpandProperty Path -Unique
        } else {
            # Unix/Linux: Use grep
            $files = & bash -c $searchCmd 2>$null
        }
        
        if ($files) {
            foreach ($file in $files) {
                if ($file -and (Test-Path $file)) {
                    $relativePath = Resolve-Path -Path $file -Relative -ErrorAction SilentlyContinue
                    if (-not $relativePath) { $relativePath = $file }
                    
                    $issuesFound += @{
                        File = $relativePath
                        Pattern = $pattern.Description
                        Severity = $pattern.Severity
                        SearchPattern = $pattern.Pattern
                    }
                }
            }
        }
    }
}

# Report findings
if ($issuesFound.Count -gt 0) {
    Write-Error-Color "Found $($issuesFound.Count) potential dummy data / fallback patterns!"
    Write-Host ""
    
    # Group by severity
    $highSeverity = $issuesFound | Where-Object { $_.Severity -eq "HIGH" }
    $mediumSeverity = $issuesFound | Where-Object { $_.Severity -eq "MEDIUM" }
    $lowSeverity = $issuesFound | Where-Object { $_.Severity -eq "LOW" }
    
    if ($highSeverity) {
        Write-Error-Color "HIGH SEVERITY ISSUES (Must fix):"
        $highSeverity | ForEach-Object {
            Write-Host "  - $($_.File): $($_.Pattern)" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    if ($mediumSeverity) {
        Write-Warning-Color "MEDIUM SEVERITY ISSUES (Should fix):"
        $mediumSeverity | ForEach-Object {
            Write-Host "  - $($_.File): $($_.Pattern)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    if ($lowSeverity) {
        Write-Info-Color "LOW SEVERITY ISSUES (Consider fixing):"
        $lowSeverity | ForEach-Object {
            Write-Host "  - $($_.File): $($_.Pattern)" -ForegroundColor Cyan
        }
        Write-Host ""
    }
    
    Write-Error-Color "QUALITY GATE FAILED: No dummy data or fallback implementations allowed!"
    Write-Host ""
    Write-Host "To fix these issues:" -ForegroundColor White
    Write-Host "1. Replace dummy/mock data with real data connections" -ForegroundColor White
    Write-Host "2. Remove catch blocks that return fake success" -ForegroundColor White
    Write-Host "3. Let errors propagate - don't hide failures" -ForegroundColor White
    Write-Host "4. Use proper error handling that logs and throws" -ForegroundColor White
    Write-Host ""
    
    if ($env:BMAD_DISABLE_GATES -eq "1") {
        Write-Warning-Color "Quality gate BYPASSED (BMAD_DISABLE_GATES=1)"
        exit 0
    } else {
        exit 1
    }
} else {
    Write-Success-Color "No dummy data or fallback patterns detected!"
    Write-Success-Color "Code follows no-fallback policy ✨"
    exit 0
}

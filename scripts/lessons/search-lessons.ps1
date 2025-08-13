#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Search and discover lessons in the BMAD Framework lessons learned system
.DESCRIPTION
    This script provides various search capabilities for finding relevant lessons
    based on tags, contexts, difficulty, impact, and other criteria.
.PARAMETER Tag
    Search for lessons with specific tags
.PARAMETER Context
    Search for lessons that surface in specific file contexts
.PARAMETER Impact
    Filter by lesson impact level (high, medium, low)
.PARAMETER Difficulty
    Filter by lesson difficulty (beginner, intermediate, advanced)
.PARAMETER Category
    Filter by lesson category (project-implementation, bmad-workflow, technology-patterns, troubleshooting)
.PARAMETER Agent
    Find lessons that surface for specific agents (DEV, QA, ARCHITECT, etc.)
.PARAMETER Recent
    Show lessons created in the last N days (default: 30)
.PARAMETER List
    List all available lessons with basic info
.EXAMPLE
    .\search-lessons.ps1 -Tag "authentication"
    Find all lessons tagged with authentication
.EXAMPLE
    .\search-lessons.ps1 -Context "backend/*" -Agent "DEV"
    Find lessons that surface for developers working on backend code
.EXAMPLE
    .\search-lessons.ps1 -Impact "high" -Recent 7
    Find high-impact lessons created in the last 7 days
#>

param(
    [string]$Tag,
    [string]$Context,
    [ValidateSet("high", "medium", "low")]
    [string]$Impact,
    [ValidateSet("beginner", "intermediate", "advanced")]
    [string]$Difficulty,
    [ValidateSet("project-implementation", "bmad-workflow", "technology-patterns", "troubleshooting")]
    [string]$Category,
    [ValidateSet("SM", "PO", "DEV", "QA", "ARCHITECT", "ORCHESTRATOR", "LEARNINGS", "DOC", "GIT", "UX", "ANALYST", "PM")]
    [string]$Agent,
    [int]$Recent = 30,
    [switch]$List,
    [switch]$Help
)

# Script configuration
$LessonsDir = "docs/lessons"
$IndexFile = "$LessonsDir/index.md"

# Helper function to check if lessons directory exists
function Test-LessonsDirectory {
    if (-not (Test-Path $LessonsDir)) {
        Write-Host "âŒ Lessons directory not found: $LessonsDir" -ForegroundColor Red
        Write-Host "Make sure you're running this from the project root directory." -ForegroundColor Yellow
        exit 1
    }
    
    if (-not (Test-Path $IndexFile)) {
        Write-Host "âš ï¸  Lessons index not found. Run setup to initialize the lessons system." -ForegroundColor Yellow
    }
}

# Function to display help
function Show-Help {
    Write-Host @"
ðŸ” BMAD Framework Lessons Search Tool

USAGE:
  .\search-lessons.ps1 [OPTIONS]

SEARCH OPTIONS:
  -Tag <string>          Search by tag (e.g., "authentication", "performance")
  -Context <pattern>     Search by file context (e.g., "backend/*", "src/*")  
  -Impact <level>        Filter by impact: high, medium, low
  -Difficulty <level>    Filter by difficulty: beginner, intermediate, advanced
  -Category <type>       Filter by category: project-implementation, bmad-workflow, technology-patterns, troubleshooting
  -Agent <role>          Find lessons for specific agent: DEV, QA, ARCHITECT, etc.
  -Recent <days>         Show lessons from last N days (default: 30)

ACTIONS:
  -List                  List all available lessons
  -Help                  Show this help message

EXAMPLES:
  .\search-lessons.ps1 -List
  .\search-lessons.ps1 -Tag "authentication" -Impact "high"  
  .\search-lessons.ps1 -Context "backend/*" -Agent "DEV"
  .\search-lessons.ps1 -Category "troubleshooting" -Recent 7
  .\search-lessons.ps1 -Difficulty "beginner" -Tag "database"

QUICK SEARCH:
  rg -i "your-search-term" docs/lessons/ --type md
  find docs/lessons/ -name "*keyword*" -type f
"@ -ForegroundColor Cyan
}

# Function to search lessons by content using ripgrep
function Search-LessonsByContent {
    param(
        [string]$SearchTerm,
        [string]$FilePattern = "*.md"
    )
    
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg -i --type md --files-with-matches "$SearchTerm" $LessonsDir
    } else {
        # Fallback to Select-String if ripgrep not available
        Get-ChildItem -Path $LessonsDir -Recurse -Include $FilePattern |
            Select-String -Pattern $SearchTerm -CaseSensitive:$false |
            Select-Object -ExpandProperty Filename -Unique
    }
}

# Function to search metadata JSON files
function Search-MetadataFiles {
    param(
        [hashtable]$Criteria
    )
    
    $results = @()
    
    Get-ChildItem -Path $LessonsDir -Recurse -Name "metadata.json" | ForEach-Object {
        $metadataPath = Join-Path $LessonsDir $_
        
        if (Test-Path $metadataPath) {
            try {
                $metadata = Get-Content $metadataPath | ConvertFrom-Json
                
                foreach ($lesson in $metadata.lessons) {
                    $matches = $true
                    
                    # Check each criteria
                    if ($Criteria.ContainsKey('impact') -and $lesson.impact -ne $Criteria.impact) {
                        $matches = $false
                    }
                    
                    if ($Criteria.ContainsKey('difficulty') -and $lesson.difficulty -ne $Criteria.difficulty) {
                        $matches = $false
                    }
                    
                    if ($Criteria.ContainsKey('tag') -and $lesson.tags -notcontains $Criteria.tag) {
                        $matches = $false
                    }
                    
                    if ($Criteria.ContainsKey('agent') -and $lesson.surface_when -notcontains $Criteria.agent) {
                        $matches = $false
                    }
                    
                    if ($Criteria.ContainsKey('context')) {
                        $contextMatch = $false
                        foreach ($ctx in $lesson.surface_contexts) {
                            if ($ctx -like "*$($Criteria.context)*") {
                                $contextMatch = $true
                                break
                            }
                        }
                        if (-not $contextMatch) {
                            $matches = $false
                        }
                    }
                    
                    if ($matches) {
                        $results += [PSCustomObject]@{
                            ID = $lesson.id
                            Title = $lesson.title
                            Category = $metadata.category
                            Impact = $lesson.impact
                            Difficulty = $lesson.difficulty
                            Tags = $lesson.tags -join ", "
                            FilePath = $lesson.file_path
                            LastApplied = if ($lesson.last_applied) { $lesson.last_applied } else { "Never" }
                            SuccessRate = if ($lesson.success_rate) { "$([math]::Round($lesson.success_rate * 100))%" } else { "N/A" }
                        }
                    }
                }
            }
            catch {
                Write-Warning "Failed to parse metadata file: $metadataPath"
            }
        }
    }
    
    return $results
}

# Function to list all lessons
function Get-AllLessons {
    Write-Host "ðŸ“š All Available Lessons" -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Green
    
    $allLessons = @()
    
    # Get lessons from each category
    $categories = @("project-implementation", "bmad-workflow", "technology-patterns", "troubleshooting")
    
    foreach ($category in $categories) {
        $metadataPath = Join-Path $LessonsDir "$category/metadata.json"
        
        if (Test-Path $metadataPath) {
            try {
                $metadata = Get-Content $metadataPath | ConvertFrom-Json
                
                Write-Host "`nðŸ”¸ $($category.ToUpper()) ($($metadata.total_lessons) lessons)" -ForegroundColor Cyan
                
                foreach ($lesson in $metadata.lessons) {
                    $impact = switch ($lesson.impact) {
                        "high" { "ðŸ”´" }
                        "medium" { "ðŸŸ¡" }
                        "low" { "ðŸŸ¢" }
                        default { "âšª" }
                    }
                    
                    Write-Host "  $impact $($lesson.id): $($lesson.title)" -ForegroundColor White
                    Write-Host "     Tags: $($lesson.tags -join ', ')" -ForegroundColor Gray
                    
                    $allLessons += $lesson
                }
            }
            catch {
                Write-Warning "Failed to parse metadata for category: $category"
            }
        } else {
            Write-Host "`nðŸ”¸ $($category.ToUpper()) (0 lessons - category not initialized)" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "`nðŸ“Š Summary: $($allLessons.Count) total lessons available" -ForegroundColor Green
    
    if ($allLessons.Count -eq 0) {
        Write-Host "`nðŸ’¡ No lessons found. Start creating lessons by completing development stories!" -ForegroundColor Yellow
        Write-Host "   Lessons are automatically created by the learnings-agent during story completion." -ForegroundColor Gray
    }
}

# Function to display search results
function Show-SearchResults {
    param(
        [array]$Results,
        [string]$SearchDescription
    )
    
    if ($Results.Count -eq 0) {
        Write-Host "ðŸ” No lessons found matching: $SearchDescription" -ForegroundColor Yellow
        Write-Host "Try different search criteria or create new lessons!" -ForegroundColor Gray
        return
    }
    
    Write-Host "ðŸ” Found $($Results.Count) lesson(s) matching: $SearchDescription" -ForegroundColor Green
    Write-Host "=" * 80 -ForegroundColor Green
    
    foreach ($result in $Results) {
        $impact = switch ($result.Impact) {
            "high" { "ðŸ”´" }
            "medium" { "ðŸŸ¡" }  
            "low" { "ðŸŸ¢" }
            default { "âšª" }
        }
        
        Write-Host "`n$impact $($result.ID): $($result.Title)" -ForegroundColor White
        Write-Host "   Category: $($result.Category) | Difficulty: $($result.Difficulty)" -ForegroundColor Cyan
        Write-Host "   Tags: $($result.Tags)" -ForegroundColor Gray
        Write-Host "   Success Rate: $($result.SuccessRate) | Last Applied: $($result.LastApplied)" -ForegroundColor Gray
        Write-Host "   ðŸ“„ $($result.FilePath)" -ForegroundColor Blue
    }
    
    Write-Host "`nðŸ’¡ To view a lesson, use: Get-Content `"$($Results[0].FilePath)`"" -ForegroundColor Yellow
}

# Function to search recent lessons
function Get-RecentLessons {
    param([int]$Days)
    
    $cutoffDate = (Get-Date).AddDays(-$Days)
    $recentLessons = @()
    
    Get-ChildItem -Path $LessonsDir -Recurse -Include "*.md" -Exclude "index.md", "README.md" | 
        Where-Object { $_.LastWriteTime -gt $cutoffDate } |
        ForEach-Object {
            # Try to extract lesson info from frontmatter
            $content = Get-Content $_.FullName -Raw
            if ($content -match '^---\s*\n(.*?)\n---' -and $content -match 'title:\s*"(.+)"') {
                $recentLessons += [PSCustomObject]@{
                    ID = if ($content -match 'id:\s*(.+)') { $Matches[1].Trim() } else { $_.BaseName }
                    Title = $Matches[1]
                    FilePath = $_.FullName.Replace((Get-Location).Path + "\", "")
                    LastModified = $_.LastWriteTime
                    Category = $_.Directory.Name
                    Impact = if ($content -match 'impact:\s*(.+)') { $Matches[1].Trim() } else { "unknown" }
                    Difficulty = if ($content -match 'difficulty:\s*(.+)') { $Matches[1].Trim() } else { "unknown" }
                    Tags = if ($content -match 'tags:\s*\[([^\]]+)\]') { $Matches[1] } else { "" }
                }
            }
        }
    
    return $recentLessons | Sort-Object LastModified -Descending
}

# Main execution
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    Test-LessonsDirectory
    
    if ($List) {
        Get-AllLessons
        exit 0
    }
    
    # Build search criteria
    $searchCriteria = @{}
    $searchDescription = @()
    
    if ($Tag) {
        $searchCriteria.tag = $Tag
        $searchDescription += "tag:'$Tag'"
    }
    
    if ($Context) {
        $searchCriteria.context = $Context  
        $searchDescription += "context:'$Context'"
    }
    
    if ($Impact) {
        $searchCriteria.impact = $Impact
        $searchDescription += "impact:'$Impact'"
    }
    
    if ($Difficulty) {
        $searchCriteria.difficulty = $Difficulty
        $searchDescription += "difficulty:'$Difficulty'"
    }
    
    if ($Agent) {
        $searchCriteria.agent = $Agent
        $searchDescription += "agent:'$Agent'"
    }
    
    # Handle different search scenarios
    if ($searchCriteria.Count -gt 0) {
        # Metadata-based search
        $results = Search-MetadataFiles -Criteria $searchCriteria
        
        # Filter by category if specified
        if ($Category) {
            $results = $results | Where-Object { $_.Category -eq $Category }
            $searchDescription += "category:'$Category'"
        }
        
        Show-SearchResults -Results $results -SearchDescription ($searchDescription -join ", ")
    }
    elseif ($Category) {
        # Category-only search
        $searchCriteria.category = $Category
        $results = Search-MetadataFiles -Criteria $searchCriteria
        Show-SearchResults -Results $results -SearchDescription "category:'$Category'"
    }
    else {
        # Show recent lessons by default
        Write-Host "ðŸ” Showing lessons from the last $Recent days" -ForegroundColor Green
        $recentLessons = Get-RecentLessons -Days $Recent
        Show-SearchResults -Results $recentLessons -SearchDescription "recent $Recent days"
    }
}

# Execute main function
Main
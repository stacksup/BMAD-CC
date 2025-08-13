#!/usr/bin/env bash
# Enhanced BMAD Validation Enforcement Hook for BMAD-CC
# Comprehensive quality gates and validation automation

set -e

# Parameters
EVENT_TYPE="${1:-}"
AGENT_NAME="${2:-}"
TASK_TYPE="${3:-}"
FILE_PATH="${4:-}"

# Enhanced Configuration
PROJECT_NAME="BMAD-CC"
PROJECT_TYPE="${PROJECT_TYPE:-framework}"  # Fixed from "Framework"
VALIDATION_DIR="docs/validation"
DISABLE_GATES="${BMAD_DISABLE_GATES:-0}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'

# Configurable minimum scores by validation type
MIN_SCORES_ARCH="${BMAD_ARCH_MIN_SCORE:-8}"
MIN_SCORES_PRD="${BMAD_PRD_MIN_SCORE:-8}"
MIN_SCORES_SETUP="${BMAD_SETUP_MIN_SCORE:-7}"
MIN_SCORES_STORY="${BMAD_STORY_MIN_SCORE:-7}"
MIN_SCORES_DOD="${BMAD_DOD_MIN_SCORE:-9}"
MIN_SCORES_CHANGE="${BMAD_CHANGE_MIN_SCORE:-7}"

# Ensure validation directory exists
mkdir -p "$VALIDATION_DIR"

# Function to get validation status
get_validation_status() {
    local validation_type="$1"
    local identifier="$2"
    
    local pattern="$VALIDATION_DIR/${validation_type}-*${identifier}*.md"
    local latest_validation=$(ls -t $pattern 2>/dev/null | head -1)
    
    if [ -n "$latest_validation" ] && [ -f "$latest_validation" ]; then
        local content=$(cat "$latest_validation")
        
        # Extract score
        local score=0
        if echo "$content" | grep -qE "Overall.*Score.*([0-9]+)/10"; then
            score=$(echo "$content" | grep -oE "Overall.*Score.*([0-9]+)/10" | grep -oE "[0-9]+" | head -1)
        fi
        
        # Extract status
        local status="UNKNOWN"
        if echo "$content" | grep -qE "\*\*APPROVED\*\*|✅.*APPROVED"; then
            status="APPROVED"
        elif echo "$content" | grep -qE "\*\*GO\*\*|✅.*GO"; then
            status="GO"
        elif echo "$content" | grep -qE "\*\*READY\*\*|✅.*READY"; then
            status="READY"
        elif echo "$content" | grep -qE "\*\*DONE\*\*|✅.*DONE"; then
            status="DONE"
        elif echo "$content" | grep -qE "\*\*CONDITIONAL\*\*|⚠️"; then
            status="CONDITIONAL"
        elif echo "$content" | grep -qE "\*\*REJECTED\*\*|❌.*REJECTED"; then
            status="REJECTED"
        elif echo "$content" | grep -qE "\*\*BLOCKED\*\*|❌.*BLOCKED"; then
            status="BLOCKED"
        elif echo "$content" | grep -qE "\*\*NOT READY\*\*|❌.*NOT READY"; then
            status="NOT_READY"
        fi
        
        echo "$score|$status|$(basename "$latest_validation")|$(stat -c %y "$latest_validation" 2>/dev/null || stat -f "%Sm" "$latest_validation" 2>/dev/null)"
        return 0
    fi
    
    return 1
}

# Function for automated validation
invoke_automated_validation() {
    local validation_type="$1"
    local document_path="$2"
    local identifier="${3:-$(date +%Y%m%d-%H%M)}"
    
    echo -e "${CYAN}🔍 Running automated validation for $validation_type...${NC}"
    
    if [ ! -f "$document_path" ]; then
        echo -e "${YELLOW}⚠️ Document not found for validation: $document_path${NC}"
        return 1
    fi
    
    local content=$(cat "$document_path")
    local issues=()
    local score=0
    
    # Automated scoring based on document type
    case "$validation_type" in
        "story-draft")
            # Story validation scoring
            if echo "$content" | grep -qE "User Story:.*As a.*I want.*So that"; then
                ((score+=2))
            else
                issues+=("Missing proper user story format")
            fi
            
            if echo "$content" | grep -qE "Acceptance Criteria:.*Given.*When.*Then"; then
                ((score+=2))
            else
                issues+=("Missing testable acceptance criteria")
            fi
            
            if echo "$content" | grep -qE "\[Source:.*\]"; then
                ((score+=2))
            else
                issues+=("Missing source references for technical claims")
            fi
            
            if ! echo "$content" | grep -qE "TODO|TBD|FIXME|\[\]"; then
                ((score+=2))
            else
                issues+=("Contains TODOs or incomplete sections")
            fi
            
            if echo "$content" | grep -qE "Definition of Done:"; then
                ((score+=2))
            else
                issues+=("Missing Definition of Done")
            fi
            ;;
            
        "architecture")
            # Architecture validation scoring
            if echo "$content" | grep -qE "System Architecture:|Technical Architecture:"; then
                ((score+=2))
            else
                issues+=("Missing system architecture section")
            fi
            
            if echo "$content" | grep -qE "Technology Stack:"; then
                ((score+=2))
            else
                issues+=("Missing technology stack specification")
            fi
            
            if echo "$content" | grep -qE "Security:|Security Architecture:"; then
                ((score+=2))
            else
                issues+=("Missing security considerations")
            fi
            
            if echo "$content" | grep -qE "Performance:|Scalability:"; then
                ((score+=2))
            else
                issues+=("Missing performance/scalability section")
            fi
            
            if echo "$content" | grep -qE "NO.FALLBACK|NO-FALLBACK"; then
                ((score+=2))
            else
                issues+=("Missing NO-FALLBACK design principles")
            fi
            ;;
            
        "prd")
            # PRD validation scoring
            if echo "$content" | grep -qE "Product Vision:|Vision:"; then
                ((score+=2))
            else
                issues+=("Missing product vision")
            fi
            
            if echo "$content" | grep -qE "User Stories:|Requirements:"; then
                ((score+=2))
            else
                issues+=("Missing user requirements section")
            fi
            
            if echo "$content" | grep -qE "Success Metrics:|Metrics:"; then
                ((score+=2))
            else
                issues+=("Missing success metrics")
            fi
            
            if echo "$content" | grep -qE "Technical Requirements:"; then
                ((score+=2))
            else
                issues+=("Missing technical requirements")
            fi
            
            if ! echo "$content" | grep -qE "TODO|TBD|\[\s\]"; then
                ((score+=2))
            else
                issues+=("Contains incomplete sections")
            fi
            ;;
            
        *)
            # Generic document validation
            if [ ${#content} -gt 100 ]; then ((score+=3)); fi
            if ! echo "$content" | grep -qE "TODO|TBD"; then ((score+=3)); fi
            if echo "$content" | grep -qE "##.*"; then ((score+=2)); fi
            if echo "$content" | grep -qE "\|.*\|"; then ((score+=2)); fi
            ;;
    esac
    
    # Determine status based on score
    local status
    if [ $score -ge 9 ]; then
        status="APPROVED"
    elif [ $score -ge 7 ]; then
        status="CONDITIONAL"
    elif [ $score -ge 5 ]; then
        status="NEEDS_WORK"
    else
        status="REJECTED"
    fi
    
    # Generate validation report
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local report_path="$VALIDATION_DIR/${validation_type}-${identifier}.md"
    
    # Get minimum score for this type
    local min_score=8
    case "$validation_type" in
        "architecture") min_score=$MIN_SCORES_ARCH ;;
        "prd") min_score=$MIN_SCORES_PRD ;;
        "project-setup") min_score=$MIN_SCORES_SETUP ;;
        "story-draft") min_score=$MIN_SCORES_STORY ;;
        "story-dod") min_score=$MIN_SCORES_DOD ;;
        "change-impact") min_score=$MIN_SCORES_CHANGE ;;
    esac
    
    # Write report
    cat > "$report_path" <<EOF
# $validation_type Validation Report

**Document:** $document_path  
**Validation Date:** $timestamp  
**Validator:** Automated BMAD Validation System  
**Overall Score:** $score/10  
**Status:** $status

## Scoring Breakdown

$([ $score -ge 8 ] && echo "✅" || echo "❌") **Overall Score:** $score/10 (Minimum required: $min_score)

## Issues Identified

EOF
    
    if [ ${#issues[@]} -eq 0 ]; then
        echo "✅ No issues found" >> "$report_path"
    else
        for issue in "${issues[@]}"; do
            echo "❌ $issue" >> "$report_path"
        done
    fi
    
    cat >> "$report_path" <<EOF

## Validation Decision

EOF
    
    case "$status" in
        "APPROVED")
            echo "✅ **APPROVED** - Document meets all requirements and is ready for next phase." >> "$report_path"
            ;;
        "CONDITIONAL")
            echo "⚠️ **CONDITIONAL** - Document is acceptable but has minor issues that should be addressed." >> "$report_path"
            ;;
        "NEEDS_WORK")
            echo "🔄 **NEEDS WORK** - Document requires improvements before proceeding." >> "$report_path"
            ;;
        "REJECTED")
            echo "❌ **REJECTED** - Document has major issues and requires significant rework." >> "$report_path"
            ;;
    esac
    
    echo "" >> "$report_path"
    echo "---" >> "$report_path"
    echo "*Generated by BMAD Validation Enforcer v3.0*" >> "$report_path"
    
    echo -e "${GRAY}📋 Validation report saved: $report_path${NC}"
    
    echo "$score|$status"
    return 0
}

# Function to enforce validation gate
enforce_validation_gate() {
    local validation_type="$1"
    local identifier="$2"
    local min_score="${3:-8}"
    local document_path="${4:-}"
    
    if [ "$DISABLE_GATES" = "1" ]; then
        echo -e "${YELLOW}⚠️ Validation gates disabled (BMAD_DISABLE_GATES=1)${NC}"
        return 0
    fi
    
    local validation_result
    if ! validation_result=$(get_validation_status "$validation_type" "$identifier"); then
        # If no validation exists and we have a document path, run automated validation
        if [ -n "$document_path" ] && [ -f "$document_path" ]; then
            echo -e "${BLUE}🤖 Running automated validation...${NC}"
            local auto_result=$(invoke_automated_validation "$validation_type" "$document_path" "$identifier")
            validation_result="$(echo "$auto_result" | cut -d'|' -f1)|$(echo "$auto_result" | cut -d'|' -f2)|validation-report.md|$(date)"
        else
            echo -e "${YELLOW}⚠️ VALIDATION REQUIRED: No $validation_type validation found for $identifier${NC}"
            echo "Please complete validation before proceeding."
            echo -e "${GRAY}Or provide document path for automated validation.${NC}"
            return 1
        fi
    fi
    
    local score=$(echo "$validation_result" | cut -d'|' -f1)
    local status=$(echo "$validation_result" | cut -d'|' -f2)
    local file=$(echo "$validation_result" | cut -d'|' -f3)
    
    # Check score
    if [ "$score" -lt "$min_score" ]; then
        echo -e "${RED}❌ VALIDATION FAILED: $validation_type score $score/10 is below minimum $min_score/10${NC}"
        echo -e "${RED}Please address validation issues in: $file${NC}"
        return 1
    fi
    
    # Check status
    case "$status" in
        "APPROVED"|"GO"|"READY"|"DONE")
            echo -e "${GREEN}✅ Validation Passed: $validation_type (Score: $score/10, Status: $status)${NC}"
            return 0
            ;;
        "CONDITIONAL")
            echo -e "${YELLOW}⚠️ CONDITIONAL APPROVAL: $validation_type has conditions that should be addressed${NC}"
            return 0
            ;;
        *)
            echo -e "${RED}❌ VALIDATION BLOCKED: $validation_type status is $status${NC}"
            echo -e "${RED}Please resolve issues in: $file${NC}"
            return 1
            ;;
    esac
}

# Main enforcement logic based on event type
case "$EVENT_TYPE" in
    "pre-planning-handoff")
        echo -e "\n${CYAN}🔍 Enforcing Planning Phase Quality Gates...${NC}"
        
        enforce_validation_gate "architect-validation" "$(date +%Y-%m)" "$MIN_SCORES_ARCH"
        arch_valid=$?
        
        enforce_validation_gate "prd-validation" "$(date +%Y-%m)" "$MIN_SCORES_PRD"
        prd_valid=$?
        
        if [ $arch_valid -ne 0 ] || [ $prd_valid -ne 0 ]; then
            echo -e "${RED}Planning phase validation gates not met. Cannot proceed to development.${NC}"
            exit 1
        fi
        ;;
        
    "pre-story-development")
        echo -e "\n${CYAN}🔍 Enforcing Story Readiness Gate...${NC}"
        
        story_id="${STORY_ID:-current}"
        if ! enforce_validation_gate "story-draft" "$story_id" "$MIN_SCORES_STORY"; then
            echo -e "${RED}Story not ready for development. Please complete validation.${NC}"
            exit 1
        fi
        ;;
        
    "pre-story-completion")
        echo -e "\n${CYAN}🔍 Enforcing Definition of Done Gate...${NC}"
        
        story_id="${STORY_ID:-current}"
        if ! enforce_validation_gate "story-dod" "$story_id" "$MIN_SCORES_DOD"; then
            echo -e "${RED}Story does not meet Definition of Done. Cannot mark as complete.${NC}"
            exit 1
        fi
        ;;
        
    "pre-project-start")
        echo -e "\n${CYAN}🔍 Enforcing Project Setup Gate...${NC}"
        
        if ! enforce_validation_gate "project-setup" "$PROJECT_NAME" "$MIN_SCORES_SETUP"; then
            echo -e "${YELLOW}Project setup validation failed. Critical issues must be resolved.${NC}"
            echo -e "${YELLOW}Run: Load po-agent → validate-project-setup${NC}"
            echo -e "${RED}Project not ready to start. Complete setup validation.${NC}"
            exit 1
        fi
        ;;
        
    "change-request")
        echo -e "\n${CYAN}🔍 Enforcing Change Management Gate...${NC}"
        
        change_id="${CHANGE_ID:-$(date +%Y%m%d)}"
        if ! enforce_validation_gate "change-impact" "$change_id" "$MIN_SCORES_CHANGE"; then
            echo -e "${YELLOW}Change impact assessment required before proceeding.${NC}"
            exit 1
        fi
        ;;
        
    "validation-status")
        echo -e "\n${CYAN}📊 Current Validation Status for $PROJECT_NAME${NC}"
        echo "============================================================"
        
        validation_types=(
            "architect-validation|Architecture"
            "prd-validation|PRD"
            "project-setup|Project Setup"
            "story-draft|Story Drafts"
            "story-dod|Story Completions"
        )
        
        for vtype in "${validation_types[@]}"; do
            type_name=$(echo "$vtype" | cut -d'|' -f1)
            label=$(echo "$vtype" | cut -d'|' -f2)
            
            latest=$(ls -t "$VALIDATION_DIR/${type_name}-"*.md 2>/dev/null | head -1)
            
            if [ -n "$latest" ]; then
                if validation=$(get_validation_status "$type_name" "*"); then
                    score=$(echo "$validation" | cut -d'|' -f1)
                    status=$(echo "$validation" | cut -d'|' -f2)
                    
                    case "$status" in
                        "APPROVED"|"GO"|"READY"|"DONE")
                            status_display="✅ $status"
                            ;;
                        "CONDITIONAL")
                            status_display="⚠️ Conditional"
                            ;;
                        *)
                            status_display="❌ $status"
                            ;;
                    esac
                    
                    echo "$label: $status_display (Score: $score/10) - $(basename "$latest")"
                fi
            else
                echo -e "$label: ${GRAY}⏸️ Not validated yet${NC}"
            fi
        done
        echo "============================================================"
        ;;
        
    *)
        # No enforcement for this event type
        [ -n "$EVENT_TYPE" ] && echo "No validation enforcement for event type: $EVENT_TYPE"
        ;;
esac

# Success message if we get here
if [ "$EVENT_TYPE" != "validation-status" ] && [ -n "$EVENT_TYPE" ]; then
    echo -e "\n${GREEN}✅ All validation gates passed successfully!${NC}"
fi
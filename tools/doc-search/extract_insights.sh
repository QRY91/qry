#!/bin/bash

# QRY Repository Insight Extraction Script
# Extracts valuable insights before archiving content
# Uses semantic search to identify worth-preserving knowledge

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
EXTRACT_DIR="$SCRIPT_DIR/extracted_insights"
DATE=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we can run qry-search
if [[ ! -f "$SCRIPT_DIR/qry-search" ]]; then
    log_error "qry-search not found. Please run setup.sh first."
    exit 1
fi

# Create extraction directory
mkdir -p "$EXTRACT_DIR"

log_info "Starting insight extraction for QRY repository cleanup"
log_info "Extraction directory: $EXTRACT_DIR"
echo

# Test the search system
log_info "Testing search system..."
if ! ./qry-search test > /dev/null 2>&1; then
    log_error "Search system test failed. Please check Ollama and ChromaDB."
    exit 1
fi
log_success "Search system is working"

# Function to run search and save results
extract_insights() {
    local query="$1"
    local filename="$2"
    local limit="${3:-50}"

    log_info "Searching for: '$query'"

    # Create file with header
    cat > "$EXTRACT_DIR/$filename" << EOF
# QRY Repository Insights: $query
**Extracted**: $(date)
**Query**: "$query"
**Limit**: $limit results

---

EOF

    # Run search and append results
    if ./qry-search search "$query" --limit "$limit" >> "$EXTRACT_DIR/$filename" 2>/dev/null; then
        local result_count=$(grep -c "File:" "$EXTRACT_DIR/$filename" || echo "0")
        log_success "Found $result_count results for '$query'"
    else
        log_warning "Search failed for '$query'"
        echo "Search failed - no results found" >> "$EXTRACT_DIR/$filename"
    fi

    echo -e "\n---\n" >> "$EXTRACT_DIR/$filename"
}

# Function to filter results by directory patterns
filter_archive_candidates() {
    local input_file="$1"
    local output_file="$2"

    log_info "Filtering for archive candidate directories..."

    # Extract only results from directories we plan to archive
    grep -E "(other_projects|backups|enterprise|arcade|atelier|qry-deskhog-prototypes)" "$input_file" > "$output_file" || true

    local filtered_count=$(grep -c "File:" "$output_file" 2>/dev/null || echo "0")
    log_info "Filtered to $filtered_count results from archive candidates"
}

echo "🔍 EXTRACTING METHODOLOGICAL INSIGHTS"
echo "========================================"

# QRY Methodology and Process Insights
extract_insights "QRY methodology" "methodology_core.md" 30
extract_insights "systematic approach" "methodology_systematic.md" 25
extract_insights "query refine yield" "methodology_qry_process.md" 20
extract_insights "workflow optimization" "methodology_workflow.md" 25
extract_insights "process documentation" "methodology_process.md" 25

echo
echo "🧠 EXTRACTING LEARNING AND BREAKTHROUGH INSIGHTS"
echo "==============================================="

# Learning and Breakthrough Insights
extract_insights "lessons learned" "learning_lessons.md" 30
extract_insights "breakthrough moment" "learning_breakthroughs.md" 25
extract_insights "failure discovery" "learning_failures.md" 25
extract_insights "learning through" "learning_methods.md" 25
extract_insights "mistake insight" "learning_mistakes.md" 20

echo
echo "🤝 EXTRACTING COLLABORATION INSIGHTS"
echo "===================================="

# Collaboration and AI Insights
extract_insights "AI collaboration" "collaboration_ai.md" 30
extract_insights "team collaboration" "collaboration_team.md" 25
extract_insights "collaborative breakthrough" "collaboration_breakthroughs.md" 20
extract_insights "productive collaboration" "collaboration_productive.md" 25
extract_insights "meatspace authentication" "collaboration_authentication.md" 15

echo
echo "🔧 EXTRACTING TECHNICAL INSIGHTS"
echo "==============================="

# Technical Implementation Insights
extract_insights "implementation strategy" "technical_implementation.md" 30
extract_insights "architecture decision" "technical_architecture.md" 25
extract_insights "technical breakthrough" "technical_breakthroughs.md" 25
extract_insights "optimization technique" "technical_optimization.md" 20
extract_insights "performance improvement" "technical_performance.md" 20

echo
echo "💡 EXTRACTING STRATEGIC INSIGHTS"
echo "==============================="

# Strategic and Business Insights
extract_insights "strategic thinking" "strategic_thinking.md" 25
extract_insights "business strategy" "strategic_business.md" 20
extract_insights "competitive advantage" "strategic_advantage.md" 20
extract_insights "value proposition" "strategic_value.md" 20
extract_insights "market opportunity" "strategic_market.md" 15

echo
echo "🏗️ EXTRACTING PROJECT INSIGHTS"
echo "============================="

# Project-Specific Insights
extract_insights "PostHog integration" "projects_posthog.md" 20
extract_insights "uroboro capture" "projects_uroboro.md" 25
extract_insights "semantic search" "projects_search.md" 20
extract_insights "local AI optimization" "projects_ai.md" 25
extract_insights "enterprise solution" "projects_enterprise.md" 15

echo
echo "📊 CREATING ARCHIVE-SPECIFIC EXTRACTIONS"
echo "========================================"

# Create filtered versions focusing on archive candidates
for file in "$EXTRACT_DIR"/*.md; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file" .md)
        filtered_file="$EXTRACT_DIR/archive_${filename}.md"

        # Create header for filtered version
        cat > "$filtered_file" << EOF
# Archive Candidate Insights: $filename
**Extracted**: $(date)
**Source**: $(basename "$file")
**Focus**: Content from directories planned for archival

This file contains insights specifically from directories that will be archived:
- other_projects/
- backups/
- enterprise/
- arcade/
- atelier/
- qry-deskhog-prototypes/

---

EOF

        # Filter and append
        filter_archive_candidates "$file" "$filtered_file"
    fi
done

echo
echo "📋 CREATING EXTRACTION SUMMARY"
echo "=============================="

# Create summary report
SUMMARY_FILE="$EXTRACT_DIR/EXTRACTION_SUMMARY.md"
cat > "$SUMMARY_FILE" << EOF
# QRY Repository Insight Extraction Summary

**Date**: $(date)
**Purpose**: Extract valuable insights before archiving 516 files from QRY repository
**Method**: Semantic search across 900 markdown files
**Target**: Archive candidates (other_projects/, backups/, enterprise/, etc.)

## Extraction Statistics

EOF

# Count results in each file
echo "### Files Created:" >> "$SUMMARY_FILE"
for file in "$EXTRACT_DIR"/*.md; do
    if [[ -f "$file" && "$file" != "$SUMMARY_FILE" ]]; then
        filename=$(basename "$file")
        result_count=$(grep -c "File:" "$file" 2>/dev/null || echo "0")
        echo "- **$filename**: $result_count results" >> "$SUMMARY_FILE"
    fi
done

echo "" >> "$SUMMARY_FILE"
echo "### Archive Candidate Focus" >> "$SUMMARY_FILE"
echo "Files prefixed with 'archive_' contain insights specifically from directories planned for archival." >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "### Next Steps" >> "$SUMMARY_FILE"
echo "1. Review extracted insights manually" >> "$SUMMARY_FILE"
echo "2. Integrate valuable insights into core workspace documentation" >> "$SUMMARY_FILE"
echo "3. Proceed with archival of source directories" >> "$SUMMARY_FILE"
echo "4. Update semantic search index after cleanup" >> "$SUMMARY_FILE"

# Final statistics
TOTAL_FILES=$(ls -1 "$EXTRACT_DIR"/*.md | wc -l)
TOTAL_INSIGHTS=$(grep -c "File:" "$EXTRACT_DIR"/*.md 2>/dev/null | awk -F: '{sum += $2} END {print sum}' || echo "0")

echo
echo "🎉 EXTRACTION COMPLETE"
echo "====================="
log_success "Created $TOTAL_FILES insight files with $TOTAL_INSIGHTS total results"
log_success "Extraction directory: $EXTRACT_DIR"
log_success "Summary report: $SUMMARY_FILE"

echo
echo "📖 Next Steps:"
echo "1. Review insights in: $EXTRACT_DIR"
echo "2. Integrate valuable patterns into core documentation"
echo "3. Proceed with archival using QRY_CLEANUP_PLAN.md"
echo "4. Re-run semantic search embedding after cleanup"

echo
echo "🔍 Quick Preview of Archive Candidate Insights:"
ARCHIVE_INSIGHTS=$(grep -c "File:" "$EXTRACT_DIR"/archive_*.md 2>/dev/null | awk -F: '{sum += $2} END {print sum}' || echo "0")
echo "Found $ARCHIVE_INSIGHTS insights specifically from archive candidate directories"

# Show top archive candidate files with insights
echo
echo "📊 Top insight sources from archive candidates:"
grep -h "File:" "$EXTRACT_DIR"/archive_*.md 2>/dev/null | head -10 || echo "No archive candidate insights found"

log_success "Insight extraction completed successfully!"

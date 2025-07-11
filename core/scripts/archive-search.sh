#!/bin/bash

# QRY Archive Search - Retrieve archived project details without cluttering workspace
# Usage: ./archive-search.sh "search terms" [--extract]

set -e

ARCHIVE_REPO="git@github.com:QRY91/archive.git"
TEMP_DIR="/tmp/qry-archive-$$"
SEARCH_TERMS="$1"
EXTRACT_MODE=""

if [[ "$2" == "--extract" ]]; then
    EXTRACT_MODE="true"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 \"search terms\" [--extract]"
    echo ""
    echo "Examples:"
    echo "  $0 \"ESP32 deskhog posthog\""
    echo "  $0 \"uroboro implementation\" --extract"
    echo ""
    echo "Options:"
    echo "  --extract    Copy relevant files to experiments/ for active work"
    exit 1
}

cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        echo -e "${YELLOW}Cleaning up temporary archive...${NC}"
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

if [[ -z "$SEARCH_TERMS" ]]; then
    usage
fi

echo -e "${BLUE}🔍 Searching QRY Archive for: '$SEARCH_TERMS'${NC}"
echo ""

# Clone archive to temp location
echo -e "${YELLOW}Cloning archive (this may take a moment)...${NC}"
git clone --depth 1 "$ARCHIVE_REPO" "$TEMP_DIR" 2>/dev/null || {
    echo -e "${RED}Failed to clone archive. Check your SSH keys and repo access.${NC}"
    exit 1
}

cd "$TEMP_DIR"

# Search for relevant markdown files
echo -e "${GREEN}Searching markdown files...${NC}"
echo ""

# Case-insensitive grep across all markdown files
RESULTS=$(find . -name "*.md" -type f -exec grep -l -i "$SEARCH_TERMS" {} \; 2>/dev/null | head -20)

if [[ -z "$RESULTS" ]]; then
    echo -e "${RED}No matching files found in archive.${NC}"
    exit 0
fi

echo -e "${GREEN}Found relevant files:${NC}"
echo ""

# Display results with context
for file in $RESULTS; do
    echo -e "${BLUE}📄 $file${NC}"

    # Show a few lines of context around matches
    grep -i -n -A 2 -B 2 "$SEARCH_TERMS" "$file" 2>/dev/null | head -10 | sed 's/^/    /'
    echo ""
done

# Extract mode - copy relevant files to experiments
if [[ "$EXTRACT_MODE" == "true" ]]; then
    EXTRACT_DIR="../../experiments/$(date +%Y%m%d)-archive-extract"

    echo -e "${YELLOW}Extracting files to: $EXTRACT_DIR${NC}"
    mkdir -p "$EXTRACT_DIR"

    # Copy each relevant file maintaining some directory structure
    for file in $RESULTS; do
        # Create directory structure
        DIR_PATH=$(dirname "$file")
        mkdir -p "$EXTRACT_DIR/$DIR_PATH"

        # Copy file
        cp "$file" "$EXTRACT_DIR/$file"
        echo -e "${GREEN}✓${NC} Extracted: $file"
    done

    # Create extraction summary
    cat > "$EXTRACT_DIR/EXTRACTION_INFO.md" << EOF
# Archive Extraction Summary

**Date**: $(date)
**Search Terms**: $SEARCH_TERMS
**Files Extracted**: $(echo "$RESULTS" | wc -l)

## Extracted Files:
$(echo "$RESULTS" | sed 's/^/- /')

## Next Steps:
1. Review extracted files for relevant context
2. Copy needed information to your active project
3. Delete this extraction directory when done

---
*Generated by QRY archive-search.sh*
EOF

    echo ""
    echo -e "${GREEN}📁 Extraction complete! Files available at:${NC}"
    echo -e "${BLUE}   $EXTRACT_DIR${NC}"
    echo ""
    echo -e "${YELLOW}Remember to clean up the extraction directory when done.${NC}"
fi

echo -e "${GREEN}Archive search complete!${NC}"

#!/bin/bash

# QRY Unified Search - Search both active workspace and archives
# Usage: ./qry-search-all.sh "search terms" [--include-archived] [--extract-archived]

set -e

# Configuration
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC_SEARCH_PATH="$WORKSPACE_ROOT/tools/doc-search"
ARCHIVE_REGISTRY="$HOME/.qry-archive/search-registry.txt"
ARCHIVE_BASE="$HOME/.qry-archive"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default options
INCLUDE_ARCHIVED=true
EXTRACT_ARCHIVED=false
SEARCH_TERMS=""
MAX_RESULTS=10

usage() {
    cat << EOF
QRY Unified Search - Search active workspace and archives

Usage: $0 "search terms" [options]

Arguments:
  "search terms"        What to search for

Options:
  --active-only         Search only active workspace (faster)
  --archived-only       Search only archived content
  --extract             Offer to extract archived results to experiments/
  --max-results=N       Maximum results to show (default: 10)
  --help               Show this help

Examples:
  $0 "ESP32 hardware setup"
  $0 "posthog integration" --extract
  $0 "AI collaboration" --active-only
  $0 "methodology" --archived-only

Results are labeled as [ACTIVE] or [ARCHIVED] for easy identification.
EOF
    exit 1
}

error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --active-only)
            INCLUDE_ARCHIVED=false
            shift
            ;;
        --archived-only)
            INCLUDE_ARCHIVED=true
            DOC_SEARCH_DISABLED=true
            shift
            ;;
        --extract)
            EXTRACT_ARCHIVED=true
            shift
            ;;
        --max-results=*)
            MAX_RESULTS="${1#*=}"
            shift
            ;;
        --help)
            usage
            ;;
        -*)
            error "Unknown option $1"
            ;;
        *)
            if [[ -z "$SEARCH_TERMS" ]]; then
                SEARCH_TERMS="$1"
            else
                error "Multiple search terms should be quoted as one argument"
            fi
            shift
            ;;
    esac
done

if [[ -z "$SEARCH_TERMS" ]]; then
    usage
fi

# Search active workspace using doc-search
search_active() {
    if [[ "$DOC_SEARCH_DISABLED" == "true" ]]; then
        return 0
    fi

    if [[ ! -x "$DOC_SEARCH_PATH/qry-search" ]]; then
        echo -e "${YELLOW}Warning:${NC} doc-search not found, skipping active workspace search"
        return 0
    fi

    echo -e "${BLUE}🔍 Searching Active Workspace${NC}"
    echo ""

    # Run doc-search and format results
    local results
    results=$("$DOC_SEARCH_PATH/qry-search" search "$SEARCH_TERMS" 2>/dev/null | head -n $((MAX_RESULTS * 6))) || {
        echo "No results found in active workspace"
        return 0
    }

    # Parse and format doc-search results
    local result_count=0
    while IFS= read -r line && [[ $result_count -lt $MAX_RESULTS ]]; do
        if [[ "$line" =~ ^---\ Result\ [0-9]+\ \(similarity:\ (.*)\)\ ---$ ]]; then
            echo -e "${GREEN}[ACTIVE]${NC} Result $((result_count + 1))"
            ((result_count++))
        elif [[ "$line" =~ ^File:\ (.*)$ ]]; then
            echo -e "  📄 ${CYAN}${BASH_REMATCH[1]}${NC}"
        elif [[ "$line" =~ ^Directory:\ (.*)$ ]]; then
            echo -e "  📁 ${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Preview:\ (.*)$ ]]; then
            echo -e "  💭 ${BASH_REMATCH[1]}"
            echo ""
        fi
    done <<< "$results"

    if [[ $result_count -eq 0 ]]; then
        echo "No results found in active workspace"
    fi
    echo ""
}

# Search archived content
search_archived() {
    if [[ "$INCLUDE_ARCHIVED" != "true" ]]; then
        return 0
    fi

    if [[ ! -f "$ARCHIVE_REGISTRY" ]]; then
        if [[ "$DOC_SEARCH_DISABLED" == "true" ]]; then
            echo "No archive registry found at $ARCHIVE_REGISTRY"
        fi
        return 0
    fi

    echo -e "${PURPLE}📦 Searching Archived Content${NC}"
    echo ""

    local found_results=false
    local result_count=0

    # Search archive registry and metadata files
    while IFS='|' read -r date_archived original_path archive_dest tag_info && [[ $result_count -lt $MAX_RESULTS ]]; do
        # Skip empty lines and comments
        [[ -z "$date_archived" || "$date_archived" =~ ^# ]] && continue

        # Search in original path and tag
        local search_text="$original_path $tag_info"
        if [[ "$search_text" =~ $SEARCH_TERMS ]] || [[ "$search_text" =~ $(echo "$SEARCH_TERMS" | tr '[:upper:]' '[:lower:]') ]]; then
            found_results=true
            ((result_count++))

            echo -e "${PURPLE}[ARCHIVED]${NC} Result $result_count"
            echo -e "  📄 ${CYAN}$original_path${NC} (archived)"
            echo -e "  📅 Archived: $(date -d "${date_archived}" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$date_archived")"

            if [[ -n "$tag_info" && "$tag_info" != "" ]]; then
                echo -e "  🏷️  Tag: $tag_info"
            fi

            # Try to get preview from metadata
            local metadata_file="$archive_dest/.qry-archive-meta"
            if [[ -f "$metadata_file" ]]; then
                local preview=$(grep -A 5 "# Content preview:" "$metadata_file" 2>/dev/null | tail -n +2 | head -n 3 | sed 's/^# //' | tr '\n' ' ')
                if [[ -n "$preview" && "$preview" != " " ]]; then
                    echo -e "  💭 $preview"
                fi
            fi

            echo -e "  📍 Location: ${archive_dest/$HOME/~}"
            echo ""
        fi
    done < "$ARCHIVE_REGISTRY"

    if [[ "$found_results" != "true" ]]; then
        echo "No results found in archived content"
    fi
    echo ""
}

# Extract archived content if requested
offer_extraction() {
    if [[ "$EXTRACT_ARCHIVED" != "true" ]]; then
        return 0
    fi

    echo -e "${YELLOW}📤 Archive Extraction Available${NC}"
    echo "Use the archive paths shown above with qry-unarchive.sh to restore content."
    echo "Example: ./core/scripts/qry-unarchive.sh ~/.qry-archive/2025/06/19/old-project"
    echo ""
}

# Main search function
main() {
    echo -e "${CYAN}🔍 QRY Unified Search${NC}"
    echo -e "Query: \"${SEARCH_TERMS}\""
    echo ""

    # Search active workspace first
    search_active

    # Search archived content
    search_archived

    # Offer extraction options
    offer_extraction

    echo -e "${GREEN}Search complete!${NC}"
    echo ""
    echo "💡 Tips:"
    echo "  • Use --active-only for faster searches of current workspace"
    echo "  • Use --extract to get help restoring archived content"
    echo "  • Check qry/experiments/ for recently extracted archives"
}

# Run the search
main

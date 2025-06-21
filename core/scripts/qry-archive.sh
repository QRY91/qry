#!/bin/bash

# QRY Archive System - Move content while preserving searchability
# Usage: ./qry-archive.sh <path> [--strategy=TYPE] [--tag=TAG]

set -e

# Configuration
ARCHIVE_BASE="$HOME/.qry-archive"
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC_SEARCH_PATH="$WORKSPACE_ROOT/tools/doc-search"
UROBORO_CMD="uroboro"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
STRATEGY="date"
TAG=""
DRY_RUN=false
VERBOSE=false

usage() {
    cat << EOF
QRY Archive System - Keep workspace clean while preserving searchability

Usage: $0 <path> [options]

Arguments:
  path                  File or directory to archive

Options:
  --strategy=TYPE       Archive strategy: date, project, topic (default: date)
  --tag=TAG            Add tag for easier retrieval
  --dry-run            Show what would be archived without doing it
  --verbose            Show detailed output
  --help               Show this help

Strategies:
  date                 Archive by current date (YYYY/MM/DD)
  project              Archive by detected project name
  topic                Archive by content topic (experimental)

Examples:
  $0 experiments/old-prototype
  $0 work/completed-project --strategy=project --tag=posthog
  $0 docs/research-notes --tag=ai-collaboration

The archived content remains searchable via doc-search but is moved
out of your active workspace for better focus.
EOF
    exit 1
}

log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
    fi
}

error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}Warning:${NC} $1" >&2
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --strategy=*)
            STRATEGY="${1#*=}"
            shift
            ;;
        --tag=*)
            TAG="${1#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            usage
            ;;
        -*)
            error "Unknown option $1"
            ;;
        *)
            if [[ -z "$TARGET_PATH" ]]; then
                TARGET_PATH="$1"
            else
                error "Multiple paths not supported"
            fi
            shift
            ;;
    esac
done

if [[ -z "$TARGET_PATH" ]]; then
    usage
fi

# Validate target path
if [[ ! -e "$TARGET_PATH" ]]; then
    error "Path does not exist: $TARGET_PATH"
fi

# Get absolute path and relative path from workspace
TARGET_ABS="$(realpath "$TARGET_PATH")"
if [[ "$TARGET_ABS" == "$WORKSPACE_ROOT"* ]]; then
    TARGET_REL="${TARGET_ABS#$WORKSPACE_ROOT/}"
else
    error "Path must be within QRY workspace: $TARGET_PATH"
fi

# Determine archive destination based on strategy
determine_archive_dest() {
    local base_name=$(basename "$TARGET_REL")

    case "$STRATEGY" in
        "date")
            local date_path=$(date +"%Y/%m/%d")
            echo "$ARCHIVE_BASE/$date_path/$base_name"
            ;;
        "project")
            # Try to detect project from path structure
            local project=""
            if [[ "$TARGET_REL" =~ ^(experiments|tools)/([^/]+) ]]; then
                project="${BASH_REMATCH[2]}"
            elif [[ "$TARGET_REL" =~ ^([^/]+) ]]; then
                project="${BASH_REMATCH[1]}"
            else
                project="misc"
            fi
            echo "$ARCHIVE_BASE/projects/$project/$base_name"
            ;;
        "topic")
            # Experimental: use simple topic detection
            local topic="misc"
            if [[ -n "$TAG" ]]; then
                topic="$TAG"
            elif [[ "$TARGET_REL" =~ (ai|llm|semantic) ]]; then
                topic="ai"
            elif [[ "$TARGET_REL" =~ (web|frontend|ui) ]]; then
                topic="web"
            elif [[ "$TARGET_REL" =~ (hardware|esp32|embedded) ]]; then
                topic="hardware"
            fi
            echo "$ARCHIVE_BASE/topics/$topic/$base_name"
            ;;
        *)
            error "Unknown strategy: $STRATEGY"
            ;;
    esac
}

ARCHIVE_DEST=$(determine_archive_dest)

# Create archive metadata
create_metadata() {
    local metadata_file="$ARCHIVE_DEST/.qry-archive-meta"

    cat > "$metadata_file" << EOF
# QRY Archive Metadata
original_path=$TARGET_REL
archived_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
strategy=$STRATEGY
tag=$TAG
archive_script_version=1.0

# File/directory info
$(if [[ -f "$TARGET_ABS" ]]; then
    echo "type=file"
    echo "size=$(stat -c%s "$TARGET_ABS" 2>/dev/null || stat -f%z "$TARGET_ABS" 2>/dev/null || echo "unknown")"
else
    echo "type=directory"
    echo "size=$(du -sh "$TARGET_ABS" 2>/dev/null | cut -f1 || echo "unknown")"
fi)

# Content summary (first few lines for files)
$(if [[ -f "$TARGET_ABS" && "$TARGET_ABS" =~ \.(md|txt|py|sh|js|go|rs)$ ]]; then
    echo "# Content preview:"
    echo "$(head -n 5 "$TARGET_ABS" 2>/dev/null | sed 's/^/# /')"
fi)
EOF
}

# Update doc-search index with archive status
update_search_index() {
    if [[ -x "$DOC_SEARCH_PATH/qry-search" ]]; then
        log "Updating search index to mark content as archived..."

        # This would need to be implemented in the doc-search tool
        # For now, we'll create a simple archived content registry
        local archive_registry="$HOME/.qry-archive/search-registry.txt"
        mkdir -p "$(dirname "$archive_registry")"

        echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ")|$TARGET_REL|$ARCHIVE_DEST|$TAG" >> "$archive_registry"

        log "Added to archive search registry"
    else
        warn "doc-search tool not found, skipping search index update"
    fi
}

# Record action with uroboro
record_action() {
    if command -v "$UROBORO_CMD" > /dev/null; then
        local msg="Archived $TARGET_REL to $(basename "$ARCHIVE_DEST")"
        if [[ -n "$TAG" ]]; then
            msg="$msg (tag: $TAG)"
        fi
        "$UROBORO_CMD" capture "$msg" 2>/dev/null || true
    fi
}

# Main archive operation
perform_archive() {
    echo -e "${BLUE}📦 QRY Archive Operation${NC}"
    echo "  Source: $TARGET_REL"
    echo "  Destination: $ARCHIVE_DEST"
    echo "  Strategy: $STRATEGY"
    if [[ -n "$TAG" ]]; then
        echo "  Tag: $TAG"
    fi
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}DRY RUN - No changes will be made${NC}"
        echo ""
        echo "Would create: $ARCHIVE_DEST"
        echo "Would move: $TARGET_ABS → $ARCHIVE_DEST"
        echo "Would create metadata file"
        echo "Would update search registry"
        return 0
    fi

    # Confirm operation
    read -p "Proceed with archive operation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Archive operation cancelled"
        exit 0
    fi

    # Create archive directory
    log "Creating archive directory..."
    mkdir -p "$(dirname "$ARCHIVE_DEST")"

    # Move content to archive
    log "Moving content to archive..."
    mv "$TARGET_ABS" "$ARCHIVE_DEST"

    # Create metadata
    log "Creating archive metadata..."
    create_metadata

    # Update search index
    update_search_index

    # Record with uroboro
    record_action

    success "Successfully archived $TARGET_REL"
    echo "  Location: $ARCHIVE_DEST"
    echo "  Use 'qry-unarchive.sh' to restore if needed"
}

# Check for existing archive
if [[ -e "$ARCHIVE_DEST" ]]; then
    error "Archive destination already exists: $ARCHIVE_DEST"
fi

# Perform the archive operation
perform_archive

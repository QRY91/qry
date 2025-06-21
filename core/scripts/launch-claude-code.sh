#!/bin/bash

# QRY Claude Code Integration - Launch Claude Code with QRY workspace context
# Usage: ./launch-claude-code.sh [--background] [--with-context]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QRY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKGROUND_MODE=false
WITH_CONTEXT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --background)
            BACKGROUND_MODE=true
            shift
            ;;
        --with-context)
            WITH_CONTEXT=true
            shift
            ;;
        --help|-h)
            cat << EOF
QRY Claude Code Integration

Usage: $0 [options]

Options:
  --background     Launch Claude Code in background
  --with-context   Include QRY workspace context files
  --help          Show this help

This script launches Claude Code with QRY workspace optimization:
- Opens in QRY root directory
- Includes workspace context for better AI understanding
- Integrates with existing aider + neovim workflow
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1. Use --help for usage."
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Claude Code is available
check_claude_code() {
    # Check for various possible Claude Code installations
    local claude_commands=("code" "claude-code" "claudecode")
    local claude_cmd=""

    for cmd in "${claude_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            # For Claude Code, the 'code' command is often reused
            # So we'll be more permissive and assume any 'code' command works
            if [[ "$cmd" == *claude* ]]; then
                # Explicitly Claude-named commands
                claude_cmd="$cmd"
                break
            elif [[ "$cmd" == "code" ]]; then
                # Regular 'code' command - could be Claude Code or VS Code
                # Claude Code often reuses the same binary name
                claude_cmd="$cmd"
                break
            fi
        fi
    done

    if [[ -n "$claude_cmd" ]]; then
        echo "$claude_cmd"
        return 0
    else
        return 1
    fi
}

# Create context files for Claude Code
create_context_files() {
    if [[ "$WITH_CONTEXT" != "true" ]]; then
        return 0
    fi

    log_info "Creating context files for Claude Code..."

    local context_dir="$QRY_ROOT/.claude-context"
    mkdir -p "$context_dir"

    # Create workspace overview
    cat > "$context_dir/QRY_WORKSPACE_OVERVIEW.md" << EOF
# QRY Workspace Context for Claude Code

**Purpose**: This file provides context for Claude Code about the QRY workspace structure and methodology.

## Workspace Structure

\`\`\`
qry/
├── tools/              # CLI utilities (uroboro, wherewasi, examinator, qoins, doc-search)
├── experiments/        # Prototypes and early-stage projects
├── core/              # Orchestration, AI collaboration, scripts
├── zone/              # Main website (qry.zone)
├── content/           # Documentation, assets, logos
└── backups/           # System backups
\`\`\`

## Active Tools

- **uroboro**: Work documentation and acknowledgment system (Go)
- **wherewasi**: Context generation for AI collaboration (Python)
- **examinator**: Offline study companion with spaced repetition (Python)
- **qoins**: Cost tracking and optimization (Shell)
- **doc-search**: Semantic search across workspace (Python + ChromaDB)

## QRY Methodology

**Query, Refine, Yield** - Systematic approach to tool building:
1. **Query**: Deep dive into real problems and systematic dysfunction
2. **Refine**: Build tools that work WITH human psychology
3. **Yield**: Deploy tools that solve problems and share what works

## Development Practices

- **Local-first**: Privacy-respecting, offline-capable tools
- **AI-collaborative**: Transparent AI assistance with human oversight
- **Systematic**: Document learning process, build reusable approaches
- **Honest**: Build useful things, not impressive-sounding projects

## Current Focus

$(cd "$QRY_ROOT" && ls experiments/ 2>/dev/null | head -3 | sed 's/^/- /')

## AI Collaboration Context

The workspace includes systematic AI collaboration procedures in \`core/ai/\`.
Aider setup available in \`core/aider-setup-optimization/\` for terminal-based AI development.
This Claude Code integration complements the existing aider workflow.
EOF

    # Create current project context if in experiments
    if [[ -d "$QRY_ROOT/experiments" ]]; then
        local current_projects
        current_projects=$(find "$QRY_ROOT/experiments" -maxdepth 1 -type d | tail -n +2)

        if [[ -n "$current_projects" ]]; then
            cat > "$context_dir/CURRENT_PROJECTS.md" << EOF
# Current QRY Projects

$(echo "$current_projects" | while read -r project; do
    local project_name=$(basename "$project")
    echo "## $project_name"
    echo ""
    if [[ -f "$project/README.md" ]]; then
        echo "$(head -n 10 "$project/README.md")"
    elif [[ -f "$project/PROJECT_README.md" ]]; then
        echo "$(head -n 10 "$project/PROJECT_README.md")"
    else
        echo "Project directory: $project"
        echo "Files: $(ls "$project" 2>/dev/null | tr '\n' ' ')"
    fi
    echo ""
done)
EOF
        fi
    fi

    log_success "Context files created in .claude-context/"
}

# Launch Claude Code
launch_claude_code() {
    local claude_cmd

    if ! claude_cmd=$(check_claude_code); then
        log_error "Claude Code not found!"
        echo ""
        echo -e "${CYAN}Installation options:${NC}"
        echo "1. Download from: https://claude.ai/code"
        echo "2. Install via package manager (if available)"
        echo "3. Use VS Code with Claude extension as alternative"
        echo ""
        echo -e "${YELLOW}Once installed, run this script again.${NC}"
        return 1
    fi

    log_info "Found Claude Code: $claude_cmd"

    # Change to QRY root directory
    cd "$QRY_ROOT"

    # Create context files if requested
    create_context_files

    # Launch Claude Code
    log_info "Launching Claude Code in QRY workspace..."

    if [[ "$BACKGROUND_MODE" == "true" ]]; then
        nohup "$claude_cmd" . >/dev/null 2>&1 &
        log_success "Claude Code launched in background"
    else
        "$claude_cmd" .
        log_success "Claude Code launched"
    fi

    # Show helpful information
    echo ""
    echo -e "${CYAN}🎯 Claude Code QRY Integration Ready!${NC}"
    echo ""
    echo -e "${CYAN}Quick tips:${NC}"
    echo "• Workspace root: $QRY_ROOT"

    if [[ "$WITH_CONTEXT" == "true" ]]; then
        echo "• Context files: .claude-context/ (for workspace understanding)"
    fi

    echo "• Complement with: aider (terminal), qry tools (CLI)"
    echo "• Use 'qry status' to check workspace overview"
    echo ""

    if [[ -f "$QRY_ROOT/core/aider-setup-optimization/safe_aider.sh" ]]; then
        echo -e "${CYAN}AI Development Workflow:${NC}"
        echo "• Claude Code: Visual editing + AI chat"
        echo "• Aider: Terminal AI pair programming"
        echo "• Neovim: Fast text editing"
        echo "• All work captured via uroboro"
    fi
}

# Main function
main() {
    echo ""
    echo -e "${BLUE}🤖 QRY Claude Code Integration${NC}"
    echo -e "${BLUE}══════════════════════════════${NC}"
    echo ""

    # Ensure we're in QRY workspace
    if [[ ! -f "$QRY_ROOT/README.md" ]] || [[ ! -d "$QRY_ROOT/tools" ]]; then
        log_error "Not in a QRY workspace"
        log_info "Run this script from your QRY directory"
        exit 1
    fi

    launch_claude_code
}

# Run main function
main "$@"

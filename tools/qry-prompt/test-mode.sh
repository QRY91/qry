#!/bin/bash

# QRY Prompt Test Mode
# Safely test QRY Prompt without modifying your shell config

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[TEST-MODE]${NC} $1"; }
warn() { echo -e "${YELLOW}[TEST-MODE]${NC} $1"; }
info() { echo -e "${BLUE}[TEST-MODE]${NC} $1"; }
error() { echo -e "${RED}[TEST-MODE]${NC} $1"; }

# Check if we're in a test session
if [[ "$QRY_PROMPT_TEST_MODE" == "1" ]]; then
    error "Already in QRY Prompt test mode!"
    info "Type 'exit' or press Ctrl+D to return to your original prompt"
    exit 1
fi

# Backup current PS1 if it exists
if [[ -n "$PS1" ]]; then
    export QRY_PROMPT_ORIGINAL_PS1="$PS1"
    log "Backed up current PS1"
fi

# Check if Starship is active
if command -v starship >/dev/null 2>&1; then
    if [[ -n "$STARSHIP_SESSION_KEY" ]] || pgrep -f starship >/dev/null 2>&1; then
        warn "Starship detected - it will be temporarily disabled in test session"
        export QRY_PROMPT_HAD_STARSHIP="1"
    fi
fi

# Start test session
log "Starting QRY Prompt test session..."
info "═══════════════════════════════════════"
info "🧪 QRY PROMPT TEST MODE"
info "═══════════════════════════════════════"
info "• QRY Prompt is now active"
info "• Your original setup is preserved"
info "• Type 'exit' or Ctrl+D to return to normal"
info "• Use 'qry-demo' to see feature showcase"
info "═══════════════════════════════════════"

# Set test mode flag
export QRY_PROMPT_TEST_MODE="1"

# Create temporary demo function
qry-demo() {
    echo "QRY Prompt Features Demo:"
    echo "========================"
    ./demo.sh 2>/dev/null || echo "Demo script not found - run from qry-prompt directory"
}
export -f qry-demo

# Load QRY prompt in a new shell session
exec bash --rcfile <(
    echo "# Temporary test session for QRY Prompt"
    echo "export QRY_PROMPT_TEST_MODE=1"
    echo "export QRY_PROMPT_ORIGINAL_PS1='$QRY_PROMPT_ORIGINAL_PS1'"
    echo "export QRY_PROMPT_HAD_STARSHIP='$QRY_PROMPT_HAD_STARSHIP'"
    
    # Source original bashrc but skip starship
    if [[ -f ~/.bashrc ]]; then
        echo "# Load original bashrc (modified)"
        # Read bashrc and comment out starship initialization
        sed 's/^[[:space:]]*eval.*starship init.*/#&  # Disabled for QRY test/' ~/.bashrc
    fi
    
    echo "# Load QRY Prompt"
    echo "source \"$(pwd)/qry-prompt.sh\""
    
    echo "# Test mode helper functions"
    echo "qry-demo() { $(pwd)/demo.sh 2>/dev/null || echo 'Demo script not found - run from qry-prompt directory'; }"
    echo "qry-help() {"
    echo "  echo 'QRY Prompt Test Mode Commands:'"
    echo "  echo '  qry-demo  - Show feature demonstration'"
    echo "  echo '  qry-help  - Show this help'"
    echo "  echo '  exit      - Return to your original prompt'"
    echo "}"
    
    echo "# Welcome message"
    echo "echo"
    echo "echo -e '${GREEN}🧪 QRY Prompt Test Mode Active${NC}'"
    echo "echo -e '${BLUE}Type \"qry-help\" for commands or \"exit\" to return${NC}'"
    echo "echo"
)
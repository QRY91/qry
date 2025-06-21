#!/bin/bash

# QRY Workspace Setup - Complete Environment Installation
# Makes any fresh clone ready for systematic development
# Usage: ./setup.sh [--minimal] [--dev-env]

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
QRY_ROOT="$SCRIPT_DIR"
MINIMAL_INSTALL=false
DEV_ENV_INSTALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --minimal)
            MINIMAL_INSTALL=true
            shift
            ;;
        --dev-env)
            DEV_ENV_INSTALL=true
            shift
            ;;
        --help|-h)
            cat << EOF
QRY Workspace Setup - Complete Environment Installation

Usage: $0 [options]

Options:
  --minimal     Install only core tools (no AI/aider setup)
  --dev-env     Full development environment with aider + neovim
  --help        Show this help

What gets installed:
- QRY core tools (uroboro, wherewasi, examinator, qoins, doc-search)
- Ollama + local AI models (unless --minimal)
- Aider + optimized setup (if --dev-env)
- AI collaboration environment
- All dependencies and configurations

After installation, you'll have a complete QRY workspace ready for:
- Systematic tool building
- AI-assisted development
- Local-first privacy-respecting workflows
- Cross-project context sharing
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1. Use --help for usage."
            exit 1
            ;;
    esac
done

# Utility functions
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

log_section() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo "$(printf '%.0s─' {1..50})"
}

# Check prerequisites
check_prerequisites() {
    log_section "Checking Prerequisites"

    # Check if we're in a QRY workspace
    if [[ ! -f "$QRY_ROOT/README.md" ]] || [[ ! -d "$QRY_ROOT/tools" ]]; then
        log_error "Not in a QRY workspace directory"
        log_info "Clone the QRY repository first: git clone <your-qry-repo>"
        exit 1
    fi

    # Check OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    else
        log_warn "Unsupported platform: $OSTYPE. Proceeding anyway..."
        PLATFORM="unknown"
    fi

    # Check required commands
    local required_commands=("curl" "git" "python3" "pip3")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    log_success "Prerequisites check passed"
}

# Install Ollama and models
install_ollama() {
    if [[ "$MINIMAL_INSTALL" == "true" ]]; then
        log_info "Skipping Ollama installation (minimal mode)"
        return 0
    fi

    log_section "Installing Ollama + AI Models"

    if command -v ollama &> /dev/null; then
        log_info "Ollama already installed"
    else
        log_info "Installing Ollama..."
        if [[ "$PLATFORM" == "macos" ]]; then
            brew install ollama 2>/dev/null || {
                log_info "Homebrew not available, using curl installer"
                curl -fsSL https://ollama.ai/install.sh | sh
            }
        else
            curl -fsSL https://ollama.ai/install.sh | sh
        fi
        log_success "Ollama installed"
    fi

    # Start Ollama service
    log_info "Starting Ollama service..."
    if [[ "$PLATFORM" == "macos" ]]; then
        brew services start ollama 2>/dev/null || ollama serve &
    else
        systemctl --user start ollama 2>/dev/null || ollama serve &
    fi

    # Wait for Ollama to be ready
    sleep 3

    # Install essential models
    log_info "Installing AI models (this may take a while)..."
    local models=("nomic-embed-text" "qwen2.5-coder:0.5b")

    if [[ "$DEV_ENV_INSTALL" == "true" ]]; then
        models+=("qwen2.5-coder:7b")
    fi

    for model in "${models[@]}"; do
        log_info "Pulling model: $model"
        ollama pull "$model" || log_warn "Failed to pull $model, continuing..."
    done

    log_success "Ollama and models installed"
}

# Install QRY tools
install_qry_tools() {
    log_section "Installing QRY Tools"

    # Install core tools
    if [[ -x "$QRY_ROOT/core/install_tools.sh" ]]; then
        log_info "Running core tools installer..."
        cd "$QRY_ROOT"
        ./core/install_tools.sh
    else
        log_info "Installing tools manually..."

        # Install uroboro (Go-based)
        if [[ -d "$QRY_ROOT/tools/uroboro" ]]; then
            cd "$QRY_ROOT/tools/uroboro"
            if command -v go &> /dev/null; then
                go mod tidy && go install ./cmd/uroboro
                log_success "uroboro installed"
            else
                log_warn "Go not found, skipping uroboro installation"
            fi
        fi

        # Install Python-based tools
        for tool in "wherewasi" "examinator" "doc-search"; do
            if [[ -d "$QRY_ROOT/tools/$tool" ]]; then
                cd "$QRY_ROOT/tools/$tool"
                if [[ -f "requirements.txt" ]]; then
                    pip3 install -r requirements.txt --user
                fi
                if [[ -f "setup.sh" ]]; then
                    ./setup.sh
                fi
                log_success "$tool dependencies installed"
            fi
        done
    fi

    cd "$QRY_ROOT"
    log_success "QRY tools installed"
}

# Set up development environment
setup_dev_environment() {
    if [[ "$DEV_ENV_INSTALL" != "true" ]]; then
        log_info "Skipping development environment setup (use --dev-env flag)"
        return 0
    fi

    log_section "Setting Up Development Environment"

    # Install aider
    log_info "Installing aider..."
    pip3 install aider-chat --user --upgrade

    # Run aider setup optimization
    if [[ -f "$QRY_ROOT/core/aider-setup-optimization/setup.sh" ]]; then
        log_info "Running aider optimization setup..."
        cd "$QRY_ROOT/core/aider-setup-optimization"
        ./setup.sh --auto || log_warn "Aider setup had issues, continuing..."
        cd "$QRY_ROOT"
    fi

    log_success "Development environment configured"
}

# Configure QRY workspace
configure_workspace() {
    log_section "Configuring QRY Workspace"

    # Set up environment variables
    log_info "Setting up environment..."

    # Add QRY tools to PATH
    local qry_bin_paths=""
    if [[ -d "$HOME/go/bin" ]]; then
        qry_bin_paths="$HOME/go/bin"
    fi
    if [[ -d "$HOME/.local/bin" ]]; then
        qry_bin_paths="$qry_bin_paths:$HOME/.local/bin"
    fi

    # Create QRY environment setup
    cat > "$QRY_ROOT/.qryrc" << EOF
# QRY Workspace Environment
export QRY_ROOT="$QRY_ROOT"
export PATH="$qry_bin_paths:\$PATH"

# QRY shortcuts
alias qry="$QRY_ROOT/core/qry-enhanced"
alias uro="uroboro"
alias qsearch="$QRY_ROOT/core/scripts/qry-search-all.sh"
alias qarchive="$QRY_ROOT/core/scripts/qry-archive.sh"

# AI development shortcuts
if command -v aider &> /dev/null; then
    alias ai="cd $QRY_ROOT && aider"
    alias ais="cd $QRY_ROOT && $QRY_ROOT/core/aider-setup-optimization/safe_aider.sh"
fi

echo "QRY workspace ready! Use 'qry status' to check setup."
EOF

    # Set up doc-search if not already done
    if [[ -d "$QRY_ROOT/tools/doc-search" ]]; then
        cd "$QRY_ROOT/tools/doc-search"
        if [[ ! -f ".setup_complete" ]]; then
            log_info "Setting up doc-search..."
            ./setup.sh 2>/dev/null || log_warn "doc-search setup had issues"
            touch ".setup_complete"
        fi
        cd "$QRY_ROOT"
    fi

    log_success "QRY workspace configured"
}

# Create initial capture
create_initial_capture() {
    log_section "Creating Initial Setup Capture"

    if command -v uroboro &> /dev/null; then
        local setup_type="minimal"
        [[ "$DEV_ENV_INSTALL" == "true" ]] && setup_type="full development"

        uroboro capture "QRY workspace setup complete: $setup_type installation on $(uname -s). Ready for systematic development." 2>/dev/null || {
            log_info "uroboro capture failed, but setup is complete"
        }
    fi

    log_success "Initial capture created"
}

# Main installation function
main() {
    echo ""
    echo -e "${CYAN}🔧 QRY Workspace Setup${NC}"
    echo -e "${CYAN}════════════════════════${NC}"

    if [[ "$MINIMAL_INSTALL" == "true" ]]; then
        echo -e "Mode: ${YELLOW}Minimal Installation${NC}"
    elif [[ "$DEV_ENV_INSTALL" == "true" ]]; then
        echo -e "Mode: ${GREEN}Full Development Environment${NC}"
    else
        echo -e "Mode: ${BLUE}Standard Installation${NC}"
    fi

    echo ""

    check_prerequisites
    install_ollama
    install_qry_tools
    setup_dev_environment
    configure_workspace
    create_initial_capture

    log_section "Setup Complete!"

    echo ""
    echo -e "${GREEN}🎉 QRY Workspace is ready!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Source the environment: source .qryrc"
    echo "2. Check status: qry status"
    echo "3. Start building: qry capture \"Starting work on...\""
    echo ""

    if [[ "$DEV_ENV_INSTALL" == "true" ]]; then
        echo -e "${CYAN}Development environment ready:${NC}"
        echo "• Use 'ai' to start aider in QRY workspace"
        echo "• Use 'ais' for safe aider with optimized settings"
        echo "• Neovim config available in core/aider-setup-optimization/"
        echo ""
    fi

    echo -e "${CYAN}Quick commands:${NC}"
    echo "• qry search \"terms\" - Search workspace and archives"
    echo "• qry archive <path> - Archive completed work"
    echo "• qry tools - List available tools"
    echo ""
    echo -e "${YELLOW}💡 Tip: Run './setup.sh --dev-env' for full development environment${NC}"
    echo ""
}

# Run main function
main "$@"

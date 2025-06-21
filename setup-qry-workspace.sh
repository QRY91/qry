#!/bin/bash

# QRY Workspace Setup - Complete Development Environment
# Clone from GitHub, run this script, start building
#
# Usage: ./setup-qry-workspace.sh [--dev-env] [--ai-setup] [--skip-models]
#
# Author: QRY Labs - Systematic Tool Building
# Version: 2.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QRY_ROOT="$SCRIPT_DIR"
HOME_CONFIG_DIR="$HOME/.config"

# Setup options
SETUP_DEV_ENV=false
SETUP_AI=false
SKIP_MODELS=false
VERBOSE=false

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_header() {
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

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
    exit 1
}

log_step() {
    echo -e "${CYAN}🔧 $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create directory if it doesn't exist
ensure_dir() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

usage() {
    cat << EOF
${BLUE}QRY Workspace Setup${NC} - Complete Development Environment

Usage: $0 [options]

${CYAN}Setup Options:${NC}
  --dev-env         Set up complete development environment (aider, nvim, etc.)
  --ai-setup        Install and configure AI tools (ollama, models)
  --skip-models     Skip downloading AI models (faster setup)
  --verbose         Show detailed output
  --help           Show this help

${CYAN}Setup Phases:${NC}
  1. Core QRY Tools (uroboro, wherewasi, examinator, etc.)
  2. Development Environment (aider, nvim, terminal setup)
  3. AI Infrastructure (ollama, models, collaboration setup)
  4. Integration Testing (verify everything works)

${CYAN}Examples:${NC}
  $0                          # Basic QRY tools only
  $0 --dev-env --ai-setup     # Complete development setup
  $0 --ai-setup --skip-models # AI setup without model downloads

${CYAN}After setup:${NC}
  • Use 'qry status' to check workspace
  • Use 'qry tools' to see available tools
  • Use './core/aider-setup-optimization/safe_aider.sh' for AI development
  • Check 'core/ai/' for collaboration procedures

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev-env)
            SETUP_DEV_ENV=true
            shift
            ;;
        --ai-setup)
            SETUP_AI=true
            shift
            ;;
        --skip-models)
            SKIP_MODELS=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            log_error "Unknown option: $1. Use --help for usage."
            ;;
    esac
done

# =============================================================================
# ENVIRONMENT CHECKS
# =============================================================================

check_environment() {
    log_header "Environment Checks"

    # Check if we're in the right directory
    if [[ ! -f "$QRY_ROOT/README.md" ]] || [[ ! -d "$QRY_ROOT/tools" ]]; then
        log_error "Not in QRY workspace root. Run this from the main QRY directory."
    fi

    # Check OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        PACKAGE_MANAGER="apt"
        if command_exists "yum"; then
            PACKAGE_MANAGER="yum"
        elif command_exists "pacman"; then
            PACKAGE_MANAGER="pacman"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PACKAGE_MANAGER="brew"
    else
        log_warn "Unsupported OS: $OSTYPE. Continuing with best effort."
        OS="unknown"
    fi

    log_info "OS: $OS"
    log_info "Package Manager: $PACKAGE_MANAGER"
    log_info "QRY Root: $QRY_ROOT"

    # Check essential tools
    local missing_tools=()
    for tool in git python3 curl; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing essential tools: ${missing_tools[*]}. Please install them first."
    fi

    log_success "Environment checks passed"
}

# =============================================================================
# CORE QRY TOOLS SETUP
# =============================================================================

setup_core_tools() {
    log_header "Core QRY Tools Setup"

    # Install Go (needed for several tools)
    if ! command_exists "go"; then
        log_step "Installing Go..."
        if [[ "$OS" == "linux" ]]; then
            curl -LO https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
            sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            export PATH=$PATH:/usr/local/go/bin
            rm go1.21.0.linux-amd64.tar.gz
        elif [[ "$OS" == "macos" ]]; then
            if command_exists "brew"; then
                brew install go
            else
                log_error "Homebrew required on macOS. Install from https://brew.sh"
            fi
        fi
        log_success "Go installed"
    else
        log_info "Go already installed: $(go version)"
    fi

    # Setup Python virtual environment for tools that need it
    log_step "Setting up Python environment..."
    if [[ ! -d "$QRY_ROOT/tools/doc-search/venv" ]]; then
        cd "$QRY_ROOT/tools/doc-search"
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt 2>/dev/null || log_warn "doc-search requirements install failed"
        cd "$QRY_ROOT"
    fi

    # Install uroboro (if not already installed)
    if ! command_exists "uroboro"; then
        log_step "Installing uroboro..."
        cd "$QRY_ROOT/tools/uroboro"
        if [[ -f "go.mod" ]]; then
            go install ./cmd/uroboro
            log_success "Uroboro installed from source"
        else
            log_warn "Uroboro source not found, skipping"
        fi
        cd "$QRY_ROOT"
    else
        log_info "Uroboro already installed: $(uroboro --version 2>/dev/null || echo 'version unknown')"
    fi

    # Make core scripts executable
    log_step "Setting up core scripts..."
    chmod +x core/scripts/*.sh
    chmod +x core/qry-enhanced
    chmod +x core/install_*.sh

    # Create symlinks for easy access
    if [[ ! -L "/usr/local/bin/qry" ]]; then
        sudo ln -sf "$QRY_ROOT/core/qry-enhanced" /usr/local/bin/qry 2>/dev/null || {
            log_warn "Could not create global 'qry' command. You can use ./core/qry-enhanced instead."
        }
    fi

    log_success "Core QRY tools setup complete"
}

# =============================================================================
# DEVELOPMENT ENVIRONMENT SETUP
# =============================================================================

setup_development_environment() {
    if [[ "$SETUP_DEV_ENV" != "true" ]]; then
        log_info "Skipping development environment setup (use --dev-env to enable)"
        return
    fi

    log_header "Development Environment Setup"

    # Install aider
    if ! command_exists "aider"; then
        log_step "Installing aider..."
        if command_exists "pipx"; then
            pipx install aider-chat
        else
            pip3 install aider-chat --user
        fi
        log_success "Aider installed"
    else
        log_info "Aider already installed: $(aider --version 2>/dev/null || echo 'version unknown')"
    fi

    # Install development tools
    local dev_tools=()
    if [[ "$OS" == "linux" ]]; then
        dev_tools=("neovim" "tmux" "fzf" "ripgrep" "fd-find")
    elif [[ "$OS" == "macos" ]]; then
        dev_tools=("neovim" "tmux" "fzf" "ripgrep" "fd")
    fi

    for tool in "${dev_tools[@]}"; do
        if ! command_exists "$tool"; then
            log_step "Installing $tool..."
            case "$PACKAGE_MANAGER" in
                "apt")
                    sudo apt update && sudo apt install -y "$tool"
                    ;;
                "brew")
                    brew install "$tool"
                    ;;
                "yum")
                    sudo yum install -y "$tool"
                    ;;
                "pacman")
                    sudo pacman -S --noconfirm "$tool"
                    ;;
            esac
        fi
    done

    # Setup aider configuration
    log_step "Configuring aider integration..."
    if [[ -d "$QRY_ROOT/core/aider-setup-optimization" ]]; then
        cd "$QRY_ROOT/core/aider-setup-optimization"

        # Copy configuration files
        cp .aider.conf.yml ~/.aider.conf.yml 2>/dev/null || true
        cp .aiderignore ~/.aiderignore 2>/dev/null || true

        # Setup shell aliases
        if [[ -f ".aider_aliases.sh" ]]; then
            if ! grep -q "aider_aliases" ~/.bashrc; then
                echo "# QRY Aider aliases" >> ~/.bashrc
                echo "source $QRY_ROOT/core/aider-setup-optimization/.aider_aliases.sh" >> ~/.bashrc
            fi
        fi

        # Make scripts executable
        chmod +x *.sh

        cd "$QRY_ROOT"
        log_success "Aider configuration complete"
    else
        log_warn "Aider setup optimization not found"
    fi

    log_success "Development environment setup complete"
}

# =============================================================================
# AI INFRASTRUCTURE SETUP
# =============================================================================

setup_ai_infrastructure() {
    if [[ "$SETUP_AI" != "true" ]]; then
        log_info "Skipping AI infrastructure setup (use --ai-setup to enable)"
        return
    fi

    log_header "AI Infrastructure Setup"

    # Install Ollama
    if ! command_exists "ollama"; then
        log_step "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
        log_success "Ollama installed"
    else
        log_info "Ollama already installed"
    fi

    # Start Ollama service
    log_step "Starting Ollama service..."
    if [[ "$OS" == "linux" ]]; then
        systemctl --user enable ollama 2>/dev/null || true
        systemctl --user start ollama 2>/dev/null || ollama serve &
    else
        ollama serve &
    fi

    # Wait for Ollama to be ready
    local attempts=0
    while ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
        if [[ $attempts -ge 30 ]]; then
            log_error "Ollama failed to start after 30 seconds"
        fi
        sleep 1
        ((attempts++))
    done

    # Install AI models (unless skipped)
    if [[ "$SKIP_MODELS" != "true" ]]; then
        log_step "Installing AI models..."

        # Essential models based on aider setup optimization
        local models=("qwen2.5-coder:0.5b" "qwen2.5:7b" "nomic-embed-text")

        for model in "${models[@]}"; do
            log_info "Pulling model: $model"
            ollama pull "$model" || log_warn "Failed to pull $model"
        done

        log_success "AI models installed"
    else
        log_info "Skipping model downloads (use ollama pull <model> to install later)"
    fi

    # Setup AI collaboration files
    log_step "Setting up AI collaboration procedures..."
    ensure_dir "$HOME/.qry"

    # Copy AI collaboration procedures to user config
    if [[ -d "$QRY_ROOT/core/ai" ]]; then
        cp -r "$QRY_ROOT/core/ai" "$HOME/.qry/" 2>/dev/null || true
        log_success "AI collaboration procedures available in ~/.qry/ai/"
    fi

    log_success "AI infrastructure setup complete"
}

# =============================================================================
# INTEGRATION TESTING
# =============================================================================

run_integration_tests() {
    log_header "Integration Testing"

    local tests_passed=0
    local tests_failed=0

    # Test 1: QRY command
    log_step "Testing QRY command..."
    if "$QRY_ROOT/core/qry-enhanced" status >/dev/null 2>&1; then
        log_success "QRY command working"
        ((tests_passed++))
    else
        log_warn "QRY command failed"
        ((tests_failed++))
    fi

    # Test 2: Uroboro
    if command_exists "uroboro"; then
        log_step "Testing uroboro..."
        if uroboro capture "QRY workspace setup test" >/dev/null 2>&1; then
            log_success "Uroboro working"
            ((tests_passed++))
        else
            log_warn "Uroboro failed"
            ((tests_failed++))
        fi
    fi

    # Test 3: Doc search
    log_step "Testing doc-search..."
    if [[ -x "$QRY_ROOT/tools/doc-search/qry-search" ]]; then
        log_success "Doc-search available"
        ((tests_passed++))
    else
        log_warn "Doc-search not working"
        ((tests_failed++))
    fi

    # Test 4: Aider (if dev env was set up)
    if [[ "$SETUP_DEV_ENV" == "true" ]] && command_exists "aider"; then
        log_step "Testing aider..."
        if aider --version >/dev/null 2>&1; then
            log_success "Aider working"
            ((tests_passed++))
        else
            log_warn "Aider failed"
            ((tests_failed++))
        fi
    fi

    # Test 5: Ollama (if AI was set up)
    if [[ "$SETUP_AI" == "true" ]]; then
        log_step "Testing Ollama..."
        if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
            log_success "Ollama working"
            ((tests_passed++))
        else
            log_warn "Ollama not responding"
            ((tests_failed++))
        fi
    fi

    log_info "Tests passed: $tests_passed, Tests failed: $tests_failed"

    if [[ $tests_failed -gt 0 ]]; then
        log_warn "Some tests failed. Check the setup manually."
    else
        log_success "All integration tests passed!"
    fi
}

# =============================================================================
# FINAL SETUP SUMMARY
# =============================================================================

show_setup_summary() {
    log_header "QRY Workspace Setup Complete!"

    echo -e "${GREEN}🎉 Your QRY workspace is ready!${NC}"
    echo ""
    echo -e "${CYAN}Quick Start:${NC}"
    echo "  • Check status: ${YELLOW}qry status${NC}"
    echo "  • List tools: ${YELLOW}qry tools${NC}"
    echo "  • Capture work: ${YELLOW}qry capture \"your message\"${NC}"
    echo "  • Search everything: ${YELLOW}qry search \"your terms\"${NC}"
    echo ""

    if [[ "$SETUP_DEV_ENV" == "true" ]]; then
        echo -e "${CYAN}Development Environment:${NC}"
        echo "  • Start aider: ${YELLOW}./core/aider-setup-optimization/safe_aider.sh${NC}"
        echo "  • Aider config: ${YELLOW}~/.aider.conf.yml${NC}"
        echo "  • Shell aliases: ${YELLOW}source ~/.bashrc${NC}"
        echo ""
    fi

    if [[ "$SETUP_AI" == "true" ]]; then
        echo -e "${CYAN}AI Infrastructure:${NC}"
        echo "  • Ollama status: ${YELLOW}ollama list${NC}"
        echo "  • AI procedures: ${YELLOW}~/.qry/ai/${NC}"
        echo "  • Pull more models: ${YELLOW}ollama pull <model-name>${NC}"
        echo ""
    fi

    echo -e "${CYAN}Documentation:${NC}"
    echo "  • Workspace README: ${YELLOW}$QRY_ROOT/README.md${NC}"
    echo "  • AI collaboration: ${YELLOW}$QRY_ROOT/core/ai/${NC}"
    echo "  • Aider setup guide: ${YELLOW}$QRY_ROOT/core/aider-setup-optimization/README.md${NC}"
    echo ""

    echo -e "${CYAN}Key Directories:${NC}"
    echo "  • ${YELLOW}tools/${NC}     - CLI utilities (uroboro, wherewasi, examinator, etc.)"
    echo "  • ${YELLOW}experiments/${NC} - Active prototypes and projects"
    echo "  • ${YELLOW}zone/${NC}      - Main website (qry.zone)"
    echo "  • ${YELLOW}core/${NC}      - Orchestration, AI collaboration, scripts"
    echo ""

    echo -e "${GREEN}Happy building! 🚀${NC}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ██████  ██████  ██    ██                                    ║
    ║  ██    ██ ██   ██  ██  ██                                     ║
    ║  ██    ██ ██████    ████     Workspace Setup v2.0            ║
    ║  ██ ▄▄ ██ ██   ██    ██                                      ║
    ║   ██████  ██   ██    ██      Systematic Tool Building        ║
    ║      ▀▀                                                       ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Show what will be set up
    echo -e "${BLUE}Setup Configuration:${NC}"
    echo "  • Core QRY Tools: ${GREEN}✓${NC}"
    echo "  • Development Environment: $(if [[ "$SETUP_DEV_ENV" == "true" ]]; then echo -e "${GREEN}✓${NC}"; else echo -e "${YELLOW}○${NC}"; fi)"
    echo "  • AI Infrastructure: $(if [[ "$SETUP_AI" == "true" ]]; then echo -e "${GREEN}✓${NC}"; else echo -e "${YELLOW}○${NC}"; fi)"
    echo "  • Model Downloads: $(if [[ "$SKIP_MODELS" == "true" ]]; then echo -e "${YELLOW}○${NC}"; else echo -e "${GREEN}✓${NC}"; fi)"
    echo ""

    # Ask for confirmation
    read -p "Proceed with setup? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Setup cancelled"
        exit 0
    fi

    # Run setup phases
    check_environment
    setup_core_tools
    setup_development_environment
    setup_ai_infrastructure
    run_integration_tests
    show_setup_summary

    # Record the setup
    if command_exists "uroboro"; then
        uroboro capture "QRY workspace setup complete - dev_env:$SETUP_DEV_ENV ai:$SETUP_AI" 2>/dev/null || true
    fi
}

# Run main function
main "$@"

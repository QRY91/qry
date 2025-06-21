#!/bin/bash
# Aider Setup Optimization - Automated Installation Script
# Implements HN community insights for local AI development
# Author: QRY Labs - Systematic AI Integration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_CONFIG_DIR="$HOME/.config"
ZELLIJ_CONFIG_DIR="$HOME_CONFIG_DIR/zellij"
NVIM_CONFIG_DIR="$HOME_CONFIG_DIR/nvim"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

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

log_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Capture progress with uroboro if available
capture_progress() {
    if command_exists uroboro; then
        uroboro capture "$1" >/dev/null 2>&1 || true
    fi
}

# =============================================================================
# SYSTEM DETECTION
# =============================================================================

detect_system() {
    log_step "Detecting system configuration..."

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if command_exists apt; then
            DISTRO="debian"
        elif command_exists pacman; then
            DISTRO="arch"
        elif command_exists dnf; then
            DISTRO="fedora"
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    else
        OS="unknown"
        DISTRO="unknown"
    fi

    log_info "Detected: $OS ($DISTRO)"
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

check_prerequisites() {
    log_step "Checking prerequisites..."

    local missing_deps=()

    # Check for essential tools
    if ! command_exists git; then
        missing_deps+=("git")
    fi

    if ! command_exists python3; then
        missing_deps+=("python3")
    fi

    if ! command_exists pip || ! command_exists pip3; then
        missing_deps+=("python3-pip")
    fi

    if ! command_exists curl; then
        missing_deps+=("curl")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies first:"

        case $DISTRO in
            "debian")
                echo "  sudo apt update && sudo apt install -y ${missing_deps[*]}"
                ;;
            "arch")
                echo "  sudo pacman -S ${missing_deps[*]}"
                ;;
            "fedora")
                echo "  sudo dnf install -y ${missing_deps[*]}"
                ;;
            "macos")
                echo "  brew install ${missing_deps[*]}"
                ;;
        esac
        exit 1
    fi

    log_success "All prerequisites available"
}

# =============================================================================
# OLLAMA INSTALLATION
# =============================================================================

install_ollama() {
    log_step "Installing Ollama..."

    if command_exists ollama; then
        log_success "Ollama already installed"
        return 0
    fi

    case $OS in
        "linux"|"macos")
            curl -fsSL https://ollama.ai/install.sh | sh
            ;;
        *)
            log_error "Unsupported OS for automatic Ollama installation: $OS"
            log_info "Please install Ollama manually from https://ollama.ai"
            exit 1
            ;;
    esac

    # Wait for ollama to be ready
    sleep 3

    if command_exists ollama; then
        log_success "Ollama installed successfully"
    else
        log_error "Ollama installation failed"
        exit 1
    fi
}

# =============================================================================
# AIDER INSTALLATION
# =============================================================================

install_aider() {
    log_step "Installing Aider..."

    if command_exists aider; then
        log_success "Aider already installed"
        return 0
    fi

    pip3 install --user aider-chat

    # Check if aider is in PATH
    if ! command_exists aider; then
        log_warning "Aider installed but not in PATH"
        log_info "You may need to add ~/.local/bin to your PATH"

        # Try to add to shell rc files
        for rcfile in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [[ -f "$rcfile" ]]; then
                if ! grep -q "/.local/bin" "$rcfile"; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rcfile"
                    log_info "Added ~/.local/bin to PATH in $rcfile"
                fi
            fi
        done

        export PATH="$HOME/.local/bin:$PATH"
    fi

    if command_exists aider; then
        log_success "Aider installed successfully ($(aider --version))"
    else
        log_error "Aider installation failed"
        exit 1
    fi
}

# =============================================================================
# ZELLIJ INSTALLATION
# =============================================================================

install_zellij() {
    log_step "Installing Zellij..."

    if command_exists zellij; then
        log_success "Zellij already installed"
        return 0
    fi

    case $OS in
        "linux")
            # Install via cargo if available, otherwise download binary
            if command_exists cargo; then
                cargo install zellij
            else
                log_info "Installing Rust and Cargo first..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
                cargo install zellij
            fi
            ;;
        "macos")
            if command_exists brew; then
                brew install zellij
            else
                log_error "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            ;;
        *)
            log_error "Unsupported OS for automatic Zellij installation: $OS"
            exit 1
            ;;
    esac

    if command_exists zellij; then
        log_success "Zellij installed successfully"
    else
        log_error "Zellij installation failed"
        exit 1
    fi
}

# =============================================================================
# MODEL SETUP
# =============================================================================

setup_models() {
    log_step "Setting up Qwen models..."

    # Start ollama if not running
    if ! pgrep -f ollama >/dev/null; then
        log_info "Starting Ollama service..."
        ollama serve &
        sleep 5
    fi

    # Download models
    log_info "Downloading qwen2.5-coder:0.5b-instruct (fast model)..."
    ollama pull qwen2.5-coder:0.5b-instruct

    log_info "Downloading qwen2.5:3b (quality model)..."
    ollama pull qwen2.5:3b

    # Test models
    log_info "Testing models..."
    if echo "Hello" | ollama run qwen2.5-coder:0.5b-instruct >/dev/null 2>&1; then
        log_success "Fast model (0.5b) working"
    else
        log_error "Fast model test failed"
    fi

    if echo "Hello" | ollama run qwen2.5:3b >/dev/null 2>&1; then
        log_success "Quality model (3b) working"
    else
        log_error "Quality model test failed"
    fi
}

# =============================================================================
# CONFIGURATION SETUP
# =============================================================================

setup_configurations() {
    log_step "Setting up configuration files..."

    # Create config directories
    mkdir -p "$HOME_CONFIG_DIR"
    mkdir -p "$ZELLIJ_CONFIG_DIR/layouts"
    mkdir -p "$NVIM_CONFIG_DIR"

    # Copy aider configuration
    if [[ -f "$SCRIPT_DIR/.aider.conf.yml" ]]; then
        cp "$SCRIPT_DIR/.aider.conf.yml" "$HOME/"
        log_success "Aider configuration copied to ~/.aider.conf.yml"
    fi

    # Copy aiderignore
    if [[ -f "$SCRIPT_DIR/.aiderignore" ]]; then
        cp "$SCRIPT_DIR/.aiderignore" "$HOME/"
        log_success "Aiderignore copied to ~/.aiderignore"
    fi

    # Copy zellij layout
    if [[ -f "$SCRIPT_DIR/.config/zellij/layouts/qry-ai-dev.kdl" ]]; then
        cp "$SCRIPT_DIR/.config/zellij/layouts/qry-ai-dev.kdl" "$ZELLIJ_CONFIG_DIR/layouts/"
        log_success "Zellij layout copied"
    fi

    # Setup shell aliases
    if [[ -f "$SCRIPT_DIR/.aider_aliases.sh" ]]; then
        cp "$SCRIPT_DIR/.aider_aliases.sh" "$HOME/"

        # Add to shell rc files
        for rcfile in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [[ -f "$rcfile" ]]; then
                if ! grep -q ".aider_aliases.sh" "$rcfile"; then
                    echo "" >> "$rcfile"
                    echo "# Aider Setup Optimization" >> "$rcfile"
                    echo "source ~/.aider_aliases.sh" >> "$rcfile"
                    log_success "Added aliases to $rcfile"
                fi
            fi
        done
    fi
}

# =============================================================================
# NEOVIM INTEGRATION
# =============================================================================

setup_neovim_integration() {
    log_step "Setting up Neovim integration..."

    if ! command_exists nvim; then
        log_warning "Neovim not found - skipping Neovim integration"
        return 0
    fi

    # Check if user wants to integrate with existing config
    if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
        log_info "Existing Neovim configuration found"
        read -p "Do you want to backup and update your init.lua with aider integration? (y/n): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Backup existing config
            cp "$NVIM_CONFIG_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua.backup.$(date +%Y%m%d-%H%M%S)"
            log_success "Backed up existing init.lua"

            # Copy enhanced config if available
            if [[ -f "$SCRIPT_DIR/copy_of_init.lua" ]]; then
                cp "$SCRIPT_DIR/copy_of_init.lua" "$NVIM_CONFIG_DIR/init.lua"
                log_success "Updated init.lua with aider integration"
            fi
        fi
    else
        # Copy init.lua if available
        if [[ -f "$SCRIPT_DIR/copy_of_init.lua" ]]; then
            cp "$SCRIPT_DIR/copy_of_init.lua" "$NVIM_CONFIG_DIR/init.lua"
            log_success "Created init.lua with aider integration"
        fi
    fi
}

# =============================================================================
# VALIDATION TESTS
# =============================================================================

run_validation_tests() {
    log_step "Running validation tests..."

    local failures=0

    # Test ollama
    if ! command_exists ollama; then
        log_error "Ollama validation failed"
        ((failures++))
    else
        log_success "Ollama: ✓"
    fi

    # Test aider
    if ! command_exists aider; then
        log_error "Aider validation failed"
        ((failures++))
    else
        log_success "Aider: ✓ ($(aider --version))"
    fi

    # Test zellij
    if ! command_exists zellij; then
        log_error "Zellij validation failed"
        ((failures++))
    else
        log_success "Zellij: ✓"
    fi

    # Test models
    if ollama list | grep -q "qwen2.5-coder:0.5b-instruct"; then
        log_success "Fast model: ✓"
    else
        log_error "Fast model validation failed"
        ((failures++))
    fi

    if ollama list | grep -q "qwen2.5:3b"; then
        log_success "Quality model: ✓"
    else
        log_error "Quality model validation failed"
        ((failures++))
    fi

    # Test configuration files
    if [[ -f "$HOME/.aider.conf.yml" ]]; then
        log_success "Aider config: ✓"
    else
        log_error "Aider config validation failed"
        ((failures++))
    fi

    if [[ -f "$ZELLIJ_CONFIG_DIR/layouts/qry-ai-dev.kdl" ]]; then
        log_success "Zellij layout: ✓"
    else
        log_error "Zellij layout validation failed"
        ((failures++))
    fi

    return $failures
}

# =============================================================================
# PERFORMANCE BENCHMARK
# =============================================================================

run_performance_benchmark() {
    log_step "Running performance benchmark..."

    local test_prompt="Write a simple hello world function in Python"

    log_info "Testing qwen2.5-coder:0.5b-instruct (fast model)..."
    local fast_time=$(time (echo "$test_prompt" | ollama run qwen2.5-coder:0.5b-instruct >/dev/null 2>&1) 2>&1 | grep real | awk '{print $2}')

    log_info "Testing qwen2.5:3b (quality model)..."
    local quality_time=$(time (echo "$test_prompt" | ollama run qwen2.5:3b >/dev/null 2>&1) 2>&1 | grep real | awk '{print $2}')

    log_success "Performance Results:"
    echo "  Fast model (0.5b):    $fast_time"
    echo "  Quality model (3b):   $quality_time"
}

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

show_usage_instructions() {
    log_success "🎉 Aider Setup Optimization Installation Complete!"
    echo
    echo "========================================"
    echo "QUICK START GUIDE"
    echo "========================================"
    echo
    echo "1. Restart your terminal or run:"
    echo "   source ~/.bashrc  # or ~/.zshrc"
    echo
    echo "2. Launch QRY AI Development Environment:"
    echo "   qdev"
    echo
    echo "3. Quick Commands:"
    echo "   aq          - Quick aider (0.5b model)"
    echo "   aiq         - Quality aider (3b model)"
    echo "   aic         - Chat mode"
    echo "   aider_help  - Show all commands"
    echo
    echo "4. Neovim Integration:"
    echo "   <leader>ai  - Aider with current file"
    echo "   <leader>ac  - Aider chat mode"
    echo "   <leader>aq  - Quality mode (3b+0.5b)"
    echo
    echo "5. Monitor Performance:"
    echo "   ai_status   - Check model status"
    echo "   ai_benchmark - Test performance"
    echo
    echo "========================================"
    echo "NEXT STEPS"
    echo "========================================"
    echo
    echo "• Review configuration files in ~/"
    echo "• Customize .aiderignore for your projects"
    echo "• Explore the zellij layout: qdev"
    echo "• Read the documentation in README.md"
}

# =============================================================================
# MAIN INSTALLATION FLOW
# =============================================================================

main() {
    echo "========================================"
    echo "🤖 AIDER SETUP OPTIMIZATION"
    echo "========================================"
    echo "Local AI Development Environment"
    echo "Based on HN Community Insights"
    echo "QRY Labs - Systematic AI Integration"
    echo "========================================"
    echo

    capture_progress "Starting aider setup optimization installation"

    # System detection
    detect_system

    # Prerequisites
    check_prerequisites

    # Core installations
    install_ollama
    install_aider
    install_zellij

    # Model setup
    setup_models

    # Configuration
    setup_configurations
    setup_neovim_integration

    # Validation
    if run_validation_tests; then
        log_success "All validation tests passed!"
    else
        log_warning "Some validation tests failed. Check the output above."
    fi

    # Performance benchmark
    run_performance_benchmark

    # Usage instructions
    show_usage_instructions

    capture_progress "Completed aider setup optimization installation successfully"

    log_success "Installation completed successfully! 🚀"
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

trap 'log_error "Installation failed at line $LINENO. Check the output above for details."' ERR

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

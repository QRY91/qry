#!/bin/bash

# QRY Prompt Installer
# Installs nerd fonts and sets up the QRY shell prompt

set -e

# Configuration
INSTALL_DIR="$HOME/.local/share/qry-prompt"
FONTS_DIR="$HOME/.local/share/fonts"
NERD_FONTS_VERSION="v3.2.1"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[QRY-PROMPT]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[QRY-PROMPT]${NC} $1"
}

error() {
    echo -e "${RED}[QRY-PROMPT]${NC} $1"
}

info() {
    echo -e "${BLUE}[QRY-PROMPT]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Install system dependencies
install_dependencies() {
    local os=$(detect_os)
    
    case $os in
        linux)
            if command_exists apt-get; then
                log "Installing dependencies with apt..."
                sudo apt-get update
                sudo apt-get install -y wget unzip fontconfig
            elif command_exists yum; then
                log "Installing dependencies with yum..."
                sudo yum install -y wget unzip fontconfig
            elif command_exists pacman; then
                log "Installing dependencies with pacman..."
                sudo pacman -S --noconfirm wget unzip fontconfig
            else
                warn "Could not detect package manager. Please install wget, unzip, and fontconfig manually."
            fi
            ;;
        macos)
            if command_exists brew; then
                log "Installing dependencies with brew..."
                brew install wget unzip
            else
                warn "Homebrew not found. Please install wget and unzip manually."
            fi
            ;;
        *)
            warn "OS not detected or unsupported. Please install wget and unzip manually."
            ;;
    esac
}

# Download and install nerd fonts
install_nerd_fonts() {
    local fonts=(
        "FiraCode"
        "JetBrainsMono" 
        "Hack"
        "SourceCodePro"
        "UbuntuMono"
    )
    
    log "Creating fonts directory..."
    mkdir -p "$FONTS_DIR"
    
    for font in "${fonts[@]}"; do
        log "Installing $font Nerd Font..."
        
        local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${font}.zip"
        local temp_file="/tmp/${font}.zip"
        
        # Download font
        if wget -q "$font_url" -O "$temp_file"; then
            # Extract to fonts directory
            unzip -o "$temp_file" -d "$FONTS_DIR" >/dev/null 2>&1
            rm "$temp_file"
            info "✓ Installed $font"
        else
            warn "✗ Failed to download $font"
        fi
    done
    
    # Refresh font cache
    log "Refreshing font cache..."
    if command_exists fc-cache; then
        fc-cache -f "$FONTS_DIR"
    fi
    
    log "Nerd fonts installation complete!"
}

# Install QRY prompt
install_qry_prompt() {
    log "Installing QRY prompt..."
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy prompt script
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp "$script_dir/qry-prompt.sh" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/qry-prompt.sh"
    
    info "✓ QRY prompt installed to $INSTALL_DIR"
}

# Setup shell integration
setup_shell_integration() {
    local shell_name=$(basename "$SHELL")
    
    case $shell_name in
        bash)
            setup_bash_integration
            ;;
        zsh)
            setup_zsh_integration
            ;;
        fish)
            setup_fish_integration
            ;;
        *)
            warn "Shell '$shell_name' not fully supported. Manual setup required."
            show_manual_setup
            ;;
    esac
}

setup_bash_integration() {
    local bashrc="$HOME/.bashrc"
    local source_line="source \"$INSTALL_DIR/qry-prompt.sh\""
    
    # Check for existing Starship
    if grep -q "starship init" "$bashrc" 2>/dev/null; then
        warn "Starship detected in ~/.bashrc"
        read -p "Comment out Starship to avoid conflicts? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "Commenting out Starship initialization..."
            sed -i 's/^[[:space:]]*eval.*starship init.*/#&  # Commented by QRY Prompt installer/' "$bashrc"
            info "✓ Starship commented out (can be restored by uncommenting)"
        fi
    fi
    
    if ! grep -q "qry-prompt.sh" "$bashrc" 2>/dev/null; then
        log "Adding QRY prompt to ~/.bashrc..."
        echo "" >> "$bashrc"
        echo "# QRY Prompt" >> "$bashrc"
        echo "$source_line" >> "$bashrc"
        info "✓ Added to ~/.bashrc"
    else
        info "✓ QRY prompt already configured in ~/.bashrc"
    fi
}

setup_zsh_integration() {
    local zshrc="$HOME/.zshrc"
    local source_line="source \"$INSTALL_DIR/qry-prompt.sh\""
    
    if ! grep -q "qry-prompt.sh" "$zshrc" 2>/dev/null; then
        log "Adding QRY prompt to ~/.zshrc..."
        echo "" >> "$zshrc"
        echo "# QRY Prompt" >> "$zshrc"
        echo "$source_line" >> "$zshrc"
        info "✓ Added to ~/.zshrc"
    else
        info "✓ QRY prompt already configured in ~/.zshrc"
    fi
}

setup_fish_integration() {
    log "Setting up Fish shell integration..."
    # Fish integration is handled directly in the prompt script
    source "$INSTALL_DIR/qry-prompt.sh"
    info "✓ Fish shell integration complete"
}

show_manual_setup() {
    info "Manual setup instructions:"
    info "Add this line to your shell's config file:"
    info "source \"$INSTALL_DIR/qry-prompt.sh\""
}

# Test font installation
test_fonts() {
    log "Testing nerd font installation..."
    
    echo "If you see icons below, nerd fonts are working:"
    echo "📁 Folder: 󰉋"
    echo "🌿 Git: "
    echo "👤 User: "
    echo "🖥️  Host: 󰍹"
    echo "➜ Arrow: "
    echo "✓ Check: "
    echo "✗ Cross: "
    echo ""
    
    read -p "Do you see the icons properly? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Great! Nerd fonts are working correctly."
    else
        warn "Fonts may not be working. Try:"
        warn "1. Restart your terminal"
        warn "2. Change your terminal font to a Nerd Font"
        warn "3. Check font installation with: fc-list | grep -i nerd"
    fi
}

# Main installation function
main() {
    info "QRY Prompt Installer"
    info "===================="
    
    # Check if running in supported environment
    if [[ -z "$BASH_VERSION" ]] && [[ -z "$ZSH_VERSION" ]] && [[ "$SHELL" != */fish ]]; then
        error "Please run this installer in bash, zsh, or fish shell"
        exit 1
    fi
    
    # Install dependencies
    install_dependencies
    
    # Install nerd fonts
    install_nerd_fonts
    
    # Install QRY prompt
    install_qry_prompt
    
    # Setup shell integration
    setup_shell_integration
    
    # Test installation
    test_fonts
    
    log "Installation complete!"
    info "Restart your terminal or run: source ~/.$(basename "$SHELL")rc"
    info "Or for immediate effect: source \"$INSTALL_DIR/qry-prompt.sh\""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fonts-only)
            install_nerd_fonts
            exit 0
            ;;
        --prompt-only)
            install_qry_prompt
            setup_shell_integration
            exit 0
            ;;
        --test)
            test_fonts
            exit 0
            ;;
        -h|--help)
            echo "QRY Prompt Installer"
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --fonts-only    Install only nerd fonts"
            echo "  --prompt-only   Install only the prompt (skip fonts)"
            echo "  --test          Test font installation"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Run main installation if no specific options provided
main
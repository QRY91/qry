#!/bin/bash

# QRY Prompt Uninstaller
# Safely removes QRY Prompt and restores previous setup

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[UNINSTALL]${NC} $1"; }
warn() { echo -e "${YELLOW}[UNINSTALL]${NC} $1"; }
info() { echo -e "${BLUE}[UNINSTALL]${NC} $1"; }
error() { echo -e "${RED}[UNINSTALL]${NC} $1"; }

INSTALL_DIR="$HOME/.local/share/qry-prompt"

# Remove from shell configs
remove_from_shell_configs() {
    local files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.config/fish/config.fish"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            if grep -q "qry-prompt" "$file" 2>/dev/null; then
                log "Removing QRY Prompt from $(basename "$file")..."
                
                # Remove QRY Prompt lines
                sed -i '/# QRY Prompt/d' "$file"
                sed -i '\|qry-prompt|d' "$file"
                
                # Restore Starship if it was commented out
                if grep -q "# Commented by QRY Prompt installer" "$file"; then
                    log "Restoring Starship in $(basename "$file")..."
                    sed -i 's/^#\(.*starship init.*\)  # Commented by QRY Prompt installer/\1/' "$file"
                fi
                
                info "✓ Cleaned $(basename "$file")"
            fi
        fi
    done
}

# Remove Fish function
remove_fish_function() {
    local fish_func="$HOME/.config/fish/functions/fish_prompt.fish"
    if [[ -f "$fish_func" ]]; then
        if grep -q "QRY Prompt" "$fish_func" 2>/dev/null; then
            log "Removing QRY Prompt fish function..."
            rm "$fish_func"
            info "✓ Removed fish prompt function"
        fi
    fi
}

# Main uninstall
main() {
    info "QRY Prompt Uninstaller"
    info "======================"
    
    # Confirm uninstall
    read -p "Remove QRY Prompt and restore previous setup? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Uninstall cancelled"
        exit 0
    fi
    
    # Remove installation directory
    if [[ -d "$INSTALL_DIR" ]]; then
        log "Removing installation directory..."
        rm -rf "$INSTALL_DIR"
        info "✓ Removed $INSTALL_DIR"
    fi
    
    # Remove from shell configs
    remove_from_shell_configs
    
    # Remove fish function
    remove_fish_function
    
    log "QRY Prompt uninstalled successfully!"
    info "Restart your terminal or source your shell config to complete removal"
    
    # Ask about fonts
    echo ""
    read -p "Also remove installed Nerd Fonts? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        warn "Removing Nerd Fonts..."
        rm -f ~/.local/share/fonts/*Nerd* 2>/dev/null || true
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f ~/.local/share/fonts
        fi
        info "✓ Nerd Fonts removed"
    else
        info "Nerd Fonts kept (can be used by other applications)"
    fi
    
    echo ""
    log "Uninstall complete! Your original prompt should be restored."
}

# Parse arguments
case "${1:-}" in
    --config-only)
        remove_from_shell_configs
        remove_fish_function
        log "Removed QRY Prompt from shell configs only"
        ;;
    --help|-h)
        echo "QRY Prompt Uninstaller"
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --config-only   Remove only shell config changes"
        echo "  -h, --help      Show this help"
        ;;
    *)
        main
        ;;
esac
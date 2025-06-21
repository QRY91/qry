#!/bin/bash

# QRY Enhanced Installation Script
# Installs the context-aware CLI development environment
# Version: 0.2.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
INSTALL_DIR="$HOME/bin"
CONFIG_DIR="$HOME/.config/qry"
DATA_DIR="$HOME/.local/share/qry"
QRY_SCRIPT="qry_enhanced"
TARGET_NAME="qry"

print_header() {
    echo -e "${BLUE}${BOLD}🚀 QRY Enhanced Installer${NC}"
    echo "=================================="
}

print_step() {
    echo -e "${CYAN}▶️${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Check dependencies
check_dependencies() {
    print_step "Checking dependencies..."

    local missing_deps=()

    # Essential tools
    for tool in bash find grep sed awk; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_deps+=("$tool")
        fi
    done

    # Recommended tools
    local recommended=("jq" "tmux" "git" "zoxide")
    local missing_recommended=()

    for tool in "${recommended[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_recommended+=("$tool")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing essential dependencies: ${missing_deps[*]}"
        exit 1
    fi

    if [[ ${#missing_recommended[@]} -gt 0 ]]; then
        print_warning "Missing recommended tools: ${missing_recommended[*]}"
        echo "  Install them for enhanced functionality:"
        case "$(uname)" in
            "Darwin")
                echo "  brew install ${missing_recommended[*]}"
                ;;
            "Linux")
                echo "  sudo apt install ${missing_recommended[*]}"
                echo "  # or your distribution's package manager"
                ;;
        esac
        echo
    fi

    print_success "Dependencies check complete"
}

# Create directory structure
setup_directories() {
    print_step "Setting up directory structure..."

    # Create directories
    mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR"

    # Create subdirectories
    mkdir -p "$CONFIG_DIR"/{sessions,templates,backups}
    mkdir -p "$DATA_DIR"/{procedures,contexts,logs}

    print_success "Directory structure created"
}

# Install the main script
install_script() {
    print_step "Installing QRY command..."

    # Check if source script exists
    if [[ ! -f "$QRY_SCRIPT" ]]; then
        print_error "Source script '$QRY_SCRIPT' not found in current directory"
        exit 1
    fi

    # Backup existing installation
    if [[ -f "$INSTALL_DIR/$TARGET_NAME" ]]; then
        local backup_name="$TARGET_NAME.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing installation to $backup_name"
        cp "$INSTALL_DIR/$TARGET_NAME" "$CONFIG_DIR/backups/$backup_name"
    fi

    # Copy script
    cp "$QRY_SCRIPT" "$INSTALL_DIR/$TARGET_NAME"
    chmod +x "$INSTALL_DIR/$TARGET_NAME"

    print_success "QRY command installed to $INSTALL_DIR/$TARGET_NAME"
}

# Initialize configuration
init_config() {
    print_step "Initializing configuration..."

    # Create main config file
    cat > "$CONFIG_DIR/config.yaml" << EOF
# QRY Enhanced Configuration
# Auto-generated on $(date)

qry:
  version: "0.2.0"
  root: "${QRY_ROOT:-$PWD}"

navigation:
  fuzzy_threshold: 0.6
  show_context: true
  auto_context_update: true

tools:
  uroboro: auto-detect
  wherewasi: auto-detect
  qoins: auto-detect
  doggowoof: auto-detect
  slopsquid: auto-detect

ai:
  provider: ollama
  default_model: mistral:latest
  endpoint: http://localhost:11434

session:
  manager: tmux
  auto_create: true
  default_layout: main-vertical

appearance:
  colors: true
  emoji: true
  compact_mode: false
EOF

    # Create projects database
    cat > "$CONFIG_DIR/projects.json" << EOF
{
  "projects": {},
  "aliases": {},
  "categories": {
    "tools": ["uroboro", "qoins", "slopsquid", "doggowoof", "wherewasi"],
    "games": ["qoinbots", "quantum_dice", "feline-fortune"],
    "web": ["sites", "web-apps"],
    "experiments": ["prototypes", "research", "ai"]
  },
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "1.0"
}
EOF

    # Create procedures database
    cat > "$CONFIG_DIR/procedures.json" << EOF
{
  "procedures": {},
  "shortcuts": {},
  "notes": {},
  "templates": {},
  "version": "1.0"
}
EOF

    print_success "Configuration initialized"
}

# Set up shell integration
setup_shell_integration() {
    print_step "Setting up shell integration..."

    # Detect shell
    local shell_name=$(basename "$SHELL")
    local shell_config=""

    case "$shell_name" in
        "bash")
            shell_config="$HOME/.bashrc"
            if [[ "$(uname)" == "Darwin" ]]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        "zsh")
            shell_config="$HOME/.zshrc"
            ;;
        "fish")
            shell_config="$HOME/.config/fish/config.fish"
            ;;
        *)
            print_warning "Unknown shell: $shell_name"
            print_info "Please manually add $INSTALL_DIR to your PATH"
            return 0
            ;;
    esac

    # Check if PATH already includes install directory
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_info "PATH already includes $INSTALL_DIR"
    else
        # Add to PATH in shell config
        if [[ -f "$shell_config" ]]; then
            local path_line="export PATH=\"$INSTALL_DIR:\$PATH\""

            # Check if already added
            if ! grep -q "$INSTALL_DIR" "$shell_config" 2>/dev/null; then
                echo "" >> "$shell_config"
                echo "# QRY Enhanced CLI Environment" >> "$shell_config"
                echo "$path_line" >> "$shell_config"
                print_success "Added $INSTALL_DIR to PATH in $shell_config"
            else
                print_info "PATH entry already exists in $shell_config"
            fi
        else
            print_warning "Shell config file not found: $shell_config"
            print_info "Please manually add to your shell configuration:"
            echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        fi
    fi

    # Set up completion (if supported)
    if [[ "$shell_name" == "bash" ]] || [[ "$shell_name" == "zsh" ]]; then
        local completion_line="complete -W 'cd ls capture costs health ai slop morning status session help remember procedures context' qry"
        if [[ "$shell_name" == "zsh" ]]; then
            completion_line="autoload -U compinit && compinit && compdef '_arguments \"1:command:(cd ls capture costs health ai slop morning status session help remember procedures context)\"' qry"
        fi

        if [[ -f "$shell_config" ]] && ! grep -q "complete.*qry" "$shell_config" 2>/dev/null; then
            echo "$completion_line" >> "$shell_config"
            print_success "Added shell completion"
        fi
    fi
}

# Create useful aliases and shortcuts
create_shortcuts() {
    print_step "Creating shortcuts and aliases..."

    # Create common aliases file
    cat > "$CONFIG_DIR/aliases.sh" << EOF
#!/bin/bash
# QRY Enhanced Aliases
# Source this file in your shell configuration for convenient shortcuts

# Navigation shortcuts
alias q='qry'
alias qc='qry cd'
alias ql='qry ls'
alias qs='qry status'

# Development shortcuts
alias qcap='qry capture'
alias qcost='qry costs'
alias qhealth='qry health'
alias qai='qry ai'

# Session shortcuts
alias qsession='qry session'
alias qmorning='qry morning'

# Context shortcuts
alias qremember='qry remember'
alias qproc='qry procedures'

# Quick project navigation (customize these)
alias quro='qry cd uroboro'
alias qqoin='qry cd qoinbots'
alias qdice='qry cd quantum_dice'

# Utility functions
qcd() {
    # Smart cd with automatic qry integration
    if [[ -n "\$1" ]]; then
        qry cd "\$1"
    else
        qry ls
    fi
}

qfind() {
    # Find files in current project
    local query="\${1:-*}"
    find . -name "*\$query*" -type f | grep -v -E '\.(git|node_modules|target|build)' | head -20
}

qgrep() {
    # Grep in current project
    local pattern="\$1"
    if [[ -n "\$pattern" ]]; then
        grep -r "\$pattern" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target --exclude-dir=build | head -20
    else
        echo "Usage: qgrep <pattern>"
    fi
}
EOF

    print_info "Aliases created in $CONFIG_DIR/aliases.sh"
    print_info "Add 'source $CONFIG_DIR/aliases.sh' to your shell config to enable shortcuts"
}

# Create session templates
create_session_templates() {
    print_step "Creating session templates..."

    # Development session template
    cat > "$CONFIG_DIR/sessions/development.yaml" << EOF
# QRY Development Session Template
name: "qry-dev-{{.Project}}"
root: "{{.ProjectPath}}"
startup_commands:
  - "qry context scan"
  - "qry status --brief"
windows:
  - name: "main"
    layout: "main-horizontal"
    panes:
      - commands:
          - "# Main development terminal"
          - "# Use qry commands for navigation and context"
      - commands:
          - "# Secondary terminal for utilities"
          - "# Git, testing, monitoring"
  - name: "ai"
    panes:
      - commands:
          - "# AI assistance terminal"
          - "qry ai models"
          - "# Use: qry ai chat mistral:latest"
  - name: "monitor"
    panes:
      - commands:
          - "# System monitoring"
          - "qry health status"
          - "qry costs status"
EOF

    # Multi-project template
    cat > "$CONFIG_DIR/sessions/workspace.yaml" << EOF
# QRY Multi-Project Workspace Template
name: "qry-workspace"
startup_commands:
  - "qry morning"
windows:
  - name: "active-1"
    root: "{{.QRY_ROOT}}"
    panes:
      - commands:
          - "# Project slot 1"
          - "qry ls --type=active"
  - name: "active-2"
    root: "{{.QRY_ROOT}}"
    panes:
      - commands:
          - "# Project slot 2"
          - "qry status"
  - name: "tools"
    root: "{{.QRY_ROOT}}"
    panes:
      - commands:
          - "# Tools and utilities"
          - "qry ls --type=tool"
      - commands:
          - "# Cost and health monitoring"
          - "qry costs status"
          - "qry health status"
  - name: "ai"
    panes:
      - commands:
          - "# AI assistance"
          - "qry ai models"
EOF

    print_success "Session templates created"
}

# Test installation
test_installation() {
    print_step "Testing installation..."

    # Test if command is accessible
    if ! command -v qry >/dev/null 2>&1; then
        print_warning "qry command not found in PATH"
        print_info "You may need to restart your shell or run:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        echo "  source ~/.bashrc  # or ~/.zshrc"
        return 1
    fi

    # Test basic functionality
    local test_output
    if test_output=$(qry help 2>&1); then
        print_success "QRY command working correctly"
    else
        print_error "QRY command test failed"
        echo "$test_output"
        return 1
    fi

    # Test context scan
    if qry context scan >/dev/null 2>&1; then
        print_success "Context scanning working"
    else
        print_warning "Context scanning may need manual setup"
    fi

    return 0
}

# Print post-installation instructions
print_post_install() {
    echo
    print_header
    print_success "QRY Enhanced installation complete!"
    echo

    echo -e "${BOLD}🚀 Getting Started:${NC}"
    echo "1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
    echo "2. Navigate to your main development directory"
    echo "3. Run: qry context scan"
    echo "4. Try: qry ls"
    echo "5. Navigate with: qry cd <project>"
    echo

    echo -e "${BOLD}💡 Quick Commands:${NC}"
    echo "  qry ls                  - List all projects"
    echo "  qry cd <project>        - Smart navigation with context"
    echo "  qry morning             - Daily development routine"
    echo "  qry status              - Environment overview"
    echo "  qry help                - Full command reference"
    echo

    echo -e "${BOLD}🔧 Configuration:${NC}"
    echo "  Config: $CONFIG_DIR"
    echo "  Data: $DATA_DIR"
    echo "  Aliases: source $CONFIG_DIR/aliases.sh"
    echo

    echo -e "${BOLD}🎯 Next Steps:${NC}"
    echo "1. Set QRY_ROOT environment variable (optional):"
    echo "   export QRY_ROOT=/path/to/your/main/workspace"
    echo "2. Customize aliases by sourcing $CONFIG_DIR/aliases.sh"
    echo "3. Install recommended tools: tmux, jq, git, zoxide"
    echo "4. Set up your QRY tool ecosystem (uroboro, qoins, etc.)"
    echo

    if ! command -v qry >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Note:${NC} You may need to restart your shell for the PATH changes to take effect"
        echo
    fi

    echo -e "${GREEN}Welcome to QRY Enhanced! 🎉${NC}"
    echo "Context-aware development environment ready!"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_error "Installation failed!"
        print_info "You can retry or install manually"
    fi
    exit $exit_code
}

# Main installation flow
main() {
    # Handle command line arguments
    case "${1:-}" in
        "--uninstall")
            print_header
            print_step "Uninstalling QRY Enhanced..."
            rm -f "$INSTALL_DIR/$TARGET_NAME"
            rm -rf "$CONFIG_DIR" "$DATA_DIR"
            print_success "QRY Enhanced uninstalled"
            exit 0
            ;;
        "--help"|"-h")
            echo "QRY Enhanced Installer"
            echo
            echo "Usage: $0 [options]"
            echo
            echo "Options:"
            echo "  --uninstall    Remove QRY Enhanced completely"
            echo "  --help         Show this help"
            echo
            echo "Environment Variables:"
            echo "  QRY_ROOT       Set default workspace root directory"
            echo
            exit 0
            ;;
    esac

    # Set up error handling
    trap cleanup EXIT

    # Run installation steps
    print_header
    echo "Installing QRY Enhanced CLI Development Environment"
    echo

    check_dependencies
    setup_directories
    install_script
    init_config
    setup_shell_integration
    create_shortcuts
    create_session_templates

    # Test installation (don't fail if this doesn't work)
    test_installation || true

    print_post_install
}

# Run main function
main "$@"

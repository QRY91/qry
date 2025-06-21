#!/bin/bash

# QRY Labs Credential Management Setup Script
# Quick setup for 1Password CLI + direnv credential management system

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# QRY Labs branding
print_header() {
    echo -e "${PURPLE}🔐 QRY Labs Credential Management Setup${NC}"
    echo -e "${PURPLE}=======================================${NC}"
    echo -e "${CYAN}Privacy-first, developer-friendly credential management${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Check if running on supported OS
check_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        DISTRO=$(lsb_release -si 2>/dev/null || echo "Unknown")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi

    print_info "Detected OS: $OS"
    if [[ "$OS" == "linux" ]]; then
        print_info "Distribution: $DISTRO"
    fi
}

# Install 1Password CLI
install_1password_cli() {
    print_step "Installing 1Password CLI..."

    if command -v op &> /dev/null; then
        print_success "1Password CLI already installed"
        return 0
    fi

    if [[ "$OS" == "linux" ]]; then
        # Add 1Password repository
        print_info "Adding 1Password repository..."
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
          sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
          sudo tee /etc/apt/sources.list.d/1password.list

        # Install
        sudo apt update
        sudo apt install -y 1password-cli

    elif [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install 1password-cli
        else
            print_error "Homebrew not found. Install Homebrew first: https://brew.sh"
            exit 1
        fi
    fi

    # Verify installation
    if command -v op &> /dev/null; then
        print_success "1Password CLI installed successfully"
        print_info "Version: $(op --version)"
    else
        print_error "1Password CLI installation failed"
        exit 1
    fi
}

# Install direnv
install_direnv() {
    print_step "Installing direnv..."

    if command -v direnv &> /dev/null; then
        print_success "direnv already installed"
        return 0
    fi

    if [[ "$OS" == "linux" ]]; then
        sudo apt install -y direnv
    elif [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install direnv
        else
            print_error "Homebrew not found. Install Homebrew first: https://brew.sh"
            exit 1
        fi
    fi

    # Verify installation
    if command -v direnv &> /dev/null; then
        print_success "direnv installed successfully"
        print_info "Version: $(direnv version)"
    else
        print_error "direnv installation failed"
        exit 1
    fi
}

# Setup shell integration
setup_shell_integration() {
    print_step "Setting up shell integration..."

    # Detect shell
    SHELL_NAME=$(basename "$SHELL")

    case "$SHELL_NAME" in
        bash)
            SHELL_RC="$HOME/.bashrc"
            HOOK_CMD='eval "$(direnv hook bash)"'
            ;;
        zsh)
            SHELL_RC="$HOME/.zshrc"
            HOOK_CMD='eval "$(direnv hook zsh)"'
            ;;
        fish)
            SHELL_RC="$HOME/.config/fish/config.fish"
            HOOK_CMD='direnv hook fish | source'
            ;;
        *)
            print_warning "Unknown shell: $SHELL_NAME"
            print_info "Please manually add direnv hook to your shell config"
            return 0
            ;;
    esac

    # Check if hook already exists
    if [[ -f "$SHELL_RC" ]] && grep -q "direnv hook" "$SHELL_RC"; then
        print_success "direnv hook already configured in $SHELL_RC"
    else
        print_info "Adding direnv hook to $SHELL_RC"
        echo "" >> "$SHELL_RC"
        echo "# QRY Labs direnv integration" >> "$SHELL_RC"
        echo "$HOOK_CMD" >> "$SHELL_RC"
        print_success "direnv hook added to $SHELL_RC"
        print_warning "Please restart your shell or run: source $SHELL_RC"
    fi
}

# Setup 1Password
setup_1password() {
    print_step "Setting up 1Password..."

    # Check if already signed in
    if op account list &> /dev/null; then
        print_success "Already signed in to 1Password"

        # Check if QRY Labs vault exists
        if op vault list | grep -q "QRY Labs Development"; then
            print_success "QRY Labs Development vault already exists"
        else
            print_info "Creating QRY Labs Development vault..."
            op vault create "QRY Labs Development"
            print_success "QRY Labs Development vault created"
        fi
    else
        print_info "Please sign in to 1Password CLI"
        echo ""
        echo "If you don't have a 1Password account:"
        echo "1. Go to https://1password.com"
        echo "2. Create an account"
        echo "3. Come back and run: op signin"
        echo ""
        read -p "Press Enter when ready to sign in..."

        op signin

        # Create QRY Labs vault
        print_info "Creating QRY Labs Development vault..."
        op vault create "QRY Labs Development"
        print_success "QRY Labs Development vault created"
    fi
}

# Create directory structure
create_directory_structure() {
    print_step "Creating QRY Labs directory structure..."

    # Ensure we're in the right place
    if [[ ! -d "qry" ]]; then
        print_error "Please run this script from the directory containing the 'qry' folder"
        exit 1
    fi

    # Create scripts directory if it doesn't exist
    mkdir -p qry/scripts

    # Create backup directory
    mkdir -p "$HOME/.qry-backups"

    print_success "Directory structure created"
}

# Create global .envrc
create_global_envrc() {
    print_step "Creating global QRY environment..."

    cat > qry/.envrc << 'EOF'
#!/bin/bash
# QRY Labs Global Environment Configuration

# 1Password CLI integration
if command -v op &> /dev/null; then
    # Check if signed in
    if op account list &> /dev/null 2>&1; then
        export QRY_1PASSWORD_AVAILABLE=true
        export QRY_VAULT="QRY Labs Development"
    else
        echo "⚠️  1Password CLI available but not signed in"
        echo "Run: op signin"
        export QRY_1PASSWORD_AVAILABLE=false
    fi
else
    echo "⚠️  1Password CLI not found. Install for credential management."
    export QRY_1PASSWORD_AVAILABLE=false
fi

# QRY Labs global settings
export QRY_ENVIRONMENT="development"
export QRY_PRIVACY_MODE="enhanced"
export QRY_LOCAL_FIRST="true"

# Development tools
export QRY_DEBUG="true"
export QRY_LOG_LEVEL="info"

# Credential management
export QRY_CREDENTIAL_MANAGER="1password"
export QRY_BACKUP_DIR="$HOME/.qry-backups"

echo "🚀 QRY Labs global environment loaded"
if [[ "$QRY_1PASSWORD_AVAILABLE" == "true" ]]; then
    echo "🔐 1Password credential management available"
else
    echo "⚠️  1Password credential management not available"
fi
EOF

    print_success "Global .envrc created"
}

# Create PostHog project .envrc
create_posthog_envrc() {
    print_step "Creating PostHog integration environment..."

    mkdir -p qry/labs/posthog-integration

    cat > qry/labs/posthog-integration/.envrc << 'EOF'
#!/bin/bash
# PostHog Integration Project Environment

# Load global QRY environment
source_up

# Project-specific settings
export QRY_PROJECT="posthog-integration"
export QRY_PROJECT_TYPE="labs"

# PostHog credentials from 1Password
if [[ "$QRY_1PASSWORD_AVAILABLE" == "true" ]]; then
    # Try to load PostHog credentials
    POSTHOG_API_KEY_ITEM="PostHog Project API Key"
    POSTHOG_PERSONAL_API_KEY_ITEM="PostHog Personal API Key"

    export POSTHOG_API_KEY="$(op item get "$POSTHOG_API_KEY_ITEM" --vault "$QRY_VAULT" --field credential 2>/dev/null || echo '')"
    export POSTHOG_PERSONAL_API_KEY="$(op item get "$POSTHOG_PERSONAL_API_KEY_ITEM" --vault "$QRY_VAULT" --field credential 2>/dev/null || echo '')"

    if [[ -n "$POSTHOG_API_KEY" ]]; then
        echo "✅ PostHog credentials loaded from 1Password"
    else
        echo "⚠️  PostHog credentials not found in 1Password"
        echo "Add them with: ./scripts/add_posthog_credentials.sh"
    fi
else
    echo "⚠️  1Password not available, checking for local fallback..."
    if [[ -f ".env.posthog.local" ]]; then
        source .env.posthog.local
        echo "✅ PostHog credentials loaded from local file"
    else
        echo "❌ No PostHog credentials available"
        echo "Either set up 1Password or create .env.posthog.local"
    fi
fi

# PostHog configuration
export POSTHOG_HOST="https://us.posthog.com"
export QRY_POSTHOG_ENABLED="true"
export QRY_POSTHOG_ENVIRONMENT="development"

# Project-specific settings
export UROBORO_POSTHOG_ENABLED="true"
export DOGGOWOOF_POSTHOG_ENABLED="true"

echo "📊 PostHog integration environment loaded"
EOF

    print_success "PostHog integration .envrc created"
}

# Create helper scripts
create_helper_scripts() {
    print_step "Creating helper scripts..."

    # Create credential addition script
    cat > qry/scripts/add_posthog_credentials.sh << 'EOF'
#!/bin/bash
# Add PostHog credentials to 1Password

set -e

QRY_VAULT="QRY Labs Development"

echo "🔐 Adding PostHog credentials to 1Password"
echo "=========================================="
echo ""

# Get API keys from user
echo "Please enter your PostHog credentials:"
echo ""

read -p "PostHog Project API Key (starts with phc_): " -s PROJECT_API_KEY
echo ""
read -p "PostHog Personal API Key (optional, starts with phx_): " -s PERSONAL_API_KEY
echo ""

# Validate project API key
if [[ ! "$PROJECT_API_KEY" =~ ^phc_ ]]; then
    echo "❌ Invalid project API key format (should start with 'phc_')"
    exit 1
fi

# Store project API key
echo "📝 Storing PostHog Project API Key..."
op item create \
  --category "API Credential" \
  --title "PostHog Project API Key" \
  --vault "$QRY_VAULT" \
  --url "https://us.posthog.com" \
  username="qry-labs" \
  credential="$PROJECT_API_KEY" \
  --tags "posthog,analytics,qry-labs,project-api" \
  project="qry-ecosystem" \
  environment="development" \
  created_date="$(date -I)" \
  rotation_schedule="quarterly"

# Store personal API key if provided
if [[ -n "$PERSONAL_API_KEY" ]]; then
    if [[ "$PERSONAL_API_KEY" =~ ^phx_ ]]; then
        echo "📝 Storing PostHog Personal API Key..."
        op item create \
          --category "API Credential" \
          --title "PostHog Personal API Key" \
          --vault "$QRY_VAULT" \
          --url "https://us.posthog.com" \
          username="qry-labs" \
          credential="$PERSONAL_API_KEY" \
          --tags "posthog,analytics,qry-labs,personal-api" \
          project="qry-ecosystem" \
          environment="development" \
          created_date="$(date -I)" \
          rotation_schedule="quarterly"
    else
        echo "⚠️  Invalid personal API key format (should start with 'phx_') - skipping"
    fi
fi

echo ""
echo "✅ PostHog credentials stored successfully!"
echo "🔄 Reload your environment: direnv reload"
echo "🧪 Test connection: cd qry/labs/posthog-integration && python tests/test_connection.py"
EOF

    chmod +x qry/scripts/add_posthog_credentials.sh

    # Create credential health check script
    cat > qry/scripts/check_credentials.sh << 'EOF'
#!/bin/bash
# QRY Labs Credential Health Check

set -e

QRY_VAULT="QRY Labs Development"

echo "🔐 QRY Labs Credential Health Check"
echo "=================================="
echo ""

check_credential() {
    local item_name="$1"
    local test_url="$2"

    echo "🔍 Checking $item_name..."

    # Get credential
    local credential=$(op item get "$item_name" --vault "$QRY_VAULT" --field credential 2>/dev/null || echo "")

    if [[ -z "$credential" ]]; then
        echo "   Status: ❌ Not found"
        return 1
    fi

    # Get metadata
    local created=$(op item get "$item_name" --vault "$QRY_VAULT" --field created_date 2>/dev/null || echo "unknown")
    local last_rotated=$(op item get "$item_name" --vault "$QRY_VAULT" --field last_rotated 2>/dev/null || echo "never")

    echo "   Created: $created"
    echo "   Last rotated: $last_rotated"
    echo "   Length: ${#credential} characters"

    # Test credential if test URL provided
    if [[ -n "$test_url" ]]; then
        if curl -s -f -H "Authorization: Bearer $credential" "$test_url" >/dev/null 2>&1; then
            echo "   Status: ✅ Valid"
        else
            echo "   Status: ❌ Invalid or expired"
        fi
    else
        echo "   Status: ℹ️  Not tested"
    fi

    echo ""
}

# Check if 1Password is available
if ! command -v op &> /dev/null; then
    echo "❌ 1Password CLI not found"
    exit 1
fi

if ! op account list &> /dev/null 2>&1; then
    echo "❌ Not signed in to 1Password. Run: op signin"
    exit 1
fi

# Check PostHog credentials
check_credential "PostHog Project API Key" "https://us.posthog.com/api/projects/"
check_credential "PostHog Personal API Key" "https://us.posthog.com/api/projects/"

echo "Health check complete"
EOF

    chmod +x qry/scripts/check_credentials.sh

    print_success "Helper scripts created"
}

# Create template files
create_templates() {
    print_step "Creating template files..."

    # Create PostHog environment template
    cat > qry/labs/posthog-integration/.env.template << 'EOF'
# PostHog Integration Environment Template
# Copy to .env.posthog.local and fill in your credentials

# PostHog Configuration
POSTHOG_API_KEY=your_posthog_project_api_key_here
POSTHOG_PERSONAL_API_KEY=your_posthog_personal_api_key_here
POSTHOG_HOST=https://us.posthog.com

# QRY Configuration
QRY_ENVIRONMENT=development
QRY_PRIVACY_MODE=enhanced
QRY_DEBUG=true
QRY_POSTHOG_ENABLED=true

# Integration Settings
UROBORO_POSTHOG_ENABLED=true
DOGGOWOOF_POSTHOG_ENABLED=true

# Instructions:
# 1. Get PostHog API keys from your PostHog dashboard
# 2. Copy this file to .env.posthog.local
# 3. Fill in your actual API keys
# 4. Test connection: python tests/test_connection.py
#
# For better security, use 1Password CLI integration instead:
# ./scripts/add_posthog_credentials.sh
EOF

    # Update .gitignore
    if [[ ! -f "qry/.gitignore" ]]; then
        touch qry/.gitignore
    fi

    # Add credential-related patterns to .gitignore
    cat >> qry/.gitignore << 'EOF'

# QRY Labs Credential Management
.env*
.envrc
secrets/
*.key
*.pem
*.p12
credentials.json
**/credentials/**
**/.env.*.local
EOF

    print_success "Template files created"
}

# Print next steps
print_next_steps() {
    echo ""
    echo -e "${PURPLE}🎉 QRY Labs Credential Management Setup Complete!${NC}"
    echo -e "${PURPLE}===============================================${NC}"
    echo ""

    echo -e "${GREEN}✅ What's been set up:${NC}"
    echo "   • 1Password CLI installed and configured"
    echo "   • direnv installed with shell integration"
    echo "   • QRY Labs Development vault created"
    echo "   • Global and project-specific environment files"
    echo "   • Helper scripts for credential management"
    echo "   • Template files for team collaboration"
    echo ""

    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo ""
    echo -e "${YELLOW}1. Restart your shell or run:${NC}"
    echo "   source ~/.bashrc  # or ~/.zshrc"
    echo ""
    echo -e "${YELLOW}2. Add PostHog credentials:${NC}"
    echo "   ./scripts/add_posthog_credentials.sh"
    echo ""
    echo -e "${YELLOW}3. Test the setup:${NC}"
    echo "   cd qry/labs/posthog-integration"
    echo "   # direnv will automatically load environment"
    echo "   python tests/test_connection.py"
    echo ""
    echo -e "${YELLOW}4. Check credential health:${NC}"
    echo "   ./scripts/check_credentials.sh"
    echo ""

    echo -e "${CYAN}📁 Key Files Created:${NC}"
    echo "   • qry/.envrc                                - Global QRY environment"
    echo "   • qry/labs/posthog-integration/.envrc       - PostHog project environment"
    echo "   • qry/scripts/add_posthog_credentials.sh    - Add credentials to 1Password"
    echo "   • qry/scripts/check_credentials.sh          - Health check credentials"
    echo "   • qry/.gitignore                            - Updated with credential patterns"
    echo ""

    echo -e "${PURPLE}🔐 Security Features:${NC}"
    echo "   • Credentials stored securely in 1Password"
    echo "   • Environment variables loaded per-project"
    echo "   • Git-safe (credentials never committed)"
    echo "   • Audit trail for credential usage"
    echo "   • Easy rotation and health checking"
    echo ""

    echo -e "${GREEN}Ready for secure QRY Labs development! 🎯${NC}"
}

# Main setup function
main() {
    print_header

    # Check OS compatibility
    check_os

    # Install required tools
    install_1password_cli
    install_direnv

    # Set up integrations
    setup_shell_integration
    setup_1password

    # Create QRY Labs structure
    create_directory_structure
    create_global_envrc
    create_posthog_envrc
    create_helper_scripts
    create_templates

    # Show next steps
    print_next_steps

    echo ""
    echo -e "${GREEN}🎉 Credential management setup completed successfully!${NC}"

    return 0
}

# Handle script interruption
cleanup() {
    echo ""
    print_warning "Setup interrupted by user"
    exit 1
}

trap cleanup SIGINT

# Run main setup
main "$@"

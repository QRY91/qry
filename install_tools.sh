#!/bin/bash

# QRY Tools Global Installation Script
# Installs wherewasi, uroboro, and qryai tools globally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/.local/bin"

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

echo -e "${BLUE}🚀 QRY Tools Global Installation${NC}"
echo "Installing to: $INSTALL_DIR"
echo ""

# Function to check if directory exists
check_project() {
    local project=$1
    if [ ! -d "labs/projects/$project" ]; then
        echo -e "${RED}❌ Project $project not found${NC}"
        return 1
    fi
    return 0
}

# Function to build and install Go project
install_go_tool() {
    local project=$1
    local binary_name=$2
    local short_name=$3
    
    echo -e "${YELLOW}📦 Installing $project...${NC}"
    
    if ! check_project "$project"; then
        return 1
    fi
    
    cd "labs/projects/$project"
    
    # Build the tool
    if [ -f "main.go" ]; then
        echo "  Building from main.go..."
        go build -o "$binary_name" main.go
    elif [ -f "cmd/$project/main.go" ]; then
        echo "  Building from cmd/$project/main.go..."
        go build -o "$binary_name" "./cmd/$project"
    else
        echo -e "${RED}  ❌ No main.go found${NC}"
        cd ../../..
        return 1
    fi
    
    # Install binary
    cp "$binary_name" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$binary_name"
    echo -e "${GREEN}  ✅ Installed $binary_name${NC}"
    
    # Create short name symlink if provided
    if [ -n "$short_name" ]; then
        ln -sf "$INSTALL_DIR/$binary_name" "$INSTALL_DIR/$short_name"
        echo -e "${GREEN}  ✅ Created symlink: $short_name → $binary_name${NC}"
    fi
    
    cd ../../..
    return 0
}

# Install wherewasi
install_go_tool "wherewasi" "wherewasi" ""

# Install uroboro
install_go_tool "uroboro" "uroboro" "uro"

# Install qryai (using the phase3 version we just built)
echo -e "${YELLOW}📦 Installing qryai...${NC}"
if check_project "qryai"; then
    cd "labs/projects/qryai"
    
    # Check if qryai-phase3 exists, if not build it
    if [ ! -f "qryai-phase3" ]; then
        echo "  Building qryai-phase3..."
        go build -o qryai-phase3 main.go
    fi
    
    # Install binary
    cp "qryai-phase3" "$INSTALL_DIR/qryai"
    chmod +x "$INSTALL_DIR/qryai"
    echo -e "${GREEN}  ✅ Installed qryai${NC}"
    
    # Setup Python virtual environment if it doesn't exist
    if [ ! -d "ai_env" ]; then
        echo "  Setting up Python virtual environment..."
        python3 -m venv ai_env
        source ai_env/bin/activate
        pip install -r ai/requirements.txt
        echo -e "${GREEN}  ✅ Python environment ready${NC}"
    fi
    
    cd ../../..
fi

echo ""
echo -e "${BLUE}🎯 Installation Summary${NC}"
echo "Tools installed to: $INSTALL_DIR"
echo ""

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}⚠️  $INSTALL_DIR is not in your PATH${NC}"
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Test installations
echo -e "${BLUE}🧪 Testing installations...${NC}"

test_tool() {
    local tool=$1
    local test_arg=$2
    
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool: Available${NC}"
        # Try to run with test argument if provided
        if [ -n "$test_arg" ]; then
            if "$tool" "$test_arg" >/dev/null 2>&1; then
                echo -e "${GREEN}   Works correctly${NC}"
            else
                echo -e "${YELLOW}   May need additional setup${NC}"
            fi
        fi
    else
        echo -e "${RED}❌ $tool: Not found in PATH${NC}"
    fi
}

test_tool "wherewasi" "status"
test_tool "uroboro" "status"
test_tool "uro" "status"
test_tool "qryai" ""

echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  wherewasi status    # Check ecosystem status"
echo "  wherewasi pull      # Get AI context"
echo "  uro capture \"msg\"   # Capture development insight"
echo "  uro status          # Check uroboro status"
echo "  qryai               # Start QRY AI assistant"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Add $INSTALL_DIR to your PATH if needed"
echo "2. Run 'wherewasi start' to begin ecosystem tracking"
echo "3. Test with 'wherewasi pull' to verify integration"
echo ""
echo -e "${YELLOW}Note: qryai requires the working directory to be the qryai project${NC}"
echo "      for AI methodology module access"
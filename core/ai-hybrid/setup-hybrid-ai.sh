#!/bin/bash

# QRY Hybrid AI Setup Script
# Combines LocalAI (Docker) + Ollama for intelligent AI routing
# Based on sophisticated backup implementation + current LocalAI setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QRY_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCALAI_PORT=8080
MODELS_TO_INSTALL=(
    "orca-mini:3b"      # Speed (1.9GB)
    "mistral:7b"        # Balance (4.1GB)
    "codellama:7b"      # Code (3.8GB)
    "llama2:13b"        # Quality (7.3GB)
)

# Default settings
MODE="comprehensive"
SKIP_LOCALAI=false
SKIP_OLLAMA=false
SKIP_MODELS=false

print_header() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║        🚀 QRY HYBRID AI SETUP 🚀                            ║
    ║                                                               ║
    ║   LocalAI (Docker + Unified API) + Ollama (Multi-Model)     ║
    ║   Smart Routing • Cost Optimization • Local Privacy         ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
    echo -e "${YELLOW}🎯 Goal: Best-in-class local AI with intelligent model selection${NC}"
    echo -e "${YELLOW}📊 Approach: Hybrid LocalAI + Ollama with smart routing${NC}"
    echo -e "${YELLOW}💰 Target: 80-90% cost reduction vs cloud AI${NC}"
    echo
}

show_help() {
    cat << EOF
🚀 QRY Hybrid AI Setup

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --quick              Fast setup with minimal models
    --comprehensive      Full setup with all models [DEFAULT]
    --skip-localai       Skip LocalAI setup (use existing)
    --skip-ollama        Skip Ollama setup (use existing)
    --skip-models        Skip model downloads (use existing)
    --help, -h           Show this help message

WHAT THIS SCRIPT DOES:
    1. 🐳 Sets up LocalAI with Docker (unified API)
    2. 🦙 Installs and configures Ollama (multi-model)
    3. 📥 Downloads optimized model set for different use cases
    4. 🧠 Builds smart routing system
    5. 🧪 Tests both backends working together
    6. ⚙️  Generates configuration and usage examples

MODELS INSTALLED:
    • orca-mini:3b    - Speed tasks (3s response, 1.9GB)
    • mistral:7b      - Balanced general use (12s, 4.1GB)
    • codellama:7b    - Technical/code tasks (15s, 3.8GB)
    • llama2:13b      - High quality content (25s, 7.3GB)

REQUIREMENTS:
    • Docker (for LocalAI)
    • 8GB+ RAM (16GB recommended for llama2:13b)
    • 20GB+ free disk space
    • Go 1.19+ (for smart router)

EXPECTED RUNTIME:
    --quick:         15-30 minutes (basic models only)
    --comprehensive: 45-90 minutes (all models)
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            MODE="quick"
            MODELS_TO_INSTALL=("orca-mini:3b" "mistral:7b")
            shift
            ;;
        --comprehensive)
            MODE="comprehensive"
            shift
            ;;
        --skip-localai)
            SKIP_LOCALAI=true
            shift
            ;;
        --skip-ollama)
            SKIP_OLLAMA=true
            shift
            ;;
        --skip-models)
            SKIP_MODELS=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

    local errors=0

    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found${NC}"
        echo "   Install: https://docs.docker.com/get-docker/"
        ((errors++))
    else
        echo -e "${GREEN}✅ Docker found: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)${NC}"
    fi

    # Check Go
    if ! command -v go &> /dev/null; then
        echo -e "${RED}❌ Go not found${NC}"
        echo "   Install: https://golang.org/doc/install"
        ((errors++))
    else
        echo -e "${GREEN}✅ Go found: $(go version | awk '{print $3}')${NC}"
    fi

    # Check available RAM
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
        if [ "$TOTAL_RAM" -lt 8 ]; then
            echo -e "${YELLOW}⚠️  Low RAM: ${TOTAL_RAM}GB (8GB+ recommended)${NC}"
        else
            echo -e "${GREEN}✅ RAM: ${TOTAL_RAM}GB${NC}"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        TOTAL_RAM=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
        if [ "$TOTAL_RAM" -lt 8 ]; then
            echo -e "${YELLOW}⚠️  Low RAM: ${TOTAL_RAM}GB (8GB+ recommended)${NC}"
        else
            echo -e "${GREEN}✅ RAM: ${TOTAL_RAM}GB${NC}"
        fi
    fi

    # Check disk space
    AVAILABLE_SPACE=$(df . | tail -1 | awk '{print int($4/1024/1024)}') # GB
    if [ "$AVAILABLE_SPACE" -lt 20 ]; then
        echo -e "${YELLOW}⚠️  Low disk space: ${AVAILABLE_SPACE}GB available (20GB+ recommended)${NC}"
    else
        echo -e "${GREEN}✅ Disk space: ${AVAILABLE_SPACE}GB available${NC}"
    fi

    if [ $errors -gt 0 ]; then
        echo -e "${RED}❌ Please install missing prerequisites before continuing${NC}"
        exit 1
    fi
    echo
}

setup_localai() {
    if [ "$SKIP_LOCALAI" = true ]; then
        echo -e "${YELLOW}⏭️  Skipping LocalAI setup${NC}"
        return
    fi

    echo -e "${BLUE}🐳 Setting up LocalAI with Docker...${NC}"

    # Check if LocalAI is already running
    if curl -s "http://localhost:$LOCALAI_PORT/v1/models" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ LocalAI already running on port $LOCALAI_PORT${NC}"
        return
    fi

    # Stop any existing LocalAI containers
    if docker ps -a --format '{{.Names}}' | grep -q "qry-localai"; then
        echo "🔄 Stopping existing LocalAI container..."
        docker stop qry-localai > /dev/null 2>&1 || true
        docker rm qry-localai > /dev/null 2>&1 || true
    fi

    # Start LocalAI with the working configuration
    echo "🚀 Starting LocalAI container..."
    docker run -d \
        --name qry-localai \
        -p $LOCALAI_PORT:8080 \
        -v "$QRY_ROOT/models:/models:cached" \
        --restart unless-stopped \
        localai/localai:latest-aio-cpu

    # Wait for LocalAI to start
    echo "⏳ Waiting for LocalAI to start..."
    local attempts=0
    while ! curl -s "http://localhost:$LOCALAI_PORT/v1/models" > /dev/null 2>&1; do
        sleep 5
        ((attempts++))
        if [ $attempts -ge 24 ]; then # 2 minutes
            echo -e "${RED}❌ LocalAI failed to start after 2 minutes${NC}"
            echo "Check logs: docker logs qry-localai"
            exit 1
        fi
        echo -n "."
    done
    echo

    echo -e "${GREEN}✅ LocalAI started successfully${NC}"
    echo
}

setup_ollama() {
    if [ "$SKIP_OLLAMA" = true ]; then
        echo -e "${YELLOW}⏭️  Skipping Ollama setup${NC}"
        return
    fi

    echo -e "${BLUE}🦙 Setting up Ollama...${NC}"

    # Check if Ollama is installed
    if ! command -v ollama &> /dev/null; then
        echo "📥 Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
    else
        echo -e "${GREEN}✅ Ollama found: $(ollama --version 2>/dev/null || echo 'installed')${NC}"
    fi

    # Start Ollama service if not running
    if ! ollama list &> /dev/null; then
        echo "🚀 Starting Ollama service..."
        if [[ "$OSTYPE" == "linux-gnu" ]]; then
            systemctl --user start ollama || (ollama serve &> /dev/null &)
        else
            ollama serve &> /dev/null &
        fi
        sleep 3
    fi

    echo -e "${GREEN}✅ Ollama service running${NC}"
    echo
}

install_models() {
    if [ "$SKIP_MODELS" = true ]; then
        echo -e "${YELLOW}⏭️  Skipping model installation${NC}"
        return
    fi

    echo -e "${BLUE}📥 Installing optimized model set...${NC}"
    echo -e "${YELLOW}Models for $MODE mode: ${MODELS_TO_INSTALL[*]}${NC}"
    echo

    local total_size=0
    case "$MODE" in
        "quick")
            total_size="~6GB"
            ;;
        "comprehensive")
            total_size="~17GB"
            ;;
    esac

    echo -e "${CYAN}📊 Total download size: $total_size${NC}"
    echo -e "${CYAN}💡 These models are selected for optimal cost/performance balance${NC}"
    echo

    for model in "${MODELS_TO_INSTALL[@]}"; do
        echo -e "${PURPLE}🔄 Installing $model...${NC}"

        # Check if model already exists
        if ollama list | grep -q "$(echo $model | cut -d':' -f1)"; then
            echo -e "${GREEN}✅ $model already installed${NC}"
            continue
        fi

        # Install with progress
        if ollama pull "$model"; then
            echo -e "${GREEN}✅ $model installed successfully${NC}"
        else
            echo -e "${RED}❌ Failed to install $model${NC}"
            echo -e "${YELLOW}⚠️  Continuing with other models...${NC}"
        fi
        echo
    done

    echo -e "${GREEN}✅ Model installation complete${NC}"
    echo
}

build_smart_router() {
    echo -e "${BLUE}🧠 Building smart router...${NC}"

    # Create Go module for smart router
    cd "$SCRIPT_DIR"
    if [ ! -f "go.mod" ]; then
        go mod init qry-smart-ai
    fi

    # Build the smart router
    echo "🔨 Compiling smart router..."
    if go build -o qry-smart-ai qry-smart-ai.go; then
        echo -e "${GREEN}✅ Smart router built successfully${NC}"

        # Make it executable
        chmod +x qry-smart-ai

        # Create symlink in tools directory for easy access
        local tools_dir="$QRY_ROOT/tools"
        if [ -d "$tools_dir" ]; then
            ln -sf "$SCRIPT_DIR/qry-smart-ai" "$tools_dir/qry-smart-ai"
            echo -e "${GREEN}✅ Smart router linked to tools directory${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to build smart router${NC}"
        exit 1
    fi
    echo
}

test_hybrid_system() {
    echo -e "${BLUE}🧪 Testing hybrid system...${NC}"

    # Test prompts for different scenarios
    local test_prompts=(
        "quick summary of AI routing"
        "write comprehensive API documentation for user authentication"
        "fix bug in Go HTTP handler function"
        "detailed analysis of microservice architecture patterns"
    )

    local test_descriptions=(
        "Speed test (should use orca-mini:3b)"
        "Quality test (should use llama2:13b if available)"
        "Code test (should use codellama:7b if available)"
        "Complex test (should use best available model)"
    )

    echo "🔬 Running routing tests..."
    echo

    for i in "${!test_prompts[@]}"; do
        echo -e "${CYAN}Test $((i+1)): ${test_descriptions[i]}${NC}"
        echo -e "${YELLOW}Prompt: \"${test_prompts[i]}\"${NC}"

        if ./qry-smart-ai "${test_prompts[i]}" --explain; then
            echo -e "${GREEN}✅ Test passed${NC}"
        else
            echo -e "${RED}❌ Test failed${NC}"
        fi
        echo
    done

    echo -e "${GREEN}✅ Hybrid system testing complete${NC}"
    echo
}

create_configuration() {
    echo -e "${BLUE}⚙️  Creating configuration files...${NC}"

    # Create QRY AI config directory
    local config_dir="$HOME/.qry"
    mkdir -p "$config_dir"

    # Create AI configuration
    cat > "$config_dir/ai-config.toml" << EOF
# QRY Hybrid AI Configuration
# Generated by setup-hybrid-ai.sh

[routing]
strategy = "intelligent"  # vs "fixed"
default_backend = "ollama"
fallback_backend = "localai"
explain_decisions = false

[backends]
[backends.localai]
endpoint = "http://localhost:$LOCALAI_PORT"
timeout_seconds = 60
default_model = "llama-3.2-1b-instruct:q4_k_m"

[backends.ollama]
binary_path = "ollama"
timeout_seconds = 60

[models]
speed = "orca-mini:3b"
balanced = "mistral:7b"
quality = "llama2:13b"
code = "codellama:7b"

[costs]
local_cost_per_query = 0.001  # Electricity + amortized hardware
cloud_fallback_budget = 10.0  # Monthly budget for cloud AI fallback

[optimization]
track_usage = true
auto_optimize = true
quality_threshold = 0.8
performance_monitoring = true
EOF

    # Create usage examples
    cat > "$SCRIPT_DIR/USAGE_EXAMPLES.md" << EOF
# QRY Smart AI Usage Examples

## Command Line Usage

### Basic Query
\`\`\`bash
./qry-smart-ai "explain the uroboro tool architecture"
\`\`\`

### With Routing Explanation
\`\`\`bash
./qry-smart-ai "fix authentication bug in Go" --explain
\`\`\`

### Interactive Mode
\`\`\`bash
./qry-smart-ai
# Then enter prompts interactively
\`\`\`

## Integration Examples

### In Shell Scripts
\`\`\`bash
# Generate commit message
COMMIT_MSG=\$(./qry-smart-ai "generate commit message for: \$(git diff --cached)")
git commit -m "\$COMMIT_MSG"
\`\`\`

### With Uroboro
\`\`\`bash
# Enhanced uroboro capture with AI
uroboro capture "working on AI integration" | ./qry-smart-ai "create detailed devlog entry"
\`\`\`

## Model Selection Logic

The smart router automatically selects models based on:

- **Speed Priority**: "quick", "fast", "urgent" → orca-mini:3b
- **Code Tasks**: "code", "function", "bug" → codellama:7b
- **Quality Focus**: "comprehensive", "detailed" → llama2:13b
- **Default**: Most tasks → mistral:7b
- **Fallback**: If Ollama fails → LocalAI

## Performance Expectations

| Model | Use Case | Response Time | Quality | Cost |
|-------|----------|---------------|---------|------|
| orca-mini:3b | Quick tasks | ~3s | Good | $0.001 |
| mistral:7b | General use | ~12s | Very Good | $0.004 |
| codellama:7b | Code tasks | ~15s | Excellent (Code) | $0.005 |
| llama2:13b | Complex/Quality | ~25s | Excellent | $0.008 |

*Note: Costs are estimated local processing costs (electricity + hardware amortization)*
EOF

    echo -e "${GREEN}✅ Configuration files created${NC}"
    echo -e "${CYAN}📋 Config location: $config_dir/ai-config.toml${NC}"
    echo -e "${CYAN}📖 Usage examples: $SCRIPT_DIR/USAGE_EXAMPLES.md${NC}"
    echo
}

print_summary() {
    echo -e "${GREEN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║        🎉 HYBRID AI SETUP COMPLETE! 🎉                      ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "${CYAN}🚀 Quick Start:${NC}"
    echo -e "   ${YELLOW}Interactive mode:${NC} $SCRIPT_DIR/qry-smart-ai"
    echo -e "   ${YELLOW}Single query:${NC}    $SCRIPT_DIR/qry-smart-ai \"your prompt here\""
    echo -e "   ${YELLOW}With explanation:${NC} $SCRIPT_DIR/qry-smart-ai \"your prompt\" --explain"
    echo

    echo -e "${CYAN}📊 System Status:${NC}"

    # Check LocalAI
    if curl -s "http://localhost:$LOCALAI_PORT/v1/models" > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ LocalAI running${NC} (http://localhost:$LOCALAI_PORT)"
    else
        echo -e "   ${RED}❌ LocalAI not responding${NC}"
    fi

    # Check Ollama
    if ollama list &> /dev/null; then
        local model_count=$(ollama list | wc -l)
        echo -e "   ${GREEN}✅ Ollama running${NC} ($((model_count-1)) models installed)"
    else
        echo -e "   ${RED}❌ Ollama not responding${NC}"
    fi

    echo -e "   ${GREEN}✅ Smart router built${NC} ($SCRIPT_DIR/qry-smart-ai)"
    echo

    echo -e "${CYAN}💡 Next Steps:${NC}"
    echo -e "   1. Try the interactive mode: ${YELLOW}$SCRIPT_DIR/qry-smart-ai${NC}"
    echo -e "   2. Test different prompt types with ${YELLOW}--explain${NC} flag"
    echo -e "   3. Integrate with your existing QRY tools"
    echo -e "   4. Monitor usage and optimize model selection"
    echo

    echo -e "${CYAN}📚 Resources:${NC}"
    echo -e "   • Usage examples: ${YELLOW}$SCRIPT_DIR/USAGE_EXAMPLES.md${NC}"
    echo -e "   • Configuration: ${YELLOW}$HOME/.qry/ai-config.toml${NC}"
    echo -e "   • Integration plan: ${YELLOW}$SCRIPT_DIR/INTEGRATION_PLAN.md${NC}"
    echo

    echo -e "${PURPLE}🎯 Expected Benefits:${NC}"
    echo -e "   • 80-90% cost reduction vs cloud AI"
    echo -e "   • Intelligent model selection for optimal performance"
    echo -e "   • Complete privacy with local processing"
    echo -e "   • Automatic fallback strategies for reliability"
    echo
}

# Main execution
main() {
    print_header
    check_prerequisites
    setup_localai
    setup_ollama
    install_models
    build_smart_router
    test_hybrid_system
    create_configuration
    print_summary
}

# Run main function
main "$@"

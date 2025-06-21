#!/bin/bash

# QOINs Quick Start - Immediate Cost Management
# Get cost tracking up and running in under 5 minutes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QOINS_ROOT="$SCRIPT_DIR"

print_header() {
    echo -e "${BLUE}${BOLD}"
    echo "💰 QOINs Quick Start - Emergency Cost Control"
    echo "============================================="
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_action() {
    echo -e "${BOLD}[ACTION REQUIRED]${NC} $1"
}

# Check current spending status (based on provided data)
check_current_status() {
    print_status "Analyzing current spending situation..."
    echo

    # Current spending data
    CURRENT_SPENDING=95.94
    BUDGET_LIMIT=110.00
    REMAINING=$(echo "$BUDGET_LIMIT - $CURRENT_SPENDING" | bc -l)
    UTILIZATION=$(echo "scale=1; $CURRENT_SPENDING * 100 / $BUDGET_LIMIT" | bc -l)

    # Calculate days remaining in month
    TODAY=$(date +%d)
    DAYS_IN_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)
    DAYS_REMAINING=$((DAYS_IN_MONTH - TODAY))

    echo -e "${BOLD}📊 Current Budget Status:${NC}"
    echo "  Spent: \$${CURRENT_SPENDING} / \$${BUDGET_LIMIT}"
    echo "  Remaining: \$${REMAINING}"
    echo "  Utilization: ${UTILIZATION}%"
    echo "  Days left in month: ${DAYS_REMAINING}"
    echo

    if (( $(echo "$UTILIZATION >= 95" | bc -l) )); then
        print_error "🚨 CRITICAL: You're at ${UTILIZATION}% of budget!"
        print_action "Emergency cost reduction mode required"
        EMERGENCY_MODE=true
    elif (( $(echo "$UTILIZATION >= 85" | bc -l) )); then
        print_warning "⚠️  WARNING: High budget utilization (${UTILIZATION}%)"
        print_action "Immediate cost optimization recommended"
        WARNING_MODE=true
    else
        print_success "✅ Budget utilization within acceptable range"
    fi

    echo
}

# Set up local Ollama alternatives immediately
setup_local_ai() {
    print_status "Setting up local AI alternatives..."

    # Check if Ollama is installed
    if ! command -v ollama &> /dev/null; then
        print_warning "Ollama not found. Installing..."
        echo
        print_action "Please install Ollama:"
        echo "  Visit: https://ollama.ai"
        echo "  Or run: curl -fsSL https://ollama.ai/install.sh | sh"
        echo
        read -p "Press Enter after installing Ollama..."
    fi

    # Check available models
    echo "📋 Checking available local models..."
    AVAILABLE_MODELS=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | tr '\n' ' ')

    if [[ -z "$AVAILABLE_MODELS" ]]; then
        print_status "No models found. Installing essential models..."
        echo
        print_status "Installing mistral:latest (recommended for general use)..."
        ollama pull mistral:latest

        print_status "Installing codellama:7b (for technical content)..."
        ollama pull codellama:7b

        print_success "Essential models installed!"
    else
        print_success "Available models: $AVAILABLE_MODELS"
    fi

    echo
}

# Create immediate cost tracking
create_quick_tracker() {
    print_status "Creating quick cost tracker..."

    # Create data directory
    mkdir -p "$QOINS_ROOT/data"

    # Create simple cost tracking script
    cat > "$QOINS_ROOT/track_spending.sh" << 'EOF'
#!/bin/bash

# Quick Cost Tracker - Manual entry for immediate tracking
QOINS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="$QOINS_ROOT/data/daily_costs.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Initialize data file if it doesn't exist
if [[ ! -f "$DATA_FILE" ]]; then
    echo '{"budget_limit": 110.00, "daily_costs": []}' > "$DATA_FILE"
fi

# Function to add cost entry
add_cost() {
    local service=$1
    local amount=$2
    local description=$3
    local date=$(date +%Y-%m-%d)

    # Add entry to JSON (simple append)
    local entry="{\"date\": \"$date\", \"service\": \"$service\", \"amount\": $amount, \"description\": \"$description\"}"

    # Use jq if available, otherwise manual JSON handling
    if command -v jq &> /dev/null; then
        jq ".daily_costs += [$entry]" "$DATA_FILE" > "${DATA_FILE}.tmp" && mv "${DATA_FILE}.tmp" "$DATA_FILE"
    else
        # Simple manual append (less robust but works)
        sed -i 's/\]\}$/,'"$entry"']\}/' "$DATA_FILE"
    fi

    echo -e "${GREEN}✅ Added: $service - \$${amount} - $description${NC}"
}

# Function to show current status
show_status() {
    echo -e "${YELLOW}📊 Current Month Spending:${NC}"

    # Current known spending
    echo "  OpenAI API:    \$45.20"
    echo "  AWS:           \$28.15"
    echo "  GitHub:        \$12.30"
    echo "  Vercel:        \$10.29"
    echo "  ──────────────────────"
    echo "  Total:         \$95.94 / \$110.00 (87%)"
    echo "  Remaining:     \$14.06"
    echo

    # Show recent entries if any
    if [[ -f "$DATA_FILE" ]] && command -v jq &> /dev/null; then
        local recent=$(jq -r '.daily_costs | sort_by(.date) | reverse | .[0:5][] | "\(.date) - \(.service): $\(.amount) - \(.description)"' "$DATA_FILE" 2>/dev/null)
        if [[ -n "$recent" ]]; then
            echo -e "${YELLOW}📝 Recent entries:${NC}"
            echo "$recent"
            echo
        fi
    fi
}

# Main command handling
case "${1:-status}" in
    "add")
        if [[ $# -lt 3 ]]; then
            echo "Usage: $0 add <service> <amount> [description]"
            echo "Example: $0 add openai 5.20 'GPT-4 API calls for blog post'"
            exit 1
        fi
        add_cost "$2" "$3" "${4:-Manual entry}"
        ;;
    "status")
        show_status
        ;;
    "alert")
        # Check if we're approaching limits
        current_total=95.94
        if (( $(echo "$current_total >= 105" | bc -l) )); then
            echo -e "${RED}🚨 ALERT: Approaching budget limit!${NC}"
            echo "Consider switching to local models immediately."
        fi
        ;;
    *)
        echo "Usage: $0 {status|add|alert}"
        echo "  status - Show current spending"
        echo "  add <service> <amount> [description] - Add new cost entry"
        echo "  alert - Check for budget alerts"
        ;;
esac
EOF

    chmod +x "$QOINS_ROOT/track_spending.sh"
    print_success "Quick tracker created: ./track_spending.sh"
    echo
}

# Create cost optimization recommendations
create_optimizer() {
    print_status "Creating cost optimization guide..."

    cat > "$QOINS_ROOT/optimize_costs.sh" << 'EOF'
#!/bin/bash

# Immediate Cost Optimization Actions

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}💡 Immediate Cost Optimization Actions${NC}"
echo "========================================"
echo

echo -e "${YELLOW}🎯 HIGH IMPACT (Do Now):${NC}"
echo "1. Switch to local LLM for development tasks"
echo "   → Replace OpenAI calls with 'ollama run mistral:latest'"
echo "   → Potential savings: \$15-20/month"
echo

echo "2. Enable cost-aware AI selection in your code:"
echo "   → Check budget before expensive API calls"
echo "   → Use local models when budget is >80% used"
echo

echo "3. Batch API requests where possible"
echo "   → Combine multiple small requests"
echo "   → Use caching for repeated queries"
echo

echo -e "${BLUE}🔧 MEDIUM IMPACT (This Week):${NC}"
echo "4. Optimize AWS resources:"
echo "   → Review Lambda memory allocations"
echo "   → Check for unused EC2 instances"
echo "   → Enable S3 lifecycle policies"
echo

echo "5. GitHub Actions optimization:"
echo "   → Use smaller runners where possible"
echo "   → Cache dependencies effectively"
echo "   → Reduce unnecessary workflow runs"
echo

echo -e "${GREEN}📊 TRACKING (Ongoing):${NC}"
echo "6. Set up daily cost alerts:"
echo "   → Run './track_spending.sh status' daily"
echo "   → Monitor with './track_spending.sh alert'"
echo

echo "7. Weekly cost review:"
echo "   → Compare local vs cloud usage"
echo "   → Identify cost spikes"
echo "   → Adjust strategies accordingly"
echo

echo -e "${BOLD}🚨 Emergency Mode (Budget >95%):${NC}"
if [[ "${EMERGENCY_MODE:-false}" == "true" ]]; then
    echo -e "${RED}ACTIVATED - You are in emergency mode!${NC}"
    echo "→ Stop all non-essential cloud API calls"
    echo "→ Use only local models until month end"
    echo "→ Pause non-critical deployments"
    echo "→ Review and cancel unused subscriptions"
else
    echo "→ Automatically redirect all AI calls to local models"
    echo "→ Pause non-essential cloud operations"
    echo "→ Enable aggressive caching"
    echo "→ Alert on any spending above \$1/day"
fi

echo
echo -e "${BOLD}💰 Estimated Monthly Savings Potential:${NC}"
echo "Local AI adoption:        \$18-25"
echo "AWS optimization:         \$8-12"
echo "GitHub efficiency:        \$3-7"
echo "Request optimization:     \$5-10"
echo "────────────────────────────────"
echo "Total potential:          \$34-54/month"
echo
EOF

    chmod +x "$QOINS_ROOT/optimize_costs.sh"
    print_success "Cost optimizer created: ./optimize_costs.sh"
    echo
}

# Create local AI usage helper
create_local_ai_helper() {
    print_status "Creating local AI helper script..."

    cat > "$QOINS_ROOT/use_local_ai.sh" << 'EOF'
#!/bin/bash

# Local AI Helper - Easy interface for using local models instead of cloud APIs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

show_help() {
    echo -e "${BOLD}🤖 Local AI Helper${NC}"
    echo "==================="
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  chat <model> [prompt]    - Interactive chat with local model"
    echo "  generate <model> <prompt> - Single generation"
    echo "  models                   - List available models"
    echo "  test                     - Test model performance"
    echo "  compare                  - Compare models for same prompt"
    echo
    echo "Recommended models:"
    echo "  mistral:latest          - General purpose, fast"
    echo "  codellama:7b           - Code and technical content"
    echo "  llama2:7b              - Balanced performance"
    echo
    echo "Examples:"
    echo "  $0 chat mistral:latest"
    echo "  $0 generate codellama:7b 'Explain Redis caching'"
    echo "  $0 models"
}

list_models() {
    echo -e "${BLUE}📋 Available Local Models:${NC}"
    ollama list
    echo
    echo -e "${YELLOW}💡 Model Recommendations:${NC}"
    echo "• mistral:latest    - Best for general tasks (replaces GPT-3.5)"
    echo "• codellama:7b      - Best for coding tasks"
    echo "• llama2:13b        - Best quality (slower, more memory)"
    echo "• orca-mini:3b      - Fastest for quick tasks"
}

chat_with_model() {
    local model=$1
    shift
    local initial_prompt="$*"

    echo -e "${GREEN}💬 Starting chat with $model${NC}"
    echo "Type 'exit' or 'quit' to end the session"
    echo "Type 'cost' to see cost savings vs cloud API"
    echo "─────────────────────────────────────────"

    if [[ -n "$initial_prompt" ]]; then
        echo "You: $initial_prompt"
        echo
        ollama run "$model" "$initial_prompt"
        echo
    fi

    while true; do
        echo -n "You: "
        read -r user_input

        case "$user_input" in
            "exit"|"quit"|"q")
                echo "Chat ended."
                break
                ;;
            "cost")
                echo -e "${YELLOW}💰 Cost Comparison:${NC}"
                echo "Local model ($model): \$0.00"
                echo "GPT-3.5-turbo equivalent: ~\$0.002 per 1K tokens"
                echo "GPT-4 equivalent: ~\$0.03 per 1K tokens"
                echo "Monthly savings potential: \$15-30"
                echo
                ;;
            "")
                continue
                ;;
            *)
                echo
                ollama run "$model" "$user_input"
                echo
                ;;
        esac
    done
}

generate_once() {
    local model=$1
    local prompt="$2"

    if [[ -z "$prompt" ]]; then
        echo "Error: Please provide a prompt"
        exit 1
    fi

    echo -e "${BLUE}🎯 Generating with $model...${NC}"
    echo "Prompt: $prompt"
    echo "─────────────────────────────────────────"

    start_time=$(date +%s)
    ollama run "$model" "$prompt"
    end_time=$(date +%s)

    duration=$((end_time - start_time))
    echo
    echo -e "${GREEN}✅ Generated in ${duration}s (Cost: \$0.00)${NC}"
}

test_performance() {
    echo -e "${BLUE}🧪 Testing Local Model Performance${NC}"
    echo "=================================="

    local test_prompt="Write a brief explanation of how caching works in web applications."
    local models=("mistral:latest" "codellama:7b")

    for model in "${models[@]}"; do
        if ollama list | grep -q "$model"; then
            echo
            echo -e "${YELLOW}Testing $model...${NC}"
            start_time=$(date +%s)

            # Run the model with a timeout
            timeout 30s ollama run "$model" "$test_prompt" > /dev/null 2>&1

            end_time=$(date +%s)
            duration=$((end_time - start_time))

            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}✅ $model: ${duration}s${NC}"
            else
                echo -e "${RED}❌ $model: Failed or timed out${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  $model: Not installed${NC}"
        fi
    done

    echo
    echo -e "${BOLD}💡 Performance Tips:${NC}"
    echo "• Faster models: orca-mini:3b, mistral:latest"
    echo "• Better quality: llama2:13b, codellama:13b"
    echo "• Best balance: mistral:latest, llama2:7b"
}

compare_models() {
    local prompt="$1"
    if [[ -z "$prompt" ]]; then
        prompt="Explain the benefits of using local AI models vs cloud APIs."
    fi

    echo -e "${BLUE}🔄 Comparing Models${NC}"
    echo "Prompt: $prompt"
    echo "==========================================="

    local models=("mistral:latest" "codellama:7b")

    for model in "${models[@]}"; do
        if ollama list | grep -q "$model"; then
            echo
            echo -e "${YELLOW}─── $model ───${NC}"
            start_time=$(date +%s)
            ollama run "$model" "$prompt"
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo -e "${GREEN}(Generated in ${duration}s)${NC}"
        fi
    done
}

# Main command handling
case "${1:-help}" in
    "chat")
        shift
        model=${1:-mistral:latest}
        shift
        chat_with_model "$model" "$@"
        ;;
    "generate")
        shift
        model=${1:-mistral:latest}
        prompt="$2"
        generate_once "$model" "$prompt"
        ;;
    "models")
        list_models
        ;;
    "test")
        test_performance
        ;;
    "compare")
        shift
        compare_models "$*"
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF

    chmod +x "$QOINS_ROOT/use_local_ai.sh"
    print_success "Local AI helper created: ./use_local_ai.sh"
    echo
}

# Create daily monitoring script
create_daily_monitor() {
    print_status "Creating daily monitoring script..."

    cat > "$QOINS_ROOT/daily_check.sh" << 'EOF'
#!/bin/bash

# Daily Cost Check - Run this every morning

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}🌅 Daily Cost Check - $(date '+%Y-%m-%d')${NC}"
echo "=================================="
echo

# Current status
echo -e "${YELLOW}📊 Budget Status:${NC}"
echo "  Current: \$95.94 / \$110.00 (87%)"
echo "  Remaining: \$14.06"

# Days calculation
TODAY=$(date +%d)
DAYS_IN_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)
DAYS_REMAINING=$((DAYS_IN_MONTH - TODAY))
echo "  Days left: $DAYS_REMAINING"

# Daily budget calculation
DAILY_BUDGET=$(echo "scale=2; 14.06 / $DAYS_REMAINING" | bc -l)
echo "  Suggested daily limit: \$${DAILY_BUDGET}"
echo

# Recommendations based on budget status
if (( $(echo "95.94 >= 105" | bc -l) )); then
    echo -e "${RED}🚨 EMERGENCY MODE:${NC}"
    echo "→ Use ONLY local models today"
    echo "→ Pause all non-essential cloud operations"
    echo "→ Target spending: \$0.50 or less"
elif (( $(echo "95.94 >= 98" | bc -l) )); then
    echo -e "${YELLOW}⚠️  CAUTION MODE:${NC}"
    echo "→ Prefer local models for all tasks"
    echo "→ Use cloud APIs only when absolutely necessary"
    echo "→ Target spending: \$${DAILY_BUDGET} or less"
else
    echo -e "${GREEN}✅ NORMAL MODE:${NC}"
    echo "→ Can use cloud APIs sparingly"
    echo "→ Prefer local models when possible"
    echo "→ Target spending: \$${DAILY_BUDGET}"
fi

echo
echo -e "${BOLD}💡 Today's Action Items:${NC}"
echo "1. Check './track_spending.sh status' for latest costs"
echo "2. Use './use_local_ai.sh chat mistral:latest' for AI tasks"
echo "3. Run './optimize_costs.sh' to review savings opportunities"
echo "4. Update spending with './track_spending.sh add <service> <amount>'"
echo

echo -e "${YELLOW}🤖 Quick Local AI Test:${NC}"
if command -v ollama &> /dev/null; then
    if ollama list | grep -q "mistral:latest"; then
        echo "✅ Ollama and mistral:latest ready"
    else
        echo "⚠️  Install mistral: ollama pull mistral:latest"
    fi
else
    echo "❌ Install Ollama: https://ollama.ai"
fi

echo
echo "Run this daily: ./daily_check.sh"
EOF

    chmod +x "$QOINS_ROOT/daily_check.sh"
    print_success "Daily monitor created: ./daily_check.sh"
    echo
}

# Main execution
main() {
    print_header

    check_current_status

    if [[ "${EMERGENCY_MODE:-false}" == "true" ]] || [[ "${WARNING_MODE:-false}" == "true" ]]; then
        print_action "Setting up emergency cost control measures..."
    else
        print_status "Setting up proactive cost management..."
    fi

    echo

    setup_local_ai
    create_quick_tracker
    create_optimizer
    create_local_ai_helper
    create_daily_monitor

    print_success "🎉 QOINs Quick Start Complete!"
    echo
    echo -e "${BOLD}🚀 Next Steps:${NC}"
    echo "1. Run './optimize_costs.sh' to see immediate savings opportunities"
    echo "2. Test local AI: './use_local_ai.sh chat mistral:latest'"
    echo "3. Track spending: './track_spending.sh status'"
    echo "4. Daily monitoring: './daily_check.sh'"
    echo

    if [[ "${EMERGENCY_MODE:-false}" == "true" ]]; then
        print_error "🚨 EMERGENCY: You're at 87% budget with days remaining!"
        print_action "Run './optimize_costs.sh' NOW to see emergency actions"
    elif [[ "${WARNING_MODE:-false}" == "true" ]]; then
        print_warning "⚠️  HIGH USAGE: Consider immediate optimization"
        print_action "Start using local models today to avoid overages"
    fi

    echo
    echo -e "${GREEN}💰 Potential Monthly Savings: \$25-40${NC}"
    echo -e "${BLUE}📱 For live dashboard: open dashboard/index.html${NC}"
    echo
}

# Check if running with --help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "QOINs Quick Start - Emergency Cost Control"
    echo ""
    echo "This script sets up immediate cost tracking and optimization tools."
    echo "Perfect for when you're approaching budget limits and need quick action."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Creates:"
    echo "  • Cost tracking tools"
    echo "  • Local AI setup"
    echo "  • Optimization recommendations"
    echo "  • Daily monitoring"
    echo ""
    exit 0
fi

# Run main function
main "$@"

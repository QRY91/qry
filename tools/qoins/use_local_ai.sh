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

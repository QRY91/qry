#!/bin/bash

# AI Model Benchmarking Quick Start
# Test local models vs cloud APIs for cost optimization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    echo -e "${BLUE}${BOLD}"
    echo "🧪 AI Model Benchmarking Suite"
    echo "============================="
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

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."

    # Check Ollama
    if ! command -v ollama &> /dev/null; then
        print_error "Ollama not found. Please install it first:"
        echo "  Visit: https://ollama.ai"
        echo "  Or run: curl -fsSL https://ollama.ai/install.sh | sh"
        exit 1
    fi

    # Check for basic tools
    for tool in bc jq curl; do
        if ! command -v $tool &> /dev/null; then
            print_warning "$tool not found - some features may be limited"
        fi
    done

    print_success "Dependencies check complete"
}

# Get available models
get_available_models() {
    print_status "Scanning available local models..."

    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v '^$')

    if [[ -z "$models" ]]; then
        print_warning "No models found. Installing recommended models..."
        install_recommended_models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v '^$')
    fi

    echo "$models"
}

# Install recommended models for benchmarking
install_recommended_models() {
    local recommended=("mistral:latest" "codellama:7b" "llama2:7b")

    for model in "${recommended[@]}"; do
        print_status "Installing $model..."
        ollama pull "$model" || print_warning "Failed to install $model"
    done
}

# Run single model benchmark
benchmark_model() {
    local model=$1
    local prompt=$2
    local test_name=$3

    echo -e "${YELLOW}Testing $model on '$test_name'...${NC}"

    # Create temp file for prompt
    local temp_file=$(mktemp)
    echo "$prompt" > "$temp_file"

    # Time the execution
    local start_time=$(date +%s.%N)

    # Run the model with timeout
    local response
    if response=$(timeout 60s ollama run "$model" < "$temp_file" 2>/dev/null); then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l)

        # Calculate metrics
        local response_length=${#response}
        local estimated_tokens=$((response_length / 4))  # Rough estimate

        echo "  ✅ Response time: ${duration}s"
        echo "  📏 Response length: ${response_length} chars (~${estimated_tokens} tokens)"
        echo "  💰 Cost: \$0.00 (local)"

        # Show response preview
        local preview=$(echo "$response" | head -c 100)
        echo "  📝 Preview: ${preview}..."
        echo

        # Save results
        echo "$model,$test_name,$duration,$estimated_tokens,0.00" >> /tmp/benchmark_results.csv

        rm -f "$temp_file"
        return 0
    else
        print_error "  Model $model failed or timed out"
        rm -f "$temp_file"
        return 1
    fi
}

# Run comprehensive benchmark suite
run_benchmark_suite() {
    print_status "Running comprehensive benchmark suite..."

    # Initialize results file
    echo "model,test_name,response_time,tokens,cost" > /tmp/benchmark_results.csv

    local models=($(get_available_models))

    if [[ ${#models[@]} -eq 0 ]]; then
        print_error "No models available for testing"
        exit 1
    fi

    print_success "Testing ${#models[@]} models: ${models[*]}"
    echo

    # Test prompts for different use cases
    local tests=(
        "quick_response|Write a brief explanation of what Docker is.|Quick Response Test"
        "code_explanation|Explain how async/await works in JavaScript with a simple example.|Code Explanation"
        "blog_content|Write an introduction paragraph for a blog post about microservices architecture.|Blog Content"
        "technical_summary|Summarize the key benefits of using Redis as a caching layer in web applications.|Technical Summary"
        "problem_solving|How would you debug a memory leak in a Node.js application? List 3 approaches.|Problem Solving"
    )

    for test_spec in "${tests[@]}"; do
        IFS='|' read -r test_id prompt test_name <<< "$test_spec"

        echo -e "${BOLD}🎯 Test: $test_name${NC}"
        echo "Prompt: $prompt"
        echo "────────────────────────────────────────"

        for model in "${models[@]}"; do
            benchmark_model "$model" "$prompt" "$test_name"
        done

        echo
    done
}

# Analyze results and generate report
analyze_results() {
    if [[ ! -f /tmp/benchmark_results.csv ]]; then
        print_error "No benchmark results found"
        return 1
    fi

    print_status "Analyzing benchmark results..."
    echo

    echo -e "${BOLD}📊 BENCHMARK RESULTS SUMMARY${NC}"
    echo "════════════════════════════════════════"

    # Model performance summary
    echo -e "${YELLOW}🚀 Model Performance:${NC}"
    printf "%-20s %-15s %-15s %-10s\n" "Model" "Avg Time (s)" "Avg Tokens" "Tests"
    echo "────────────────────────────────────────────────────────────────"

    # Process results with awk
    awk -F',' '
    NR > 1 {
        model = $1
        time = $2
        tokens = $4

        times[model] += time
        token_counts[model] += tokens
        test_counts[model]++
    }
    END {
        for (model in times) {
            avg_time = times[model] / test_counts[model]
            avg_tokens = token_counts[model] / test_counts[model]
            printf "%-20s %-15.2f %-15.0f %-10d\n", model, avg_time, avg_tokens, test_counts[model]
        }
    }' /tmp/benchmark_results.csv

    echo

    # Cost comparison
    echo -e "${YELLOW}💰 Cost Comparison (vs Cloud APIs):${NC}"
    echo "Local models: \$0.00 per request"
    echo "GPT-3.5-turbo equivalent: ~\$0.002 per 1K tokens"
    echo "GPT-4 equivalent: ~\$0.03 per 1K tokens"
    echo "Claude-3-Sonnet equivalent: ~\$0.003 per 1K tokens"
    echo

    # Calculate potential savings
    local total_tokens=$(awk -F',' 'NR > 1 {sum += $4} END {print sum}' /tmp/benchmark_results.csv)
    if [[ -n "$total_tokens" && "$total_tokens" -gt 0 ]]; then
        local gpt35_cost=$(echo "scale=2; $total_tokens * 0.002 / 1000" | bc -l)
        local gpt4_cost=$(echo "scale=2; $total_tokens * 0.03 / 1000" | bc -l)

        echo -e "${GREEN}💡 Savings Analysis:${NC}"
        echo "Total tokens in benchmark: $total_tokens"
        echo "Cost if using GPT-3.5: \$${gpt35_cost}"
        echo "Cost if using GPT-4: \$${gpt4_cost}"
        echo "Cost using local models: \$0.00"
        echo "Monthly savings potential (100x usage): \$$(echo "scale=2; $gpt35_cost * 100" | bc -l) - \$$(echo "scale=2; $gpt4_cost * 100" | bc -l)"
    fi

    echo
}

# Generate recommendations
generate_recommendations() {
    if [[ ! -f /tmp/benchmark_results.csv ]]; then
        return 1
    fi

    echo -e "${BOLD}💡 RECOMMENDATIONS${NC}"
    echo "════════════════════"

    # Find fastest model
    local fastest=$(awk -F',' '
    NR > 1 {
        times[model] += $2
        counts[model]++
    }
    END {
        min_time = 999999
        fastest_model = ""
        for (model in times) {
            avg = times[model] / counts[model]
            if (avg < min_time) {
                min_time = avg
                fastest_model = model
            }
        }
        print fastest_model
    }' /tmp/benchmark_results.csv)

    # Find most verbose model (highest token output)
    local most_verbose=$(awk -F',' '
    NR > 1 {
        tokens[model] += $4
        counts[model]++
    }
    END {
        max_tokens = 0
        verbose_model = ""
        for (model in tokens) {
            avg = tokens[model] / counts[model]
            if (avg > max_tokens) {
                max_tokens = avg
                verbose_model = model
            }
        }
        print verbose_model
    }' /tmp/benchmark_results.csv)

    echo "🏃 Fastest model: $fastest"
    echo "  → Use for quick responses and real-time applications"
    echo

    echo "📝 Most detailed model: $most_verbose"
    echo "  → Use for comprehensive content generation"
    echo

    echo -e "${YELLOW}🎯 Use Case Recommendations:${NC}"
    echo "• Quick dev logs: Use fastest model ($fastest)"
    echo "• Code explanations: Use codellama models if available"
    echo "• Blog content: Use most detailed model ($most_verbose)"
    echo "• Technical docs: Balance speed and detail"
    echo

    echo -e "${GREEN}🔧 Integration Tips:${NC}"
    echo "1. Set up model selection based on task type"
    echo "2. Use local models for 80%+ of AI tasks"
    echo "3. Reserve cloud APIs for critical/public content"
    echo "4. Implement fallback chains: local → cloud"
    echo "5. Monitor usage with QOINs cost tracking"
    echo
}

# Quick performance test
quick_test() {
    local model=${1:-mistral:latest}

    print_status "Running quick performance test with $model..."

    local test_prompt="Explain what a REST API is in 2-3 sentences."

    echo "Prompt: $test_prompt"
    echo "────────────────────────────────"

    local start_time=$(date +%s.%N)

    if ollama run "$model" "$test_prompt"; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l)

        echo
        print_success "Completed in ${duration}s (Cost: \$0.00)"

        # Quick cost comparison
        echo
        echo -e "${YELLOW}💰 Cost Comparison:${NC}"
        echo "Local ($model): \$0.00"
        echo "GPT-3.5-turbo: ~\$0.01"
        echo "GPT-4: ~\$0.15"
    else
        print_error "Test failed"
        return 1
    fi
}

# Model installation helper
install_models() {
    local models_to_install=(
        "mistral:latest|General purpose, fast"
        "codellama:7b|Code generation and explanation"
        "llama2:7b|Balanced performance"
        "llama2:13b|Higher quality, slower"
        "orca-mini:3b|Fastest, good for quick tasks"
    )

    echo -e "${BOLD}🔽 Available Models for Installation${NC}"
    echo "══════════════════════════════════════"

    for i in "${!models_to_install[@]}"; do
        IFS='|' read -r model desc <<< "${models_to_install[$i]}"
        echo "$((i+1)). $model - $desc"
    done

    echo "a. Install all recommended models"
    echo "q. Quit"
    echo

    read -p "Select models to install (e.g., 1,2,3 or 'a' for all): " selection

    case "$selection" in
        "a"|"all")
            for model_spec in "${models_to_install[@]}"; do
                IFS='|' read -r model desc <<< "$model_spec"
                print_status "Installing $model..."
                ollama pull "$model"
            done
            ;;
        "q"|"quit")
            return 0
            ;;
        *)
            IFS=',' read -ra SELECTED <<< "$selection"
            for i in "${SELECTED[@]}"; do
                if [[ "$i" =~ ^[0-9]+$ ]] && [[ "$i" -le "${#models_to_install[@]}" ]]; then
                    IFS='|' read -r model desc <<< "${models_to_install[$((i-1))]}"
                    print_status "Installing $model..."
                    ollama pull "$model"
                fi
            done
            ;;
    esac
}

# Usage help
show_help() {
    echo "AI Model Benchmarking Tool"
    echo "========================="
    echo
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  benchmark    - Run comprehensive benchmark suite"
    echo "  quick        - Quick performance test"
    echo "  install      - Install recommended models"
    echo "  models       - List available models"
    echo "  analyze      - Analyze previous results"
    echo "  compare      - Compare specific models"
    echo
    echo "Examples:"
    echo "  $0 benchmark                    # Full benchmark"
    echo "  $0 quick mistral:latest         # Quick test"
    echo "  $0 install                      # Install models"
    echo "  $0 compare mistral:latest llama2:7b"
    echo
}

# Compare specific models
compare_models() {
    local models=("$@")

    if [[ ${#models[@]} -lt 2 ]]; then
        print_error "Please specify at least 2 models to compare"
        echo "Available models:"
        ollama list
        return 1
    fi

    print_status "Comparing models: ${models[*]}"

    local test_prompt="Explain the benefits of microservices architecture in 3 key points."

    echo "Test prompt: $test_prompt"
    echo "═══════════════════════════════════════════════"

    for model in "${models[@]}"; do
        echo
        echo -e "${YELLOW}🤖 Testing $model${NC}"
        echo "─────────────────────────"

        local start_time=$(date +%s.%N)

        if timeout 45s ollama run "$model" "$test_prompt"; then
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc -l)
            echo -e "${GREEN}⏱️  Completed in ${duration}s${NC}"
        else
            print_error "Failed or timed out"
        fi
    done
}

# Main execution
main() {
    case "${1:-help}" in
        "benchmark"|"bench")
            print_header
            check_dependencies
            run_benchmark_suite
            analyze_results
            generate_recommendations
            ;;
        "quick")
            shift
            print_header
            check_dependencies
            quick_test "$@"
            ;;
        "install")
            print_header
            check_dependencies
            install_models
            ;;
        "models")
            check_dependencies
            echo "Available local models:"
            ollama list
            ;;
        "analyze")
            analyze_results
            generate_recommendations
            ;;
        "compare")
            shift
            print_header
            check_dependencies
            compare_models "$@"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Check for no arguments
if [[ $# -eq 0 ]]; then
    print_header
    echo "Welcome to the AI Model Benchmarking Suite!"
    echo
    echo "This tool helps you:"
    echo "• Test local AI model performance"
    echo "• Compare models for different use cases"
    echo "• Calculate cost savings vs cloud APIs"
    echo "• Optimize your AI workflow for cost efficiency"
    echo
    echo "Quick start:"
    echo "  $0 quick              # Run a quick test"
    echo "  $0 benchmark         # Full benchmark suite"
    echo "  $0 install           # Install recommended models"
    echo
    echo "For help: $0 help"
    exit 0
fi

# Run main function
main "$@"

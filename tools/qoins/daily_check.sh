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

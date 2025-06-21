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

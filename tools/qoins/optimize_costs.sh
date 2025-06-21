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

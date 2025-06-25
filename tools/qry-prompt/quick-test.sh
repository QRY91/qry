#!/bin/bash

# QRY Prompt Quick Test
# Even simpler - just source and show prompt without changing anything

echo "🧪 QRY Prompt Quick Test"
echo "======================="
echo ""

# Check if nerd fonts might be available
if fc-list | grep -qi "nerd\|powerline" 2>/dev/null; then
    echo "✓ Nerd fonts detected"
else
    echo "⚠️  Nerd fonts not detected - icons may not display properly"
    echo "   Install with: ./install.sh --fonts-only"
fi

echo ""
echo "Current directory prompt preview:"
echo "================================="

# Source and show prompt without changing shell
source ./qry-prompt.sh
build_prompt

echo ""
echo "🎨 Feature demonstration:"
./demo.sh

echo ""
echo "💡 To test interactively without changing your shell config:"
echo "   ./test-mode.sh     (safe test session)"
echo ""
echo "💡 To install permanently:"
echo "   ./install.sh       (can be reverted)"
echo ""
echo "💡 Your current Starship setup will not be modified."
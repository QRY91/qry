#!/bin/bash
# QRY Chaos Recovery Script
# Generated automatically during pre-chaos backup
# Usage: ./RECOVER_FROM_CHAOS.sh

echo "🚨 QRY CHAOS RECOVERY PROTOCOL 🚨"
echo "================================="
echo ""
echo "This script will restore QRY ecosystem from pre-chaos backup."
echo ""
read -p "Are you sure you want to restore from backup? [y/N]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Recovery cancelled."
    exit 0
fi

# Restore databases
if [ -f "uroboro-pre-chaos.sqlite" ]; then
    cp "uroboro-pre-chaos.sqlite" "$HOME/.local/share/uroboro/uroboro.sqlite"
    echo "✅ Uroboro database restored"
fi

if [ -f "wherewasi-pre-chaos.sqlite" ]; then
    cp "wherewasi-pre-chaos.sqlite" "$HOME/.local/share/wherewasi/context.sqlite"
    echo "✅ Wherewasi database restored"
fi

if [ -f "ecosystem-pre-chaos.sqlite" ]; then
    cp "ecosystem-pre-chaos.sqlite" "$HOME/.local/share/qry/ecosystem.sqlite"
    echo "✅ Ecosystem database restored"
fi

echo ""
echo "🎉 Recovery complete! Your data has been restored."
echo "The chaos experiment damage has been undone."
echo ""
echo "Remember: Junkyard engineering is about learning through failure."
echo "This failure taught you something. Document it!"

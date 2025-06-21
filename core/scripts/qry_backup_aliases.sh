#!/bin/bash
# QRY Backup Aliases for Junkyard Engineer Convenience
# 
# Purpose: Quick access to backup operations for systematic chaos
# Usage: source scripts/qry_backup_aliases.sh (add to ~/.bashrc for permanent)
#
# Philosophy: "Make safety so easy you do it automatically"

# Get the QRY project root directory
QRY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Core backup aliases
alias qry-backup="$QRY_ROOT/scripts/backup_uroboro.sh"
alias qry-backup-now="$QRY_ROOT/scripts/backup_uroboro.sh --auto-commit"

# Chaos preparation aliases
alias qry-chaos="$QRY_ROOT/scripts/backup_before_chaos.sh"
alias qry-experiment="$QRY_ROOT/scripts/backup_before_chaos.sh"
alias qry-safety="$QRY_ROOT/scripts/backup_before_chaos.sh"

# Quick status checks
alias qry-backup-status="echo '📊 QRY Backup Status:' && ls -la $QRY_ROOT/backups/uroboro/ | tail -5 && echo '' && echo '⚡ Chaos Backups:' && ls -la $QRY_ROOT/backups/chaos/ 2>/dev/null || echo 'No chaos backups yet'"

# Database status
alias qry-db-status="echo '🗄️  QRY Database Status:' && echo 'Uroboro:' && [ -f ~/.local/share/uroboro/uroboro.sqlite ] && sqlite3 ~/.local/share/uroboro/uroboro.sqlite 'SELECT COUNT(*) || \" captures\" FROM captures;' || echo 'Not found' && echo 'Wherewasi:' && [ -f ~/.local/share/wherewasi/context.sqlite ] && sqlite3 ~/.local/share/wherewasi/context.sqlite 'SELECT COUNT(*) || \" contexts\" FROM context_sessions;' 2>/dev/null || echo 'Not found' && echo 'Ecosystem:' && [ -f ~/.local/share/qry/ecosystem.sqlite ] && sqlite3 ~/.local/share/qry/ecosystem.sqlite 'SELECT name FROM sqlite_master WHERE type=\"table\";' | wc -l | awk '{print $1 \" tables\"}' || echo 'Not found'"

# Recovery helpers
alias qry-recover="echo '🚨 QRY Recovery Options:' && echo '1. List chaos backups: ls -la $QRY_ROOT/backups/chaos/' && echo '2. Enter backup dir: cd \$QRY_ROOT/backups/chaos/[experiment-name]' && echo '3. Run recovery: ./RECOVER_FROM_CHAOS.sh'"

# Junkyard engineer motivation
alias qry-unleash="echo '' && echo '⚡ JUNKYARD ENGINEER MODE ⚡' && echo 'Remember:' && echo '✅ Safety nets deployed (daily backups)' && echo '✅ Chaos backup ready (qry-chaos [experiment-name])' && echo '✅ Recovery tools available (qry-recover)' && echo '' && echo '🔬 You may now proceed with gleeful destruction!' && echo 'Document everything. Fail systematically. Learn exponentially.' && echo ''"

# Development workflow helpers
alias qry-dev-backup="qry-chaos development-session --force"
alias qry-feature-backup="echo 'Usage: qry-chaos feature-[name] --force'"
alias qry-migration-backup="echo 'Usage: qry-chaos migration-[description] --force'"

# Show available commands
alias qry-backup-help="echo '🔒 QRY Backup Commands:' && echo '' && echo 'Daily Backups:' && echo '  qry-backup              - Manual backup' && echo '  qry-backup-now          - Backup + git commit' && echo '' && echo 'Chaos Preparation:' && echo '  qry-chaos [name]        - Full pre-experiment backup' && echo '  qry-experiment [name]   - Alias for qry-chaos' && echo '  qry-safety [name]       - Alias for qry-chaos' && echo '' && echo 'Quick Dev Backups:' && echo '  qry-dev-backup          - Quick development backup' && echo '' && echo 'Status & Recovery:' && echo '  qry-backup-status       - Show backup status' && echo '  qry-db-status           - Show database status' && echo '  qry-recover             - Recovery instructions' && echo '' && echo 'Junkyard Engineer:' && echo '  qry-unleash             - Motivational reminder' && echo '  qry-backup-help         - Show this help' && echo ''"

# Welcome message when sourced
echo ""
echo "🔒 QRY Backup Aliases Loaded!"
echo "Type 'qry-backup-help' for available commands"
echo "Type 'qry-unleash' for junkyard engineer motivation"
echo ""
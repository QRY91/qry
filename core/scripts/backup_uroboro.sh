#!/bin/bash
# QRY Uroboro Database Backup Script
# 
# Purpose: Preserve uroboro methodology insights before junkyard engineer experiments
# Philosophy: Anti-fragile data preservation for community knowledge
# Usage: ./scripts/backup_uroboro.sh [--auto-commit]
#
# This script embodies QRY principles:
# - Systematic backup methodology  
# - Anti-fragile data preservation
# - Community knowledge protection
# - Junkyard engineer safety net

set -e  # Exit on error - anti-fragile scripting

# Configuration
UROBORO_DB="$HOME/.local/share/uroboro/uroboro.sqlite"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$(dirname "$SCRIPT_DIR")/backups/uroboro"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
BACKUP_FILE="uroboro-backup-${TIMESTAMP}.sqlite"
MAX_BACKUPS=10  # Keep last 10 backups

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 QRY Uroboro Backup Script${NC}"
echo "================================="

# Check if uroboro database exists
if [ ! -f "$UROBORO_DB" ]; then
    echo -e "${RED}❌ Error: Uroboro database not found at $UROBORO_DB${NC}"
    echo "Make sure uroboro has been run at least once to create the database."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Get database size for verification
DB_SIZE=$(du -h "$UROBORO_DB" | cut -f1)
RECORD_COUNT=$(sqlite3 "$UROBORO_DB" "SELECT COUNT(*) FROM captures;" 2>/dev/null || echo "unknown")

echo "📊 Database Status:"
echo "   Location: $UROBORO_DB"
echo "   Size: $DB_SIZE"
echo "   Records: $RECORD_COUNT captures"
echo ""

# Perform backup
echo -e "${YELLOW}📦 Creating backup...${NC}"
cp "$UROBORO_DB" "$BACKUP_DIR/$BACKUP_FILE"

# Verify backup
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✅ Backup created successfully!${NC}"
    echo "   Backup: $BACKUP_DIR/$BACKUP_FILE"
    echo "   Size: $BACKUP_SIZE"
else
    echo -e "${RED}❌ Backup failed!${NC}"
    exit 1
fi

# Clean up old backups (keep only MAX_BACKUPS)
echo ""
echo -e "${YELLOW}🧹 Cleaning up old backups...${NC}"
cd "$BACKUP_DIR"
BACKUP_COUNT=$(ls -1 uroboro-backup-*.sqlite 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    EXCESS_COUNT=$((BACKUP_COUNT - MAX_BACKUPS))
    echo "   Found $BACKUP_COUNT backups, removing oldest $EXCESS_COUNT"
    ls -1t uroboro-backup-*.sqlite | tail -n "$EXCESS_COUNT" | xargs rm -f
    echo "   Kept $MAX_BACKUPS most recent backups"
else
    echo "   $BACKUP_COUNT backups found, no cleanup needed"
fi

# List current backups
echo ""
echo "📂 Current backups:"
ls -lah uroboro-backup-*.sqlite | while read -r line; do
    echo "   $line"
done

# Git integration (optional)
if [ "$1" = "--auto-commit" ]; then
    echo ""
    echo -e "${YELLOW}📝 Committing backup to git...${NC}"
    cd "$(dirname "$SCRIPT_DIR")"
    git add "backups/uroboro/$BACKUP_FILE"
    git commit -m "Backup uroboro database before experiments - $RECORD_COUNT captures preserved

- Database size: $DB_SIZE  
- Backup: $BACKUP_FILE
- Safety backup before development work
- Community knowledge preservation"
    echo -e "${GREEN}✅ Backup committed to git${NC}"
fi

echo ""
echo -e "${GREEN}✅ Backup complete!${NC}"
echo "Your data has been safely backed up."
echo "You can now proceed with development work."
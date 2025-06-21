#!/bin/bash
# QRY Pre-Experiment Chaos Backup Script
# 
# Purpose: Create comprehensive safety backup before junkyard engineer experiments
# Philosophy: "Systematic chaos requires systematic safety nets"
# Usage: ./scripts/backup_before_chaos.sh [experiment_name] [--force]
#
# This script embodies QRY junkyard engineer principles:
# - Gleeful destruction requires bulletproof preservation
# - Mad scientist mode needs data scientist safety
# - Anti-fragile experimentation through systematic backup
# - Community knowledge protection before individual chaos

set -e  # Exit on error - no chaos without safety

# Configuration
UROBORO_DB="$HOME/.local/share/uroboro/uroboro.sqlite"
WHEREWASI_DB="$HOME/.local/share/wherewasi/context.sqlite"
ECOSYSTEM_DB="$HOME/.local/share/qry/ecosystem.sqlite"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$(dirname "$SCRIPT_DIR")/backups"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
EXPERIMENT_NAME="${1:-unknown-experiment}"
CHAOS_BACKUP_DIR="$BACKUP_DIR/chaos/$EXPERIMENT_NAME-$TIMESTAMP"

# Colors for dramatic junkyard engineer output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${PURPLE}⚡ QRY PRE-CHAOS BACKUP PROTOCOL ⚡${NC}"
echo "================================================"
echo -e "${CYAN}Experiment: ${EXPERIMENT_NAME}${NC}"
echo -e "${CYAN}Timestamp: ${TIMESTAMP}${NC}"
echo ""

# Junkyard engineer safety check
if [ "$2" != "--force" ]; then
    echo -e "${YELLOW}🤔 JUNKYARD ENGINEER SAFETY CHECK${NC}"
    echo "About to backup everything before potentially destructive experiment."
    echo ""
    echo -e "${RED}⚠️  This experiment could break things. That's the point.${NC}"
    echo -e "${GREEN}✅ But we're backing up everything first. That's also the point.${NC}"
    echo ""
    read -p "Ready to proceed with chaos preparation? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🛡️  Wise choice. Experiment cancelled.${NC}"
        echo "Junkyard engineering is about gleeful destruction, not reckless destruction."
        exit 0
    fi
fi

echo -e "${BLUE}🔍 SCANNING QRY ECOSYSTEM FOR VALUABLE DATA...${NC}"

# Create chaos backup directory
mkdir -p "$CHAOS_BACKUP_DIR"

# Function to backup a database if it exists
backup_database() {
    local db_path="$1"
    local db_name="$2"
    local backup_name="$3"
    
    if [ -f "$db_path" ]; then
        local db_size=$(du -h "$db_path" | cut -f1)
        local record_count=$(sqlite3 "$db_path" "SELECT name FROM sqlite_master WHERE type='table';" 2>/dev/null | wc -l || echo "N/A")
        
        echo -e "${YELLOW}📦 Backing up $db_name...${NC}"
        echo "   Location: $db_path"
        echo "   Size: $db_size"
        echo "   Tables: $record_count"
        
        cp "$db_path" "$CHAOS_BACKUP_DIR/$backup_name"
        
        if [ -f "$CHAOS_BACKUP_DIR/$backup_name" ]; then
            echo -e "${GREEN}   ✅ $db_name backed up successfully${NC}"
            return 0
        else
            echo -e "${RED}   ❌ $db_name backup failed${NC}"
            return 1
        fi
    else
        echo -e "${BLUE}   ℹ️  $db_name not found (probably not created yet)${NC}"
        return 0
    fi
}

echo ""

# Backup all QRY databases
backup_database "$UROBORO_DB" "Uroboro Database" "uroboro-pre-chaos.sqlite"
backup_database "$WHEREWASI_DB" "Wherewasi Database" "wherewasi-pre-chaos.sqlite" 
backup_database "$ECOSYSTEM_DB" "Ecosystem Database" "ecosystem-pre-chaos.sqlite"

# Backup critical QRY configuration and code
echo ""
echo -e "${YELLOW}📁 Backing up critical QRY ecosystem files...${NC}"

# Create manifest of what we're backing up
MANIFEST_FILE="$CHAOS_BACKUP_DIR/backup_manifest.txt"
echo "QRY Pre-Chaos Backup Manifest" > "$MANIFEST_FILE"
echo "==============================" >> "$MANIFEST_FILE"
echo "Experiment: $EXPERIMENT_NAME" >> "$MANIFEST_FILE"
echo "Timestamp: $TIMESTAMP" >> "$MANIFEST_FILE"
echo "Backup Directory: $CHAOS_BACKUP_DIR" >> "$MANIFEST_FILE"
echo "" >> "$MANIFEST_FILE"

# Backup QRY northstars and critical docs
QRY_ROOT="$(dirname "$SCRIPT_DIR")"
if [ -f "$QRY_ROOT/QRY_NORTHSTARS.md" ]; then
    cp "$QRY_ROOT/QRY_NORTHSTARS.md" "$CHAOS_BACKUP_DIR/"
    echo "✅ QRY_NORTHSTARS.md" >> "$MANIFEST_FILE"
fi

# Backup AI collaboration infrastructure
if [ -d "$QRY_ROOT/ai" ]; then
    cp -r "$QRY_ROOT/ai" "$CHAOS_BACKUP_DIR/"
    echo "✅ AI collaboration infrastructure" >> "$MANIFEST_FILE"
fi

# Backup any existing ecosystem packages (in case we break them)
for tool_dir in "$QRY_ROOT/labs/projects"/*; do
    if [ -d "$tool_dir/internal/ecosystem" ]; then
        tool_name=$(basename "$tool_dir")
        mkdir -p "$CHAOS_BACKUP_DIR/ecosystem_packages"
        cp -r "$tool_dir/internal/ecosystem" "$CHAOS_BACKUP_DIR/ecosystem_packages/$tool_name-ecosystem"
        echo "✅ $tool_name ecosystem package" >> "$MANIFEST_FILE"
    fi
done

# Create git state snapshot
echo "" >> "$MANIFEST_FILE"
echo "Git State:" >> "$MANIFEST_FILE"
cd "$QRY_ROOT"
git rev-parse HEAD >> "$MANIFEST_FILE" 2>/dev/null || echo "Not a git repository" >> "$MANIFEST_FILE"
git status --porcelain >> "$MANIFEST_FILE" 2>/dev/null || echo "No git status available" >> "$MANIFEST_FILE"

# Create recovery script
RECOVERY_SCRIPT="$CHAOS_BACKUP_DIR/RECOVER_FROM_CHAOS.sh"
cat > "$RECOVERY_SCRIPT" << 'EOF'
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
EOF

chmod +x "$RECOVERY_SCRIPT"

# Calculate total backup size
BACKUP_SIZE=$(du -sh "$CHAOS_BACKUP_DIR" | cut -f1)

echo ""
echo -e "${GREEN}🎉 PRE-CHAOS BACKUP COMPLETE!${NC}"
echo "================================"
echo -e "${CYAN}Backup Location: $CHAOS_BACKUP_DIR${NC}"
echo -e "${CYAN}Total Size: $BACKUP_SIZE${NC}"
echo ""
echo -e "${PURPLE}⚡ JUNKYARD ENGINEER MODE ACTIVATED ⚡${NC}"
echo ""
echo -e "${GREEN}✅ Safety nets deployed${NC}"
echo -e "${GREEN}✅ Recovery script ready${NC}"
echo -e "${GREEN}✅ All valuable data preserved${NC}"
echo ""
echo -e "${YELLOW}🔬 You may now proceed with gleeful destruction!${NC}"
echo ""
echo -e "${BLUE}Recovery Instructions:${NC}"
echo "   1. If chaos goes wrong: cd $CHAOS_BACKUP_DIR"
echo "   2. Run: ./RECOVER_FROM_CHAOS.sh"
echo "   3. Document what you learned!"
echo ""
echo -e "${RED}Remember: The goal is productive failure, not just failure.${NC}"
echo -e "${PURPLE}Happy experimenting! 🧪⚡${NC}"

# Git commit the backup
cd "$QRY_ROOT"
git add "backups/chaos/" 2>/dev/null || true
git commit -m "Pre-chaos backup: $EXPERIMENT_NAME

Comprehensive safety backup before junkyard engineer experiment:
- All QRY databases preserved
- Ecosystem packages backed up  
- Recovery script generated
- Backup size: $BACKUP_SIZE

Ready for gleeful destruction with systematic safety nets.
Experiment timestamp: $TIMESTAMP" 2>/dev/null || echo -e "${BLUE}ℹ️  Backup created but not committed to git${NC}"
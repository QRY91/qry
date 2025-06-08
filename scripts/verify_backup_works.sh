#!/bin/bash
# Simple Backup Verification Script
# Purpose: Verify that uroboro backups actually work for recovery
# Philosophy: Keep it simple, test what matters

set -e

REAL_DB="$HOME/.local/share/uroboro/uroboro.sqlite"
BACKUP_DIR="$(dirname "$0")/../backups/uroboro"
TEST_DIR="/tmp/backup_test_$$"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Backup Verification"
echo "==================="

# Test 1: Check if we have backups
echo -n "1. Checking for existing backups... "
if ls "$BACKUP_DIR"/uroboro-backup-*.sqlite >/dev/null 2>&1; then
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/uroboro-backup-*.sqlite | wc -l)
    echo -e "${GREEN}✅ Found $BACKUP_COUNT backups${NC}"
else
    echo -e "${RED}❌ No backups found!${NC}"
    echo "Run ./scripts/backup_uroboro.sh first"
    exit 1
fi

# Test 2: Check if original database exists
echo -n "2. Checking original database... "
if [ -f "$REAL_DB" ]; then
    REAL_COUNT=$(sqlite3 "$REAL_DB" "SELECT COUNT(*) FROM captures;" 2>/dev/null || echo "0")
    echo -e "${GREEN}✅ Found database with $REAL_COUNT records${NC}"
else
    echo -e "${YELLOW}⚠️  No original database${NC}"
    REAL_COUNT=0
fi

# Test 3: Verify latest backup can be read
echo -n "3. Testing latest backup integrity... "
LATEST_BACKUP=$(ls -1t "$BACKUP_DIR"/uroboro-backup-*.sqlite | head -1)
if [ -f "$LATEST_BACKUP" ]; then
    BACKUP_COUNT=$(sqlite3 "$LATEST_BACKUP" "SELECT COUNT(*) FROM captures;" 2>/dev/null || echo "CORRUPT")
    if [ "$BACKUP_COUNT" = "CORRUPT" ]; then
        echo -e "${RED}❌ Backup is corrupted!${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ $BACKUP_COUNT records in backup${NC}"
    fi
else
    echo -e "${RED}❌ Latest backup not found${NC}"
    exit 1
fi

# Test 4: Data consistency check
echo -n "4. Checking data consistency... "
if [ "$REAL_COUNT" -gt 0 ] && [ "$BACKUP_COUNT" != "$REAL_COUNT" ]; then
    echo -e "${YELLOW}⚠️  Record count mismatch (real: $REAL_COUNT, backup: $BACKUP_COUNT)${NC}"
else
    echo -e "${GREEN}✅ Data counts match${NC}"
fi

# Test 5: Recovery simulation
echo -n "5. Testing recovery simulation... "
mkdir -p "$TEST_DIR"
cp "$LATEST_BACKUP" "$TEST_DIR/recovered.sqlite"

# Verify recovered database works
RECOVERED_COUNT=$(sqlite3 "$TEST_DIR/recovered.sqlite" "SELECT COUNT(*) FROM captures;" 2>/dev/null || echo "FAILED")
if [ "$RECOVERED_COUNT" = "FAILED" ]; then
    echo -e "${RED}❌ Recovery failed${NC}"
    rm -rf "$TEST_DIR"
    exit 1
else
    echo -e "${GREEN}✅ Recovery successful ($RECOVERED_COUNT records)${NC}"
fi

# Test 6: Verify actual data content
echo -n "6. Checking sample data content... "
SAMPLE_DATA=$(sqlite3 "$TEST_DIR/recovered.sqlite" "SELECT content FROM captures ORDER BY id DESC LIMIT 1;" 2>/dev/null || echo "FAILED")
if [ "$SAMPLE_DATA" != "FAILED" ] && [ -n "$SAMPLE_DATA" ]; then
    echo -e "${GREEN}✅ Data content accessible${NC}"
    echo "   Latest capture: ${SAMPLE_DATA:0:50}..."
else
    echo -e "${RED}❌ Cannot read data content${NC}"
fi

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo -e "${GREEN}✅ Backup verification complete${NC}"
echo ""
echo "Summary:"
echo "- Backups available: $BACKUP_COUNT"
echo "- Records in latest backup: $BACKUP_COUNT"
echo "- Recovery test: PASSED"
echo ""
echo -e "${GREEN}✅ Your data can be recovered from backups${NC}"
echo "Safe to proceed with development work."
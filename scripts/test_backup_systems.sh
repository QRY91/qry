#!/bin/bash
# QRY Backup Systems Automated Testing Script
# 
# Purpose: Validate all backup and recovery systems work correctly
# Philosophy: "Untested parachute is a piece of fabric" - systematic safety validation
# Usage: ./scripts/test_backup_systems.sh [--verbose] [--report-only]
#
# This script embodies QRY safety principles:
# - Test all safety nets regularly
# - Validate recovery procedures under realistic conditions
# - Document failures for systematic improvement
# - Ensure junkyard engineer experiments have working parachutes

set -e  # Exit on error - safety testing must be bulletproof

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QRY_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
TEST_REPORT_DIR="$QRY_ROOT/backups/test_reports"
TEST_REPORT="$TEST_REPORT_DIR/safety_test_$TEST_TIMESTAMP.log"
VERBOSE=false
REPORT_ONLY=false

# Database paths
UROBORO_DB="$HOME/.local/share/uroboro/uroboro.sqlite"
WHEREWASI_DB="$HOME/.local/share/wherewasi/context.sqlite"
ECOSYSTEM_DB="$HOME/.local/share/qry/ecosystem.sqlite"

# Backup paths
DAILY_BACKUP_DIR="$QRY_ROOT/backups/uroboro"
CHAOS_BACKUP_DIR="$QRY_ROOT/backups/chaos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --report-only)
            REPORT_ONLY=true
            shift
            ;;
        *)
            echo "Usage: $0 [--verbose] [--report-only]"
            exit 1
            ;;
    esac
done

# Logging functions
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$TEST_REPORT"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        log "$1"
    else
        echo "[$timestamp] $1" >> "$TEST_REPORT"
    fi
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$TEST_REPORT"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$TEST_REPORT"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$TEST_REPORT"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$TEST_REPORT"
}

# Create test report directory
mkdir -p "$TEST_REPORT_DIR"

echo -e "${PURPLE}🧪 QRY BACKUP SYSTEMS SAFETY TEST${NC}"
echo "=================================================="
log "Starting QRY backup systems safety validation"
log "Test timestamp: $TEST_TIMESTAMP"
log "Verbose mode: $VERBOSE"
log "Report only mode: $REPORT_ONLY"
echo ""

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}🔬 Test $TOTAL_TESTS: $test_name${NC}"
    log "Running test: $test_name"
    
    if [ "$REPORT_ONLY" = true ]; then
        log_info "SKIPPED (report-only mode)"
        return 0
    fi
    
    if $test_function; then
        log_success "PASSED: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "FAILED: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test 1: Daily Backup System Health
test_daily_backup_system() {
    log_verbose "Testing daily backup system health..."
    
    # Check if backup directory exists
    if [ ! -d "$DAILY_BACKUP_DIR" ]; then
        log_error "Daily backup directory not found: $DAILY_BACKUP_DIR"
        return 1
    fi
    
    # Check for recent backups
    RECENT_BACKUPS=$(find "$DAILY_BACKUP_DIR" -name "uroboro-backup-*.sqlite" -mtime -2 | wc -l)
    if [ "$RECENT_BACKUPS" -eq 0 ]; then
        log_warning "No recent daily backups found (last 48 hours)"
        WARNING_TESTS=$((WARNING_TESTS + 1))
    fi
    
    # Test backup script exists and is executable
    if [ ! -x "$QRY_ROOT/scripts/backup_uroboro.sh" ]; then
        log_error "Daily backup script not found or not executable"
        return 1
    fi
    
    # Test backup creation (if uroboro database exists)
    if [ -f "$UROBORO_DB" ]; then
        log_verbose "Testing backup creation..."
        if ! "$QRY_ROOT/scripts/backup_uroboro.sh" >/dev/null 2>&1; then
            log_error "Failed to create backup with backup script"
            return 1
        fi
        
        # Verify backup was created
        LATEST_BACKUP=$(ls -t "$DAILY_BACKUP_DIR"/uroboro-backup-*.sqlite | head -1 2>/dev/null)
        if [ -z "$LATEST_BACKUP" ]; then
            log_error "No backup file found after running backup script"
            return 1
        fi
        
        # Test backup integrity
        if ! sqlite3 "$LATEST_BACKUP" "PRAGMA integrity_check;" >/dev/null 2>&1; then
            log_error "Backup file failed integrity check: $LATEST_BACKUP"
            return 1
        fi
        
        log_verbose "Backup integrity verified: $LATEST_BACKUP"
    else
        log_warning "Uroboro database not found - skipping backup creation test"
        WARNING_TESTS=$((WARNING_TESTS + 1))
    fi
    
    return 0
}

# Test 2: Chaos Backup System
test_chaos_backup_system() {
    log_verbose "Testing chaos backup system..."
    
    # Check if chaos backup script exists
    if [ ! -x "$QRY_ROOT/scripts/backup_before_chaos.sh" ]; then
        log_error "Chaos backup script not found or not executable"
        return 1
    fi
    
    # Create test chaos backup
    TEST_EXPERIMENT="safety-test-$TEST_TIMESTAMP"
    log_verbose "Creating test chaos backup: $TEST_EXPERIMENT"
    
    if ! "$QRY_ROOT/scripts/backup_before_chaos.sh" "$TEST_EXPERIMENT" --force >/dev/null 2>&1; then
        log_error "Failed to create chaos backup"
        return 1
    fi
    
    # Find the created backup directory
    CHAOS_TEST_DIR=$(ls -td "$CHAOS_BACKUP_DIR/$TEST_EXPERIMENT"* | head -1 2>/dev/null)
    if [ -z "$CHAOS_TEST_DIR" ]; then
        log_error "Chaos backup directory not found after creation"
        return 1
    fi
    
    log_verbose "Chaos backup created: $CHAOS_TEST_DIR"
    
    # Verify recovery script exists and is executable
    if [ ! -x "$CHAOS_TEST_DIR/RECOVER_FROM_CHAOS.sh" ]; then
        log_error "Recovery script not found or not executable in chaos backup"
        return 1
    fi
    
    # Verify critical files were backed up
    MISSING_FILES=()
    
    if [ -f "$UROBORO_DB" ] && [ ! -f "$CHAOS_TEST_DIR/uroboro-pre-chaos.sqlite" ]; then
        MISSING_FILES+=("uroboro database")
    fi
    
    if [ -f "$WHEREWASI_DB" ] && [ ! -f "$CHAOS_TEST_DIR/wherewasi-pre-chaos.sqlite" ]; then
        MISSING_FILES+=("wherewasi database")
    fi
    
    if [ ! -f "$CHAOS_TEST_DIR/backup_manifest.txt" ]; then
        MISSING_FILES+=("backup manifest")
    fi
    
    if [ ${#MISSING_FILES[@]} -gt 0 ]; then
        log_error "Missing files in chaos backup: ${MISSING_FILES[*]}"
        return 1
    fi
    
    # Test backup file integrity
    for db_backup in "$CHAOS_TEST_DIR"/*.sqlite; do
        if [ -f "$db_backup" ]; then
            if ! sqlite3 "$db_backup" "PRAGMA integrity_check;" >/dev/null 2>&1; then
                log_error "Chaos backup file failed integrity check: $db_backup"
                return 1
            fi
        fi
    done
    
    log_verbose "All chaos backup files passed integrity checks"
    return 0
}

# Test 3: Recovery Procedures
test_recovery_procedures() {
    log_verbose "Testing recovery procedures..."
    
    # Find most recent chaos backup for testing
    LATEST_CHAOS=$(ls -td "$CHAOS_BACKUP_DIR"/*/ | head -1 2>/dev/null)
    if [ -z "$LATEST_CHAOS" ]; then
        log_warning "No chaos backups found for recovery testing"
        WARNING_TESTS=$((WARNING_TESTS + 1))
        return 0
    fi
    
    # Check recovery script
    if [ ! -x "$LATEST_CHAOS/RECOVER_FROM_CHAOS.sh" ]; then
        log_error "Recovery script not executable: $LATEST_CHAOS/RECOVER_FROM_CHAOS.sh"
        return 1
    fi
    
    # Test that recovery script contains proper restoration logic
    if ! grep -q "uroboro-pre-chaos.sqlite" "$LATEST_CHAOS/RECOVER_FROM_CHAOS.sh"; then
        log_error "Recovery script missing uroboro restoration logic"
        return 1
    fi
    
    # Verify recovery script has safety confirmation
    if ! grep -q "Are you sure" "$LATEST_CHAOS/RECOVER_FROM_CHAOS.sh"; then
        log_error "Recovery script missing safety confirmation"
        return 1
    fi
    
    log_verbose "Recovery script structure validated"
    return 0
}

# Test 4: Database Integrity Monitoring
test_database_integrity() {
    log_verbose "Testing database integrity monitoring..."
    
    # Test each database that exists
    DATABASES=()
    [ -f "$UROBORO_DB" ] && DATABASES+=("$UROBORO_DB:uroboro")
    [ -f "$WHEREWASI_DB" ] && DATABASES+=("$WHEREWASI_DB:wherewasi") 
    [ -f "$ECOSYSTEM_DB" ] && DATABASES+=("$ECOSYSTEM_DB:ecosystem")
    
    if [ ${#DATABASES[@]} -eq 0 ]; then
        log_warning "No QRY databases found for integrity testing"
        WARNING_TESTS=$((WARNING_TESTS + 1))
        return 0
    fi
    
    for db_info in "${DATABASES[@]}"; do
        IFS=":" read -r db_path db_name <<< "$db_info"
        
        log_verbose "Testing integrity of $db_name database..."
        
        # Test basic connectivity
        if ! sqlite3 "$db_path" "SELECT 1;" >/dev/null 2>&1; then
            log_error "Cannot connect to $db_name database: $db_path"
            return 1
        fi
        
        # Test integrity check
        INTEGRITY_RESULT=$(sqlite3 "$db_path" "PRAGMA integrity_check;" 2>/dev/null)
        if [ "$INTEGRITY_RESULT" != "ok" ]; then
            log_error "$db_name database failed integrity check: $INTEGRITY_RESULT"
            return 1
        fi
        
        # Test for reasonable data (if expected tables exist)
        case $db_name in
            "uroboro")
                if sqlite3 "$db_path" "SELECT name FROM sqlite_master WHERE type='table' AND name='captures';" 2>/dev/null | grep -q captures; then
                    CAPTURE_COUNT=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM captures;" 2>/dev/null)
                    log_verbose "$db_name database: $CAPTURE_COUNT captures"
                fi
                ;;
            "wherewasi")
                if sqlite3 "$db_path" "SELECT name FROM sqlite_master WHERE type='table' AND name='context_sessions';" 2>/dev/null | grep -q context_sessions; then
                    CONTEXT_COUNT=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM context_sessions;" 2>/dev/null)
                    log_verbose "$db_name database: $CONTEXT_COUNT context sessions"
                fi
                ;;
        esac
    done
    
    return 0
}

# Test 5: Cron Job Validation
test_cron_automation() {
    log_verbose "Testing cron job automation..."
    
    # Check if uroboro backup cron job is installed
    if ! crontab -l 2>/dev/null | grep -q "backup_uroboro.sh"; then
        log_warning "Daily backup cron job not found in crontab"
        WARNING_TESTS=$((WARNING_TESTS + 1))
        return 0
    fi
    
    # Verify cron job points to correct script
    CRON_SCRIPT_PATH=$(crontab -l 2>/dev/null | grep "backup_uroboro.sh" | awk '{print $6}')
    if [ ! -x "$CRON_SCRIPT_PATH" ]; then
        log_error "Cron job points to non-executable script: $CRON_SCRIPT_PATH"
        return 1
    fi
    
    log_verbose "Cron job automation validated"
    return 0
}

# Test 6: Storage Space Monitoring
test_storage_capacity() {
    log_verbose "Testing storage capacity for backups..."
    
    # Check available space in backup directory
    BACKUP_SPACE=$(df "$QRY_ROOT/backups" | tail -1 | awk '{print $4}')
    BACKUP_SPACE_GB=$((BACKUP_SPACE / 1024 / 1024))
    
    if [ "$BACKUP_SPACE_GB" -lt 1 ]; then
        log_warning "Low storage space for backups: ${BACKUP_SPACE_GB}GB available"
        WARNING_TESTS=$((WARNING_TESTS + 1))
    fi
    
    # Check total backup directory size
    TOTAL_BACKUP_SIZE=$(du -sh "$QRY_ROOT/backups" 2>/dev/null | cut -f1)
    log_verbose "Total backup storage used: $TOTAL_BACKUP_SIZE"
    
    # Count old backups that could be cleaned up
    OLD_BACKUPS=$(find "$DAILY_BACKUP_DIR" -name "*.sqlite" -mtime +30 2>/dev/null | wc -l)
    if [ "$OLD_BACKUPS" -gt 10 ]; then
        log_warning "$OLD_BACKUPS old daily backups found (>30 days) - consider cleanup"
        WARNING_TESTS=$((WARNING_TESTS + 1))
    fi
    
    return 0
}

# Test 7: Git Integration
test_git_integration() {
    log_verbose "Testing git integration for backups..."
    
    cd "$QRY_ROOT"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_warning "QRY directory is not a git repository - backup commits disabled"
        WARNING_TESTS=$((WARNING_TESTS + 1))
        return 0
    fi
    
    # Check for recent backup commits
    BACKUP_COMMITS=$(git log --oneline --since="7 days ago" --grep="backup" | wc -l)
    if [ "$BACKUP_COMMITS" -eq 0 ]; then
        log_warning "No backup-related git commits found in last 7 days"
        WARNING_TESTS=$((WARNING_TESTS + 1))
    fi
    
    # Test that backup directory is tracked by git
    if ! git ls-files --error-unmatch "backups/" >/dev/null 2>&1; then
        log_warning "Backup directory not tracked by git"
        WARNING_TESTS=$((WARNING_TESTS + 1))
    fi
    
    return 0
}

# Run all tests
echo -e "${BLUE}🔬 Running comprehensive backup system tests...${NC}"
echo ""

run_test "Daily Backup System Health" test_daily_backup_system
run_test "Chaos Backup System" test_chaos_backup_system  
run_test "Recovery Procedures" test_recovery_procedures
run_test "Database Integrity Monitoring" test_database_integrity
run_test "Cron Job Automation" test_cron_automation
run_test "Storage Capacity" test_storage_capacity
run_test "Git Integration" test_git_integration

# Generate test summary
echo ""
echo -e "${PURPLE}📊 TEST SUMMARY${NC}"
echo "================="
log "Test Summary:"
log "Total tests: $TOTAL_TESTS"
log "Passed: $PASSED_TESTS"
log "Failed: $FAILED_TESTS" 
log "Warnings: $WARNING_TESTS"

if [ "$FAILED_TESTS" -eq 0 ]; then
    log_success "ALL SAFETY TESTS PASSED!"
    echo ""
    echo -e "${GREEN}🎉 Your backup parachutes are ready for junkyard engineer mode!${NC}"
    EXIT_CODE=0
else
    log_error "$FAILED_TESTS CRITICAL SAFETY FAILURES DETECTED"
    echo ""
    echo -e "${RED}🚨 SAFETY SYSTEMS COMPROMISED - DO NOT PROCEED WITH RISKY EXPERIMENTS${NC}"
    echo -e "${RED}Fix failed tests before continuing development work${NC}"
    EXIT_CODE=1
fi

if [ "$WARNING_TESTS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNING_TESTS warnings detected - consider addressing for optimal safety${NC}"
fi

echo ""
echo -e "${BLUE}📄 Full test report: $TEST_REPORT${NC}"

# Create summary status file
SUMMARY_FILE="$TEST_REPORT_DIR/latest_test_summary.txt"
cat > "$SUMMARY_FILE" << EOF
QRY Backup Systems Safety Test Summary
======================================
Test Date: $(date)
Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Warnings: $WARNING_TESTS
Status: $([ "$FAILED_TESTS" -eq 0 ] && echo "SAFE" || echo "UNSAFE")

Full Report: $TEST_REPORT
EOF

echo -e "${BLUE}📋 Latest summary: $SUMMARY_FILE${NC}"
echo ""

# Final safety reminder
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}🔒 Safety nets validated. Happy experimenting!${NC}"
    echo -e "${BLUE}Remember: Test your parachutes regularly, not just before you jump.${NC}"
else
    echo -e "${RED}🔒 Safety nets compromised. Fix issues before proceeding.${NC}"
    echo -e "${RED}Remember: No junkyard engineering without working safety systems.${NC}"
fi

exit $EXIT_CODE
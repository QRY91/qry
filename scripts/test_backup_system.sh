#!/bin/bash
# QRY Backup System Comprehensive Testing Framework
#
# Purpose: Test backup and restoration to ensure we can actually recover from death
# Philosophy: "It's not a backup system if it can't bring you back from death"
# Usage: ./scripts/test_backup_system.sh [--destructive] [--verbose]
#
# This script embodies QRY anti-fragile principles:
# - Test every failure mode we can think of
# - Verify restoration actually works
# - Document what breaks and how to fix it
# - Build confidence through systematic validation

set -e

# Configuration
TEST_DIR="/tmp/qry_backup_test_$$"
BACKUP_SCRIPT="$(dirname "$0")/backup_uroboro.sh"
REAL_UROBORO_DIR="$HOME/.local/share/uroboro"
TEST_UROBORO_DIR="$TEST_DIR/fake_uroboro"
VERBOSE=false
DESTRUCTIVE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${PURPLE}🔍 $1${NC}"
    fi
}

# Test framework functions
start_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_info "Test $TESTS_RUN: $1"
}

pass_test() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_success "PASS: $1"
}

fail_test() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$1")
    log_error "FAIL: $1"
}

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --destructive)
            DESTRUCTIVE=true
            log_warning "DESTRUCTIVE MODE ENABLED - will test with real database"
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --help)
            echo "QRY Backup System Testing Framework"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --destructive  Test with real uroboro database (DANGER)"
            echo "  --verbose      Show detailed test output"
            echo "  --help         Show this help message"
            echo ""
            echo "Safe mode (default) creates fake test data"
            echo "Destructive mode tests with your actual uroboro database"
            exit 0
            ;;
    esac
done

# Setup test environment
setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    mkdir -p "$TEST_UROBORO_DIR"
    
    # Create fake uroboro database with test data
    create_fake_uroboro_database
    
    log_verbose "Test environment created at $TEST_DIR"
}

create_fake_uroboro_database() {
    local db_file="$TEST_UROBORO_DIR/uroboro.sqlite"
    
    log_verbose "Creating fake uroboro database with test data..."
    
    # Create database with same schema as real uroboro
    sqlite3 "$db_file" << 'EOF'
CREATE TABLE IF NOT EXISTS captures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    description TEXT NOT NULL,
    project TEXT,
    tags TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO captures (timestamp, description, project, tags) VALUES
    ('2025-06-08T10:00:00', 'Test capture 1 - backup system development', 'backup-system', 'testing,backup,critical'),
    ('2025-06-08T10:01:00', 'Test capture 2 - anti-fragile system design', 'backup-system', 'anti-fragile,testing'),
    ('2025-06-08T10:02:00', 'Test capture 3 - death recovery validation', 'backup-system', 'death-test,recovery'),
    ('2025-06-08T10:03:00', 'Test capture 4 - systematic methodology', 'qry-core', 'methodology,systematic'),
    ('2025-06-08T10:04:00', 'Test capture 5 - junkyard engineer principles', 'qry-core', 'junkyard-engineer,chaos');
EOF
    
    # Verify test data
    local count=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM captures;")
    if [ "$count" = "5" ]; then
        log_verbose "Created fake database with $count test records"
    else
        log_error "Failed to create test database properly"
        exit 1
    fi
}

# Backup system tests
test_backup_script_exists() {
    start_test "Backup script exists and is executable"
    
    if [ -f "$BACKUP_SCRIPT" ] && [ -x "$BACKUP_SCRIPT" ]; then
        pass_test "Backup script found and executable"
    else
        fail_test "Backup script missing or not executable: $BACKUP_SCRIPT"
    fi
}

test_backup_creation() {
    start_test "Backup creation with test database"
    
    # Temporarily replace real uroboro location for test
    export HOME="$TEST_DIR"
    mkdir -p "$TEST_DIR/.local/share/uroboro"
    cp "$TEST_UROBORO_DIR/uroboro.sqlite" "$TEST_DIR/.local/share/uroboro/"
    
    # Create backup directory in test environment
    local test_backup_dir="$TEST_DIR/backups/uroboro"
    mkdir -p "$test_backup_dir"
    
    # Modify backup script temporarily (create a test version)
    local test_backup_script="$TEST_DIR/test_backup.sh"
    sed "s|\\$HOME/.local/share/uroboro/uroboro.sqlite|$TEST_DIR/.local/share/uroboro/uroboro.sqlite|g" "$BACKUP_SCRIPT" > "$test_backup_script"
    sed -i "s|\\$(dirname \"\\$0\")/../backups/uroboro|$test_backup_dir|g" "$test_backup_script"
    chmod +x "$test_backup_script"
    
    # Run backup
    if "$test_backup_script" >/dev/null 2>&1; then
        # Check if backup was created
        local backup_count=$(ls -1 "$test_backup_dir"/uroboro-backup-*.sqlite 2>/dev/null | wc -l)
        if [ "$backup_count" -gt 0 ]; then
            pass_test "Backup created successfully"
        else
            fail_test "Backup script ran but no backup file created"
        fi
    else
        fail_test "Backup script execution failed"
    fi
    
    # Restore HOME
    unset HOME
    export HOME="$(eval echo ~$(whoami))"
}

test_backup_integrity() {
    start_test "Backup data integrity verification"
    
    local original_db="$TEST_UROBORO_DIR/uroboro.sqlite"
    local backup_db=$(ls -1t "$TEST_DIR/backups/uroboro"/uroboro-backup-*.sqlite 2>/dev/null | head -1)
    
    if [ -z "$backup_db" ]; then
        fail_test "No backup file found for integrity check"
        return
    fi
    
    # Compare record counts
    local original_count=$(sqlite3 "$original_db" "SELECT COUNT(*) FROM captures;" 2>/dev/null)
    local backup_count=$(sqlite3 "$backup_db" "SELECT COUNT(*) FROM captures;" 2>/dev/null)
    
    if [ "$original_count" = "$backup_count" ] && [ "$original_count" = "5" ]; then
        pass_test "Backup data integrity verified ($backup_count records)"
    else
        fail_test "Data integrity check failed: original=$original_count, backup=$backup_count"
    fi
}

test_backup_restoration() {
    start_test "Database restoration from backup"
    
    local backup_db=$(ls -1t "$TEST_DIR/backups/uroboro"/uroboro-backup-*.sqlite 2>/dev/null | head -1)
    local restore_target="$TEST_DIR/restored_uroboro.sqlite"
    
    if [ -z "$backup_db" ]; then
        fail_test "No backup file found for restoration test"
        return
    fi
    
    # Copy backup to restoration target
    cp "$backup_db" "$restore_target"
    
    # Verify restored database
    local restored_count=$(sqlite3 "$restore_target" "SELECT COUNT(*) FROM captures;" 2>/dev/null)
    local sample_record=$(sqlite3 "$restore_target" "SELECT description FROM captures LIMIT 1;" 2>/dev/null)
    
    if [ "$restored_count" = "5" ] && [[ "$sample_record" =~ "Test capture" ]]; then
        pass_test "Database restoration successful"
    else
        fail_test "Database restoration failed or data corrupted"
    fi
}

test_corruption_recovery() {
    start_test "Recovery from corrupted database"
    
    local corrupted_db="$TEST_DIR/corrupted_uroboro.sqlite"
    local backup_db=$(ls -1t "$TEST_DIR/backups/uroboro"/uroboro-backup-*.sqlite 2>/dev/null | head -1)
    
    if [ -z "$backup_db" ]; then
        fail_test "No backup file found for corruption recovery test"
        return
    fi
    
    # Create corrupted database (truncate it)
    echo "CORRUPTED" > "$corrupted_db"
    
    # Attempt to read corrupted database (should fail)
    if sqlite3 "$corrupted_db" "SELECT COUNT(*) FROM captures;" >/dev/null 2>&1; then
        fail_test "Corrupted database test setup failed - database still readable"
        return
    fi
    
    # Restore from backup
    cp "$backup_db" "$corrupted_db"
    
    # Verify recovery
    local recovered_count=$(sqlite3 "$corrupted_db" "SELECT COUNT(*) FROM captures;" 2>/dev/null)
    if [ "$recovered_count" = "5" ]; then
        pass_test "Recovery from corruption successful"
    else
        fail_test "Recovery from corruption failed"
    fi
}

test_backup_rotation() {
    start_test "Backup rotation system"
    
    local test_backup_dir="$TEST_DIR/backups/uroboro"
    
    # Create multiple fake backups to test rotation
    for i in {1..12}; do
        local fake_backup="$test_backup_dir/uroboro-backup-2025-06-0$((i % 10))-$(printf "%04d" $i).sqlite"
        cp "$TEST_UROBORO_DIR/uroboro.sqlite" "$fake_backup"
        # Make files have different timestamps
        touch -t "2025060$((i % 10))$(printf "%02d" $i)00" "$fake_backup"
    done
    
    # Check how many backups we have (should be more than 10)
    local backup_count_before=$(ls -1 "$test_backup_dir"/uroboro-backup-*.sqlite 2>/dev/null | wc -l)
    
    # Run backup script (which should trigger rotation)
    local test_backup_script="$TEST_DIR/test_backup.sh"
    if [ -f "$test_backup_script" ]; then
        "$test_backup_script" >/dev/null 2>&1
    fi
    
    # Check backup count after rotation
    local backup_count_after=$(ls -1 "$test_backup_dir"/uroboro-backup-*.sqlite 2>/dev/null | wc -l)
    
    if [ "$backup_count_before" -gt 10 ] && [ "$backup_count_after" -le 10 ]; then
        pass_test "Backup rotation working (reduced from $backup_count_before to $backup_count_after)"
    else
        fail_test "Backup rotation failed (before: $backup_count_before, after: $backup_count_after)"
    fi
}

test_destructive_real_database() {
    if [ "$DESTRUCTIVE" != true ]; then
        log_warning "Skipping destructive tests (use --destructive to enable)"
        return
    fi
    
    start_test "DESTRUCTIVE: Real database backup and restoration"
    log_warning "Testing with REAL uroboro database - this could be dangerous!"
    
    # Create a safety backup first
    local safety_backup="$TEST_DIR/safety_backup.sqlite"
    if [ -f "$REAL_UROBORO_DIR/uroboro.sqlite" ]; then
        cp "$REAL_UROBORO_DIR/uroboro.sqlite" "$safety_backup"
        log_verbose "Safety backup created at $safety_backup"
    else
        fail_test "Real uroboro database not found"
        return
    fi
    
    # Test real backup creation
    if "$BACKUP_SCRIPT" >/dev/null 2>&1; then
        pass_test "Real database backup successful"
    else
        fail_test "Real database backup failed"
    fi
    
    # Restore safety backup
    cp "$safety_backup" "$REAL_UROBORO_DIR/uroboro.sqlite"
    log_verbose "Safety backup restored"
}

# Edge case tests
test_missing_database() {
    start_test "Handling missing database file"
    
    local test_backup_script="$TEST_DIR/test_backup_missing.sh"
    local fake_missing_db="$TEST_DIR/missing/uroboro.sqlite"
    
    # Create backup script that points to non-existent database
    sed "s|\\$HOME/.local/share/uroboro/uroboro.sqlite|$fake_missing_db|g" "$BACKUP_SCRIPT" > "$test_backup_script"
    chmod +x "$test_backup_script"
    
    # Should fail gracefully
    if "$test_backup_script" >/dev/null 2>&1; then
        fail_test "Backup script should fail with missing database"
    else
        pass_test "Backup script correctly handles missing database"
    fi
}

test_insufficient_permissions() {
    start_test "Handling insufficient permissions"
    
    local readonly_dir="$TEST_DIR/readonly"
    mkdir -p "$readonly_dir"
    chmod 444 "$readonly_dir"
    
    local test_backup_script="$TEST_DIR/test_backup_readonly.sh"
    sed "s|\\$(dirname \"\\$0\")/../backups/uroboro|$readonly_dir|g" "$BACKUP_SCRIPT" > "$test_backup_script"
    sed -i "s|\\$HOME/.local/share/uroboro/uroboro.sqlite|$TEST_UROBORO_DIR/uroboro.sqlite|g" "$test_backup_script"
    chmod +x "$test_backup_script"
    
    if "$test_backup_script" >/dev/null 2>&1; then
        fail_test "Backup script should fail with insufficient permissions"
    else
        pass_test "Backup script correctly handles permission errors"
    fi
    
    chmod 755 "$readonly_dir"  # Cleanup
}

# Cleanup function
cleanup_test_environment() {
    log_info "Cleaning up test environment..."
    
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        log_verbose "Test directory removed: $TEST_DIR"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🧪 QRY Backup System Death Test${NC}"
    echo "=================================="
    echo "Testing backup and restoration to ensure we can recover from death"
    echo ""
    
    # Setup
    setup_test_environment
    
    # Core functionality tests
    test_backup_script_exists
    test_backup_creation
    test_backup_integrity
    test_backup_restoration
    test_corruption_recovery
    test_backup_rotation
    
    # Edge case tests
    test_missing_database
    test_insufficient_permissions
    
    # Destructive tests (if enabled)
    test_destructive_real_database
    
    # Results summary
    echo ""
    echo -e "${BLUE}🧪 Test Results Summary${NC}"
    echo "======================="
    echo -e "Tests run: ${BLUE}$TESTS_RUN${NC}"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo ""
        echo -e "${RED}❌ Failed Tests:${NC}"
        for failed_test in "${FAILED_TESTS[@]}"; do
            echo "  - $failed_test"
        done
        echo ""
        echo -e "${RED}🚨 BACKUP SYSTEM NOT RELIABLE${NC}"
        echo "Fix failed tests before trusting this backup system with your life!"
    else
        echo ""
        echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
        echo "Backup system is robust and ready for production chaos experiments!"
        echo ""
        echo -e "${GREEN}✅ DEATH RECOVERY VERIFIED${NC}"
        echo "Your methodology insights are safe from junkyard engineer experiments!"
    fi
    
    # Cleanup
    cleanup_test_environment
    
    # Exit with appropriate code
    if [ "$TESTS_FAILED" -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Trap for cleanup on interruption
trap cleanup_test_environment EXIT

# Run main function
main "$@"
# QRY Safety and Backup Procedures

**Essential AI Collaboration Safety Protocols**

*"Untested parachute is a piece of fabric" - All safety nets must be validated*

---

## 🎯 **Purpose**

This document establishes safety protocols for AI collaboration within the QRY ecosystem, ensuring data protection during junkyard engineer experiments and systematic development work.

**Core Principle**: Systematic chaos requires systematic safety. Every AI assistant working on QRY projects MUST understand and follow these procedures.

---

## 🔒 **Safety Architecture Overview**

### **Three-Layer Protection System**

1. **Daily Automated Backups** - Continuous protection (9am cron job)
2. **Pre-Experiment Chaos Backups** - Before risky operations
3. **Real-Time Safety Monitoring** - During AI collaboration sessions

### **Critical Data Locations**
```
~/.local/share/uroboro/uroboro.sqlite     # 110+ methodology captures
~/.local/share/wherewasi/context.sqlite   # Development context sessions  
~/.local/share/qry/ecosystem.sqlite       # Cross-tool intelligence
/qry/ai/                                  # AI collaboration infrastructure
/qry/backups/                             # All backup storage
```

---

## 🤖 **AI Assistant Safety Responsibilities**

### **BEFORE Any Risky Operation**

**MANDATORY SAFETY CHECK**:
```bash
# Check backup status
ls -la /qry/backups/uroboro/ | tail -3
sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;"

# If no recent backup (>24 hours), STOP and backup first:
/qry/scripts/backup_uroboro.sh --auto-commit
```

### **Operations Requiring Pre-Chaos Backup**
- Database schema changes
- Ecosystem integration modifications  
- Tool installation/uninstallation
- Configuration changes affecting data storage
- Experimental feature development
- Migration between database systems

**Required Command**:
```bash
/qry/scripts/backup_before_chaos.sh [experiment-description] --force
```

### **NEVER Do These Without Backup**
- ❌ Modify database schemas directly
- ❌ Run `rm` commands on database files
- ❌ Change ecosystem database configurations
- ❌ Test migration scripts on production data
- ❌ Experiment with new database drivers
- ❌ Run SQL commands that modify structure

---

## 📋 **Backup System Validation Protocol**

### **Daily Backup Health Check**

**Test Frequency**: Every AI collaboration session

```bash
# 1. Verify automated backup exists
LATEST_BACKUP=$(ls -t /qry/backups/uroboro/ | head -1)
echo "Latest backup: $LATEST_BACKUP"

# 2. Check backup age (should be <24 hours)
find /qry/backups/uroboro/ -name "*.sqlite" -mtime -1 | wc -l

# 3. Verify backup integrity
sqlite3 "/qry/backups/uroboro/$LATEST_BACKUP" "SELECT COUNT(*) FROM captures;"

# 4. Compare with live database
LIVE_COUNT=$(sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;")
echo "Live database: $LIVE_COUNT captures"
```

**Expected Results**:
- ✅ Backup file exists from last 24 hours
- ✅ Backup opens without corruption
- ✅ Record count matches or is close to live database

### **Chaos Backup Testing**

**Test Frequency**: Weekly during development, before major experiments

```bash
# 1. Create test chaos backup
/qry/scripts/backup_before_chaos.sh backup-test --force

# 2. Verify comprehensive backup created
CHAOS_DIR=$(ls -td /qry/backups/chaos/backup-test-* | head -1)
echo "Chaos backup: $CHAOS_DIR"

# 3. Test recovery script exists and is executable
test -x "$CHAOS_DIR/RECOVER_FROM_CHAOS.sh" && echo "✅ Recovery script ready"

# 4. Verify all critical data backed up
test -f "$CHAOS_DIR/uroboro-pre-chaos.sqlite" && echo "✅ Uroboro database backed up"
test -f "$CHAOS_DIR/wherewasi-pre-chaos.sqlite" && echo "✅ Wherewasi database backed up"
test -d "$CHAOS_DIR/ai/" && echo "✅ AI infrastructure backed up"
```

---

## 🚨 **Emergency Recovery Procedures**

### **Data Loss Detection**

**Immediate Actions When Data Loss Suspected**:

1. **STOP ALL OPERATIONS** - Don't make the problem worse
2. **Assess damage scope**:
   ```bash
   # Check database existence and health
   ls -la ~/.local/share/uroboro/uroboro.sqlite
   sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;" || echo "DATABASE CORRUPTED"
   ```

3. **Identify most recent backup**:
   ```bash
   # Daily backups
   ls -lt /qry/backups/uroboro/ | head -5
   
   # Chaos backups
   ls -ltd /qry/backups/chaos/*/ | head -3
   ```

### **Recovery Options (In Order of Preference)**

#### **Option 1: Daily Backup Recovery**
```bash
# Find latest good backup
LATEST_BACKUP=$(ls -t /qry/backups/uroboro/uroboro-backup-*.sqlite | head -1)

# Verify backup integrity
sqlite3 "$LATEST_BACKUP" "SELECT COUNT(*) FROM captures;"

# Restore (BACKUP CURRENT STATE FIRST)
cp ~/.local/share/uroboro/uroboro.sqlite ~/.local/share/uroboro/uroboro.sqlite.corrupted.backup
cp "$LATEST_BACKUP" ~/.local/share/uroboro/uroboro.sqlite

# Verify restoration
sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;"
```

#### **Option 2: Chaos Backup Recovery**
```bash
# Navigate to most recent chaos backup
cd $(ls -td /qry/backups/chaos/*/ | head -1)

# Run automated recovery
./RECOVER_FROM_CHAOS.sh

# Verify recovery
sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;"
```

#### **Option 3: Git History Recovery**
```bash
# Check git history for backup commits
cd /qry
git log --oneline --grep="backup" | head -10

# Restore from git if backups committed
git show [commit-hash]:backups/uroboro/[backup-file] > recovery.sqlite
```

---

## 🧪 **Testing Safety Nets**

### **Monthly Safety Net Validation**

**Purpose**: Ensure all backup systems work under realistic failure conditions

#### **Test 1: Automated Backup Functionality**
```bash
# Force a backup outside normal schedule
/qry/scripts/backup_uroboro.sh --auto-commit

# Verify git commit created
git log --oneline -1 | grep -i backup

# Test backup integrity
LATEST_BACKUP=$(ls -t /qry/backups/uroboro/ | head -1)
sqlite3 "/qry/backups/uroboro/$LATEST_BACKUP" "PRAGMA integrity_check;"
```

#### **Test 2: Chaos Backup and Recovery**
```bash
# Create test database copy
cp ~/.local/share/uroboro/uroboro.sqlite ~/.local/share/uroboro/uroboro.sqlite.test.backup

# Run chaos backup
/qry/scripts/backup_before_chaos.sh recovery-test --force

# Simulate corruption (controlled damage)
echo "CORRUPTED" > ~/.local/share/uroboro/uroboro.sqlite

# Test recovery process
CHAOS_DIR=$(ls -td /qry/backups/chaos/recovery-test-* | head -1)
cd "$CHAOS_DIR"
echo "y" | ./RECOVER_FROM_CHAOS.sh

# Verify recovery worked
sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;"

# Restore test backup to original
cp ~/.local/share/uroboro/uroboro.sqlite.test.backup ~/.local/share/uroboro/uroboro.sqlite
rm ~/.local/share/uroboro/uroboro.sqlite.test.backup
```

#### **Test 3: Cross-Database Recovery**
```bash
# Test ecosystem database recovery
/qry/scripts/backup_before_chaos.sh ecosystem-recovery-test --force
CHAOS_DIR=$(ls -td /qry/backups/chaos/ecosystem-recovery-test-* | head -1)

# Verify all databases included
ls -la "$CHAOS_DIR"/*.sqlite
```

### **Automated Testing Integration**

**Cron Job for Weekly Safety Testing**:
```bash
# Add to crontab (Sundays at 8am):
0 8 * * 0 /qry/scripts/test_backup_systems.sh >/dev/null 2>&1
```

---

## 📝 **AI Collaboration Safety Checklist**

### **Session Startup Safety Check**
- [ ] Verify recent backup exists (<24 hours)
- [ ] Check database integrity: `sqlite3 [db] "PRAGMA integrity_check;"`
- [ ] Confirm disk space available for new backups
- [ ] Identify planned operations and risk level

### **Before Risky Operations**
- [ ] Create pre-experiment chaos backup
- [ ] Document experiment purpose and scope
- [ ] Verify recovery procedures are accessible
- [ ] Confirm git working directory is clean

### **During Development**
- [ ] Monitor database file sizes for corruption
- [ ] Create intermediate saves for long experiments
- [ ] Test changes on backup copies first
- [ ] Document unexpected behaviors immediately

### **Session Cleanup**
- [ ] Verify no database corruption occurred
- [ ] Create manual backup if significant work done
- [ ] Update backup manifest if new critical files created
- [ ] Test key functionality still works

---

## 🔧 **Integration with AI Collaboration Workflow**

### **Morning Lab Startup Integration**

Add to `MORNING_LAB_STARTUP.md` checklist:
```markdown
### **Safety Net Verification**
- [ ] Check backup status: `ls -la /qry/backups/uroboro/ | tail -1`
- [ ] Verify database health: `sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;"`
- [ ] Confirm recovery procedures accessible
```

### **Pre-Experiment Protocol**

Before any ecosystem modifications:
```bash
# 1. Safety backup
qry-chaos [experiment-name] --force

# 2. Document experiment scope
echo "Experiment: [name]
Purpose: [description]  
Risk Level: [low/medium/high]
Expected Changes: [list]
Rollback Plan: [recovery steps]" > experiment-log.md

# 3. Proceed with experiment
```

### **Post-Experiment Validation**

```bash
# 1. Verify system health
sqlite3 ~/.local/share/uroboro/uroboro.sqlite "PRAGMA integrity_check;"

# 2. Test core functionality
uroboro status
wherewasi pull --save=false --clipboard=false > /dev/null

# 3. Document results
uroboro capture "Experiment [name] complete: [results]" --project="qry-ecosystem" --tags="experiment,safety"
```

---

## 📊 **Safety Metrics and Monitoring**

### **Key Safety Indicators**

1. **Backup Freshness**: Latest backup <24 hours old
2. **Backup Integrity**: All backups pass integrity checks
3. **Recovery Readiness**: Recovery scripts tested monthly
4. **Data Growth**: Database sizes within expected ranges

### **Warning Signs**

- ⚠️ No backup created in >48 hours
- ⚠️ Database file size suddenly drops
- ⚠️ SQLite integrity check failures
- ⚠️ Backup script execution failures
- ⚠️ Recovery test failures

### **Emergency Escalation**

If safety systems fail:
1. **STOP all development work immediately**
2. **Document failure mode and symptoms**
3. **Attempt recovery using most recent known-good backup**
4. **Update safety procedures to prevent recurrence**

---

## 🏗️ **Continuous Improvement**

### **Safety System Evolution**

- **Monthly Review**: Assess backup coverage and test results
- **Failure Learning**: Document and analyze any data loss incidents
- **Procedure Updates**: Refine based on practical experience
- **Community Sharing**: Contribute safety learnings to broader developer community

### **Future Enhancements**

- [ ] Automated integrity monitoring
- [ ] Real-time backup health dashboards
- [ ] Cross-machine backup replication
- [ ] Backup encryption for sensitive experiments
- [ ] Integration with external backup services

---

## 🎯 **Quick Reference Commands**

```bash
# Daily safety check
qry-backup-status

# Pre-experiment backup
qry-chaos [experiment-name] --force

# Emergency recovery
cd /qry/backups/chaos/[latest-backup]/
./RECOVER_FROM_CHAOS.sh

# Test backup integrity
sqlite3 [backup-file] "PRAGMA integrity_check;"

# Force immediate backup
qry-backup-now
```

---

**Remember**: The goal isn't to prevent all failures, but to ensure they're recoverable learning experiences rather than catastrophic data loss.

*"Smart chaos requires systematic safety. Test your parachutes before you jump."*
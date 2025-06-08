# AI Collaboration Quick Reference

**Purpose**: Rapid reference for systematic AI collaboration during development  
**Use**: Keep open during AI-assisted coding sessions  
**Full Procedure**: See `AI_COLLABORATION_PROCEDURE.md` for complete methodology

---

## 🚀 Session Quick Start

### **Pre-Session (2 minutes)**
- [ ] Update `TIMEKEEPING.md` 
- [ ] Identify AI collaboration goal
- [ ] Prepare context artifacts (code samples, requirements)

### **🔒 SAFETY CHECK (MANDATORY)**
- [ ] Verify recent backup exists: `ls -la /qry/backups/uroboro/ | tail -1`
- [ ] Check database health: `sqlite3 ~/.local/share/uroboro/uroboro.sqlite "SELECT COUNT(*) FROM captures;"`
- [ ] For risky operations: `qry-chaos [experiment-name] --force`

**⚠️ NEVER proceed with database changes, ecosystem modifications, or experimental features without current backups!**

**See**: `SAFETY_AND_BACKUP_PROCEDURES.md` for complete safety protocols

### **Context Pattern Template**
```
Current state: [What we have now]
Goal: [What we want to achieve] 
Constraints: [Technical/QRY limitations]
QRY Principles: [local-first/psychology-informed/etc.]
Example: [Show desired outcome]
```

---

## 💬 Effective Prompting Patterns

### **Prompt by Example** (Most Effective)
✅ Show exactly how result should look/behave  
✅ Include usage examples, not just specifications  
✅ Demonstrate the style/structure you want  

### **Multi-Shot Refinement**
✅ "You did X, but we should do Y. Please fix."  
✅ Clear context → Specific changes → Direct instruction  
✅ Reference QRY principles when relevant  

### **Documentation Generation**
✅ "Generate comprehensive documentation for [component]"  
✅ Include links to relevant docs with `@<link>`  
✅ Request specific format/style alignment  

---

## 📝 Commit Message Templates

### **AI-Generated** (>90% AI)
```
[COMPONENT] Brief description

AI Collaboration: AI-Generated
Prompt: "[Essential prompt content]"

Human Oversight: [What you added/modified]
QRY Alignment: [Methodology considerations]
```

### **AI-Assisted** (~70% AI)
```
[COMPONENT] Brief description

AI Collaboration: AI-Assisted
Prompt: "[Key refinement prompt]"

Human Oversight: [Significant modifications]
QRY Alignment: [Principle applications]
```

### **AI-Enhanced** (~50% AI)
```
[COMPONENT] Brief description

AI Collaboration: AI-Enhanced
Prompt: "[Documentation/formatting prompt]"

Human Oversight: [Core logic and decisions]
QRY Alignment: [Strategic considerations]
```

---

## 🎯 Project-Specific Focus

### **uroboro** (Communication Intelligence)
- **AI Role**: Content generation, professional formatting
- **Human Role**: Strategic messaging, authenticity
- **Focus**: How AI helps present human insights

### **wherewasi** (Context Intelligence)  
- **AI Role**: Context structuring, archaeological docs
- **Human Role**: Context strategy, integration decisions
- **Focus**: Systematic context transfer between sessions

### **doggowoof** (Alert Intelligence)
- **AI Role**: Alert logic, UX patterns
- **Human Role**: Psychology-informed design
- **Focus**: Human-centered alert behaviors

---

## ✅ Pre-Commit Quality Check

### **Code Quality**
- [ ] Aligns with QRY local-first principles
- [ ] Respects psychology-informed design  
- [ ] Preserves privacy and user sovereignty
- [ ] Integrates with ecosystem intelligence

### **Documentation Quality**
- [ ] AI collaboration level accurate
- [ ] Essential prompts included
- [ ] Human contributions identified
- [ ] QRY methodology alignment noted

---

## 🚨 Common Patterns & Fixes

### **When AI Struggles**
- Complex refactoring → Manual intervention
- Styling/cleanup → Faster to do manually
- Duplicate code blocks → Use manual find/replace
- Domain-specific logic → Human judgment required

### **Multi-Shot Indicators**
- First attempt ~80% correct → Normal, refine
- AI misunderstands context → Add more examples
- Code structure wrong → Show exact structure needed
- Missing QRY principles → Explicitly reference methodology

---

## 📊 Session Success Indicators

### **Good Collaboration Session**
✅ Clear archaeological record in commits  
✅ Prompts preserved for methodology transfer  
✅ Human oversight documented transparently  
✅ QRY principles consistently applied  
✅ Professional credibility through transparency  

### **Needs Improvement**
❌ Generic commit messages without prompts  
❌ Missing human oversight documentation  
❌ QRY methodology not referenced  
❌ AI involvement hidden or unclear  

---

## 🔄 End-of-Session (5 minutes)

### **Archaeological Documentation**
- [ ] Review commit history for systematic documentation
- [ ] Note successful prompt patterns for reuse
- [ ] Identify methodology insights for transfer
- [ ] Update project context for next session

### **Integration Opportunities**
- [ ] How does this advance ecosystem intelligence?
- [ ] Cross-project enhancement opportunities?
- [ ] Content for uroboro communication?
- [ ] Context improvements for wherewasi?

---

**Remember**: AI collaboration should be transparent, systematic, and create archaeological records that others can learn from. Every commit tells the story of human-AI creative partnership.

**Quick Mental Check**: "Could someone else replicate this collaboration by reading my commit messages?"
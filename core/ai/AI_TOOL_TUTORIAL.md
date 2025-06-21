# AI Tool Tutorial: QRY Ecosystem Tool Usage Patterns

**Purpose**: Systematic guide for AI assistants using QRY ecosystem tools  
**Current Date**: June 8, 2025
**Status**: Living tutorial - update as tool usage patterns evolve  
**Scope**: Complete reference for effective tool integration in AI collaboration

---

## 🎯 Core Tools & Usage Patterns

### **Uroboro - Communication Intelligence**
**Location**: `labs/projects/uroboro/uroboro`  
**Purpose**: Capture insights and generate professional communication content

### **Wherewasi - Context Intelligence**
**Location**: `labs/projects/wherewasi/wherewasi`  
**Purpose**: Preserve context across sessions and maintain archaeological documentation

#### **Standard Capture Pattern**
```bash
cd labs/projects/uroboro
./uroboro capture --db "description" --project project-name --tags tag1,tag2,tag3
```

#### **Common Project Names**
- `qry-ecosystem` - Meta-work on QRY methodology and infrastructure
- `uroboro-dev` - Development work on uroboro itself
- `doggowoof-dev` - Development work on doggowoof
- `wherewasi-dev` - Development work on wherewasi
- `quantum-dice` - Educational game development
- `strategic-planning` - High-level QRY strategy work
- `ai-collaboration` - AI methodology and framework development

#### **Standard Tag Categories**
**Strategic Work**:
- `strategic-planning`, `ecosystem-documentation`, `methodology-development`
- `microstudio-architecture`, `systematic-methodology`, `r-and-d-lab`

**Development Work**:
- `bug-fix`, `feature-development`, `architecture-decision`
- `testing`, `documentation`, `integration`

**AI Collaboration**:
- `ai-collaboration`, `ai-methodology`, `meta-analysis`
- `framework-development`, `community-contribution`

**Educational/Research**:
- `educational-methodology`, `complex-concept-translation`
- `psychology-informed-design`, `academic-research`

#### **Example Captures for Common Scenarios**

**Major Strategic Session**:
```bash
./uroboro capture --db "Comprehensive QRY ecosystem documentation and strategic planning session. Developed AI collaboration infrastructure and identified R&D lab concept." --project qry-ecosystem --tags strategic-planning,ecosystem-documentation,ai-collaboration,systematic-methodology
```

**Development Work**:
```bash
./uroboro capture --db "Implemented shadow mode communication protocol for wherewasi context sharing." --project wherewasi-dev --tags feature-development,architecture-decision,ecosystem-intelligence
```

**Educational Insight**:
```bash
./uroboro capture --db "Validated complex concept translation methodology through quantum dice mechanics analysis." --project quantum-dice --tags educational-methodology,complex-concept-translation,methodology-validation
```

**AI Collaboration Methodology**:
```bash
./uroboro capture --prompt "Multi-shot refinement pattern for context preservation" --project wherewasi-dev --tags ai-collab,context-intelligence,methodology --effectiveness-rating 4
```

### **Wherewasi Usage Patterns**

#### **Session Management**
```bash
# Start new AI collaboration session
wherewasi new-session --type ai-collab --project [project-name] --date $(date +%Y-%m-%d)

# Load previous session context
wherewasi load --session latest --include methodology,insights,context

# Save current session with archaeological documentation
wherewasi save --session current --archaeological --transferable-methodology
```

#### **Context Preservation**
```bash
# Track methodology evolution across sessions
wherewasi track --methodology-evolution --improvements "[what got better]" --challenges "[what's still hard]"

# Create archaeological record for methodology transfer
wherewasi archive --session [session-id] --include full-prompt-history,methodology-insights --format archaeological-record
```

---

## 🔧 Integrated Tool Workflow (uroboro + wherewasi)

### **Morning Lab Startup** (Following MORNING_LAB_STARTUP.md)
1. **Update timekeeping**: Modify `ai/TIMEKEEPING.md` with current date/time
2. **Context restoration**: `wherewasi load --session latest --include methodology,insights,context`
3. **Tool initialization**: `./uroboro capture-mode --active --session morning-$(date +%Y-%m-%d)`
4. **Generate situation report**: AI creates morning digest for coffee-time review

### **Active AI Collaboration** (Following INTEGRATED_AI_COLLABORATION.md)
1. **Prompt capture**: `uro capture --prompt "[prompt content]" --project [name] --tags ai-collab,methodology`
2. **Context tracking**: `wherewasi track --methodology-evolution --session current`
3. **Systematic refinement**: Multi-shot prompting with archaeological documentation
4. **Quality assurance**: Verify QRY alignment (local-first, psychology-informed)

### **Session Documentation**
1. **Generate commit messages**: `uro generate-commit-message --session-today --project [name]`
2. **Archive session**: `wherewasi archive --session current --archaeological --transferable-methodology`
3. **Methodology insights**: Capture patterns for future sessions and community transfer

### **Session Wrap-Up**
1. **Final insights**: `uro capture --methodology-evolution "[what we learned today]"`
2. **Context preparation**: `wherewasi prepare-next-session --context-continuity`
3. **Update procedures**: Note any new usage patterns or improvements discovered

---

## 🎯 QRY Tool Preferences & Standards

### **Project Naming Conventions**
- Use **kebab-case** for project names (`qry-ecosystem`, not `qry_ecosystem`)
- Be **specific but concise** (`doggowoof-dev` better than `dog-development`)
- **Align with repository names** where applicable
- **Group related work** under consistent project names

### **Tagging Strategy**
- **3-5 tags maximum** for focused categorization
- **Use existing tags** when possible for consistency
- **Hierarchical thinking**: `strategic-planning > ecosystem-documentation > ai-collaboration`
- **Future searchability**: Tags should enable useful filtering and analysis

### **Description Best Practices**
- **Start with action or outcome**: "Developed...", "Discovered...", "Implemented..."
- **Include context**: Reference major concepts or decisions
- **Professional tone**: Suitable for portfolio and business communication
- **Systematic thinking**: Show methodology and strategic consideration

---

## 🚀 Advanced Usage Patterns

### **Cross-Project Capture Strategy**
When work affects multiple projects, use primary project name and cross-reference tags:
```bash
./uroboro capture --db "Ecosystem intelligence breakthrough affects all QRY tools through shadow mode communication." --project qry-ecosystem --tags ecosystem-intelligence,wherewasi-dev,doggowoof-dev,uroboro-dev
```

### **Methodology Development Captures**
For work that advances QRY methodology itself:
```bash
./uroboro capture --db "Developed systematic AI collaboration framework with transparent procedures and quality assurance." --project qry-ecosystem --tags methodology-development,ai-collaboration,systematic-methodology,community-contribution
```

### **Professional Portfolio Captures**
For work that demonstrates competence and strategic thinking:
```bash
./uroboro capture --db "Completed systematic profiling of QRY microstudio architecture - demonstrates enterprise-grade strategic thinking and infrastructure planning." --project qry-ecosystem --tags strategic-planning,professional-portfolio,microstudio-architecture,systematic-methodology
```

---

## 🧠 Integration with AI Collaboration

### **Capture AI Session Insights**
Document significant AI collaboration breakthroughs:
```bash
./uroboro capture --db "AI collaboration revealed complete microstudio architecture and R&D lab concept. Systematic documentation approach validated for strategic planning." --project ai-collaboration --tags ai-methodology,strategic-discovery,systematic-methodology
```

### **Methodology Validation**
When AI work validates QRY principles:
```bash
./uroboro capture --db "AI collaboration demonstrates QRY methodology effectiveness - systematic approach, human-centered design, and transparent documentation create superior outcomes." --project qry-ecosystem --tags methodology-validation,ai-collaboration,systematic-methodology
```

### **Community Contribution Prep**
For insights that benefit others:
```bash
./uroboro capture --db "Developed transferable framework for transparent AI collaboration that other developers can adopt and adapt." --project ai-collaboration --tags community-contribution,framework-development,ai-methodology
```

---

## 🔄 Future Tool Integration

### **Active Tool Integrations**
- **wherewasi + uroboro**: Meta-intelligence loop for AI collaboration methodology
- **Morning lab startup**: Systematic session initialization with context restoration
- **Archaeological documentation**: Transparent methodology preservation and transfer

### **Planned Tool Integrations**
- **doggowoof**: Pattern recognition for capture optimization and workflow alerts
- **qomoboro**: Time-based capture automation and session management integration
- **examinator**: Analysis of capture patterns and methodology insights for continuous improvement

### **Tool Preference Evolution**
This tutorial will evolve as:
- **Usage patterns mature** through practical application
- **New tools integrate** into the QRY ecosystem
- **Community feedback** improves systematic approaches
- **Academic research** validates methodology effectiveness

---

## 🎯 Success Metrics

### **Effective Tool Usage**
- **Consistent project naming** enables useful filtering and analysis
- **Strategic tagging** supports cross-project insights and methodology development
- **Professional descriptions** enhance portfolio value and business communication
- **Systematic approach** aligns with QRY methodology principles

### **AI Collaboration Enhancement**
- **Systematic documentation** preserves insights for future sessions
- **Strategic thinking** advances QRY ecosystem development
- **Community value** creates frameworks others can adopt
- **Professional credibility** demonstrates competence and systematic thinking
- **Archaeological preservation** enables methodology transfer and continuous improvement
- **Context continuity** maintains session-to-session workflow intelligence

---

**Tutorial Status**: Foundation complete, designed for systematic expansion  
**Next Update**: As new tool integration patterns emerge  
**Integration**: Reference for all AI assistants working within QRY ecosystem  
**Community Value**: Framework for systematic tool usage in collaborative development

*"Systematic tool usage that preserves insights, advances methodology, and creates community value."*
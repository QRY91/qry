# QRY Ecosystem Database Integration Guide

**Strategic Architecture for Unified Database with Independent Tool Operation**

## Overview

This guide implements a shared database strategy that allows QRY ecosystem tools (wherewasi/uroboro/examinator) to:

- **Function independently** with their own databases when installed alone
- **Share ecosystem intelligence** when pointed to a common database
- **Maintain backward compatibility** with existing tool-specific databases
- **Enable cross-tool insights** through standardized communication tables

## Architecture Strategy

### Database Discovery Logic
```
1. Check for shared ecosystem database (~/.local/share/qry/ecosystem.sqlite)
2. If available and not forced local → Use shared database
3. If not available or forced local → Use tool-specific database
4. Each tool maintains full functionality regardless of database choice
```

### Shared Schema Design
```sql
-- CORE ECOSYSTEM TABLES (shared by all tools)
projects              -- Project tracking across ecosystem
tool_messages         -- Cross-tool communication
usage_stats           -- Analytics across all tools
ecosystem_insights     -- AI-generated cross-tool recommendations

-- TOOL-SPECIFIC TABLES (created as needed)
context_sessions      -- wherewasi: context captures
captures              -- uroboro: content captures  
publications          -- uroboro: published content
flashcards            -- examinator: spaced repetition
study_sessions        -- examinator: learning analytics
```

## Implementation Steps

### Step 1: Copy Ecosystem Package

Copy the entire `internal/ecosystem/` package to each project:

```
yourproject/
├── internal/
│   ├── ecosystem/
│   │   ├── database.go    # Core ecosystem database logic
│   │   └── types.go       # Shared types and constants
│   └── existing_packages/
```

### Step 2: Update Main Database Initialization

Replace tool-specific database initialization with ecosystem database:

#### Before (tool-specific):
```go
import "github.com/yourproject/internal/database"

var db *database.DB

func main() {
    db, err = database.NewDB("")
    // ...
}
```

#### After (ecosystem-aware):
```go
import (
    "github.com/yourproject/internal/ecosystem"
    "github.com/yourproject/internal/common"
)

var db *ecosystem.EcosystemDB

func main() {
    config := ecosystem.DatabaseConfig{
        ToolName:     ecosystem.ToolYourTool,  // e.g., ToolWherewasi
        FallbackPath: filepath.Join(common.GetDataDir(), "yourtool.sqlite"),
        ForceLocal:   false,
    }
    
    db, err = ecosystem.NewEcosystemDB(config)
    if err != nil {
        fmt.Printf("⚠️  Failed to initialize ecosystem database: %v\n", err)
        // Continue without persistence
    } else {
        if db.IsShared() {
            fmt.Printf("🔗 Connected to shared ecosystem database\n")
        } else {
            fmt.Printf("📁 Using local database\n")
        }
    }
}
```

### Step 3: Update Method Calls

The ecosystem database implements all the original database methods plus new ecosystem features:

#### Existing Methods (unchanged interface):
```go
// wherewasi
db.SaveContext(project, contextData, sessionInfo, keywords)
db.GetRecentContexts(project, limit)
db.SearchStoredContexts(keyword)

// uroboro  
db.InsertCapture(content, project, tags)
db.GetRecentCaptures(days, project)
db.InsertPublication(title, content, format, pubType, project, targetPath, sourceCaptureIDs)

// examinator (new methods to implement)
db.CreateFlashcard(question, answer, category, difficulty, sourceCaptureID, project)
db.GetFlashcardsForReview(project, limit)
db.RecordStudySession(project, flashcardsReviewed, correctAnswers, durationMinutes)
```

#### New Ecosystem Methods:
```go
// Cross-tool communication
db.SendToolMessage(fromTool, toTool, messageType, data)
db.GetUnprocessedMessages(toolName)
db.MarkMessageProcessed(messageID)

// Project tracking
db.TrackProject(name, path, primaryTool, isGitRepo)
db.GetRecentProjects(limit)

// Usage analytics
db.TrackUsage(tool, command, project, sessionID, durationMs, success, errorMsg)
```

## Tool-Specific Integration Examples

### wherewasi Integration

```go
// Enhanced context saving with ecosystem awareness
func saveContext(context, project, sessionInfo, keywords string) {
    // Save to ecosystem database
    session, err := db.SaveContext(project, context, sessionInfo, keywords)
    if err != nil {
        log.Printf("Failed to save context: %v", err)
        return
    }
    
    // Send context update message to other tools
    contextData := ecosystem.ContextUpdateMessageData{
        Project:     project,
        ContextData: context,
        SessionInfo: sessionInfo,
        Keywords:    keywords,
    }
    
    msg, _ := ecosystem.NewToolMessage(
        ecosystem.ToolWherewasi,
        ecosystem.ToolUroboro,
        ecosystem.MessageTypeContextUpdate,
        contextData,
    )
    
    db.SendToolMessage(msg.FromTool, msg.ToTool, msg.MessageType, msg.Data)
    
    // Track project activity
    db.TrackProject(project, getCurrentDir(), ecosystem.ToolWherewasi, hasGitRepo("."))
}
```

### uroboro Integration

```go
// Enhanced capture with context awareness
func createCapture(content, project, tags string) {
    // Check for recent context from wherewasi
    if db.IsShared() {
        contextSessions, err := db.GetRecentContexts(project, 1)
        if err == nil && len(contextSessions) > 0 {
            // Link capture to recent context session
            capture, err := db.InsertCaptureWithContext(
                content, project, tags, &contextSessions[0].ID)
        } else {
            capture, err := db.InsertCapture(content, project, tags)
        }
    } else {
        capture, err := db.InsertCapture(content, project, tags)
    }
    
    // Send capture notification to examinator for potential flashcard generation
    captureData := ecosystem.CaptureMessageData{
        Content: content,
        Project: project,
        Tags:    tags,
    }
    
    msg, _ := ecosystem.NewToolMessage(
        ecosystem.ToolUroboro,
        ecosystem.ToolExaminator,
        ecosystem.MessageTypeCapture,
        captureData,
    )
    
    db.SendToolMessage(msg.FromTool, msg.ToTool, msg.MessageType, msg.Data)
}
```

### examinator Integration (New)

```go
// Process messages from other tools for flashcard generation
func processEcosystemMessages() {
    if !db.IsShared() {
        return // No ecosystem integration in local mode
    }
    
    messages, err := db.GetUnprocessedMessages(ecosystem.ToolExaminator)
    if err != nil {
        log.Printf("Failed to get messages: %v", err)
        return
    }
    
    for _, msg := range messages {
        switch msg.MessageType {
        case ecosystem.MessageTypeCapture:
            var captureData ecosystem.CaptureMessageData
            if err := msg.ParseMessageData(&captureData); err != nil {
                continue
            }
            
            // Generate flashcards from capture content
            flashcards := generateFlashcardsFromContent(captureData.Content)
            for _, fc := range flashcards {
                db.CreateFlashcard(fc.Question, fc.Answer, fc.Category, 
                    fc.Difficulty, captureData.SourceCaptureID, captureData.Project)
            }
            
        case ecosystem.MessageTypeContextUpdate:
            // Use context to improve flashcard categorization
            var contextData ecosystem.ContextUpdateMessageData
            if err := msg.ParseMessageData(&contextData); err != nil {
                continue
            }
            
            // Update flashcard categories based on current context
            updateFlashcardCategories(contextData.Project, contextData.Keywords)
        }
        
        db.MarkMessageProcessed(msg.ID)
    }
}
```

## Benefits of Ecosystem Integration

### For Individual Tools
- **Backward compatibility**: Existing functionality unchanged
- **Enhanced context**: Access to cross-tool data when available
- **Improved UX**: "Smart" behavior when tools work together
- **Analytics**: Better usage tracking and optimization

### For Users
- **Seamless workflow**: Tools that "know" about each other
- **Reduced friction**: Auto-population of data between tools
- **Intelligence amplification**: AI insights from tool interaction patterns
- **Unified analytics**: Single dashboard for entire workflow

### For QRY Ecosystem
- **Network effects**: Tools become more valuable together
- **Data consistency**: Single source of truth for cross-tool data
- **Innovation platform**: Foundation for advanced AI features
- **Community value**: Reusable patterns for other ecosystems

## Migration Strategy

### Phase 1: wherewasi (Scout)
1. ✅ Implement ecosystem database package
2. ✅ Update wherewasi to use ecosystem DB with fallback
3. ✅ Test context saving/retrieval with shared database

### Phase 2: uroboro (Scribe)
1. Copy ecosystem package to uroboro repository
2. Update uroboro database initialization
3. Implement capture-context linking
4. Add tool message processing for wherewasi context updates

### Phase 3: examinator (Scholar)
1. Copy ecosystem package to examinator repository  
2. Implement SQLite database (currently Python, needs database layer)
3. Add flashcard generation from uroboro captures
4. Implement study session tracking with context awareness

### Phase 4: qryai (Intelligence)
1. Update qryai to use ecosystem database for insights
2. Implement cross-tool intelligence recommendations
3. Add ecosystem analytics and optimization suggestions

## Usage Examples

### Shared Database Scenario
```bash
# User enables ecosystem database
mkdir -p ~/.local/share/qry
touch ~/.local/share/qry/ecosystem.sqlite

# wherewasi captures context
cd ~/projects/myproject
wherewasi pull
# → Saves context to shared database
# → Sends context_update message to uroboro

# uroboro creates capture
uroboro capture "Implemented user authentication"
# → Links capture to recent wherewasi context
# → Sends capture message to examinator

# examinator generates flashcards
examinator process-messages
# → Creates flashcards from uroboro capture
# → Uses wherewasi context for better categorization
```

### Independent Tool Scenario
```bash
# User installs only uroboro
pip install uroboro

# uroboro works independently
uroboro capture "Fixed bug in login system"
# → Uses local uroboro.sqlite database
# → Full functionality without ecosystem database
```

## File Structure for Implementation

```
yourproject/
├── internal/
│   ├── ecosystem/           # 📁 Copy this entire package
│   │   ├── database.go      # Core ecosystem database logic
│   │   └── types.go         # Shared types and validation
│   ├── database/            # 📁 Keep existing for backward compatibility
│   │   └── database.go      # Original tool-specific database
│   └── common/
│       └── dirs.go          # XDG-compliant directory helpers
├── cmd/yourproject/
│   └── main.go              # 🔧 Update database initialization
├── go.mod                   # 🔧 Add dependencies if needed
└── README.md                # 📝 Document ecosystem features
```

## Testing Ecosystem Integration

### Unit Tests
```go
func TestEcosystemDatabaseDiscovery(t *testing.T) {
    // Test shared database discovery
    // Test fallback to local database
    // Test tool-specific table creation
}

func TestCrossToolCommunication(t *testing.T) {
    // Test message sending/receiving
    // Test message validation
    // Test message processing
}
```

### Integration Tests
```bash
# Test ecosystem workflow
./test_ecosystem_integration.sh
# 1. Initialize shared database
# 2. Run wherewasi context capture
# 3. Run uroboro capture with context linking
# 4. Verify cross-tool data consistency
```

## Maintenance and Evolution

### Database Migrations
- Each tool manages its own table migrations
- Shared tables use coordinated migration strategy
- Version tracking prevents conflicts

### Tool Addition
- Copy ecosystem package to new tool repository
- Implement tool-specific migration function
- Add tool constants to types.go
- Test integration with existing tools

### Schema Evolution
- Backward-compatible changes preferred
- Migration coordination across repositories
- Community notification for breaking changes

---

## Quick Start Checklist

- [ ] Copy `internal/ecosystem/` package to your project
- [ ] Update database initialization in main.go
- [ ] Test local database functionality (should be unchanged)
- [ ] Test shared database discovery
- [ ] Implement tool-specific message processing
- [ ] Add ecosystem integration tests
- [ ] Update documentation with ecosystem features

**Result**: Your tool gains ecosystem intelligence while maintaining full independence.

*"Better tools through ecosystem intelligence, with no compromise on autonomy."*
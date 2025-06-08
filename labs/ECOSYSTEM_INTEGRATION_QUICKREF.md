# QRY Ecosystem Integration Quick Reference

**For developers implementing ecosystem integration in QRY tools**

## Quick Setup (5 minutes)

### 1. Copy Ecosystem Package
```bash
# Copy ecosystem package to your tool repository
cp -r /path/to/qry/labs/projects/wherewasi/internal/ecosystem ./internal/
```

### 2. Update Dependencies
```go
// Add to imports in main.go
import (
    "github.com/yourproject/internal/ecosystem"
    "github.com/yourproject/internal/common"
)
```

### 3. Replace Database Initialization
```go
// BEFORE (tool-specific)
var db *database.DB
func main() {
    db, err = database.NewDB("")
}

// AFTER (ecosystem-aware)
var db *ecosystem.EcosystemDB
func main() {
    config := ecosystem.DatabaseConfig{
        ToolName:     ecosystem.ToolYourTool,  // ToolWherewasi, ToolUroboro, etc.
        FallbackPath: filepath.Join(common.GetDataDir(), "yourtool.sqlite"),
        ForceLocal:   false,
    }
    
    db, err = ecosystem.NewEcosystemDB(config)
    if err != nil {
        fmt.Printf("⚠️  Database init failed: %v\n", err)
        return
    }
    
    if db.IsShared() {
        fmt.Printf("🔗 Connected to QRY ecosystem\n")
    } else {
        fmt.Printf("📁 Using local database\n")
    }
}
```

## Tool-Specific Integration

### wherewasi
```go
// Enhanced context saving
session, err := db.SaveContext(project, contextData, sessionInfo, keywords)

// Send context update to uroboro
contextData := ecosystem.ContextUpdateMessageData{
    Project: project, ContextData: contextData, 
    SessionInfo: sessionInfo, Keywords: keywords,
}
msg, _ := ecosystem.NewToolMessage(
    ecosystem.ToolWherewasi, ecosystem.ToolUroboro,
    ecosystem.MessageTypeContextUpdate, contextData,
)
db.SendToolMessage(msg.FromTool, msg.ToTool, msg.MessageType, msg.Data)
```

### uroboro
```go
// Capture with context linking
var capture *ecosystem.Capture
if db.IsShared() && project != "" {
    contexts, err := db.GetRecentContexts(project, 1)
    if err == nil && len(contexts) > 0 {
        capture, err = db.InsertCaptureWithContext(content, project, tags, &contexts[0].ID)
    }
}
if capture == nil {
    capture, err = db.InsertCapture(content, project, tags)
}

// Notify examinator
captureData := ecosystem.CaptureMessageData{Content: content, Project: project, Tags: tags}
msg, _ := ecosystem.NewToolMessage(
    ecosystem.ToolUroboro, ecosystem.ToolExaminator,
    ecosystem.MessageTypeCapture, captureData,
)
db.SendToolMessage(msg.FromTool, msg.ToTool, msg.MessageType, msg.Data)

// Process ecosystem messages
err := db.ProcessUroboroCaptures()
```

### examinator (Python)
```python
# Initialize ecosystem database
db = EcosystemDatabase(force_local=False)

# Process messages from other tools
messages = db.get_unprocessed_messages("examinator")
for msg in messages:
    if msg.message_type == "capture":
        data = json.loads(msg.data)
        # Generate flashcards from capture
        flashcards = generate_flashcards(data['content'])
        for fc in flashcards:
            db.create_flashcard(fc.question, fc.answer, fc.category, data['project'])
    db.mark_message_processed(msg.id)
```

## Testing Integration

### 1. Test Local Mode (should work unchanged)
```bash
# Your tool should work exactly as before
yourtool command --args
```

### 2. Test Ecosystem Mode
```bash
# Create ecosystem database
mkdir -p ~/.local/share/qry
touch ~/.local/share/qry/ecosystem.sqlite

# Run your tool (should detect ecosystem)
yourtool command --args
# Should show: "🔗 Connected to QRY ecosystem"
```

### 3. Test Force Local
```bash
# Should fall back to local database
yourtool command --local
# Should show: "📁 Using local database"
```

### 4. Run Integration Test
```bash
# Use the provided test script
bash /path/to/qry/labs/ECOSYSTEM_INTEGRATION_TEST.sh
```

## Key Commands to Add

### Configuration Commands
```bash
# Enable ecosystem mode
yourtool config enable-ecosystem

# Disable ecosystem mode  
yourtool config disable-ecosystem

# Check status
yourtool status
# Output should show:
# 🗄️  Database: ~/.local/share/qry/ecosystem.sqlite
# 🔗 Ecosystem mode: ENABLED
```

### Message Processing
```bash
# Process ecosystem messages
yourtool sync
# or
yourtool process-messages
```

## Essential Code Patterns

### 1. Message Sending
```go
data := ecosystem.YourMessageData{Field1: value1, Field2: value2}
msg, err := ecosystem.NewToolMessage(fromTool, toTool, messageType, data)
if err == nil {
    db.SendToolMessage(msg.FromTool, msg.ToTool, msg.MessageType, msg.Data)
}
```

### 2. Message Processing
```go
messages, err := db.GetUnprocessedMessages(ecosystem.ToolYourTool)
for _, msg := range messages {
    switch msg.MessageType {
    case ecosystem.MessageTypeCapture:
        // Handle capture message
    case ecosystem.MessageTypeContextUpdate:
        // Handle context update
    }
    db.MarkMessageProcessed(msg.ID)
}
```

### 3. Project Tracking
```go
err := db.TrackProject(projectName, projectPath, ecosystem.ToolYourTool, hasGitRepo)
```

### 4. Usage Tracking
```go
err := db.TrackUsage(toolName, commandName, projectName, sessionID, durationMs, success, errorMsg)
```

## Ecosystem Constants

```go
// Tool names
ecosystem.ToolWherewasi
ecosystem.ToolUroboro  
ecosystem.ToolExaminator
ecosystem.ToolQryAI
ecosystem.ToolDoggowoof
ecosystem.ToolQomoboro

// Message types
ecosystem.MessageTypeCapture
ecosystem.MessageTypeContextUpdate
ecosystem.MessageTypeFlashcardRequest
ecosystem.MessageTypeStudySession
ecosystem.MessageTypeProjectActivity
ecosystem.MessageTypeInsight
```

## Troubleshooting

### Database Issues
```bash
# Check if ecosystem database exists
ls -la ~/.local/share/qry/ecosystem.sqlite

# Check database schema
sqlite3 ~/.local/share/qry/ecosystem.sqlite ".schema"

# Check tool messages
sqlite3 ~/.local/share/qry/ecosystem.sqlite "SELECT * FROM tool_messages;"
```

### Common Errors
- **"Database not found"**: Normal - tool will use local database
- **"Tool messages table missing"**: Run migrations or recreate ecosystem DB
- **"Cross-tool features not working"**: Check if both tools use ecosystem DB

### Force Recreate Ecosystem Database
```bash
rm ~/.local/share/qry/ecosystem.sqlite
yourtool command  # Will recreate with fresh schema
```

## Verification Checklist

- [ ] Tool works without ecosystem database (local mode)
- [ ] Tool detects and uses ecosystem database when available
- [ ] Tool shows ecosystem status in output
- [ ] Tool-specific tables created in ecosystem database
- [ ] Tool can send messages to other tools
- [ ] Tool can process messages from other tools
- [ ] `--local` flag forces local database mode
- [ ] Configuration commands work (enable/disable ecosystem)
- [ ] Project activity tracked in ecosystem database

## File Structure Reference

```
yourproject/
├── internal/
│   ├── ecosystem/          # 📁 Copy this package
│   │   ├── database.go
│   │   └── types.go
│   ├── database/           # 📁 Keep for backward compatibility
│   └── common/
├── cmd/yourproject/
│   └── main.go             # 🔧 Update database init
└── README.md               # 📝 Document ecosystem features
```

## Quick Test Command

```bash
# All-in-one test
mkdir -p ~/.local/share/qry && touch ~/.local/share/qry/ecosystem.sqlite && yourtool status
```

---

**Result**: Your tool gains ecosystem intelligence while maintaining full independence.

*Time to implement: ~30 minutes*  
*Time to test: ~10 minutes*  
*Benefit: Ecosystem-aware tool with zero functionality loss*
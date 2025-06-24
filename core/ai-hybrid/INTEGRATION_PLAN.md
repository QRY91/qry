# QRY AI Hybrid Integration Plan 🤖⚡

**Combining LocalAI Infrastructure with Ollama Smart Routing Excellence**

## 🎯 Integration Vision

Transform QRY's AI capabilities by merging:
- **Current**: Working LocalAI setup with Docker + unified API
- **Backup**: Sophisticated Ollama smart routing + multi-model optimization
- **Result**: Best-in-class local AI system with intelligent model selection

### Target Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    QRY AI Hybrid System                    │
├─────────────────────────────────────────────────────────────┤
│  Smart Router (Prompt Analysis → Model Selection)          │
├─────────────────┬───────────────────────────────────────────┤
│   LocalAI API   │            Ollama CLI                    │
│   (Unified)     │         (Model Variety)                  │
├─────────────────┼───────────────────────────────────────────┤
│ • OpenAI compat │ • orca-mini:3b (speed)                  │
│ • Docker setup  │ • codellama:7b (code)                   │
│ • Working now   │ • llama2:13b (quality)                  │
│                 │ • mistral:7b (balanced)                 │
└─────────────────┴───────────────────────────────────────────┘
```

## 📊 Current State Analysis

### LocalAI Setup (Working ✅)
- **Model**: `llama-3.2-1b-instruct:q4_k_m`
- **Interface**: Docker + HTTP API (OpenAI compatible)
- **Integration**: Basic Go prototypes (qry-ai.go, uroboro-ai.go, wherewasi-ai.go)
- **Strengths**: Unified API, working now, consistent interface
- **Limitations**: Single model, basic routing, no optimization

### Ollama Backup (Sophisticated 🏆)
- **Models**: Multi-model strategy with smart selection
- **Routing**: Advanced prompt analysis and model selection
- **Integration**: Deep uroboro integration with smart capture
- **Optimization**: Cost tracking, performance monitoring, fallback strategies
- **Strengths**: Intelligent routing, proven methodology, comprehensive tooling
- **Limitations**: Not currently deployed, CLI-based interface

## 🚀 Hybrid Integration Strategy

### Phase 1: Foundation (Week 1)
**Goal**: Establish hybrid infrastructure supporting both LocalAI and Ollama

#### 1.1 Dual Backend Support
```go
// core/ai-hybrid/backends/
type AIBackend interface {
    Query(prompt string, config ModelConfig) (string, error)
    ListModels() ([]string, error)
    IsAvailable() bool
}

type LocalAIBackend struct {
    endpoint string
}

type OllamaBackend struct {
    binaryPath string
}
```

#### 1.2 Smart Router Implementation
```go
// core/ai-hybrid/router/
type SmartRouter struct {
    analyzer   *PromptAnalyzer
    selector   *ModelSelector
    backends   map[string]AIBackend
    config     *RoutingConfig
}
```

#### 1.3 Configuration System
```bash
# ~/.qry/ai-config.toml
[routing]
strategy = "intelligent"  # vs "fixed"
default_backend = "ollama"
fallback_backend = "localai"

[models]
speed = "orca-mini:3b"
balanced = "mistral:7b" 
quality = "llama2:13b"
code = "codellama:7b"
```

### Phase 2: Smart Routing (Week 2)
**Goal**: Implement intelligent prompt analysis and model selection

#### 2.1 Prompt Analysis Engine
Extract from backup: `uroboro_smart_routing_starter.go`
- Complexity analysis (simple/medium/complex)
- Urgency detection (immediate/normal/quality)
- Content type identification (code/docs/general)
- Confidence scoring

#### 2.2 Model Selection Logic
```go
func (r *SmartRouter) SelectModel(analysis PromptAnalysis) ModelTarget {
    switch {
    case analysis.Urgency == "immediate":
        return ModelTarget{Backend: "ollama", Model: "orca-mini:3b"}
    case analysis.ContentType == "code":
        return ModelTarget{Backend: "ollama", Model: "codellama:7b"}
    case analysis.Complexity == "complex" && analysis.Urgency == "quality":
        return ModelTarget{Backend: "ollama", Model: "llama2:13b"}
    default:
        return ModelTarget{Backend: "localai", Model: "llama-3.2-1b-instruct:q4_k_m"}
    }
}
```

#### 2.3 Tool Integration Updates
Enhance existing tools with smart routing:
- `uroboro-ai.go` → `uroboro-smart.go`
- `wherewasi-ai.go` → `wherewasi-smart.go`
- `qry-ai.go` → `qry-smart.go`

### Phase 3: Optimization Framework (Week 3)
**Goal**: Implement cost tracking and performance optimization

#### 3.1 Performance Monitoring
```go
type UsageMetrics struct {
    ModelUsage     map[string]int
    ResponseTimes  map[string][]time.Duration
    CostTracking   map[string]float64
    QualityScores  map[string][]int
}
```

#### 3.2 Benchmark Integration
Extract from backup:
- `local_ai_benchmark.py` → Go implementation
- `model_comparison.go` → Enhanced version
- `uroboro_model_tester.go` → Integration with current tools

#### 3.3 Cost Optimization
- Track usage patterns
- Recommend model selections
- Monitor performance degradation
- Generate optimization reports

### Phase 4: Advanced Features (Week 4)
**Goal**: Add sophisticated features for production use

#### 4.1 Fallback Strategies
```go
type FallbackChain struct {
    Primary   ModelTarget
    Secondary ModelTarget
    Emergency ModelTarget  // Could be cloud API
}
```

#### 4.2 Quality Gates
- Automatic quality assessment
- Retry with better models if quality is poor
- User feedback integration

#### 4.3 A/B Testing Framework
- Split traffic between models
- Compare performance metrics
- Optimize selections based on real usage

## 🛠 Implementation Details

### Directory Structure
```
qry/core/ai-hybrid/
├── README.md                 # This plan
├── backends/                 # AI backend implementations
│   ├── localai.go           # LocalAI backend
│   ├── ollama.go            # Ollama backend
│   └── interface.go         # Common interface
├── router/                  # Smart routing system
│   ├── analyzer.go          # Prompt analysis
│   ├── selector.go          # Model selection
│   └── router.go            # Main router
├── config/                  # Configuration management
│   ├── config.go            # Config loading
│   └── defaults.toml        # Default settings
├── metrics/                 # Performance tracking
│   ├── tracker.go           # Usage tracking
│   └── reporter.go          # Report generation
├── tools/                   # Updated tool implementations
│   ├── uroboro-smart.go     # Enhanced uroboro AI
│   ├── wherewasi-smart.go   # Enhanced wherewasi AI
│   └── qry-smart.go         # Enhanced qry AI
└── examples/                # Usage examples
    ├── basic-usage.go       # Simple examples
    └── advanced.go          # Complex scenarios
```

### Key Implementation Files

#### 1. Smart Router Core
```go
// router/router.go
type QRYSmartRouter struct {
    analyzer   *PromptAnalyzer
    selector   *ModelSelector
    backends   map[string]AIBackend
    metrics    *UsageTracker
    config     *RoutingConfig
}

func (r *QRYSmartRouter) Query(prompt string, options ...Option) (*Response, error) {
    // 1. Analyze prompt
    analysis := r.analyzer.Analyze(prompt)
    
    // 2. Select optimal model
    target := r.selector.SelectModel(analysis, r.config)
    
    // 3. Execute with fallback
    response, err := r.executeWithFallback(target, prompt)
    
    // 4. Track metrics
    r.metrics.Record(target, response, err)
    
    return response, err
}
```

#### 2. Backend Abstraction
```go
// backends/interface.go
type AIBackend interface {
    Name() string
    Query(model string, prompt string, config QueryConfig) (*Response, error)
    ListModels() ([]ModelInfo, error)
    IsModelAvailable(model string) bool
    HealthCheck() error
}
```

#### 3. Configuration System
```go
// config/config.go
type RoutingConfig struct {
    Strategy     string            `toml:"strategy"`
    Models       ModelConfig       `toml:"models"`
    Backends     BackendConfig     `toml:"backends"`
    Optimization OptimizationConfig `toml:"optimization"`
}
```

## 🎯 Migration Strategy

### Immediate Actions (This Week)
1. **Install Ollama alongside LocalAI**
   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   ollama pull orca-mini:3b
   ollama pull mistral:7b
   ollama pull codellama:7b
   ```

2. **Extract Smart Router from Backup**
   ```bash
   cp qry-backup-20250616/ai/experiments/local_ai_optimization_framework/tools/uroboro_smart_routing_starter.go \
      qry/core/ai-hybrid/router/
   ```

3. **Create Basic Hybrid Tool**
   ```bash
   # Start with a simple proof-of-concept
   cd qry/core/ai-hybrid
   go mod init ai-hybrid
   ```

### Gradual Transition
1. **Week 1**: Dual backend support, basic routing
2. **Week 2**: Smart prompt analysis, model selection
3. **Week 3**: Performance monitoring, optimization
4. **Week 4**: Advanced features, production readiness

### Validation Approach
- **Side-by-side testing** with current tools
- **Performance comparison** between backends
- **Cost tracking** to validate optimization
- **Quality assessment** to ensure no regression

## 💰 Expected Benefits

### Cost Optimization
- **Multi-model efficiency**: Use smallest model that works
- **Local processing**: Zero API costs for most tasks
- **Smart fallbacks**: Only use expensive models when needed
- **Target**: 80-90% cost reduction (matching backup goals)

### Performance Gains
- **Speed**: `orca-mini:3b` for immediate tasks (3s response)
- **Quality**: `llama2:13b` for complex work (25s response) 
- **Specialization**: `codellama:7b` for technical accuracy
- **Reliability**: Automatic fallbacks prevent failures

### Developer Experience
- **Transparent**: Same API, better backend selection
- **Configurable**: Tune routing to personal preferences
- **Observable**: Metrics and reports for optimization
- **Flexible**: Easy to add new models/backends

## 🔄 Next Steps

### Phase 1 Tasks (Week 1)
- [ ] Set up dual LocalAI + Ollama environment
- [ ] Extract smart router code from backup
- [ ] Create basic hybrid infrastructure
- [ ] Test both backends working together

### Phase 2 Tasks (Week 2)  
- [ ] Implement prompt analysis engine
- [ ] Add intelligent model selection
- [ ] Update existing tools with smart routing
- [ ] Validate routing decisions with test prompts

### Phase 3 Tasks (Week 3)
- [ ] Add performance monitoring
- [ ] Implement cost tracking
- [ ] Create optimization reports
- [ ] Fine-tune model selections

### Phase 4 Tasks (Week 4)
- [ ] Add advanced fallback strategies
- [ ] Implement quality gates
- [ ] Create A/B testing framework
- [ ] Document and finalize system

## 🎉 Success Metrics

### Technical Goals
- **Response Time**: < 5s for 80% of queries
- **Success Rate**: > 99% with fallbacks
- **Model Efficiency**: Right model for task 90% of time
- **System Uptime**: > 99.5% availability

### Business Goals  
- **Cost Reduction**: 80-90% vs current cloud AI spend
- **Quality Maintenance**: No regression in output quality
- **Productivity**: Same or better developer experience
- **Independence**: Reduced cloud AI dependency

### Measurable Outcomes
- **Weekly cost reports** showing savings
- **Response time distributions** by model
- **Quality scores** for different content types
- **Usage patterns** for optimization insights

---

**This hybrid approach combines the best of both worlds: LocalAI's unified API infrastructure with Ollama's sophisticated routing intelligence, creating a truly optimized local AI system for QRY.**
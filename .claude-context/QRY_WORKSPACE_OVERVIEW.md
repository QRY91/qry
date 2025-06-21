# QRY Workspace Context for Claude Code

**Purpose**: This file provides context for Claude Code about the QRY workspace structure and methodology.

## Workspace Structure

```
qry/
├── tools/              # CLI utilities (uroboro, wherewasi, examinator, qoins, doc-search)
├── experiments/        # Prototypes and early-stage projects
├── core/              # Orchestration, AI collaboration, scripts
├── zone/              # Main website (qry.zone)
├── content/           # Documentation, assets, logos
└── backups/           # System backups
```

## Active Tools

- **uroboro**: Work documentation and acknowledgment system (Go)
- **wherewasi**: Context generation for AI collaboration (Python)
- **examinator**: Offline study companion with spaced repetition (Python)
- **qoins**: Cost tracking and optimization (Shell)
- **doc-search**: Semantic search across workspace (Python + ChromaDB)

## QRY Methodology

**Query, Refine, Yield** - Systematic approach to tool building:
1. **Query**: Deep dive into real problems and systematic dysfunction
2. **Refine**: Build tools that work WITH human psychology
3. **Yield**: Deploy tools that solve problems and share what works

## Development Practices

- **Local-first**: Privacy-respecting, offline-capable tools
- **AI-collaborative**: Transparent AI assistance with human oversight
- **Systematic**: Document learning process, build reusable approaches
- **Honest**: Build useful things, not impressive-sounding projects

## Current Focus

- esp32_build

## AI Collaboration Context

The workspace includes systematic AI collaboration procedures in `core/ai/`.
Aider setup available in `core/aider-setup-optimization/` for terminal-based AI development.
This Claude Code integration complements the existing aider workflow.

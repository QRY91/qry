# QRY Virtual Workspace

My complete development environment and digital workshop.

## Structure

```
qry/
├── zone/               # Main website (qry.zone)
├── tools/              # CLI utilities and productivity tools
├── experiments/        # Prototypes and early-stage ideas
├── core/               # Orchestration, AI collaboration, scripts
├── content/            # Documentation, assets, logos
└── backups/            # System backups
```

## Active Tools

**CLI Utilities:**
- `uroboro` - Work documentation and acknowledgment system
- `wherewasi` - Context generation for AI collaboration
- `examinator` - Offline study companion with spaced repetition
- `qoins` - Cost tracking and optimization
- `doc-search` - Documentation search across the workspace

**Website:**
- `zone/` - Main public presence at [qry.zone](https://qry.zone)

## Getting Started

### Quick Setup (GitHub Clone)

```bash
# Clone the workspace
git clone https://github.com/QRY91/qry.git
cd qry

# Basic setup (tools only)
./setup-qry-workspace.sh

# Complete development environment
./setup-qry-workspace.sh --dev-env --ai-setup

# Start working
qry status
qry capture "Starting work on..."
```

### Manual Setup

```bash
# Install core tools
./core/install_tools.sh

# Set up AI collaboration environment
cd core/ai && ./setup.sh

# Start uroboro for work documentation
uroboro capture "Starting work on..."
```

## What This Is

This workspace represents my approach to systematic tool building - converting problems into useful software through local-first, privacy-respecting development.

The methodology (QRY: Query, Refine, Yield) focuses on understanding real problems, building tools that work with human psychology, and sharing what actually works.

For full context on the approach and philosophy, see [qry.zone](https://qry.zone).



---

**Status**: Active development workspace
**Last Restructure**: June 2025
**Focus**: Building useful tools, documenting what works, systematic knowledge ownership

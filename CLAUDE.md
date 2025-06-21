# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

QRY is a systematic tool-building workspace with the following key areas:

- **zone/** - Next.js website (qry.zone) - main public presence
- **tools/** - CLI utilities including uroboro, wherewasi, examinator, qoins
- **core/** - AI collaboration procedures, scripts, and orchestration
- **content/** - Documentation, assets, logos
- **experiments/** - Prototypes and early-stage ideas

## Essential Commands

### Website Development (zone/)
```bash
cd zone/
npm run dev          # Start development server
npm run build        # Build for production  
npm run start        # Start production server
npm run lint         # Run ESLint
```

### Go Tools Development (tools/uroboro, tools/wherewasi)
```bash
# For uroboro (comprehensive Makefile available)
cd tools/uroboro/
make help           # Show all available targets
make build          # Build binary
make test           # Run unit tests
make ci             # Run complete CI pipeline (verify + test-all)
make quick          # Quick cycle: format, test, build

# For wherewasi  
cd tools/wherewasi/
go build            # Build binary
go test ./...       # Run tests
```

### Workspace Setup
```bash
./setup-qry-workspace.sh              # Basic setup
./setup-qry-workspace.sh --dev-env    # Full development environment
```

## Architecture Overview

**QRY Methodology**: Query, Refine, Yield - systematic tool building focused on local-first, privacy-respecting development that works with human psychology.

**Key Tools Architecture**:
- **uroboro**: Work documentation and acknowledgment system (Go + SQLite)
- **wherewasi**: Context generation for AI collaboration (Go + SQLite) 
- **examinator**: Offline study companion with spaced repetition (Python)
- **qoins**: Cost tracking and optimization (Shell scripts + JSON)

**Website Architecture**:
- Next.js 14 with App Router
- TypeScript + React 18
- Custom components for article layouts and shader visuals
- PostHog analytics integration

## Development Practices

**AI Collaboration**: This workspace has systematic AI collaboration procedures documented in `core/ai/AI_COLLABORATION_PROCEDURE.md`. When working on AI-assisted development, follow the transparency and documentation principles outlined there.

**Testing Strategy**: 
- Go tools use comprehensive testing (unit + integration)
- Use `make ci` for uroboro to run full validation pipeline
- Next.js uses standard Jest/testing patterns

**Local-First Philosophy**: Tools prioritize local data storage (SQLite databases), offline functionality, and user data ownership.

## Working with Uroboro

Uroboro is the primary work documentation tool. Key commands:
```bash
uroboro capture "Starting work on X"    # Document work start
uroboro status --days 7                 # View recent activity
uroboro journey                          # Web interface for timeline view
```

Database location: `~/.local/share/uroboro/uroboro.sqlite`
Backups available in: `backups/uroboro/`

## Key Files to Reference

- `README.md` - Overall workspace structure and getting started
- `tools/uroboro/Makefile` - Comprehensive build/test targets for Go development
- `zone/package.json` - Website dependencies and scripts
- `core/ai/AI_COLLABORATION_PROCEDURE.md` - AI collaboration methodology
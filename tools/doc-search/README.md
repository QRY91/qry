# QRY Documentation Search 🔍

A semantic search system for the QRY repository's 899 markdown files across 165+ directories. Built with ChromaDB + Ollama for local-first, zero-cost document discovery.

## Overview

The QRY repository contains extensive documentation across multiple projects, methodologies, and experiments. With 899 markdown files spread across 165+ directories, finding relevant information becomes challenging. This tool provides semantic search capabilities to quickly locate documents based on meaning, not just keywords.

### Key Features

- **Semantic Search**: Find documents by meaning, not just exact keywords
- **Local-First**: No cloud dependencies, runs entirely offline
- **Fast**: ~50ms search responses with embedded vectors
- **Web Interface**: Beautiful, responsive search UI
- **CLI Tool**: Command-line interface for quick searches
- **Zero Cost**: No API fees, uses local Ollama embeddings

### Built On

- **ChromaDB**: Vector database for semantic search
- **Ollama**: Local LLM inference (nomic-embed-text model)
- **Flask**: Web interface
- **Python**: Core implementation

## Quick Start

### 1. Automated Setup

```bash
cd qry/tools/doc-search
./setup.sh
```

The setup script will:
- Install Python dependencies
- Check/install Ollama
- Download the embedding model
- Embed all QRY documentation
- Test the system

### 2. Manual Setup

If you prefer manual setup:

```bash
# Install dependencies
pip3 install -r requirements.txt

# Install and start Ollama
# macOS: brew install ollama
# Linux: curl -fsSL https://ollama.ai/install.sh | sh
ollama serve

# Download embedding model
ollama pull nomic-embed-text

# Embed documents (takes 10-15 minutes for 899 files)
python3 qry_doc_search.py embed

# Test the system
python3 qry_doc_search.py test
```

## Usage

### Web Interface (Recommended)

```bash
python3 web_demo.py
```

Visit http://localhost:5001 for the web interface.

### Command Line Interface

**Easy wrapper script (recommended):**
```bash
# Simple usage
./qry-search search "AI collaboration procedures"
./qry-search stats
./qry-search web
```

**Direct Python usage:**
```bash
# Activate virtual environment first
source venv/bin/activate

# Search documents
python qry_doc_search.py search "AI collaboration procedures"

# Get statistics
python qry_doc_search.py stats

# Test connections
python qry_doc_search.py test

# Reset embeddings
python qry_doc_search.py reset
```

## Example Searches

### Methodology & Processes
- `"AI collaboration procedures"`
- `"QRY methodology"`
- `"workflow optimization"`
- `"development processes"`

### Technical Implementation
- `"semantic search implementation"`
- `"ChromaDB integration"`
- `"local AI optimization"`
- `"vector embeddings"`

### Project-Specific
- `"PostHog integration strategy"`
- `"uroboro capture system"`
- `"arcade game development"`
- `"enterprise solutions"`

### Learning & Philosophy
- `"learning through failure"`
- `"professional development"`
- `"collaboration techniques"`
- `"systematic building"`

## Architecture

```
QRY Documentation Search
├── Document Discovery
│   ├── Scans all .md files in QRY repo
│   ├── Extracts metadata (path, size, dates)
│   └── Filters content for relevance
├── Embedding Generation
│   ├── Uses Ollama + nomic-embed-text
│   ├── 768-dimensional vectors per document
│   └── Stores in ChromaDB collection
├── Semantic Search
│   ├── Query embedding generation
│   ├── Vector similarity search
│   └── Relevance scoring & ranking
└── Interfaces
    ├── Web UI (Flask + responsive design)
    └── CLI tool (argparse + JSON output)
```

## Technical Details

### Storage Locations
- **ChromaDB**: `~/.local/share/qry-doc-search/chromadb/`
- **Embeddings**: Stored in ChromaDB collection "qry_docs"
- **Logs**: Console output with configurable levels

### Performance
- **Embedding Speed**: ~1-2 documents/second
- **Search Speed**: ~50ms per query
- **Memory Usage**: ~500MB for full collection
- **Disk Usage**: ~100MB for embeddings

### Document Processing
- **File Types**: `.md` files only
- **Exclusions**: Hidden directories, build folders
- **Metadata**: Path, directory, filename, size, modification date
- **Content**: Full markdown text with UTF-8 encoding

## Development

### Project Structure

```
qry/tools/doc-search/
├── qry_doc_search.py    # Core search system
├── web_demo.py          # Flask web interface  
├── requirements.txt     # Python dependencies
├── setup.sh            # Automated setup script
└── README.md           # This file
```

### Key Classes

- **QRYDocSearch**: Main search system class
- **Document Processing**: File discovery and content extraction
- **Embedding Pipeline**: Ollama integration and vector generation
- **Search Interface**: Query processing and result ranking

### Extension Points

- **Custom Filters**: Directory-specific search scoping
- **Result Formatting**: Enhanced preview generation
- **Metadata Extraction**: Additional document properties
- **Integration**: API endpoints for external tools

## Troubleshooting

### Common Issues

**"Ollama connection failed"**
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama if needed
ollama serve
```

**"Model not found"**
```bash
# Download the embedding model
ollama pull nomic-embed-text

# Verify model is available
ollama list
```

**"ChromaDB initialization failed"**
```bash
# Check permissions
ls -la ~/.local/share/qry-doc-search/

# Reinstall ChromaDB
pip3 uninstall chromadb
pip3 install chromadb
```

**"No documents found"**
```bash
# Check you're in the right directory
pwd  # Should be in qry/tools/doc-search or specify --qry-repo

# Verify QRY repository structure
ls ../../  # Should show ai/, labs/, tools/, etc.
```

### Performance Optimization

**Slow embedding**
- Ensure Ollama has sufficient RAM (4GB+)
- Use SSD storage for ChromaDB
- Close other applications during embedding

**Search latency**
- ChromaDB automatically optimizes for query performance
- Consider limiting result count for faster responses
- Use directory filters to scope searches

## Integration with QRY Methodology

This tool embodies several QRY principles:

- **Query-Driven**: Built to solve the specific problem of document discovery
- **Refine-First**: Iteratively improved based on usage patterns  
- **Yield-Focused**: Practical tool that immediately provides value
- **Learning-Oriented**: Facilitates knowledge discovery and connection
- **Systematic**: Methodical approach to information organization

## Contributing

### Adding Features

1. **New Search Filters**: Modify `semantic_search()` method
2. **Enhanced UI**: Update web interface templates
3. **Additional Metadata**: Extend document processing pipeline
4. **Export Capabilities**: Add result export functionality

### Testing

```bash
# Test core functionality
python3 qry_doc_search.py test

# Test with sample queries
python3 qry_doc_search.py search "test query"

# Verify web interface
python3 web_demo.py
# Visit http://localhost:5001
```

## Future Enhancements

- **Cross-Reference Detection**: Find related documents automatically
- **Trend Analysis**: Track documentation evolution over time
- **Content Summarization**: Generate document summaries
- **Integration APIs**: Connect with other QRY tools
- **Advanced Filters**: Date ranges, file types, project scoping
- **Batch Operations**: Bulk document processing capabilities

## Related Projects

- **Uroboro AI**: Original semantic search implementation for development captures
- **QRY Methodology**: Systematic approach to Query → Refine → Yield
- **Local AI Optimization**: Framework for cost-effective AI deployment

---

**Status**: Production Ready  
**Last Updated**: June 2025  
**Maintainer**: QRY Team  

*This tool demonstrates rapid prototyping velocity - from concept to working system in hours, not days.*
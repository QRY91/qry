#!/bin/bash

# QRY Documentation Search Setup Script
# Sets up the semantic search system for QRY repository documentation

set -e  # Exit on any error

echo "🔍 QRY Documentation Search Setup"
echo "=================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [[ ! -f "qry_doc_search.py" ]]; then
    log_error "Please run this script from the qry/tools/doc-search directory"
    exit 1
fi

# Step 1: Check Python
log_info "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    log_error "Python 3 is required but not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
log_success "Python $PYTHON_VERSION found"

# Step 2: Check pip
if ! command -v pip3 &> /dev/null; then
    log_error "pip3 is required but not installed"
    exit 1
fi

# Step 3: Create virtual environment and install dependencies
log_info "Creating virtual environment..."
if python3 -m venv venv; then
    log_success "Virtual environment created"
else
    log_error "Failed to create virtual environment"
    exit 1
fi

log_info "Installing Python dependencies in virtual environment..."
if source venv/bin/activate && pip install -r requirements.txt; then
    log_success "Python dependencies installed"
else
    log_error "Failed to install Python dependencies"
    exit 1
fi

# Step 4: Check Ollama
log_info "Checking Ollama installation..."
if ! command -v ollama &> /dev/null; then
    log_warning "Ollama not found in PATH"
    echo
    echo "Please install Ollama first:"
    echo "  macOS: brew install ollama"
    echo "  Linux: curl -fsSL https://ollama.ai/install.sh | sh"
    echo "  Or visit: https://ollama.ai/download"
    echo
    read -p "Press Enter when Ollama is installed and running..."
fi

# Step 5: Check if Ollama is running
log_info "Checking if Ollama is running..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    log_success "Ollama is running"
else
    log_warning "Ollama doesn't seem to be running"
    echo
    echo "Please start Ollama:"
    echo "  ollama serve"
    echo
    echo "Then run this script again."
    exit 1
fi

# Step 6: Check for embedding model
log_info "Checking for nomic-embed-text model..."
if ollama list | grep -q "nomic-embed-text"; then
    log_success "nomic-embed-text model found"
else
    log_info "Downloading nomic-embed-text model (this may take a few minutes)..."
    if ollama pull nomic-embed-text; then
        log_success "nomic-embed-text model downloaded"
    else
        log_error "Failed to download embedding model"
        exit 1
    fi
fi

# Step 7: Test the search system
log_info "Testing search system connection..."
if source venv/bin/activate && python qry_doc_search.py test > /dev/null 2>&1; then
    log_success "Search system connection test passed"
else
    log_warning "Search system connection test failed, but continuing..."
fi

# Step 8: Check if embeddings exist
log_info "Checking for existing embeddings..."
EMBED_COUNT=$(source venv/bin/activate && python -c "
from qry_doc_search import QRYDocSearch
try:
    searcher = QRYDocSearch()
    stats = searcher.get_stats()
    print(stats['total_documents'])
except:
    print(0)
" 2>/dev/null || echo "0")

if [[ "$EMBED_COUNT" -gt "0" ]]; then
    log_success "Found $EMBED_COUNT existing embedded documents"
    echo
    read -p "Rebuild embeddings? This will take several minutes. (y/N): " rebuild
    if [[ "$rebuild" =~ ^[Yy]$ ]]; then
        FORCE_REBUILD="--force"
    else
        FORCE_REBUILD=""
    fi
else
    log_info "No existing embeddings found, will create them"
    FORCE_REBUILD=""
fi

# Step 9: Embed documents
if [[ "$EMBED_COUNT" -eq "0" ]] || [[ -n "$FORCE_REBUILD" ]]; then
    log_info "Embedding QRY documentation (this will take several minutes)..."
    echo "📚 Processing approximately 673 markdown files..."

    if source venv/bin/activate && python qry_doc_search.py embed $FORCE_REBUILD; then
        log_success "Document embedding complete!"
    else
        log_error "Document embedding failed"
        exit 1
    fi
fi

# Step 10: Final check
log_info "Running final system check..."
FINAL_COUNT=$(source venv/bin/activate && python -c "
from qry_doc_search import QRYDocSearch
try:
    searcher = QRYDocSearch()
    stats = searcher.get_stats()
    print(stats['total_documents'])
except Exception as e:
    print(f'Error: {e}')
    exit(1)
")

if [[ "$FINAL_COUNT" =~ ^[0-9]+$ ]] && [[ "$FINAL_COUNT" -gt "0" ]]; then
    log_success "Setup complete! $FINAL_COUNT documents ready for search."
else
    log_error "Setup validation failed: $FINAL_COUNT"
    exit 1
fi

# Step 11: Usage instructions
echo
echo "🎉 QRY Documentation Search is ready!"
echo "===================================="
echo
echo "💻 Command Line Usage:"
echo "  source venv/bin/activate"
echo "  python qry_doc_search.py search 'your query here'"
echo "  python qry_doc_search.py stats"
echo
echo "🌐 Web Interface:"
echo "  source venv/bin/activate"
echo "  python web_demo.py"
echo "  Then visit: http://localhost:5001"
echo
echo "🔍 Example Searches:"
echo "  • 'AI collaboration procedures'"
echo "  • 'PostHog integration strategy'"
echo "  • 'semantic search implementation'"
echo "  • 'uroboro capture system'"
echo "  • 'local AI optimization'"
echo
echo "📊 Quick Stats:"
source venv/bin/activate && python qry_doc_search.py stats | grep -E "(total_documents|directories)" || true
echo
log_success "Setup completed successfully!"

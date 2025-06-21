#!/usr/bin/env python3
"""
QRY Documentation Search Web Demo

A Flask web interface for semantic search across QRY documentation.
Based on the successful uroboro capture search demo.
"""

import os
import json
from flask import Flask, render_template_string, request, jsonify
from qry_doc_search import QRYDocSearch

app = Flask(__name__)

# Initialize the search system
searcher = None

def init_searcher():
    """Initialize the QRY doc search system."""
    global searcher
    if searcher is None:
        # Try to find QRY repo path (assume we're in qry/tools/doc-search)
        current_dir = os.path.dirname(os.path.abspath(__file__))
        qry_repo_path = os.path.dirname(os.path.dirname(current_dir))  # Go up two levels

        searcher = QRYDocSearch(qry_repo_path=qry_repo_path)
    return searcher

# HTML Template
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QRY Documentation Search</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #eee;
            padding-bottom: 20px;
        }

        .header h1 {
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 2.5em;
            font-weight: 300;
        }

        .header p {
            color: #7f8c8d;
            font-size: 1.1em;
        }

        .search-container {
            margin-bottom: 30px;
        }

        .search-box {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        #searchInput {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid #ddd;
            border-radius: 50px;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease;
        }

        #searchInput:focus {
            border-color: #667eea;
            box-shadow: 0 0 15px rgba(102, 126, 234, 0.2);
        }

        .search-btn {
            padding: 15px 30px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            min-width: 120px;
        }

        .search-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .search-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .controls {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }

        .control-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .control-group label {
            font-weight: 500;
            color: #555;
        }

        .control-group input, .control-group select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
        }

        .stats-container {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .stat-item {
            text-align: center;
            padding: 15px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
            display: block;
        }

        .stat-label {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        }

        .results-container {
            margin-top: 30px;
        }

        .result-item {
            background: white;
            border-left: 4px solid #667eea;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }

        .result-item:hover {
            transform: translateX(5px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }

        .result-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 10px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .result-title {
            font-weight: bold;
            color: #2c3e50;
            font-size: 1.1em;
            flex: 1;
        }

        .result-similarity {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 500;
        }

        .result-path {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 10px;
            font-family: 'Courier New', monospace;
            background: #f8f9fa;
            padding: 5px 10px;
            border-radius: 5px;
        }

        .result-preview {
            color: #555;
            line-height: 1.6;
            margin-bottom: 10px;
        }

        .result-meta {
            display: flex;
            gap: 15px;
            font-size: 0.85em;
            color: #888;
            flex-wrap: wrap;
        }

        .loading {
            text-align: center;
            padding: 40px;
            color: #666;
        }

        .loading::after {
            content: '';
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 2px solid #ddd;
            border-top: 2px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .error {
            background: #ffe6e6;
            border: 1px solid #ff9999;
            color: #cc0000;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
        }

        .no-results {
            text-align: center;
            padding: 40px;
            color: #666;
            background: #f8f9fa;
            border-radius: 10px;
        }

        @media (max-width: 768px) {
            .container {
                padding: 20px;
                margin: 10px;
            }

            .header h1 {
                font-size: 2em;
            }

            .search-box {
                flex-direction: column;
            }

            .controls {
                justify-content: center;
            }

            .stats-container {
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            }

            .result-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔍 QRY Documentation Search</h1>
            <p>Semantic search across {{ stats.total_documents }} documentation files</p>
        </div>

        <div class="stats-container">
            <div class="stat-item">
                <span class="stat-value">{{ stats.total_documents }}</span>
                <div class="stat-label">Total Documents</div>
            </div>
            <div class="stat-item">
                <span class="stat-value">{{ stats.directories }}</span>
                <div class="stat-label">Directories</div>
            </div>
            <div class="stat-item">
                <span class="stat-value">{{ stats.embedding_model }}</span>
                <div class="stat-label">AI Model</div>
            </div>
        </div>

        <div class="search-container">
            <div class="search-box">
                <input type="text" id="searchInput" placeholder="Search QRY documentation... (e.g., 'AI collaboration procedures', 'PostHog integration', 'semantic search')" />
                <button class="search-btn" onclick="performSearch()">Search</button>
            </div>

            <div class="controls">
                <div class="control-group">
                    <label for="limitSelect">Results:</label>
                    <select id="limitSelect">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                </div>
                <div class="control-group">
                    <label for="showContent">
                        <input type="checkbox" id="showContent"> Show full content
                    </label>
                </div>
            </div>
        </div>

        <div id="resultsContainer" class="results-container"></div>
    </div>

    <script>
        // Global state
        let isSearching = false;

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');

            // Enter key support
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter' && !isSearching) {
                    performSearch();
                }
            });

            // Auto-focus search input
            searchInput.focus();
        });

        async function performSearch() {
            if (isSearching) return;

            const query = document.getElementById('searchInput').value.trim();
            if (!query) {
                showError('Please enter a search query');
                return;
            }

            isSearching = true;
            const searchBtn = document.querySelector('.search-btn');
            const resultsContainer = document.getElementById('resultsContainer');

            // Update UI
            searchBtn.textContent = 'Searching...';
            searchBtn.disabled = true;
            resultsContainer.innerHTML = '<div class="loading">Searching QRY documentation...</div>';

            try {
                const limit = document.getElementById('limitSelect').value;
                const showContent = document.getElementById('showContent').checked;

                const response = await fetch('/api/search', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        query: query,
                        limit: parseInt(limit),
                        show_content: showContent
                    })
                });

                if (!response.ok) {
                    throw new Error(`Search failed: ${response.status}`);
                }

                const data = await response.json();
                displayResults(data.results, query);

            } catch (error) {
                showError(`Search failed: ${error.message}`);
            } finally {
                isSearching = false;
                searchBtn.textContent = 'Search';
                searchBtn.disabled = false;
            }
        }

        function displayResults(results, query) {
            const resultsContainer = document.getElementById('resultsContainer');
            const showContent = document.getElementById('showContent').checked;

            if (!results || results.length === 0) {
                resultsContainer.innerHTML = `
                    <div class="no-results">
                        <h3>No results found</h3>
                        <p>Try different keywords or check the spelling of your query: "${query}"</p>
                    </div>
                `;
                return;
            }

            let html = `<h3>Found ${results.length} results for "${query}"</h3>`;

            results.forEach((result, index) => {
                const similarity = (result.similarity * 100).toFixed(1);
                const directory = result.directory || 'root';

                html += `
                    <div class="result-item">
                        <div class="result-header">
                            <div class="result-title">${escapeHtml(result.filename)}</div>
                            <div class="result-similarity">${similarity}% match</div>
                        </div>

                        <div class="result-path">${escapeHtml(result.file_path)}</div>

                        <div class="result-preview">
                            ${escapeHtml(showContent ? result.content : result.preview)}
                        </div>

                        <div class="result-meta">
                            <span>📁 ${escapeHtml(directory)}</span>
                            <span>📄 ${result.metadata.size} chars</span>
                            <span>🕒 ${formatDate(result.metadata.modified)}</span>
                        </div>
                    </div>
                `;
            });

            resultsContainer.innerHTML = html;
        }

        function showError(message) {
            const resultsContainer = document.getElementById('resultsContainer');
            resultsContainer.innerHTML = `<div class="error">${escapeHtml(message)}</div>`;
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function formatDate(dateString) {
            try {
                const date = new Date(dateString);
                return date.toLocaleDateString();
            } catch {
                return dateString;
            }
        }

        // Example searches
        function searchExample(query) {
            document.getElementById('searchInput').value = query;
            performSearch();
        }
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    """Main search interface."""
    try:
        searcher = init_searcher()
        stats = searcher.get_stats()
        return render_template_string(HTML_TEMPLATE, stats=stats)
    except Exception as e:
        return f"Error initializing search system: {e}", 500

@app.route('/api/search', methods=['POST'])
def api_search():
    """API endpoint for semantic search."""
    try:
        searcher = init_searcher()
        data = request.get_json()

        query = data.get('query', '').strip()
        limit = data.get('limit', 10)
        show_content = data.get('show_content', False)

        if not query:
            return jsonify({'error': 'Query is required'}), 400

        # Perform search
        results = searcher.semantic_search(query, limit=limit)

        # Format results for API
        formatted_results = []
        for result in results:
            formatted_result = {
                'doc_id': result['doc_id'],
                'file_path': result['file_path'],
                'filename': result['filename'],
                'directory': result['directory'],
                'similarity': result['similarity'],
                'preview': result['preview'],
                'metadata': result['metadata']
            }

            if show_content:
                formatted_result['content'] = result['content']

            formatted_results.append(formatted_result)

        return jsonify({
            'query': query,
            'results': formatted_results,
            'count': len(formatted_results),
            'limit': limit
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats')
def api_stats():
    """API endpoint for collection statistics."""
    try:
        searcher = init_searcher()
        stats = searcher.get_stats()
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    """Health check endpoint."""
    try:
        searcher = init_searcher()
        status = searcher.test_connection()
        return jsonify({
            'status': 'healthy' if status['ollama'] and status['chromadb'] else 'unhealthy',
            'details': status
        })
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 500

if __name__ == '__main__':
    print("🔍 Starting QRY Documentation Search Server...")
    print("📍 Make sure you have:")
    print("   - Ollama running with nomic-embed-text model")
    print("   - ChromaDB Python package installed")
    print("   - Run embedding first: python qry_doc_search.py embed")
    print()
    print("🌐 Web interface will be available at: http://localhost:5001")
    print()

    app.run(host='0.0.0.0', port=5001, debug=True)

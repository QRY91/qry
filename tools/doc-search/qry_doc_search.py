#!/usr/bin/env python3
"""
QRY Documentation Semantic Search System

A semantic search system for the QRY repository's 600+ markdown files.
Uses ChromaDB + Ollama embeddings for local-first document discovery.

Based on the uroboro AI capture search system.
"""

import os
import sqlite3
import logging
import requests
import json
import hashlib
from pathlib import Path
from typing import List, Dict, Any, Optional
from datetime import datetime

try:
    import chromadb
    from chromadb.config import Settings
except ImportError:
    raise ImportError("ChromaDB not installed. Run: pip install chromadb")


class QRYDocSearch:
    """QRY Documentation Semantic Search using ChromaDB + Ollama."""

    def __init__(self,
                 qry_repo_path: str = None,
                 chroma_db_path: str = None,
                 ollama_url: str = "http://localhost:11434",
                 embed_model: str = "nomic-embed-text"):
        """Initialize the QRY doc search system.

        Args:
            qry_repo_path: Path to QRY repository root
            chroma_db_path: Path to ChromaDB storage directory
            ollama_url: URL for Ollama API
            embed_model: Embedding model to use
        """
        # Set up paths
        home_dir = os.path.expanduser("~")
        if qry_repo_path is None:
            # Auto-detect QRY repo root (assume we're in qry/tools/doc-search)
            current_dir = os.path.dirname(os.path.abspath(__file__))
            self.qry_repo_path = os.path.dirname(os.path.dirname(current_dir))
        else:
            self.qry_repo_path = qry_repo_path
        self.chroma_db_path = chroma_db_path or os.path.join(
            home_dir, ".local/share/qry-doc-search/chromadb"
        )

        # Ollama configuration
        self.ollama_url = ollama_url
        self.embed_model = embed_model

        # Set up logging
        self.logger = self._setup_logging()

        # Initialize ChromaDB
        self.chroma_client = None
        self.collection = None
        self._init_chromadb()

    def _setup_logging(self) -> logging.Logger:
        """Set up logging configuration."""
        logger = logging.getLogger("qry_doc_search")
        logger.setLevel(logging.INFO)

        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)

        return logger

    def _init_chromadb(self):
        """Initialize ChromaDB client and collection."""
        try:
            # Ensure ChromaDB directory exists
            os.makedirs(self.chroma_db_path, exist_ok=True)

            # Initialize ChromaDB client
            self.chroma_client = chromadb.PersistentClient(
                path=self.chroma_db_path,
                settings=Settings(
                    anonymized_telemetry=False,
                    allow_reset=True
                )
            )

            # Get or create collection
            self.collection = self.chroma_client.get_or_create_collection(
                name="qry_docs",
                metadata={"description": "QRY documentation semantic search"}
            )

            self.logger.info(f"ChromaDB initialized at: {self.chroma_db_path}")

        except Exception as e:
            self.logger.error(f"Failed to initialize ChromaDB: {e}")
            raise

    def get_ollama_embedding(self, text: str) -> List[float]:
        """Get embedding for text using Ollama."""
        try:
            response = requests.post(
                f"{self.ollama_url}/api/embeddings",
                json={
                    "model": self.embed_model,
                    "prompt": text
                },
                timeout=30
            )
            response.raise_for_status()
            embedding = response.json()["embedding"]

            self.logger.debug(f"Generated embedding for text ({len(text)} chars)")
            return embedding

        except requests.exceptions.RequestException as e:
            self.logger.error(f"Ollama API request failed: {e}")
            raise
        except KeyError as e:
            self.logger.error(f"Unexpected Ollama API response format: {e}")
            raise

    def find_markdown_files(self) -> List[Dict[str, Any]]:
        """Find all markdown files in the QRY repository."""
        markdown_files = []

        # Walk through the repository
        for root, dirs, files in os.walk(self.qry_repo_path):
            # Skip hidden directories and common build/cache directories
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['node_modules', '__pycache__', 'venv', '.git']]

            for file in files:
                if file.endswith('.md'):
                    file_path = os.path.join(root, file)
                    relative_path = os.path.relpath(file_path, self.qry_repo_path)

                    try:
                        # Get file stats
                        stat = os.stat(file_path)
                        modified_time = datetime.fromtimestamp(stat.st_mtime)

                        # Read file content
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            content = f.read()

                        # Create document info
                        doc_info = {
                            'file_path': relative_path,
                            'full_path': file_path,
                            'content': content,
                            'size': len(content),
                            'modified': modified_time.isoformat(),
                            'directory': os.path.dirname(relative_path),
                            'filename': file,
                            'doc_id': hashlib.md5(relative_path.encode()).hexdigest()
                        }

                        markdown_files.append(doc_info)

                    except Exception as e:
                        self.logger.warning(f"Failed to process {relative_path}: {e}")
                        continue

        self.logger.info(f"Found {len(markdown_files)} markdown files")
        return markdown_files

    def embed_document(self, doc_info: Dict[str, Any]) -> bool:
        """Embed a single document."""
        try:
            doc_id = doc_info['doc_id']
            content = doc_info['content']

            # Skip empty files
            if not content.strip():
                self.logger.debug(f"Skipping empty file: {doc_info['file_path']}")
                return False

            # Generate embedding
            embedding = self.get_ollama_embedding(content)

            # Prepare metadata
            metadata = {
                'file_path': doc_info['file_path'],
                'directory': doc_info['directory'],
                'filename': doc_info['filename'],
                'size': doc_info['size'],
                'modified': doc_info['modified']
            }

            # Add to ChromaDB
            self.collection.add(
                embeddings=[embedding],
                documents=[content],
                ids=[doc_id],
                metadatas=[metadata]
            )

            self.logger.debug(f"Embedded: {doc_info['file_path']}")
            return True

        except Exception as e:
            self.logger.error(f"Failed to embed {doc_info.get('file_path', 'unknown')}: {e}")
            return False

    def embed_all_documents(self, force_rebuild: bool = False) -> Dict[str, Any]:
        """Embed all markdown documents in the repository."""
        try:
            # Check if we need to rebuild
            collection_count = self.collection.count()
            if collection_count > 0 and not force_rebuild:
                self.logger.info(f"Collection already has {collection_count} documents. Use force_rebuild=True to rebuild.")
                return {"status": "skipped", "count": collection_count}

            if force_rebuild and collection_count > 0:
                self.logger.info("Force rebuild requested, clearing existing collection...")
                self.collection.delete(where={})

            # Find all markdown files
            documents = self.find_markdown_files()

            if not documents:
                self.logger.warning("No markdown files found!")
                return {"status": "no_files", "count": 0}

            # Embed documents
            success_count = 0
            failed_count = 0

            for i, doc_info in enumerate(documents, 1):
                self.logger.info(f"Embedding {i}/{len(documents)}: {doc_info['file_path']}")

                if self.embed_document(doc_info):
                    success_count += 1
                else:
                    failed_count += 1

            result = {
                "status": "completed",
                "total_files": len(documents),
                "embedded": success_count,
                "failed": failed_count,
                "success_rate": success_count / len(documents) if documents else 0
            }

            self.logger.info(f"Embedding complete: {success_count}/{len(documents)} files embedded")
            return result

        except Exception as e:
            self.logger.error(f"Failed to embed documents: {e}")
            raise

    def semantic_search(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Perform semantic search across embedded documents.

        Args:
            query: Search query
            limit: Maximum number of results to return

        Returns:
            List of search results with similarity scores
        """
        try:
            # Get embedding for query
            query_embedding = self.get_ollama_embedding(query)

            # Search in ChromaDB
            results = self.collection.query(
                query_embeddings=[query_embedding],
                n_results=limit,
                include=["documents", "metadatas", "distances"]
            )

            # Format results
            search_results = []
            for i in range(len(results["ids"][0])):
                # Get content preview (first 200 chars)
                content = results["documents"][0][i]
                preview = content[:200] + "..." if len(content) > 200 else content

                result = {
                    "doc_id": results["ids"][0][i],
                    "file_path": results["metadatas"][0][i]["file_path"],
                    "filename": results["metadatas"][0][i]["filename"],
                    "directory": results["metadatas"][0][i]["directory"],
                    "similarity": 1 - results["distances"][0][i],  # Convert distance to similarity
                    "distance": results["distances"][0][i],
                    "preview": preview,
                    "content": content,
                    "metadata": results["metadatas"][0][i]
                }
                search_results.append(result)

            self.logger.info(f"Found {len(search_results)} results for query: '{query}'")
            return search_results

        except Exception as e:
            self.logger.error(f"Semantic search failed: {e}")
            raise

    def get_stats(self) -> Dict[str, Any]:
        """Get statistics about the document collection."""
        try:
            collection_count = self.collection.count()

            # Get directory breakdown if we have documents
            directory_stats = {}
            if collection_count > 0:
                # Query all documents to get metadata
                all_docs = self.collection.get(include=["metadatas"])

                for metadata in all_docs["metadatas"]:
                    directory = metadata.get("directory", "root")
                    directory_stats[directory] = directory_stats.get(directory, 0) + 1

            stats = {
                "total_documents": collection_count,
                "directories": len(directory_stats),
                "directory_breakdown": directory_stats,
                "embedding_model": self.embed_model,
                "chroma_db_path": self.chroma_db_path,
                "qry_repo_path": self.qry_repo_path
            }

            return stats

        except Exception as e:
            self.logger.error(f"Failed to get stats: {e}")
            raise

    def test_connection(self) -> Dict[str, Any]:
        """Test Ollama and ChromaDB connections."""
        status = {
            "ollama": False,
            "chromadb": False,
            "embedding_model": self.embed_model
        }

        # Test Ollama
        try:
            response = requests.get(f"{self.ollama_url}/api/tags", timeout=5)
            response.raise_for_status()
            status["ollama"] = True

            # Check if our embedding model is available
            models = response.json().get("models", [])
            model_names = [m.get("name", "") for m in models]
            status["model_available"] = any(self.embed_model in name for name in model_names)

        except Exception as e:
            self.logger.error(f"Ollama connection failed: {e}")
            status["ollama_error"] = str(e)

        # Test ChromaDB
        try:
            collection_count = self.collection.count()
            status["chromadb"] = True
            status["document_count"] = collection_count

        except Exception as e:
            self.logger.error(f"ChromaDB connection failed: {e}")
            status["chromadb_error"] = str(e)

        return status

    def reset_collection(self):
        """Reset the document collection (delete all embeddings)."""
        try:
            self.collection.delete(where={})
            self.logger.info("Collection reset complete")

        except Exception as e:
            self.logger.error(f"Failed to reset collection: {e}")
            raise


def main():
    """Main CLI interface for QRY doc search."""
    import argparse

    parser = argparse.ArgumentParser(description="QRY Documentation Semantic Search")
    parser.add_argument("--qry-repo", help="Path to QRY repository")
    parser.add_argument("--chroma-db", help="Path to ChromaDB storage")
    parser.add_argument("--ollama-url", default="http://localhost:11434", help="Ollama API URL")
    parser.add_argument("--embed-model", default="nomic-embed-text", help="Embedding model")

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Embed command
    embed_parser = subparsers.add_parser("embed", help="Embed all documents")
    embed_parser.add_argument("--force", action="store_true", help="Force rebuild of embeddings")

    # Search command
    search_parser = subparsers.add_parser("search", help="Search documents")
    search_parser.add_argument("query", help="Search query")
    search_parser.add_argument("--limit", type=int, default=10, help="Max results")
    search_parser.add_argument("--show-content", action="store_true", help="Show full content")

    # Stats command
    subparsers.add_parser("stats", help="Show collection statistics")

    # Test command
    subparsers.add_parser("test", help="Test connections")

    # Reset command
    subparsers.add_parser("reset", help="Reset collection")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    # Initialize search system
    searcher = QRYDocSearch(
        qry_repo_path=args.qry_repo,
        chroma_db_path=args.chroma_db,
        ollama_url=args.ollama_url,
        embed_model=args.embed_model
    )

    try:
        if args.command == "embed":
            print("Embedding documents...")
            result = searcher.embed_all_documents(force_rebuild=args.force)
            print(f"Result: {json.dumps(result, indent=2)}")

        elif args.command == "search":
            print(f"Searching for: '{args.query}'")
            results = searcher.semantic_search(args.query, limit=args.limit)

            for i, result in enumerate(results, 1):
                print(f"\n--- Result {i} (similarity: {result['similarity']:.3f}) ---")
                print(f"File: {result['file_path']}")
                print(f"Directory: {result['directory']}")

                if args.show_content:
                    print(f"Content:\n{result['content'][:500]}...")
                else:
                    print(f"Preview: {result['preview']}")

            if not results:
                print("No results found.")

        elif args.command == "stats":
            stats = searcher.get_stats()
            print(json.dumps(stats, indent=2))

        elif args.command == "test":
            status = searcher.test_connection()
            print(json.dumps(status, indent=2))

        elif args.command == "reset":
            confirm = input("This will delete all embeddings. Continue? (y/N): ")
            if confirm.lower() == 'y':
                searcher.reset_collection()
                print("Collection reset complete.")
            else:
                print("Reset cancelled.")

    except KeyboardInterrupt:
        print("\nOperation cancelled.")
    except Exception as e:
        print(f"Error: {e}")
        raise


if __name__ == "__main__":
    main()

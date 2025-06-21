#!/usr/bin/env python3
"""
Sphinx Riddle Generator

Analyzes a codebase and generates sphinx-style riddles to test deep understanding.
Uses local AI to create personalized challenges for each project.

Usage:
    python sphinx.py /path/to/project
    python sphinx.py /path/to/project --model mistral:7b --output riddles.md
"""

import argparse
import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Optional

SPHINX_PROMPT = """You are the Sphinx. Generate riddles to test deep understanding of a software project.

Project: {project_name}
Languages: {languages}
Key files: {key_files}

README excerpt:
{readme}

Generate exactly 3 riddles using this EXACT format:

### Riddle I: [Title]
*"[Question in quotes]"*

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

**Proof of Understanding**: [Demonstration requirement]

### Riddle II: [Title]
*"[Question in quotes]"*

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

**Proof of Understanding**: [Demonstration requirement]

### Riddle III: [Title]
*"[Question in quotes]"*

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

**Proof of Understanding**: [Demonstration requirement]

Focus on: core architecture, dependencies, and rebuild-from-scratch challenges."""

class SphinxGenerator:
    def __init__(self, model: str = "mistral:7b"):
        self.model = model

    def scan_project(self, project_path: Path) -> Dict:
        """Scan project directory and extract key information"""
        project_info = {
            "name": project_path.name,
            "path": str(project_path),
            "structure": {},
            "readme": "",
            "languages": set(),
            "key_files": []
        }

        # Get directory structure
        project_info["structure"] = self._get_directory_structure(project_path)

        # Read README if exists
        readme_files = ["README.md", "README.txt", "README.rst", "README"]
        for readme_name in readme_files:
            readme_path = project_path / readme_name
            if readme_path.exists():
                try:
                    project_info["readme"] = readme_path.read_text(encoding='utf-8')
                    break
                except Exception as e:
                    print(f"Warning: Could not read {readme_path}: {e}")

        # Detect languages and key files
        project_info["languages"], project_info["key_files"] = self._analyze_files(project_path)

        return project_info

    def _get_directory_structure(self, path: Path, max_depth: int = 3, current_depth: int = 0) -> Dict:
        """Get a simplified directory structure"""
        if current_depth > max_depth:
            return {}

        structure = {}
        try:
            for item in path.iterdir():
                if item.name.startswith('.'):
                    continue

                if item.is_dir():
                    structure[f"{item.name}/"] = self._get_directory_structure(
                        item, max_depth, current_depth + 1
                    )
                else:
                    structure[item.name] = "file"
        except PermissionError:
            structure["<permission_denied>"] = "error"

        return structure

    def _analyze_files(self, path: Path) -> tuple[set, list]:
        """Analyze files to detect languages and find key files"""
        languages = set()
        key_files = []

        # File extension to language mapping
        ext_map = {
            '.py': 'Python',
            '.js': 'JavaScript',
            '.ts': 'TypeScript',
            '.go': 'Go',
            '.rs': 'Rust',
            '.c': 'C',
            '.cpp': 'C++',
            '.java': 'Java',
            '.rb': 'Ruby',
            '.php': 'PHP',
            '.sh': 'Shell',
            '.yml': 'YAML',
            '.yaml': 'YAML',
            '.json': 'JSON',
            '.toml': 'TOML',
            '.sql': 'SQL'
        }

        # Key files to always include
        key_file_names = {
            'Makefile', 'Dockerfile', 'docker-compose.yml',
            'package.json', 'Cargo.toml', 'go.mod',
            'requirements.txt', 'setup.py', 'main.py',
            'main.go', 'main.rs', 'index.js', 'app.py'
        }

        try:
            for file_path in path.rglob('*'):
                if file_path.is_file() and not any(part.startswith('.') for part in file_path.parts):
                    # Detect language
                    suffix = file_path.suffix.lower()
                    if suffix in ext_map:
                        languages.add(ext_map[suffix])

                    # Check if it's a key file
                    if file_path.name in key_file_names:
                        key_files.append(str(file_path.relative_to(path)))

        except Exception as e:
            print(f"Warning: Error analyzing files: {e}")

        return languages, key_files

    def _read_key_files(self, project_path: Path, key_files: List[str]) -> Dict[str, str]:
        """Read contents of key files"""
        file_contents = {}

        for file_path in key_files[:5]:  # Limit to first 5 key files
            full_path = project_path / file_path
            try:
                if full_path.stat().st_size < 10000:  # Only read files < 10KB
                    content = full_path.read_text(encoding='utf-8', errors='ignore')
                    file_contents[file_path] = content[:2000]  # Truncate to 2KB
            except Exception as e:
                print(f"Warning: Could not read {file_path}: {e}")

        return file_contents

    def generate_riddles(self, project_path: Path) -> str:
        """Generate sphinx riddles for the given project"""
        print(f"🔍 Scanning project: {project_path}")

        # Scan project
        project_info = self.scan_project(project_path)

        # Read key file contents
        file_contents = self._read_key_files(project_path, project_info["key_files"])

        # Prepare simplified project information for AI
        languages_str = ", ".join(list(project_info["languages"])) or "Unknown"
        key_files_str = ", ".join(project_info["key_files"][:5]) or "No key files found"
        readme_excerpt = project_info["readme"][:800] if project_info["readme"] else "No README found"

        print(f"📊 Detected languages: {languages_str}")
        print(f"🔑 Key files found: {len(project_info['key_files'])}")

        # Generate riddles using local AI
        print(f"🤖 Generating riddles with {self.model}...")

        prompt = SPHINX_PROMPT.format(
            project_name=project_info["name"],
            languages=languages_str,
            key_files=key_files_str,
            readme=readme_excerpt
        )

        try:
            riddles = self._call_ollama(prompt)
            return riddles
        except Exception as e:
            print(f"❌ Error generating riddles: {e}")
            return self._generate_fallback_riddles(project_info)

    def _call_ollama(self, prompt: str) -> str:
        """Call local Ollama API to generate riddles"""
        try:
            result = subprocess.run([
                'ollama', 'run', self.model
            ], input=prompt, text=True, capture_output=True, timeout=60)

            if result.returncode != 0:
                raise Exception(f"Ollama failed: {result.stderr}")

            return result.stdout.strip()

        except subprocess.TimeoutExpired:
            raise Exception("Ollama request timed out")
        except FileNotFoundError:
            raise Exception("Ollama not found. Install from https://ollama.ai")

    def _generate_fallback_riddles(self, project_info: Dict) -> str:
        """Generate basic riddles when AI is unavailable"""
        project_name = project_info["name"]
        languages = list(project_info["languages"])

        return f"""# Sphinx Riddles: {project_name}

> **Answer correctly, or be devoured by your own ignorance.**

### Riddle I: The Foundation
*"What is the core purpose of this system, and how does it achieve it?"*

- [ ] Explain the main problem this project solves
- [ ] Identify the core data structures and algorithms
- [ ] Trace the flow of data through the system
- [ ] Document the key architectural decisions

**Proof of Understanding**: Rebuild the core functionality from scratch without looking at the original code.

### Riddle II: The Dependencies
*"What external forces does this system rely upon, and why?"*

- [ ] List all external dependencies and their purposes
- [ ] Understand the trade-offs made in dependency choices
- [ ] Identify potential failure points in external systems
- [ ] Document how to replace each major dependency

**Proof of Understanding**: Explain what would break if each dependency was removed.

### Riddle III: The Interface
*"How does this system communicate with the outside world?"*

- [ ] Map all input/output mechanisms
- [ ] Understand the API design choices (if applicable)
- [ ] Document error handling and edge cases
- [ ] Trace data validation and sanitization

**Proof of Understanding**: Design and implement an alternative interface for the same functionality.

*Generated in fallback mode - enhance with local AI for deeper insights.*
"""

def main():
    parser = argparse.ArgumentParser(description="Generate sphinx riddles for a project")
    parser.add_argument("project_path", help="Path to the project directory")
    parser.add_argument("--model", default="mistral:7b", help="Local AI model to use")
    parser.add_argument("--output", help="Output file (default: stdout)")

    args = parser.parse_args()

    project_path = Path(args.project_path)
    if not project_path.exists():
        print(f"❌ Project path does not exist: {project_path}")
        sys.exit(1)

    if not project_path.is_dir():
        print(f"❌ Project path is not a directory: {project_path}")
        sys.exit(1)

    # Generate riddles
    generator = SphinxGenerator(args.model)
    riddles = generator.generate_riddles(project_path)

    # Output results
    if args.output:
        output_path = Path(args.output)
        output_path.write_text(riddles)
        print(f"✅ Riddles written to: {output_path}")
    else:
        print("\n" + "="*50)
        print(riddles)

if __name__ == "__main__":
    main()

# Sphinx Generator

> *"The sphinx does not simply ask questions - it crafts riddles that reveal the depth of your ignorance."*

## What Is This?

The Sphinx Generator is a tool that analyzes your codebase and generates personalized riddles to test your deep understanding of it. It's designed for the sspphhiinnxx methodology: using local AI to structure learning challenges while doing the actual learning work yourself.

## Philosophy

**The Problem**: You built something with AI assistance, but do you actually understand it deeply enough to rebuild it from scratch?

**The Solution**: The sphinx poses specific riddles tailored to your project that force you to prove your understanding at a fundamental level.

**The Principle**: AI structures the learning, humans do the learning.

## How It Works

1. **Scan**: Analyzes your project structure, README, key files, and dependencies
2. **Analyze**: Uses local AI (via Ollama) to understand the project's complexity
3. **Challenge**: Generates sphinx-style riddles that test core concepts
4. **Test**: Each riddle includes concrete tasks and "Proof of Understanding" requirements

## Prerequisites

- Python 3.8+
- [Ollama](https://ollama.ai) installed locally
- A local model pulled (e.g., `ollama pull mistral:7b`)

## Installation

```bash
# Clone or navigate to the sphinx-generator directory
cd qry/sspphhiinnxx/sphinx-generator/

# Make executable (optional)
chmod +x sphinx.py

# Test your setup
python sphinx.py --help
```

## Usage

### Basic Usage
```bash
# Generate riddles for a project (output to stdout)
python sphinx.py /path/to/your/project

# Generate riddles with specific model
python sphinx.py /path/to/your/project --model mistral:7b

# Save riddles to file
python sphinx.py /path/to/your/project --output riddles.md
```

### Testing on Uroboro
```bash
# From the sphinx-generator directory
python sphinx.py ../../tools/uroboro --output ../uroboro/riddles.md
```

## Example Output

The generator creates riddles like this:

```markdown
### Riddle I: The Data Foundation
*"How does your system remember what it knows?"*

- [ ] Explain the SQLite schema design choices
- [ ] Rebuild the database migrations by hand
- [ ] Document the query patterns and their performance implications

**Proof of Understanding**: Create the database schema from scratch and explain why each constraint exists.
```

## Models and Performance

**Recommended Models:**
- `mistral:7b` - Good balance of speed and quality
- `llama3.1:8b` - Better reasoning, slower
- `qwen2.5:7b` - Fast and focused

**Fallback Mode:** If Ollama isn't available, generates basic template riddles.

## The Riddle Structure

Each generated riddle follows this pattern:

1. **Philosophical Question**: Tests conceptual understanding
2. **Concrete Tasks**: Specific things you must do/build/explain
3. **Proof of Understanding**: How to demonstrate mastery

## Troubleshooting

### "Ollama not found"
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull a model
ollama pull mistral:7b
```

### "Model not available"
```bash
# Check available models
ollama list

# Pull the model you want
ollama pull mistral:7b
```

### "Permission denied"
```bash
# Make sure you can read the project directory
ls -la /path/to/your/project
```

## Advanced Usage

### Custom Prompts
Edit the `SPHINX_PROMPT` in `sphinx.py` to adjust the riddle generation style.

### Project Types
The generator adapts to different project types:
- **CLI Tools**: Focuses on argument parsing, data flow, error handling
- **Web Apps**: Emphasizes routing, state management, security
- **Libraries**: Tests API design, abstractions, usage patterns

## Integration with sspphhiinnxx Workflow

1. Build something (possibly with AI assistance)
2. Generate riddles: `python sphinx.py project-path --output riddles.md`
3. Work through riddles systematically
4. Document your learning in `progress.md`
5. Rebuild core components by hand in `artifacts/`

## The Meta-Riddle

The sphinx generator itself is subject to its own riddles. Can you:
- Rebuild the project scanning logic?
- Implement the Ollama integration from scratch?
- Design an alternative prompt that generates better riddles?

*Use the tool to understand the tool. The ouroboros devours its own tail.*

## Contributing

Found a bug? Generated poor riddles? The sphinx accepts offerings of improved code and better prompts.

But first, make sure you understand how the current implementation works well enough to rebuild it.
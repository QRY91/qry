# Aider Setup Implementation Guide

**Implementation Checklist**: Step-by-step setup for optimized local AI development environment  
**Based on**: HN community insights + QRY methodology  
**Timeline**: 2-3 hours for complete setup  
**Prerequisites**: Linux/macOS with 8GB+ RAM

---

## 🚀 Quick Start (TL;DR)

```bash
# 1. Run the setup script
curl -sSL https://raw.githubusercontent.com/QRY91/qry/main/labs/projects/aider-setup-optimization/install.sh | bash

# 2. Start optimized development environment
qdev  # alias for zellij --layout qry-ai-dev

# 3. Test aider in dedicated pane
qaider  # optimized aider with qwen models
```

---

## 📋 Prerequisites Checklist

### **System Requirements**
- [ ] **OS**: Linux (Ubuntu 20.04+) or macOS (11+)
- [ ] **RAM**: 8GB minimum, 16GB recommended
- [ ] **Storage**: 10GB free space for models
- [ ] **Network**: Internet for initial downloads
- [ ] **Shell**: bash or zsh

### **Required Tools**
- [ ] **Python 3.8+** with pip
- [ ] **Node.js 16+** (for some neovim plugins)
- [ ] **Git** (for version control)
- [ ] **curl** and **wget** (for downloads)

### **Check Prerequisites**
```bash
# Verify system requirements
python3 --version  # Should be 3.8+
node --version     # Should be 16+
git --version      # Any recent version
free -h            # Check available RAM
df -h              # Check disk space
```

---

## 🔧 Phase 1: Core Tools Installation

### **Step 1: Install Base Tools**

#### **Ubuntu/Debian**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y python3-pip nodejs npm git curl wget build-essential

# Install modern CLI tools
sudo apt install -y ripgrep fd-find bat
sudo snap install nvim --classic

# Install eza (better ls)
wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
sudo mv eza /usr/local/bin/
```

#### **macOS**
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install python node git curl wget
brew install ripgrep fd bat eza neovim
```

#### **Arch Linux**
```bash
# Install tools
sudo pacman -S python python-pip nodejs npm git curl wget
sudo pacman -S ripgrep fd bat eza neovim
```

### **Step 2: Install Zellij**

#### **Download and Install**
```bash
# Download latest zellij
ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep tag_name | cut -d '"' -f 4)
wget "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz"
tar -xf zellij-x86_64-unknown-linux-musl.tar.gz
sudo mv zellij /usr/local/bin/
rm zellij-x86_64-unknown-linux-musl.tar.gz

# Test installation
zellij --version
```

### **Step 3: Install Aider**
```bash
# Install aider via pip
pip3 install aider-chat

# Verify installation
aider --version

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### **Step 4: Install Ollama and Models**
```bash
# Install ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Start ollama service
ollama serve &

# Download optimized models (this will take time)
ollama pull qwen2.5-coder:0.5b-instruct-q4_0
ollama pull qwen:7b-chat-q4_0

# Test models
ollama run qwen2.5-coder:0.5b-instruct-q4_0 "print('hello world')"
ollama run qwen:7b-chat-q4_0 "Explain what you are in one sentence"
```

---

## ⚙️ Phase 2: Configuration Setup

### **Step 5: Neovim Configuration**

#### **Create Neovim Config Directory**
```bash
mkdir -p ~/.config/nvim/lua/config
cd ~/.config/nvim
```

#### **Install Lazy.nvim Plugin Manager**
```bash
# Create init.lua
cat > init.lua << 'EOF'
-- QRY Labs Neovim Configuration
-- Optimized for aider integration and systematic development

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("config.plugins")
require("config.keymaps")
EOF
```

#### **Create Plugin Configuration**
```bash
cat > lua/config/plugins.lua << 'EOF'
-- Plugin configuration for QRY development workflow
return require("lazy").setup({
  -- File navigation and fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
    end,
  },

  -- Quick file jumping (essential for aider workflow)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
    end,
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "tsserver", "gopls" },
      })
      
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "go", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
        },
      })
    end,
  },

  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
})
EOF
```

#### **Create Key Mappings**
```bash
cat > lua/config/keymaps.lua << 'EOF'
-- QRY Labs key mappings optimized for aider workflow

local keymap = vim.keymap.set

-- Telescope (fuzzy finding)
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })

-- Harpoon (quick navigation)
local harpoon = require("harpoon")
keymap("n", "<leader>a", function() harpoon:list():append() end)
keymap("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
keymap("n", "<C-h>", function() harpoon:list():select(1) end)
keymap("n", "<C-t>", function() harpoon:list():select(2) end)
keymap("n", "<C-n>", function() harpoon:list():select(3) end)
keymap("n", "<C-s>", function() harpoon:list():select(4) end)

-- File tree
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })

-- LSP keymaps
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
keymap("n", "<leader>f", vim.lsp.buf.format, { desc = "Format" })

-- Aider integration keymaps
keymap("n", "<leader>ai", "<cmd>!aider %<cr>", { desc = "Aider current file" })
keymap("n", "<leader>ac", "<cmd>!aider --chat<cr>", { desc = "Aider chat mode" })
keymap("n", "<leader>aa", "<cmd>!aider .<cr>", { desc = "Aider all files" })

-- QRY tools integration
keymap("n", "<leader>qc", "<cmd>!uro capture ", { desc = "Uroboro capture" })
keymap("n", "<leader>qp", "<cmd>!uro publish --blog<cr>", { desc = "Uroboro publish" })
keymap("n", "<leader>qs", "<cmd>!uro status<cr>", { desc = "Uroboro status" })

-- Quick navigation
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
keymap("n", "<leader>x", "<cmd>x<cr>", { desc = "Save and quit" })

-- Better window navigation
keymap("n", "<C-Left>", "<C-w>h")
keymap("n", "<C-Down>", "<C-w>j")
keymap("n", "<C-Up>", "<C-w>k")
keymap("n", "<C-Right>", "<C-w>l")
EOF
```

### **Step 6: Zellij Layout Configuration**

#### **Create Zellij Config Directory**
```bash
mkdir -p ~/.config/zellij/layouts
```

#### **Create QRY Development Layout**
```bash
cat > ~/.config/zellij/layouts/qry-ai-dev.kdl << 'EOF'
layout {
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        children
        pane size=2 borderless=true {
            plugin location="zellij:status-bar"
        }
    }
    
    tab name="AI-Dev" focus=true {
        pane split_direction="vertical" {
            pane size="65%" {
                command "nvim"
                args "."
                name "neovim"
            }
            pane split_direction="horizontal" {
                pane size="70%" {
                    name "aider"
                    command "bash"
                    args "-c" "echo 'Run: qaider to start aider with optimized settings'; bash"
                }
                pane size="30%" {
                    name "terminal"
                }
            }
        }
    }
    
    tab name="QRY-Tools" {
        pane split_direction="horizontal" {
            pane {
                name "uroboro"
                command "bash"
                args "-c" "echo 'Uroboro commands: uro capture, uro publish, uro status'; bash"
            }
            pane {
                name "monitoring"
                command "bash"
                args "-c" "echo 'System monitoring: htop, nvidia-smi, etc.'; bash"
            }
        }
    }
    
    tab name="Git" {
        pane {
            name "git-status"
            command "bash"
            args "-c" "git status; bash"
        }
    }
}
EOF
```

### **Step 7: Aider Configuration**

#### **Create Aider Config**
```bash
# Create aider config directory
mkdir -p ~/.config/aider

# Create optimized configuration
cat > ~/.config/aider/config.yml << 'EOF'
# QRY Labs Aider Configuration
# Optimized based on HN community insights

# Model configuration
model: ollama/qwen:7b-chat-q4_0
editor-model: ollama/qwen2.5-coder:0.5b-instruct-q4_0

# Performance optimizations
no-auto-commits: false
gitignore: true
show-diffs: true

# Context management (prevent overload)
max-chat-history-tokens: 8192

# Output preferences
no-pretty: false
show-model-warnings: false

# Integration settings
env-file: .env
EOF
```

#### **Create .aiderignore Template**
```bash
cat > ~/.config/aider/.aiderignore.template << 'EOF'
# QRY Labs .aiderignore template
# Copy to project root and customize

# Dependencies
node_modules/
venv/
env/
__pycache__/
*.pyc
.pytest_cache/

# Build outputs
dist/
build/
target/
*.o
*.so
*.dylib

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Version control
.git/
.svn/
.hg/

# Logs and databases
*.log
*.db
*.sqlite
*.sqlite3

# Environment and secrets
.env*
*.key
*.pem
config/secrets/

# Large files
*.zip
*.tar.gz
*.mp4
*.mov
*.pdf
*.jpg
*.png
*.gif

# QRY specific ignores
daily/
captures/
.uroboro/
EOF
```

### **Step 8: Shell Configuration and Aliases**

#### **Add Aliases and Functions**
```bash
# Add to ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# QRY Labs Development Environment
# Aider optimization aliases

# Development environment
alias qdev="zellij --layout qry-ai-dev"

# Optimized aider commands
alias qaider="aider --model ollama/qwen:7b-chat-q4_0"
alias qedit="aider --editor-model ollama/qwen2.5-coder:0.5b-instruct-q4_0"
alias qchat="aider --model ollama/qwen:7b-chat-q4_0 --chat"

# Enhanced CLI tools
alias ls="eza --icons"
alias ll="eza -la --icons"
alias tree="eza --tree --icons"
alias cat="bat"
alias find="fd"
alias grep="rg"

# QRY tool integration
alias qcap="uro capture"
alias qpub="uro publish --blog"
alias qstat="uro status"

# System prompt with /nothink for qwen3
qwen_prompt() {
    echo "/nothink You are a helpful coding assistant. Provide direct, practical responses without showing your reasoning process."
}

# Aider with optimized prompts
qaider_opt() {
    local system_prompt=$(qwen_prompt)
    aider --model ollama/qwen:7b-chat-q4_0 --message "$system_prompt" "$@"
}

# Quick project setup
qproject() {
    if [ -z "$1" ]; then
        echo "Usage: qproject <project-name>"
        return 1
    fi
    
    mkdir -p "$1"
    cd "$1"
    git init
    cp ~/.config/aider/.aiderignore.template .aiderignore
    echo "# $1" > README.md
    echo "Project $1 initialized with QRY setup"
}

# Model performance testing
qperf() {
    echo "Testing qwen2.5-coder-0.5b (lightweight):"
    time echo "print('hello world')" | ollama run qwen2.5-coder:0.5b-instruct-q4_0
    
    echo -e "\nTesting qwen-7b (full capability):"
    time echo "Explain what you are in one sentence" | ollama run qwen:7b-chat-q4_0
}

EOF

# Source the new configuration
source ~/.bashrc
```

---

## 🧪 Phase 3: Testing and Validation

### **Step 9: System Tests**

#### **Test Core Tools**
```bash
# Test neovim
nvim --version | head -n 1

# Test zellij
zellij --version

# Test aider
aider --version

# Test ollama and models
ollama list | grep qwen
```

#### **Test Development Workflow**
```bash
# Create test project
qproject test-aider-setup
cd test-aider-setup

# Test basic aider functionality
echo "print('Hello from optimized aider')" > test.py
qaider test.py --message "Add a comment explaining what this does"

# Test neovim integration
nvim test.py
# In nvim: <leader>ai should trigger aider on current file
```

#### **Performance Validation**
```bash
# Run performance tests
qperf

# Monitor resource usage
htop &
# Run aider session and monitor CPU/memory usage

# Test context window optimization
qaider --chat
# Try progressively larger contexts and note performance
```

### **Step 10: Development Environment Test**

#### **Launch Full Environment**
```bash
# Start optimized development session
qdev

# In neovim pane, test key mappings:
# <space>ff - file finding
# <space>fg - grep search
# <space>e - file tree
# <C-e> - harpoon menu

# In aider pane, test AI assistance:
qaider_opt
# Test with /nothink prompt optimization
```

#### **QRY Integration Test**
```bash
# Test uroboro integration
qcap "Successfully set up optimized aider environment with qwen models"
qstat

# Test with actual development work
cd ~/path/to/existing/project
qdev
# Use aider for real development task
# Capture insights with uroboro
```

---

## 🔧 Phase 4: Optimization and Customization

### **Step 11: Performance Tuning**

#### **Model Performance Optimization**
```bash
# Test context window sizes
# Create test script to measure response times with different contexts

cat > ~/test_context_performance.py << 'EOF'
#!/usr/bin/env python3
import time
import subprocess
import sys

def test_model_performance(model, context_sizes):
    results = {}
    for size in context_sizes:
        # Create context of specified size
        context = "# " * size + "\nprint('hello')"
        
        start_time = time.time()
        result = subprocess.run([
            'ollama', 'run', model, context
        ], capture_output=True, text=True)
        end_time = time.time()
        
        results[size] = end_time - start_time
        print(f"Model: {model}, Context: {size} tokens, Time: {results[size]:.2f}s")
    
    return results

if __name__ == "__main__":
    models = [
        "qwen2.5-coder:0.5b-instruct-q4_0",
        "qwen:7b-chat-q4_0"
    ]
    
    context_sizes = [100, 500, 1000, 2000, 4000]
    
    for model in models:
        print(f"\nTesting {model}:")
        test_model_performance(model, context_sizes)
EOF

chmod +x ~/test_context_performance.py
python3 ~/test_context_performance.py
```

#### **System Resource Monitoring**
```bash
# Create monitoring script
cat > ~/monitor_aider_resources.sh << 'EOF'
#!/bin/bash
# Monitor system resources during aider usage

echo "Monitoring system resources for aider optimization..."
echo "Timestamp,CPU%,Memory%,Temp" > aider_resources.csv

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    memory=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
    
    # Temperature (if available)
    if command -v sensors &> /dev/null; then
        temp=$(sensors | grep -oP 'Core.*?\+\K[0-9.]+' | head -n 1)
    else
        temp="N/A"
    fi
    
    echo "$timestamp,$cpu,$memory,$temp" >> aider_resources.csv
    echo "CPU: $cpu%, Memory: $memory%, Temp: $temp°C"
    sleep 5
done
EOF

chmod +x ~/monitor_aider_resources.sh
```

### **Step 12: Custom Configurations**

#### **Project-Specific Aider Configs**
```bash
# Create project config generator
cat > ~/.local/bin/qry-aider-init << 'EOF'
#!/bin/bash
# Initialize QRY-optimized aider configuration for project

PROJECT_DIR=${1:-.}
cd "$PROJECT_DIR"

# Create project-specific .aider.conf.yml
cat > .aider.conf.yml << AIDER_EOF
# Project-specific aider configuration
model: ollama/qwen:7b-chat-q4_0
editor-model: ollama/qwen2.5-coder:0.5b-instruct-q4_0

# Customize based on project type
$(if [[ -f "package.json" ]]; then
    echo "# JavaScript/TypeScript project detected"
    echo "# Consider using smaller context for rapid iteration"
    echo "max-chat-history-tokens: 4096"
elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    echo "# Python project detected"
    echo "# Standard context size works well"
    echo "max-chat-history-tokens: 8192"
elif [[ -f "go.mod" ]]; then
    echo "# Go project detected"
    echo "# Larger context helpful for understanding interfaces"
    echo "max-chat-history-tokens: 12288"
else
    echo "# Generic project configuration"
    echo "max-chat-history-tokens: 8192"
fi)

# Performance settings
no-auto-commits: false
gitignore: true
show-diffs: true
AIDER_EOF

# Copy optimized .aiderignore
cp ~/.config/aider/.aiderignore.template .aiderignore

echo "Aider configuration initialized for $(basename $(pwd))"
echo "Customize .aider.conf.yml and .aiderignore as needed"
EOF

chmod +x ~/.local/bin/qry-aider-init
```

---

## 📊 Phase 5: Documentation and Sharing

### **Step 13: Performance Benchmarking**

#### **Create Benchmark Suite**
```bash
# Create comprehensive benchmark
cat > ~/aider_benchmark_suite.py << 'EOF'
#!/usr/bin/env python3
"""
QRY Labs Aider Performance Benchmark Suite
Tests optimized local AI development workflow
"""

import time
import subprocess
import json
import sys
from pathlib import Path

class AiderBenchmark:
    def __init__(self):
        self.results = {}
        
    def benchmark_model_loading(self):
        """Test model loading times"""
        models = [
            "qwen2.5-coder:0.5b-instruct-q4_0",
            "qwen:7b-chat-q4_0"
        ]
        
        loading_times = {}
        for model in models:
            print(f"Testing {model} loading time...")
            start = time.time()
            subprocess.run(['ollama', 'run', model, 'test'], 
                         capture_output=True, text=True)
            end = time.time()
            loading_times[model] = end - start
            print(f"  Loading time: {loading_times[model]:.2f}s")
        
        self.results['model_loading'] = loading_times
        
    def benchmark_response_quality(self):
        """Test response quality vs speed trade-offs"""
        test_prompts = [
            "Fix this Python function: def add(a, b): return a + b",
            "Explain this code: const items = arr.map(x => x * 2)",
            "Refactor this for better performance: for i in range(len(lst)): print(lst[i])"
        ]
        
        models = [
            "qwen2.5-coder:0.5b-instruct-q4_0",
            "qwen:7b-chat-q4_0"
        ]
        
        quality_results = {}
        for model in models:
            quality_results[model] = {}
            for i, prompt in enumerate(test_prompts):
                start = time.time()
                result = subprocess.run([
                    'ollama', 'run', model, prompt
                ], capture_output=True, text=True)
                end = time.time()
                
                quality_results[model][f'prompt_{i}'] = {
                    'response_time': end - start,
                    'response_length': len(result.stdout),
                    'prompt': prompt[:50] + "..."
                }
        
        self.results['response_quality'] = quality_results
        
    def save_results(self, filename='aider_benchmark_results.json'):
        """Save benchmark results"""
        with open(filename, 'w') as f:
            json.dump(self.results, f, indent=2)
        print(f"Results saved to {filename}")

if __name__ == "__main__":
    benchmark = AiderBenchmark()
    
    print("QRY Labs Aider Benchmark Suite")
    print("=" * 40)
    
    benchmark.benchmark_model_loading()
    print()
    benchmark.benchmark_response_quality()
    
    benchmark.save_results()
    print("\nBenchmark complete!")
EOF

chmod +x ~/aider_benchmark_suite.py
```

### **Step 14: Create Setup Automation Script**

#### **Complete Installation Script**
```bash
cat > ~/install_qry_aider_setup.sh << 'EOF'
#!/bin/bash
# QRY Labs Aider Setup Automation Script
# Complete installation and configuration

set -e

echo "🚀 QRY Labs Aider Setup - Starting Installation"
echo "=================================================="

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
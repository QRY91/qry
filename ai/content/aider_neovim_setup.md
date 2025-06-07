# Aider + Neovim + Zellij Development Setup

*Systematic CLI-first development environment aligned with QRY Labs philosophy*

## Core Philosophy

**Performance + Learning + Systematic Control** = Better tools for building better tools.

This setup transforms development from "using an IDE" to "orchestrating a systematic workflow" - directly applicable to understanding what makes tools engaging and effective.

## Required Tools

### Essential Components
- **aider** - AI pair programming in terminal
- **neovim** - Modal editing mastery
- **zellij** - Terminal multiplexing with layouts
- **ripgrep** - Fast search (rg)
- **fd** - Fast file finding
- **bat** - Better cat with syntax highlighting
- **eza** - Better ls with colors/icons

### Installation Commands

```bash
# Install aider
pip install aider-chat

# Install neovim (latest)
# Ubuntu/Debian:
sudo apt install neovim
# Arch:
sudo pacman -S neovim
# macOS:
brew install neovim

# Install zellij
# Ubuntu/Debian (download from GitHub releases)
# Arch:
sudo pacman -S zellij
# macOS:
brew install zellij

# Install CLI utilities
# Ubuntu/Debian:
sudo apt install ripgrep fd-find bat
# Arch:
sudo pacman -S ripgrep fd bat
# macOS:
brew install ripgrep fd bat eza

# Install eza separately if needed
cargo install eza
```

## Neovim Configuration

### Essential Plugins (via lazy.nvim)

```lua
-- Essential for systematic development
{
  -- File navigation (like Cursor's file explorer)
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  
  -- Quick file jumping (replaces tabs)
  'ThePrimeagen/harpoon',
  
  -- LSP for code intelligence
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  
  -- Autocompletion
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  
  -- Syntax highlighting
  'nvim-treesitter/nvim-treesitter',
  
  -- Git integration
  'tpope/vim-fugitive',
  'lewis6991/gitsigns.nvim',
  
  -- File tree
  'nvim-tree/nvim-tree.lua',
  
  -- Status line
  'nvim-lualine/lualine.nvim',
  
  -- Theme (optional but nice)
  'catppuccin/nvim',
}
```

### Key Mappings Philosophy
**Modal editing = systematic thinking made physical**

```lua
-- Telescope (fuzzy finding)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')

-- Harpoon (quick navigation)
vim.keymap.set('n', '<leader>a', require('harpoon.mark').add_file)
vim.keymap.set('n', '<C-e>', require('harpoon.ui').toggle_quick_menu)
vim.keymap.set('n', '<C-h>', function() require('harpoon.ui').nav_file(1) end)
vim.keymap.set('n', '<C-t>', function() require('harpoon.ui').nav_file(2) end)
vim.keymap.set('n', '<C-n>', function() require('harpoon.ui').nav_file(3) end)
vim.keymap.set('n', '<C-s>', function() require('harpoon.ui').nav_file(4) end)

-- File tree
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')

-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
```

## Zellij Layout Configuration

### QRY Development Layout

Create `~/.config/zellij/layouts/qry-dev.kdl`:

```kdl
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
    
    tab name="Code" focus=true {
        pane split_direction="vertical" {
            pane size="70%" {
                command "nvim"
                args "."
            }
            pane split_direction="horizontal" {
                pane size="60%" {
                    name "aider"
                }
                pane size="40%" {
                    name "terminal"
                }
            }
        }
    }
    
    tab name="Tools" {
        pane split_direction="horizontal" {
            pane {
                name "git"
            }
            pane {
                name "tests"
            }
        }
    }
}
```

### Launch Command

```bash
# Start the systematic development environment
zellij --layout qry-dev

# Or create an alias
alias qdev="zellij --layout qry-dev"
```

## Aider Configuration

### .aiderignore Setup
```
node_modules/
.git/
dist/
build/
.env*
*.log
.DS_Store
__pycache__/
*.pyc
.pytest_cache/
coverage/
.coverage
```

### Usage Patterns

```bash
# Start aider with Claude (in the aider pane)
aider --model claude-3-5-sonnet-20241022

# For specific files
aider src/main.py src/utils.py --model claude-3-5-sonnet-20241022

# With git integration
aider --model claude-3-5-sonnet-20241022 --git
```

## Systematic Workflow

### Daily Development Cycle

1. **Launch Environment**: `qdev` (zellij with layout)
2. **Navigate to Project**: Navigate in nvim pane
3. **Start Aider**: Launch in dedicated pane with Claude
4. **Code + Chat**: Seamless switching between editing and AI conversation
5. **Test + Iterate**: Use terminal pane for running tests/commands
6. **Git Management**: Use git tab for version control

### Keyboard Flow Optimization

**Zellij Navigation:**
- `Ctrl + p` → Switch between panes
- `Alt + [hjkl]` → Resize panes
- `Ctrl + t` → New tab

**Neovim Navigation:**
- `<leader>` = `<space>` (spacebar)
- `<space>ff` → Find files
- `<space>fg` → Grep search
- `Ctrl-e` → Harpoon menu
- `<space>e` → File tree

## Learning Objectives

### Systematic Skill Development

**Week 1**: Master basic navigation
- Zellij pane switching without thinking
- Telescope file finding muscle memory
- Harpoon for quick file jumping

**Week 2**: Modal editing fluency
- Vim motions become automatic
- Text objects (ciw, da", etc.)
- Visual mode selections

**Week 3**: AI integration patterns
- Effective aider prompting
- File-specific vs project-wide changes
- Git integration workflow

**Week 4**: Customization and optimization
- Personal keybinding preferences
- Plugin configuration tweaks
- Layout refinements

## QRY Labs Integration

### Tool Analysis Benefits
- **Systematic understanding** of CLI tool design patterns
- **First-hand experience** with performance vs feature tradeoffs
- **Workflow optimization** insights applicable to your own tools
- **Modal thinking** practice that applies to game state management

### Documentation Approach
- Document friction points and solutions
- Analyze what makes certain key combinations "feel right"
- Track productivity metrics (subjective feel, not numbers)
- Note metaphor consistency across tools

## Troubleshooting

### Common Issues
- **Aider can't find files**: Check .aiderignore, use explicit file paths
- **Neovim LSP not working**: Run `:Mason` to install language servers
- **Zellij layout not loading**: Check kdl syntax, file permissions
- **Performance issues**: Reduce treesitter parsers, check plugin count

### Performance Optimization
- Use `fd` instead of `find`
- Configure nvim for your hardware (reduce animations, etc.)
- Optimize zellij config for your typical workflow patterns

---

**Remember**: This isn't about the "perfect" setup - it's about systematic learning and tool mastery that serves your broader mission of understanding what makes tools engaging and effective.

*Tools teaching you to build better tools.* 🔄 
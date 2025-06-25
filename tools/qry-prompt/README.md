# QRY Prompt

A beautiful, feature-rich shell prompt with nerd font icons that works across bash, zsh, and fish shells.

## Features

- **🎨 Beautiful Design**: Clean, two-line prompt with vibrant colors
- **🔤 Nerd Font Icons**: Rich iconography for better visual experience
- **📊 Git Integration**: Shows branch, modifications, staged files, and sync status
- **🔍 Project Detection**: Automatically detects and displays project types (Node.js, Python, Go, Rust, Docker, Vim)
- **⚡ Multi-Shell Support**: Works with bash, zsh, and fish
- **🎯 Smart Status**: Shows exit codes and command success/failure
- **👤 User Context**: Displays user@hostname with privilege indication
- **📁 Directory Display**: Shows current directory with folder icon

## Preview

```
👤 user@hostname 📁 qry-prompt 🐍 📦 🌿 main ⚡3 ↑1
✓ ➜ 
```

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/your-repo/qry-prompt/main/install.sh | bash
```

Or download and run locally:

```bash
git clone https://github.com/your-repo/qry-prompt.git
cd qry-prompt
chmod +x install.sh
./install.sh
```

## Manual Installation

1. **Install Nerd Fonts** (required for icons):
   ```bash
   ./install.sh --fonts-only
   ```

2. **Install the prompt**:
   ```bash
   ./install.sh --prompt-only
   ```

3. **Add to your shell config**:

   **Bash** (`~/.bashrc`):
   ```bash
   source "$HOME/.local/share/qry-prompt/qry-prompt.sh"
   ```

   **Zsh** (`~/.zshrc`):
   ```bash
   source "$HOME/.local/share/qry-prompt/qry-prompt.sh"
   ```

   **Fish** (`~/.config/fish/config.fish`):
   ```fish
   source "$HOME/.local/share/qry-prompt/qry-prompt.sh"
   ```

## Prompt Segments

### First Line
- **User@Host**: Shows current user and hostname with privilege colors
- **Directory**: Current directory name with folder icon
- **Project Type**: Auto-detected project icons (Node.js, Python, Go, etc.)
- **Git Status**: Branch name and file status indicators

### Second Line
- **Exit Status**: Green checkmark for success, red cross for errors
- **Prompt Arrow**: Clean arrow indicating input ready

## Icons Reference

| Element | Icon | Description |
|---------|------|-------------|
| Folder | 󰉋 | Current directory |
| Git Branch |  | Git repository branch |
| Git Modified |  | Modified files |
| Git Staged |  | Staged files |
| Git Untracked | ? | Untracked files |
| Git Ahead |  | Commits ahead of remote |
| Git Behind |  | Commits behind remote |
| User |  | Current user |
| Host | 󰍹 | Hostname |
| Success |  | Command succeeded |
| Error |  | Command failed |
| Python | 🐍 | Python project |
| Node.js | 📦 | Node.js project |
| Go | 🐹 | Go project |
| Rust | 🦀 | Rust project |
| Docker | 🐳 | Docker project |
| Vim |  | Vim configuration |

## Git Status Indicators

- **Yellow** : Modified files count
- **Green** : Staged files count  
- **Red ?**: Untracked files count
- **Cyan** : Commits ahead of remote
- **Magenta** : Commits behind remote

## Color Scheme

- **User**: Bright green (normal user), bright red (root)
- **Host**: Bright blue
- **Directory**: Bright cyan
- **Git**: Blue branch, status-dependent colors
- **Success**: Bright green
- **Error**: Bright red
- **Project Types**: Contextual colors

## Configuration

The prompt automatically detects your current shell and configures itself appropriately. No additional configuration is required for basic usage.

### Customization

To customize colors or icons, edit the arrays at the top of `qry-prompt.sh`:

```bash
# Color definitions
declare -A colors=(
    [green]='\033[32m'
    # ... add your colors
)

# Icon definitions  
declare -A icons=(
    [folder]="󰉋"
    # ... customize icons
)
```

## Terminal Font Setup

For the best experience, configure your terminal to use a Nerd Font:

### Popular Nerd Fonts (included in installation)
- **FiraCode Nerd Font** (recommended)
- **JetBrains Mono Nerd Font**
- **Hack Nerd Font** 
- **Source Code Pro Nerd Font**
- **Ubuntu Mono Nerd Font**

### Terminal Configuration Examples

**GNOME Terminal**:
1. Open Preferences → Profiles → Text
2. Uncheck "Use system fixed width font"
3. Select a Nerd Font from the list

**Alacritty** (`~/.config/alacritty/alacritty.yml`):
```yaml
font:
  normal:
    family: "FiraCode Nerd Font"
```

**Kitty** (`~/.config/kitty/kitty.conf`):
```
font_family FiraCode Nerd Font
```

## Troubleshooting

### Icons not displaying
1. Ensure a Nerd Font is installed and selected in your terminal
2. Test with: `./install.sh --test`
3. Check font installation: `fc-list | grep -i nerd`

### Prompt not loading
1. Verify shell configuration file has the source line
2. Restart terminal or run: `source ~/.bashrc` (or appropriate config)
3. Check file permissions: `ls -la ~/.local/share/qry-prompt/`

### Git status not showing
1. Ensure you're in a git repository
2. Check git is installed: `git --version`
3. Verify repository status: `git status`

### Performance issues
The prompt is optimized for speed, but if you experience slowness:
1. Check if you're in a very large git repository
2. Consider using `git config core.preloadindex true`

## Uninstallation

1. Remove source line from shell config files
2. Remove installation directory: `rm -rf ~/.local/share/qry-prompt`
3. Optional: Remove nerd fonts: `rm -rf ~/.local/share/fonts/*Nerd*`

## Requirements

- **Bash 4.0+**, **Zsh 5.0+**, or **Fish 3.0+**
- **Git** (for git status features)
- **Nerd Font** (automatically installed)
- **wget/curl** and **unzip** (for installation)

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test across all supported shells
4. Submit a pull request

## Credits

- Icons from [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
- Inspired by modern prompt frameworks like Starship and Powerlevel10k
- Built for the QRY ecosystem of development tools
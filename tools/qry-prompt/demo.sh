#!/bin/bash

# QRY Prompt Demo Script
# Shows the prompt in different scenarios

echo "QRY Prompt Demo"
echo "==============="
echo ""

# Source the prompt
source ./qry-prompt.sh

echo "🎨 Basic prompt (current directory):"
build_prompt | head -1
echo ""

echo "📊 Git status indicators:"
echo "  🟡 Modified files: ${colors[yellow]}${icons[git_modified]}3${colors[reset]}"
echo "  🟢 Staged files: ${colors[green]}${icons[git_staged]}2${colors[reset]}"  
echo "  🔴 Untracked files: ${colors[red]}${icons[git_untracked]}5${colors[reset]}"
echo "  🔵 Ahead of remote: ${colors[cyan]}${icons[git_ahead]}1${colors[reset]}"
echo "  🟣 Behind remote: ${colors[magenta]}${icons[git_behind]}2${colors[reset]}"
echo ""

echo "🔧 Project type detection:"
echo "  📦 Node.js: ${colors[green]}${icons[nodejs]}${colors[reset]}"
echo "  🐍 Python: ${colors[yellow]}${icons[python]}${colors[reset]}"
echo "  🐹 Go: ${colors[cyan]}${icons[go]}${colors[reset]}"
echo "  🦀 Rust: ${colors[red]}${icons[rust]}${colors[reset]}"
echo "  🐳 Docker: ${colors[blue]}${icons[docker]}${colors[reset]}"
echo "  📝 Vim: ${colors[green]}${icons[vim]}${colors[reset]}"
echo ""

echo "👤 User context:"
echo "  Normal user: ${colors[bright_green]}${icons[user]} user${colors[reset]}"
echo "  Root user: ${colors[bright_red]}${icons[user]} root${colors[reset]}"
echo ""

echo "✅ Status indicators:"
echo "  Success: ${colors[bright_green]}${icons[check]}${colors[reset]}"
echo "  Error: ${colors[bright_red]}${icons[cross]}(1)${colors[reset]}"
echo ""

echo "🎯 Complete example:"
echo "${colors[bright_green]}${icons[user]} developer${colors[gray]}@${colors[bright_blue]}${icons[host]} workstation${colors[reset]} ${colors[bright_cyan]}${icons[folder]} my-project${colors[reset]} ${colors[green]}${icons[nodejs]} ${colors[yellow]}${icons[python]} ${colors[bright_blue]}${icons[git_branch]} main${colors[yellow]}${icons[git_modified]}2${colors[green]}${icons[git_staged]}1${colors[reset]}"
echo "${colors[bright_green]}${icons[check]}${colors[reset]} ${colors[bright_white]}${icons[arrow]} ${colors[reset]}"
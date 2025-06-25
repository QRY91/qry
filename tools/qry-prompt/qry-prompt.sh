#!/bin/bash

# QRY Shell Prompt - A beautiful prompt with nerd fonts
# Supports bash, zsh, and fish shells

# Color definitions
declare -A colors=(
    [reset]='\033[0m'
    [bold]='\033[1m'
    [dim]='\033[2m'
    [red]='\033[31m'
    [green]='\033[32m'
    [yellow]='\033[33m'
    [blue]='\033[34m'
    [magenta]='\033[35m'
    [cyan]='\033[36m'
    [white]='\033[37m'
    [gray]='\033[90m'
    [bright_red]='\033[91m'
    [bright_green]='\033[92m'
    [bright_yellow]='\033[93m'
    [bright_blue]='\033[94m'
    [bright_magenta]='\033[95m'
    [bright_cyan]='\033[96m'
    [bright_white]='\033[97m'
)

# Nerd font icons
declare -A icons=(
    [folder]="󰉋"
    [git_branch]=""
    [git_modified]=""
    [git_ahead]=""
    [git_behind]=""
    [git_staged]=""
    [git_untracked]="?"
    [user]=""
    [host]="󰍹"
    [arrow]=""
    [check]=""
    [cross]=""
    [time]=""
    [battery]=""
    [memory]=""
    [cpu]=""
    [separator]=""
    [python]=""
    [nodejs]=""
    [go]=""
    [rust]=""
    [docker]=""
    [vim]=""
)

# Get git status information
get_git_info() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return
    fi
    
    local branch=$(git branch --show-current 2>/dev/null)
    local status=""
    local git_status=$(git status --porcelain 2>/dev/null)
    
    # Count file types
    local modified=0
    local staged=0 
    local untracked=0
    
    if [[ -n "$git_status" ]]; then
        modified=$(echo "$git_status" | grep -c "^ M\|^M " 2>/dev/null)
        staged=$(echo "$git_status" | grep -c "^A\|^M\|^D" 2>/dev/null) 
        untracked=$(echo "$git_status" | grep -c "^??" 2>/dev/null)
        
        # Ensure numeric values
        [[ ! "$modified" =~ ^[0-9]+$ ]] && modified=0
        [[ ! "$staged" =~ ^[0-9]+$ ]] && staged=0
        [[ ! "$untracked" =~ ^[0-9]+$ ]] && untracked=0
    fi
    
    # Check if ahead/behind remote
    local ahead_behind=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null || echo "0	0")
    local behind=$(echo "$ahead_behind" | cut -f1 2>/dev/null)
    local ahead=$(echo "$ahead_behind" | cut -f2 2>/dev/null)
    
    # Ensure numeric values
    [[ -z "$behind" || ! "$behind" =~ ^[0-9]+$ ]] && behind=0
    [[ -z "$ahead" || ! "$ahead" =~ ^[0-9]+$ ]] && ahead=0
    
    # Build status string
    [[ $modified -gt 0 ]] && status+="${colors[yellow]}${icons[git_modified]}$modified"
    [[ $staged -gt 0 ]] && status+="${colors[green]}${icons[git_staged]}$staged"
    [[ $untracked -gt 0 ]] && status+="${colors[red]}${icons[git_untracked]}$untracked"
    [[ $ahead -gt 0 ]] && status+="${colors[cyan]}${icons[git_ahead]}$ahead"
    [[ $behind -gt 0 ]] && status+="${colors[magenta]}${icons[git_behind]}$behind"
    
    if [[ -n "$branch" ]]; then
        echo "${colors[bright_blue]}${icons[git_branch]} $branch${status}${colors[reset]}"
    fi
}

# Detect project type
get_project_type() {
    local project_icons=""
    
    [[ -f "package.json" ]] && project_icons+="${colors[green]}${icons[nodejs]} "
    [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] && project_icons+="${colors[yellow]}${icons[python]} "
    [[ -f "go.mod" ]] && project_icons+="${colors[cyan]}${icons[go]} "
    [[ -f "Cargo.toml" ]] && project_icons+="${colors[red]}${icons[rust]} "
    [[ -f "Dockerfile" ]] && project_icons+="${colors[blue]}${icons[docker]} "
    [[ -f ".vimrc" ]] || [[ -f "init.vim" ]] || [[ -f "init.lua" ]] && project_icons+="${colors[green]}${icons[vim]} "
    
    echo "$project_icons"
}

# Get current directory name (last part of path)
get_dir_name() {
    local dir=$(basename "$PWD")
    [[ "$dir" == "$HOME" ]] && dir="~"
    echo "${colors[bright_cyan]}${icons[folder]} $dir${colors[reset]}"
}

# Get user@host info
get_user_host() {
    local user_color="${colors[bright_green]}"
    [[ "$EUID" -eq 0 ]] && user_color="${colors[bright_red]}"
    
    echo "${user_color}${icons[user]} $USER${colors[gray]}@${colors[bright_blue]}${icons[host]} $HOSTNAME${colors[reset]}"
}

# Get exit status indicator
get_exit_status() {
    local exit_code=$1
    if [[ $exit_code -eq 0 ]]; then
        echo "${colors[bright_green]}${icons[check]}"
    else
        echo "${colors[bright_red]}${icons[cross]}($exit_code)"
    fi
}

# Main prompt function for bash/zsh
build_prompt() {
    local exit_code=$?
    local prompt=""
    
    # First line: user@host, directory, project type
    prompt+="$(get_user_host) "
    prompt+="$(get_dir_name) "
    prompt+="$(get_project_type)"
    
    # Git info if available
    local git_info=$(get_git_info)
    [[ -n "$git_info" ]] && prompt+="$git_info "
    
    prompt+="\n"
    
    # Second line: exit status and arrow
    prompt+="$(get_exit_status $exit_code)${colors[reset]} "
    prompt+="${colors[bright_white]}${icons[arrow]} ${colors[reset]}"
    
    echo "$prompt"
}

# Setup for different shells
setup_bash() {
    PS1='$(build_prompt)'
    export PS1
}

setup_zsh() {
    setopt PROMPT_SUBST
    PS1='$(build_prompt)'
    export PS1
}

setup_fish() {
    # Fish uses a different function-based approach
    mkdir -p ~/.config/fish/functions
    cat > ~/.config/fish/functions/fish_prompt.fish << 'EOF'
function fish_prompt
    set -l exit_code $status
    
    # Colors for fish
    set -l reset (set_color normal)
    set -l user_color (set_color brgreen)
    test $USER = "root"; and set user_color (set_color brred)
    
    # Icons
    set -l folder_icon "󰉋"
    set -l user_icon ""
    set -l host_icon "󰍹"
    set -l git_icon ""
    set -l arrow_icon ""
    set -l check_icon ""
    set -l cross_icon ""
    
    # Build prompt
    echo -n $user_color$user_icon" "$USER(set_color bryellow)"@"(set_color brblue)$host_icon" "(hostname)" "
    echo -n (set_color brcyan)$folder_icon" "(basename $PWD)" "
    
    # Git info
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (git branch --show-current 2>/dev/null)
        if test -n "$branch"
            echo -n (set_color brblue)$git_icon" "$branch" "
        end
    end
    
    echo ""
    
    # Exit status and arrow
    if test $exit_code -eq 0
        echo -n (set_color brgreen)$check_icon$reset" "
    else
        echo -n (set_color brred)$cross_icon"("$exit_code")"$reset" "
    end
    
    echo -n (set_color brwhite)$arrow_icon" "$reset
end
EOF
}

# Auto-detect shell and setup
case "$SHELL" in
    */bash)
        setup_bash
        ;;
    */zsh)
        setup_zsh
        ;;
    */fish)
        setup_fish
        ;;
    *)
        echo "Shell not detected or unsupported. Defaulting to bash setup."
        setup_bash
        ;;
esac
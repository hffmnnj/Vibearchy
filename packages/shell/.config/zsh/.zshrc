# Vibearchy Zsh Configuration
# Interactive shell settings

# Early return for non-interactive shells
[[ $- != *i* ]] && return

# Ensure history directory exists
[[ ! -d "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" ]] && mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"

# ============================================
# Zsh Options
# ============================================

# History
setopt EXTENDED_HISTORY          # Write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_FIND_NO_DUPS         # Don't show duplicates in search
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY               # Show command with history expansion before running
setopt SHARE_HISTORY             # Share history between sessions
setopt INC_APPEND_HISTORY        # Add commands as they are typed

# Directory navigation
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print directory stack

# Completion
setopt COMPLETE_IN_WORD          # Complete from both ends
setopt ALWAYS_TO_END             # Move cursor to end after completion
setopt AUTO_MENU                 # Show completion menu on tab
setopt AUTO_LIST                 # Automatically list choices
setopt AUTO_PARAM_SLASH          # Add slash after completing directory

# Other
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_BEEP                   # Disable beep
setopt EXTENDED_GLOB             # Extended globbing

# ============================================
# Completion System
# ============================================

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# ============================================
# Key Bindings
# ============================================

# Emacs-style line editing (default)
bindkey -e

# Better history search
bindkey '^[[A' history-search-backward  # Up arrow
bindkey '^[[B' history-search-forward   # Down arrow
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Word navigation
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

# Home/End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete
bindkey '^[[3~' delete-char

# ============================================
# Aliases
# ============================================

# Git
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gst='git status'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Docker
alias d='docker'
alias dc='docker compose'

# Modern replacements
if command -v eza &>/dev/null; then
    alias ls='eza -a --icons --group-directories-first --hyperlink'
    alias l='eza -la --icons --group-directories-first --hyperlink'
    alias ll='eza -la --icons --group-directories-first --hyperlink'
    alias lt='eza -la --icons --group-directories-first --tree --level=2 --hyperlink'
    alias lh='eza -la --icons --group-directories-first --hyperlink --ignore-glob=".*"'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat --plain --paging=never'
fi

# Safety
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Misc
alias v='nvim'
alias vim='nvim'
alias c='clear'
alias q='exit'
alias reload='source ~/.config/zsh/.zshrc'

# ============================================
# Functions
# ============================================

# mkcd - Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# extract - Universal archive extractor
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "Cannot extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Clone and cd into repo
clone-cd() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# ============================================
# Tool Integrations
# ============================================

# Source conf.d scripts
for conf in "$ZDOTDIR/conf.d/"*.zsh(N); do
    source "$conf"
done

# Autoload custom functions
fpath=("$ZDOTDIR/functions" $fpath)
autoload -Uz $ZDOTDIR/functions/*(:t)

# ============================================
# Starship Prompt (must be last)
# ============================================

if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

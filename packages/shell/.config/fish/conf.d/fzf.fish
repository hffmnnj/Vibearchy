# fzf configuration - Celestial Sky Blue theme

if type -q fzf
    # Celestial theme colors
    set -x FZF_DEFAULT_OPTS "\
        --color=bg+:#313244,bg:#11111b,spinner:#7dcfff,hl:#7dcfff \
        --color=fg:#cdd6f4,header:#7dcfff,info:#cba6f7,pointer:#7dcfff \
        --color=marker:#7dcfff,fg+:#cdd6f4,prompt:#cba6f7,hl+:#7dcfff \
        --border rounded \
        --height 40% \
        --layout=reverse \
        --info=inline \
        --preview-window=right:50%:wrap"

    # Use fd for faster searching if available
    if type -q fd
        set -x FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
        set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -x FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
    end

    # Preview with bat if available
    if type -q bat
        set -x FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    end

    # Preview directories with eza if available
    if type -q eza
        set -x FZF_ALT_C_OPTS "--preview 'eza --tree --color=always --icons {} | head -200'"
    end
end

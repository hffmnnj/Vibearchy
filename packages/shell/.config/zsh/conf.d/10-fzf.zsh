# FZF Configuration - Celestial Sky Blue Theme

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Celestial Sky Blue color scheme
export FZF_DEFAULT_OPTS="
    --height=90%
    --layout=reverse
    --info=inline
    --border=rounded
    --margin=1
    --padding=1
    --color=bg+:#313244,bg:#1e1e2e,spinner:#58a6ff,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#58a6ff,pointer:#58a6ff
    --color=marker:#a6e3a1,fg+:#cdd6f4,prompt:#58a6ff,hl+:#f38ba8
    --color=selected-bg:#45475a
    --color=border:#58a6ff,label:#cdd6f4
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-d:preview-half-page-down'
    --bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | wl-copy --trim-newline)'
    --bind 'alt-j:down+down+down+down+down'
    --bind 'alt-k:up+up+up+up+up'
"

export fzf_preview_dir_cmd='eza --long --header --icons --all --color=always --group-directories-first --hyperlink'
export fzf_fd_opts='--hidden --color=always'

# FZF key bindings if installed
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

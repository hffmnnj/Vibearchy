# Zoxide - smarter cd

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"

    # Zoxide with FZF preview
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview 'eza --long --header --icons --all --color=always --group-directories-first {2}'"
fi

# Atuin - better shell history

export ATUIN_NOBIND=true

if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"

    # Bind Ctrl+R to Atuin search
    bindkey '^r' atuin-search

    # Bind up arrow to Atuin
    bindkey '^[[A' atuin-up-search
    bindkey '^[OA' atuin-up-search
fi

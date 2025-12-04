# LS_COLORS with vivid

if command -v vivid &>/dev/null; then
    export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

# eza - modern ls replacement

if type -q eza
    # Base aliases
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -l --icons --group-directories-first --git"
    alias la="eza -la --icons --group-directories-first --git"
    alias lt="eza --tree --icons --level=2"
    alias lta="eza --tree --icons --level=2 -a"
    alias l="eza -l --icons --group-directories-first"

    # Extended views
    alias lld="eza -lD --icons"                    # Directories only
    alias llf="eza -lf --icons"                    # Files only
    alias lls="eza -l --icons --sort=size"         # Sort by size
    alias llt="eza -l --icons --sort=modified"     # Sort by time
    alias llr="eza -lR --icons --level=2"          # Recursive

    # Git-aware
    alias lg="eza -l --icons --git --git-ignore"   # Respect .gitignore
end

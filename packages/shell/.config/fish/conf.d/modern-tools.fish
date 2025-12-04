# Modern CLI tools configuration

# bat - better cat
if type -q bat
    alias cat="bat --paging=never"
    alias catp="bat"  # with pager
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -x MANROFFOPT "-c"
end

# ripgrep
if type -q rg
    set -x RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/config"
end

# fd - better find
if type -q fd
    alias find="fd"
end

# Useful aliases
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias ip="ip -color=auto"

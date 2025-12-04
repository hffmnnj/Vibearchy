# Vibearchy Zsh Environment
# Sourced for all shells (login, interactive, scripts)

# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
export XDG_SCRIPT_HOME="${XDG_SCRIPT_HOME:-$HOME/.local/script}"

# Zsh config location (for XDG compliance)
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# XDG Compliance for various tools
export CONAN_USER_HOME="$XDG_CONFIG_HOME"
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export LEIN_HOME="$XDG_DATA_HOME/lein"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/.ripgreprc"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export ANSIBLE_HOME="$XDG_CONFIG_HOME/ansible"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export MYSQL_HISTFILE="$XDG_DATA_HOME/mysql_history"
export OMNISHARPHOME="$XDG_CONFIG_HOME/omnisharp"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export W3M_DIR="$XDG_DATA_HOME/w3m"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export WINEPREFIX="$XDG_DATA_HOME/wine"

# Zsh history (XDG compliant)
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000

# Editor
export EDITOR="nvim"
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"
export PAGER="bat"

# GPG
export GPG_TTY=$(tty)

# Starship
export STARSHIP_LOG="error"

# Atac
export ATAC_KEY_BINDINGS="$XDG_CONFIG_HOME/atac/vim_key_bindings.toml"

# Path setup
typeset -U path  # Unique entries only
path=(
    "$XDG_BIN_HOME"
    "$XDG_BIN_HOME/color-scripts"
    "$XDG_SCRIPT_HOME"
    "$GOPATH/bin"
    "$CARGO_HOME/bin"
    "/usr/lib/rustup/bin"
    "/usr/lib/go/bin"
    "$HOME/.dotnet/tools"
    "$XDG_DATA_HOME/bob/nvim-bin"
    "$XDG_DATA_HOME/npm/bin"
    "$XDG_DATA_HOME/nvim/mason/bin"
    "$HOME/.yarn/bin"
    "$XDG_DATA_HOME/pnpm"
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
    $path
)
export PATH

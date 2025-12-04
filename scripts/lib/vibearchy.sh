#!/bin/bash
#
# Vibearchy Core Library
# Shared functions for all Vibearchy scripts
#
# Source this file in your scripts:
#   source "$(dirname "$0")/../lib/vibearchy.sh"
#
# Or with absolute path:
#   source "$VIBEARCHY_DIR/scripts/lib/vibearchy.sh"

# Prevent double-sourcing
[[ -n "$_VIBEARCHY_LIB_LOADED" ]] && return 0
readonly _VIBEARCHY_LIB_LOADED=1

# Version
readonly VIBEARCHY_VERSION="2.0.0"

# ═══════════════════════════════════════════════════════════════════════════════
# ENVIRONMENT DETECTION
# ═══════════════════════════════════════════════════════════════════════════════

# Detect Vibearchy installation directory
detect_vibearchy_dir() {
    local script_path="${BASH_SOURCE[1]:-$0}"
    local real_path
    real_path="$(realpath "$script_path" 2>/dev/null)" || real_path="$script_path"

    # Walk up to find the Vibearchy root (contains packages/ and scripts/)
    local dir="${real_path%/*}"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/packages" && -d "$dir/scripts" ]]; then
            echo "$dir"
            return 0
        fi
        dir="${dir%/*}"
    done

    # Fallback to common locations
    for loc in "$HOME/Documents/Vibearchy" "$HOME/.vibearchy" "$HOME/vibearchy"; do
        [[ -d "$loc/packages" ]] && echo "$loc" && return 0
    done

    return 1
}

# Set global paths
export VIBEARCHY_DIR="${VIBEARCHY_DIR:-$(detect_vibearchy_dir)}"
export VIBEARCHY_PACKAGES="$VIBEARCHY_DIR/packages"
export VIBEARCHY_SCRIPTS="$VIBEARCHY_DIR/scripts"
export VIBEARCHY_LIB="$VIBEARCHY_DIR/scripts/lib"

# ═══════════════════════════════════════════════════════════════════════════════
# COLOR DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Reset
readonly NC='\033[0m'

# Standard colors
readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'

# Bold colors
readonly BOLD='\033[1m'
readonly BOLD_RED='\033[1;31m'
readonly BOLD_GREEN='\033[1;32m'
readonly BOLD_YELLOW='\033[1;33m'
readonly BOLD_BLUE='\033[1;34m'
readonly BOLD_PURPLE='\033[1;35m'
readonly BOLD_CYAN='\033[1;36m'

# Dim
readonly DIM='\033[2m'

# Vibearchy theme colors (for special styling)
readonly VIBE_ACCENT='\033[38;2;125;207;255m'    # Sky blue #7dcfff
readonly VIBE_BG='\033[48;2;17;17;27m'            # Crust #11111b
readonly VIBE_SUCCESS='\033[38;2;166;227;161m'   # Green #a6e3a1
readonly VIBE_ERROR='\033[38;2;243;139;168m'     # Red #f38ba8
readonly VIBE_WARN='\033[38;2;249;226;175m'      # Yellow #f9e2af

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Print info message
vibe_log() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# Print success message
vibe_ok() {
    echo -e "${GREEN}[OK]${NC} $*"
}

# Print warning message
vibe_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Print error message
vibe_err() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Print error and exit
vibe_die() {
    vibe_err "$*"
    exit 1
}

# Print step indicator
vibe_step() {
    echo -e "${VIBE_ACCENT}[${1}]${NC} ${2}"
}

# Print header
vibe_header() {
    echo ""
    echo -e "${BOLD}${VIBE_ACCENT}═══ $* ═══${NC}"
    echo ""
}

# Print subheader
vibe_subheader() {
    echo -e "${CYAN}─── $* ───${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ASCII BANNER
# ═══════════════════════════════════════════════════════════════════════════════

vibe_banner() {
    echo -e "${VIBE_ACCENT}"
    cat << 'EOF'

  ██╗   ██╗██╗██████╗ ███████╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗   ██╗
  ██║   ██║██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝
  ██║   ██║██║██████╔╝█████╗  ███████║██████╔╝██║     ███████║ ╚████╔╝
  ╚██╗ ██╔╝██║██╔══██╗██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║  ╚██╔╝
   ╚████╔╝ ██║██████╔╝███████╗██║  ██║██║  ██║╚██████╗██║  ██║   ██║
    ╚═══╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝

EOF
    echo -e "                    ${DIM}Good vibes lead to good code${NC}"
    echo -e "                         ${DIM}v${VIBEARCHY_VERSION}${NC}"
    echo ""
}

# Compact banner for smaller scripts
vibe_banner_compact() {
    local title="${1:-Vibearchy}"
    echo -e "${VIBE_ACCENT}"
    echo "╔══════════════════════════════════════╗"
    printf "║%*s%s%*s║\n" $(( (38 - ${#title}) / 2 )) "" "$title" $(( (39 - ${#title}) / 2 )) ""
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# USER INTERACTION
# ═══════════════════════════════════════════════════════════════════════════════

# Prompt for yes/no confirmation
# Usage: vibe_confirm "Question?" && do_something
vibe_confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"  # Default: no

    local yn_hint
    case "$default" in
        y|Y) yn_hint="[Y/n]" ;;
        *)   yn_hint="[y/N]" ;;
    esac

    echo -en "${YELLOW}$prompt${NC} $yn_hint "
    read -r response

    case "${response:-$default}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Prompt with timeout
# Usage: vibe_confirm_timeout 30 "Question?" && do_something
vibe_confirm_timeout() {
    local timeout="$1"
    local prompt="${2:-Continue?}"
    local default="${3:-n}"

    echo -en "${YELLOW}$prompt${NC} [y/N] (${timeout}s timeout): "
    read -r -t "$timeout" response || response="$default"
    echo ""

    case "${response:-$default}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Select from options
# Usage: choice=$(vibe_select "Choose one" "opt1" "opt2" "opt3")
vibe_select() {
    local prompt="$1"
    shift
    local options=("$@")

    echo -e "${BOLD}$prompt${NC}"
    echo ""

    local i=1
    for opt in "${options[@]}"; do
        echo -e "  ${CYAN}$i)${NC} $opt"
        ((i++))
    done
    echo ""

    local choice
    while true; do
        read -p "Choice [1-${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            echo "${options[$((choice-1))]}"
            return 0
        fi
        vibe_warn "Invalid choice. Enter 1-${#options[@]}"
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEPENDENCY CHECKING
# ═══════════════════════════════════════════════════════════════════════════════

# Check if a command exists
vibe_has_cmd() {
    command -v "$1" &>/dev/null
}

# Check multiple dependencies
# Usage: vibe_check_deps stow hyprland waybar
vibe_check_deps() {
    local missing=()

    for dep in "$@"; do
        if ! vibe_has_cmd "$dep"; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        vibe_err "Missing dependencies: ${missing[*]}"
        return 1
    fi

    return 0
}

# Check and report dependencies
vibe_check_deps_verbose() {
    local all_ok=true

    for dep in "$@"; do
        if vibe_has_cmd "$dep"; then
            echo -e "  ${GREEN}✓${NC} $dep"
        else
            echo -e "  ${RED}✗${NC} $dep ${DIM}(missing)${NC}"
            all_ok=false
        fi
    done

    $all_ok
}

# ═══════════════════════════════════════════════════════════════════════════════
# AUR HELPER DETECTION
# ═══════════════════════════════════════════════════════════════════════════════

# Detect available AUR helper
vibe_detect_aur() {
    for helper in yay paru; do
        if vibe_has_cmd "$helper"; then
            echo "$helper"
            return 0
        fi
    done
    return 1
}

# Get AUR helper or die
vibe_require_aur() {
    local helper
    helper=$(vibe_detect_aur) || vibe_die "No AUR helper found! Install yay or paru first."
    echo "$helper"
}

# Install packages via AUR helper
# Usage: vibe_install pkg1 pkg2 pkg3
vibe_install() {
    local helper
    helper=$(vibe_require_aur)

    vibe_log "Installing: $*"
    "$helper" -S --needed --noconfirm "$@"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PACKAGE LIST HANDLING (.lst files)
# ═══════════════════════════════════════════════════════════════════════════════

# Read packages from a .lst file
# Ignores comments (#) and empty lines
vibe_read_lst() {
    local file="$1"

    [[ -f "$file" ]] || { vibe_err "Package list not found: $file"; return 1; }

    grep -v '^\s*#' "$file" | grep -v '^\s*$' | tr '\n' ' '
}

# Install packages from a .lst file
vibe_install_lst() {
    local file="$1"
    local packages

    packages=$(vibe_read_lst "$file") || return 1

    if [[ -n "$packages" ]]; then
        # shellcheck disable=SC2086
        vibe_install $packages
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# DESKTOP NOTIFICATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Send desktop notification
vibe_notify() {
    local title="$1"
    local body="${2:-}"
    local icon="${3:-dialog-information}"
    local urgency="${4:-normal}"  # low, normal, critical

    if vibe_has_cmd notify-send; then
        notify-send -u "$urgency" -i "$icon" "$title" "$body"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# FILE OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Create backup of a file
vibe_backup() {
    local file="$1"
    local backup="${file}.vibe-backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -e "$file" ]]; then
        cp -r "$file" "$backup"
        vibe_log "Backed up: $file → $backup"
    fi
}

# Safe symlink creation
vibe_link() {
    local src="$1"
    local dst="$2"

    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        vibe_backup "$dst"
        rm -rf "$dst"
    fi

    ln -s "$src" "$dst"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SYSTEM INFORMATION
# ═══════════════════════════════════════════════════════════════════════════════

# Get uptime in human readable format
vibe_uptime() {
    uptime -p 2>/dev/null | sed 's/^up //' || echo "unknown"
}

# Check if running in Hyprland
vibe_is_hyprland() {
    [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]
}

# Check if running in Wayland
vibe_is_wayland() {
    [[ -n "$WAYLAND_DISPLAY" ]]
}

# ═══════════════════════════════════════════════════════════════════════════════
# ROFI INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════════

# Standard rofi invocation with Vibearchy theme
vibe_rofi() {
    local prompt="${1:-Vibearchy}"
    local mesg="${2:-}"
    local theme="${3:-$HOME/.config/rofi/theme/vibearchy.rasi}"

    local args=(
        -dmenu
        -i
        -p "$prompt"
    )

    [[ -n "$mesg" ]] && args+=(-mesg "$mesg")
    [[ -f "$theme" ]] && args+=(-theme "$theme")

    rofi "${args[@]}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Run command silently (suppress stdout/stderr)
vibe_quiet() {
    "$@" &>/dev/null
}

# Check if running as root
vibe_is_root() {
    [[ $EUID -eq 0 ]]
}

# Ensure not running as root
vibe_no_root() {
    vibe_is_root && vibe_die "Do not run this script as root!"
}

# Print separator line
vibe_line() {
    echo -e "${DIM}────────────────────────────────────────${NC}"
}

# Print a spinner while command runs
vibe_spinner() {
    local pid=$1
    local msg="${2:-Working}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYAN}[%s]${NC} %s..." "${spin:i++%${#spin}:1}" "$msg"
        sleep 0.1
    done
    printf "\r"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

# Validate environment on load
_vibe_init() {
    # Ensure we have a valid Vibearchy directory
    if [[ -z "$VIBEARCHY_DIR" ]] || [[ ! -d "$VIBEARCHY_DIR" ]]; then
        echo "Warning: Could not detect Vibearchy directory" >&2
    fi
}

_vibe_init

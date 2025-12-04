#!/bin/bash
#
# Vibearchy Stow Manager
# Deploy dotfiles using GNU Stow
#
# Usage:
#   ./stow.sh                 # Interactive mode
#   ./stow.sh status          # Show stow status
#   ./stow.sh stow <pkg>      # Stow a package
#   ./stow.sh unstow <pkg>    # Unstow a package
#   ./stow.sh stow-all        # Stow all packages
#

set -e

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export VIBEARCHY_DIR="$(dirname "$SCRIPT_DIR")"

# Source the core library
source "$SCRIPT_DIR/lib/vibearchy.sh"
source "$SCRIPT_DIR/lib/icons.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# PACKAGE DISCOVERY
# ═══════════════════════════════════════════════════════════════════════════════

# Get list of available packages (auto-discovered)
get_packages() {
    local packages=()
    for dir in "$VIBEARCHY_PACKAGES"/*/; do
        [[ -d "$dir" ]] && packages+=("$(basename "$dir")")
    done
    echo "${packages[@]}"
}

# Get package description from .desc file or generate default
get_pkg_desc() {
    local pkg="$1"
    local desc_file="$VIBEARCHY_PACKAGES/$pkg/.desc"

    if [[ -f "$desc_file" ]]; then
        cat "$desc_file"
    else
        # Generate description based on package name
        case "$pkg" in
            hypr)       echo "Hyprland window manager" ;;
            waybar)     echo "Status bar" ;;
            rofi)       echo "Application launcher + menus" ;;
            shell)      echo "Fish shell + Starship prompt" ;;
            terminals)  echo "Ghostty + Kitty terminals" ;;
            nvim)       echo "Neovim editor" ;;
            swaync)     echo "Notification center" ;;
            wallpapers) echo "Curated wallpaper collection" ;;
            ssh)        echo "SSH config template" ;;
            gtk)        echo "GTK theme settings" ;;
            bat)        echo "Bat syntax highlighter" ;;
            btop)       echo "System monitor" ;;
            fastfetch)  echo "System info fetcher" ;;
            lazygit)    echo "Git TUI" ;;
            yazi)       echo "File manager" ;;
            *)          echo "Configuration package" ;;
        esac
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STOW OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Check if a package is stowed (has active symlinks)
is_stowed() {
    local pkg="$1"
    local pkg_path="$VIBEARCHY_PACKAGES/$pkg"

    # Find any file in the package
    local test_file
    test_file=$(find "$pkg_path" -type f 2>/dev/null | head -1)

    if [[ -n "$test_file" ]]; then
        local rel_path="${test_file#$pkg_path/}"
        [[ -L "$HOME/$rel_path" ]] && return 0
    fi

    return 1
}

# Stow a single package
do_stow() {
    local pkg="$1"
    local pkg_path="$VIBEARCHY_PACKAGES/$pkg"

    if [[ ! -d "$pkg_path" ]]; then
        vibe_err "Package '$pkg' not found"
        return 1
    fi

    vibe_step "$ICON_FOLDER" "Stowing $pkg..."

    if stow -v -d "$VIBEARCHY_PACKAGES" -t "$HOME" --restow "$pkg" 2>&1; then
        vibe_ok "Stowed $pkg"
        return 0
    else
        vibe_warn "Issue stowing $pkg (may need --adopt)"
        return 1
    fi
}

# Unstow a single package
do_unstow() {
    local pkg="$1"
    local pkg_path="$VIBEARCHY_PACKAGES/$pkg"

    if [[ ! -d "$pkg_path" ]]; then
        vibe_err "Package '$pkg' not found"
        return 1
    fi

    vibe_step "$ICON_FOLDER" "Unstowing $pkg..."

    if stow -v -d "$VIBEARCHY_PACKAGES" -t "$HOME" -D "$pkg" 2>&1; then
        vibe_ok "Unstowed $pkg"
        return 0
    else
        vibe_err "Failed to unstow $pkg"
        return 1
    fi
}

# Adopt existing files into the repo
do_adopt() {
    local pkg="$1"
    local pkg_path="$VIBEARCHY_PACKAGES/$pkg"

    if [[ ! -d "$pkg_path" ]]; then
        vibe_err "Package '$pkg' not found"
        return 1
    fi

    vibe_warn "Adopting existing files for $pkg..."
    vibe_warn "This will MOVE your existing files INTO the Vibearchy repo!"
    echo ""

    if vibe_confirm "Are you sure?"; then
        stow -v -d "$VIBEARCHY_PACKAGES" -t "$HOME" --adopt "$pkg" 2>&1
        vibe_ok "Adopted $pkg - your files are now in the repo"
    else
        vibe_log "Cancelled"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMMANDS
# ═══════════════════════════════════════════════════════════════════════════════

cmd_list() {
    vibe_subheader "Available Packages"
    echo ""

    local packages
    read -ra packages <<< "$(get_packages)"

    for pkg in "${packages[@]}"; do
        local desc
        desc=$(get_pkg_desc "$pkg")
        printf "  ${CYAN}%-14s${NC} %s\n" "$pkg" "$desc"
    done

    echo ""
}

cmd_status() {
    vibe_subheader "Package Status"
    echo ""

    local packages
    read -ra packages <<< "$(get_packages)"

    for pkg in "${packages[@]}"; do
        local desc
        desc=$(get_pkg_desc "$pkg")

        if is_stowed "$pkg"; then
            printf "  ${GREEN}$ICON_CHECK${NC} %-14s ${DIM}%s${NC}\n" "$pkg" "$desc"
        else
            printf "  ${RED}$ICON_CROSS${NC} %-14s ${DIM}%s${NC}\n" "$pkg" "$desc"
        fi
    done

    echo ""
    echo -e "${DIM}$ICON_CHECK = stowed, $ICON_CROSS = not stowed${NC}"
    echo ""
}

cmd_stow() {
    local pkg="$1"

    if [[ -z "$pkg" ]]; then
        vibe_err "Please specify a package"
        cmd_list
        return 1
    fi

    do_stow "$pkg"
}

cmd_unstow() {
    local pkg="$1"

    if [[ -z "$pkg" ]]; then
        vibe_err "Please specify a package"
        cmd_list
        return 1
    fi

    do_unstow "$pkg"
}

cmd_stow_all() {
    vibe_subheader "Stowing All Packages"
    echo ""

    local packages
    read -ra packages <<< "$(get_packages)"
    local count=0
    local failed=0

    for pkg in "${packages[@]}"; do
        if do_stow "$pkg"; then
            ((count++))
        else
            ((failed++))
        fi
    done

    echo ""
    vibe_ok "Stowed $count packages"
    [[ $failed -gt 0 ]] && vibe_warn "$failed packages had issues"
}

cmd_unstow_all() {
    vibe_subheader "Unstowing All Packages"
    echo ""

    if ! vibe_confirm "Unstow ALL packages?"; then
        vibe_log "Cancelled"
        return 0
    fi

    local packages
    read -ra packages <<< "$(get_packages)"

    for pkg in "${packages[@]}"; do
        do_unstow "$pkg"
    done

    echo ""
    vibe_ok "All packages unstowed!"
}

cmd_adopt() {
    local pkg="$1"

    if [[ -z "$pkg" ]]; then
        vibe_err "Please specify a package"
        cmd_list
        return 1
    fi

    do_adopt "$pkg"
}

cmd_interactive() {
    vibe_subheader "Interactive Stow Manager"
    echo ""

    local packages
    read -ra packages <<< "$(get_packages)"

    echo "Select an action:"
    echo ""
    echo -e "  ${CYAN}1)${NC} Stow a package"
    echo -e "  ${CYAN}2)${NC} Unstow a package"
    echo -e "  ${CYAN}3)${NC} Stow all packages"
    echo -e "  ${CYAN}4)${NC} Show status"
    echo -e "  ${CYAN}5)${NC} Adopt existing files"
    echo -e "  ${CYAN}6)${NC} Exit"
    echo ""

    read -p "Choice [1-6]: " choice
    echo ""

    case "$choice" in
        1)
            cmd_list
            read -p "Package to stow: " pkg
            [[ -n "$pkg" ]] && do_stow "$pkg"
            ;;
        2)
            cmd_list
            read -p "Package to unstow: " pkg
            [[ -n "$pkg" ]] && do_unstow "$pkg"
            ;;
        3)
            cmd_stow_all
            ;;
        4)
            cmd_status
            ;;
        5)
            cmd_list
            read -p "Package to adopt: " pkg
            [[ -n "$pkg" ]] && do_adopt "$pkg"
            ;;
        6)
            vibe_log "Goodbye!"
            ;;
        *)
            vibe_err "Invalid choice"
            ;;
    esac
}

show_help() {
    echo "Vibearchy Stow Manager"
    echo ""
    echo "Usage: $0 [command] [package]"
    echo ""
    echo "Commands:"
    echo "  (none)          Interactive mode"
    echo "  list            List available packages"
    echo "  status          Show stow status of all packages"
    echo "  stow <pkg>      Stow a single package"
    echo "  stow-all        Stow all packages"
    echo "  unstow <pkg>    Unstow a single package"
    echo "  unstow-all      Unstow all packages"
    echo "  adopt <pkg>     Adopt existing files into repo"
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive mode"
    echo "  $0 stow hypr          # Stow Hyprland config"
    echo "  $0 stow-all           # Stow everything"
    echo "  $0 adopt shell        # Move existing files into repo"
    echo "  $0 status             # Check what's stowed"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Check for stow
    if ! vibe_has_cmd stow; then
        vibe_err "GNU Stow is not installed!"
        echo "Install with: yay -S stow"
        exit 1
    fi

    # Show mini banner
    echo ""
    echo -e "${VIBE_ACCENT}${BOLD}Vibearchy${NC} ${DIM}Stow Manager${NC}"
    vibe_line

    case "${1:-}" in
        list)
            cmd_list
            ;;
        status)
            cmd_status
            ;;
        stow)
            cmd_stow "$2"
            ;;
        stow-all)
            cmd_stow_all
            ;;
        unstow)
            cmd_unstow "$2"
            ;;
        unstow-all)
            cmd_unstow_all
            ;;
        adopt)
            cmd_adopt "$2"
            ;;
        -h|--help|help)
            show_help
            ;;
        "")
            cmd_interactive
            ;;
        *)
            vibe_err "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

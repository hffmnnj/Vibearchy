#!/bin/bash
#
# Vibearchy Installer
# Modular installation with .lst package support
#
# Usage:
#   ./install.sh              # Interactive installation
#   ./install.sh --quick      # Quick install with defaults
#   ./install.sh --deps-only  # Only install dependencies
#   ./install.sh --stow-only  # Only stow configs
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

# Installation flags
FLAG_QUICK=false
FLAG_DEPS_ONLY=false
FLAG_STOW_ONLY=false
FLAG_SKIP_CONFIRM=false

# Track what's been done
DEPS_INSTALLED=false
CONFIGS_STOWED=false

# ═══════════════════════════════════════════════════════════════════════════════
# ARGUMENT PARSING
# ═══════════════════════════════════════════════════════════════════════════════

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --quick|-q)
                FLAG_QUICK=true
                FLAG_SKIP_CONFIRM=true
                shift
                ;;
            --deps-only|-d)
                FLAG_DEPS_ONLY=true
                shift
                ;;
            --stow-only|-s)
                FLAG_STOW_ONLY=true
                shift
                ;;
            --yes|-y)
                FLAG_SKIP_CONFIRM=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                vibe_err "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo "Vibearchy Installer"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -q, --quick       Quick install with defaults (essential packages)"
    echo "  -d, --deps-only   Only install dependencies, skip config stowing"
    echo "  -s, --stow-only   Only stow configs, skip dependency installation"
    echo "  -y, --yes         Skip all confirmation prompts"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                # Interactive installation"
    echo "  $0 --quick        # Fast install with sensible defaults"
    echo "  $0 --deps-only    # Just install packages"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1: PRE-FLIGHT CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

phase_preflight() {
    vibe_header "Phase 1: Pre-flight Checks"

    # Ensure not root
    vibe_no_root

    # Check for AUR helper
    vibe_log "Checking for AUR helper..."
    local aur_helper
    if aur_helper=$(vibe_detect_aur); then
        vibe_ok "Found $aur_helper"
    else
        vibe_err "No AUR helper found!"
        echo ""
        echo "Install yay with:"
        echo "  git clone https://aur.archlinux.org/yay.git"
        echo "  cd yay && makepkg -si"
        echo ""
        exit 1
    fi

    # Check for stow
    vibe_log "Checking for GNU Stow..."
    if vibe_has_cmd stow; then
        vibe_ok "GNU Stow installed"
    else
        vibe_warn "GNU Stow not installed"
        if $FLAG_SKIP_CONFIRM || vibe_confirm "Install stow now?"; then
            vibe_install stow
        else
            vibe_die "GNU Stow is required"
        fi
    fi

    # Show Vibearchy directory
    vibe_log "Vibearchy directory: $VIBEARCHY_DIR"

    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2: DEPENDENCY INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

phase_deps() {
    vibe_header "Phase 2: Install Dependencies"

    if $FLAG_STOW_ONLY; then
        vibe_log "Skipping dependencies (--stow-only)"
        return 0
    fi

    local pkg_dir="$SCRIPT_DIR/packages"
    local available_lists=()

    # Find available .lst files
    for lst in "$pkg_dir"/*.lst; do
        [[ -f "$lst" ]] && available_lists+=("$(basename "$lst" .lst)")
    done

    if [[ ${#available_lists[@]} -eq 0 ]]; then
        vibe_warn "No package lists found in $pkg_dir"
        return 0
    fi

    # Quick mode: install core + hyprland + rofi-deps
    if $FLAG_QUICK; then
        vibe_log "Quick mode: Installing essential packages..."
        for lst in core hyprland rofi-deps; do
            local file="$pkg_dir/$lst.lst"
            if [[ -f "$file" ]]; then
                vibe_step "$ICON_PACKAGE" "Installing $lst packages..."
                vibe_install_lst "$file"
            fi
        done
        DEPS_INSTALLED=true
        return 0
    fi

    # Interactive mode
    echo "Available package lists:"
    echo ""

    local i=1
    for lst in "${available_lists[@]}"; do
        local count
        count=$(grep -v '^\s*#' "$pkg_dir/$lst.lst" 2>/dev/null | grep -v '^\s*$' | wc -l)
        echo -e "  ${CYAN}$i)${NC} $lst ${DIM}($count packages)${NC}"
        ((i++))
    done
    echo -e "  ${CYAN}$i)${NC} ${BOLD}All of the above${NC}"
    echo -e "  ${CYAN}$((i+1)))${NC} Skip dependency installation"
    echo ""

    read -p "Select package lists (space-separated, e.g., '1 2 3'): " selections

    if [[ "$selections" == "$((i+1))" ]]; then
        vibe_log "Skipping dependency installation"
        return 0
    fi

    if [[ "$selections" == "$i" ]]; then
        selections=$(seq 1 ${#available_lists[@]} | tr '\n' ' ')
    fi

    local selected_lists=()
    for num in $selections; do
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#available_lists[@]} )); then
            selected_lists+=("${available_lists[$((num-1))]}")
        fi
    done

    if [[ ${#selected_lists[@]} -gt 0 ]]; then
        echo ""
        vibe_log "Installing: ${selected_lists[*]}"
        echo ""

        for lst in "${selected_lists[@]}"; do
            vibe_step "$ICON_PACKAGE" "Installing $lst..."
            vibe_install_lst "$pkg_dir/$lst.lst"
        done

        DEPS_INSTALLED=true
    fi

    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3: STOW CONFIGURATIONS
# ═══════════════════════════════════════════════════════════════════════════════

phase_stow() {
    vibe_header "Phase 3: Stow Configurations"

    if $FLAG_DEPS_ONLY; then
        vibe_log "Skipping stow (--deps-only)"
        return 0
    fi

    # Essential packages for quick mode
    local essential_pkgs=(hypr waybar rofi shell terminals)
    local all_pkgs=()

    # Find all stow packages
    for dir in "$VIBEARCHY_PACKAGES"/*/; do
        [[ -d "$dir" ]] && all_pkgs+=("$(basename "$dir")")
    done

    if [[ ${#all_pkgs[@]} -eq 0 ]]; then
        vibe_warn "No packages found in $VIBEARCHY_PACKAGES"
        return 0
    fi

    # Quick mode: stow essentials
    if $FLAG_QUICK; then
        vibe_log "Quick mode: Stowing essential configs..."
        for pkg in "${essential_pkgs[@]}"; do
            if [[ -d "$VIBEARCHY_PACKAGES/$pkg" ]]; then
                vibe_step "$ICON_FOLDER" "Stowing $pkg..."
                stow -v -d "$VIBEARCHY_PACKAGES" -t "$HOME" --restow "$pkg" 2>&1 | head -5
            fi
        done
        CONFIGS_STOWED=true
        return 0
    fi

    # Interactive mode
    echo "Available configuration packages:"
    echo ""

    local i=1
    for pkg in "${all_pkgs[@]}"; do
        # Check if already stowed
        local status="${RED}○${NC}"
        local test_file
        test_file=$(find "$VIBEARCHY_PACKAGES/$pkg" -type f 2>/dev/null | head -1)
        if [[ -n "$test_file" ]]; then
            local rel_path="${test_file#$VIBEARCHY_PACKAGES/$pkg/}"
            [[ -L "$HOME/$rel_path" ]] && status="${GREEN}●${NC}"
        fi

        echo -e "  ${CYAN}$i)${NC} $status $pkg"
        ((i++))
    done
    echo -e "  ${CYAN}$i)${NC} ${BOLD}Stow all packages${NC}"
    echo -e "  ${CYAN}$((i+1)))${NC} Essential only (${essential_pkgs[*]})"
    echo -e "  ${CYAN}$((i+2)))${NC} Skip stowing"
    echo ""
    echo -e "${DIM}● = stowed, ○ = not stowed${NC}"
    echo ""

    read -p "Select packages (space-separated): " selections

    local max_option=$((i+2))
    local all_option=$i
    local essential_option=$((i+1))
    local skip_option=$((i+2))

    if [[ "$selections" == "$skip_option" ]]; then
        vibe_log "Skipping stow"
        return 0
    fi

    local selected_pkgs=()

    if [[ "$selections" == "$all_option" ]]; then
        selected_pkgs=("${all_pkgs[@]}")
    elif [[ "$selections" == "$essential_option" ]]; then
        selected_pkgs=("${essential_pkgs[@]}")
    else
        for num in $selections; do
            if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#all_pkgs[@]} )); then
                selected_pkgs+=("${all_pkgs[$((num-1))]}")
            fi
        done
    fi

    if [[ ${#selected_pkgs[@]} -gt 0 ]]; then
        echo ""
        vibe_log "Stowing: ${selected_pkgs[*]}"
        echo ""

        for pkg in "${selected_pkgs[@]}"; do
            vibe_step "$ICON_FOLDER" "Stowing $pkg..."
            if stow -v -d "$VIBEARCHY_PACKAGES" -t "$HOME" --restow "$pkg" 2>&1; then
                vibe_ok "Stowed $pkg"
            else
                vibe_warn "Issue stowing $pkg (may need --adopt)"
            fi
        done

        CONFIGS_STOWED=true
    fi

    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4: WALLPAPERS
# ═══════════════════════════════════════════════════════════════════════════════

WALLS_DOWNLOADED=false

phase_wallpapers() {
    vibe_header "Phase 4: Wallpaper Packs"

    if $FLAG_STOW_ONLY; then
        vibe_log "Skipping wallpapers (stow-only mode)"
        return 0
    fi

    echo -e "${DIM}Vibearchy includes curated wallpaper packs from open-source collections.${NC}"
    echo ""

    if $FLAG_QUICK; then
        # Quick mode: download all
        vibe_log "Quick mode: downloading all wallpaper packs..."
        "$SCRIPT_DIR/wallpapers.sh" all
        WALLS_DOWNLOADED=true
    else
        # Interactive mode
        echo -e "${BOLD}Select wallpaper packs to download:${NC}"
        echo ""
        echo -e "  ${CYAN}1)${NC} Riced/Anime    - Cyberpunk, anime, aesthetic vibes"
        echo -e "  ${CYAN}2)${NC} Minimal/Clean  - Gradients, macOS-style, solid colors"
        echo -e "  ${CYAN}3)${NC} Nature/Space   - Landscapes, cosmos, mountains"
        echo -e "  ${CYAN}4)${NC} All Categories - Download everything (~100 wallpapers)"
        echo -e "  ${CYAN}0)${NC} Skip           - Download later via wallpaper menu"
        echo ""

        read -p "Enter choices (e.g., 1 3 or 4): " -a choices

        for choice in "${choices[@]}"; do
            case "$choice" in
                1) "$SCRIPT_DIR/wallpapers.sh" riced; WALLS_DOWNLOADED=true ;;
                2) "$SCRIPT_DIR/wallpapers.sh" minimal; WALLS_DOWNLOADED=true ;;
                3) "$SCRIPT_DIR/wallpapers.sh" nature; WALLS_DOWNLOADED=true ;;
                4) "$SCRIPT_DIR/wallpapers.sh" all; WALLS_DOWNLOADED=true ;;
                0) vibe_log "Skipping wallpapers (can download later)" ;;
                *) ;;
            esac
        done
    fi

    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 5: POST-INSTALL
# ═══════════════════════════════════════════════════════════════════════════════

phase_post() {
    vibe_header "Phase 5: Post-Installation"

    # Summary
    vibe_subheader "Summary"
    echo ""
    echo -e "  Dependencies: $($DEPS_INSTALLED && echo "${GREEN}Installed${NC}" || echo "${YELLOW}Skipped${NC}")"
    echo -e "  Configs:      $($CONFIGS_STOWED && echo "${GREEN}Stowed${NC}" || echo "${YELLOW}Skipped${NC}")"
    echo -e "  Wallpapers:   $($WALLS_DOWNLOADED && echo "${GREEN}Downloaded${NC}" || echo "${YELLOW}Skipped${NC}")"
    echo ""

    # Tips
    vibe_subheader "Next Steps"
    echo ""
    echo "  1. Log out and back in, or restart Hyprland"
    echo "  2. Check your configs: ./scripts/stow.sh status"
    echo "  3. Install apps:       ./scripts/apps.sh"
    echo ""

    # Useful commands
    vibe_subheader "Useful Commands"
    echo ""
    echo "  ./scripts/stow.sh stow <pkg>    # Stow a specific package"
    echo "  ./scripts/stow.sh unstow <pkg>  # Remove package symlinks"
    echo "  ./scripts/stow.sh status        # Check stow status"
    echo "  ./scripts/apps.sh               # Install recommended apps"
    echo ""

    # Reload hint for Hyprland
    if vibe_is_hyprland; then
        vibe_notify "Vibearchy" "Installation complete! Press Super+Shift+R to reload Hyprland."
        echo -e "${YELLOW}Tip:${NC} Press ${BOLD}Super+Shift+R${NC} to reload Hyprland"
        echo ""
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    parse_args "$@"

    # Show banner
    vibe_banner

    # Confirm before starting
    if ! $FLAG_SKIP_CONFIRM; then
        echo -e "${DIM}This installer will set up Vibearchy on your system.${NC}"
        echo ""
        vibe_confirm "Ready to begin?" || { echo "Aborted."; exit 0; }
        echo ""
    fi

    # Run phases
    phase_preflight
    phase_deps
    phase_stow
    phase_wallpapers
    phase_post

    # Done
    vibe_line
    echo ""
    echo -e "${VIBE_SUCCESS}${BOLD}Vibearchy installation complete!${NC}"
    echo -e "${DIM}Good vibes lead to good code.${NC}"
    echo ""
}

main "$@"

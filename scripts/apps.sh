#!/bin/bash
#
# Vibearchy App Installer
# Install recommended software for a vibe-driven workflow
#
# Usage:
#   ./apps.sh                       # Interactive mode
#   ./apps.sh list                  # List all available packages
#   ./apps.sh install <list>        # Install a specific .lst file
#   ./apps.sh quick <preset>        # Quick install preset
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

PKG_DIR="$SCRIPT_DIR/packages"

# Track selected packages
declare -A SELECTED

# Special packages requiring npm or pip
declare -A SPECIAL_INSTALL=(
    ["claude-code-cli"]="npm:@anthropic-ai/claude-code"
    ["open-interpreter"]="pip:open-interpreter"
)

# ═══════════════════════════════════════════════════════════════════════════════
# PACKAGE LIST FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Get available .lst files
get_available_lists() {
    local lists=()
    for lst in "$PKG_DIR"/*.lst; do
        [[ -f "$lst" ]] && lists+=("$(basename "$lst" .lst)")
    done
    echo "${lists[@]}"
}

# Get icon for a package list
get_list_icon() {
    case "$1" in
        core)        echo "$ICON_PACKAGE" ;;
        hyprland)    echo "$ICON_HYPRLAND" ;;
        development) echo "$ICON_CODE" ;;
        ai-tools)    echo "$ICON_AI" ;;
        privacy)     echo "$ICON_LOCK" ;;
        productivity) echo "$ICON_FOLDER" ;;
        creativity)  echo "$ICON_CAMERA" ;;
        utilities)   echo "$ICON_SETTINGS" ;;
        rofi-deps)   echo "$ICON_MENU" ;;
        gaming)      echo "$ICON_GAMEPAD" ;;
        *)           echo "$ICON_PACKAGE" ;;
    esac
}

# Get description for a package list
get_list_desc() {
    case "$1" in
        core)        echo "Core system utilities" ;;
        hyprland)    echo "Hyprland ecosystem" ;;
        development) echo "Development tools" ;;
        ai-tools)    echo "AI CLI tools" ;;
        privacy)     echo "Privacy & security" ;;
        productivity) echo "Productivity apps" ;;
        creativity)  echo "Creative tools" ;;
        utilities)   echo "System utilities" ;;
        rofi-deps)   echo "Rofi menu dependencies" ;;
        gaming)      echo "Gaming (optional)" ;;
        *)           echo "Package list" ;;
    esac
}

# Check if a package is installed
is_installed() {
    local pkg="$1"

    # Special case for npm/pip packages
    case "$pkg" in
        claude-code-cli)
            command -v claude &>/dev/null && return 0
            return 1
            ;;
        open-interpreter)
            command -v interpreter &>/dev/null && return 0
            pip show open-interpreter &>/dev/null 2>&1 && return 0
            return 1
            ;;
    esac

    # Standard pacman check
    pacman -Qi "$pkg" &>/dev/null 2>&1
}

# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Show packages from a .lst file
show_list_packages() {
    local lst="$1"
    local file="$PKG_DIR/$lst.lst"

    if [[ ! -f "$file" ]]; then
        vibe_err "List '$lst' not found"
        return 1
    fi

    local icon
    icon=$(get_list_icon "$lst")
    local desc
    desc=$(get_list_desc "$lst")

    echo ""
    echo -e "${BOLD}$icon $lst${NC} ${DIM}- $desc${NC}"
    vibe_line

    local packages
    packages=$(vibe_read_lst "$file")

    for pkg in $packages; do
        if is_installed "$pkg"; then
            echo -e "  ${GREEN}$ICON_CHECK${NC} $pkg ${DIM}(installed)${NC}"
        elif [[ "${SELECTED[$pkg]}" == "1" ]]; then
            echo -e "  ${YELLOW}$ICON_CHECK${NC} $pkg ${YELLOW}(selected)${NC}"
        else
            echo -e "  ${DIM}$ICON_CIRCLE${NC} $pkg"
        fi
    done
}

# Show all package lists
show_all_lists() {
    vibe_subheader "Available Package Lists"

    local lists
    read -ra lists <<< "$(get_available_lists)"

    for lst in "${lists[@]}"; do
        show_list_packages "$lst"
    done

    echo ""
}

# Show selected packages
show_selection() {
    if [[ ${#SELECTED[@]} -eq 0 ]]; then
        vibe_warn "No packages selected"
        return 1
    fi

    vibe_subheader "Selected Packages"
    echo ""

    local pacman_pkgs=()
    local npm_pkgs=()
    local pip_pkgs=()

    for pkg in "${!SELECTED[@]}"; do
        local method="pacman/AUR"

        if [[ -n "${SPECIAL_INSTALL[$pkg]}" ]]; then
            local type="${SPECIAL_INSTALL[$pkg]%%:*}"
            if [[ "$type" == "npm" ]]; then
                method="npm"
                npm_pkgs+=("$pkg")
            elif [[ "$type" == "pip" ]]; then
                method="pip"
                pip_pkgs+=("$pkg")
            fi
        else
            pacman_pkgs+=("$pkg")
        fi

        echo -e "  ${GREEN}$ICON_CHECK${NC} $pkg ${DIM}($method)${NC}"
    done

    echo ""
    echo -e "${DIM}Total: ${#SELECTED[@]} packages${NC}"
    echo ""
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# SELECTION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Select all packages from a .lst file
select_list() {
    local lst="$1"
    local file="$PKG_DIR/$lst.lst"

    if [[ ! -f "$file" ]]; then
        vibe_err "List '$lst' not found"
        return 1
    fi

    vibe_log "Selecting packages from $lst..."

    local packages
    packages=$(vibe_read_lst "$file")

    for pkg in $packages; do
        if ! is_installed "$pkg"; then
            SELECTED["$pkg"]="1"
        fi
    done
}

# Deselect all packages from a .lst file
deselect_list() {
    local lst="$1"
    local file="$PKG_DIR/$lst.lst"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local packages
    packages=$(vibe_read_lst "$file")

    for pkg in $packages; do
        unset "SELECTED[$pkg]"
    done
}

# Clear all selections
clear_selection() {
    SELECTED=()
    vibe_log "Selection cleared"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PRESETS
# ═══════════════════════════════════════════════════════════════════════════════

preset_essential() {
    vibe_log "Preset: Essential"
    select_list "core"
    select_list "privacy"
}

preset_developer() {
    vibe_log "Preset: Developer"
    select_list "core"
    select_list "privacy"
    select_list "development"
    select_list "ai-tools"
}

preset_rofi() {
    vibe_log "Preset: Rofi Dependencies"
    select_list "rofi-deps"
    select_list "ai-tools"
}

preset_full() {
    vibe_log "Preset: Full Vibearchy"
    local lists
    read -ra lists <<< "$(get_available_lists)"

    for lst in "${lists[@]}"; do
        [[ "$lst" != "gaming" ]] && select_list "$lst"
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

install_selected() {
    if [[ ${#SELECTED[@]} -eq 0 ]]; then
        vibe_warn "Nothing to install"
        return 0
    fi

    local pacman_pkgs=()
    local npm_pkgs=()
    local pip_pkgs=()

    # Sort packages by install method
    for pkg in "${!SELECTED[@]}"; do
        if [[ -n "${SPECIAL_INSTALL[$pkg]}" ]]; then
            local type="${SPECIAL_INSTALL[$pkg]%%:*}"
            local package="${SPECIAL_INSTALL[$pkg]#*:}"

            if [[ "$type" == "npm" ]]; then
                npm_pkgs+=("$package")
            elif [[ "$type" == "pip" ]]; then
                pip_pkgs+=("$package")
            fi
        else
            pacman_pkgs+=("$pkg")
        fi
    done

    # Install pacman/AUR packages
    if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
        vibe_step "$ICON_PACKAGE" "Installing ${#pacman_pkgs[@]} packages via AUR helper..."
        vibe_install "${pacman_pkgs[@]}"
    fi

    # Install npm packages
    if [[ ${#npm_pkgs[@]} -gt 0 ]]; then
        vibe_step "$ICON_CODE" "Installing npm packages..."
        for pkg in "${npm_pkgs[@]}"; do
            vibe_log "Installing $pkg globally..."
            npm install -g "$pkg"
        done
    fi

    # Install pip packages
    if [[ ${#pip_pkgs[@]} -gt 0 ]]; then
        vibe_step "$ICON_CODE" "Installing pip packages..."
        for pkg in "${pip_pkgs[@]}"; do
            vibe_log "Installing $pkg..."
            pip install --user "$pkg"
        done
    fi

    echo ""
    vibe_ok "Installation complete!"
}

# Install a specific .lst file directly
install_list() {
    local lst="$1"
    local file="$PKG_DIR/$lst.lst"

    if [[ ! -f "$file" ]]; then
        vibe_err "List '$lst' not found"
        return 1
    fi

    vibe_step "$ICON_PACKAGE" "Installing $lst packages..."
    vibe_install_lst "$file"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTERACTIVE MENU
# ═══════════════════════════════════════════════════════════════════════════════

interactive_menu() {
    while true; do
        clear
        vibe_banner

        echo -e "${BOLD}What would you like to do?${NC}"
        echo ""
        echo -e "  ${CYAN}1)${NC} Browse all packages"
        echo -e "  ${CYAN}2)${NC} Preset: ${GREEN}Essential${NC} (core + privacy)"
        echo -e "  ${CYAN}3)${NC} Preset: ${GREEN}Developer${NC} (core + dev + AI)"
        echo -e "  ${CYAN}4)${NC} Preset: ${GREEN}Rofi Deps${NC} (rofi menus + AI)"
        echo -e "  ${CYAN}5)${NC} Preset: ${GREEN}Full${NC} (everything except gaming)"
        echo -e "  ${CYAN}6)${NC} Select package lists"
        echo -e "  ${CYAN}7)${NC} View selection"
        echo -e "  ${CYAN}8)${NC} Install selected"
        echo -e "  ${CYAN}9)${NC} Clear selection"
        echo -e "  ${CYAN}q)${NC} Quit"
        echo ""

        read -p "Choice: " choice

        case "$choice" in
            1)
                clear
                vibe_banner
                show_all_lists
                read -p "Press Enter to continue..."
                ;;
            2)
                preset_essential
                show_selection && read -p "Press Enter to continue..."
                ;;
            3)
                preset_developer
                show_selection && read -p "Press Enter to continue..."
                ;;
            4)
                preset_rofi
                show_selection && read -p "Press Enter to continue..."
                ;;
            5)
                preset_full
                show_selection && read -p "Press Enter to continue..."
                ;;
            6)
                clear
                vibe_banner
                vibe_subheader "Select Package Lists"
                echo ""

                local lists
                read -ra lists <<< "$(get_available_lists)"
                local i=1

                for lst in "${lists[@]}"; do
                    local icon
                    icon=$(get_list_icon "$lst")
                    local desc
                    desc=$(get_list_desc "$lst")
                    echo -e "  ${CYAN}$i)${NC} $icon $lst ${DIM}- $desc${NC}"
                    ((i++))
                done

                echo ""
                read -p "Enter numbers (space-separated): " selections

                for num in $selections; do
                    if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#lists[@]} )); then
                        select_list "${lists[$((num-1))]}"
                    fi
                done

                show_selection || true
                read -p "Press Enter to continue..."
                ;;
            7)
                clear
                vibe_banner
                show_selection || true
                read -p "Press Enter to continue..."
                ;;
            8)
                clear
                vibe_banner
                if show_selection; then
                    if vibe_confirm "Proceed with installation?"; then
                        install_selected
                    fi
                fi
                read -p "Press Enter to continue..."
                ;;
            9)
                clear_selection
                ;;
            q|Q)
                echo ""
                vibe_log "Good vibes! $ICON_WAVE"
                echo ""
                exit 0
                ;;
            *)
                vibe_err "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════════════════════

show_help() {
    echo "Vibearchy App Installer"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  (none)              Interactive mode"
    echo "  list                List all available packages"
    echo "  install <list>      Install packages from a .lst file"
    echo "  quick <preset>      Quick install preset"
    echo ""
    echo "Presets:"
    echo "  essential           Core + Privacy packages"
    echo "  developer           Core + Dev + AI packages"
    echo "  rofi                Rofi menu dependencies + AI"
    echo "  full                Everything except gaming"
    echo ""
    echo "Available lists:"

    local lists
    read -ra lists <<< "$(get_available_lists)"
    for lst in "${lists[@]}"; do
        local desc
        desc=$(get_list_desc "$lst")
        printf "  %-14s %s\n" "$lst" "$desc"
    done

    echo ""
    echo "Examples:"
    echo "  $0                      # Interactive mode"
    echo "  $0 list                 # Show all packages"
    echo "  $0 install ai-tools     # Install AI tools"
    echo "  $0 quick developer      # Quick developer setup"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Pre-flight
    vibe_no_root

    local aur_helper
    if ! aur_helper=$(vibe_detect_aur); then
        vibe_err "No AUR helper found!"
        echo "Install yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
        exit 1
    fi

    case "${1:-}" in
        list)
            vibe_banner
            show_all_lists
            ;;
        install)
            if [[ -z "${2:-}" ]]; then
                vibe_err "Please specify a list"
                echo ""
                echo "Available lists:"
                get_available_lists | tr ' ' '\n' | sed 's/^/  /'
                exit 1
            fi
            vibe_banner
            install_list "$2"
            ;;
        quick)
            vibe_banner
            case "${2:-}" in
                essential) preset_essential ;;
                developer) preset_developer ;;
                rofi|rofi-deps) preset_rofi ;;
                full) preset_full ;;
                *)
                    vibe_err "Unknown preset: ${2:-}"
                    echo "Available: essential, developer, rofi, full"
                    exit 1
                    ;;
            esac
            show_selection
            if vibe_confirm "Proceed with installation?"; then
                install_selected
            fi
            ;;
        -h|--help|help)
            show_help
            ;;
        "")
            interactive_menu
            ;;
        *)
            vibe_err "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

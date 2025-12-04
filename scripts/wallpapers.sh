#!/bin/bash
#
# Vibearchy Wallpaper Pack Downloader
# Downloads curated wallpaper collections from open-source repositories
#
# Usage:
#   ./wallpapers.sh           # Interactive category selection
#   ./wallpapers.sh all       # Download all categories
#   ./wallpapers.sh riced     # Download only riced category
#   ./wallpapers.sh minimal   # Download only minimal category
#   ./wallpapers.sh nature    # Download only nature category
#

# Source the core library
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/lib/vibearchy.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

WALL_DIR="${WALL_DIR:-$HOME/.config/hypr/walls}"
TEMP_DIR="/tmp/vibearchy-walls"

# Wallpaper sources
declare -A WALL_REPOS=(
    ["nordic"]="https://github.com/linuxdotexe/nordic-wallpapers"
    ["aesthetic"]="https://github.com/D3Ext/aesthetic-wallpapers"
    ["catppuccin"]="https://github.com/orangci/walls-catppuccin-mocha"
    ["ml4w"]="https://github.com/mylinuxforwork/wallpaper"
)

# Category descriptions
declare -A CATEGORIES=(
    ["riced"]="Anime, cyberpunk, aesthetic vibes"
    ["minimal"]="Clean gradients, macOS-style, solid colors"
    ["nature"]="Landscapes, space, mountains, cosmos"
)

# ═══════════════════════════════════════════════════════════════════════════════
# WALLPAPER LISTS (Curated selections from each repo)
# ═══════════════════════════════════════════════════════════════════════════════

# Riced/Anime category (~40 walls)
RICED_WALLS=(
    # From aesthetic-wallpapers
    "aesthetic|images|anime"
    "aesthetic|images|cyberpunk"
    "aesthetic|images|lofi"
    "aesthetic|images|neon"
    # From catppuccin
    "catppuccin|.|cat"
    "catppuccin|.|aesthetic"
    "catppuccin|.|anime"
    "catppuccin|.|city"
    "catppuccin|.|cabin"
    "catppuccin|.|pixel"
)

# Minimal/Clean category (~30 walls)
MINIMAL_WALLS=(
    # From nordic-wallpapers
    "nordic|wallpapers|minimal"
    "nordic|wallpapers|gradient"
    "nordic|dynamic-wallpapers|."
    # From ml4w
    "ml4w|.|astronaut"
    "ml4w|.|apple"
    "ml4w|.|dark-waves"
    "ml4w|.|color-wall"
    "ml4w|.|emergence"
)

# Nature/Space category (~30 walls)
NATURE_WALLS=(
    # From nordic-wallpapers
    "nordic|wallpapers|forest"
    "nordic|wallpapers|mountain"
    "nordic|wallpapers|lake"
    "nordic|wallpapers|snow"
    # From ml4w
    "ml4w|.|desert"
    "ml4w|.|dunes"
    "ml4w|.|earth"
    "ml4w|.|comet"
    "ml4w|.|Space"
    "ml4w|.|expanse"
    # From aesthetic
    "aesthetic|images|space"
    "aesthetic|images|landscape"
)

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Create directory structure
setup_dirs() {
    vibe_log "Setting up wallpaper directories..."
    mkdir -p "$WALL_DIR"/{riced,minimal,nature}
    mkdir -p "$TEMP_DIR"
}

# Clone a repo (shallow)
clone_repo() {
    local name="$1"
    local url="${WALL_REPOS[$name]}"
    local dest="$TEMP_DIR/$name"

    if [[ -d "$dest" ]]; then
        vibe_log "Using cached: $name"
        return 0
    fi

    vibe_log "Cloning $name..."
    git clone --depth 1 --quiet "$url" "$dest" 2>/dev/null || {
        vibe_err "Failed to clone $name"
        return 1
    }
    vibe_ok "Downloaded $name"
}

# Copy wallpapers matching pattern to category
copy_walls() {
    local src_dir="$1"
    local dest_category="$2"
    local pattern="$3"
    local count=0

    local dest="$WALL_DIR/$dest_category"

    # Find and copy matching files
    while IFS= read -r -d '' file; do
        cp "$file" "$dest/" 2>/dev/null && ((count++))
    done < <(find "$src_dir" -maxdepth 2 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        -iname "*${pattern}*" -print0 2>/dev/null)

    # If pattern is "." copy all images
    if [[ "$pattern" == "." ]] && [[ $count -eq 0 ]]; then
        while IFS= read -r -d '' file; do
            cp "$file" "$dest/" 2>/dev/null && ((count++))
        done < <(find "$src_dir" -maxdepth 2 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
            -print0 2>/dev/null)
    fi

    echo "$count"
}

# Process wallpaper list for a category
process_category() {
    local category="$1"
    shift
    local walls=("$@")
    local total=0

    vibe_subheader "Processing $category wallpapers"

    for entry in "${walls[@]}"; do
        IFS='|' read -r repo folder pattern <<< "$entry"

        local src="$TEMP_DIR/$repo"
        [[ -n "$folder" && "$folder" != "." ]] && src="$src/$folder"

        if [[ -d "$src" ]]; then
            local count
            count=$(copy_walls "$src" "$category" "$pattern")
            ((total += count))
        fi
    done

    vibe_ok "Copied $total wallpapers to $category/"
}

# Count wallpapers in directory
count_walls() {
    local dir="$1"
    find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | wc -l
}

# ═══════════════════════════════════════════════════════════════════════════════
# DOWNLOAD FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

download_riced() {
    vibe_header "Downloading Riced/Anime Wallpapers"

    clone_repo "aesthetic"
    clone_repo "catppuccin"

    process_category "riced" "${RICED_WALLS[@]}"
}

download_minimal() {
    vibe_header "Downloading Minimal/Clean Wallpapers"

    clone_repo "nordic"
    clone_repo "ml4w"

    process_category "minimal" "${MINIMAL_WALLS[@]}"
}

download_nature() {
    vibe_header "Downloading Nature/Space Wallpapers"

    clone_repo "nordic"
    clone_repo "ml4w"
    clone_repo "aesthetic"

    process_category "nature" "${NATURE_WALLS[@]}"
}

download_all() {
    download_riced
    download_minimal
    download_nature
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTERACTIVE MENU
# ═══════════════════════════════════════════════════════════════════════════════

show_menu() {
    vibe_banner_compact "Wallpaper Packs"

    echo -e "${BOLD}Select wallpaper packs to download:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Riced/Anime    - ${DIM}${CATEGORIES[riced]}${NC}"
    echo -e "  ${CYAN}2)${NC} Minimal/Clean  - ${DIM}${CATEGORIES[minimal]}${NC}"
    echo -e "  ${CYAN}3)${NC} Nature/Space   - ${DIM}${CATEGORIES[nature]}${NC}"
    echo -e "  ${CYAN}4)${NC} All Categories - ${DIM}~100 wallpapers${NC}"
    echo ""
    echo -e "  ${CYAN}0)${NC} Cancel"
    echo ""

    read -p "Enter choices (e.g., 1 3 or 4): " -a choices

    for choice in "${choices[@]}"; do
        case "$choice" in
            1) download_riced ;;
            2) download_minimal ;;
            3) download_nature ;;
            4) download_all ;;
            0) vibe_log "Cancelled"; exit 0 ;;
            *) vibe_warn "Unknown option: $choice" ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════

cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        vibe_log "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

show_summary() {
    vibe_header "Wallpaper Summary"

    local riced_count minimal_count nature_count total

    riced_count=$(count_walls "$WALL_DIR/riced")
    minimal_count=$(count_walls "$WALL_DIR/minimal")
    nature_count=$(count_walls "$WALL_DIR/nature")
    total=$((riced_count + minimal_count + nature_count))

    echo -e "  ${CYAN}Riced/Anime:${NC}    $riced_count wallpapers"
    echo -e "  ${CYAN}Minimal/Clean:${NC}  $minimal_count wallpapers"
    echo -e "  ${CYAN}Nature/Space:${NC}   $nature_count wallpapers"
    vibe_line
    echo -e "  ${BOLD}Total:${NC}          $total wallpapers"
    echo ""
    echo -e "  ${DIM}Location: $WALL_DIR${NC}"
    echo ""

    vibe_ok "Wallpapers ready! Use ${CYAN}Super + Shift + W${NC} to browse."
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Check dependencies
    vibe_check_deps git || vibe_die "git is required"

    # Setup
    setup_dirs

    # Handle arguments
    case "${1:-}" in
        all)     download_all ;;
        riced)   download_riced ;;
        minimal) download_minimal ;;
        nature)  download_nature ;;
        "")      show_menu ;;
        *)
            vibe_err "Unknown argument: $1"
            echo "Usage: $0 [all|riced|minimal|nature]"
            exit 1
            ;;
    esac

    # Cleanup and summary
    cleanup
    show_summary
}

# Run if not sourced
[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"

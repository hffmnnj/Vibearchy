#!/bin/bash
#
# Vibearchy Wallpaper Selector v2
# Intuitive wallpaper management with categories
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

WALL_DIR="$HOME/.config/hypr/walls"
THEME="$SCRIPT_DIR/walls.rasi"
CURRENT_WALL_FILE="/tmp/vibearchy-current-wall"

# Categories (subdirectories in WALL_DIR)
CATEGORIES=("riced" "minimal" "nature")

# Icons (all defined locally - no external dependencies)
ICON_ALL='󰸉'
ICON_RICED='󰣇'
ICON_MINIMAL='󰔉'
ICON_NATURE='󰋜'
ICON_RANDOM='󰒝'
ICON_FOLDER='󰝰'
ICON_REFRESH='󰑓'

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Get currently active wallpaper
get_current_wallpaper() {
    # Try swww query first
    local current
    current=$(swww query 2>/dev/null | head -1 | sed 's/.*image: //')

    # Fallback to tracking file
    if [[ -z "$current" ]] && [[ -f "$CURRENT_WALL_FILE" ]]; then
        current=$(cat "$CURRENT_WALL_FILE")
    fi

    echo "$current"
}

# Find all wallpapers in a directory (recursively)
find_wallpapers() {
    local dir="${1:-$WALL_DIR}"
    find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null
}

# Count wallpapers in a directory
count_wallpapers() {
    local dir="${1:-$WALL_DIR}"
    find_wallpapers "$dir" | wc -l
}

# Set wallpaper with smooth transition
set_wallpaper() {
    local wall="$1"

    # Validate file exists
    if [[ ! -f "$wall" ]]; then
        notify-send "Wallpaper" "File not found: $(basename "$wall")" -u critical
        return 1
    fi

    # Ensure swww daemon is running
    if ! pgrep -x swww-daemon >/dev/null; then
        swww-daemon &
        sleep 0.5
    fi

    # Set wallpaper with smooth transition
    # Using 'grow' from center - more reliable than wipe, equally beautiful
    if swww img "$wall" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60 \
        --transition-step 90; then

        # Track current wallpaper
        echo "$wall" > "$CURRENT_WALL_FILE"
        notify-send "Wallpaper Set" "$(basename "$wall")" -i "$wall" -t 2000
    else
        notify-send "Wallpaper" "Failed to set wallpaper" -u critical
        return 1
    fi
}

# Set random wallpaper
set_random() {
    local wall
    wall=$(find_wallpapers | shuf -n 1)

    if [[ -n "$wall" ]]; then
        set_wallpaper "$wall"
    else
        notify-send "Wallpaper" "No wallpapers found in $WALL_DIR" -u warning
    fi
}

# Browse wallpapers with image preview grid
browse_wallpapers() {
    local dir="${1:-$WALL_DIR}"
    local current
    current=$(get_current_wallpaper)

    # Check if directory has wallpapers
    local count
    count=$(count_wallpapers "$dir")
    if [[ "$count" -eq 0 ]]; then
        notify-send "Wallpaper" "No wallpapers found in $(basename "$dir")" -u warning
        return 1
    fi

    # Build wallpaper list with image previews
    local selection
    selection=$(find_wallpapers "$dir" | sort | while read -r wall; do
        local name
        name=$(basename "$wall")
        # Mark current wallpaper with checkmark
        [[ "$wall" == "$current" ]] && name="✓ $name"
        # Format: name\0icon\x1f/path/to/image (rofi image preview format)
        printf '%s\0icon\x1f%s\n' "$name" "$wall"
    done | rofi -dmenu -i -p "Select Wallpaper" -theme "$THEME" -show-icons)

    # Exit if nothing selected
    [[ -z "$selection" ]] && return 0

    # Extract filename (strip ✓ prefix if present)
    local name="${selection#✓ }"
    name="${name# }"  # Remove leading space if any

    # Find the full path by matching filename
    local wall
    wall=$(find_wallpapers "$dir" | grep -F "/$name" | head -1)

    if [[ -n "$wall" ]] && [[ -f "$wall" ]]; then
        set_wallpaper "$wall"
    else
        notify-send "Wallpaper" "Could not find: $name" -u warning
    fi
}

# Show main menu
show_menu() {
    local total riced minimal nature
    total=$(count_wallpapers)
    riced=$(count_wallpapers "$WALL_DIR/riced")
    minimal=$(count_wallpapers "$WALL_DIR/minimal")
    nature=$(count_wallpapers "$WALL_DIR/nature")

    # Always show Browse All
    echo "$ICON_ALL Browse All ($total)"

    # Only show categories that have wallpapers
    [[ $riced -gt 0 ]] && echo "$ICON_RICED Riced/Anime ($riced)"
    [[ $minimal -gt 0 ]] && echo "$ICON_MINIMAL Minimal/Clean ($minimal)"
    [[ $nature -gt 0 ]] && echo "$ICON_NATURE Nature/Space ($nature)"

    # Always show these options
    echo "$ICON_RANDOM Random"
    echo "$ICON_FOLDER Open Folder"
    echo "$ICON_REFRESH Refresh Daemon"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Check for swww
    if ! command -v swww >/dev/null 2>&1; then
        notify-send "Wallpaper" "swww not installed" -u critical
        exit 1
    fi

    # Show menu and get selection
    local choice
    choice=$(show_menu | rofi -dmenu -i -p "Wallpaper" -theme "${ROFI_THEME:-$THEME}")

    # Exit if nothing selected
    [[ -z "$choice" ]] && exit 0

    # Handle selection
    case "$choice" in
        *"Browse All"*)
            browse_wallpapers
            ;;
        *"Riced/Anime"*)
            browse_wallpapers "$WALL_DIR/riced"
            ;;
        *"Minimal/Clean"*)
            browse_wallpapers "$WALL_DIR/minimal"
            ;;
        *"Nature/Space"*)
            browse_wallpapers "$WALL_DIR/nature"
            ;;
        *Random*)
            set_random
            ;;
        *Folder*)
            xdg-open "$WALL_DIR" &
            ;;
        *Refresh*)
            pkill swww-daemon
            sleep 0.3
            swww-daemon &
            notify-send "Wallpaper" "Daemon restarted" -t 2000
            ;;
    esac
}

main "$@"

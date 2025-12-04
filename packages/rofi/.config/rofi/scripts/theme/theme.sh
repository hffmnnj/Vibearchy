#!/bin/bash
#
# Vibearchy Theme Selector
# Pick a theme with Rofi
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

THEME="$SCRIPT_DIR/theme.rasi"
[[ ! -f "$THEME" ]] && THEME="$ROFI_THEME"

THEME_SWITCH="$HOME/.config/hypr/scripts/theme-switch"

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Show menu
show_menu() {
    echo -e "$ICON_CELESTIAL\tCelestial"
    echo -e "$ICON_MIDNIGHT\tMidnight"
    echo -e "$ICON_DAWN\tDawn"
}

# Icon definitions (overrides)
ICON_CELESTIAL="󰖔"     # Moon/sky
ICON_MIDNIGHT="󰖙"      # Night
ICON_DAWN="󰖨"          # Sunrise

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    local current
    current=$($THEME_SWITCH --current 2>/dev/null || echo "celestial")

    local choice
    choice=$(show_menu | rofi -dmenu -i \
        -p "Theme" \
        -mesg "Current: $current" \
        -theme "$THEME")

    [[ -z "$choice" ]] && exit 0

    local action="${choice##*$'\t'}"

    case "$action" in
        Celestial)
            $THEME_SWITCH celestial
            vibe_notify "Theme" "Celestial theme applied"
            ;;
        Midnight)
            $THEME_SWITCH midnight
            vibe_notify "Theme" "Midnight theme applied"
            ;;
        Dawn)
            $THEME_SWITCH dawn
            vibe_notify "Theme" "Dawn theme applied"
            ;;
    esac
}

main

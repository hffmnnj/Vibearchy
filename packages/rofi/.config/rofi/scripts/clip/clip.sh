#!/bin/bash
#
# Vibearchy Clipboard Manager
# Browse, search, and manage clipboard history
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

THEME="$SCRIPT_DIR/clip.rasi"
[[ ! -f "$THEME" ]] && THEME="$ROFI_THEME"

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Show main menu
show_menu() {
    local count
    count=$(cliphist list | wc -l)

    echo -e "$ICON_CLIPBOARD\tBrowse History ($count)"
    echo -e "$ICON_SEARCH\tSearch History"
    echo -e "$ICON_DELETE\tDelete Entry"
    echo -e "$ICON_CLEAR\tClear All"
}

# Browse clipboard history
browse_history() {
    local selection
    selection=$(cliphist list | rofi -dmenu -i \
        -p "Clipboard" \
        -mesg "Select to copy" \
        -theme "$THEME")

    if [[ -n "$selection" ]]; then
        cliphist decode <<< "$selection" | wl-copy
        vibe_notify "Clipboard" "Copied to clipboard"
    fi
}

# Search clipboard history
search_history() {
    local query
    query=$(echo "" | rofi -dmenu \
        -p "Search" \
        -mesg "Enter search term" \
        -theme "$THEME")

    [[ -z "$query" ]] && return

    local selection
    selection=$(cliphist list | grep -i "$query" | rofi -dmenu -i \
        -p "Results" \
        -mesg "Matching: $query" \
        -theme "$THEME")

    if [[ -n "$selection" ]]; then
        cliphist decode <<< "$selection" | wl-copy
        vibe_notify "Clipboard" "Copied to clipboard"
    fi
}

# Delete a single entry
delete_entry() {
    local selection
    selection=$(cliphist list | rofi -dmenu -i \
        -p "Delete" \
        -mesg "Select entry to delete" \
        -theme "$THEME")

    if [[ -n "$selection" ]]; then
        cliphist delete <<< "$selection"
        vibe_notify "Clipboard" "Entry deleted"
    fi
}

# Clear all history
clear_all() {
    if vibe_confirm "Clear entire clipboard history?"; then
        cliphist wipe
        vibe_notify "Clipboard" "History cleared"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Check dependencies
    vibe_need cliphist || exit 1
    vibe_need wl-copy wl-clipboard || exit 1

    # Handle direct browse mode (no menu)
    if [[ "$1" == "--browse" ]] || [[ "$1" == "-b" ]]; then
        browse_history
        exit 0
    fi

    local choice
    choice=$(show_menu | rofi -dmenu -i \
        -p "Clipboard" \
        -theme "$THEME")

    [[ -z "$choice" ]] && exit 0

    local action="${choice##*$'\t'}"

    case "$action" in
        "Browse History"*)
            browse_history
            ;;
        "Search History")
            search_history
            ;;
        "Delete Entry")
            delete_entry
            ;;
        "Clear All")
            clear_all
            ;;
    esac
}

main "$@"

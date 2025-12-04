#!/bin/bash
#
# Vibearchy Screenshot Tool
# Capture screenshots with various modes and options
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

THEME="$SCRIPT_DIR/capture.rasi"
[[ ! -f "$THEME" ]] && THEME="$ROFI_THEME"

# Screenshot save directory
SAVE_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$SAVE_DIR"

# Last screenshot path tracking
LAST_SCREENSHOT_FILE="/tmp/vibearchy-last-screenshot"

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Generate filename
gen_filename() {
    echo "$SAVE_DIR/$(vibe_timestamp "screenshot" "png")"
}

# Save last screenshot path
save_last_path() {
    echo "$1" > "$LAST_SCREENSHOT_FILE"
}

# Get last screenshot path
get_last_path() {
    [[ -f "$LAST_SCREENSHOT_FILE" ]] && cat "$LAST_SCREENSHOT_FILE"
}

# Copy last screenshot path to clipboard
copy_last_path() {
    local last
    last=$(get_last_path)

    if [[ -n "$last" ]] && [[ -f "$last" ]]; then
        echo -n "$last" | wl-copy
        vibe_notify "Screenshot" "Path copied: $(basename "$last")"
    else
        vibe_notify "Screenshot" "No recent screenshot found"
    fi
}

# Show main menu
show_menu() {
    echo -e "$ICON_REGION\tRegion"
    echo -e "$ICON_MONITOR\tFull Screen"
    echo -e "$ICON_WINDOW\tActive Window"
    echo -e "$ICON_TIMER\tDelayed (3s)"
    echo -e "$ICON_ANNOTATE\tRegion + Annotate"
    echo -e "$ICON_AI\tRegion + AI Analyze"
    echo -e "$ICON_COPY\tCopy Last Path"
    echo -e "$ICON_FOLDER\tOpen Screenshots"
}

# Capture region
capture_region() {
    vibe_need grim || return 1
    vibe_need slurp || return 1

    local file
    file=$(gen_filename)

    if grim -g "$(slurp)" "$file"; then
        wl-copy < "$file"
        save_last_path "$file"
        vibe_notify "Screenshot" "Saved & copied" "$file"
    fi
}

# Capture full screen
capture_screen() {
    vibe_need grim || return 1

    local file
    file=$(gen_filename)

    if grim "$file"; then
        wl-copy < "$file"
        save_last_path "$file"
        vibe_notify "Screenshot" "Saved & copied" "$file"
    fi
}

# Capture active window
capture_window() {
    vibe_need grim || return 1

    if ! vibe_is_hyprland; then
        vibe_notify "Screenshot" "Window capture requires Hyprland"
        return 1
    fi

    local file
    file=$(gen_filename)

    local geom
    geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

    if grim -g "$geom" "$file"; then
        wl-copy < "$file"
        save_last_path "$file"
        vibe_notify "Screenshot" "Window captured" "$file"
    fi
}

# Capture with delay
capture_delayed() {
    vibe_need grim || return 1

    vibe_notify "Screenshot" "Capturing in 3 seconds..."
    sleep 3

    local file
    file=$(gen_filename)

    if grim "$file"; then
        wl-copy < "$file"
        save_last_path "$file"
        vibe_notify "Screenshot" "Saved & copied" "$file"
    fi
}

# Capture and annotate
capture_annotate() {
    vibe_need grim || return 1
    vibe_need slurp || return 1
    vibe_need swappy || return 1

    local file
    file=$(gen_filename)

    if grim -g "$(slurp)" "$file"; then
        save_last_path "$file"
        swappy -f "$file"
    fi
}

# Capture and analyze with AI
capture_ai() {
    vibe_need grim || return 1
    vibe_need slurp || return 1
    vibe_need aichat || return 1

    local tmpfile="/tmp/screenshot-ai-$(date +%s).png"

    if grim -g "$(slurp)" "$tmpfile"; then
        local term
        term=$(vibe_terminal)

        $term -e bash -c "
            echo 'Analyzing screenshot with AI...'
            echo ''
            aichat -S -f '$tmpfile' 'Analyze this screenshot. What do you see? If it contains code, errors, or UI elements, explain them in detail.'
            echo ''
            echo 'Press Enter to exit...'
            read
        " &
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Handle direct capture modes
    case "$1" in
        --region|-r)     capture_region; exit 0 ;;
        --screen|-s)     capture_screen; exit 0 ;;
        --window|-w)     capture_window; exit 0 ;;
        --delay|-d)      capture_delayed; exit 0 ;;
        --annotate|-a)   capture_annotate; exit 0 ;;
        --copy-path|-p)  copy_last_path; exit 0 ;;
    esac

    # Get last screenshot info for message
    local last_file
    last_file=$(get_last_path)
    local mesg="Ctrl+Shift+Escape: Copy last path"
    [[ -n "$last_file" ]] && mesg="Last: $(basename "$last_file") | Ctrl+Shift+Esc: Copy path"

    local choice
    choice=$(show_menu | rofi -dmenu -i \
        -p "Screenshot" \
        -mesg "$mesg" \
        -kb-custom-1 "Control+Shift+Escape" \
        -theme "$THEME")

    local exit_code=$?

    # Handle Ctrl+Shift+Escape (exit code 10 = kb-custom-1)
    if [[ $exit_code -eq 10 ]]; then
        copy_last_path
        exit 0
    fi

    [[ -z "$choice" ]] && exit 0

    local action="${choice##*$'\t'}"

    case "$action" in
        Region)
            capture_region
            ;;
        "Full Screen")
            capture_screen
            ;;
        "Active Window")
            capture_window
            ;;
        "Delayed (3s)")
            capture_delayed
            ;;
        "Region + Annotate")
            capture_annotate
            ;;
        "Region + AI Analyze")
            capture_ai
            ;;
        "Copy Last Path")
            copy_last_path
            ;;
        "Open Screenshots")
            xdg-open "$SAVE_DIR" &
            ;;
    esac
}

main "$@"

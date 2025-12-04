#!/bin/bash
#
# Vibearchy Rofi Common Library
# Shared functions for all Rofi menu scripts
#

# ═══════════════════════════════════════════════════════════════════════════════
# PATHS
# ═══════════════════════════════════════════════════════════════════════════════

ROFI_DIR="$HOME/.config/rofi"
ROFI_SCRIPTS="$ROFI_DIR/scripts"
ROFI_THEME="$ROFI_DIR/theme/vibearchy.rasi"

# ═══════════════════════════════════════════════════════════════════════════════
# ICONS (Nerd Font)
# ═══════════════════════════════════════════════════════════════════════════════

# Power
readonly ICON_POWER='󰐥'
readonly ICON_REBOOT='󰜉'
readonly ICON_LOCK='󰌾'
readonly ICON_SUSPEND='󰤄'
readonly ICON_LOGOUT='󰍃'
readonly ICON_FIRMWARE='󰒔'
readonly ICON_HIBERNATE='󰋊'

# Confirmation
readonly ICON_YES='󰸞'
readonly ICON_NO='󱎘'

# Media/Screenshots
readonly ICON_CAMERA='󰄀'
readonly ICON_REGION='󰆞'
readonly ICON_WINDOW='󰖯'
readonly ICON_MONITOR='󰍹'
readonly ICON_TIMER='󰔛'
readonly ICON_ANNOTATE='󰏬'

# Clipboard
readonly ICON_CLIPBOARD='󰅍'
readonly ICON_COPY='󰆏'
readonly ICON_DELETE='󰆴'
readonly ICON_CLEAR='󰃢'
readonly ICON_SEARCH='󰍉'

# Wallpaper
readonly ICON_WALLPAPER='󰸉'
readonly ICON_RANDOM='󰒝'
readonly ICON_FOLDER='󰉋'
readonly ICON_REFRESH='󰑓'

# Emoji
readonly ICON_EMOJI='󰱫'
readonly ICON_RECENT='󰋚'
readonly ICON_FACE='󰱸'
readonly ICON_HEART='󰋑'

# General
readonly ICON_AI='󰧑'
readonly ICON_SETTINGS='󰒓'
readonly ICON_INFO='󰋽'
readonly ICON_BACK='󰁍'

# ═══════════════════════════════════════════════════════════════════════════════
# NOTIFICATION HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

# Send a notification
vibe_notify() {
    local title="$1"
    local message="${2:-}"
    local icon="${3:-}"

    if [[ -n "$icon" ]] && [[ -f "$icon" ]]; then
        notify-send "$title" "$message" -i "$icon"
    else
        notify-send "$title" "$message"
    fi
}

# Notify missing dependency
vibe_need() {
    local cmd="$1"
    local pkg="${2:-$1}"

    if ! command -v "$cmd" &>/dev/null; then
        notify-send "Missing Dependency" "Please install: $pkg" -u critical
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# ROFI LAUNCHERS
# ═══════════════════════════════════════════════════════════════════════════════

# Standard rofi dmenu
vibe_rofi() {
    local prompt="${1:-Menu}"
    local message="${2:-}"
    local theme="${3:-$ROFI_THEME}"

    local cmd="rofi -dmenu -i -p \"$prompt\""
    [[ -n "$message" ]] && cmd+=" -mesg \"$message\""
    [[ -f "$theme" ]] && cmd+=" -theme \"$theme\""

    eval "$cmd"
}

# Rofi with custom theme string
vibe_rofi_styled() {
    local prompt="$1"
    local message="$2"
    local theme_str="$3"
    local theme="${4:-$ROFI_THEME}"

    local cmd="rofi -dmenu -i -p \"$prompt\""
    [[ -n "$message" ]] && cmd+=" -mesg \"$message\""
    [[ -n "$theme_str" ]] && cmd+=" -theme-str '$theme_str'"
    [[ -f "$theme" ]] && cmd+=" -theme \"$theme\""

    eval "$cmd"
}

# Rofi confirmation dialog
vibe_confirm() {
    local message="${1:-Are you sure?}"
    local theme="${2:-$ROFI_THEME}"

    local style='window {location: center; anchor: center; width: 320px;}'
    style+=' mainbox {children: [ "message", "listview" ];}'
    style+=' listview {columns: 2; lines: 1;}'
    style+=' element-text {horizontal-align: 0.5;}'
    style+=' textbox {horizontal-align: 0.5;}'

    local chosen
    chosen=$(echo -e "$ICON_YES Yes\n$ICON_NO No" | \
        rofi -dmenu -i \
            -p "Confirm" \
            -mesg "$message" \
            -theme-str "$style" \
            -theme "$theme")

    [[ "$chosen" == *"Yes"* ]]
}

# Rofi icon grid (for wallpapers, etc.)
vibe_rofi_grid() {
    local prompt="$1"
    local rows="${2:-4}"
    local cols="${3:-4}"
    local icon_size="${4:-10}"
    local theme="${5:-$ROFI_THEME}"

    local style="element{orientation:vertical;}"
    style+="element-text{horizontal-align:0.5;}"
    style+="element-icon{size:${icon_size}.0000em;}"
    style+="listview{lines:$rows;columns:$cols;}"

    rofi -dmenu -i -show-icons \
        -p "$prompt" \
        -theme-str "$style" \
        -theme "$theme"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLIPBOARD HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

# Copy text to clipboard
vibe_copy() {
    local text="$1"
    echo -n "$text" | wl-copy
}

# Get clipboard contents
vibe_paste() {
    wl-paste 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# SYSTEM INFO
# ═══════════════════════════════════════════════════════════════════════════════

# Get uptime string
vibe_uptime() {
    uptime -p | sed 's/up //'
}

# Check if running Hyprland
vibe_is_hyprland() {
    [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]] || \
    [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]
}

# Get terminal emulator
vibe_terminal() {
    if command -v ghostty &>/dev/null; then
        echo "ghostty"
    elif command -v kitty &>/dev/null; then
        echo "kitty"
    elif command -v alacritty &>/dev/null; then
        echo "alacritty"
    else
        echo "xterm"
    fi
}

# Run command in terminal
vibe_term_run() {
    local cmd="$1"
    local term
    term=$(vibe_terminal)

    case "$term" in
        ghostty) ghostty -e bash -c "$cmd" & ;;
        kitty)   kitty -e bash -c "$cmd" & ;;
        *)       "$term" -e bash -c "$cmd" & ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# FILE HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

# Generate timestamp filename
vibe_timestamp() {
    local prefix="${1:-file}"
    local ext="${2:-png}"
    echo "${prefix}-$(date +%Y-%m-%d-%H%M%S).${ext}"
}

# Get random file from directory
vibe_random_file() {
    local dir="$1"
    local pattern="${2:-*}"

    find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null | shuf -n 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# WALLPAPER HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

# Default wallpaper directories
WALLS_DIR="${WALLS_DIR:-$HOME/.config/hypr/walls}"
WALLS_DIR_ALT="${WALLS_DIR_ALT:-$HOME/Pictures/Wallpapers}"

# Set wallpaper using swww
vibe_set_wallpaper() {
    local wallpaper="$1"
    local transition="${2:-wipe}"
    local duration="${3:-2}"

    if ! command -v swww &>/dev/null; then
        vibe_notify "Wallpaper" "swww not installed"
        return 1
    fi

    # Start daemon if not running
    pgrep -x swww-daemon >/dev/null || swww-daemon &

    swww img "$wallpaper" \
        --transition-type "$transition" \
        --transition-duration "$duration" \
        --transition-fps 60

    vibe_notify "Wallpaper Changed" "$(basename "$wallpaper")" "$wallpaper"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SCREENSHOT HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"

# Capture screen region
vibe_capture_region() {
    local output="$1"
    local delay="${2:-0}"

    vibe_need grim || return 1
    vibe_need slurp || return 1

    [[ "$delay" -gt 0 ]] && sleep "$delay"

    grim -g "$(slurp)" "$output"
}

# Capture full screen
vibe_capture_screen() {
    local output="$1"
    local delay="${2:-0}"

    vibe_need grim || return 1

    [[ "$delay" -gt 0 ]] && sleep "$delay"

    grim "$output"
}

# Capture window (Hyprland)
vibe_capture_window() {
    local output="$1"

    vibe_need grim || return 1
    vibe_is_hyprland || { vibe_notify "Error" "Window capture requires Hyprland"; return 1; }

    local geom
    geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

    grim -g "$geom" "$output"
}

# Open screenshot for annotation
vibe_annotate() {
    local file="$1"

    if command -v swappy &>/dev/null; then
        swappy -f "$file"
    else
        vibe_notify "Annotate" "swappy not installed"
    fi
}

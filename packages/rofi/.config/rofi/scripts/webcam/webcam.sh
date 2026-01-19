#!/bin/bash
#
# Vibearchy Webcam Tool
# Quick preview, photos, recording, and OBS integration
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

THEME="$SCRIPT_DIR/webcam.rasi"
[[ ! -f "$THEME" ]] && THEME="$ROFI_THEME"

# Save directories
PHOTO_DIR="${WEBCAM_PHOTO_DIR:-$HOME/Pictures/Webcam}"
VIDEO_DIR="${WEBCAM_VIDEO_DIR:-$HOME/Videos/Webcam}"
mkdir -p "$PHOTO_DIR" "$VIDEO_DIR"

# State files
RECORDING_PID_FILE="/tmp/vibearchy-webcam-recording.pid"
PREVIEW_PID_FILE="/tmp/vibearchy-webcam-preview.pid"

# ═══════════════════════════════════════════════════════════════════════════════
# DEVICE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Get default webcam device
get_default_device() {
    local device
    device=$(v4l2-ctl --list-devices 2>/dev/null | \
        grep -A1 -i "camera\|webcam" | grep "/dev/video" | head -1 | tr -d ' \t')
    [[ -z "$device" ]] && device="/dev/video0"
    echo "$device"
}

# Get device name
get_device_name() {
    local device="${1:-$(get_default_device)}"
    v4l2-ctl --list-devices 2>/dev/null | grep -B1 "$device" | head -1 | sed 's/(.*//' | xargs
}

# List available webcam devices
list_devices() {
    v4l2-ctl --list-devices 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# PREVIEW FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Preview webcam in floating mpv window
preview_webcam() {
    local device
    device=$(get_default_device)

    vibe_need mpv || return 1

    # Kill existing preview if running
    if [[ -f "$PREVIEW_PID_FILE" ]]; then
        kill "$(cat "$PREVIEW_PID_FILE")" 2>/dev/null
        rm -f "$PREVIEW_PID_FILE"
    fi

    # Launch mpv with webcam
    mpv --demuxer-lavf-format=video4linux2 \
        --demuxer-lavf-o=video_size=1280x720,input_format=mjpeg \
        --title="Webcam Preview" \
        --geometry=640x480 \
        --ontop \
        --no-osc \
        --profile=low-latency \
        av://v4l2:"$device" &

    echo $! > "$PREVIEW_PID_FILE"
    vibe_notify "Webcam" "Preview started"
}

# Close preview
close_preview() {
    if [[ -f "$PREVIEW_PID_FILE" ]]; then
        kill "$(cat "$PREVIEW_PID_FILE")" 2>/dev/null
        rm -f "$PREVIEW_PID_FILE"
        vibe_notify "Webcam" "Preview closed"
    fi
}

# Check if preview is running
is_preview_running() {
    [[ -f "$PREVIEW_PID_FILE" ]] && kill -0 "$(cat "$PREVIEW_PID_FILE")" 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHOTO FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Take photo
take_photo() {
    local device
    device=$(get_default_device)
    local file="$PHOTO_DIR/$(vibe_timestamp "photo" "jpg")"

    vibe_need ffmpeg || return 1

    if ffmpeg -f v4l2 -video_size 1280x720 -i "$device" \
        -frames:v 1 "$file" -y 2>/dev/null; then
        wl-copy < "$file"
        vibe_notify "Webcam" "Photo saved & copied" "$file"
    else
        vibe_notify "Webcam" "Failed to capture photo" -u critical
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# RECORDING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Check if recording
is_recording() {
    [[ -f "$RECORDING_PID_FILE" ]] && kill -0 "$(cat "$RECORDING_PID_FILE")" 2>/dev/null
}

# Start recording
start_recording() {
    local device
    device=$(get_default_device)
    local file="$VIDEO_DIR/$(vibe_timestamp "video" "mp4")"

    vibe_need ffmpeg || return 1

    ffmpeg -f v4l2 -video_size 1280x720 -framerate 30 -i "$device" \
        -c:v libx264 -preset ultrafast -crf 23 \
        "$file" 2>/dev/null &

    echo $! > "$RECORDING_PID_FILE"
    vibe_notify "Webcam" "Recording started" "$file"
}

# Stop recording
stop_recording() {
    if [[ -f "$RECORDING_PID_FILE" ]]; then
        kill "$(cat "$RECORDING_PID_FILE")" 2>/dev/null
        rm -f "$RECORDING_PID_FILE"
        vibe_notify "Webcam" "Recording stopped"
    fi
}

# Toggle recording
toggle_recording() {
    if is_recording; then
        stop_recording
    else
        start_recording
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MENU FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Show main menu
show_menu() {
    # Preview option
    if is_preview_running; then
        echo -e "$ICON_PLAY\tClose Preview"
    else
        echo -e "$ICON_CAMERA\tQuick Preview"
    fi

    echo -e "$ICON_VIDEO\tTake Photo"

    # Recording option
    if is_recording; then
        echo -e "$ICON_RECORD_STOP\tStop Recording [REC]"
    else
        echo -e "$ICON_RECORD\tStart Recording"
    fi

    echo -e "$ICON_STREAM\tOpen OBS Studio"
    echo -e "$ICON_DEVICE\tDevice Settings"
    echo -e "$ICON_INFO\tDevice Info"
    echo -e "$ICON_FOLDER\tOpen Captures"
}

# Show device info
show_device_info() {
    local device
    device=$(get_default_device)
    local name
    name=$(get_device_name "$device")

    local info
    info=$(v4l2-ctl -d "$device" --all 2>/dev/null | head -30)

    vibe_notify "Webcam: $name" "$device\n\n$info" -t 10000
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    # Handle CLI arguments
    case "$1" in
        --preview|-p)    preview_webcam; exit 0 ;;
        --photo|-s)      take_photo; exit 0 ;;
        --record|-r)     toggle_recording; exit 0 ;;
        --close|-c)      close_preview; exit 0 ;;
    esac

    # Get status for message
    local device
    device=$(get_default_device)
    local name
    name=$(get_device_name "$device")
    local mesg="$name"
    is_recording && mesg="$mesg | Recording..."
    is_preview_running && mesg="$mesg | Preview active"

    local choice
    choice=$(show_menu | rofi -dmenu -i \
        -p "Webcam" \
        -mesg "$mesg" \
        -theme "$THEME")

    [[ -z "$choice" ]] && exit 0

    local action="${choice##*$'\t'}"

    case "$action" in
        "Quick Preview")
            preview_webcam
            ;;
        "Close Preview")
            close_preview
            ;;
        "Take Photo")
            take_photo
            ;;
        "Start Recording"|"Stop Recording [REC]")
            toggle_recording
            ;;
        "Open OBS Studio")
            obs &
            ;;
        "Device Settings")
            if command -v cameractrls &>/dev/null; then
                cameractrls &
            else
                vibe_notify "Webcam" "cameractrls not installed\nInstall with: yay -S cameractrls"
            fi
            ;;
        "Device Info")
            show_device_info
            ;;
        "Open Captures")
            xdg-open "$PHOTO_DIR" &
            ;;
    esac
}

main "$@"

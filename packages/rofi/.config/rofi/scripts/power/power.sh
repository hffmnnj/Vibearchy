#!/bin/bash
#
# Vibearchy Power Menu
# System power controls with confirmation
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

THEME="$SCRIPT_DIR/power.rasi"
[[ ! -f "$THEME" ]] && THEME="$ROFI_THEME"

# ═══════════════════════════════════════════════════════════════════════════════
# MENU
# ═══════════════════════════════════════════════════════════════════════════════

show_menu() {
    local uptime
    uptime=$(vibe_uptime)

    echo -e "$ICON_LOCK\tLock"
    echo -e "$ICON_SUSPEND\tSuspend"
    echo -e "$ICON_LOGOUT\tLogout"
    echo -e "$ICON_REBOOT\tReboot"
    echo -e "$ICON_POWER\tShutdown"
    echo -e "$ICON_FIRMWARE\tReboot to UEFI"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ACTIONS
# ═══════════════════════════════════════════════════════════════════════════════

do_lock() {
    if command -v hyprlock &>/dev/null; then
        hyprlock
    elif command -v swaylock &>/dev/null; then
        swaylock -f
    else
        vibe_notify "Lock" "No screen locker found"
    fi
}

do_suspend() {
    # Pause media before suspend
    command -v playerctl &>/dev/null && playerctl pause

    # Lock first, then suspend
    do_lock &
    sleep 0.5
    systemctl suspend
}

do_logout() {
    if vibe_is_hyprland; then
        hyprctl dispatch exit
    elif [[ -n "$SWAY_SOCK" ]]; then
        swaymsg exit
    else
        loginctl terminate-user "$USER"
    fi
}

do_reboot() {
    systemctl reboot
}

do_shutdown() {
    systemctl poweroff
}

do_firmware() {
    systemctl reboot --firmware-setup
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    local uptime
    uptime=$(vibe_uptime)

    local choice
    choice=$(show_menu | rofi -dmenu -i \
        -p "Power" \
        -mesg "Uptime: $uptime" \
        -theme "$THEME")

    [[ -z "$choice" ]] && exit 0

    local action="${choice##*$'\t'}"

    case "$action" in
        Lock)
            do_lock
            ;;
        Suspend)
            vibe_confirm "Suspend system?" && do_suspend
            ;;
        Logout)
            vibe_confirm "Logout of session?" && do_logout
            ;;
        Reboot)
            vibe_confirm "Reboot system?" && do_reboot
            ;;
        Shutdown)
            vibe_confirm "Shutdown system?" && do_shutdown
            ;;
        "Reboot to UEFI")
            vibe_confirm "Reboot to UEFI firmware?" && do_firmware
            ;;
    esac
}

main

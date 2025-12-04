#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibearchy Keybindings Reference
# Quick reference for all system keybindings
# ═══════════════════════════════════════════════════════════════════════════════

# Theme
THEME="$HOME/.config/rofi/scripts/keys/keys.rasi"

# Build keybindings list
build_keybinds() {
    cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━ APPLICATIONS ━━━━━━━━━━━━━━━━━━━━━
󰆍  Super + Return          Terminal
󰖟  Super + W               Browser
󰉋  Super + E               File Manager
󰊠  Super + Tab             App Launcher
󰌾  Super + P               Password Manager
━━━━━━━━━━━━━━━━━━━━━ ROFI MENUS ━━━━━━━━━━━━━━━━━━━━━━━
󰌌  Super + /               Keybindings (this menu)
󰅍  Super + Y               Clipboard History
󰧑  Super + Shift + Y       Clipboard AI
  Super + .               Emoji Picker
󰖂  Super + Ctrl + V        VPN Menu
󰒋  Super + Shift + S       SSH Menu
󰸉  Super + Shift + W       Wallpaper Selector
󰐥  Alt + Escape            Power Menu
󱎫  Copilot Key             AI Assistant
━━━━━━━━━━━━━━━━━━━━━ SCREENSHOTS ━━━━━━━━━━━━━━━━━━━━━━
󰹑  Print                   Screenshot Menu
󰆏  Super + Print           Copy Last Screenshot Path
━━━━━━━━━━━━━━━━━━━━━ SCRATCHPADS ━━━━━━━━━━━━━━━━━━━━━━
󰕾  Super + V               Volume Mixer
󰂯  Super + B               Bluetooth
󰆍  Super + `               Terminal
󰃬  Super + C               Calculator
󰍹  Super + M               System Monitor
󰊢  Super + G               LazyGit
󰡨  Super + D               LazyDocker
󰂺  Super + I               Notes
󰐪  Super + Z               Zoom Window
━━━━━━━━━━━━━━━━━━━━━ WINDOWS ━━━━━━━━━━━━━━━━━━━━━━━━━━
󰅖  Super + Q               Close Window
󰊓  Super + F               Fullscreen
󰖲  Super + A               Toggle Floating
󰆾  Super + S               Toggle Split
󰕰  Super + Shift + C       Center Window
󰁌  Super + R               Resize Mode
󱂬  Super + Shift + G       Toggle Group
━━━━━━━━━━━━━━━━━━━━━ FOCUS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
󰁍  Super + H/←             Focus Left
󰁔  Super + L/→             Focus Right
󰁝  Super + K/↑             Focus Up
󰁅  Super + J/↓             Focus Down
󰜱  Alt + Tab               Last Window
━━━━━━━━━━━━━━━━━━━━━ MOVE WINDOWS ━━━━━━━━━━━━━━━━━━━━━
  Super + Shift + H/←     Move Left
  Super + Shift + L/→     Move Right
  Super + Shift + K/↑     Move Up
  Super + Shift + J/↓     Move Down
━━━━━━━━━━━━━━━━━━━━━ WORKSPACES ━━━━━━━━━━━━━━━━━━━━━━━
󰎤  Super + 1-9             Go to Workspace
󰎧  Super + Shift + 1-9     Move Window to Workspace
󰁍  Super + Ctrl + H/←      Previous Workspace
󰁔  Super + Ctrl + L/→      Next Workspace
󰍽  Super + Scroll          Cycle Workspaces
󱃸  Super + </              Previous Monitor
󱃺  Super + >/              Next Monitor
━━━━━━━━━━━━━━━━━━━━━ SYSTEM ━━━━━━━━━━━━━━━━━━━━━━━━━━━
󰂚  Super + N               Notification Center
󰂛  Super + Shift + N       Clear Notifications
󱄄  Super + T               Toggle Waybar
󰑓  Super + Ctrl + R        Reload Waybar
󰏘  Super + Insert          Color Picker
󰕮  Super + Ctrl + W        Random Wallpaper
EOF
}

# Rofi command
rofi_cmd() {
    rofi -dmenu \
        -p "Keybindings" \
        -mesg "Vibearchy Keyboard Shortcuts" \
        -theme "$THEME" \
        -i
}

# Main
main() {
    build_keybinds | rofi_cmd
}

main "$@"

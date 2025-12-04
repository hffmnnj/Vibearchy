#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibearchy SSH Menu
# Quick access to SSH hosts from ~/.ssh/config
# ═══════════════════════════════════════════════════════════════════════════════

# Icons (Nerd Font)
server_icon='󰒋'
config_icon=''
add_icon='󰐕'
copy_icon='󰆏'

# Theme
THEME="$HOME/.config/rofi/scripts/ssh/ssh.rasi"

# Terminal (change if using different terminal)
TERMINAL="${TERMINAL:-ghostty}"

# ─────────────────────────────────────────────────────────────────────────────
# Parse SSH Config
# ─────────────────────────────────────────────────────────────────────────────
get_ssh_hosts() {
    local config_file="$HOME/.ssh/config"

    if [[ ! -f "$config_file" ]]; then
        return
    fi

    # Extract Host entries (excluding wildcards and patterns)
    grep -E "^Host " "$config_file" | \
        awk '{print $2}' | \
        grep -v '[*?]' | \
        sort -u
}

# ─────────────────────────────────────────────────────────────────────────────
# Build Menu
# ─────────────────────────────────────────────────────────────────────────────
build_menu() {
    local hosts
    hosts=$(get_ssh_hosts)

    # List SSH hosts
    if [[ -n "$hosts" ]]; then
        while IFS= read -r host; do
            echo -e "$server_icon $host"
        done <<< "$hosts"
    else
        echo -e "$add_icon No hosts configured"
    fi

    # Divider and options
    echo -e "$config_icon Edit SSH Config"
    echo -e "$copy_icon Copy Public Key"
}

# ─────────────────────────────────────────────────────────────────────────────
# Rofi Command
# ─────────────────────────────────────────────────────────────────────────────
rofi_cmd() {
    rofi -dmenu \
        -p "SSH" \
        -mesg "Select host or action" \
        -theme "$THEME"
}

# ─────────────────────────────────────────────────────────────────────────────
# Connect to Host
# ─────────────────────────────────────────────────────────────────────────────
connect_host() {
    local host="$1"

    # Remove icon prefix
    host="${host#* }"

    notify-send "SSH" "Connecting to $host..." -i network-server

    # Launch terminal with SSH
    $TERMINAL -e ssh "$host" &
}

# ─────────────────────────────────────────────────────────────────────────────
# Actions
# ─────────────────────────────────────────────────────────────────────────────
handle_selection() {
    local selection="$1"

    case "$selection" in
        *"Edit SSH Config"*)
            $TERMINAL -e "${EDITOR:-nvim}" "$HOME/.ssh/config" &
            ;;
        *"Copy Public Key"*)
            local pubkey="$HOME/.ssh/id_ed25519.pub"
            [[ ! -f "$pubkey" ]] && pubkey="$HOME/.ssh/id_rsa.pub"

            if [[ -f "$pubkey" ]]; then
                cat "$pubkey" | wl-copy
                notify-send "SSH" "Public key copied to clipboard" -i edit-copy
            else
                notify-send "SSH" "No public key found" -u critical
            fi
            ;;
        *"No hosts configured"*)
            notify-send "SSH" "Add hosts to ~/.ssh/config" -i dialog-information
            ;;
        *)
            # Connect to selected host
            if [[ -n "$selection" ]]; then
                connect_host "$selection"
            fi
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    local selection
    selection=$(build_menu | rofi_cmd)

    if [[ -n "$selection" ]]; then
        handle_selection "$selection"
    fi
}

main "$@"

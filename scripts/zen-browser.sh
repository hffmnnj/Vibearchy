#!/bin/bash
#
# Vibearchy Zen Browser Setup
# Configures Zen Browser with recommended mods, extensions, and privacy settings
#
# Usage:
#   ./zen-browser.sh              # Interactive setup
#   ./zen-browser.sh --mods       # Install Zen Mods only
#   ./zen-browser.sh --extensions # Setup extensions only
#   ./zen-browser.sh --all        # Install everything
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/lib/vibearchy.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Zen Browser paths (check multiple locations)
ZEN_PATHS=(
    "$HOME/.zen"
    "$HOME/.var/app/app.zen_browser.zen/.zen"
    "$HOME/.var/app/io.github.nickvision.browser/.zen"
)

# Zen installation paths for policies.json
ZEN_INSTALL_PATHS=(
    "/opt/zen-browser"
    "/usr/lib/zen-browser"
    "/usr/lib/zen"
    "$HOME/.local/share/zen"
    "$HOME/Applications/zen"
)

# ═══════════════════════════════════════════════════════════════════════════════
# ZEN MODS - UUIDs from zen-browser/theme-store
# ═══════════════════════════════════════════════════════════════════════════════

declare -A ZEN_MODS=(
    ["Better Find Bar"]="a6335949-4465-4b71-926c-4a52d34bc9c0"
    ["Bigger Mute Button"]="5c4d7772-d963-4672-ab03-e9d541438881"
    ["Floating Status Bar"]="906c6915-5677-48ff-9bfc-096a02a72379"
    ["Only Close On Hover"]="4596d8f9-f0b7-4aeb-aa92-851222dc1888"
    ["Private Mode Highlighting"]="58649066-2b6f-4a5b-af6d-c3d21d16fc00"
    ["Trackpad Animation"]="8039de3b-72e1-41ea-83b3-5077cf0f98d1"
    ["Zen Context Menu"]="81fcd6b3-f014-4796-988f-6c3cb3874db8"
)

# ═══════════════════════════════════════════════════════════════════════════════
# FIREFOX EXTENSIONS - Privacy & Productivity focused
# ═══════════════════════════════════════════════════════════════════════════════

declare -A EXTENSIONS=(
    # Privacy Extensions
    ["uBlock Origin"]="uBlock0@raymondhill.net"
    ["ClearURLs"]="{74145f27-f039-47ce-a470-a662b129930a}"
    ["Decentraleyes"]="jid1-BoFifL9Vbdl2zQ@jetpack"
    ["LocalCDN"]="{b86e4813-687a-43e6-ab65-0bde4ab75758}"
    ["Privacy Badger"]="jid1-MnnxcxisBPnSXQ@jetpack"
    ["Privacy Possum"]="woop-NoopscooPsnSXQ@jetpack"
    ["Port Authority"]="{6c00218c-707a-4977-84cf-36df1cef310f}"

    # Productivity Extensions
    ["Bitwarden"]="{446900e4-71c2-419f-a6a7-df9c091e268b}"
    ["Kagi Search"]="search@kagi.com"
    ["Page Assist"]="page-assist@nazeem"
    ["Save webP as PNG"]="savewebpas@jeffersonscher.com"
    ["Wappalyzer"]="wappalyzer@crunchlabz.com"
)

# Extension download URLs (addons.mozilla.org)
declare -A EXTENSION_URLS=(
    ["uBlock Origin"]="https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
    ["ClearURLs"]="https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi"
    ["Decentraleyes"]="https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi"
    ["LocalCDN"]="https://addons.mozilla.org/firefox/downloads/latest/localcdn-fork-of-decentraleyes/latest.xpi"
    ["Privacy Badger"]="https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi"
    ["Privacy Possum"]="https://addons.mozilla.org/firefox/downloads/latest/privacy-possum/latest.xpi"
    ["Port Authority"]="https://addons.mozilla.org/firefox/downloads/latest/port-authority/latest.xpi"
    ["Bitwarden"]="https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi"
    ["Kagi Search"]="https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi"
    ["Page Assist"]="https://addons.mozilla.org/firefox/downloads/latest/page-assist/latest.xpi"
    ["Save webP as PNG"]="https://addons.mozilla.org/firefox/downloads/latest/save-webp-as-png-or-jpeg/latest.xpi"
    ["Wappalyzer"]="https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/latest.xpi"
)

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Find Zen Browser profile directory
find_zen_profile() {
    local zen_dir=""

    # Find .zen directory
    for path in "${ZEN_PATHS[@]}"; do
        if [[ -d "$path" ]]; then
            zen_dir="$path"
            break
        fi
    done

    if [[ -z "$zen_dir" ]]; then
        return 1
    fi

    # Find default profile
    local profiles_ini="$zen_dir/profiles.ini"
    if [[ -f "$profiles_ini" ]]; then
        # Get default profile path
        local profile_path
        profile_path=$(grep -A5 '\[Install' "$profiles_ini" | grep "Default=" | head -1 | cut -d= -f2)

        if [[ -n "$profile_path" ]]; then
            echo "$zen_dir/$profile_path"
            return 0
        fi

        # Fallback: find first profile directory
        profile_path=$(grep "Path=" "$profiles_ini" | head -1 | cut -d= -f2)
        if [[ -n "$profile_path" ]]; then
            echo "$zen_dir/$profile_path"
            return 0
        fi
    fi

    # Last resort: find any profile-like directory
    local profile
    profile=$(find "$zen_dir" -maxdepth 1 -type d -name "*.default*" 2>/dev/null | head -1)
    if [[ -n "$profile" ]]; then
        echo "$profile"
        return 0
    fi

    return 1
}

# Find Zen Browser installation directory (for system-wide policies)
find_zen_install() {
    for path in "${ZEN_INSTALL_PATHS[@]}"; do
        # Check if it's a valid Zen installation (has application.ini or zen binary)
        if [[ -d "$path" ]] && [[ -f "$path/application.ini" || -f "$path/zen" || -f "$path/zen-browser" ]]; then
            echo "$path"
            return 0
        fi
    done

    # Try to find via which and resolve actual installation
    local zen_bin
    zen_bin=$(which zen-browser 2>/dev/null || which zen 2>/dev/null)
    if [[ -n "$zen_bin" ]]; then
        local zen_real
        zen_real=$(readlink -f "$zen_bin")
        local zen_dir
        zen_dir=$(dirname "$zen_real")

        # Verify it's an actual installation directory (not just /usr/bin)
        if [[ -f "$zen_dir/application.ini" ]]; then
            echo "$zen_dir"
            return 0
        fi
    fi

    return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# ZEN MODS INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

install_zen_mods() {
    vibe_header "Installing Zen Mods"

    local profile
    profile=$(find_zen_profile)

    if [[ -z "$profile" ]]; then
        vibe_err "Could not find Zen Browser profile"
        vibe_log "Make sure Zen Browser has been run at least once"
        return 1
    fi

    vibe_log "Found profile: $profile"

    # Create chrome/zen-themes directory if needed
    local themes_dir="$profile/chrome/zen-themes"
    mkdir -p "$themes_dir"

    # Create user.js to enable mods
    local user_js="$profile/user.js"

    vibe_log "Enabling Zen Mods..."

    # Backup existing user.js
    if [[ -f "$user_js" ]]; then
        cp "$user_js" "$user_js.vibearchy-backup"
    fi

    # Add mod preferences
    {
        echo ""
        echo "// ═══════════════════════════════════════════════════════════════════════════════"
        echo "// Vibearchy Zen Mods Configuration"
        echo "// ═══════════════════════════════════════════════════════════════════════════════"
        echo ""
        echo "// Enable userChrome.css customizations"
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
        echo ""
        echo "// Zen Mods - Enabled via theme store"
        for mod_name in "${!ZEN_MODS[@]}"; do
            local uuid="${ZEN_MODS[$mod_name]}"
            echo "// $mod_name"
            echo "user_pref(\"zen.themes.$uuid.enabled\", true);"
        done
    } >> "$user_js"

    echo ""
    for mod_name in "${!ZEN_MODS[@]}"; do
        vibe_ok "Enabled: $mod_name"
    done

    echo ""
    vibe_warn "Note: Mods will be downloaded from Zen Theme Store on browser restart"
    vibe_log "If mods don't appear, install them manually from: zen://mods"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIREFOX EXTENSIONS INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

install_extensions() {
    vibe_header "Setting Up Firefox Extensions"

    local distribution_dir=""
    local profile
    profile=$(find_zen_profile)

    if [[ -z "$profile" ]]; then
        vibe_err "Could not find Zen Browser profile"
        return 1
    fi

    # Use profile-based distribution (works without sudo)
    distribution_dir="$profile/distribution"
    vibe_log "Using profile: $profile"

    # Also try system-wide if we have write access
    local zen_install
    zen_install=$(find_zen_install)
    if [[ -n "$zen_install" ]] && [[ -w "$zen_install" ]]; then
        distribution_dir="$zen_install/distribution"
        vibe_log "Using system installation: $zen_install"
    fi

    mkdir -p "$distribution_dir" 2>/dev/null || {
        # Fallback to profile directory
        distribution_dir="$profile/distribution"
        mkdir -p "$distribution_dir"
    }

    local policies_file="$distribution_dir/policies.json"

    vibe_log "Creating policies.json..."

    # Build extensions install array
    local install_urls=""
    for ext_name in "${!EXTENSION_URLS[@]}"; do
        local url="${EXTENSION_URLS[$ext_name]}"
        if [[ -n "$install_urls" ]]; then
            install_urls="$install_urls,"
        fi
        install_urls="$install_urls
        \"$url\""
    done

    # Create policies.json
    cat > "$policies_file" << EOF
{
  "policies": {
    "ExtensionSettings": {
      "*": {
        "installation_mode": "allowed"
      },
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["uBlock Origin"]}"
      },
      "{74145f27-f039-47ce-a470-a662b129930a}": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["ClearURLs"]}"
      },
      "jid1-BoFifL9Vbdl2zQ@jetpack": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Decentraleyes"]}"
      },
      "{b86e4813-687a-43e6-ab65-0bde4ab75758}": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["LocalCDN"]}"
      },
      "jid1-MnnxcxisBPnSXQ@jetpack": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Privacy Badger"]}"
      },
      "woop-NoopscooPsnSXQ@jetpack": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Privacy Possum"]}"
      },
      "{6c00218c-707a-4977-84cf-36df1cef310f}": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Port Authority"]}"
      },
      "{446900e4-71c2-419f-a6a7-df9c091e268b}": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Bitwarden"]}"
      },
      "search@kagi.com": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Kagi Search"]}"
      },
      "page-assist@nazeem": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Page Assist"]}"
      },
      "savewebpas@jeffersonscher.com": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Save webP as PNG"]}"
      },
      "wappalyzer@crunchlabz.com": {
        "installation_mode": "force_installed",
        "install_url": "${EXTENSION_URLS["Wappalyzer"]}"
      }
    },
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "EnableTrackingProtection": {
      "Value": true,
      "Locked": false,
      "Cryptomining": true,
      "Fingerprinting": true
    },
    "SearchEngines": {
      "Default": "Kagi",
      "Remove": ["Google", "Bing", "Amazon.com", "eBay"]
    }
  }
}
EOF

    vibe_ok "Created policies.json at: $policies_file"

    echo ""
    vibe_subheader "Extensions to be installed"
    for ext_name in "${!EXTENSIONS[@]}"; do
        echo "  - $ext_name"
    done

    echo ""
    vibe_warn "Extensions will be installed on next browser restart"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SEARCH ENGINE & PRIVACY SETTINGS
# ═══════════════════════════════════════════════════════════════════════════════

configure_privacy() {
    vibe_header "Configuring Privacy Settings"

    local profile
    profile=$(find_zen_profile)

    if [[ -z "$profile" ]]; then
        vibe_err "Could not find Zen Browser profile"
        return 1
    fi

    local user_js="$profile/user.js"

    vibe_log "Adding privacy preferences to user.js..."

    {
        echo ""
        echo "// ═══════════════════════════════════════════════════════════════════════════════"
        echo "// Vibearchy Privacy Configuration"
        echo "// ═══════════════════════════════════════════════════════════════════════════════"
        echo ""
        echo "// Disable telemetry"
        echo 'user_pref("toolkit.telemetry.enabled", false);'
        echo 'user_pref("toolkit.telemetry.unified", false);'
        echo 'user_pref("datareporting.healthreport.uploadEnabled", false);'
        echo 'user_pref("datareporting.policy.dataSubmissionEnabled", false);'
        echo ""
        echo "// Enhanced tracking protection"
        echo 'user_pref("privacy.trackingprotection.enabled", true);'
        echo 'user_pref("privacy.trackingprotection.socialtracking.enabled", true);'
        echo 'user_pref("privacy.trackingprotection.cryptomining.enabled", true);'
        echo 'user_pref("privacy.trackingprotection.fingerprinting.enabled", true);'
        echo ""
        echo "// Disable Pocket"
        echo 'user_pref("extensions.pocket.enabled", false);'
        echo ""
        echo "// HTTPS-Only mode"
        echo 'user_pref("dom.security.https_only_mode", true);'
        echo ""
        echo "// Disable prefetching"
        echo 'user_pref("network.prefetch-next", false);'
        echo 'user_pref("network.dns.disablePrefetch", true);'
        echo ""
        echo "// Resist fingerprinting (may break some sites)"
        echo '// user_pref("privacy.resistFingerprinting", true);'
    } >> "$user_js"

    vibe_ok "Privacy settings configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTERACTIVE MENU
# ═══════════════════════════════════════════════════════════════════════════════

show_menu() {
    vibe_banner_compact "Zen Browser Setup"

    echo -e "${BOLD}Configure Zen Browser with Vibearchy defaults:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Install Zen Mods        - UI enhancements"
    echo -e "  ${CYAN}2)${NC} Setup Extensions        - Privacy & productivity"
    echo -e "  ${CYAN}3)${NC} Configure Privacy       - Telemetry & tracking"
    echo -e "  ${CYAN}4)${NC} All of the above        - Full setup"
    echo ""
    echo -e "  ${CYAN}0)${NC} Exit"
    echo ""

    read -p "Select options (e.g., 1 2 or 4): " -a choices

    local do_mods=false
    local do_extensions=false
    local do_privacy=false

    for choice in "${choices[@]}"; do
        case "$choice" in
            1) do_mods=true ;;
            2) do_extensions=true ;;
            3) do_privacy=true ;;
            4) do_mods=true; do_extensions=true; do_privacy=true ;;
            0) vibe_log "Cancelled"; exit 0 ;;
            *) vibe_warn "Unknown option: $choice" ;;
        esac
    done

    echo ""

    $do_mods && install_zen_mods
    $do_extensions && install_extensions
    $do_privacy && configure_privacy
}

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

show_summary() {
    vibe_header "Setup Complete"

    echo -e "${BOLD}Zen Mods:${NC}"
    for mod_name in "${!ZEN_MODS[@]}"; do
        echo "  - $mod_name"
    done

    echo ""
    echo -e "${BOLD}Extensions:${NC}"
    echo "  Privacy: uBlock Origin, ClearURLs, Decentraleyes, LocalCDN,"
    echo "           Privacy Badger, Privacy Possum, Port Authority"
    echo "  Productivity: Bitwarden, Kagi Search, Page Assist,"
    echo "                Save webP as PNG, Wappalyzer"

    echo ""
    echo -e "${BOLD}Search Engine:${NC} Kagi Search"

    echo ""
    vibe_warn "Restart Zen Browser for changes to take effect"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    case "${1:-}" in
        --mods)
            install_zen_mods
            ;;
        --extensions)
            install_extensions
            ;;
        --privacy)
            configure_privacy
            ;;
        --all)
            install_zen_mods
            install_extensions
            configure_privacy
            show_summary
            ;;
        "")
            show_menu
            show_summary
            ;;
        *)
            echo "Usage: $0 [--mods|--extensions|--privacy|--all]"
            exit 1
            ;;
    esac
}

main "$@"

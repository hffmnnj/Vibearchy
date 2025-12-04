#!/bin/bash

# Vibearchy Sync Script
# Sync changes from ~/.config back to the repo
# Useful when you edit configs directly instead of through the symlinks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIBEARCHY_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="$VIBEARCHY_DIR/packages"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Mapping of packages to their source locations
declare -A PACKAGE_SOURCES=(
    ["hypr"]=".config/hypr"
    ["waybar"]=".config/waybar"
    ["rofi"]=".config/rofi"
    ["shell"]=".config/fish .config/starship"
    ["terminals"]=".config/ghostty .config/kitty"
    ["nvim"]=".config/nvim"
    ["swaync"]=".config/swaync"
    ["wallpapers"]=".local/share/wallpapers"
    ["ssh"]=".ssh/config"
)

sync_package() {
    local pkg="$1"
    local sources="${PACKAGE_SOURCES[$pkg]}"

    if [[ -z "$sources" ]]; then
        log_warn "Unknown package: $pkg"
        return 1
    fi

    log_info "Syncing $pkg..."

    for src in $sources; do
        local home_path="$HOME/$src"
        local repo_path="$PACKAGES_DIR/$pkg/$src"

        if [[ ! -e "$home_path" ]]; then
            log_warn "  Source not found: $home_path"
            continue
        fi

        # Check if it's already a symlink to our repo
        if [[ -L "$home_path" ]]; then
            local link_target=$(readlink -f "$home_path")
            if [[ "$link_target" == "$repo_path"* ]]; then
                log_success "  $src is already symlinked (in sync)"
                continue
            fi
        fi

        # Create parent directory
        mkdir -p "$(dirname "$repo_path")"

        # Sync using rsync
        if [[ -d "$home_path" ]]; then
            rsync -av --delete "$home_path/" "$repo_path/"
        else
            rsync -av "$home_path" "$repo_path"
        fi

        log_success "  Synced: $src"
    done
}

sync_all() {
    log_info "Syncing all packages from system to repo..."
    echo ""

    for pkg in "${!PACKAGE_SOURCES[@]}"; do
        sync_package "$pkg"
        echo ""
    done

    log_success "Sync complete!"
}

check_diff() {
    log_info "Checking for differences..."
    echo ""

    local has_diff=false

    for pkg in "${!PACKAGE_SOURCES[@]}"; do
        local sources="${PACKAGE_SOURCES[$pkg]}"

        for src in $sources; do
            local home_path="$HOME/$src"
            local repo_path="$PACKAGES_DIR/$pkg/$src"

            if [[ ! -e "$home_path" ]] || [[ ! -e "$repo_path" ]]; then
                continue
            fi

            # Skip if symlink
            if [[ -L "$home_path" ]]; then
                continue
            fi

            if ! diff -rq "$home_path" "$repo_path" &>/dev/null; then
                echo -e "${YELLOW}[$pkg]${NC} $src has changes"
                has_diff=true
            fi
        done
    done

    if ! $has_diff; then
        log_success "All packages are in sync!"
    fi
}

usage() {
    echo "Usage: $0 <command> [package]"
    echo ""
    echo "Commands:"
    echo "  sync <pkg>     Sync a single package from system to repo"
    echo "  sync-all       Sync all packages from system to repo"
    echo "  diff           Check for differences between system and repo"
    echo ""
    echo "Note: If you're using stow symlinks, files are already in sync!"
    echo "This script is for when you edit configs directly without stow."
    echo ""
}

case "${1:-}" in
    sync)
        if [[ -z "${2:-}" ]]; then
            echo "Available packages: ${!PACKAGE_SOURCES[*]}"
            exit 1
        fi
        sync_package "$2"
        ;;
    sync-all)
        sync_all
        ;;
    diff)
        check_diff
        ;;
    *)
        usage
        ;;
esac

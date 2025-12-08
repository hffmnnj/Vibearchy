# Helium Browser Configuration

Privacy-focused Chromium browser configured as the secondary browser in Vibearchy.

## Overview

Helium is a privacy-first, Chromium-based browser with:
- Built-in ad/tracker blocking
- Zero telemetry on first launch
- Support for all Chrome extensions
- Regular Chromium security updates

## Installation

```bash
yay -S helium-browser-bin
```

Or via Vibearchy apps script:

```bash
cd ~/Documents/Vibearchy/scripts
./apps.sh install privacy
```

## Configuration

The configuration includes:
- **Wayland support** - Native Wayland with window decorations
- **Privacy flags** - Disables telemetry, sync, and background networking
- **Performance** - GPU rasterization and zero-copy enabled
- **Dark mode** - Force dark theme across all websites

## Keybindings

- **Super + Shift + W** - Launch Helium Browser (secondary browser)
- **Super + W** - Launch Zen Browser (primary)

## File Locations

- Config: `~/.config/helium/chromium-flags.conf`
- User data: `~/.config/helium/`

## Extensions

> **Note**: Helium includes uBlock Origin pre-installed.

Install extensions directly from the Chrome Web Store. See [extensions.md](.config/helium/extensions.md) for the complete list.

**Privacy**:
- [ClearURLs](https://chromewebstore.google.com/detail/clearurls/lckanjgmijmafbedllaakclkaicjfmnk) - Remove tracking from URLs
- [Privacy Badger](https://chromewebstore.google.com/detail/privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp) - Block invisible trackers

**Productivity**:
- [Bitwarden](https://chromewebstore.google.com/detail/bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb) - Password manager
- [Kagi Search](https://chromewebstore.google.com/detail/kagi-search/cdglnehniifkbagbbombnjghhcihifij) - Privacy-focused search
- [Wappalyzer](https://chromewebstore.google.com/detail/wappalyzer-technology-pro/gppongmhjkpfnbhagpmjfkannfbllamg) - Tech profiler
- [Save image as Type](https://chromewebstore.google.com/detail/save-image-as-type/gabfmnliflodkdafenbcpjdlppllnemd) - WebP converter

**AI**:
- [Claude for Chrome](https://claude.ai/chrome) - Official Anthropic extension
- [Page Assist](https://chromewebstore.google.com/detail/page-assist-a-web-ui-for/jfgfiigpkhlkbnfnbobbkinehhfdhndo) - Local AI with Ollama

## Stow Installation

```bash
cd ~/Documents/Vibearchy/packages
stow helium
```

This will symlink the configuration to `~/.config/helium/`.

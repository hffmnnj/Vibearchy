#!/bin/bash
#
# Vibearchy Icon Library
# Nerd Font icons for consistent UI across all scripts
#
# Source this file to use icons:
#   source "$VIBEARCHY_LIB/icons.sh"

# Prevent double-sourcing
[[ -n "$_VIBEARCHY_ICONS_LOADED" ]] && return 0
readonly _VIBEARCHY_ICONS_LOADED=1

# ═══════════════════════════════════════════════════════════════════════════════
# POWER / SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_POWER='󰐥'
readonly ICON_REBOOT='󰜉'
readonly ICON_LOCK='󰌾'
readonly ICON_LOGOUT='󰍃'
readonly ICON_SUSPEND='󰤄'
readonly ICON_HIBERNATE='󰒲'
readonly ICON_FIRMWARE='󰘚'

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIRMATION
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_YES='󰸞'
readonly ICON_NO='󱎘'
readonly ICON_CHECK='󰄬'
readonly ICON_CROSS='󰅖'
readonly ICON_WARN='󰀦'
readonly ICON_INFO='󰋽'

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATIONS
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_TERMINAL='󰆍'
readonly ICON_BROWSER='󰖟'
readonly ICON_EDITOR='󰅩'
readonly ICON_FILES='󰉋'
readonly ICON_SETTINGS='󰒓'
readonly ICON_APP='󰀲'
readonly ICON_SEARCH='󰍉'

# ═══════════════════════════════════════════════════════════════════════════════
# AI TOOLS
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_AI='󰧑'
readonly ICON_CHAT='󰭻'
readonly ICON_OLLAMA='󱙺'
readonly ICON_CLAUDE='󰘦'
readonly ICON_BRAIN='󰠃'
readonly ICON_ROBOT='󰚩'
readonly ICON_SPARK='󱐋'
readonly ICON_MCP='󱂛'

# ═══════════════════════════════════════════════════════════════════════════════
# NETWORK / VPN
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_VPN='󰖂'
readonly ICON_NETWORK='󰒍'
readonly ICON_WIFI='󰖩'
readonly ICON_WIFI_OFF='󰖪'
readonly ICON_CONNECT='󰌾'
readonly ICON_DISCONNECT='󰌿'
readonly ICON_SHIELD='󰒃'
readonly ICON_DNS='󰇖'

# ═══════════════════════════════════════════════════════════════════════════════
# CLIPBOARD
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_CLIPBOARD='󰅍'
readonly ICON_COPY='󰆏'
readonly ICON_PASTE='󰆒'
readonly ICON_HISTORY='󰋚'
readonly ICON_CLEAR='󰃢'
readonly ICON_DELETE='󰆴'

# ═══════════════════════════════════════════════════════════════════════════════
# MEDIA / SCREENSHOTS
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_CAMERA='󰄀'
readonly ICON_SCREENSHOT='󰹑'
readonly ICON_SCREEN='󰍹'
readonly ICON_REGION='󰩭'
readonly ICON_WINDOW='󰖲'
readonly ICON_TIMER='󱎫'
readonly ICON_IMAGE='󰋩'
readonly ICON_SAVE='󰆓'
readonly ICON_OCR='󰗊'

# ═══════════════════════════════════════════════════════════════════════════════
# WALLPAPER
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_WALLPAPER='󰸉'
readonly ICON_PICTURE='󰋩'
readonly ICON_RANDOM='󰒝'
readonly ICON_FOLDER='󰉋'
readonly ICON_GALLERY='󰥶'

# ═══════════════════════════════════════════════════════════════════════════════
# EMOJI
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_EMOJI='󰱫'
readonly ICON_SMILE='󰞅'
readonly ICON_RECENT='󰣜'
readonly ICON_CATEGORY='󰓹'

# ═══════════════════════════════════════════════════════════════════════════════
# SSH / REMOTE
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_SSH='󰣀'
readonly ICON_SERVER='󰒍'
readonly ICON_KEY='󰌆'
readonly ICON_CLOUD='󰅧'
readonly ICON_TUNNEL='󱘖'

# ═══════════════════════════════════════════════════════════════════════════════
# DEVELOPMENT
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_GIT='󰊢'
readonly ICON_BRANCH='󰘬'
readonly ICON_CODE='󰅩'
readonly ICON_BUG='󰃤'
readonly ICON_DOCKER='󰡨'
readonly ICON_PACKAGE='󰏖'

# ═══════════════════════════════════════════════════════════════════════════════
# NAVIGATION
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_BACK='󰁍'
readonly ICON_FORWARD='󰁔'
readonly ICON_UP='󰁝'
readonly ICON_DOWN='󰁅'
readonly ICON_HOME='󰋜'
readonly ICON_EXIT='󰗼'
readonly ICON_REFRESH='󰑓'

# ═══════════════════════════════════════════════════════════════════════════════
# STATUS
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_ON='󰔡'
readonly ICON_OFF='󰔢'
readonly ICON_ACTIVE='󰄬'
readonly ICON_INACTIVE='󰄰'
readonly ICON_LOADING='󰔟'
readonly ICON_SUCCESS='󰄬'
readonly ICON_ERROR='󰅖'

# ═══════════════════════════════════════════════════════════════════════════════
# COUNTRIES (for VPN menu)
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_AUTO='󰈀'
readonly ICON_US='󰴽'
readonly ICON_UK='󰴿'
readonly ICON_DE='󰴺'
readonly ICON_NL='󰿘'
readonly ICON_SE='󰴾'
readonly ICON_JP='󰴻'
readonly ICON_AU='󰵀'
readonly ICON_CA='󰴼'
readonly ICON_CH='󰴽'

# ═══════════════════════════════════════════════════════════════════════════════
# MISC
# ═══════════════════════════════════════════════════════════════════════════════

readonly ICON_KEYBOARD='󰌌'
readonly ICON_KEYBIND='󰌓'
readonly ICON_STAR='󰓎'
readonly ICON_HEART='󰋑'
readonly ICON_FLAME='󰈸'
readonly ICON_MOON='󰖙'
readonly ICON_SUN='󰖨'
readonly ICON_MUSIC='󰝚'
readonly ICON_VOLUME='󰕾'
readonly ICON_MUTE='󰖁'

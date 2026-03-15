#!/usr/bin/env bash
# Update checker for Waybar with improved error handling

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

_checkCommandExists() {
    command -v "$1" >/dev/null 2>&1
}

_retry_curl() {
    local max_attempts=3
    local timeout=10
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if timeout "$timeout" curl -fsS "$@"; then
            return 0
        fi
        ((attempt++))
        [[ $attempt -le $max_attempts ]] && sleep 2
    done
    
    return 1
}

# ============================================================================
# LOCK MANAGEMENT
# ============================================================================

LOCK_FILE="/tmp/updates-waybar.lock"
LOCK_FD=200

# Clean up lock file on exit
trap 'rm -f "$LOCK_FILE"' EXIT

exec 200>"$LOCK_FILE"

# Prevent concurrent runs
if ! flock -n 200; then
    echo '{"text": "", "tooltip": "Update check in progress...", "class": "updates-yellow"}'
    exit 0
fi

# ============================================================================
# CONFIGURATION
# ============================================================================

THRESHOLD_YELLOW=${THRESHOLD_YELLOW:-25}
THRESHOLD_RED=${THRESHOLD_RED:-100}
CSS_CLASS="updates-green"
UPDATES=0

# ============================================================================
# CHECK FOR UPDATES
# ============================================================================

if _checkCommandExists pacman; then
    # Wait for pacman lock
    WAIT_TIME=0
    while [[ -f /var/lib/pacman/db.lck ]] && [[ $WAIT_TIME -lt 30 ]]; do
        sleep 1
        ((WAIT_TIME++))
    done

    UPDATES_PACMAN=0
    UPDATES_AUR=0
    UPDATES_FLATPAK=0

    # Pacman updates
    if command -v checkupdates >/dev/null 2>&1; then
        UPDATES_PACMAN=$(checkupdates 2>/dev/null | wc -l) || UPDATES_PACMAN=0
    fi

    # AUR updates - detect helper
    if _checkCommandExists paru && ! _checkCommandExists yay; then
        AUR_HELPER="paru"
    elif _checkCommandExists yay; then
        AUR_HELPER="yay"
    else
        AUR_HELPER=""
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        UPDATES_AUR=$($AUR_HELPER -Qum 2>/dev/null | wc -l) || UPDATES_AUR=0
    fi

    # Flatpak updates
    if _checkCommandExists flatpak; then
        UPDATES_FLATPAK=$(flatpak remote-ls --updates flathub 2>/dev/null | wc -l) || UPDATES_FLATPAK=0
    fi

    UPDATES=$((UPDATES_AUR + UPDATES_PACMAN + UPDATES_FLATPAK))

elif _checkCommandExists dnf; then
    # Fedora/RHEL support
    UPDATES=$(dnf check-update -q 2>/dev/null | grep -c '^[a-zA-Z0-9]' || echo 0)
fi

# ============================================================================
# DETERMINE CSS CLASS & NOTIFICATION
# ============================================================================

if [[ $UPDATES -gt $THRESHOLD_RED ]]; then
    CSS_CLASS="updates-red"
    # Auto-notify on critical
    notify-send -u critical "Critical Updates" "$UPDATES updates available! Please update soon." 2>/dev/null || true
elif [[ $UPDATES -gt $THRESHOLD_YELLOW ]]; then
    CSS_CLASS="updates-yellow"
else
    CSS_CLASS="updates-green"
fi

# ============================================================================
# OUTPUT FOR WAYBAR
# ============================================================================

if [[ $UPDATES -gt 0 ]]; then
    TOOLTIP="📦 Pacman: $UPDATES_PACMAN | 🏗️  AUR: $UPDATES_AUR | 📦 Flatpak: $UPDATES_FLATPAK\n\nClick to update your system"
    TEXT=" $UPDATES"
else
    TOOLTIP="✓ System is up to date"
    TEXT=""
fi

# Output valid JSON for Waybar
printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}\n' \
    "$TEXT" "$UPDATES" "$TOOLTIP" "$CSS_CLASS"

exit 0
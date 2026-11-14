#!/usr/bin/env bash
# Update checker for Waybar with improved error handling

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

_checkCommandExists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# LOCK MANAGEMENT
# ============================================================================

STATE_DIR="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/waybar}"
mkdir -p "$STATE_DIR" || exit 1
LOCK_FILE="$STATE_DIR/updates-check.lock"
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
CHECK_FAILED=0
UPDATES_PACMAN=0
UPDATES_AUR=0
UPDATES_FLATPAK=0

count_lines() {
    awk 'NF { count++ } END { print count + 0 }' <<< "$1"
}

# ============================================================================
# CHECK FOR UPDATES
# ============================================================================

if _checkCommandExists pacman; then
    WAIT_TIME=0
    while [[ -f /var/lib/pacman/db.lck ]] && [[ $WAIT_TIME -lt 30 ]]; do
        sleep 1
        ((WAIT_TIME++))
    done

    if [[ -f /var/lib/pacman/db.lck ]]; then
        CHECK_FAILED=1
    elif _checkCommandExists checkupdates; then
        PACMAN_OUTPUT=$(checkupdates 2>/dev/null)
        PACMAN_STATUS=$?
        if [[ $PACMAN_STATUS -eq 0 || $PACMAN_STATUS -eq 2 ]]; then
            UPDATES_PACMAN=$(count_lines "$PACMAN_OUTPUT")
        else
            CHECK_FAILED=1
        fi
    else
        PACMAN_OUTPUT=$(pacman -Qu 2>&1)
        PACMAN_STATUS=$?
        if [[ $PACMAN_STATUS -eq 0 || ( $PACMAN_STATUS -eq 1 && -z $PACMAN_OUTPUT ) ]]; then
            UPDATES_PACMAN=$(count_lines "$PACMAN_OUTPUT")
        else
            CHECK_FAILED=1
        fi
    fi

    if _checkCommandExists paru; then
        AUR_HELPER="paru"
    elif _checkCommandExists yay; then
        AUR_HELPER="yay"
    else
        AUR_HELPER=""
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        AUR_OUTPUT=$("$AUR_HELPER" -Qum 2>&1)
        AUR_STATUS=$?
        if [[ $AUR_STATUS -eq 0 || ( $AUR_STATUS -eq 1 && -z $AUR_OUTPUT ) ]]; then
            UPDATES_AUR=$(count_lines "$AUR_OUTPUT")
        else
            CHECK_FAILED=1
        fi
    fi

    if _checkCommandExists flatpak; then
        FLATPAK_OUTPUT=$(flatpak remote-ls --updates flathub 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            UPDATES_FLATPAK=$(count_lines "$FLATPAK_OUTPUT")
        else
            CHECK_FAILED=1
        fi
    fi

    UPDATES=$((UPDATES_AUR + UPDATES_PACMAN + UPDATES_FLATPAK))
elif _checkCommandExists dnf; then
    DNF_OUTPUT=$(dnf check-update -q 2>/dev/null)
    DNF_STATUS=$?
    if [[ $DNF_STATUS -eq 0 || $DNF_STATUS -eq 100 ]]; then
        UPDATES=$(awk 'NF && /^[[:alnum:]]/ { count++ } END { print count + 0 }' <<< "$DNF_OUTPUT")
    else
        CHECK_FAILED=1
    fi
else
    CHECK_FAILED=1
fi

# ============================================================================
# DETERMINE CSS CLASS & NOTIFICATION
# ============================================================================

if [[ $CHECK_FAILED -eq 1 ]]; then
    CSS_CLASS="updates-error"
elif [[ $UPDATES -gt $THRESHOLD_RED ]]; then
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

if [[ $CHECK_FAILED -eq 1 ]]; then
    TOOLTIP="Unable to check for updates"
    TEXT="?"
elif [[ $UPDATES -gt 0 ]]; then
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
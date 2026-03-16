#!/usr/bin/env bash

# ============================================================================
# COLOR CODES & LOGGING
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# ============================================================================
# CONFIGURATION
# ============================================================================
UPDATE_LOG="$HOME/.local/share/devitana/update.log"
LOG_DIR="$(dirname "$UPDATE_LOG")"
LOCK_FILE="/tmp/devitana-update.lock"

# ============================================================================
# CLEANUP & EXIT HANDLERS
# ============================================================================
cleanup() {
    rm -f "$LOCK_FILE"
}

trap cleanup EXIT

error_exit() {
    log_error "$1"
    notify-send -u critical "Update Failed" "$1" 2>/dev/null || true
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ERROR - $1" >> "$UPDATE_LOG" 2>/dev/null
    
    echo ""
    read -p "Press Enter to close..."
    exit 1
}

# ============================================================================
# PRELIMINARY CHECKS
# ============================================================================

# Check if already running
if [[ -f "$LOCK_FILE" ]]; then
    log_warning "Update already in progress. Exiting."
    read -p "Press Enter to close..."
    exit 0
fi
touch "$LOCK_FILE"

# Create log directory
mkdir -p "$LOG_DIR" 2>/dev/null || true

# Check if running as regular user (sudo will be used)
if [[ $EUID -eq 0 ]]; then
    error_exit "This script should not be run as root"
fi

# Check sudo availability
if ! command -v sudo &>/dev/null; then
    error_exit "sudo is not installed"
fi

# ============================================================================
# DISPLAY HEADER
# ============================================================================
sleep 1

if command -v figlet >/dev/null 2>&1; then
    figlet -f smslant "Updates" 2>/dev/null || echo "=== System Updates ==="
else
    echo -e "${CYAN}━━━━━━━━���━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} System Updates${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo
log_info "Update started at $(date '+%Y-%m-%d %H:%M:%S')"
echo "$(date '+%Y-%m-%d %H:%M:%S'): Update started" >> "$UPDATE_LOG" 2>/dev/null

# ============================================================================
# PACMAN UPDATES (Official Repos)
# ============================================================================
log_info "Updating official Arch repositories..."
echo

# Wait for pacman lock
WAIT_TIME=0
while [[ -f /var/lib/pacman/db.lck ]] && [[ $WAIT_TIME -lt 60 ]]; do
    log_warning "Pacman database locked. Waiting... ($WAIT_TIME/60s)"
    sleep 2
    ((WAIT_TIME+=2))
done

if [[ -f /var/lib/pacman/db.lck ]]; then
    error_exit "Pacman database still locked after 60 seconds"
fi

# Update pacman - THIS WILL PROMPT FOR PASSWORD IN TERMINAL
if ! sudo pacman -Syu; then
    error_exit "Pacman update failed"
fi

log_success "Pacman updates completed"
echo "$(date '+%Y-%m-%d %H:%M:%S'): Pacman update successful" >> "$UPDATE_LOG" 2>/dev/null

# ============================================================================
# AUR UPDATES
# ============================================================================
echo
log_info "Checking for AUR updates..."

# Detect AUR helper
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
else
    log_warning "No AUR helper found (yay/paru). Skipping AUR updates."
    echo "$(date '+%Y-%m-%d %H:%M:%S'): No AUR helper found" >> "$UPDATE_LOG" 2>/dev/null
fi

if [[ -n "$AUR_HELPER" ]]; then
    log_info "Using $AUR_HELPER for AUR updates..."
    echo
    
    if ! $AUR_HELPER -Syu --noconfirm; then
        log_error "$AUR_HELPER update encountered an error (non-critical, continuing...)"
        notify-send -u normal "Update Warning" "$AUR_HELPER had issues, but pacman succeeded." 2>/dev/null || true
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $AUR_HELPER update had issues" >> "$UPDATE_LOG" 2>/dev/null
    else
        log_success "$AUR_HELPER updates completed"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $AUR_HELPER update successful" >> "$UPDATE_LOG" 2>/dev/null
    fi
fi

# ============================================================================
# FLATPAK UPDATES
# ============================================================================
echo
log_info "Checking for Flatpak updates..."

if command -v flatpak >/dev/null 2>&1; then
    echo
    
    if ! flatpak update --assumeyes; then
        log_error "Flatpak update encountered an error (non-critical, continuing...)"
        notify-send -u normal "Update Warning" "Flatpak update had issues." 2>/dev/null || true
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Flatpak update had issues" >> "$UPDATE_LOG" 2>/dev/null
    else
        log_success "Flatpak updates completed"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Flatpak update successful" >> "$UPDATE_LOG" 2>/dev/null
    fi
else
    log_warning "Flatpak not installed. Skipping..."
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Flatpak not installed" >> "$UPDATE_LOG" 2>/dev/null
fi

# ============================================================================
# RELOAD WAYBAR & NOTIFY
# ============================================================================
echo
log_info "Reloading Waybar..."
pkill -RTMIN+1 waybar 2>/dev/null || log_warning "Waybar not running"

# ============================================================================
# FINISH
# ============================================================================
echo
log_success "All updates completed successfully!"
notify-send -u normal "Update Complete" "All system updates applied successfully." 2>/dev/null || true
echo "$(date '+%Y-%m-%d %H:%M:%S'): Update completed successfully" >> "$UPDATE_LOG" 2>/dev/null

# Display summary
echo
log_info "Update log: $UPDATE_LOG"
echo

read -p "Press Enter to close..."
exit 0
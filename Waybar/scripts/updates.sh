#!/usr/bin/env bash
# _ _ _ _
# | | | |_ __ __| | __ _| |_ ___ ___
# | | | | '_ \ / _` |/ _` | __/ _ \/ __|
# | |_| | |_) | (_| | (_| | || __/\__ \
# \___/| .__/ \__,_|\__,_|\__\___||___/
# |_|
# Check if command exists
_checkCommandExists() {
  command -v "$1" >/dev/null
}

script_name=$(basename "$0")

# Use flock to prevent concurrent runs
exec 200>/tmp/updates.lock
if ! flock -n 200; then
  echo "Another instance running, exiting."
  exit 0
fi

# Thresholds for color classes (configurable via env vars)
threshold_yellow=${THRESHOLD_YELLOW:-25}
threshold_red=${THRESHOLD_RED:-100}

# -----------------------------------------------------
# Check for updates
# -----------------------------------------------------
updates=0
updates_pacman=0
updates_aur=0
updates_flatpak=0
css_class="updates-green" # default

if _checkCommandExists pacman; then
  # Wait for pacman or checkupdates lock files
  while [ -f /var/lib/pacman/db.lck ] || [ -f "${TMPDIR:-/tmp}/checkup-db-${UID}/db.lck" ]; do
    sleep 1
  done

  # Determine AUR helper
  if _checkCommandExists yay && ! _checkCommandExists paru; then
    aur_helper="yay"
  elif _checkCommandExists paru; then
    aur_helper="paru"
  else
    aur_helper="yay"
  fi

  # AUR updates
  updates_aur=$($aur_helper -Qum 2>/dev/null | wc -l) || updates_aur=0

  # Pacman updates
  updates_pacman=$(checkupdates 2>/dev/null | wc -l) || updates_pacman=0

  # Flatpak updates (if installed)
  if _checkCommandExists flatpak; then
    updates_flatpak=$(flatpak remote-ls --updates flathub 2>/dev/null | wc -l) || updates_flatpak=0
  fi

  updates=$((updates_aur + updates_pacman + updates_flatpak))
elif _checkCommandExists dnf; then
  updates=$(dnf check-update -q | grep -c '^[a-zA-Z0-9]' || echo 0)
fi

# -----------------------------------------------------
# Set CSS class based on update count
# -----------------------------------------------------
if [ "$updates" -gt "$threshold_red" ]; then
  css_class="updates-red"
  notify-send -u critical "Critical Updates" "$updates updates available! Update soon."  # Auto-notify on red
elif [ "$updates" -gt "$threshold_yellow" ]; then
  css_class="updates-yellow"
else
  css_class="updates-green"
fi

# -----------------------------------------------------
# Always output valid JSON for Waybar
# -----------------------------------------------------
if [ "$updates" -gt 0 ]; then
  tooltip="Click to update your system ($updates_pacman pacman + $updates_aur AUR + $updates_flatpak Flatpak updates available)"
  text=" $updates"
else
  tooltip="System is up to date"
  text="" # Empty text + hide-empty-text = module disappears when up-to-date
fi
printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}\n' \
  "$text" "$updates" "$tooltip" "$css_class"
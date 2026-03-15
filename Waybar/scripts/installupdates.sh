#!/usr/bin/env bash
# ____ __ ____ __ __
# / _/__ ___ / /____ _/ / / __ _____ ___/ /__ _/ /____ ___
# _/ // _ \(_-</ __/ _ `/ / / / // / _ \/ _ / _ `/ __/ -_|_-<
# /___/_//_/___/\__/\_,_/_/_/ \_,_/ .__/\_,_/\_,_/\__/\__/___/
# /_/
# ------------------------------------------------------
# Direct Update Script (no confirmation)
# ------------------------------------------------------
sleep 1
# clear  # Commented out to preserve terminal logs if needed

# Fallback for figlet if not installed
if command -v figlet >/dev/null; then
  figlet -f smslant "Updates"
else
  echo "Updates"
fi
echo
echo ":: Update started..."
echo

# Log start time
echo "$(date): Update started" >> ~/.update_log

# -----------------------------------------------------
# Perform updates (Arch official repos only)
# -----------------------------------------------------
echo ":: Updating official Arch repositories..."
sudo pacman -Syu
if [ $? -ne 0 ]; then
  notify-send -u critical "Update Failed" "Pacman update encountered an error."
  echo "$(date): Pacman update failed" >> ~/.update_log
  exit 1
fi

# -----------------------------------------------------
# AUR updates (if helper installed)
# -----------------------------------------------------
echo
echo ":: Updating AUR packages..."
if command -v yay >/dev/null; then
  yay -Syu --noconfirm
  if [ $? -ne 0 ]; then
    notify-send -u critical "Update Failed" "Yay AUR update encountered an error."
    echo "$(date): Yay update failed" >> ~/.update_log
    exit 1
  fi
elif command -v paru >/dev/null; then
  paru -Syu --noconfirm
  if [ $? -ne 0 ]; then
    notify-send -u critical "Update Failed" "Paru AUR update encountered an error."
    echo "$(date): Paru update failed" >> ~/.update_log
    exit 1
  fi
else
  echo ":: No AUR helper (yay/paru) found, skipping..."
fi

# -----------------------------------------------------
# Flatpak updates
# -----------------------------------------------------
echo
if command -v flatpak >/dev/null; then
  echo ":: Searching for Flatpak updates..."
  flatpak update --assumeyes
  if [ $? -ne 0 ]; then
    notify-send -u critical "Update Failed" "Flatpak update encountered an error."
    echo "$(date): Flatpak update failed" >> ~/.update_log
    exit 1
  fi
else
  echo ":: No Flatpak installed, skipping..."
fi

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------
echo
echo ":: Reloading Waybar..."
pkill -RTMIN+1 waybar 2>/dev/null || true

# -----------------------------------------------------
# Finish
# -----------------------------------------------------
echo
echo ":: Update complete!"
notify-send "Update Complete" "All updates applied successfully."
echo "$(date): Update complete" >> ~/.update_log
sleep 5  # Auto-close after 5 seconds
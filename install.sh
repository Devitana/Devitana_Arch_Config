#!/usr/bin/env bash

set -e

echo "==> Installing Waybar dependencies..."

sudo pacman -S --needed --noconfirm \
  waybar \
  ttf-font-awesome \
  noto-fonts \
  jq \
  playerctl \
  grim \
  slurp \
  wl-clipboard

echo "==> Installing Waybar config..."

CONFIG_DIR="$HOME/.config/waybar"

mkdir -p "$CONFIG_DIR"

cp -r waybar/* "$CONFIG_DIR"

echo "==> Making scripts executable..."

chmod +x "$CONFIG_DIR"/scripts/*.sh 2>/dev/null || true

echo "==> Done!"
echo "Restart Waybar or log out/in."
#!/usr/bin/env bash

set -euo pipefail

### ========= CONFIG ========= ###
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/configs"
BACKUP_DIR="$HOME/.config-backup-$(date +%s)"

### ========= LOGGING ========= ###
log() { echo -e "\e[1;32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $1"; }
err()  { echo -e "\e[1;31m[ERROR]\e[0m $1"; exit 1; }

### ========= CHECKS ========= ###
require_user() {
    [[ $EUID -eq 0 ]] && err "Do NOT run as root"
}

### ========= GPU DETECTION ========= ###
install_gpu_drivers() {
    log "Detecting GPU..."

    GPU=$(lspci | grep -E "VGA|3D")

    if echo "$GPU" | grep -qi "AMD"; then
        log "AMD GPU detected"
        sudo pacman -S --noconfirm \
            mesa vulkan-radeon libva-mesa-driver \
            vulkan-tools mesa-utils

    elif echo "$GPU" | grep -qi "NVIDIA"; then
        log "NVIDIA GPU detected"
        sudo pacman -S --noconfirm \
            nvidia nvidia-utils nvidia-settings

    elif echo "$GPU" | grep -qi "Intel"; then
        log "Intel GPU detected"
        sudo pacman -S --noconfirm \
            mesa vulkan-intel intel-media-driver

    else
        warn "Unknown GPU — skipping drivers"
    fi
}

### ========= CORE ========= ###
install_core() {
    log "Installing core system..."

    sudo pacman -Syu --noconfirm

    CORE_PKGS=(
        hyprland
        hyprlauncher
        waybar
        kitty
        greetd

        networkmanager
        bluez
        bluez-utils

        pipewire
        pipewire-alsa
        pipewire-pulse
        wireplumber

        polkit
        polkit-gnome

        xdg-desktop-portal-hyprland
        xdg-user-dirs

        wl-clipboard
        grim
        slurp

        seatd

        ttf-dejavu
        ttf-font-awesome
        noto-fonts

        git
        base-devel
    )

    for pkg in "${CORE_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log "Installing $pkg"
            sudo pacman -S --noconfirm "$pkg"
        fi
    done

    install_gpu_drivers
}

### ========= APPS ========= ###
install_apps() {
    log "Installing optional apps..."

    APP_PKGS=(
        thunderbird
        chromium
        vivaldi
        krusader
        nautilus
        mission-center
        htop
        dunst
        network-manager-applet
    )

    for pkg in "${APP_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log "Installing $pkg"
            sudo pacman -S --noconfirm "$pkg" || warn "Failed: $pkg"
        fi
    done
}

### ========= CONFIGS ========= ###
install_configs() {
    log "Installing configs..."

    mkdir -p "$HOME/.config"
    mkdir -p "$BACKUP_DIR"

    for dir in "$CONFIG_DIR"/*; do
        name=$(basename "$dir")
        target="$HOME/.config/$name"

        if [[ -d "$target" ]]; then
            warn "Backing up $name"
            mv "$target" "$BACKUP_DIR/"
        fi

        cp -r "$dir" "$target"
        log "Installed $name"
    done
}

### ========= SERVICES ========= ###
enable_services() {
    log "Enabling services..."

    SERVICES=(
        NetworkManager
        bluetooth
        seatd
    )

    for svc in "${SERVICES[@]}"; do
        sudo systemctl enable "$svc" --now || warn "Failed: $svc"
    done
}

### ========= GREETD ========= ###
setup_greetd() {
    log "Configuring greetd..."

    sudo mkdir -p /etc/greetd

    sudo bash -c "cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = \"Hyprland\"
user = \"$USER\"
EOF"
}

### ========= MAIN ========= ###
main() {
    require_user

    log "Starting Devitana Arch setup (official repos only)..."

    install_core
    install_apps
    install_configs
    enable_services
    setup_greetd

    log "Setup complete!"
    log "Reboot recommended."
}

main

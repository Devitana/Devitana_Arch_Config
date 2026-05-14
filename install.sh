#!/usr/bin/env bash

set -euo pipefail

### ========= CONFIG ========= ###
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%s)"
DRY_RUN=0

### ========= LOGGING ========= ###
log() { echo -e "\e[1;32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $1"; }
err()  { echo -e "\e[1;31m[ERROR]\e[0m $1"; exit 1; }

usage() {
    cat <<EOF
Usage: $0 [--dry-run|-n]

Options:
  -n, --dry-run   Show actions without making changes
  -h, --help      Show this help message
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                err "Unknown option: $1"
                ;;
        esac
        shift
    done
}

run_cmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log "[dry-run] $*"
    else
        "$@"
    fi
}

### ========= CHECKS ========= ###
require_user() {
    if [[ "$EUID" -eq 0 ]]; then
        err "Do NOT run as root"
    fi
}

### ========= GPU DETECTION ========= ###
install_gpu_drivers() {
    log "Detecting GPU..."

    GPU="$(lspci | grep -E "VGA|3D" || true)"

    if [[ -z "$GPU" ]]; then
        warn "No compatible GPU detected from lspci output; skipping drivers"
        return
    fi

    if echo "$GPU" | grep -qi "AMD"; then
        log "AMD GPU detected"
        run_cmd sudo pacman -S --noconfirm \
            mesa vulkan-radeon libva-mesa-driver \
            vulkan-tools mesa-utils

    elif echo "$GPU" | grep -qi "NVIDIA"; then
        log "NVIDIA GPU detected"
        run_cmd sudo pacman -S --noconfirm \
            nvidia nvidia-utils nvidia-settings

    elif echo "$GPU" | grep -qi "Intel"; then
        log "Intel GPU detected"
        run_cmd sudo pacman -S --noconfirm \
            mesa vulkan-intel intel-media-driver

    else
        warn "Unknown GPU - skipping drivers"
    fi
}

### ========= CORE ========= ###
install_core() {
    log "Installing core system..."

    run_cmd sudo pacman -Syu --noconfirm

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
        jq
        playerctl
        python
        python-requests

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
            run_cmd sudo pacman -S --noconfirm "$pkg"
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
            run_cmd sudo pacman -S --noconfirm "$pkg" || warn "Failed: $pkg"
        fi
    done
}

### ========= CONFIGS ========= ###
install_configs() {
    log "Installing configs..."

    run_cmd mkdir -p "$HOME/.config"
    run_cmd mkdir -p "$BACKUP_DIR"

    # Install these config directories into ~/.config.
    # Prefer repo/.config/<name>, fallback to repo-root/<name> for compatibility.
    CONFIG_DIRS=(
        hypr
        kitty
        waybar
    )

    for name in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$CONFIG_DIR/$name" ]]; then
            src="$CONFIG_DIR/$name"
        elif [[ -d "$REPO_DIR/$name" ]]; then
            src="$REPO_DIR/$name"
        else
            warn "Missing config dir: $name (checked $CONFIG_DIR and repo root)"
            continue
        fi

        target="$HOME/.config/$name"

        if [[ -e "$target" ]]; then
            warn "Backing up $target"
            run_cmd mv "$target" "$BACKUP_DIR/"
        fi

        run_cmd cp -r "$src" "$target"
        log "Installed $name -> $target"
    done

    # Install dotfiles from repo root into $HOME
    DOTFILES=(
        .bashrc
    )

    for file in "${DOTFILES[@]}"; do
        src="$REPO_DIR/$file"
        target="$HOME/$file"

        [[ -f "$src" ]] || { warn "Missing dotfile: $file (skipping)"; continue; }

        if [[ -e "$target" ]]; then
            warn "Backing up $target"
            run_cmd mv "$target" "$BACKUP_DIR/"
        fi

        run_cmd cp "$src" "$target"
        log "Installed $file -> $target"
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
        run_cmd sudo systemctl enable "$svc" --now || warn "Failed to enable or start service: $svc"
    done
}

### ========= GREETD ========= ###
setup_greetd() {
    log "Configuring greetd..."

    run_cmd sudo mkdir -p /etc/greetd

    local greetd_user="$USER"
    if [[ ! "$greetd_user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        err "Unsafe username for greetd config: $greetd_user"
    fi

    local hyprland_cmd
    hyprland_cmd="$(command -v Hyprland || true)"
    if [[ -z "$hyprland_cmd" ]]; then
        hyprland_cmd="/usr/bin/Hyprland"
    fi

    local tmp_cfg
    tmp_cfg="$(mktemp)"
    cat > "$tmp_cfg" <<EOF
[terminal]
vt = 1

[default_session]
command = "$hyprland_cmd"
user = "$greetd_user"
EOF

    if [[ "$DRY_RUN" -eq 1 ]]; then
        if [[ -f /etc/greetd/config.toml ]]; then
            run_cmd sudo cp /etc/greetd/config.toml "/etc/greetd/config.toml.bak.$(date +%s)"
            warn "Backed up existing /etc/greetd/config.toml"
        fi
    else
        if sudo test -f /etc/greetd/config.toml; then
            run_cmd sudo cp /etc/greetd/config.toml "/etc/greetd/config.toml.bak.$(date +%s)"
            warn "Backed up existing /etc/greetd/config.toml"
        fi
    fi

    run_cmd sudo install -m 0644 "$tmp_cfg" /etc/greetd/config.toml
    rm -f "$tmp_cfg"
}

### ========= MAIN ========= ###
main() {
    parse_args "$@"

    require_user

    log "Starting Devitana Arch setup (official repos only)..."
    [[ "$DRY_RUN" -eq 1 ]] && log "Dry-run mode enabled; no changes will be made"

    install_core
    install_apps
    install_configs
    enable_services
    setup_greetd

    log "Setup complete!"
    log "Reboot recommended."
}

main "$@"

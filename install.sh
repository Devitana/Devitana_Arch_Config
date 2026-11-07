#!/usr/bin/env bash
# Devitana Arch Config installer - official Arch repositories only.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DETECT="$REPO_DIR/hypr/scripts/detect_gpu.sh"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)-$$"
DRY_RUN=0
VERIFY=0
GAMING=1
STEAM=0
ENABLE_SERVICES=0
NVIDIA_OPEN_DKMS=0
YES=0

actions() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'HELP'
Usage: bash install.sh [options]
  -n, --dry-run          Preview (read-only: no sudo, writes or installs)
      --verify           Check installed packages, files and GPU detection
      --no-gaming        Skip gaming tools and 32-bit GPU libraries
      --steam            Install Steam (requires multilib)
      --nvidia-open-dkms Opt in to NVIDIA open DKMS driver (Turing+ only)
      --enable-services  Enable NetworkManager and Bluetooth services
  -y, --yes              Pass --noconfirm to pacman
  -h, --help             Print this help
HELP
}

while (($#)); do
    case "$1" in
        -n|--dry-run) DRY_RUN=1 ;;
        --verify) VERIFY=1 ;;
        --no-gaming) GAMING=0 ;;
        --steam) STEAM=1 ;;
        --nvidia-open-dkms) NVIDIA_OPEN_DKMS=1 ;;
        --enable-services) ENABLE_SERVICES=1 ;;
        -y|--yes) YES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
    shift
done
((EUID != 0)) || die 'Do not run the installer as root.'
((STEAM == 0 || GAMING == 1)) || die '--steam requires gaming mode.'

# Package names below are actual official Arch package names, not binaries.
PKGS_DESKTOP=(
    hyprland hyprpaper hypridle hyprlock hyprlauncher
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    xdg-utils qt5-wayland qt6-wayland qt6ct kvantum kvantum-qt5
    polkit-gnome waybar kitty firefox nautilus
    pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol
    playerctl libnotify blueman bluez bluez-utils
    networkmanager network-manager-applet nm-connection-editor
    grim slurp swappy wl-clipboard cliphist
    jq curl python python-requests git pciutils
    pacman-contrib iputils util-linux flatpak figlet mission-center
    fontconfig
)
PKGS_ICONS=(
    otf-font-awesome ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    adwaita-icon-theme adwaita-cursors hicolor-icon-theme papirus-icon-theme
)
PKGS_GAMING=(gamemode mangohud gamescope vulkan-tools)
PKGS_32_GAMING=(lib32-gamemode lib32-mangohud lib32-vulkan-icd-loader)
PKGS_AMD=(mesa vulkan-radeon)
PKGS_INTEL=(mesa vulkan-intel intel-media-driver)
PKGS_NVIDIA=(nvidia-utils nvidia-settings)
PKGS_AMD32=(lib32-mesa lib32-vulkan-radeon)
PKGS_INTEL32=(lib32-mesa lib32-vulkan-intel)
PKGS_NVIDIA32=(lib32-nvidia-utils)

has_package() { pacman -Qq "$1" >/dev/null 2>&1; }
multilib_enabled() {
    command -v pacman-conf >/dev/null 2>&1 &&
        pacman-conf --repo-list 2>/dev/null | grep -Fxq multilib
}

# One sorted, de-duplicated package plan; one pacman -Syu transaction.
declare -a PACKAGES=() VENDORS=()
declare -A INCLUDED=()
add_packages() {
    local pkg
    for pkg in "$@"; do
        if [[ ! -v "INCLUDED[$pkg]" ]]; then
            PACKAGES+=("$pkg")
            INCLUDED[$pkg]=1
        fi
    done
}

plan_packages() {
    [[ -f "$DETECT" ]] || die "Missing $DETECT (run from complete repository)."
    command -v pacman >/dev/null 2>&1 || {
        ((DRY_RUN)) && warn 'pacman not found: package plan only.' || die 'pacman required.'
    }
    mapfile -t VENDORS < <(bash "$DETECT" --vendors)
    actions "GPU detection: $(bash "$DETECT" --report | tr '\n' ';')"

    add_packages "${PKGS_DESKTOP[@]}" "${PKGS_ICONS[@]}"
    if ((GAMING)); then
        add_packages "${PKGS_GAMING[@]}" "${PKGS_32_GAMING[@]}"
    fi
    if ((STEAM)); then add_packages steam; fi

    local vendor
    for vendor in "${VENDORS[@]}"; do
        case "$vendor" in
            amd)
                add_packages "${PKGS_AMD[@]}"
                ((GAMING)) && add_packages "${PKGS_AMD32[@]}"
                ;;
            intel)
                add_packages "${PKGS_INTEL[@]}"
                ((GAMING)) && add_packages "${PKGS_INTEL32[@]}"
                ;;
            nvidia)
                if ((NVIDIA_OPEN_DKMS)) || has_package nvidia-utils; then
                    add_packages "${PKGS_NVIDIA[@]}"
                    ((GAMING)) && add_packages "${PKGS_NVIDIA32[@]}"
                else
                    warn 'NVIDIA detected, but driver not installed. Use --nvidia-open-dkms only for Turing+ or install the correct driver manually.'
                fi
                ;;
        esac
    done
    ((${#VENDORS[@]} > 0)) || warn 'No known GPU found: skipping vendor drivers.'

    if ((NVIDIA_OPEN_DKMS)); then
        local found_nvidia=0 found_kernel=0 kernel headers
        for vendor in "${VENDORS[@]}"; do
            [[ "$vendor" == nvidia ]] && found_nvidia=1
        done
        ((found_nvidia)) || die '--nvidia-open-dkms requires a detected NVIDIA GPU.'
        add_packages nvidia-open-dkms dkms
        for kernel in linux linux-zen linux-lts linux-hardened; do
            if has_package "$kernel"; then
                headers="${kernel}-headers"
                add_packages "$headers"
                found_kernel=1
            fi
        done
        ((found_kernel)) || die 'No supported installed kernel found for DKMS headers.'
        warn 'NVIDIA: verify Turing-or-newer GPU, Secure Boot, kernel headers and DRM KMS before reboot.'
    fi

    if ((GAMING || STEAM)) && ! multilib_enabled; then
        if ((DRY_RUN)); then
            warn '[dry-run] multilib is disabled or cannot be checked: real gaming install would stop.'
        else
            die 'Enable [multilib] in /etc/pacman.conf, run sudo pacman -Syu, then rerun (or use --no-gaming).'
        fi
    fi
}

# Preflight checks avoid an incomplete dotfiles checkout silently 'succeeding'.
check_sources() {
    local src
    for src in hypr waybar kitty; do
        [[ -d "$REPO_DIR/$src" ]] || die "Missing repository directory: $src/"
    done
    [[ -f "$REPO_DIR/hypr/hyprland.lua" ]] || die 'Missing hypr/hyprland.lua'
    [[ -f "$REPO_DIR/waybar/config.jsonc" ]] || die 'Missing waybar/config.jsonc'
    [[ -f "$REPO_DIR/waybar/style.css" ]] || die 'Missing waybar/style.css'
    local file
    for file in weather.sh kb.sh updates.sh installupdates.sh; do
        [[ -f "$REPO_DIR/waybar/scripts/$file" ]] || die "Missing waybar/scripts/$file"
    done
    [[ -f "$REPO_DIR/hypr/env_var/gpu/generic_gpu.lua" ]] || die 'Missing generic GPU profile'
}

install_packages() {
    actions "Planned official packages (${#PACKAGES[@]}):"
    printf '  %s\n' "${PACKAGES[@]}"
    ((DRY_RUN)) && return 0
    command -v sudo >/dev/null 2>&1 || die 'sudo required.'
    local flags=(--needed)
    ((YES)) && flags+=(--noconfirm)
    sudo pacman -Syu "${flags[@]}" "${PACKAGES[@]}"
}

install_configs() {
    local component src dst
    for component in hypr waybar kitty; do
        src="$REPO_DIR/$component"
        dst="$CONFIG_HOME/$component"
        [[ ! -L "$dst" ]] || die "Refusing to overwrite symlinked config dir: $dst"
        if ((DRY_RUN)); then
            actions "[dry-run] backup (if exists) $dst -> $BACKUP_DIR/$component"
            actions "[dry-run] copy $src -> $dst"
            continue
        fi
        if [[ -e "$dst" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp -a "$dst" "$BACKUP_DIR/$component"
        fi
        mkdir -p "$dst"
        cp -a "$src/." "$dst/"
    done

    local profile
    profile="$(bash "$DETECT" --profile)"
    if ((DRY_RUN)); then
        actions "[dry-run] copy $profile -> $CONFIG_HOME/hypr/env_var/current_gpu.lua"
        return 0
    fi
    find "$CONFIG_HOME/waybar/scripts" "$CONFIG_HOME/hypr/scripts" \
        -maxdepth 1 -type f -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
    cp -a "$profile" "$CONFIG_HOME/hypr/env_var/current_gpu.lua"
    [[ -d "$BACKUP_DIR" ]] && actions "Backups saved in $BACKUP_DIR"
    actions "Installed GPU profile: $(basename "$profile")"
}

configure_services() {
    ((ENABLE_SERVICES)) || { actions 'Services unchanged (use --enable-services to opt in).'; return; }
    if ((DRY_RUN)); then
        actions '[dry-run] enable NetworkManager.service and bluetooth.service'
    else
        sudo systemctl enable --now NetworkManager.service bluetooth.service
    fi
    # seatd is intentionally not enabled: Hyprland can use systemd-logind.
}

verify_setup() {
    local errors=0 pkg path
    actions 'Checking installed packages and config files...'
    for pkg in "${PACKAGES[@]}"; do
        if ! has_package "$pkg"; then
            warn "Missing package: $pkg"
            ((errors+=1))
        fi
    done
    for path in \
        "$CONFIG_HOME/hypr/hyprland.lua" \
        "$CONFIG_HOME/hypr/env_var/current_gpu.lua" \
        "$CONFIG_HOME/hypr/scripts/detect_gpu.sh" \
        "$CONFIG_HOME/waybar/config.jsonc" \
        "$CONFIG_HOME/waybar/style.css" \
        "$CONFIG_HOME/waybar/scripts/weather.sh" \
        "$CONFIG_HOME/waybar/scripts/kb.sh" \
        "$CONFIG_HOME/waybar/scripts/updates.sh" \
        "$CONFIG_HOME/waybar/scripts/installupdates.sh"; do
        if [[ ! -f "$path" ]]; then warn "Missing file: $path"; ((errors+=1)); fi
    done
    if command -v vulkaninfo >/dev/null 2>&1; then
        actions 'Vulkan inspection available: vulkaninfo --summary'
    fi
    actions "Primary GPU: $(bash "$DETECT" --primary)"
    local vendor
    for vendor in "${VENDORS[@]}"; do
        if [[ "$vendor" == nvidia ]] && ! has_package nvidia-utils; then
            warn 'NVIDIA detected without nvidia-utils: select the correct NVIDIA driver for your hardware.'
            ((errors+=1))
        fi
    done
    if ((errors)); then
        warn "Verification found $errors missing item(s)."
        return 1
    fi
    actions 'Installed package/config checks passed (not a live graphics test).'
}

check_sources
plan_packages
if ((VERIFY)); then
    verify_setup
    exit $?
fi
install_packages
install_configs
configure_services
if ((DRY_RUN)); then
    actions 'Dry-run finished: no changes made.'
else
    verify_setup
    actions 'Install completed. Log out and start a fresh Hyprland session.'
fi

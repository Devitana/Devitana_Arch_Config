#!/usr/bin/env bash
# Devitana Arch Linux / Hyprland config installer.
# Official Arch packages only; never modifies bootloader or kernel drivers.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)-$$"
DETECTOR="$REPO_DIR/hypr/scripts/detect_gpu.sh"
PROFILE_DIR="$REPO_DIR/hypr/env_var/gpu"
DRY_RUN=0
VERIFY_ONLY=0
GAMING=0
ENABLE_SERVICES=0
GPU_OVERRIDE=auto
SELECTED_GPU=generic
GPU_VENDORS=()
PACKAGES=()

log()  { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die()  { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'HELP'
Usage: bash install.sh [options]
  --dry-run, -n  Preview without installing or changing files
  --verify       Check packages, commands, files, and GPU selection
  --gaming       Add Steam, GameMode, MangoHud, Gamescope, 32-bit drivers
                 (requires [multilib] enabled in /etc/pacman.conf)
  --gpu VENDOR   Select Hyprland profile: auto|amd|nvidia|intel|generic
  --services     Enable NetworkManager and Bluetooth system services
  --help, -h     Show this help

NVIDIA: driver installation is deliberately MANUAL because supported
packages depend on GPU generation and the booted kernel. See README.md.
HELP
}

while (($#)); do
    case "$1" in
        -n|--dry-run) DRY_RUN=1 ;;
        --verify) VERIFY_ONLY=1 ;;
        --gaming) GAMING=1 ;;
        --services) ENABLE_SERVICES=1 ;;
        --gpu) (($# >= 2)) || die 'Missing --gpu argument'; GPU_OVERRIDE="$2"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
    shift
done
case "$GPU_OVERRIDE" in auto|amd|nvidia|intel|generic) ;; *) die "Invalid GPU: $GPU_OVERRIDE" ;; esac
if (( ! DRY_RUN && ! VERIFY_ONLY )) && [[ "$EUID" -eq 0 ]]; then
    die 'Run installs as a regular user with sudo access, not root.'
fi

# Package names confirmed against official Arch repositories (Nov 2026).
PKGS_DESKTOP=(
    hyprland hyprpaper hypridle hyprlock hyprcursor
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils xorg-xwayland
    qt5-wayland qt6-wayland polkit-kde-agent
    waybar kitty firefox nautilus hyprlauncher
    pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol playerctl
    libnotify mako
    bluez bluez-utils blueman networkmanager nm-connection-editor network-manager-applet
    grim slurp wl-clipboard cliphist swappy
    jq curl python python-requests pciutils util-linux pacman-contrib
    git flatpak figlet mission-center
)
PKGS_ICONS=(
    otf-font-awesome ttf-nerd-fonts-symbols ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    adwaita-icon-theme hicolor-icon-theme papirus-icon-theme
)
PKGS_GPU_COMMON=(vulkan-icd-loader vulkan-tools)
PKGS_AMD=(mesa vulkan-radeon libva-mesa-driver)
PKGS_INTEL=(mesa vulkan-intel intel-media-driver)
PKGS_GAME=(steam gamemode mangohud gamescope)
PKGS_GAME_32=(lib32-vulkan-icd-loader lib32-mangohud lib32-gamemode)
PKGS_AMD_32=(lib32-mesa lib32-vulkan-radeon)
PKGS_INTEL_32=(lib32-mesa lib32-vulkan-intel)

repo_check() {
    [[ -f "$DETECTOR" ]] || die "Missing $DETECTOR"
    for name in amd nvidia intel generic_gpu; do
        [[ -f "$PROFILE_DIR/$name.lua" ]] || die "Missing $PROFILE_DIR/$name.lua"
    done
<<<<<<< HEAD
    for component in hypr waybar kitty; do
        [[ -d "$REPO_DIR/$component" ]] || die "Missing $REPO_DIR/$component (run from the COMPLETE dotfiles repository)"
        if [[ -L "$CONFIG_HOME/$component" ]]; then
            die "$CONFIG_HOME/$component is a symlink. Refusing to overwrite its target; manage the symlink manually."
=======
}

run_cmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log "[dry-run] $*"
    else
        "$@"
    fi
}

### ========= PACKAGE INSTALLATION ========= ###

# ---- Package arrays grouped by category ----

# Core Hyprland ecosystem (official repos)
PKGS_HYPR=(
    hyprpaper
    hypridle
    hyprlock
    hyprcursor
    xdg-desktop-portal-hyprland
    xdg-utils
    qt5-wayland
    qt6-wayland
    polkit-kde-agent
    seatd
)

# Waybar and its runtime dependencies
PKGS_WAYBAR=(
    libpulse
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    pavucontrol
    playerctl
    jq
    curl
    python
    python-requests
    libnotify
)

# Utilities referenced by configs / keybindings
PKGS_UTILS=(
    kitty
    firefox
    nautilus
    blueman
    networkmanager
    nm-connection-editor
    network-manager-applet
    hyprlauncher
    flatpak
    pacman-contrib
    figlet
    mission-center
)

# Screenshot / clipboard / media tools
PKGS_TOOLS=(
    grim
    slurp
    wl-clipboard
    cliphist
    swappy
)

# Fonts (icon/nerd fonts used by Waybar and terminal)
PKGS_FONTS=(
    ttf-font-awesome
    ttf-nerd-fonts-symbols
    ttf-nerd-fonts-symbols-common
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
)

# ---- Helpers ----

pacman_install() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log "[dry-run] would install: $*"
        return
    fi
    # Install only packages not already installed
    local to_install=()
    for pkg in "$@"; do
        if ! pacman -Qq "$pkg" &>/dev/null; then
            to_install+=("$pkg")
>>>>>>> ee65c80c109d9545f2e23c7c0276ad6fb64caf3a
        fi
    done
    [[ -f "$REPO_DIR/hypr/hyprland.lua" ]] || die 'Missing hypr/hyprland.lua in source repository'
    [[ -f "$REPO_DIR/waybar/config.jsonc" ]] || die 'Missing waybar/config.jsonc in source repository'
}

identify_gpu() {
    local args=(--vendor --profile-dir "$PROFILE_DIR" --gpu "$GPU_OVERRIDE")
    SELECTED_GPU="$(bash "$DETECTOR" "${args[@]}")" || die 'GPU detector failed'
    log "Hyprland profile GPU: $SELECTED_GPU"

    # Inspect ALL display-class PCI devices, including inactive secondary GPUs.
    # Unlike `lspci`, /sys is available before pciutils is installed.
    local pci_device pci_vendor pci_class pci
    local found_amd=0 found_intel=0 found_nvidia=0
    for pci_device in "${GPU_SYSFS_ROOT:-/sys}"/bus/pci/devices/*; do
        [[ -r "$pci_device/vendor" && -r "$pci_device/class" ]] || continue
        pci_class="$(<"$pci_device/class")"
        [[ "$pci_class" == 0x03* ]] || continue
        pci_vendor="$(<"$pci_device/vendor")"
        case "$pci_vendor" in
            0x1002) found_amd=1 ;;
            0x8086) found_intel=1 ;;
            0x10de) found_nvidia=1 ;;
        esac
    done
    if ((found_amd)); then GPU_VENDORS+=(amd); fi
    if ((found_intel)); then GPU_VENDORS+=(intel); fi
    if ((found_nvidia)); then GPU_VENDORS+=(nvidia); fi
    # Fallback for systems without readable sysfs.
    if ((${#GPU_VENDORS[@]} == 0)) && command -v lspci >/dev/null 2>&1; then
        pci="$(lspci -Dnn 2>/dev/null | grep -Ei '\[03(00|02|80)\]|VGA compatible controller|3D controller|Display controller' || true)"
        if grep -Eq '\[1002:' <<< "$pci"; then GPU_VENDORS+=(amd); fi
        if grep -Eq '\[8086:' <<< "$pci"; then GPU_VENDORS+=(intel); fi
        if grep -Eq '\[10de:' <<< "$pci"; then GPU_VENDORS+=(nvidia); fi
    fi
    if ((${#GPU_VENDORS[@]} == 0)) && [[ "$SELECTED_GPU" != generic ]]; then
        GPU_VENDORS+=("$SELECTED_GPU")
    fi
    log "Detected PCI GPU vendors: ${GPU_VENDORS[*]:-unknown}"
}

has_vendor() {
    local target="$1" item
    for item in "${GPU_VENDORS[@]}"; do [[ "$item" != "$target" ]] || return 0; done
    return 1
}

multilib_enabled() {
    command -v pacman-conf >/dev/null 2>&1 &&
        pacman-conf --repo-list 2>/dev/null | grep -qx multilib
}

build_package_list() {
    local -a all=("${PKGS_DESKTOP[@]}" "${PKGS_ICONS[@]}" "${PKGS_GPU_COMMON[@]}")
    has_vendor amd && all+=("${PKGS_AMD[@]}")
    has_vendor intel && all+=("${PKGS_INTEL[@]}")
    if has_vendor nvidia; then
        warn 'NVIDIA GPU detected: its driver is NOT automatically installed. See README (generation/kernel-specific).'
    fi
    if ((GAMING)); then
        all+=("${PKGS_GAME[@]}" "${PKGS_GAME_32[@]}")
        has_vendor amd && all+=("${PKGS_AMD_32[@]}")
        has_vendor intel && all+=("${PKGS_INTEL_32[@]}")
        if has_vendor nvidia && ! has_vendor amd && ! has_vendor intel; then
            warn 'NVIDIA-only: Steam needs matching lib32-nvidia-utils / legacy packages; configure the NVIDIA driver first.'
            die 'Refusing unattended Steam driver-provider choice for NVIDIA-only systems.'
        fi
    fi
    # Stable deduplication, including Mesa on AMD+Intel mixed systems.
    local -A seen=()
    local pkg
    PACKAGES=()
    for pkg in "${all[@]}"; do
        if [[ -z "${seen[$pkg]+found}" ]]; then PACKAGES+=("$pkg"); seen[$pkg]=1; fi
    done
}

check_prerequisites() {
    ((DRY_RUN)) && return 0
    command -v pacman >/dev/null 2>&1 || die 'pacman not found; use Arch Linux.'
    command -v sudo >/dev/null 2>&1 || die 'sudo not found.'
    if ((GAMING)) && ! multilib_enabled; then
        die '[multilib] is not enabled. Enable it in /etc/pacman.conf, run sudo pacman -Syu, then retry --gaming.'
    fi
}

install_packages() {
    log "Official pacman packages (${#PACKAGES[@]}): ${PACKAGES[*]}"
    if ((DRY_RUN)); then
        log '[dry-run] Would run: sudo pacman -Syu --needed <packages above>'
    else
        # -Syu avoids partial upgrades; one transaction, no automatic --noconfirm.
        sudo pacman -Syu --needed "${PACKAGES[@]}"
        command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null
    fi
}

install_configs() {
    local component src dst backup_created=0
    for component in hypr waybar kitty; do
        src="$REPO_DIR/$component"
        dst="$CONFIG_HOME/$component"
        if ((DRY_RUN)); then
            if [[ -e "$dst" || -L "$dst" ]]; then
                log "[dry-run] Would back up $dst to $BACKUP_DIR/$component"
            fi
            log "[dry-run] Would overlay $src -> $dst"
            continue
        fi
        if [[ -e "$dst" || -L "$dst" ]]; then
            if ((backup_created == 0)); then mkdir -p "$BACKUP_DIR"; backup_created=1; fi
            cp -a -- "$dst" "$BACKUP_DIR/$component"
        fi
        mkdir -p -- "$dst"
        cp -a -- "$src/." "$dst/"
    done
    if ((backup_created)); then log "Backup saved at $BACKUP_DIR"; fi
    if ((DRY_RUN)); then
        log '[dry-run] Would make ~/.config/{hypr,waybar}/scripts/*.sh executable'
        return
    fi
    local script
    for component in hypr waybar; do
        for script in "$CONFIG_HOME/$component"/scripts/*.sh; do
            [[ -f "$script" ]] && chmod +x -- "$script"
        done
    done
}

install_gpu_profile() {
    local source
    source="$(bash "$DETECTOR" --profile-dir "$PROFILE_DIR" --gpu "$SELECTED_GPU")" || die 'GPU profile path not found'
    if ((DRY_RUN)); then
        log "[dry-run] Would copy $source to $CONFIG_HOME/hypr/env_var/current_gpu.lua"
        return
    fi
    mkdir -p "$CONFIG_HOME/hypr/env_var"
    cp -- "$source" "$CONFIG_HOME/hypr/env_var/current_gpu.lua"
    log "Installed $SELECTED_GPU GPU profile (no global Vulkan ICD override)"
}

enable_services() {
    ((ENABLE_SERVICES)) || { log 'Services left unchanged (use --services to enable NetworkManager and Bluetooth).'; return; }
    if ((DRY_RUN)); then
        log '[dry-run] Would enable NetworkManager.service and bluetooth.service'; return
    fi
    sudo systemctl enable --now NetworkManager.service bluetooth.service
}

verify_setup() {
    local errors=0 cmd path pkg
    log 'Running healthcheck...'
    for cmd in Hyprland waybar kitty hyprpaper hypridle hyprlock jq python checkupdates; do
        if ! command -v "$cmd" >/dev/null 2>&1; then warn "Missing command: $cmd"; ((errors+=1)); fi
    done
    for path in \
        "$CONFIG_HOME/hypr/hyprland.lua" \
        "$CONFIG_HOME/hypr/env_var/current_gpu.lua" \
        "$CONFIG_HOME/hypr/scripts/detect_gpu.sh" \
        "$CONFIG_HOME/waybar/config.jsonc" \
        "$CONFIG_HOME/waybar/scripts/kb.sh" \
        "$CONFIG_HOME/waybar/scripts/updates.sh" \
        "$CONFIG_HOME/waybar/scripts/installupdates.sh"; do
        if [[ ! -f "$path" ]]; then warn "Missing installed file: $path"; ((errors+=1)); fi
    done
    for pkg in "${PACKAGES[@]}"; do
        if ! command -v pacman >/dev/null 2>&1 || ! pacman -Qq "$pkg" >/dev/null 2>&1; then
            warn "Missing official package: $pkg"; ((errors+=1))
        fi
    done
    if command -v fc-list >/dev/null 2>&1; then
        for family in 'Font Awesome' 'Symbols Nerd Font'; do
            if ! fc-list : family | grep -Fqi "$family"; then
                warn "Fontconfig does not list $family"; ((errors+=1))
            fi
        done
    else
        warn 'fc-list not found (fontconfig verification skipped)'
    fi
    if command -v vulkaninfo >/dev/null 2>&1; then
        log 'vulkaninfo installed; run vulkaninfo --summary after starting Hyprland.'
    else
        warn 'vulkaninfo unavailable (vulkan-tools not installed).'; ((errors+=1))
    fi
    if ((GAMING)); then
        for pkg in steam gamemode mangohud gamescope; do
            if ! pacman -Qq "$pkg" >/dev/null 2>&1; then warn "Missing gaming package: $pkg"; ((errors+=1)); fi
        done
    fi
    if ((errors)); then warn "Healthcheck found $errors issue(s)"; return 1; fi
    log 'Healthcheck passed (this does not prove runtime game performance).'
}

main() {
    if ((VERIFY_ONLY)); then
        identify_gpu
        build_package_list
        verify_setup
        return
    fi
    repo_check
    check_prerequisites
    identify_gpu
    build_package_list
    if ((GAMING && DRY_RUN)) && ! multilib_enabled; then
        warn '[dry-run] [multilib] needs to be enabled for --gaming.'
    fi
    install_packages
    install_configs
    install_gpu_profile
    enable_services
    if ((DRY_RUN)); then log '[dry-run] No system changes made.'; return; fi
    verify_setup
}
main

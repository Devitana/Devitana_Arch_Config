#!/usr/bin/env bash

set -euo pipefail

### ========= CONFIG ========= ###
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%s)"
DRY_RUN=0
GPU_PROFILE="generic_gpu.conf"
VERIFY_ONLY=0

### ========= LOGGING ========= ###
log() { echo -e "\e[1;32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $1"; }
err()  { echo -e "\e[1;31m[ERROR]\e[0m $1"; exit 1; }

usage() {
    cat <<EOF
Usage: $0 [--dry-run|-n]

Options:
  -n, --dry-run   Show actions without making changes
      --verify    Run post-install healthcheck only
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
            --verify)
                VERIFY_ONLY=1
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

verify_setup() {
    log "Running healthcheck..."

    local missing=0
    local cmds=(
        Hyprland
        waybar
        kitty
        hyprpaper
        hypridle
        hyprlock
        jq
        python
        checkupdates
    )

    for cmd in "${cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            warn "Missing command: $cmd"
            ((missing+=1))
        fi
    done

    local required_files=(
        "$HOME/.config/hypr/hyprland.conf"
        "$HOME/.config/hypr/env_var/current_gpu.lua"
        "$HOME/.config/waybar/config.jsonc"
        "$HOME/.config/waybar/scripts/kb.sh"
        "$HOME/.config/waybar/scripts/updates.sh"
        "$HOME/.config/waybar/scripts/installupdates.sh"
    )

    for path in "${required_files[@]}"; do
        if [[ ! -e "$path" ]]; then
            warn "Missing file: $path"
            ((missing+=1))
        fi
    done

    if [[ -f "$HOME/.config/hypr/env_var/current_gpu.lua" ]] && ! grep -q '^source = ~/.config/hypr/env_var/gpu/' "$HOME/.config/hypr/env_var/current_gpu.lua"; then
        warn "current_gpu.lua does not source a valid GPU profile"
        ((missing+=1))
    fi

    if [[ "$missing" -eq 0 ]]; then
        log "Healthcheck passed"
        return
    fi

    err "Healthcheck found $missing issue(s)"
}

ensure_gpu_config() {
    local detect_script="$HOME/.config/hypr/scripts/detect_gpu.sh"
    local target_file="$HOME/.config/hypr/env_var/current_gpu.lua"
    local fallback="source = ~/.config/hypr/env_var/gpu/generic_gpu.conf"

    if [[ -f "$detect_script" ]]; then
        run_cmd chmod +x "$detect_script"
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log "[dry-run] would run GPU detection and write $target_file"
        else
            if "$detect_script" > "$target_file" 2>/tmp/hypr-gpu-detect.log; then
                log "GPU config detected and written to $target_file"
            else
                warn "GPU detection returned non-zero, using fallback generic profile"
                echo "$fallback" > "$target_file"
            fi
        fi
    else
        warn "GPU detection script missing at $detect_script; writing fallback generic profile"
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log "[dry-run] would write fallback GPU profile to $target_file"
        else
            echo "$fallback" > "$target_file"
        fi
    fi
}

main() {
    parse_args "$@"
    require_user

    if [[ "$VERIFY_ONLY" -eq 1 ]]; then
        verify_setup
        exit 0
    fi

    ensure_gpu_config
    verify_setup
    log "Install checks complete"
}

main "$@"

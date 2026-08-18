#!/usr/bin/env bash

set -euo pipefail

### ========= CONFIG ========= ###
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="$HOME/.config"
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
    local strict="${1:-1}"
    log "Running healthcheck..."

    local missing=0
    local missing_cmds=0
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
            ((missing_cmds+=1))
        fi
    done

    local required_files=(
        "$CONFIG_HOME/hypr/env_var/current_gpu.lua"
        "$CONFIG_HOME/waybar/config.jsonc"
        "$CONFIG_HOME/waybar/scripts/kb.sh"
        "$CONFIG_HOME/waybar/scripts/updates.sh"
        "$CONFIG_HOME/waybar/scripts/installupdates.sh"
    )

    for path in "${required_files[@]}"; do
        if [[ ! -e "$path" ]]; then
            warn "Missing file: $path"
            ((missing+=1))
        fi
    done

    if [[ ! -e "$CONFIG_HOME/hypr/hyprland.conf" && ! -e "$CONFIG_HOME/hypr/hyprland.lua" ]]; then
        warn "Missing file: $CONFIG_HOME/hypr/hyprland.conf (or hyprland.lua)"
        ((missing+=1))
    fi

    if [[ -f "$CONFIG_HOME/hypr/env_var/current_gpu.lua" ]] && ! grep -q 'hl\.env' "$CONFIG_HOME/hypr/env_var/current_gpu.lua"; then
        warn "current_gpu.lua does not contain any hl.env settings"
        ((missing+=1))
    fi

    local total_missing="$missing"
    if [[ "$strict" -eq 1 ]]; then
        total_missing=$((missing + missing_cmds))
    fi

    if [[ "$total_missing" -eq 0 ]]; then
        log "Healthcheck passed"
        return
    fi

    if [[ "$strict" -eq 1 ]]; then
        err "Healthcheck found $total_missing issue(s)"
    else
        warn "Healthcheck found $missing file issue(s) and $missing_cmds command warning(s) (non-fatal)"
    fi
}

install_configs() {
    local components=(hypr waybar kitty)

    run_cmd mkdir -p "$CONFIG_HOME"

    for component in "${components[@]}"; do
        local src="$REPO_DIR/$component"
        local dst="$CONFIG_HOME/$component"

        if [[ ! -d "$src" ]]; then
            warn "Missing component directory in repo: $src"
            continue
        fi

        run_cmd mkdir -p "$dst"
        run_cmd cp -a "$src/." "$dst/"
    done

    local waybar_scripts="$CONFIG_HOME/waybar/scripts"
    local hypr_scripts="$CONFIG_HOME/hypr/scripts"
    if [[ -d "$waybar_scripts" ]]; then
        local waybar_script_files=()
        shopt -s nullglob
        waybar_script_files=("$waybar_scripts"/*.sh)
        shopt -u nullglob
        if [[ "${#waybar_script_files[@]}" -gt 0 ]]; then
            run_cmd chmod +x "${waybar_script_files[@]}"
        fi
    fi
    if [[ -d "$hypr_scripts" ]]; then
        local hypr_script_files=()
        shopt -s nullglob
        hypr_script_files=("$hypr_scripts"/*.sh)
        shopt -u nullglob
        if [[ "${#hypr_script_files[@]}" -gt 0 ]]; then
            run_cmd chmod +x "${hypr_script_files[@]}"
        fi
    fi
}

ensure_gpu_config() {
    local detect_script="$CONFIG_HOME/hypr/scripts/detect_gpu.sh"
    local target_file="$CONFIG_HOME/hypr/env_var/current_gpu.lua"
    local fallback_src="$REPO_DIR/hypr/env_var/gpu/generic_gpu.lua"

    if [[ ! -f "$detect_script" ]]; then
        detect_script="$REPO_DIR/hypr/scripts/detect_gpu.sh"
    fi

    if [[ ! -f "$fallback_src" ]]; then
        err "Fallback GPU profile not found at $fallback_src"
    fi

    if [[ -f "$detect_script" ]]; then
        run_cmd chmod +x "$detect_script"
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log "[dry-run] would run GPU detection and copy matching .lua profile to $target_file"
        else
            local gpu_lua
            if gpu_lua="$("$detect_script" 2>/tmp/hypr-gpu-detect.log)" && [[ -f "$gpu_lua" ]]; then
                cp "$gpu_lua" "$target_file"
                log "GPU config detected and copied to $target_file"
            else
                warn "GPU detection returned no valid file, using fallback generic profile"
                cp "$fallback_src" "$target_file"
            fi
        fi
    else
        warn "GPU detection script missing at $detect_script; writing fallback generic profile"
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log "[dry-run] would copy fallback GPU profile to $target_file"
        else
            cp "$fallback_src" "$target_file"
        fi
    fi
}

main() {
    parse_args "$@"
    require_user

    if [[ "$VERIFY_ONLY" -eq 1 ]]; then
        verify_setup 1
        exit 0
    fi

    install_configs
    ensure_gpu_config

    if [[ "$DRY_RUN" -eq 1 ]]; then
        verify_setup 0
        log "Dry-run complete"
        exit 0
    fi

    verify_setup 0
    log "Install checks complete"
}

main "$@"

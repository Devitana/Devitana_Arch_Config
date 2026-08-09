#!/usr/bin/env bash
# GPU Detection Script for Hyprland
# Automatically sources the appropriate GPU configuration

set -euo pipefail

# Color codes for output
# shellcheck disable=SC2034
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GPU_CONFIG_DIR="$HOME/.config/hypr/env_var/gpu"
CONFIG_FILE=""

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

detect_from_lspci() {
    local gpus
    gpus="$(lspci -nnk | grep -Ei 'vga compatible controller|3d controller|display controller' || true)"

    # Prefer discrete NVIDIA first when present
    if grep -Eiq 'nvidia' <<< "$gpus"; then
        CONFIG_FILE="$GPU_CONFIG_DIR/nvidia.lua"
        echo -e "${GREEN}[GPU] NVIDIA GPU detected${NC}" >&2
        return 0
    fi

    # Then AMD
    if grep -Eiq 'amd|advanced micro devices|radeon' <<< "$gpus"; then
        CONFIG_FILE="$GPU_CONFIG_DIR/amd.lua"
        echo -e "${GREEN}[GPU] AMD GPU detected${NC}" >&2
        return 0
    fi

    # Then Intel
    if grep -Eiq 'intel' <<< "$gpus"; then
        CONFIG_FILE="$GPU_CONFIG_DIR/intel.lua"
        echo -e "${GREEN}[GPU] Intel GPU detected${NC}" >&2
        return 0
    fi

    return 1
}

detect_from_modules() {
    # Fallback: check loaded kernel modules
    if grep -Eq '^nvidia ' /proc/modules 2>/dev/null; then
        CONFIG_FILE="$GPU_CONFIG_DIR/nvidia.lua"
        echo -e "${GREEN}[GPU] NVIDIA GPU detected (module-based)${NC}" >&2
        return 0
    fi

    if grep -Eq '^amdgpu |^radeon ' /proc/modules 2>/dev/null; then
        CONFIG_FILE="$GPU_CONFIG_DIR/amd.lua"
        echo -e "${GREEN}[GPU] AMD GPU detected (module-based)${NC}" >&2
        return 0
    fi

    if grep -Eq '^i915 |^xe ' /proc/modules 2>/dev/null; then
        CONFIG_FILE="$GPU_CONFIG_DIR/intel.lua"
        echo -e "${GREEN}[GPU] Intel GPU detected (module-based)${NC}" >&2
        return 0
    fi

    return 1
}

detect_gpu() {
    if has_cmd lspci && detect_from_lspci; then
        return 0
    fi

    if ! has_cmd lspci; then
        echo -e "${YELLOW}[GPU] lspci not found, checking /proc/modules${NC}" >&2
    else
        echo -e "${YELLOW}[GPU] Could not map lspci GPU entries, checking /proc/modules${NC}" >&2
    fi

    if detect_from_modules; then
        return 0
    fi

    CONFIG_FILE="$GPU_CONFIG_DIR/generic_gpu.lua"
    echo -e "${YELLOW}[GPU] Using generic/fallback configuration${NC}" >&2
    return 1
}

# Run detection
detect_gpu || true

# Output the path to the detected GPU Lua config file
if [[ -f "$CONFIG_FILE" ]]; then
    echo "$CONFIG_FILE"
else
    echo "# Warning: GPU config file not found at $CONFIG_FILE" >&2
    echo "$GPU_CONFIG_DIR/generic_gpu.lua"
fi

#!/bin/bash
# GPU Detection Script for Hyprland
# Detects whether the system has an AMD, NVIDIA, or Intel GPU
# and writes the appropriate source directive to current_gpu.conf

OUTPUT="$HOME/.config/hypr/env_var/current_gpu.conf"
GPU_CONFIG_DIR="$HOME/.config/hypr/env_var/gpu"

detect_gpu() {
    if command -v lspci &> /dev/null; then
        GPU_INFO=$(lspci | grep -Ei 'vga|3d')

        if echo "$GPU_INFO" | grep -qi "nvidia"; then
            echo "$GPU_CONFIG_DIR/nvidia.conf"
            return 0
        fi

        if echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
            echo "$GPU_CONFIG_DIR/amd.conf"
            return 0
        fi

        if echo "$GPU_INFO" | grep -qi "intel"; then
            echo "$GPU_CONFIG_DIR/intel.conf"
            return 0
        fi
    fi

    # Fallback: check loaded kernel modules
    if grep -qE "^nvidia[[:space:]]" /proc/modules 2>/dev/null; then
        echo "$GPU_CONFIG_DIR/nvidia.conf"
        return 0
    fi

    if grep -qE "^amdgpu[[:space:]]" /proc/modules 2>/dev/null; then
        echo "$GPU_CONFIG_DIR/amd.conf"
        return 0
    fi

    if grep -qE "^(i915|xe)[[:space:]]" /proc/modules 2>/dev/null; then
        echo "$GPU_CONFIG_DIR/intel.conf"
        return 0
    fi

    # Generic fallback
    echo "$GPU_CONFIG_DIR/generic.conf"
}

CONFIG_FILE=$(detect_gpu)

if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$OUTPUT"
else
    cp "$GPU_CONFIG_DIR/generic.conf" "$OUTPUT"
fi

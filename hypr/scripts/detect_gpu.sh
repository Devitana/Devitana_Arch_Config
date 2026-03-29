#!/bin/bash
# Detects the primary GPU and copies the matching env config to current_gpu.conf.
# Called via exec-once so it runs once per Hyprland session.
# After writing the config, it reloads Hyprland so the new env vars
# take effect for all subsequently launched applications.

GPU_DIR="$HOME/.config/hypr/env_var/gpu"
OUTPUT="$HOME/.config/hypr/env_var/current_gpu.conf"
GPU_INFO=$(lspci 2>/dev/null | grep -Ei 'vga|3d|display')

if echo "$GPU_INFO" | grep -qi "nvidia"; then
    cp "$GPU_DIR/nvidia.conf" "$OUTPUT"

elif echo "$GPU_INFO" | grep -qi "amd\|radeon\|advanced micro devices"; then
    cp "$GPU_DIR/amd.conf" "$OUTPUT"

elif echo "$GPU_INFO" | grep -qi "intel"; then
    cp "$GPU_DIR/intel.conf" "$OUTPUT"

else
    cp "$GPU_DIR/default.conf" "$OUTPUT"
fi

# Reload Hyprland config so the GPU env vars apply to new processes
# without requiring a full restart.
# A brief delay ensures Hyprland's IPC socket is ready before we call hyprctl.
sleep 1
hyprctl reload

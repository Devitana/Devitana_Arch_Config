#!/bin/bash

OUTPUT="$HOME/.config/hypr/env_var/current_gpu.conf"
GPU_INFO=$(lspci | grep -Ei 'vga|3d')

if echo "$GPU_INFO" | grep -qi "nvidia"; then
    cp "$HOME/.config/hypr/env_var/gpu/nvidia.conf" "$OUTPUT"

elif echo "$GPU_INFO" | grep -qi "amd"; then
    cp "$HOME/.config/hypr/env_var/gpu/amd.conf" "$OUTPUT"

elif echo "$GPU_INFO" | grep -qi "intel"; then
    cp "$HOME/.config/hypr/env_var/gpu/intel.conf" "$OUTPUT"

else
    cp "$HOME/.config/hypr/env_var/gpu/default.conf" "$OUTPUT"
fi
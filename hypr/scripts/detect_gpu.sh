#!/bin/bash
# GPU Detection Script for Hyprland
# Automatically sources the appropriate GPU configuration

# Color codes for output
# shellcheck disable=SC2034
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

GPU_CONFIG_DIR="$HOME/.config/hypr/env_var/gpu"
CONFIG_FILE=""

detect_gpu() {
    if command -v lspci &> /dev/null; then
        # Check for NVIDIA GPU
        if lspci | grep -i nvidia > /dev/null 2>&1; then
            CONFIG_FILE="$GPU_CONFIG_DIR/nvidia.conf"
            echo -e "${GREEN}[GPU] NVIDIA GPU detected${NC}" >&2
            return 0
        fi
        
        # Check for AMD GPU
        if lspci | grep -i "amd\|radeon" > /dev/null 2>&1; then
            CONFIG_FILE="$GPU_CONFIG_DIR/amd.conf"
            echo -e "${GREEN}[GPU] AMD GPU detected${NC}" >&2
            return 0
        fi
        
        # Check for Intel GPU
        if lspci | grep -i "intel.*graphics" > /dev/null 2>&1; then
            CONFIG_FILE="$GPU_CONFIG_DIR/intel.conf"
            echo -e "${GREEN}[GPU] Intel GPU detected${NC}" >&2
            return 0
        fi
    else
        echo -e "${YELLOW}[GPU] lspci not found, checking /proc/modules${NC}" >&2
        
        # Fallback: check loaded kernel modules
        if grep -q nvidia /proc/modules 2>/dev/null; then
            CONFIG_FILE="$GPU_CONFIG_DIR/nvidia.conf"
            echo -e "${GREEN}[GPU] NVIDIA GPU detected (module-based)${NC}" >&2
            return 0
        fi
        
        if grep -q amdgpu /proc/modules 2>/dev/null; then
            CONFIG_FILE="$GPU_CONFIG_DIR/amd.conf"
            echo -e "${GREEN}[GPU] AMD GPU detected (module-based)${NC}" >&2
            return 0
        fi
    fi
    
    # Default fallback
    CONFIG_FILE="$GPU_CONFIG_DIR/generic_gpu.conf"
    echo -e "${YELLOW}[GPU] Using generic/fallback configuration${NC}" >&2
    return 1
}

# Run detection
detect_gpu

# Output the source command
if [ -f "$CONFIG_FILE" ]; then
    echo "source = $CONFIG_FILE"
else
    echo "# Warning: GPU config file not found at $CONFIG_FILE" >&2
    echo "source = $GPU_CONFIG_DIR/generic_gpu.conf"
fi
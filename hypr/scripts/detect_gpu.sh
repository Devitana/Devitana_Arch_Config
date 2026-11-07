#!/usr/bin/env bash
# Print a GPU profile path (default), primary vendor, or all detected vendors.
# Hardware inventory comes from PCI sysfs; lspci is a fallback only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(cd "$SCRIPT_DIR/../env_var/gpu" && pwd)"
PCI_ROOT="${GPU_SYSFS_ROOT:-/sys/bus/pci/devices}"
MODE="${1:---profile}"

case "$MODE" in
    --profile|--primary|--vendors|--report) ;;
    *) echo "Usage: $0 [--profile|--primary|--vendors|--report]" >&2; exit 2 ;;
esac

declare -a VENDORS=()
PRIMARY=""

vendor_name() {
    case "${1,,}" in
        0x1002|1002) echo amd ;;
        0x10de|10de) echo nvidia ;;
        0x8086|8086) echo intel ;;
        *) return 1 ;;
    esac
}

add_vendor() {
    local vendor="$1" found
    for found in "${VENDORS[@]}"; do
        [[ "$found" == "$vendor" ]] && return 0
    done
    VENDORS+=("$vendor")
}

# Read actual GPU-class PCI devices, not audio devices from the same card.
scan_sysfs() {
    local dev class id boot vendor
    for dev in "$PCI_ROOT"/*; do
        [[ -r "$dev/class" && -r "$dev/vendor" ]] || continue
        read -r class < "$dev/class"
        [[ "${class,,}" =~ ^0x03[[:xdigit:]]{4}$ ]] || continue
        read -r id < "$dev/vendor"
        vendor="$(vendor_name "$id")" || continue
        add_vendor "$vendor"
        if [[ -r "$dev/boot_vga" ]]; then
            read -r boot < "$dev/boot_vga"
            [[ "$boot" == 1 ]] && PRIMARY="$vendor"
        fi
    done
}

scan_lspci() {
    command -v lspci >/dev/null 2>&1 || return 0
    local line vendor
    while IFS= read -r line; do
        # Display controllers have PCI class 0300, 0302 or 0380 (03xx).
        [[ "$line" =~ \[03[[:xdigit:]]{2}\] ]] || continue
        if [[ "$line" =~ \[(10de|1002|8086):[[:xdigit:]]{4}\] ]]; then
            vendor="$(vendor_name "${BASH_REMATCH[1]}")" || continue
            add_vendor "$vendor"
        fi
    done < <(LC_ALL=C lspci -Dnn 2>/dev/null || true)
}

scan_sysfs
# On systems without readable sysfs (e.g. live/chroot), use lspci.
((${#VENDORS[@]} > 0)) || scan_lspci

# Without boot_vga information, prefer a discrete GPU over an Intel iGPU.
if [[ -z "$PRIMARY" ]]; then
    for candidate in amd nvidia intel; do
        for vendor in "${VENDORS[@]}"; do
            if [[ "$vendor" == "$candidate" ]]; then
                PRIMARY="$candidate"
                break 2
            fi
        done
    done
fi
PRIMARY="${PRIMARY:-generic_gpu}"

case "$MODE" in
    --vendors) printf '%s\n' "${VENDORS[@]}" ;;
    --primary) printf '%s\n' "$PRIMARY" ;;
    --report)
        printf 'Detected GPU vendors: %s\n' "${VENDORS[*]:-none}"
        printf 'Primary profile: %s\n' "$PRIMARY"
        ;;
    --profile)
        PROFILE="$PROFILE_DIR/$PRIMARY.lua"
        [[ -f "$PROFILE" ]] || PROFILE="$PROFILE_DIR/generic_gpu.lua"
        [[ -f "$PROFILE" ]] || { echo "Missing GPU profile: $PROFILE" >&2; exit 1; }
        printf '%s\n' "$PROFILE"
        ;;
esac

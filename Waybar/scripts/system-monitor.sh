#!/bin/bash

# ============================================================================
# SYSTEM MONITOR - Opens system monitoring tool in terminal
# ============================================================================

# Detect available terminal emulator
TERMINAL=""

if command -v kitty >/dev/null 2>&1; then
    TERMINAL="kitty"
elif command -v alacritty >/dev/null 2>&1; then
    TERMINAL="alacritty"
elif command -v konsole >/dev/null 2>&1; then
    TERMINAL="konsole"
elif command -v gnome-terminal >/dev/null 2>&1; then
    TERMINAL="gnome-terminal"
elif command -v xterm >/dev/null 2>&1; then
    TERMINAL="xterm"
else
    echo "No terminal emulator found" >&2
    exit 1
fi

# Detect available system monitor
MONITOR=""

if command -v btop >/dev/null 2>&1; then
    MONITOR="btop"
elif command -v htop >/dev/null 2>&1; then
    MONITOR="htop"
elif command -v top >/dev/null 2>&1; then
    MONITOR="top"
else
    echo "No system monitor found (btop, htop, or top)" >&2
    exit 1
fi

# Launch monitor in terminal
case "$TERMINAL" in
    kitty)
        kitty -e "$MONITOR"
        ;;
    alacritty)
        alacritty -e "$MONITOR"
        ;;
    konsole)
        konsole -e "$MONITOR"
        ;;
    gnome-terminal)
        gnome-terminal -- "$MONITOR"
        ;;
    xterm)
        xterm -e "$MONITOR"
        ;;
esac

exit $?
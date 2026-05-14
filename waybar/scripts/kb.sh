#!/bin/bash

layout=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap' | awk '{print toupper(substr($0,1,2))}')

caps=$(cat /sys/class/leds/input*::capslock/brightness 2>/dev/null | head -n1)
num=$(cat /sys/class/leds/input*::numlock/brightness 2>/dev/null | head -n1)

class=""

# Set class based on state
if [ "$caps" != "0" ] && [ -n "$caps" ] && [ "$num" != "0" ] && [ -n "$num" ]; then
    class="caps-on-num-on"  # Special combined class
elif [ "$caps" != "0" ] && [ -n "$caps" ]; then
    class="caps-on"
elif [ "$num" != "0" ] && [ -n "$num" ]; then
    class="num-on"
fi

echo "{\"text\":\"⌨ $layout\",\"class\":\"$class\"}"

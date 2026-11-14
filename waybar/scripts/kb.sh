#!/bin/bash

layout=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[0].active_keymap // "??" | ascii_upcase | .[0:2]' 2>/dev/null)
[[ -n "$layout" ]] || layout="??"

read_led() {
    local led value
    for led in /sys/class/leds/*::"$1"/brightness; do
        [[ -r "$led" ]] || continue
        IFS= read -r value < "$led" || continue
        printf '%s\n' "$value"
        return
    done
}

caps=$(read_led capslock)
num=$(read_led numlock)

class=""

# Set class based on state
if [[ "$caps" != "0" && -n "$caps" && "$num" != "0" && -n "$num" ]]; then
    class="caps-on-num-on"  # Special combined class
elif [[ "$caps" != "0" && -n "$caps" ]]; then
    class="caps-on"
elif [[ "$num" != "0" && -n "$num" ]]; then
    class="num-on"
fi

printf '{"text":"⌨ %s","class":"%s"}\n' "$layout" "$class"

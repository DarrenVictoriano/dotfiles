#!/bin/bash

# Usage: ./float_resize.sh WIDTH HEIGHT [X Y]
WIDTH=${1:-1300}   # default 1300 if not provided
HEIGHT=${2:-900}   # default 900 if not provided
X=${3:-}           # optional X position
Y=${4:-}           # optional Y position

if hyprctl activewindow -j | jq '.floating' | grep true >/dev/null; then
    hyprctl dispatch togglefloating
else
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact "$WIDTH" "$HEIGHT"
    
    if [[ -n "$X" && -n "$Y" ]]; then
        hyprctl dispatch moveactive "$X" "$Y"
    else
        hyprctl dispatch centerwindow
    fi
fi


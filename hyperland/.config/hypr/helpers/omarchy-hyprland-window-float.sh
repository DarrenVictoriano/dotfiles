#!/bin/bash

# Toggle to float a tiled window.

# Usage:
# omarchy-hyprland-window-float [WIDTH HEIGHT [X Y]]
#
# Arguments:
#   WIDTH   Optional. Width of the floating window. Default: 1300
#   HEIGHT  Optional. Height of the floating window. Default: 900
#   X       Optional. X position of the window. Must provide both X and Y to take effect.
#   Y       Optional. Y position of the window. Must provide both X and Y to take effect.
#
# Behavior:
#   - If the window is already pinned, it will be unpinned and removed from the pop layer.
#   - If the window is not pinned, it will be floated, resized, moved/centered, pinned, brought to top, and popped.

WIDTH=${1:-1300} # default 1300 if not provided
HEIGHT=${2:-900} # default 900 if not provided
X=${3:-}         # optional X position
Y=${4:-}         # optional Y position

active=$(hyprctl activewindow -j)
addr=$(echo "$active" | jq -r ".address")

[ -z "$addr" ] && {
  echo "No active window"
  exit 0
}

if hyprctl activewindow -j | jq '.floating' | grep true >/dev/null; then
  hyprctl dispatch togglefloating address:"$addr"

else

  hyprctl dispatch togglefloating address:"$addr"
  hyprctl dispatch resizeactive exact "$WIDTH" "$HEIGHT" address:"$addr"

  if [[ -n "$X" && -n "$Y" ]]; then
    hyprctl dispatch moveactive "$X" "$Y" address:"$addr"
  else
    hyprctl dispatch centerwindow address:"$addr"

  fi
fi

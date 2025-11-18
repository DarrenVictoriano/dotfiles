#!/bin/sh

# Usage: ./move_focus.sh <direction>
# direction: l, r, u, d

DIRECTION="$1"

# Get the currently active window ID
ACTIVE_WINDOW_BEFORE=$(hyprctl activewindow -j | jq .address)

# Check if the window is floating
IS_FLOATING=$(hyprctl activewindow -j | jq .floating)

if [ "$IS_FLOATING" = "true" ]; then
    # Cycle to the next window (tiled or floating)
    hyprctl dispatch cyclenext next
else
    # Try to move focus in the given direction for tiled windows
    hyprctl dispatch movefocus "$DIRECTION"

    # Get the active window ID after move
    ACTIVE_WINDOW_AFTER=$(hyprctl activewindow -j | jq .address)

    # If the window didn't change (no more tiled in that direction), fallback to next floating
    if [ "$ACTIVE_WINDOW_BEFORE" = "$ACTIVE_WINDOW_AFTER" ]; then
        hyprctl dispatch cyclenext next floating
    fi
fi


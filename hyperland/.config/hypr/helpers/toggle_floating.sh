#!/bin/bash

if hyprctl activewindow -j | jq '.floating' | grep true; then \
  hyprctl dispatch togglefloating; \
else \
  hyprctl dispatch togglefloating && hyprctl dispatch resizeactive exact 1300 900 && hyprctl dispatch centerwindow; \
fi


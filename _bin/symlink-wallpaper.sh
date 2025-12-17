#!/usr/bin/env bash

set -euo pipefail

: "${OMARCHY_PATH:?OMARCHY_PATH is not set}"

EXCLUDE_FILE="$OMARCHY_PATH/.git/info/exclude"

IGNORE_LINES=(
  "themes/tokyo-night/backgrounds/4-City-Landscape-Architecture.jpg"
  "themes/tokyo-night/backgrounds/5-Train-Station-Dusk.jpg"
)

# Ensure the exclude file exists
mkdir -p "$(dirname "$EXCLUDE_FILE")"
touch "$EXCLUDE_FILE"

for line in "${IGNORE_LINES[@]}"; do
  if ! grep -Fxq "$line" "$EXCLUDE_FILE"; then
    echo "$line" >> "$EXCLUDE_FILE"
    echo "Added ignore: $line"
  else
    echo "Already ignored: $line"
  fi
done

ln -snf "${HOME}/Code/dotfiles/wallpapers/4-City-Landscape-Architecture.jpg" "${HOME}/.local/share/omarchy/themes/tokyo-night/backgrounds/4-City-Landscape-Architecture.jpg"
ln -snf "${HOME}/Code/dotfiles/wallpapers/5-Train-Station-Dusk.jpg" "${HOME}/.local/share/omarchy/themes/tokyo-night/backgrounds/5-Train-Station-Dusk.jpg"


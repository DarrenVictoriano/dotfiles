#!/usr/bin/env zsh

# presenterm
export PRESENTERM_CONFIG_FILE="$HOME/.config/presenterm/config.yaml"

# mise
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh 2>/dev/null)"
fi


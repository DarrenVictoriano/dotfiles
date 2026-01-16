#!/usr/bin/env zsh

# Git ssh-agent
if command -v keychain &> /dev/null; then
  eval "$(keychain --eval --quiet --agents ssh ~/.ssh/id_ed25519 2>/dev/null)"
fi

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh 2>/dev/null)"
fi

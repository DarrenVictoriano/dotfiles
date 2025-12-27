#!/usr/bin/env zsh

# Git ssh-agent
if command -v keychain &> /dev/null; then
  eval "$(keychain --eval --agents ssh ~/.ssh/id_ed25519)"
fi

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

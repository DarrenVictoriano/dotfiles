#!/usr/bin/env zsh

# Git ssh-agent
eval "$(keychain --eval --agents ssh ~/.ssh/id_ed25519)"
eval "$(mise activate zsh)"

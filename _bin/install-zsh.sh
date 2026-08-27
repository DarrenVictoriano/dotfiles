#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

PLATFORM="$(detect_platform)"

if ! command -v zsh >/dev/null 2>&1; then
  log "Installing Zsh..."
  if [[ "$PLATFORM" == macos ]]; then
    BREW="$(activate_homebrew)"
    "$BREW" install zsh
  else
    omarchy-pkg-add zsh
  fi
fi

ZSH_PATH="$(command -v zsh)"
[[ -n "$ZSH_PATH" ]] || die "Zsh was not found after installation."

if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
  log "Adding $ZSH_PATH to /etc/shells..."
  printf '%s\n' "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

if [[ "$PLATFORM" == macos ]]; then
  current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
else
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
fi

if [[ "$current_shell" != "$ZSH_PATH" ]]; then
  log "Changing the login shell to $ZSH_PATH..."
  chsh -s "$ZSH_PATH"
  log "The new login shell will be used in your next session."
else
  log "Zsh is already the login shell."
fi

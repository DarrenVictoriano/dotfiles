#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

require_command curl
require_command git

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
OH_MY_ZSH_URL="https://github.com/ohmyzsh/ohmyzsh"

if [[ -e "$OH_MY_ZSH_DIR" ]]; then
  repo_matches "$OH_MY_ZSH_DIR" "$OH_MY_ZSH_URL" || \
    die "$OH_MY_ZSH_DIR exists but is not the expected Oh My Zsh checkout."
  log "Oh My Zsh is already installed."
else
  log "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"

install_plugin() {
  local url="$1"
  local destination="$2"
  local name="$3"

  if [[ -e "$destination" ]]; then
    repo_matches "$destination" "$url" || \
      die "$destination exists but is not the expected $name checkout."
    log "$name is already installed."
    return
  fi

  log "Installing $name..."
  git clone --depth=1 "$url" "$destination"
}

install_plugin \
  "https://github.com/romkatv/powerlevel10k.git" \
  "$ZSH_CUSTOM/themes/powerlevel10k" \
  powerlevel10k
install_plugin \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
  zsh-syntax-highlighting
install_plugin \
  "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
  zsh-autosuggestions
install_plugin \
  "https://github.com/zsh-users/zsh-history-substring-search.git" \
  "$ZSH_CUSTOM/plugins/zsh-history-substring-search" \
  zsh-history-substring-search

log "Oh My Zsh plugins installed successfully."

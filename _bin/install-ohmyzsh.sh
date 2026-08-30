#!/usr/bin/env bash

set -euo pipefail

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ] || {
      printf 'Error: %s is incomplete; move it aside and rerun setup.\n' "$HOME/.oh-my-zsh" >&2
      return 1
    }
    printf 'Oh My Zsh is already installed.\n'
    return 0
  fi

  printf 'Installing Oh My Zsh.\n'
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
}

install_plugin() {
  local name="$1"
  local repository="$2"
  local destination="$3"

  if [ -d "$destination" ]; then
    [ -d "$destination/.git" ] || {
      printf 'Error: %s is incomplete; move it aside and rerun setup.\n' "$destination" >&2
      return 1
    }
    printf '%s is already installed.\n' "$name"
    return 0
  fi

  printf 'Installing %s.\n' "$name"
  git clone --depth=1 "$repository" "$destination"
}

install_oh_my_zsh

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
install_plugin powerlevel10k \
  https://github.com/romkatv/powerlevel10k.git \
  "$ZSH_CUSTOM/themes/powerlevel10k"
install_plugin zsh-syntax-highlighting \
  https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
install_plugin zsh-autosuggestions \
  https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
install_plugin zsh-history-substring-search \
  https://github.com/zsh-users/zsh-history-substring-search \
  "$ZSH_CUSTOM/plugins/zsh-history-substring-search"

printf 'Oh My Zsh setup completed successfully.\n'

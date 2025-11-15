#!/bin/bash

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended
    echo "oh-my-zsh installed."
  else
    echo "oh-my-zsh already installed."
  fi
}

install_plugin() {
  local repo="$1"
  local dst="$2"
  local name="$3"

  # Normalize the destination path
  dst="${dst/#\~/$HOME}"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "$HOME/.oh-my-zsh does not exist. Can't install plugins."
    return
  fi

  if [ -d "$dst" ]; then
    echo "Plugin already installed: $name"
    return
  fi

  echo "Installing plugin: $name"
  git clone --depth=1 "$repo" "$dst"
  echo "Installed: $name"
}

# --------------------
# Run installation steps
# --------------------

install_oh_my_zsh

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_plugin "https://github.com/romkatv/powerlevel10k.git" \
               "$ZSH_CUSTOM/themes/powerlevel10k" \
               "powerlevel10k"

install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
               "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
               "zsh-syntax-highlighting"

install_plugin "https://github.com/zsh-users/zsh-autosuggestions" \
               "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
               "zsh-autosuggestions"

install_plugin "https://github.com/zsh-users/zsh-history-substring-search" \
               "$ZSH_CUSTOM/plugins/zsh-history-substring-search" \
               "zsh-history-substring-search"

install_plugin "https://github.com/superbrothers/zsh-kubectl-prompt.git" \
               "$ZSH_CUSTOM/plugins/zsh-kubectl-prompt" \
               "zsh-kubectl-prompt"

echo
echo "install-ohmyzsh.sh completed successfully!"


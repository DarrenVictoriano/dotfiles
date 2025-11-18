#!/bin/bash

echo "Installing zsh..."

if ! omarchy-pkg-add zsh; then
  echo "Failed to install zsh"
  exit 1
fi

echo "zsh installed."

# ------------------------------------------------------
# Set Zsh as the default shell (with safety checks)
# ------------------------------------------------------

ZSH_PATH="$(command -v zsh)"

if [ -z "$ZSH_PATH" ]; then
  echo "Error: zsh not found in PATH."
  exit 1
fi

# Ensure zsh is listed in /etc/shells
if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
  echo "Adding $ZSH_PATH to /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Change default shell if not already zsh
if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "Changing default shell to $ZSH_PATH..."
  chsh -s "$ZSH_PATH"
  echo "Default shell changed to zsh."
else
  echo "Default shell is already zsh."
fi

echo "install-zsh.sh completed!"


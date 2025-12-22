#!/usr/bin/env bash

set -euo pipefail

# Check if SHELL does NOT contain "zsh"
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "Error: This script requires Zsh to be your default shell." >&2
  echo "Current shell is: $SHELL" >&2
  exit 1
fi

echo "The default shell is zsh. Proceeding..."

# -----------------------------
# Clone repo if not exists
# -----------------------------
REPO_URL="https://github.com/DarrenVictoriano/dotfiles.git"
TARGET_DIR="$HOME/Code/dotfiles"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Creating parent directory for dotfiles..."
  mkdir -p "$(dirname "$TARGET_DIR")"

  echo "Cloning dotfiles repo..."
  git clone --recurse-submodules "$REPO_URL" "$TARGET_DIR"
else
  echo "Updating existing dotfiles repo..."
  git -C "$TARGET_DIR" pull --rebase
  git -C "$TARGET_DIR" submodule update --init --recursive
fi

cd "$TARGET_DIR"

# -----------------------------
# Run common scripts
# -----------------------------
BIN_DIR="$TARGET_DIR/_bin"

echo "Running install-ohmyzsh.sh..."
bash "$BIN_DIR/install-ohmyzsh.sh"

echo "Running install-common.sh..."
bash "$BIN_DIR/install-common-pkg.sh"

# -----------------------------
# Run OS-specific scripts
# -----------------------------
echo "Running OS-specific pkgs"
bash "$BIN_DIR/install-os-pkg.sh"

# -----------------------------
# Stow dotfiles
# -----------------------------
echo "Stowing config files"
bash "$BIN_DIR/stow-config.sh"

# -----------------------------
# Final touch for linux
# -----------------------------
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  echo "Running install-mise-pkg.sh..."
  bash "$BIN_DIR/install-mise-pkg.sh"


  # symlink dynamic neovim theme
  echo "Symlinking dynamic theming for neovim"
  ln -snf "${HOME}/.config/omarchy/current/theme/neovim.lua" "${HOME}/.config/nvim/lua/plugins/theme.lua"
fi

echo "dotfiles bootstrap completed successfully!"

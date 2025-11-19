#!/bin/bash

set -euo pipefail

# -----------------------------
# Variables
# -----------------------------
REPO_URL="git@github.com:DarrenVictoriano/dotfiles.git"
TARGET_DIR="$HOME/code/dotfiles"
BIN_DIR="$TARGET_DIR/_bin"

# -----------------------------
# Clone repo if not exists
# -----------------------------
if [ ! -d "$TARGET_DIR" ]; then
  echo "Creating parent directory for dotfiles..."
  mkdir -p "$(dirname "$TARGET_DIR")"

  echo "Cloning dotfiles repo..."
  git clone --recurse-submodules "$REPO_URL" "$TARGET_DIR"
else
  echo "Dotfiles repo already exists at $TARGET_DIR"
fi

cd "$TARGET_DIR"

# -----------------------------
# Run common scripts
# -----------------------------
echo "Running install-ohmyzsh.sh..."
bash "$BIN_DIR/install-ohmyzsh.sh"

echo "Running install-common.sh..."
bash "$BIN_DIR/install-common.sh"

# -----------------------------
# Run OS-specific scripts
# -----------------------------
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
Linux)
  # Further detect Arch Linux
  if [ -f /etc/arch-release ]; then
    echo "Detected Arch Linux"
    echo "Running install-linux-pkg.sh..."
    bash "$BIN_DIR/install-linux-pkg.sh"

    echo "Running install-zsh.sh..."
    bash "$BIN_DIR/install-zsh.sh"
  else
    echo "Linux detected but not Arch. Skipping Arch-specific scripts."
  fi
  ;;
Darwin)
  echo "Detected macOS"
  echo "Running install-macos.sh..."
  bash "$BIN_DIR/install-macos.sh"
  ;;
*)
  echo "Unsupported OS: $OS_TYPE"
  exit 1
  ;;
esac

# -----------------------------
# Stow dotfiles
# -----------------------------
echo "Running GNU Stow for dotfiles..."
common_pkgs=(
  bat
  ghostty
  git
  lazyvim
  tmux
  zsh
)

linux_pkgs=(
  elephant
  ghosttymarchy
  hyperland
  mise
  swayosd
  walker
  waybar
)

mac_pkgs=(
  aerospace
  hammerspoon
  hushlogin
  ideavimrc
  karabiner
)

# Determine which set to use
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  pkgs=("${common_pkgs[@]}" "${linux_pkgs[@]}")
elif [ "$OS_TYPE" = "Darwin" ]; then
  pkgs=("${common_pkgs[@]}" "${mac_pkgs[@]}")
else
  echo "Unsupported OS: $OS_TYPE"
  exit 1
fi

# Stow concatinated pkgs
for pkg in "${pkgs[@]}"; do
  echo "Stowing $pkg..."
  stow -t ~ "$pkg"
done

# -----------------------------
# Run mise for linux
# -----------------------------
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  echo "Running install-mise-pkg.sh..."
  bash "$BIN_DIR/install-mise-pkg.sh"
fi

echo "Dotfiles bootstrap completed successfully!"

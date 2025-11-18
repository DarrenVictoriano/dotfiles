#!/bin/bash

set -euo pipefail

# --------- Step 0: Variables ---------
REPO_URL="git@github.com:DarrenVictoriano/dotfiles.git"
TARGET_DIR="$HOME/code/dotfiles"
BIN_DIR="$TARGET_DIR/_bin"

# --------- Step 1: Clone repo if not exists ---------
if [ ! -d "$TARGET_DIR" ]; then
  echo "Creating parent directory for dotfiles..."
  mkdir -p "$(dirname "$TARGET_DIR")"

  echo "Cloning dotfiles repo..."
  git clone --recurse-submodules "$REPO_URL" "$TARGET_DIR"
else
  echo "Dotfiles repo already exists at $TARGET_DIR"
fi

cd "$TARGET_DIR"

# --------- Step 2: Run common scripts ---------
echo "Running install-ohmyzsh.sh..."
bash "$BIN_DIR/install-ohmyzsh.sh"

echo "Running install-common.sh..."
bash "$BIN_DIR/install-common.sh"

# --------- Step 3: Detect OS and run OS-specific scripts ---------
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

# --------- Step 4: Stow dotfiles ---------
echo "Running GNU Stow for dotfiles..."

if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  linux_pkgs=(
    bat
    elephant
    ghostty
    git
    hyperland
    lazyvim
    mise
    swayosd
    tmux
    walker
    waybar
    zsh
  )

  # Iterate over the array
  for pkg in "${linux_pkgs[@]}"; do
    echo "Stowing $pkg..."
    stow -t ~ "$pkg"
  done

elif [ "$OS_TYPE" = "Darwin" ]; then
  mac_pkgs=(
    aerospace
    bat
    ghostty
    git
    hammerspoon
    hushlogin
    ideavimrc
    karabiner
    lazyvim
    tmux
    zsh
  )

  # Map of package-specific stow args
  declare -A mac_stow_args=(
    [ghostty]="--ignore='omarchy-config'"
  )

  for pkg in "${mac_pkgs[@]}"; do
    echo "Stowing $pkg..."
    if [[ -n "${mac_stow_args[$pkg]:-}" ]]; then
      stow -t ~ "${mac_stow_args[$pkg]}" "$pkg"
    else
      stow -t ~ "$pkg"
    fi
  done
fi

# --------- Step 5: Run Linux-only script ---------
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  echo "Running install-mise-pkg.sh..."
  bash "$BIN_DIR/install-mise-pkg.sh"
fi

echo "Dotfiles bootstrap completed successfully!"

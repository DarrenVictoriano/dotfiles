#!/usr/bin/env bash

set -euo pipefail

# -----------------------------
# Variables
# -----------------------------
REPO_URL="git@github.com:DarrenVictoriano/dotfiles.git"
TARGET_DIR="$HOME/Code/dotfiles"
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
  echo "Updating existing dotfiles repo..."
  git -C "$TARGET_DIR" pull --rebase
  git -C "$TARGET_DIR" submodule update --init --recursive
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

# Stow concatenated pkgs
for pkg in "${pkgs[@]}"; do
  echo "Stowing $pkg..."

  # Iterate over *all files* in the package
  while IFS= read -r file; do
    # Compute relative path (everything after "$pkg/")
    rel_path="${file#"${pkg}"/}"
    target="$HOME/$rel_path"

    # If the target exists AND is not a symlink, back it up
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Backing up: $target -> ${target}.bak"
      mkdir -p "$(dirname "$target")" # ensure parent dirs exist
      mv "$target" "${target}.bak"
    fi
  done < <(find "$pkg" -type f)

  # Now safely stow the package
  stow -R -t "$HOME" "$pkg"
done

# -----------------------------
# Run mise for linux
# -----------------------------
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  echo "Running install-mise-pkg.sh..."
  bash "$BIN_DIR/install-mise-pkg.sh"
fi

echo "Dotfiles bootstrap completed successfully!"

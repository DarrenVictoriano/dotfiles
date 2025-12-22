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
CONFIG_HOME="$HOME/.config"
echo "Running GNU Stow for dotfiles..."
declare -A common_pkgs=(
  ["bat"]="$CONFIG_HOME/bat"
  ["ghostty"]="$CONFIG_HOME/ghostty"
  ["git"]="$CONFIG_HOME/git"
  ["lazyvim"]="$CONFIG_HOME/nvim"
  ["tmux"]="$CONFIG_HOME/tmux"
  ["zsh"]="$CONFIG_HOME/zsh"
  ["zshrc"]="$HOME/.zshrc"
)

declare -A linux_pkgs=(
  ["elephant"]="$CONFIG_HOME/elephant"
  ["ghosttymarchy"]="$CONFIG_HOME/ghosttymarchy"
  ["hyperland"]="$CONFIG_HOME/hpyr"
  ["mise"]="$CONFIG_HOME/mise"
  ["swayosd"]="$CONFIG_HOME/swayosd"
  ["walker"]="$CONFIG_HOME/walker"
  ["waybar"]="$CONFIG_HOME/waybar"
)

declare -A mac_pkgs=(
  ["aerospace"]="$CONFIG_HOME/aerospace"
  ["hammerspoon"]="$CONFIG_HOME/hammerspoon"
  ["hushlogin"]="$HOME/.hushlogin"
  ["ideavimrc"]="$HOME/.ideavimrc"
  ["karabiner"]="$CONFIG_HOME/karabiner"
)

# Determine which set to use
declare -A pkgs
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  for key in "${!common_pkgs[@]}"; do pkgs["$key"]="${common_pkgs[$key]}"; done
  for key in "${!linux_pkgs[@]}"; do pkgs["$key"]="${linux_pkgs[$key]}"; done
elif [ "$OS_TYPE" = "Darwin" ]; then
  for key in "${!common_pkgs[@]}"; do pkgs["$key"]="${common_pkgs[$key]}"; done
  for key in "${!mac_pkgs[@]}"; do pkgs["$key"]="${mac_pkgs[$key]}"; done
else
  echo "Unsupported OS: $OS_TYPE"
  exit 1
fi

# Stow concatenated pkgs
for key in "${!pkgs[@]}"; do
  echo "Starting Stow $key"
  path="${pkgs[$key]}"

  if [ -e "$path" ]; then
    echo "Checking if target location contains files."
    echo "Backing up $key: $path"
    mv "$path" "${path}.bak"
  else
    echo "Skipping $key: $path do not exists"
  fi
  
  echo "Stowing $key"
  if [ "$key" == "zshrc" ]; then
    echo "skipping stow for $key because it does not exists."
    continue
  fi

  stow -R -t "$HOME" "$key"
done

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

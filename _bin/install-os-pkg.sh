#!/usr/bin/env bash

TARGET_DIR="$HOME/Code/dotfiles"
BIN_DIR="$TARGET_DIR/_bin"
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

#!/usr/bin/env bash

install_pkg() {
  local pkg="$1"
  if [ -z "$pkg" ]; then
    echo "Error: No package name provided to install_pkg"
    return 1
  fi

  echo "Installing $pkg..."

  OS_TYPE="$(uname -s)"

  case "$OS_TYPE" in
    Darwin)
      # macOS
      if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Please install Homebrew first. Skipping $pkg."
        return 1
      fi

      if ! brew list "$pkg" &>/dev/null; then
        echo "Installing $pkg via Homebrew..."
        if ! brew install "$pkg"; then
          echo "Failed to install $pkg via Homebrew."
          return 1
        fi
      else
        echo "$pkg is already installed."
      fi
      ;;
    Linux)
      # Arch/Omarchy
      if [ -f /etc/arch-release ] || command -v omarchy-pkg-add &>/dev/null; then
        if ! omarchy-pkg-add "$pkg"; then
          echo "Failed to install $pkg via omarchy-pkg-add."
          return 1
        fi
      else
        echo "Unsupported Linux distribution. Install $pkg manually. Skipping."
        return 1
      fi
      ;;
    *)
      echo "Unsupported OS: $OS_TYPE. Skipping $pkg."
      return 1
      ;;
  esac

  echo "$pkg installed successfully!"
}

# -----------------------
# Install PKGs
# -----------------------
install_pkg "git-delta"
install_pkg "tmux"
install_pkg "stow"
install_pkg "thefuck"


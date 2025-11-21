#!/usr/bin/env bash

# -----------------------------
# Install CLI package via Homebrew
# -----------------------------
install_brew_pkg() {
  local pkg="$1"

  if [ -z "$pkg" ]; then
    echo "Error: No package name provided to install_brew_pkg"
    return 1
  fi

  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first. Skipping $pkg."
    return 1
  fi

  if brew list "$pkg" &>/dev/null; then
    echo "$pkg is already installed (brew)."
  else
    echo "Installing $pkg via brew..."
    if ! brew install "$pkg"; then
      echo "Failed to install $pkg via brew."
      return 1
    fi
    echo "$pkg installed successfully via brew."
  fi
}

# -----------------------------
# Install GUI / cask package via Homebrew
# -----------------------------
install_brew_cask() {
  local pkg="$1"

  if [ -z "$pkg" ]; then
    echo "Error: No package name provided to install_brew_cask"
    return 1
  fi

  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first. Skipping $pkg."
    return 1
  fi

  if brew list --cask "$pkg" &>/dev/null; then
    echo "$pkg is already installed (brew cask)."
  else
    echo "Installing $pkg via brew cask..."
    if ! brew install --cask "$pkg"; then
      echo "Failed to install $pkg via brew cask."
      return 1
    fi
    echo "$pkg installed successfully via brew cask."
  fi
}

# -----------------------------
# Example usage
# -----------------------------
# CLI tools
install_brew_pkg "git"
install_brew_pkg "wget"
install_brew_pkg "mas"
install_brew_pkg "jq"
install_brew_pkg "fzf"
install_brew_pkg "fd"
install_brew_pkg "tlrc"
install_brew_pkg "ripgrep"
install_brew_pkg "eza"
install_brew_pkg "bat"
install_brew_pkg "zoxide"
install_brew_pkg "node"
install_brew_pkg "jesseduffield/lazygit/lazygit"
install_brew_pkg "shellcheck"
install_brew_pkg "shfmt"
install_brew_pkg "tmux"
install_brew_pkg "nvim"
install_brew_pkg "hugo"
install_brew_pkg "imagemagick"

# GUI apps
install_brew_cask "ghostty"
install_brew_cask "hammerspoon"
install_brew_cask "kitty"
install_brew_cask "visual-studio-code"
install_brew_cask "alt-tab"
install_brew_cask "hiddenbar"
install_brew_cask "itsycal"
install_brew_cask "lulu"
install_brew_cask "obsidian"
install_brew_cask "raycast"
install_brew_cask "bitwarden"
install_brew_cask "nikitabobko/tap/aerospace"

# Tap and Install
brew tap FelixKratz/formulae
install_brew_pkg "borders"

brew tap homebrew/cask-fonts
install_brew_cask "font-caskaydia-mono-nerd-font"
install_brew_cask "font-meslo-for-powerlevel10k"
install_brew_cask "font-fira-code-nerd-font"

# Move hammerspoon config location
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

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
install_brew_pkg "llvm"
install_brew_pkg "anomalyco/tap/opencode"

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

# Finder: Hide hard drives on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Finder: Hide removable media hard drives on desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder: Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: Show hidden files inside the finder
defaults write com.apple.finder "AppleShowAllFiles" -bool true

# Finder: Show Status Bar
defaults write com.apple.finder "ShowStatusBar" -bool true

# Finder: Set search scope to current folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Finder: show full Unix path in the title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES

# Dock: disable press and hold for vim motion
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Keyboard: Make key repeat faster
defaults write NSGlobalDomain KeyRepeat -int 1         # normal minimum is 2 (30 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)

# MacOS: make dock auto-hide animation fast
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -int 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
# disable bouncing Dock icons (except Launchpad) for this account
defaults write com.apple.dock no-bouncing -bool True

# Drag windows with control command click https://www.reddit.com/r/MacOS/comments/k6hiwk/keyboard_modifier_to_simplify_click_drag_of/
defaults write -g NSWindowShouldDragOnGesture YES

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Thanks to: https://github.com/nikitabobko/dotfiles/blob/main/.script/macOsDefaults.sh

killall Dock

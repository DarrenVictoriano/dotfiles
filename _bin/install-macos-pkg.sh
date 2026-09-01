#!/usr/bin/env bash

brew_install_formula() {
  local package="$1"

  if brew list --formula "$package" >/dev/null 2>&1; then
    return 0
  fi
  brew install "$package"
}

brew_install_cask() {
  local package="$1"

  if brew list --cask "$package" >/dev/null 2>&1; then
    return 0
  fi
  brew install --cask "$package"
}

install_platform_package() {
  brew_install_formula "$1"
}

apply_macos_defaults() {
  defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua" || return 1
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false || return 1
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false || return 1
  defaults write com.apple.finder ShowPathbar -bool true || return 1
  defaults write com.apple.finder AppleShowAllFiles -bool true || return 1
  defaults write com.apple.finder ShowStatusBar -bool true || return 1
  defaults write com.apple.finder FXDefaultSearchScope -string SCcf || return 1
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true || return 1
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false || return 1
  defaults write NSGlobalDomain KeyRepeat -int 1 || return 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10 || return 1
  defaults write com.apple.dock autohide -bool true || return 1
  defaults write com.apple.dock autohide-delay -int 0 || return 1
  defaults write com.apple.dock autohide-time-modifier -float 0.4 || return 1
  defaults write com.apple.dock no-bouncing -bool true || return 1
  defaults write -g NSWindowShouldDragOnGesture -bool true || return 1
  defaults write com.apple.LaunchServices LSQuarantine -bool false || return 1
  killall Dock >/dev/null 2>&1 || true
}

install_platform_packages() {
  local package
  local -a formulas=(
    wget
    mas
    jq
    fzf
    fd
    tlrc
    ripgrep
    eza
    bat
    zoxide
    node
    lazygit
    shellcheck
    shfmt
    neovim
    imagemagick
    llvm
  )
  local -a casks=(
    ghostty
    hammerspoon
    kitty
    visual-studio-code
    alt-tab
    hiddenbar
    itsycal
    lulu
    obsidian
    raycast
    bitwarden
    nikitabobko/tap/aerospace
    font-caskaydia-mono-nerd-font
    font-meslo-for-powerlevel10k
    font-fira-code-nerd-font
  )

  require_command brew
  install_platform_package mise

  for package in "${formulas[@]}"; do
    run_optional "install Homebrew formula $package" brew_install_formula "$package"
  done
  run_optional "install Homebrew formula borders" brew_install_formula FelixKratz/formulae/borders

  for package in "${casks[@]}"; do
    run_optional "install Homebrew cask $package" brew_install_cask "$package"
  done

  run_optional "apply macOS defaults" apply_macos_defaults
}

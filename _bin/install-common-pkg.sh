#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

PLATFORM="$(detect_platform)"

install_brew_formula() {
  local package="$1"

  if "$BREW" list --formula "$package" >/dev/null 2>&1; then
    log "$package is already installed."
    return
  fi

  log "Installing $package with Homebrew..."
  "$BREW" install "$package"
}

install_brew_cask() {
  local package="$1"

  if "$BREW" list --cask "$package" >/dev/null 2>&1; then
    log "$package is already installed."
    return
  fi

  log "Installing $package with Homebrew..."
  "$BREW" install --cask "$package"
}

install_omarchy_package() {
  local package="$1"

  if pacman -Q "$package" >/dev/null 2>&1; then
    log "$package is already installed."
    return
  fi

  log "Installing $package with Omarchy..."
  omarchy-pkg-add "$package"
}

if [[ "$PLATFORM" == macos ]]; then
  BREW="$(activate_homebrew)"

  declare -a formulae=(
    bash
    bat
    eza
    fd
    fzf
    git
    git-delta
    hugo
    imagemagick
    jq
    lazygit
    llvm
    markdownlint-cli2
    mise
    neovim
    presenterm
    ripgrep
    shellcheck
    shfmt
    stow
    tealdeer
    thefuck
    tmux
    wget
    zoxide
    kubectl
  )
  declare -a casks=(
    font-caskaydia-mono-nerd-font
    font-fira-code-nerd-font
    font-meslo-for-powerlevel10k
    ghostty
    gcloud-cli
  )

  for package in "${formulae[@]}"; do
    install_brew_formula "$package"
  done
  for package in "${casks[@]}"; do
    install_brew_cask "$package"
  done
else
  require_command omarchy-pkg-add
  require_command pacman

  declare -a packages=(
    bash
    bat
    bind
    curl
    eza
    fd
    fzf
    git
    git-delta
    ghostty
    hugo
    imagemagick
    jq
    keychain
    kubectl
    lazygit
    llvm
    markdownlint-cli2
    mise
    neovim
    presenterm
    ripgrep
    shellcheck
    shfmt
    stow
    tealdeer
    thefuck
    tmux
    trash-cli
    ttf-cascadia-code-nerd
    ttf-firacode-nerd
    ttf-meslo-nerd
    wget
    wl-clipboard
    zoxide
  )

  for package in "${packages[@]}"; do
    install_omarchy_package "$package"
  done

  require_command yay
  if pacman -Q google-cloud-cli >/dev/null 2>&1; then
    log "google-cloud-cli is already installed."
  else
    log "Installing google-cloud-cli from the AUR..."
    yay -S --noconfirm --needed google-cloud-cli
  fi
fi

log "Core packages installed successfully."

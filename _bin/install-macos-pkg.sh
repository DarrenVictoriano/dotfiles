#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

[[ "$(detect_platform)" == macos ]] || die "This script requires macOS."

BREW="$(activate_homebrew)"
stage="${1:-}"
shift || true

declare -a failures=()

try_step() {
  local label="$1"
  shift

  if ! "$@"; then
    failures+=("$label")
  fi
}

install_formula() {
  local package="$1"

  if "$BREW" list --formula "$package" >/dev/null 2>&1; then
    log "$package is already installed."
  else
    "$BREW" install "$package"
  fi
}

install_cask() {
  local package="$1"

  if "$BREW" list --cask "$package" >/dev/null 2>&1; then
    log "$package is already installed."
  else
    "$BREW" install --cask "$package"
  fi
}

case "$stage" in
  packages)
    declare -a formulae=(mas)
    declare -a casks=(
      alt-tab
      bitwarden
      hammerspoon
      hiddenbar
      itsycal
      kitty
      lulu
      obsidian
      raycast
      visual-studio-code
      karabiner-elements
      nikitabobko/tap/aerospace
    )

    for package in "${formulae[@]}"; do
      try_step "$package" install_formula "$package"
    done
    for package in "${casks[@]}"; do
      try_step "$package" install_cask "$package"
    done

    try_step borders install_formula FelixKratz/formulae/borders
    ;;
  configure)
    disable_quarantine=false
    while (($# > 0)); do
      case "$1" in
        --disable-quarantine)
          disable_quarantine=true
          ;;
        *)
          die "Unknown option: $1"
          ;;
      esac
      shift
    done

    try_step "Hammerspoon config path" defaults write org.hammerspoon.Hammerspoon \
      MJConfigFile "$HOME/.config/hammerspoon/init.lua"
    try_step "hide desktop hard drives" defaults write com.apple.finder \
      ShowHardDrivesOnDesktop -bool false
    try_step "hide removable desktop media" defaults write com.apple.finder \
      ShowRemovableMediaOnDesktop -bool false
    try_step "Finder path bar" defaults write com.apple.finder ShowPathbar -bool true
    try_step "Finder hidden files" defaults write com.apple.finder AppleShowAllFiles -bool true
    try_step "Finder status bar" defaults write com.apple.finder ShowStatusBar -bool true
    try_step "Finder search scope" defaults write com.apple.finder FXDefaultSearchScope -string SCcf
    try_step "Finder POSIX title" defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    try_step "press-and-hold" defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    try_step "key repeat" defaults write NSGlobalDomain KeyRepeat -int 1
    try_step "initial key repeat" defaults write NSGlobalDomain InitialKeyRepeat -int 10
    try_step "Dock auto-hide" defaults write com.apple.dock autohide -bool true
    try_step "Dock auto-hide delay" defaults write com.apple.dock autohide-delay -int 0
    try_step "Dock animation" defaults write com.apple.dock autohide-time-modifier -float 0.4
    try_step "Dock bouncing" defaults write com.apple.dock no-bouncing -bool true
    try_step "modifier window dragging" defaults write -g NSWindowShouldDragOnGesture -bool true

    if $disable_quarantine; then
      try_step "disable application quarantine" defaults write \
        com.apple.LaunchServices LSQuarantine -bool false
    fi

    killall Dock >/dev/null 2>&1 || true
    killall Finder >/dev/null 2>&1 || true
    ;;
  *)
    die "Usage: install-macos-pkg.sh {packages|configure [--disable-quarantine]}"
    ;;
esac

if ((${#failures[@]} > 0)); then
  printf 'Failed macOS steps:\n' >&2
  printf '  - %s\n' "${failures[@]}" >&2
  exit 1
fi

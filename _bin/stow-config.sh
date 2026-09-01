#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM="${1:-${DOTFILES_PLATFORM:-}}"
CONFIG_HOME="$HOME/.config"

backup_target() {
  local backup_path counter path timestamp

  path="$1"
  timestamp="$(date +%Y%m%d%H%M%S)"
  backup_path="${path}.bak.${timestamp}"
  counter=1

  while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
    backup_path="${path}.bak.${timestamp}.${counter}"
    counter=$((counter + 1))
  done

  printf 'Backing up %s to %s\n' "$path" "$backup_path"
  mv "$path" "$backup_path"
}

stow_package() {
  local package="$1" relative_path source_path target_path
  shift

  [ -d "$REPO_DIR/$package" ] || {
    printf 'Error: Stow package does not exist: %s\n' "$package" >&2
    return 1
  }

  printf 'Stowing %s\n' "$package"

  while (($# > 0)); do
    target_path="$1"
    relative_path="${target_path#"$HOME"/}"
    source_path="$REPO_DIR/$package/$relative_path"

    if [ -L "$target_path" ] && [ -e "$source_path" ] && [ "$target_path" -ef "$source_path" ]; then
      printf 'Keeping managed link %s\n' "$target_path"
    elif [ -e "$target_path" ] || [ -L "$target_path" ]; then
      backup_target "$target_path"
    fi
    shift
  done

  stow -d "$REPO_DIR" -t "$HOME" "$package"
}

stow_common_packages() {
  stow_package bat "$CONFIG_HOME/bat"
  stow_package ghostty "$CONFIG_HOME/ghostty"
  stow_package git "$CONFIG_HOME/git"
  stow_package lazyvim "$CONFIG_HOME/nvim"
  stow_package mise "$CONFIG_HOME/mise"
  stow_package tmux "$CONFIG_HOME/tmux"
  stow_package zsh "$HOME/.zshrc" "$CONFIG_HOME/zsh"
  stow_package presenterm "$CONFIG_HOME/presenterm"
}

stow_omarchy_packages() {
  stow_package ghosttymarchy "$CONFIG_HOME/ghosttymarchy"
  stow_package hyprland "$CONFIG_HOME/hypr"
  stow_package gamemode "$CONFIG_HOME/gamemode.ini"
  stow_package omarchy "$CONFIG_HOME/omarchy"
}

stow_macos_packages() {
  stow_package aerospace "$CONFIG_HOME/aerospace"
  stow_package hammerspoon "$CONFIG_HOME/hammerspoon"
  stow_package hushlogin "$HOME/.hushlogin"
  stow_package ideavimrc "$HOME/.ideavimrc"
  stow_package karabiner "$CONFIG_HOME/karabiner"
}

case "$PLATFORM" in
omarchy)
  stow_common_packages
  stow_omarchy_packages
  ;;
macos)
  stow_common_packages
  stow_macos_packages
  ;;
*)
  printf 'Error: Unsupported Stow platform: %s\n' "${PLATFORM:-empty}" >&2
  exit 1
  ;;
esac

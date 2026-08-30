#!/usr/bin/env bash

install_platform_package() {
  omarchy-pkg-add "$1"
}

install_platform_packages() {
  local package
  local -a packages=(
    keychain
    gamemode
    lib32-gamemode
    mangohud
    lib32-mangohud
  )

  require_command omarchy-pkg-add
  for package in "${packages[@]}"; do
    run_optional "install Omarchy package $package" install_platform_package "$package"
  done
}

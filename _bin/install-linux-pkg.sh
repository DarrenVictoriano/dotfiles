#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

[[ "$(detect_platform)" == omarchy ]] || die "This script requires Omarchy."

stage="${1:-}"

case "$stage" in
  packages)
    declare -a packages=(gamemode lib32-gamemode mangohud lib32-mangohud)
    declare -a failures=()

    for package in "${packages[@]}"; do
      if pacman -Q "$package" >/dev/null 2>&1; then
        log "$package is already installed."
      elif ! omarchy-pkg-add "$package"; then
        failures+=("$package")
      fi
    done

    if ((${#failures[@]} > 0)); then
      printf 'Failed Omarchy packages:\n' >&2
      printf '  - %s\n' "${failures[@]}" >&2
      exit 1
    fi
    ;;
  configure)
    theme_source="$HOME/.local/state/omarchy/current/theme/neovim.lua"
    theme_destination="$HOME/.config/nvim/lua/plugins/theme.lua"

    if [[ -r "$theme_source" ]]; then
      if [[ -e "$theme_destination" && ! -L "$theme_destination" ]]; then
        warn "Refusing to replace non-symlink theme config: $theme_destination"
        exit 1
      fi
      mkdir -p "$(dirname "$theme_destination")"
      ln -snf "$theme_source" "$theme_destination"
      log "Enabled the current Omarchy Neovim theme."
    else
      if [[ -L "$theme_destination" && "$(readlink "$theme_destination")" == "$theme_source" ]]; then
        rm -- "$theme_destination"
      fi
      warn "Omarchy has not generated $theme_source; Neovim will use its fallback theme."
    fi
    ;;
  *)
    die "Usage: install-linux-pkg.sh {packages|configure}"
    ;;
esac

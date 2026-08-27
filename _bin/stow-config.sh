#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$BIN_DIR/.." && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

PLATFORM="$(detect_platform)"
MODE=all

case "${1:-}" in
  --core-only)
    MODE=core
    ;;
  --platform-only)
    MODE=platform
    ;;
  "")
    ;;
  *)
    die "Usage: stow-config.sh [--core-only|--platform-only]"
    ;;
esac

require_command stow

BACKUP_ID="${DOTFILES_BACKUP_ID:-$(date +%Y%m%d-%H%M%S)}"
BACKUP_ROOT="$HOME/.local/state/dotfiles/backups/$BACKUP_ID"

if [[ -L "$HOME/.config" ]]; then
  die "Refusing to use symlinked config root: $HOME/.config"
fi
mkdir -p -- "$HOME/.config"

declare -a core_packages=(bat ghostty git lazyvim lints mise presenterm tmux zsh)
declare -a omarchy_packages=(gamemode ghosttymarchy hyprland omarchy)
declare -a macos_packages=(aerospace hammerspoon hushlogin ideavimrc karabiner)

declare -A destinations=(
  [aerospace]=".config/aerospace"
  [bat]=".config/bat"
  [gamemode]=".config/gamemode.ini"
  [ghostty]=".config/ghostty"
  [ghosttymarchy]=".config/ghosttymarchy"
  [git]=".config/git"
  [hammerspoon]=".config/hammerspoon"
  [hushlogin]=".hushlogin"
  [hyprland]=".config/hypr"
  [ideavimrc]=".ideavimrc"
  [karabiner]=".config/karabiner"
  [lazyvim]=".config/nvim"
  [lints]=".markdownlint-cli2.jsonc"
  [mise]=".config/mise"
  [omarchy]=".config/omarchy"
  [presenterm]=".config/presenterm"
  [tmux]=".config/tmux"
  [zsh]=$'.zshrc\n.config/zsh'
)

canonical_path() {
  local path="$1"
  local directory
  local name

  directory="$(dirname -- "$path")"
  name="$(basename -- "$path")"
  (cd -P -- "$directory" 2>/dev/null && printf '%s/%s\n' "$PWD" "$name")
}

resolved_link() {
  local path="$1"
  local target

  target="$(readlink "$path")" || return 1
  if [[ "$target" != /* ]]; then
    target="$(dirname -- "$path")/$target"
  fi
  canonical_path "$target"
}

has_symlink_ancestor() {
  local relative="$1"
  local current="$HOME"
  local component
  local -a components

  IFS=/ read -r -a components <<<"$relative"
  for component in "${components[@]:0:${#components[@]}-1}"; do
    current="$current/$component"
    [[ -L "$current" ]] && return 0
  done
  return 1
}

is_managed_path() {
  local package="$1"
  local relative="$2"
  local target="$HOME/$relative"
  local source="$REPO_ROOT/$package/$relative"
  local source_entry
  local target_entry
  local entry_relative

  if [[ -L "$target" ]]; then
    [[ "$(resolved_link "$target" 2>/dev/null)" == "$(canonical_path "$source" 2>/dev/null)" ]]
    return
  fi

  [[ -d "$source" && -d "$target" ]] || return 1

  shopt -s dotglob globstar nullglob
  for source_entry in "$source"/**; do
    if [[ "$package" == lazyvim && "$source_entry" == */lua/plugins/theme.lua ]]; then
      continue
    fi
    if [[ "$package" == tmux && "$source_entry" == "$source/plugins/"* && \
      "$source_entry" != "$source/plugins/tpm"* ]]; then
      continue
    fi

    entry_relative="${source_entry#"$source"/}"
    target_entry="$target/$entry_relative"

    if [[ -d "$source_entry" && ! -L "$source_entry" ]]; then
      [[ -d "$target_entry" && ! -L "$target_entry" ]] || return 1
    else
      [[ -L "$target_entry" ]] || return 1
      [[ "$(resolved_link "$target_entry" 2>/dev/null)" == \
        "$(canonical_path "$source_entry" 2>/dev/null)" ]] || return 1
    fi
  done

  return 0
}

needs_backup() {
  local package="$1"
  local relative="$2"
  local target="$HOME/$relative"

  [[ -e "$target" || -L "$target" ]] || return 1
  ! is_managed_path "$package" "$relative"
}

validate_conflict() {
  local package="$1"
  local relative="$2"
  local target="$HOME/$relative"
  local backup="$BACKUP_ROOT/$relative"

  if has_symlink_ancestor "$relative"; then
    warn "Refusing to modify $target because one of its parent paths is a symlink."
    return 1
  fi

  needs_backup "$package" "$relative" || return 0

  if [[ -e "$backup" || -L "$backup" ]]; then
    warn "Backup destination already exists: $backup"
    return 1
  fi
}

backup_conflict() {
  local relative="$1"
  local target="$HOME/$relative"
  local backup="$BACKUP_ROOT/$relative"

  log "Backing up $target to $backup"
  mkdir -p -- "$(dirname -- "$backup")" && mv -- "$target" "$backup"
}

restore_backups() {
  local package="$1"
  shift
  local relative
  local target
  local backup

  for relative in "$@"; do
    target="$HOME/$relative"
    backup="$BACKUP_ROOT/$relative"

    if [[ -e "$target" || -L "$target" ]]; then
      if is_managed_path "$package" "$relative"; then
        if [[ -d "$target" && ! -L "$target" ]]; then
          rm -r -- "$target"
        else
          rm -- "$target"
        fi
      elif [[ -d "$target" ]] && rmdir -- "$target" 2>/dev/null; then
        :
      else
        warn "Could not restore $target because Stow left an unexpected path there."
        continue
      fi
    fi

    mkdir -p -- "$(dirname -- "$target")"
    mv -- "$backup" "$target"
  done
}

append_package_ignores() {
  local package="$1"
  local -n command="$2"
  local plugin_directory
  local plugin_name

  if [[ "$package" == lazyvim ]]; then
    command+=(--ignore='theme\.lua$')
  elif [[ "$package" == tmux ]]; then
    for plugin_directory in "$REPO_ROOT/tmux/.config/tmux/plugins"/*; do
      plugin_name="$(basename -- "$plugin_directory")"
      [[ "$plugin_name" == tpm ]] || command+=(--ignore="^$plugin_name$")
    done
  fi
}

stow_package() {
  local package="$1"
  local relative
  local -a package_destinations
  local -a moved=()
  local -a stow_command=(
    stow --restow --no-folding --dir="$REPO_ROOT" --target="$HOME"
  )
  local -a simulation_command=(
    stow --simulate --restow --no-folding --dir="$REPO_ROOT" --target="$HOME"
  )

  [[ -d "$REPO_ROOT/$package" ]] || {
    warn "Stow package does not exist: $package"
    return 1
  }

  mapfile -t package_destinations <<<"${destinations[$package]}"

  for relative in "${package_destinations[@]}"; do
    validate_conflict "$package" "$relative" || return 1
  done

  for relative in "${package_destinations[@]}"; do
    needs_backup "$package" "$relative" || continue
    if ! backup_conflict "$relative"; then
      restore_backups "$package" "${moved[@]}"
      return 1
    fi
    moved+=("$relative")
  done

  log "Stowing $package..."
  append_package_ignores "$package" stow_command
  append_package_ignores "$package" simulation_command
  stow_command+=("$package")
  simulation_command+=("$package")
  if ! "${simulation_command[@]}" >/dev/null 2>&1; then
    restore_backups "$package" "${moved[@]}"
    return 1
  fi
  if ! "${stow_command[@]}"; then
    restore_backups "$package" "${moved[@]}"
    return 1
  fi
}

stow_required_packages() {
  local package

  for package in "${core_packages[@]}"; do
    stow_package "$package"
  done
}

stow_platform_packages() {
  local package
  local -a packages
  local -a failures=()

  if [[ "$PLATFORM" == omarchy ]]; then
    packages=("${omarchy_packages[@]}")
  else
    packages=("${macos_packages[@]}")
  fi

  for package in "${packages[@]}"; do
    if ! stow_package "$package"; then
      failures+=("$package")
    fi
  done

  if ((${#failures[@]} > 0)); then
    printf 'Failed Stow packages:\n' >&2
    printf '  - %s\n' "${failures[@]}" >&2
    return 1
  fi
}

case "$MODE" in
  core)
    stow_required_packages
    ;;
  platform)
    stow_platform_packages
    ;;
  all)
    stow_required_packages
    stow_platform_packages
    ;;
esac

log "Dotfiles stowed successfully."

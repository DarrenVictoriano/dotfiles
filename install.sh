#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/DarrenVictoriano/dotfiles.git}"
TARGET_DIR="${DOTFILES_DIR:-$HOME/code/dotfiles}"
OS_RELEASE_FILE="${DOTFILES_OS_RELEASE_FILE:-/etc/os-release}"

log() {
  printf '\n==> %s\n' "$1"
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

detect_platform() {
  case "$(uname -s)" in
  Darwin)
    [ "$(uname -m)" = "arm64" ] || die "Only Apple Silicon macOS is supported."
    printf 'macos\n'
    ;;
  Linux)
    [ -r "$OS_RELEASE_FILE" ] || die "Linux is supported only through Omarchy."

    # shellcheck disable=SC1090,SC1091
    . "$OS_RELEASE_FILE"
    [ "${ID:-}" = "omarchy" ] || die "Linux is supported only through Omarchy."
    command -v omarchy-version >/dev/null 2>&1 || die "Omarchy tools are unavailable."
    omarchy-version >/dev/null 2>&1 || die "The Omarchy installation could not be verified."
    printf 'omarchy\n'
    ;;
  *)
    die "Unsupported operating system: $(uname -s)"
    ;;
  esac
}

install_homebrew() {
  if [ ! -x /opt/homebrew/bin/brew ]; then
    log "Installing Homebrew"
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  [ -x /opt/homebrew/bin/brew ] || die "Homebrew was not installed under /opt/homebrew."
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

brew_install_or_upgrade() {
  local package="$1"

  if brew list --formula "$package" >/dev/null 2>&1; then
    brew upgrade "$package"
  else
    brew install "$package"
  fi
}

run_omarchy_update() {
  local guard_dir gum_command real_gum reboot_marker update_status

  guard_dir="$(mktemp -d)"
  reboot_marker="$guard_dir/reboot-recommended"
  gum_command="$guard_dir/gum"
  real_gum="$(command -v gum || true)"
  [ -n "$real_gum" ] && [ -x "$real_gum" ] || die "Omarchy's gum command is unavailable."

  # Omarchy's unattended update skips its initial confirmation. This wrapper
  # declines later reboot confirmations without replacing stdin, which remains
  # available to sudo and other required credential prompts.
  # The wrapper body is emitted verbatim; its parameters and variables must be
  # expanded by the generated script, not by this one.
  # shellcheck disable=SC2016
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'if [ "${1:-}" = "confirm" ]; then' \
    '  case "${2:-}" in' \
    '    *reboot*|*Reboot*|*REBOOT*)' \
    '      : "${DOTFILES_REBOOT_MARKER:?}"' \
    '      touch "$DOTFILES_REBOOT_MARKER"' \
    '      printf "Declining reboot during dotfiles setup.\\n"' \
    '      exit 1' \
    '      ;;' \
    '  esac' \
    'fi' \
    'exec "$DOTFILES_REAL_GUM" "$@"' >"$gum_command"
  chmod +x "$gum_command"

  log "Updating Omarchy and system packages"
  if PATH="$guard_dir:$PATH" \
    DOTFILES_REAL_GUM="$real_gum" \
    DOTFILES_REBOOT_MARKER="$reboot_marker" \
    omarchy-update -y; then
    update_status=0
  else
    update_status=$?
  fi

  if [ -f "$reboot_marker" ]; then
    export DOTFILES_REBOOT_RECOMMENDED=1
    # The wrapper declined a reboot on purpose, so Omarchy's nonzero status here
    # reports our own refusal rather than a failed update. Setup continues and
    # reports the reboot recommendation once every phase has finished.
    update_status=0
  fi

  rm -f "$gum_command" "$reboot_marker"
  rmdir "$guard_dir"
  return "$update_status"
}

install_foundational_tools() {
  local platform="$1"
  local brew_prefix

  case "$platform" in
  omarchy)
    run_omarchy_update
    log "Installing foundational shells and Git"
    # One package per call so a failure names the package that caused it.
    omarchy-pkg-add bash
    omarchy-pkg-add zsh
    omarchy-pkg-add git
    DOTFILES_BASH_PATH="$(command -v bash)" || die "Bash is missing after installation."
    DOTFILES_ZSH_PATH="$(command -v zsh)" || die "Zsh is missing after installation."
    export DOTFILES_BASH_PATH DOTFILES_ZSH_PATH
    ;;
  macos)
    install_homebrew
    log "Updating Homebrew"
    brew update
    log "Installing foundational shells and Git"
    brew_install_or_upgrade bash
    brew_install_or_upgrade zsh
    brew_install_or_upgrade git
    brew_prefix="$(brew --prefix)" || die "Homebrew's prefix could not be determined."
    DOTFILES_BASH_PATH="$brew_prefix/bin/bash"
    DOTFILES_ZSH_PATH="$brew_prefix/bin/zsh"
    export DOTFILES_BASH_PATH DOTFILES_ZSH_PATH
    ;;
  esac

  [ -x "$DOTFILES_BASH_PATH" ] || die "The installed Bash executable was not found."
  [ -x "$DOTFILES_ZSH_PATH" ] || die "The installed Zsh executable was not found."

  log "Foundational shell versions"
  "$DOTFILES_BASH_PATH" --version
  "$DOTFILES_ZSH_PATH" --version
}

checkout_repository() {
  local backup_dir timestamp

  case "$REPO_URL" in
  https://*) ;;
  *) die "DOTFILES_REPO_URL must use HTTPS." ;;
  esac

  if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
    backup_dir="${TARGET_DIR}_bak"
    if [ -e "$backup_dir" ] || [ -L "$backup_dir" ]; then
      timestamp="$(date +%Y%m%d%H%M%S)"
      backup_dir="${backup_dir}.${timestamp}"
      while [ -e "$backup_dir" ] || [ -L "$backup_dir" ]; do
        backup_dir="${backup_dir}.$$"
      done
    fi

    log "Moving existing checkout to $backup_dir"
    mv "$TARGET_DIR" "$backup_dir"
  fi

  mkdir -p "$(dirname "$TARGET_DIR")"
  log "Cloning dotfiles over HTTPS"
  git clone --recurse-submodules "$REPO_URL" "$TARGET_DIR"
  git -C "$TARGET_DIR" submodule sync --recursive
  git -C "$TARGET_DIR" submodule update --init --recursive
}

main() {
  local platform

  while [ "$TARGET_DIR" != "/" ] && [ "${TARGET_DIR%/}" != "$TARGET_DIR" ]; do
    TARGET_DIR="${TARGET_DIR%/}"
  done
  case "$TARGET_DIR" in
  /*) ;;
  *) die "DOTFILES_DIR must be an absolute path." ;;
  esac
  [ "$TARGET_DIR" != "/" ] || die "DOTFILES_DIR cannot be the filesystem root."

  platform="$(detect_platform)"
  export DOTFILES_PLATFORM="$platform"

  log "Detected supported platform: $platform"
  install_foundational_tools "$platform"
  checkout_repository

  log "Starting repository setup"
  exec "$DOTFILES_BASH_PATH" "$TARGET_DIR/_bin/setup.sh" "$platform"
}

if [ "${DOTFILES_SOURCE_ONLY:-0}" != "1" ]; then
  main "$@"
fi

#!/bin/sh

set -eu

REPO_URL="https://github.com/DarrenVictoriano/dotfiles.git"
TARGET_DIR="$HOME/Code/dotfiles"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
  elif [ -x /opt/homebrew/bin/brew ]; then
    printf '%s\n' /opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    printf '%s\n' /usr/local/bin/brew
  else
    return 1
  fi
}

bash_is_modern() {
  "$1" -c '((BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 3)))' \
    >/dev/null 2>&1
}

ensure_macos_bash() {
  command -v curl >/dev/null 2>&1 || fail "curl is required to install Homebrew."

  brew_path="$(find_brew || true)"
  if [ -z "$brew_path" ]; then
    log "Installing Homebrew from https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_path="$(find_brew || true)"
  fi

  [ -n "$brew_path" ] || fail "Homebrew installation did not provide a brew executable."
  eval "$("$brew_path" shellenv)"

  if ! "$brew_path" list --formula bash >/dev/null 2>&1; then
    log "Installing Bash 5.3 or newer..."
    "$brew_path" install bash
  fi

  modern_bash="$("$brew_path" --prefix)/bin/bash"
  outdated_bash="$("$brew_path" outdated --formula bash 2>/dev/null || true)"
  if [ -x "$modern_bash" ] && \
    { ! bash_is_modern "$modern_bash" || [ -n "$outdated_bash" ]; }; then
    log "Upgrading Homebrew Bash..."
    "$brew_path" upgrade bash
  fi
  [ -x "$modern_bash" ] || fail "Homebrew Bash was not found at $modern_bash."
  bash_is_modern "$modern_bash" || fail "Bash 5.3 or newer is required."
}

ensure_omarchy_bash() {
  [ -f /etc/arch-release ] || fail "Only Omarchy and macOS are supported."
  command -v omarchy-pkg-add >/dev/null 2>&1 || fail "Omarchy is required on Linux."
  command -v curl >/dev/null 2>&1 || fail "curl is required."
  command -v git >/dev/null 2>&1 || fail "git is required."

  modern_bash="$(command -v bash || true)"
  if [ -z "$modern_bash" ] || ! bash_is_modern "$modern_bash"; then
    log "Installing Bash 5.3 or newer..."
    omarchy-pkg-add bash
    modern_bash="$(command -v bash || true)"
  fi

  [ -n "$modern_bash" ] && bash_is_modern "$modern_bash" || \
    fail "Omarchy did not provide Bash 5.3 or newer."
}

case "$(uname -s)" in
  Darwin)
    ensure_macos_bash
    ;;
  Linux)
    ensure_omarchy_bash
    ;;
  *)
    fail "Only Omarchy and macOS are supported."
    ;;
esac

command -v git >/dev/null 2>&1 || fail "git is required after platform preparation."

if [ -e "$TARGET_DIR" ]; then
  [ -d "$TARGET_DIR/.git" ] || fail "$TARGET_DIR exists but is not a Git checkout."

  origin_url="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"
  case "$origin_url" in
    https://github.com/DarrenVictoriano/dotfiles | https://github.com/DarrenVictoriano/dotfiles.git)
      ;;
    git@github.com:DarrenVictoriano/dotfiles | git@github.com:DarrenVictoriano/dotfiles.git)
      log "Migrating the dotfiles origin to HTTPS..."
      git -C "$TARGET_DIR" remote set-url origin "$REPO_URL"
      ;;
    *)
      fail "$TARGET_DIR does not use the expected dotfiles origin."
      ;;
  esac

  git -C "$TARGET_DIR" symbolic-ref -q HEAD >/dev/null || \
    fail "$TARGET_DIR is in detached HEAD state."
  [ -z "$(git -C "$TARGET_DIR" status --porcelain)" ] || \
    fail "$TARGET_DIR has local changes; update it manually before bootstrapping."

  log "Updating the existing dotfiles checkout..."
  git -C "$TARGET_DIR" pull --ff-only
else
  log "Cloning dotfiles into $TARGET_DIR..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

git -C "$TARGET_DIR" submodule sync --recursive
git -C "$TARGET_DIR" submodule update --init --recursive

exec "$modern_bash" "$TARGET_DIR/install.sh" "$@"

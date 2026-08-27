#!/usr/bin/env bash

if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3))); then
  modern_bash=""
  if [[ "$(uname -s)" == Darwin ]]; then
    for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
      if [[ -x "$candidate" ]] && "$candidate" -c \
        '((BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 3)))'; then
        modern_bash="$candidate"
        break
      fi
    done
  fi

  if [[ -n "$modern_bash" ]]; then
    exec "$modern_bash" "$0" "$@"
  fi

  printf 'Error: Bash 5.3 or newer is required. Run bootstrap.sh first.\n' >&2
  exit 1
fi

set -Eeuo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BIN_DIR="$REPO_ROOT/_bin"

# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

CORE_ONLY=false
DISABLE_QUARANTINE=false

usage() {
  cat <<'EOF'
Usage: install.sh [--core-only] [--disable-quarantine]

  --core-only           Install terminal/development tools and common configs only.
  --disable-quarantine  Disable macOS application quarantine prompts (full profile only).
  --help                Show this help.
EOF
}

while (($# > 0)); do
  case "$1" in
    --core-only)
      CORE_ONLY=true
      ;;
    --disable-quarantine)
      DISABLE_QUARANTINE=true
      ;;
    --help | -h)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

if $CORE_ONLY && $DISABLE_QUARANTINE; then
  die "--disable-quarantine cannot be combined with --core-only."
fi

PLATFORM="$(detect_platform)"
if $DISABLE_QUARANTINE && [[ "$PLATFORM" != macos ]]; then
  die "--disable-quarantine is only available on macOS."
fi

if [[ "$PLATFORM" == macos ]]; then
  BREW="$(find_brew)" || die "Homebrew is required. Run bootstrap.sh first."
  eval "$("$BREW" shellenv)"
fi

export DOTFILES_BACKUP_ID
DOTFILES_BACKUP_ID="$(date +%Y%m%d-%H%M%S)"

log "Installing the core dotfiles profile for $PLATFORM..."
"$BASH" "$BIN_DIR/install-zsh.sh"
"$BASH" "$BIN_DIR/install-common-pkg.sh"
"$BASH" "$BIN_DIR/install-ohmyzsh.sh"
"$BASH" "$BIN_DIR/stow-config.sh" --core-only
"$BASH" "$BIN_DIR/install-mise-pkgs.sh"

if command -v bat >/dev/null 2>&1; then
  bat cache --build
fi

tpm_installer="$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
if [[ -x "$tpm_installer" ]]; then
  "$tpm_installer"
fi

if ! $CORE_ONLY; then
  declare -a failures=()
  declare -a platform_args=(configure)

  log "Installing the full $PLATFORM profile..."
  if ! "$BASH" "$BIN_DIR/install-os-pkg.sh" packages; then
    failures+=("platform packages")
  fi

  if ! "$BASH" "$BIN_DIR/stow-config.sh" --platform-only; then
    failures+=("platform configs")
  fi

  if $DISABLE_QUARANTINE; then
    platform_args+=(--disable-quarantine)
  fi
  if ! "$BASH" "$BIN_DIR/install-os-pkg.sh" "${platform_args[@]}"; then
    failures+=("platform configuration")
  fi

  if ((${#failures[@]} > 0)); then
    printf 'The full profile did not complete:\n' >&2
    printf '  - %s\n' "${failures[@]}" >&2
    exit 1
  fi
fi

log "Dotfiles bootstrap completed successfully."

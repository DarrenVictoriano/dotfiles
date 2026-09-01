#!/usr/bin/env bash

set -euo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM="${1:-${DOTFILES_PLATFORM:-}}"

# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

case "$PLATFORM" in
omarchy)
  # shellcheck source=_bin/install-omarchy-pkg.sh
  source "$BIN_DIR/install-omarchy-pkg.sh"
  ;;
macos)
  # shellcheck source=_bin/install-macos-pkg.sh
  source "$BIN_DIR/install-macos-pkg.sh"
  ;;
*)
  die "Repository setup received an unsupported platform: ${PLATFORM:-empty}"
  ;;
esac

# shellcheck source=_bin/install-common-pkg.sh
source "$BIN_DIR/install-common-pkg.sh"

resolve_zsh_path() {
  if [ -n "${DOTFILES_ZSH_PATH:-}" ]; then
    printf '%s\n' "$DOTFILES_ZSH_PATH"
    return 0
  fi

  # A direct rerun of this script has no Public Bootstrap environment. Resolve
  # the package manager's Zsh rather than falling back to $PATH, which would
  # otherwise downgrade the login shell to the platform's bundled Zsh.
  case "$PLATFORM" in
  macos) printf '%s/bin/zsh\n' "$(brew --prefix)" ;;
  omarchy) printf '%s\n' "$(command -v zsh)" ;;
  esac
}

configure_login_shell() {
  local current_shell zsh_path

  zsh_path="$(resolve_zsh_path)"
  [ -x "$zsh_path" ] || die "Zsh is not executable at ${zsh_path:-empty}"

  if ! grep -Fxq "$zsh_path" /etc/shells; then
    log "Adding $zsh_path to /etc/shells"
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  case "$PLATFORM" in
  omarchy) current_shell="$(getent passwd "$USER" | cut -d: -f7)" ;;
  macos) current_shell="$(dscl . -read "/Users/$USER" UserShell | cut -d' ' -f2)" ;;
  esac

  if [ "$current_shell" != "$zsh_path" ]; then
    log "Changing the login shell to $zsh_path"
    chsh -s "$zsh_path"
  fi
}

log "Installing Oh My Zsh and plugins"
"${DOTFILES_BASH_PATH:-bash}" "$BIN_DIR/install-ohmyzsh.sh"

log "Installing common packages"
install_common_packages

log "Installing $PLATFORM packages"
install_platform_packages

log "Stowing configuration"
"${DOTFILES_BASH_PATH:-bash}" "$BIN_DIR/stow-config.sh" "$PLATFORM"

log "Installing mise-managed tools"
"${DOTFILES_BASH_PATH:-bash}" "$BIN_DIR/install-mise-pkgs.sh"

if [ "$PLATFORM" = "omarchy" ]; then
  log "Linking the current Omarchy Neovim theme"
  ln -snf \
    "$HOME/.local/state/omarchy/current/theme/neovim.lua" \
    "$HOME/.config/nvim/lua/plugins/theme.lua"
fi

configure_login_shell

if [ "${DOTFILES_REBOOT_RECOMMENDED:-0}" = "1" ]; then
  printf '\nOmarchy updated components that recommend rebooting after setup.\n'
fi
printf 'Open a new login shell to use the installed Zsh.\n'

if ! report_optional_failures; then
  exit 1
fi

printf '\nDotfiles setup completed successfully.\n'

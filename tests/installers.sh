#!/usr/bin/env bash

set -Eeuo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
temp_home=""

cleanup() {
  [[ -z "$temp_home" ]] || rm -rf -- "$temp_home"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_fails() {
  if "$@" >/dev/null 2>&1; then
    fail "command unexpectedly succeeded: $*"
  fi
}

bash "$REPO_ROOT/install.sh" --help >/dev/null
assert_fails bash "$REPO_ROOT/install.sh" --unknown
assert_fails bash "$REPO_ROOT/install.sh" --core-only --disable-quarantine
if [[ "$(uname -s)" == Linux ]] && command -v omarchy-pkg-add >/dev/null 2>&1; then
  assert_fails bash "$REPO_ROOT/install.sh" --disable-quarantine
fi

temp_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-stow.XXXXXX")"
mkdir -p "$temp_home/.config/bat"
printf 'original\n' >"$temp_home/.config/bat/marker"

HOME="$temp_home" DOTFILES_BACKUP_ID=test \
  bash "$REPO_ROOT/_bin/stow-config.sh" --core-only >/dev/null

[[ -f "$temp_home/.local/state/dotfiles/backups/test/.config/bat/marker" ]] || \
  fail "Stow did not preserve the conflicting Bat config"
[[ -d "$temp_home/.config/bat" && -L "$temp_home/.config/bat/config" ]] || \
  fail "Bat config was not stowed"
[[ -L "$temp_home/.zshrc" ]] || fail "Zsh config was not stowed"

HOME="$temp_home" DOTFILES_BACKUP_ID=test \
  bash "$REPO_ROOT/_bin/stow-config.sh" --core-only >/dev/null

[[ -f "$temp_home/.local/state/dotfiles/backups/test/.config/bat/marker" ]] || \
  fail "a rerun changed the original backup"

mkdir -p "$temp_home/.config/tmux/plugins/tmux-resurrect"
printf 'keep\n' >"$temp_home/.config/tmux/plugins/tmux-resurrect/sentinel"
HOME="$temp_home" DOTFILES_BACKUP_ID=rerun \
  bash "$REPO_ROOT/_bin/stow-config.sh" --core-only >/dev/null
[[ -f "$temp_home/.config/tmux/plugins/tmux-resurrect/sentinel" ]] || \
  fail "a rerun replaced an existing Tmux plugin"
[[ ! -e "$temp_home/.local/state/dotfiles/backups/rerun/.config/tmux" ]] || \
  fail "a rerun backed up an already managed Tmux config"

rm -rf -- "$temp_home"
temp_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-stow.XXXXXX")"

HOME="$temp_home" DOTFILES_BACKUP_ID=test \
  bash "$REPO_ROOT/_bin/stow-config.sh" --core-only >/dev/null
[[ -d "$temp_home/.config" && ! -L "$temp_home/.config" ]] || \
  fail "Stow did not preserve a real config root in an empty home"
[[ -d "$temp_home/.config/nvim" && ! -L "$temp_home/.config/nvim" ]] || \
  fail "Stow folded the Neovim config into the workspace"

rm -rf -- "$temp_home"
temp_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-stow.XXXXXX")"
mkdir -p "$temp_home/.config/bat"
printf 'original\n' >"$temp_home/.config/bat/marker"
fake_bin="$temp_home/fake-bin"
mkdir -p "$fake_bin"
printf '#!/bin/sh\nexit 1\n' >"$fake_bin/stow"
chmod +x "$fake_bin/stow"

assert_fails env HOME="$temp_home" DOTFILES_BACKUP_ID=test PATH="$fake_bin:$PATH" \
  bash "$REPO_ROOT/_bin/stow-config.sh" --core-only
[[ -f "$temp_home/.config/bat/marker" ]] || \
  fail "a failed Stow run did not restore the original config"

rm -rf -- "$temp_home"
temp_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-stow.XXXXXX")"
mkdir -p "$temp_home/external-config"
ln -s "$temp_home/external-config" "$temp_home/.config"

assert_fails env HOME="$temp_home" DOTFILES_BACKUP_ID=test \
  bash "$REPO_ROOT/_bin/stow-config.sh" --core-only
shopt -s nullglob dotglob
external_entries=("$temp_home/external-config"/*)
((${#external_entries[@]} == 0)) || fail "Stow wrote through a symlinked config ancestor"

if [[ "$(uname -s)" == Linux ]] && command -v omarchy-pkg-add >/dev/null 2>&1; then
  rm -rf -- "$temp_home"
  temp_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-theme.XXXXXX")"

  HOME="$temp_home" bash "$REPO_ROOT/_bin/install-linux-pkg.sh" configure >/dev/null 2>&1
  [[ ! -e "$temp_home/.config/nvim/lua/plugins/theme.lua" ]] || \
    fail "missing Omarchy theme produced a dangling link"

  mkdir -p "$temp_home/.local/state/omarchy/current/theme"
  printf 'return {}\n' >"$temp_home/.local/state/omarchy/current/theme/neovim.lua"
  HOME="$temp_home" bash "$REPO_ROOT/_bin/install-linux-pkg.sh" configure >/dev/null
  [[ -L "$temp_home/.config/nvim/lua/plugins/theme.lua" ]] || \
    fail "available Omarchy theme was not linked"
fi

printf 'Installer regression tests passed.\n'

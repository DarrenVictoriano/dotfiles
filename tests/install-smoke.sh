#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

pass() {
  printf 'ok - %s\n' "$1"
}

test_omarchy_detection() (
  printf 'ID=omarchy\n' >"$TEST_ROOT/omarchy-release"
  DOTFILES_OS_RELEASE_FILE="$TEST_ROOT/omarchy-release"
  DOTFILES_SOURCE_ONLY=1
  source "$REPO_DIR/install.sh"
  uname() { printf 'Linux\n'; }
  omarchy-version() { return 0; }

  [ "$(detect_platform)" = omarchy ]
)

test_apple_silicon_detection() (
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"
  uname() {
    case "$1" in
    -s) printf 'Darwin\n' ;;
    -m) printf 'arm64\n' ;;
    esac
  }

  [ "$(detect_platform)" = macos ]
)

test_intel_mac_rejection() (
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"
  uname() {
    case "$1" in
    -s) printf 'Darwin\n' ;;
    -m) printf 'x86_64\n' ;;
    esac
  }

  ! (detect_platform >/dev/null 2>&1)
)

test_plain_arch_rejection() (
  printf 'ID=arch\n' >"$TEST_ROOT/arch-release"
  DOTFILES_OS_RELEASE_FILE="$TEST_ROOT/arch-release"
  DOTFILES_SOURCE_ONLY=1
  source "$REPO_DIR/install.sh"
  uname() { printf 'Linux\n'; }

  ! (detect_platform >/dev/null 2>&1)
)

test_unknown_system_rejection() (
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"
  uname() { printf 'FreeBSD\n'; }

  ! (detect_platform >/dev/null 2>&1)
)

test_checkout_backup_collision() (
  local argument last backup

  mkdir -p "$TEST_ROOT/checkout/dotfiles" "$TEST_ROOT/checkout/dotfiles_bak"
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"
  TARGET_DIR="$TEST_ROOT/checkout/dotfiles"
  REPO_URL=https://example.invalid/dotfiles.git
  git() {
    if [ "$1" = clone ]; then
      for argument in "$@"; do
        last="$argument"
      done
      mkdir -p "$last"
    fi
    return 0
  }

  checkout_repository >/dev/null
  backup=("$TEST_ROOT"/checkout/dotfiles_bak.*)
  [ -d "${backup[0]}" ]
  [ -d "$TARGET_DIR" ]
)

test_critical_failure_propagation() (
  if bash -euo pipefail -c '
    source "$1/_bin/lib.sh"
    source "$1/_bin/install-common-pkg.sh"
    install_platform_package() { return 1; }
    install_common_packages
  ' bash "$REPO_DIR" >/dev/null 2>&1; then
    return 1
  fi
)

test_optional_failure_summary() (
  source "$REPO_DIR/_bin/lib.sh"
  source "$REPO_DIR/_bin/install-common-pkg.sh"
  install_platform_package() { [ "$1" != git-delta ]; }

  install_common_packages
  ((${#OPTIONAL_FAILURES[@]} == 1))
  ! report_optional_failures >/dev/null 2>&1
)

test_omarchy_reboot_suppression() (
  local mock_dir output

  mock_dir="$TEST_ROOT/omarchy-bin"
  mkdir -p "$mock_dir"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'read -r credential' \
    '[ "$credential" = available ]' \
    'gum confirm "Close browser windows before migration"' \
    'gum confirm "Kernel updated. Reboot?" || true' \
    'printf "continued\\n"' >"$mock_dir/omarchy-update"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\\n" "$*" >>"$GUM_DELEGATION_LOG"' >"$mock_dir/gum"
  chmod +x "$mock_dir/omarchy-update" "$mock_dir/gum"

  PATH="$mock_dir:$PATH"
  GUM_DELEGATION_LOG="$TEST_ROOT/gum-delegation"
  export GUM_DELEGATION_LOG
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"
  run_omarchy_update >"$TEST_ROOT/omarchy-update-output" <<<available
  output="$(<"$TEST_ROOT/omarchy-update-output")"

  [ "${DOTFILES_REBOOT_RECOMMENDED:-0}" = 1 ]
  [[ "$output" == *continued* ]]
  grep -Fxq 'confirm Close browser windows before migration' "$GUM_DELEGATION_LOG"
  ! grep -Fq 'Reboot' "$GUM_DELEGATION_LOG"
)

test_stow_rerun_and_conflict() (
  local backup test_home

  command -v stow >/dev/null 2>&1 || {
    printf 'skip - Stow smoke test (stow unavailable)\n'
    return 0
  }

  test_home="$TEST_ROOT/home"
  mkdir -p "$test_home/.config"
  ln -s /tmp/unrelated "$test_home/.config/bat"

  HOME="$test_home" bash "$REPO_DIR/_bin/stow-config.sh" macos >/dev/null
  HOME="$test_home" bash "$REPO_DIR/_bin/stow-config.sh" macos >/dev/null

  backup=("$test_home"/.config/bat.bak.*)
  ((${#backup[@]} == 1))
  [ -L "${backup[0]}" ]
  [ -L "$test_home/.config/bat" ]
  [ -L "$test_home/.zshrc" ]
)

test_omarchy_detection
pass "detect Omarchy"
test_apple_silicon_detection
pass "detect Apple Silicon macOS"
test_intel_mac_rejection
pass "reject Intel macOS"
test_plain_arch_rejection
pass "reject plain Arch"
test_unknown_system_rejection
pass "reject unknown systems"
test_checkout_backup_collision
pass "back up checkout without collisions"
test_critical_failure_propagation
pass "propagate critical failures"
test_optional_failure_summary
pass "summarize optional failures"
test_omarchy_reboot_suppression
pass "decline Omarchy reboot and preserve stdin"
test_stow_rerun_and_conflict
pass "rerun Stow and back up conflicts"

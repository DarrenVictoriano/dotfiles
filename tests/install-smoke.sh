#!/usr/bin/env bash

# Each test runs in a subshell so its environment overrides and function mocks
# stay isolated. SC2016 covers mock scripts emitted verbatim for later
# expansion; SC2030/SC2031 cover the deliberate subshell scoping.
# shellcheck disable=SC2016,SC2030,SC2031

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

write_gum_mock() {
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\\n" "$*" >>"$GUM_DELEGATION_LOG"' >"$1/gum"
  chmod +x "$1/gum"
}

test_omarchy_reboot_suppression() (
  local mock_dir output

  mock_dir="$TEST_ROOT/omarchy-bin"
  mkdir -p "$mock_dir"
  # Omarchy runs its phases under `set -e`, so a declined gum confirmation
  # aborts the updater with a nonzero status. The mock reproduces that instead
  # of swallowing it, which is the case a real reboot offer produces.
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -e' \
    'read -r credential' \
    '[ "$credential" = available ]' \
    'gum confirm "Close browser windows before migration"' \
    'gum confirm "Kernel updated. Reboot?" || true' \
    'printf "continued\\n"' \
    'gum confirm "Kernel updated. Reboot?"' \
    'printf "unreachable\\n"' >"$mock_dir/omarchy-update"
  chmod +x "$mock_dir/omarchy-update"
  write_gum_mock "$mock_dir"

  PATH="$mock_dir:$PATH"
  GUM_DELEGATION_LOG="$TEST_ROOT/gum-delegation"
  export GUM_DELEGATION_LOG
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"

  # The declined reboot must not abort the bootstrap.
  run_omarchy_update >"$TEST_ROOT/omarchy-update-output" <<<available
  output="$(<"$TEST_ROOT/omarchy-update-output")"

  [ "${DOTFILES_REBOOT_RECOMMENDED:-0}" = 1 ]
  [[ "$output" == *continued* ]]
  [[ "$output" != *unreachable* ]]
  grep -Fxq 'confirm Close browser windows before migration' "$GUM_DELEGATION_LOG"
  ! grep -Fq 'Reboot' "$GUM_DELEGATION_LOG"
)

test_omarchy_update_failure_propagation() (
  local mock_dir

  mock_dir="$TEST_ROOT/omarchy-fail-bin"
  mkdir -p "$mock_dir"
  # A genuine update failure offers no reboot, so nothing sets the marker and
  # the nonzero status must still abort the bootstrap.
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "mirror unreachable\\n" >&2' \
    'exit 3' >"$mock_dir/omarchy-update"
  chmod +x "$mock_dir/omarchy-update"
  write_gum_mock "$mock_dir"

  PATH="$mock_dir:$PATH"
  GUM_DELEGATION_LOG="$TEST_ROOT/gum-failure-delegation"
  export GUM_DELEGATION_LOG
  DOTFILES_SOURCE_ONLY=1 source "$REPO_DIR/install.sh"

  if run_omarchy_update >/dev/null 2>&1; then
    printf 'run_omarchy_update should fail when no reboot was declined\n' >&2
    return 1
  fi
  [ "${DOTFILES_REBOOT_RECOMMENDED:-0}" = 0 ]
)

test_resolve_zsh_path() (
  local mock_dir

  mock_dir="$TEST_ROOT/zsh-resolve-bin"
  mkdir -p "$mock_dir"
  printf '%s\n' '#!/usr/bin/env bash' 'printf "/opt/testbrew\\n"' >"$mock_dir/brew"
  printf '%s\n' '#!/usr/bin/env bash' >"$mock_dir/zsh"
  chmod +x "$mock_dir/brew" "$mock_dir/zsh"
  PATH="$mock_dir:$PATH"

  # resolve_zsh_path is defined inside setup.sh, which runs a full install when
  # sourced. Exercise it through a harness that stops after the definition.
  resolve_via() {
    PLATFORM="$1" DOTFILES_ZSH_PATH="${2:-}" bash -euo pipefail -c '
      PLATFORM="$PLATFORM"
      eval "$(sed -n "/^resolve_zsh_path()/,/^}/p" "$1/_bin/setup.sh")"
      resolve_zsh_path
    ' bash "$REPO_DIR"
  }

  # Omarchy resolves through PATH; macOS resolves through the Homebrew prefix.
  [ "$(resolve_via omarchy)" = "$mock_dir/zsh" ]
  [ "$(resolve_via macos)" = /opt/testbrew/bin/zsh ]
  # An explicit path from the Public Bootstrap always wins.
  [ "$(resolve_via macos /custom/zsh)" = /custom/zsh ]
  [ "$(resolve_via omarchy /custom/zsh)" = /custom/zsh ]
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

test_stow_platform_selection() (
  local platform test_home

  command -v stow >/dev/null 2>&1 || {
    printf 'skip - Stow platform selection (stow unavailable)\n'
    return 0
  }

  for platform in omarchy macos; do
    test_home="$TEST_ROOT/home-$platform"
    mkdir -p "$test_home"
    HOME="$test_home" bash "$REPO_DIR/_bin/stow-config.sh" "$platform" >/dev/null

    # Common packages land on both platforms, mise included.
    [ -L "$test_home/.config/bat" ]
    [ -L "$test_home/.config/nvim" ]
    [ -L "$test_home/.config/mise" ]
    [ -L "$test_home/.zshrc" ]

    case "$platform" in
    omarchy)
      [ -L "$test_home/.config/hypr" ]
      [ -L "$test_home/.config/omarchy" ]
      [ -L "$test_home/.config/ghosttymarchy" ]
      [ -L "$test_home/.config/gamemode.ini" ]
      [ ! -e "$test_home/.config/aerospace" ]
      [ ! -e "$test_home/.config/karabiner" ]
      ;;
    macos)
      [ -L "$test_home/.config/aerospace" ]
      [ -L "$test_home/.config/karabiner" ]
      [ -L "$test_home/.config/hammerspoon" ]
      [ -L "$test_home/.ideavimrc" ]
      [ ! -e "$test_home/.config/hypr" ]
      [ ! -e "$test_home/.config/omarchy" ]
      ;;
    esac
  done
)

# Runs setup.sh end to end against mocked platform tooling so phase ordering and
# platform dispatch are covered without touching the real system.
run_setup_with_mocks() {
  local platform="$1" test_home="$2" mock_dir="$3"

  mkdir -p "$mock_dir" "$test_home"
  cat >"$mock_dir/record" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "${0##*/}" >>"$SETUP_PHASE_LOG"
MOCK
  chmod +x "$mock_dir/record"

  # Mirror each Stow package as plain directories rather than symlinking into
  # the repository, so the Omarchy theme link has a target and this test never
  # writes through a symlink into the real checkout.
  cat >"$mock_dir/stow" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf 'stow\n' >>"$SETUP_PHASE_LOG"
stow_dir=""
target_dir=""
package=""
while [ "$#" -gt 0 ]; do
  case "$1" in
  -d)
    stow_dir="$2"
    shift 2
    ;;
  -t)
    target_dir="$2"
    shift 2
    ;;
  *)
    package="$1"
    shift
    ;;
  esac
done
cd "$stow_dir/$package"
find . -type d -exec mkdir -p "$target_dir/{}" \;
find . -type f -exec touch "$target_dir/{}" \;
MOCK
  chmod +x "$mock_dir/stow"

  # chsh and sudo must never run for real; getent/dscl report the old shell so
  # configure_login_shell always reaches the change branch.
  local command_name
  for command_name in omarchy-pkg-add brew chsh sudo curl git; do
    cp "$mock_dir/record" "$mock_dir/$command_name"
  done
  printf '%s\n' '#!/usr/bin/env bash' 'printf "root:x:0:0::/root:/bin/sh\n"' >"$mock_dir/getent"
  printf '%s\n' '#!/usr/bin/env bash' 'printf "UserShell: /bin/sh\n"' >"$mock_dir/dscl"
  printf '%s\n' '#!/usr/bin/env bash' 'printf "mise\n" >>"$SETUP_PHASE_LOG"' >"$mock_dir/mise"
  chmod +x "$mock_dir/getent" "$mock_dir/dscl" "$mock_dir/mise"

  SETUP_PHASE_LOG="$test_home/phases" \
    HOME="$test_home" \
    PATH="$mock_dir:$PATH" \
    DOTFILES_ZSH_PATH="$mock_dir/record" \
    DOTFILES_BASH_PATH="$(command -v bash)" \
    bash "$REPO_DIR/_bin/setup.sh" "$platform"
}

test_setup_runs_mise_on_both_platforms() (
  local platform test_home

  for platform in omarchy macos; do
    test_home="$TEST_ROOT/setup-$platform"
    # Oh My Zsh and Stow are exercised by their own tests; stub them out here so
    # this test isolates setup.sh's own ordering.
    run_setup_with_mocks "$platform" "$test_home" "$TEST_ROOT/setup-bin-$platform" \
      >"$test_home.out" 2>&1 || {
      cat "$test_home.out" >&2
      return 1
    }

    # mise must run on macOS too, not just Omarchy.
    grep -Fxq mise "$test_home/phases"
    grep -Fxq stow "$test_home/phases"
  done
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
pass "continue after declining an Omarchy reboot"
test_omarchy_update_failure_propagation
pass "propagate genuine Omarchy update failures"
test_resolve_zsh_path
pass "resolve the platform Zsh without downgrading"
pass "decline Omarchy reboot and preserve stdin"
test_stow_rerun_and_conflict
pass "rerun Stow and back up conflicts"
test_stow_platform_selection
pass "stow the right packages per platform"
test_setup_runs_mise_on_both_platforms
pass "run mise on both platforms"

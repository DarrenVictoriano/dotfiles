#!/usr/bin/env bash

if [ -n "${DOTFILES_LIB_LOADED:-}" ]; then
  return 0
fi
readonly DOTFILES_LIB_LOADED=1

declare -a OPTIONAL_FAILURES=()

log() {
  printf '\n==> %s\n' "$1"
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

run_optional() {
  local description="$1"
  shift

  if "$@"; then
    return 0
  fi

  OPTIONAL_FAILURES+=("$description")
  printf 'Warning: %s failed; continuing setup.\n' "$description" >&2
  return 0
}

report_optional_failures() {
  local failure

  if ((${#OPTIONAL_FAILURES[@]} == 0)); then
    return 0
  fi

  printf '\nSetup completed with optional failures:\n' >&2
  for failure in "${OPTIONAL_FAILURES[@]}"; do
    printf '  - %s\n' "$failure" >&2
  done
  return 1
}

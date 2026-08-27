#!/usr/bin/env bash

if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3))); then
  printf 'Error: Bash 5.3 or newer is required.\n' >&2
  exit 1
fi

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required."
}

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      printf '%s\n' macos
      ;;
    Linux)
      if [[ -f /etc/arch-release ]] && command -v omarchy-pkg-add >/dev/null 2>&1; then
        printf '%s\n' omarchy
      else
        die "Only Omarchy and macOS are supported."
      fi
      ;;
    *)
      die "Only Omarchy and macOS are supported."
      ;;
  esac
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    printf '%s\n' /opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    printf '%s\n' /usr/local/bin/brew
  else
    return 1
  fi
}

activate_homebrew() {
  local brew_path

  brew_path="$(find_brew)" || die "Homebrew is required. Run bootstrap.sh first."
  eval "$("$brew_path" shellenv)"
  printf '%s\n' "$brew_path"
}

repo_matches() {
  local directory="$1"
  local expected_url="$2"
  local actual_url

  [[ -d "$directory/.git" ]] || return 1
  actual_url="$(git -C "$directory" remote get-url origin 2>/dev/null)" || return 1
  [[ "${actual_url%.git}" == "${expected_url%.git}" ]]
}

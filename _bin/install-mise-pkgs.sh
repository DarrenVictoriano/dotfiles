#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

require_command mise

declare -a tools=(codex go node opencode python)

for tool in "${tools[@]}"; do
  if [[ -n "$(mise ls --installed --no-header "$tool" 2>/dev/null)" ]]; then
    log "$tool already has an installed Mise version."
    continue
  fi

  log "Installing $tool with Mise..."
  mise install "$tool"
done

log "Mise tools installed successfully."

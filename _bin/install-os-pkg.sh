#!/usr/bin/env bash

set -Eeuo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_bin/lib.sh
source "$BIN_DIR/lib.sh"

PLATFORM="$(detect_platform)"

case "$PLATFORM" in
  omarchy)
    exec "$BASH" "$BIN_DIR/install-linux-pkg.sh" "$@"
    ;;
  macos)
    exec "$BASH" "$BIN_DIR/install-macos-pkg.sh" "$@"
    ;;
esac

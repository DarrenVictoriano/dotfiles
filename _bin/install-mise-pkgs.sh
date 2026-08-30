#!/usr/bin/env bash

set -euo pipefail

command -v mise >/dev/null 2>&1 || {
  printf 'Error: mise is required but was not found.\n' >&2
  exit 1
}

mise install

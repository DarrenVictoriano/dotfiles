#!/usr/bin/env zsh

export SECONDBRAIN="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain"

export VCPKG_DEFAULT_TRIPLET="arm64-osx"
export VCPKG_ROOT="$HOME/Code/cpp/vcpkg"
export VCPKG_TOOLCHAIN="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
export PATH="$VCPKG_ROOT:$PATH"

if command -v brew &> /dev/null && brew --prefix llvm &> /dev/null; then
  export PATH="$(brew --prefix llvm)/bin:$PATH"
fi

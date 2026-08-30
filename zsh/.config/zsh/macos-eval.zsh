#!/usr/bin/env zsh

export SECONDBRAIN="/Users/darren/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain"

export VCPKG_DEFAULT_TRIPLET="arm64-osx"
export VCPKG_ROOT="$HOME/code/cpp/vcpkg"
export VCPKG_TOOLCHAIN="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
export PATH="$VCPKG_ROOT:$PATH"

# clang-tidy
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"



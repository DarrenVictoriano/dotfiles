#!/usr/bin/env zsh

export SECONDBRAIN="/Users/darren/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path 2>/dev/null)"
eval "$(pyenv init - 2>/dev/null)"

export VCPKG_DEFAULT_TRIPLET="arm64-osx"
export VCPKG_ROOT="$HOME/code/cpp/vcpkg"
export VCPKG_TOOLCHAIN="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
export PATH="$VCPKG_ROOT:$PATH"

# clang-tidy
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

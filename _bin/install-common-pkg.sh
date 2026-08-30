#!/usr/bin/env bash

install_common_packages() {
  install_platform_package stow
  run_optional "install git-delta" install_platform_package git-delta
  run_optional "install tmux" install_platform_package tmux
}

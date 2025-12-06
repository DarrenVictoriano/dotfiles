#!/usr/bin/env zsh

# https://github.com/NVIDIA/open-gpu-kernel-modules
alias update-nvidia='sudo pacman -S linux-headers nvidia-open-dkms nvidia-utils --noconfirm && sudo depmod -a && sudo mkinitcpio -P'

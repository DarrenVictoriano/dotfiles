#!/usr/bin/env bash

OS_TYPE="$(uname -s)"
echo "Running GNU Stow for dotfiles..."
common_pkgs=(
  bat
  ghostty
  git
  lazyvim
  tmux
  zsh
)

linux_pkgs=(
  elephant
  ghosttymarchy
  hyperland
  mise
  swayosd
  walker
  waybar
)

mac_pkgs=(
  aerospace
  hammerspoon
  hushlogin
  ideavimrc
  karabiner
)

# Determine which set to use
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  pkgs=("${common_pkgs[@]}" "${linux_pkgs[@]}")
elif [ "$OS_TYPE" = "Darwin" ]; then
  pkgs=("${common_pkgs[@]}" "${mac_pkgs[@]}")
else
  echo "Unsupported OS: $OS_TYPE"
  exit 1
fi

# Stow concatenated pkgs
for pkg in "${pkgs[@]}"; do
  echo "Stowing $pkg..."

  # Iterate over *all files* in the package
  while IFS= read -r file; do
    # Compute relative path (everything after "$pkg/")
    rel_path="${file#"${pkg}"/}"
    target="$HOME/$rel_path"

    # If the target exists AND is not a symlink, back it up
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Backing up: $target -> ${target}.bak"
      mkdir -p "$(dirname "$target")" # ensure parent dirs exist
      mv "$target" "${target}.bak"
    fi
  done < <(find "$pkg" -type f)

  # Now safely stow the package
  stow -R -t "$HOME" "$pkg"
done

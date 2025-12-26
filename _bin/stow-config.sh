#!/usr/bin/env bash

CONFIG_HOME="$HOME/.config"
OS_TYPE="$(uname -s)"
echo "Running GNU Stow for dotfiles..."

declare -A common_pkgs=(
  ["bat"]="$CONFIG_HOME/bat"
  ["ghostty"]="$CONFIG_HOME/ghostty"
  ["git"]="$CONFIG_HOME/git"
  ["lazyvim"]="$CONFIG_HOME/nvim"
  ["tmux"]="$CONFIG_HOME/tmux"
  ["zsh"]="$CONFIG_HOME/zsh"
  ["zshrc"]="$HOME/.zshrc"
)

declare -A linux_pkgs=(
  ["elephant"]="$CONFIG_HOME/elephant"
  ["ghosttymarchy"]="$CONFIG_HOME/ghosttymarchy"
  ["hyperland"]="$CONFIG_HOME/hypr"
  ["mise"]="$CONFIG_HOME/mise"
  ["swayosd"]="$CONFIG_HOME/swayosd"
  ["walker"]="$CONFIG_HOME/walker"
  ["waybar"]="$CONFIG_HOME/waybar"
  ["gamemode"]="$CONFIG_HOME/gamemode.ini"
)

declare -A mac_pkgs=(
  ["aerospace"]="$CONFIG_HOME/aerospace"
  ["hammerspoon"]="$CONFIG_HOME/hammerspoon"
  ["hushlogin"]="$HOME/.hushlogin"
  ["ideavimrc"]="$HOME/.ideavimrc"
  ["karabiner"]="$CONFIG_HOME/karabiner"
)

# Determine which set to use
declare -A pkgs
if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/arch-release ]; then
  for key in "${!common_pkgs[@]}"; do pkgs["$key"]="${common_pkgs[$key]}"; done
  for key in "${!linux_pkgs[@]}"; do pkgs["$key"]="${linux_pkgs[$key]}"; done
elif [ "$OS_TYPE" = "Darwin" ]; then
  for key in "${!common_pkgs[@]}"; do pkgs["$key"]="${common_pkgs[$key]}"; done
  for key in "${!mac_pkgs[@]}"; do pkgs["$key"]="${mac_pkgs[$key]}"; done
else
  echo "Unsupported OS: $OS_TYPE"
  exit 1
fi

# Stow concatenated pkgs
for key in "${!pkgs[@]}"; do
  echo "Starting Stow $key"
  path="${pkgs[$key]}"

  if [ -e "$path" ]; then
    if [ -L "$path" ]; then
      echo "$path is a symlink, unstowing.."
      stow -D -t "$HOME" "$key"
    fi

    echo "Checking if target location contains files."
    echo "Backing up $key: $path"
    mv "$path" "${path}.bak"
  else
    echo "Skipping $key: $path do not exists"
  fi
  
  echo "Stowing $key"
  if [ "$key" == "zshrc" ]; then
    echo "skipping stow for $key because I dont stow this file."
    continue
  fi

  stow -t "$HOME" "$key"
done


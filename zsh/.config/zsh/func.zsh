#!/usr/bin/env zsh

function git-keys() {
	# show git aliases
    # Assuming Oh My Zsh is installed in the default location
    git_plugin_file="$HOME/.oh-my-zsh/plugins/git/git.plugin.zsh"
    
    # Check if the plugin file exists
    if [[ -f "$git_plugin_file" ]]; then
        # Use grep to extract lines starting with "alias"
        grep "^alias" "$git_plugin_file" | fzf
    else
        echo "Git plugin file not found."
    fi
}


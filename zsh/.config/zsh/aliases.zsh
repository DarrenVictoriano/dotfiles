#!/usr/bin/env zsh

# For a full list of active aliases, run `alias`.
alias refresh='source ~/.zshrc'
alias ls='eza -lh --group-directories-first --icons=auto --sort=extension'
alias la='ls -a'
alias less='bat'
alias cat='bat --paging=never'
alias lt='eza --tree --level=3 --git --group-directories-first --sort=extension'
alias lta='lt -a'
alias ff="fzf --preview '$HOME/.config/zsh/fzf-preview.sh {}'"
alias fd='fd -H --exclude .git'
alias icat='kitty icat'
alias cd='z'
alias k="kubectl"
alias del="trash"
alias diff='git diff --no-index'
alias f='fuck'
alias fman='compgen -c | fzf | xargs man'
alias ftldr='compgen -c | fzf | xargs tldr'
alias vim='nvim'
# alias grep='rg'
alias kswitchcontext='kubectl config use-context $(kubectl config get-contexts -o name | fzf)'
alias tmux-keys='tmux list-keys | fzf'
alias tmux='tmux -f ~/.config/tmux/tmux.conf'



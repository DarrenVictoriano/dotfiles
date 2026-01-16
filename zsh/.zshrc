# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.s
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  sudo
  extract
  kubectl
  gcloud
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-kubectl-prompt
  poetry
)

source $ZSH/oh-my-zsh.sh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=23'

## Parse kubectl promt to only display the context
function kubectl_prompt() {
    context=$(echo "$ZSH_KUBECTL_CONTEXT" | cut -d'_' -f2)
    
    # Check if the first index is not empty
    if [ -n "$context" ]; then
		    echo "$context"
    else
        # Return an error message if the first index is empty
        echo "Error: Unable to extract the 1st index from ZSH_KUBECTL_CONTEXT"
    fi
}
RPROMPT='%{$fg[blue]%}($(kubectl_prompt))%{$reset_color%}'

# fzf setup and theme
if command -v fzf &> /dev/null; then
  source $HOME/.config/zsh/fzf-setup.zsh
fi

# zoxide for better cd
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Enable thefuck
if command -v thefuck &> /dev/null; then
  eval $(thefuck --alias)
fi

# bat theme
export BAT_THEME="Catppuccin Macchiato"

# Bind Up/Down Keys
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# Manpages to use nvim
export MANPAGER='nvim +Man!'

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=32768
SAVEHIST=32768
setopt APPEND_HISTORY           # Append to history file
setopt SHARE_HISTORY            # Share history across sessions
setopt HIST_IGNORE_DUPS         # Ignore duplicate commands
setopt HIST_IGNORE_SPACE        # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS       # Remove unnecessary blanks


# Common alias and functions
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"
[ -f "$HOME/.config/zsh/func.zsh" ] && source "$HOME/.config/zsh/func.zsh"


# OS specific
case "$OSTYPE" in
  linux*)  
    [ -f "$HOME/.config/zsh/omarchy-alias.zsh" ] && source "$HOME/.config/zsh/omarchy-alias.zsh"
    [ -f "$HOME/.config/zsh/omarchy-func.zsh" ] && source "$HOME/.config/zsh/omarchy-func.zsh"
    [ -f "$HOME/.config/zsh/omarchy-eval.zsh" ] && source "$HOME/.config/zsh/omarchy-eval.zsh"
    ;;
  darwin*) 
    [ -f "$HOME/.config/zsh/macos-alias.zsh" ] && source "$HOME/.config/zsh/macos-alias.zsh"
    [ -f "$HOME/.config/zsh/macos-func.zsh" ] && source "$HOME/.config/zsh/macos-func.zsh"
    [ -f "$HOME/.config/zsh/macos-eval.zsh" ] && source "$HOME/.config/zsh/macos-eval.zsh"
    ;;
esac

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/p10k.zsh.
[[ ! -f "$HOME/.config/zsh/p10k.zsh" ]] || source "$HOME/.config/zsh/p10k.zsh"

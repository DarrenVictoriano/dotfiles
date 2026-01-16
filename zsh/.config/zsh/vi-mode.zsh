#!/usr/bin/env zsh

# rebind esc to jk
bindkey -M viins 'jk' vi-cmd-mode

# VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=1
VI_MODE_CURSOR_VISUAL=6
VI_MODE_CURSOR_INSERT=5
VI_MODE_CURSOR_OPPEND=0

# text objects to select qoutes
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done


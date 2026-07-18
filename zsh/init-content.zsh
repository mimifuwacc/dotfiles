# brew
if [ -d /opt/homebrew ]; then export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"; fi

# direnv
eval "$(direnv hook zsh)"

# fzf
source <(fzf --zsh)

# Esc -> e to edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line
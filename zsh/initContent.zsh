# brew
if [ -d /opt/homebrew ]; then export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"; fi

# direnv
eval "$(direnv hook zsh)"

# fzf
source <(fzf --zsh)
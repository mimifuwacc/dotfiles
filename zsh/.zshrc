export _USERNAME=$(whoami)
export _HOSTNAME=$(hostname -s)

# Load starship prompt
if type starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Load direnv
if type direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# History
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000

# History key bindings
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# zsh options
setopt mark_dirs auto_param_slash auto_cd auto_menu correct
setopt interactive_comments magic_equal_subst complete_in_word
setopt print_eight_bit no_beep
setopt hist_ignore_dups inc_append_history share_history
setopt hist_ignore_all_dups hist_save_no_dups hist_expire_dups_first
setopt extended_history

# Aliases
alias ls='eza --icons --git --time-style relative'
alias vim=nvim
alias v=nvim
alias ssh="TERM=xterm ssh"
alias a=./a.out
alias ccusage="bunx ccusage@latest"

# direnv alias
if type direnv &>/dev/null; then
  alias nix-direnv="echo 'use nix' >> .envrc && direnv allow"
fi

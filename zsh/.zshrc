export _USERNAME=$(whoami)
export _HOSTNAME=$(hostname -s)

# Load zsh plugins from sheldon
if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

# Load starship prompt
if type starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Set eza for default ls
if type eza &>/dev/null; then
  alias ls='eza --icons --git --time-style relative'
fi

# Add nvim alias
if type nvim &>/dev/null; then
  alias vim=nvim
  alias v=nvim
fi

# History
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

setopt hist_ignore_dups
setopt inc_append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_expire_dups_first
setopt extended_history

# Other options
setopt mark_dirs
setopt auto_param_slash
setopt auto_cd
setopt auto_menu
setopt correct
setopt interactive_comments
setopt magic_equal_subst
setopt complete_in_word
setopt print_eight_bit
setopt no_beep

# SSH
alias ssh="TERM=xterm ssh"

# Other aliases
alias a=./a.out
alias ccusage="bunx ccusage@latest"
alias claude="claude-chill claude"

# Load custom environment variables
# source ~/.config/zsh/env.zsh

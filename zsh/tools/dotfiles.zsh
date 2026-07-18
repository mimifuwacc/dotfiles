# Run dotfiles Taskfile tasks from any directory:
#   dotfiles              # edit dotfiles
#   dotfiles apply
#   dotfiles apply:update
function dotfiles() {
  task --dir "$HOME/dotfiles" "$@"
}

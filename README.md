# Dotfiles

## Initial Setup

```sh
git clone github.com:mimifuwacc/dotfiles

# Auto-detect hostname and apply
# macOS (Darwin)
~/dotfiles/system/darwin/apply.sh $(hostname -s | tr '[:upper:]' '[:lower:]')
```

## Usage

```sh
dotfiles                  # edit dotfiles (VSCode is default editor)
dotfiles edit             # same as no agrs
dotfiles apply            # Apply configuration (auto-detects hostname)
dotfiles apply:update     # Update flake.lock, brew packages and apply
```

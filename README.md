# Dotfiles

## Initial Setup

Run the script directly:

```bash
# Auto-detect hostname and apply
# macOS (Darwin)
~/dotfiles/system/darwin/apply.sh $(hostname -s | tr '[:upper:]' '[:lower:]')
```

## Usage

```bash
# Apply configuration (auto-detects hostname)
task apply
```

```bash
# Apply for specific hostname
task apply <hostname>
```

```bash
# Update flake.lock and apply
task apply:update
```

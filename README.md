# Dotfiles

## Initial Setup

Run the script directly:

```bash
# Auto-detect hostname and apply
~/dotfiles/system/$(hostname -s)/apply.sh
```

```bash
# Or specify hostname explicitly
~/dotfiles/system/<hostname>/apply.sh
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

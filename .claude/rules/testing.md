# Testing & Application Rules

Rules for testing and applying configuration changes.

## DO

- **Use `task apply` for applying configuration** - This is the standard way to apply changes
- **Test with `darwin-rebuild build` first** - Verify changes before applying
- **Apply to all machines after common changes** - Modifying `_common/` affects everyone

## DON'T

- **Don't use `darwin-rebuild switch` directly** - Unless you're debugging and know what you're doing
- **Don't skip testing** - Especially for common config changes

## UPDATE WORKFLOW

1. Make changes to relevant files
2. Test locally: `darwin-rebuild build --flake ~/dotfiles/system/darwin`
3. If build succeeds: `task apply`
4. For common changes: Repeat on all machines

## UPDATE FLAKE LOCK

```bash
task apply:update
```

This updates `flake.lock` and applies configuration in one step.

## DIRECT COMMANDS (DEBUGGING ONLY)

```bash
# Build without applying
darwin-rebuild build --flake ~/dotfiles/system/darwin#$(hostname -s | tr '[:upper:]' '[:lower:]') --impure

# Apply with explicit environment
sudo -E _USERNAME=$(whoami) _HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]') \
  darwin-rebuild switch --flake ~/dotfiles/system/darwin --impure
```

Only use these when `task apply` isn't working and you need to debug.

# Configuration Rules

Rules for managing Nix configurations in this repository.

## DO

- **Keep common settings in `_common/`** - System-level in `_common/darwin.nix`, user-level in `_common/home.nix`
- **Put machine-specific settings in `<hostname>/hosts.nix`** - Only packages and files unique to that machine
- **Move shared settings to common** - If multiple machines need the same config, it belongs in `_common/`

## DON'T

- **Don't duplicate configuration** - Avoid repeating the same settings across multiple machines
- **Don't add machine-specific packages to common configs** - Use `<hostname>/hosts.nix` instead
- **Don't put shared VSCode settings in machine-specific configs** - If multiple machines use the same VSCode setup, consider managing it separately

## UPDATE BEHAVIOR

- **Common config changes affect all machines** - Modifying `_common/darwin.nix` or `_common/home.nix` requires running `task apply` on each machine
- **Test before applying** - Use `darwin-rebuild build` to verify changes before `task apply`

## VSCode SETTINGS

VSCode settings are managed per-machine using `mkOutOfStoreSymlink`:

- **Location**: `vscode/<hostname>/settings.json`
- **Linked to**: `~/Library/Application Support/Code/User/settings.json`
- **Benefits**: Direct symlink allows immediate edits without Nix rebuilds

**Example:**
```nix
# In <hostname>/hosts.nix
home.file."Library/Application Support/Code/User/settings.json".source =
  config.lib.file.mkOutOfStoreSymlink /Users/mimifuwacc/dotfiles/vscode/anemone/settings.json;
```

**First-time setup:**
1. Remove existing settings.json
2. Run `task apply`
3. VSCode will use the symlinked configuration

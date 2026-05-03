# File Management Rules

Rules for handling file paths and the `df` function.

## DO

- **Use absolute paths in `hosts.nix`** - For `home.file`, use paths like `/Users/mimifuwacc/dotfiles/path/to/file`
- **Use `.text` attribute for simple content** - Instead of sourcing files, use `"file.txt".text = "content"`
- **Use `df` function in `_common/home.nix`** - It works correctly there for linking dotfiles
- **Use `mkOutOfStoreSymlink` for frequently edited files** - For files like VSCode settings that you edit often

## DON'T

- **Don't use `df` function in `hosts.nix`** - Path resolution issues in shared modules context
- **Don't rely on relative paths in `hosts.nix`** - They won't resolve correctly in Nix store

## WHY

The `df` function (`df = path: ./../../${path}`) works from the flake.nix location, but when passed through home-manager's sharedModules, the relative path context is lost. Use absolute paths or inline content in machine-specific configs.

## EXAMPLE

```nix
# In hosts.nix - CORRECT for most files
home.file = {
  "config.txt".source = /Users/mimifuwacc/dotfiles/config.txt;
  "inline.txt".text = "Direct content";
};

# In hosts.nix - CORRECT for frequently edited files (VSCode settings)
home.file."Library/Application Support/Code/User/settings.json".source =
  config.lib.file.mkOutOfStoreSymlink /Users/mimifuwacc/dotfiles/vscode/anemone/settings.json;

# In hosts.nix - AVOID
home.file = {
  "config.txt".source = df "config.txt";  # Path resolution fails
};
```

## VSCode Settings Management

For VSCode settings that you edit frequently, use `mkOutOfStoreSymlink`:

1. Place settings.json in `vscode/<hostname>/settings.json`
2. In `hosts.nix`:
   ```nix
   home.file."Library/Application Support/Code/User/settings.json".source =
     config.lib.file.mkOutOfStoreSymlink /Users/mimifuwacc/dotfiles/vscode/anemone/settings.json;
   ```
3. Remove existing settings.json before first apply: `rm ~/Library/Application Support/Code/User/settings.json`
4. Run `task apply`

**Benefits:**
- File stays in dotfiles, not copied to Nix store
- Edits take effect immediately without rebuilding
- Changes persist across Nix garbage collection

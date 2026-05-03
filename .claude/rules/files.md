# File Management Rules

Rules for handling file paths and the `df` function.

## DO

- **Use absolute paths in `hosts.nix`** - For `home.file`, use paths like `/Users/mimifuwacc/dotfiles/path/to/file`
- **Use `.text` attribute for simple content** - Instead of sourcing files, use `"file.txt".text = "content"`
- **Use `df` function in `_common/home.nix`** - It works correctly there for linking dotfiles

## DON'T

- **Don't use `df` function in `hosts.nix`** - Path resolution issues in shared modules context
- **Don't rely on relative paths in `hosts.nix`** - They won't resolve correctly in Nix store

## WHY

The `df` function (`df = path: ./../../${path}`) works from the flake.nix location, but when passed through home-manager's sharedModules, the relative path context is lost. Use absolute paths or inline content in machine-specific configs.

## EXAMPLE

```nix
# In hosts.nix - CORRECT
home.file = {
  "config.txt".source = /Users/mimifuwacc/dotfiles/config.txt;
  "inline.txt".text = "Direct content";
};

# In hosts.nix - AVOID
home.file = {
  "config.txt".source = df "config.txt";  # Path resolution fails
};
```

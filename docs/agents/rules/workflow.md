# Development workflow rules

Rules for development practices and code style.

## DO

- **Use `inherit` for passing arguments** - Explicitly list all required arguments in function signatures
- **Preserve environment variables** - The apply script handles `DOTFILES_USERNAME` and `DOTFILES_HOSTNAME` automatically
- **Keep username dynamic** - Retrieved from `DOTFILES_USERNAME` environment variable, not hardcoded

## DON'T

- **Don't hardcode username** - Always use the `DOTFILES_USERNAME` environment variable
- **Don't modify flake.lock manually** - Use `task apply:update` instead
- **Don't assume hostname case** - Always use lowercase for hostnames

## CODE STYLE

```nix
# CORRECT
mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
  specialArgs = {
    inherit username hostname dotfilesPath;
  };
};

# INCORRECT
mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
  specialArgs = {
    username = "mimifuwacc";  # Hardcoded!
  };
};
```

## FILE NAMING

- **Use kebab-case for files and directories you control** - e.g. `init-content.zsh`, `file-helpers.nix` — not `initContent.zsh`.
- **Exceptions: tool- or convention-mandated names** - Keep names dictated by tools or ecosystem convention as-is: `flake.nix`, `flake.lock`, `Taskfile.yaml`, `CLAUDE.md`, `README.md`, `hosts.nix`, `home.nix`, `settings.json`, `karabiner.json`, etc.

## USERNAME AUTO-DETECTION

The flake automatically retrieves username from the environment:
```nix
username = builtins.getEnv "DOTFILES_USERNAME";
```

This is set by `apply.sh` before running darwin-rebuild, so you don't need to hardcode it.

## FLAKE LOCK

Never edit `flake.lock` manually. To update dependencies:
```bash
task apply:update
```

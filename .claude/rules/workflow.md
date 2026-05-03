# Development Workflow Rules

Rules for development practices and code style.

## DO

- **Use `inherit` for passing arguments** - Explicitly list all required arguments in function signatures
- **Preserve environment variables** - The apply script handles `_USERNAME` and `_HOSTNAME` automatically
- **Keep username dynamic** - Retrieved from `_USERNAME` environment variable, not hardcoded

## DON'T

- **Don't hardcode username** - Always use the `_USERNAME` environment variable
- **Don't modify flake.lock manually** - Use `task apply:update` instead
- **Don't assume hostname case** - Always use lowercase for hostnames

## CODE STYLE

```nix
# CORRECT
mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
  specialArgs = {
    inherit username hostname df;
  };
};

# INCORRECT
mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
  specialArgs = {
    username = "mimifuwacc";  # Hardcoded!
  };
};
```

## USERNAME AUTO-DETECTION

The flake automatically retrieves username from the environment:
```nix
username = builtins.getEnv "_USERNAME";
```

This is set by `apply.sh` before running darwin-rebuild, so you don't need to hardcode it.

## FLAKE LOCK

Never edit `flake.lock` manually. To update dependencies:
```bash
task apply:update
```

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS (Darwin) dotfiles repository using Nix flakes for declarative system configuration. The setup uses nix-darwin for system-level configuration and home-manager for user-level configuration, targeting Apple Silicon (aarch64-darwin).

**Important**: See `.claude/rules/` for detailed rules when working with this repository.

## Quick Start

```bash
# Apply configuration for current machine
task apply

# Update dependencies and apply
task apply:update
```

## Architecture

### Directory Structure

```
dotfiles/
├── system/
│   └── darwin/
│       ├── _common/
│       │   ├── darwin.nix      # Common system configuration
│       │   ├── home.nix        # Common home configuration
│       │   └── apply.sh        # Common apply script
│       ├── anemone/
│       │   └── hosts.nix       # anemone-specific packages/files
│       ├── nemophila/
│       │   └── hosts.nix       # nemophila-specific packages/files
│       ├── flake.nix           # Unified flake for all machines
│       └── flake.lock
├── .claude/
│   ├── CLAUDE.md               # This file
│   └── rules/                  # Detailed rules by category
├── Taskfile.yaml               # Task commands
└── [other config files...]
```

### Key Design Principles

1. **Unified Flake**: Single `flake.nix` manages all machines
2. **Auto-Detection**: Username retrieved from `_USERNAME` environment variable
3. **Safety**: Hostname validation prevents cross-machine configuration
4. **Modularity**: Common settings in `_common/`, machine-specific in `<hostname>/`

## Commands

### System Configuration

```bash
task apply          # Apply configuration for current machine
task apply:update   # Update flake.lock and apply
```

### Development Environment

```bash
task dev:init       # Initialize devbox and direnv in current directory
```

### Direct Nix Commands (Debugging Only)

```bash
# Build without applying
darwin-rebuild build --flake ~/dotfiles/system/darwin#$(hostname -s | tr '[:upper:]' '[:lower:]') --impure

# Apply with explicit environment
sudo -E _USERNAME=$(whoami) _HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]') \
  darwin-rebuild switch --flake ~/dotfiles/system/darwin --impure
```

> **Note**: Use `task apply` for normal operations. Direct commands are for debugging only.

## Common Patterns

### Adding Machine-Specific Packages

Edit `<hostname>/hosts.nix`:

```nix
{ config, pkgs, lib, username, df, ... }:
{
  home.packages = with pkgs; [
    # Machine-specific packages
  ];

  home.file = {
    # Use absolute paths for reliability
    "config.txt".source = /Users/mimifuwacc/dotfiles/config.txt;
    "inline.txt".text = "Direct content";
  };
}
```

### Modifying Common Settings

- **System-level**: Edit `_common/darwin.nix`
- **User-level**: Edit `_common/home.nix`

> **Warning**: Changes to `_common/` affect all machines. Run `task apply` on each machine after modifying.

### The `df` Function

```nix
df "path/to/file"  # Resolves from dotfiles root
```

**Works in**:
- `_common/home.nix` for linking dotfiles
- `_common/darwin.nix` for system configs

**Avoid in**:
- `hosts.nix` for file paths (use absolute paths instead)

See `.claude/rules/files.md` for details.

### Adding a New Machine

1. Create directory: `system/darwin/<hostname>/`
2. Create `hosts.nix` with machine-specific config
3. Add to `flake.nix`:
   ```nix
   darwinConfigurations.<hostname> = mkDarwinSystem {
     hostname = "<hostname>";
     username = username;  # Auto-retrieved from env var
   };
   ```
4. Run `task apply` on the new machine

## Environment Variables

The apply script automatically sets:

- `_USERNAME` - Current username (from `whoami`)
- `_HOSTNAME` - Target hostname in lowercase

Preserved through sudo: `sudo --preserve-env=HOME,_USERNAME,_HOSTNAME`

## Troubleshooting

### Build Failures

**Check hostname:**
```bash
hostname -s | tr '[:upper:]' '[:lower:]'
```

**Verify environment variables:**
```bash
echo $_USERNAME $_HOSTNAME
```

**Update flake.lock:**
```bash
task apply:update
```

### Hostname Mismatch

```
Error: This configuration is for 'anemone', but current hostname is 'nemophila'
```

**Solution**: You're on the wrong machine. This is a safety feature.

### Path Resolution Issues

See `.claude/rules/files.md` for `df` function limitations and solutions.

## Shell & Tools

- **Zsh**: Autosuggestions, syntax highlighting, history substring search
- **Starship**: Custom prompt
- **eza**: Enhanced `ls` with git icons and relative timestamps
- **direnv** + nix-direnv: Per-directory environment management

Configuration linked from repository via home-manager.

## Related Documentation

- `.claude/rules/configuration.md` - Configuration management rules
- `.claude/rules/files.md` - File path and `df` function rules
- `.claude/rules/security.md` - Hostname validation and safety
- `.claude/rules/testing.md` - Testing and application procedures
- `.claude/rules/workflow.md` - Development workflow and code style

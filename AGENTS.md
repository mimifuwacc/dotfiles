# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS (Darwin) dotfiles repository using Nix flakes for declarative system configuration. The setup uses nix-darwin for system-level configuration and home-manager for user-level configuration, targeting Apple Silicon (aarch64-darwin).

**Important**: See `docs/agents/rules/` for detailed rules when working with this repository.

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
├── vscode/
│   ├── anemone/
│   │   └── settings.json      # VSCode settings for anemone
│   └── nemophila/
│       └── settings.json      # VSCode settings for nemophila
├── AGENTS.md                    # Main instructions for coding agents
├── CLAUDE.md -> AGENTS.md       # Claude Code compatibility
├── .claude -> docs/agents       # Claude Code rules compatibility
├── docs/agents/rules/           # Detailed rules by category
├── Taskfile.yaml               # Task commands
└── [other config files...]
```

### Key Design Principles

1. **Unified Flake**: Single `flake.nix` manages all machines
2. **Auto-Detection**: Username retrieved from `DOTFILES_USERNAME` environment variable
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
sudo -E DOTFILES_USERNAME=$(whoami) DOTFILES_HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]') \
  darwin-rebuild switch --flake ~/dotfiles/system/darwin --impure
```

> **Note**: Use `task apply` for normal operations. Direct commands are for debugging only.

## Common Patterns

### Adding Machine-Specific Packages

Edit `<hostname>/hosts.nix`:

```nix
{ config, pkgs, lib, username, dotfilesPath, ... }:
{
  home.packages = with pkgs; [
    # Machine-specific packages
  ];

  home.file = {
    "inline.txt".text = "Direct content";  # tiny inline content
  };
  # For repo files, use the storeCopies / liveSymlinks helpers from
  # _common/file-helpers.nix (see docs/agents/rules/files.md).
}
```

### Modifying Common Settings

- **System-level**: Edit `_common/darwin.nix`
- **User-level**: Edit `_common/home.nix`

> **Warning**: Changes to `_common/` affect all machines. Run `task apply` on each machine after modifying.

### The `dotfilesPath` Function

```nix
dotfilesPath "path/to/file"  # Resolves from the dotfiles repo root
```

`./../../` is anchored to `flake.nix`, so it resolves the same **from any
module**, including `hosts.nix` — it does not depend on the caller. For
`home.file` entries, prefer the `storeCopies` / `liveSymlinks` helpers (they use
`dotfilesPath` internally); call it directly mainly for `imports`.

See `docs/agents/rules/files.md` for details.

### Managing VSCode Settings

VSCode settings are managed per-machine using `mkOutOfStoreSymlink`:

1. Create `vscode/<hostname>/settings.json` with your VSCode configuration
2. Add to `<hostname>/hosts.nix`:
   ```nix
   home.file."Library/Application Support/Code/User/settings.json".source =
     config.lib.file.mkOutOfStoreSymlink /Users/mimifuwacc/dotfiles/vscode/anemone/settings.json;
   ```
3. Remove existing settings.json before first apply:
   ```bash
   rm ~/Library/Application Support/Code/User/settings.json
   ```
4. Run `task apply`

**Benefits**:
- File stays in dotfiles, not copied to Nix store
- Edits take effect immediately without rebuilding
- Changes persist across Nix garbage collection

**Example VSCode settings**:
```json
{
  "editor.tabSize": 2,
  "editor.formatOnSave": true
}
```

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

- `DOTFILES_USERNAME` - Current username (from `whoami`)
- `DOTFILES_HOSTNAME` - Target hostname in lowercase

Preserved through sudo: `sudo --preserve-env=HOME,DOTFILES_USERNAME,DOTFILES_HOSTNAME`

## Troubleshooting

### Build Failures

**Check hostname:**
```bash
hostname -s | tr '[:upper:]' '[:lower:]'
```

**Verify environment variables:**
```bash
echo $DOTFILES_USERNAME $DOTFILES_HOSTNAME
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

See `docs/agents/rules/files.md` for `dotfilesPath` function limitations and solutions.

## Shell & Tools

- **Zsh**: Autosuggestions, syntax highlighting, history substring search
- **Starship**: Custom prompt
- **eza**: Enhanced `ls` with git icons and relative timestamps
- **direnv** + nix-direnv: Per-directory environment management

Configuration linked from repository via home-manager.

## Related Documentation

- `docs/agents/rules/configuration.md` - Configuration management rules
- `docs/agents/rules/files.md` - File path and `dotfilesPath` function rules
- `docs/agents/rules/security.md` - Hostname validation and safety
- `docs/agents/rules/testing.md` - Testing and application procedures
- `docs/agents/rules/workflow.md` - Development workflow and code style

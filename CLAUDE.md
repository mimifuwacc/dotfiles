# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS (Darwin) dotfiles repository using Nix flakes for declarative system configuration. The setup uses nix-darwin for system-level configuration and home-manager for user-level configuration, targeting Apple Silicon (aarch64-darwin).

## Common Commands

### System Configuration

- `task darwin:apply` - Apply Nix configuration changes (equivalent to `darwin-rebuild switch --flake ~/dotfiles/nix/darwin --impure`)
- `task open:dotfiles` - Open this repository in VS Code

### Development Environment

- `task dev:init` - Initialize devbox and direnv in the current directory (runs `devbox init` and `devbox generate direnv -q`)

### Initial Setup

- `./init-darwin.sh` - Bootstrap script for fresh macOS installations (installs Xcode tools, Nix, and applies initial configuration)

### Direct Nix Commands

- `sudo darwin-rebuild switch --flake ~/dotfiles/nix/darwin --impure` - Manually apply system configuration
- `darwin-rebuild build --flake ~/dotfiles/nix/darwin --impure` - Build configuration without applying

## Architecture

### Configuration Layers

The configuration is split across three main files in [nix/darwin/](nix/darwin/):

1. **[flake.nix](nix/darwin/flake.nix)** - Defines flake inputs, outputs, and the system configuration builder. Uses environment variables `_USERNAME` and `_HOSTNAME` to dynamically configure the system for the current user/host.

2. **[darwin.nix](nix/darwin/darwin.nix)** - System-level configuration including:
   - System packages (vim, git)
   - Nix settings (automatic GC every 7 days, delete older than 30 days)
   - macOS defaults (Finder, Dock, keyboard mappings)
   - Caps Lock → Left Control key remapping
   - Touch ID for sudo authentication
   - 1Password GUI integration

3. **[home.nix](nix/darwin/home.nix)** - User-level configuration including:
   - Home packages (GUI apps, CLI tools, dev tools)
   - Shell configuration (Zsh with plugins, history, aliases)
   - Starship prompt
   - eza (ls replacement)
   - direnv + nix-direnv

### Custom Packages

Custom Nix packages are defined in [pkgs/](pkgs/):
- [pkgs/calex-code-jp/](pkgs/calex-code-jp/) - Japanese programming font
- [pkgs/notchnook/](pkgs/notchnook/) - Notch management utility (v1.5.5)
- [pkgs/unityhub/](pkgs/unityhub/) - Unity Hub (v3.16.2)

These are exposed via an overlay in `flake.nix` (lines 39-44).

### File Linking

Home Manager symlinks configuration files from the dotfiles repo to the home directory:
- [Taskfile.yaml](Taskfile.yaml) → `~/Taskfile.yaml`
- [git/darwin/.gitconfig](git/darwin/.gitconfig) → `~/.gitconfig`
- [wezterm/](wezterm/) → `~/.config/wezterm`
- [discord/](discord/) → `~/.config/discord`

### Environment Variables

The following environment variables are set in Zsh and required for Nix flake evaluation:
- `_USERNAME` - Current username (set to `$(whoami)`)
- `_HOSTNAME` - Current hostname (set to `$(hostname -s)`)

These must be preserved with `sudo --preserve-env=_USERNAME,_HOSTNAME` when running `darwin-rebuild`.

### Shell Configuration

The shell setup includes:
- **Zsh** with autosuggestions, syntax highlighting, and history substring search
- **zsh-nix-shell** plugin for better Nix shell integration
- **Starship** prompt with custom settings
- **eza** for enhanced `ls` with git icons and relative timestamps
- **direnv** with nix-direnv for per-directory environment management

### Terminal

Wezterm configuration is in [wezterm/wezterm.lua](wezterm/wezterm.lua) with a custom GitHub Dark theme in [wezterm/themes/github-dark.lua](wezterm/themes/github-dark.lua).

### Git

Git configuration includes GPG signing with 1Password integration (see [git/darwin/.gitconfig](git/darwin/.gitconfig)).

## Key Patterns

### Adding a New Package

1. For nixpkgs packages: Add to `home.packages` or `environment.systemPackages` in the appropriate `.nix` file
2. For custom packages: Create a new directory in [pkgs/](pkgs/) with a `default.nix`, then add it to the overlay in [flake.nix](nix/darwin/flake.nix:39-44)

### Applying Configuration Changes

After modifying any Nix files, run `task darwin:apply` to apply changes. The configuration is evaluated with the `--impure` flag to allow environment variable access.

### Development Workflow

This repo integrates with devbox and direnv for isolated development environments. Use `task dev:init` in a project directory to set up these tools automatically.

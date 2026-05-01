#!/bin/bash

set -euo pipefail

# Parse arguments
UPDATE=0
while [[ $# -gt 0 ]]; do
    case $1 in
        --update) UPDATE=1; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Get current hostname
TARGET_OS="Darwin"
HOSTNAME="anemone"

USERNAME=$(whoami)

FLAKE_DIR="/Users/$USERNAME/dotfiles/system/anemone"

# Check if running on target OS
if [[ "$(uname)" != "$TARGET_OS" ]]; then
    echo "Error: This script is only for $TARGET_OS"
    exit 1
fi

# Check required tools
if ! command -v nix &> /dev/null; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if ! command -v xcode-select &> /dev/null || ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete the Xcode installation, then run this script again."
    exit 0
fi

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update flake.lock if --update flag is set
if [[ $UPDATE -eq 1 ]]; then

    sudo chown -R "$(whoami):staff" "/Users/$USERNAME/dotfiles/.git"
    sudo chown "$(whoami):staff" "$FLAKE_DIR/flake.lock" 2>/dev/null || true
    nix flake update --flake "$FLAKE_DIR"
fi

# Apply configuration
sudo --preserve-env=HOME,_USERNAME,_HOSTNAME darwin-rebuild switch --flake "$FLAKE_DIR" --impure

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
HOSTNAME=$(hostname -s)
USERNAME=$(whoami)

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
	echo "Error: This script is only for macOS (Darwin)"
	exit 1
fi

FLAKE_DIR="/Users/$USERNAME/dotfiles/system/anemone"

# Update flake.lock if --update flag is set
if [[ $UPDATE -eq 1 ]]; then
	echo "Updating flake.lock for $HOSTNAME..."
	sudo chown -R "$(whoami):staff" "/Users/$USERNAME/dotfiles/.git"
	sudo chown "$(whoami):staff" "$FLAKE_DIR/flake.lock" 2>/dev/null || true
	nix flake update --flake "$FLAKE_DIR"
fi

# Apply configuration
echo "Applying Nix configuration for $HOSTNAME..."
sudo --preserve-env=HOME,_USERNAME,_HOSTNAME darwin-rebuild switch --flake "$FLAKE_DIR" --impure

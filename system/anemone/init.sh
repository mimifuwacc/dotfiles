#!/bin/bash
set -euo pipefail

if ! command -v xcode-select &> /dev/null || ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete the Xcode installation, then run this script again."
    exit 0
fi

if ! command -v nix &> /dev/null; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

export _USERNAME=$(whoami)
export _HOSTNAME=$(hostname -s)
export FLAKE_DIR="/Users/$_USERNAME/dotfiles/system/anemone"
sudo -H --preserve-env=_USERNAME,_HOSTNAME darwin-rebuild switch --flake "$FLAKE_DIR" --impure

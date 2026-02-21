#!/bin/bash
set -euo pipefail

if ! command -v xcode-select &> /dev/null || ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete the Xcode installation, then run this script again."
    exit 0
fi

if ! command -v nix &> /dev/null; then
    curl -fsSL https://install.determinate.systems/nix | sh
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

export _USERNAME=$(whoami)
export _HOSTNAME=$(hostname -s)
sudo --preserve-env=_USERNAME,_HOSTNAME nix run nix-darwin/master#darwin-rebuild -- switch --flake ./nix/darwin/ --impure

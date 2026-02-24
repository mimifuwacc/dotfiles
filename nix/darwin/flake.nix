{
  description = "Darwin system flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, nix-darwin, home-manager, wezterm, brew-nix, brew-api }:
    let
      # Get the username and hostname from environment variables
      darwinUser = builtins.getEnv "_USERNAME";
      darwinHost = builtins.getEnv "_HOSTNAME";

      # full path to a dotfiles, e.g. "/Users/username/dotfiles/zsh/.zshrc"
      dotfilesPath = path: "/Users/${darwinUser}/dotfiles/${path}";

      mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            networking.hostName = hostname;
            users.users.${username}.home = "/Users/${username}";
            home-manager.useUserPackages = true;
            home-manager.users.${username} = { pkgs, lib, ... }:
              import ./home.nix { inherit pkgs lib username wezterm dotfilesPath; };
            home-manager.sharedModules = [
              {
                nixpkgs.overlays = [
                  brew-nix.overlays.default
                  (final: prev: {
                    calex-code-jp = prev.callPackage (dotfilesPath "pkgs/calex-code-jp/default.nix") { };
                  })
                ];
              }
            ];
          }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          inherit username wezterm dotfilesPath;
        };
      };
    in {
      darwinConfigurations.${darwinHost} = mkDarwinSystem {
        hostname = darwinHost;
        username = darwinUser;
      };
    };
}

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
  };
  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      # Get the username and hostname from environment variables
      darwinUser = builtins.getEnv "_USERNAME";
      darwinHost = builtins.getEnv "_HOSTNAME";

      # relative path from flake dir to dotfiles root, then to the target path
      df = path: ./../../${path};

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
              import ./home.nix { inherit pkgs lib username df; };
            home-manager.sharedModules = [
              {
                nixpkgs.overlays = [
                  (final: prev: {
                    calex-code-jp = prev.callPackage (df "fonts/calex-code-jp/default.nix") { };
                  })
                ];
              }
            ];
          }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          inherit username df;
        };
      };
    in {
      darwinConfigurations.${darwinHost} = mkDarwinSystem {
        hostname = darwinHost;
        username = darwinUser;
      };
    };
}

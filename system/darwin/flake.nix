{
  description = "Darwin system flake for multiple machines";
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
      lib = nixpkgs.lib;

      # Get username from environment variable
      username = builtins.getEnv "_USERNAME";

      # relative path from darwin dir to dotfiles root
      df = path: ./../../${path};

      mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./_common/darwin.nix
          ./${hostname}/hosts.nix
          home-manager.darwinModules.home-manager
          {
            networking.hostName = hostname;
            users.users.${username}.home = "/Users/${username}";
            home-manager.useUserPackages = true;
            home-manager.users.${username} = { pkgs, lib, ... }:
              import ./_common/home.nix { inherit pkgs lib username hostname df; };
            home-manager.sharedModules = [
              {
                _module.args = {
                  inherit lib username hostname df;
                };
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
          inherit username hostname df;
        };
      };
    in {
      darwinConfigurations.anemone = mkDarwinSystem {
        hostname = "anemone";
        username = username;
      };
      darwinConfigurations.nemophila = mkDarwinSystem {
        hostname = "nemophila";
        username = username;
      };
    };
}

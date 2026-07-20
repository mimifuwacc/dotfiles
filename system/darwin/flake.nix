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
      username = builtins.getEnv "DOTFILES_USERNAME";

      # relative path from darwin dir to dotfiles root
      dotfilesPath = path: ./../../${path};

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
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = { pkgs, lib, config, ... }:
              import ./_common/home.nix { inherit pkgs lib config username hostname dotfilesPath; };
            home-manager.sharedModules = [
              {
                _module.args = {
                  inherit lib username hostname dotfilesPath;
                };
                nixpkgs.overlays = [
                  (final: prev: {
                    calex-code-jp = prev.callPackage (dotfilesPath "fonts/calex-code-jp/default.nix") { };
                    prompt-glyph = prev.callPackage (dotfilesPath "fonts/prompt-glyph/default.nix") { };
                  })
                  # Skip OCI setuid-mode test that fails under the Nix sandbox.
                  # The sandbox cannot preserve the setuid bit, so the test sees
                  # 0o755 instead of the expected 0o4755.
                  # See: https://github.com/jdx/mise/discussions/10617
                  (final: prev: {
                    mise = prev.mise.overrideAttrs (old: {
                      cargoCheckFlags = (old.cargoCheckFlags or [ ]) ++ [
                        "--skip=oci::layer::tests::preserve_metadata_dir_layer_keeps_special_permission_bits"
                      ];
                    });
                  })
                ];
              }
            ];
          }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          inherit username hostname dotfilesPath;
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

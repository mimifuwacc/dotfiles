{ pkgs, lib, config, username, dotfilesPath, ... }:

let
  # Shared home.file helpers, written as { "target" = "repo/path"; ... }.
  inherit (import ./file-helpers.nix { inherit lib config username dotfilesPath; })
    storeCopies liveSymlinks;
in
{
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  targets.darwin.linkApps.enable = true;

  home.packages = with pkgs; [
    # Nix tools
    nh

    # Cli tools
    neovim
    git
    gh
    fzf
    fastfetch

    # Fonts
    calex-code-jp
    nerd-fonts.hack
    prompt-glyph

    # Dev tools
    uv
    devbox
    claude-code
  ];

  # dotfiles
  home.file =
    # Rarely edited: keep reproducible + rollback-able via the Nix store.
    storeCopies {
      "Taskfile.yaml" = "go-task/Taskfile.yaml";
      ".gitconfig" = "git/darwin.gitconfig";
      ".config/git/ignore" = "git/darwin.ignore";
    }
    # Frequently edited: live symlink so changes take effect immediately.
    // liveSymlinks {
      ".config/nvim/init.lua" = "nvim/init.lua";
      ".config/nvim/lua" = "nvim/lua";
      ".config/karabiner/karabiner.json" = "karabiner/karabiner.json";
      ".config/ghostty/config" = "ghostty/config";
    };

    # cleanup old files
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d --keep-one";
      };
    };


  imports = [
    # Import default packages
    (dotfilesPath "packages/default.nix")

    # Import zsh configuration
    (dotfilesPath "zsh/default.nix")
  ];
}

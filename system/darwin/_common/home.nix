{ pkgs, lib, username, df, ... }:

let
  # Helper function to create forced dotfile entries
  mkDotfile = path: { source = df path; force = true; };
in
{
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  targets.darwin.linkApps.enable = true;

  home.packages = with pkgs; [
    # Cli tools
    neovim
    git
    gh
    fzf
    fastfetch

    # Fonts
    calex-code-jp
    nerd-fonts.hack

    # Dev tools
    uv
    devbox
    claude-code
  ];

  # dotfiles
  home.file = {
    "Taskfile.yaml" = mkDotfile "Taskfile.yaml";
    ".gitconfig" = mkDotfile "git/darwin.gitconfig";
    ".config/git/ignore" = mkDotfile "git/darwin.ignore";
    ".config/nvim/init.lua" = mkDotfile "nvim/init.lua";
    ".config/nvim/lua" = mkDotfile "nvim/lua";
    ".config/karabiner/karabiner.json" = mkDotfile "karabiner/karabiner.json";
    ".config/ghostty/config" = mkDotfile "ghostty/config";
  };

  imports = [
    # Import default packages
    (df "packages/default.nix")

    # Import zsh configuration
    (df "zsh/default.nix")
  ];
}

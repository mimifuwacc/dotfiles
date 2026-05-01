{ pkgs, lib, username, wezterm, df, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  targets.darwin.linkApps.enable = true;

  home.packages = [
    # Cli tools
    pkgs.neovim
    pkgs.git
    pkgs.fzf
    pkgs.fastfetch

    # Joke tools
    pkgs.gti
    pkgs.sl
    pkgs.cowsay
    pkgs.cmatrix

    # Fonts
    pkgs.calex-code-jp
    pkgs.nerd-fonts.hack

    # Dev tools
    pkgs.uv
    pkgs.devbox
    pkgs.claude-code
  ];

  # dotfiles
  home.file = {
    "Taskfile.yaml".source = df "Taskfile.yaml";
    ".gitconfig".source = df "git/anemone.gitconfig";
    ".config/git/ignore".source = df "git/anemone.ignore";
    ".config/nvim/init.lua".source = df "nvim/init.lua";
    ".config/nvim/lua".source = df "nvim/lua";

    ".config/karabiner/karabiner.json" = {
      source = df "karabiner/karabiner.json";
      force = true;
    };
    ".config/ghostty/config" = {
      source = df "ghostty/config";
      force = true;
    };
  };

  imports = [
    # Import default packages
    (df "packages/default.nix")

    # Import zsh configuration
    (df "zsh/default.nix")
  ];
}

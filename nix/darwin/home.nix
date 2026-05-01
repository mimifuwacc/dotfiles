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
    pkgs.devbox
    pkgs.claude-code
  ];

  # dotfiles
  home.file = {
    "Taskfile.yaml".source = df "Taskfile.yaml";
    ".gitconfig".source = df "git/darwin/.gitconfig";
    ".config/git/ignore".source = df "git/darwin/ignore";
    ".config/ghostty/config" = {
      source = df "ghostty/config";
      force = true;
    };
    ".config/nvim/init.lua".source = df "nvim/init.lua";
    ".config/nvim/lua".source = df "nvim/lua";
    ".config/karabiner/karabiner.json" = {
      source = df "karabiner/karabiner.json";
      force = true;
    };
  };

  imports = [
    # Import zsh configuration
    (df "zsh/default.nix")
  ];
}

{ pkgs, lib, username, df, ... }:

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
    "Taskfile.yaml".source = df "Taskfile.yaml";
    ".gitconfig".source = df "git/darwin.gitconfig";
    ".config/git/ignore".source = df "git/darwin.ignore";
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

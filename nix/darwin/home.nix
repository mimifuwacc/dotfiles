{ pkgs, lib, username, wezterm, dotfilesPath, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  targets.darwin.linkApps.enable = true;

  home.packages = [
    # wezterm@nightly
    wezterm.packages.${pkgs.system}.default

    # Task runner
    pkgs.go-task

    # Plugins and tools for zsh
    pkgs.zsh-defer
    pkgs.zsh-syntax-highlighting
    pkgs.zsh-autosuggestions
    pkgs.starship
    pkgs.eza
    pkgs.fastfetch

    # GUI Applications
    pkgs.google-chrome
    pkgs.vscode
    pkgs.discord

    # macOS utilities
    pkgs.shottr
    pkgs.raycast
    pkgs.rectangle

    # Fonts
    pkgs.calex-code-jp
    pkgs.nerd-fonts.hack

    # Dev tools
    pkgs.claude-code
    pkgs.orbstack
  ];

  home.file = {
    "Taskfile.yaml".source = dotfilesPath "Taskfile.yaml";
    ".gitconfig".source = dotfilesPath "git/darwin/.gitconfig";

    ".config/wezterm".source = dotfilesPath "wezterm";
    ".config/starship.toml".source = dotfilesPath "starship/starship.toml";

    ".config/discord".source = dotfilesPath "discord";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      size = 100000;
      save = 100000;
      path = "$HOME/.zsh_history";
      share = true;
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      saveNoDups = true;
    };

    historySubstringSearch = {
      enable = true;
      searchUpKey = ["^P"];
      searchDownKey = ["^N"];
    };

    shellAliases = {
      ls = "eza --icons --git --time-style relative";
      vim = "nvim";
      ssh = "TERM=xterm ssh";
      ccusage = "bunx ccusage@latest";
    };

    initContent = ''
      # Environment variables
      export _USERNAME=$(whoami)
      export _HOSTNAME=$(hostname -s)

      # Starship prompt
      if type starship &>/dev/null; then
        eval "$(starship init zsh)"
      fi

      # Direnv
      if type direnv &>/dev/null; then
        eval "$(direnv hook zsh)"
      fi

      # Plugins with zsh-defer
      source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };
}

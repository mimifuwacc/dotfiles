{ pkgs, lib, username, wezterm, dotfilesPath, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.go-task
    wezterm.packages.${pkgs.system}.default
    pkgs.google-chrome
    pkgs.vscode
    pkgs.discord
    pkgs.starship
    pkgs.eza
    pkgs.shottr
    pkgs.raycast
    pkgs.discord
    pkgs.nodejs_24
    pkgs.rectangle
    pkgs.calex-code-jp
    pkgs.nerd-fonts.hack
    pkgs.rectangle
    pkgs.fastfetch
    pkgs.claude-code
    pkgs.orbstack
    pkgs.zsh-defer
    pkgs.zsh-syntax-highlighting
    pkgs.zsh-autosuggestions
  ];

  home.file = {
    "Taskfile.yaml".source = dotfilesPath "Taskfile.yaml";
    ".config/discord".source = dotfilesPath "discord";
    ".config/wezterm".source = dotfilesPath "wezterm";
    ".config/starship.toml".source = dotfilesPath "starship/starship.toml";
    ".gitconfig".source = dotfilesPath "git/darwin/.gitconfig";
  };

  targets.darwin.linkApps.enable = true;
  programs.home-manager.enable = true;

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
      zsh-defer ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      zsh-defer ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };
}

{ pkgs, lib, username, wezterm, dotfilesPath, ... }:

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
    "Taskfile.yaml".source = dotfilesPath "Taskfile.yaml";
    ".gitconfig".source = dotfilesPath "git/darwin/.gitconfig";
    ".config/git/ignore".source = dotfilesPath "git/darwin/ignore";
    ".config/ghostty/config" = {
      source = dotfilesPath "ghostty/config";
      force = true;
    };
    ".config/nvim/init.lua".source = dotfilesPath "nvim/init.lua";
    ".config/nvim/lua".source = dotfilesPath "nvim/lua";
    ".config/karabiner/karabiner.json" = {
      source = dotfilesPath "karabiner/karabiner.json";
      force = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];

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
      vim = "nvim";
      ssh = "TERM=xterm ssh";
    };

    sessionVariables = {
      _USERNAME = "$(whoami)";
      _HOSTNAME = "$(hostname -s)";
    };

    initContent = ''
      # brew PATH
      if [ -d /opt/homebrew ]; then
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      fi
      eval "$(direnv hook zsh)"
      source <(fzf --zsh)
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
      };
      package.disabled = true;
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    enableZshIntegration = true;
    extraOptions = [
      "--git"
      "--time-style=relative"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      hide_env_diff = true;
    };
  };
}

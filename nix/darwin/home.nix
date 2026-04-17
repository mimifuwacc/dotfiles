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

    # Joke tools
    pkgs.gti
    pkgs.sl
    pkgs.cowsay

    # Task runner
    pkgs.go-task

    # Cli tools
    pkgs.neovim
    pkgs.fzf

    pkgs.subversion

    pkgs.karabiner-elements

    # Fonts
    pkgs.calex-code-jp
    pkgs.nerd-fonts.hack

    # Dev tools
    pkgs.devbox
    pkgs.fastfetch
    pkgs.claude-code
    pkgs.orbstack
    pkgs.uv
    pkgs.vscode

    # Casks
    (pkgs.brewCasks.unity-hub.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-jQ6svEXqgL3sgXywd/E44uX5Sdl6lBc70nvq9DMROSQ=";
      };
    }))

    pkgs.brewCasks.shottr
    pkgs.brewCasks.raycast
    pkgs.brewCasks.rectangle
    pkgs.brewCasks.notchnook

    pkgs.brewCasks.osu
  ];

  # dotfiles
  home.file = {
    "Taskfile.yaml".source = dotfilesPath "Taskfile.yaml";
    ".gitconfig".source = dotfilesPath "git/darwin/.gitconfig";
    ".config/git/ignore".source = dotfilesPath "git/darwin/ignore";

    ".config/wezterm".source = dotfilesPath "wezterm";
    ".config/nvim/init.lua".source = dotfilesPath "nvim/init.lua";
    ".config/nvim/lua".source = dotfilesPath "nvim/lua";
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
      ccusage = "bunx ccusage@latest";
      "花譜です！始めます！" = "yarn";
    };

    sessionVariables = {
      _USERNAME = "$(whoami)";
      _HOSTNAME = "$(hostname -s)";
    };

    initContent = ''
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

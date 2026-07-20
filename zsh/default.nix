{ pkgs, lib, ... }:
let
  toolsDir = ./tools;
  toolFiles = lib.filesystem.listFilesRecursive toolsDir;
  toolsContent = lib.concatMapStrings builtins.readFile toolFiles;

  # The prompt symbols live in a Private Use Area and render as tofu in an
  # editor, so decode them from their codepoints rather than pasting the raw
  # characters. Ghostty maps them to the `prompt-glyph` font (see
  # ghostty/config); anywhere else they show as a missing glyph.
  #
  # JSON escapes are 16 bit, so a codepoint past the BMP -- which these are, to
  # stay clear of the ranges Ghostty reshapes as Nerd Font icons -- has to be
  # written as a surrogate pair.
  puaChar = codepoint:
    let
      toHex4 = n: lib.toLower (lib.fixedWidthString 4 "0" (lib.toHexString n));
      v = codepoint - 65536;
      escape =
        if codepoint < 65536
        then ''\u${toHex4 codepoint}''
        else ''\u${toHex4 (55296 + (v / 1024))}\u${toHex4 (56320 + (lib.mod v 1024))}'';
    in
    builtins.fromJSON ''"${escape}"'';
in
{
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
      DOTFILES_USERNAME = "$(whoami)";
      DOTFILES_HOSTNAME = "$(hostname -s)";
    };

    initContent = builtins.readFile ./init-content.zsh + "\n" + toolsContent;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        # Deliberately unstyled. The glyphs are colour bitmaps, so a colour here
        # would be ignored anyway -- the same way an emoji cannot be recoloured.
        # Bold is skipped for the same reason it was never useful: the font
        # ships a single weight, so it could only ever be synthesised (smeared)
        # rather than picking up a real bold face.
        #
        # The trailing space is part of the symbol so the typed command does not
        # sit flush against the glyph.
        success_symbol = "${puaChar 1048576} "; # U+100000
        error_symbol = "${puaChar 1048577} "; # U+100001
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

{ config, pkgs, lib, username, df, nix-latex, ... }:

{
  # Custom taps for machine-specific casks
  homebrew.taps = [
    {
      name = "mimifuwacc/homebrew-tap";
      trusted = true;
    }
  ];

  # Machine-specific homebrew casks
  homebrew.casks = [
    "discord"
    "1password"
    "google-chrome"
    "zotero"
    "caffeine"
    "slidepilot"
    "tailscale-app"
    "cloudflare-warp"

    "google-chrome"

    "font-genjyuugothic"
    "microsoft-word"
    "microsoft-powerpoint"

    "steam"

    # mimifuwacc/homebrew-tap
    "adderall"
    "wallpaper-manager"
  ];

  # Adderall is ad-hoc signed (not notarized). After Homebrew installs it,
  # strip the quarantine flag so it opens without the Gatekeeper prompt.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if [ -d /Applications/Adderall.app ]; then
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Adderall.app || true
    fi
    if [ -d /Applications/WallpaperManager.app ]; then
      /usr/bin/xattr -dr com.apple.quarantine /Applications/WallpaperManager.app || true
    fi
  '';

  # Home-manager configuration
  home-manager.users.${username} = { config, ... }: {
    home.packages = with pkgs; [
      nix-latex.packages.${pkgs.system}.default

      # Joke tools
      gti
      sl
      cowsay
      cmatrix

      mise
      nodejs_24
      gnumake
    ];

    home.file.".latexmkrc".source = df /latex/.latexmkrc;
    home.file.".config/latexindent/latexindent.yaml".source = df /latex/latexindent.yaml;

    # VSCode settings
    home.file."Library/Application Support/Code/User/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink /Users/${username}/dotfiles/vscode/anemone/settings.json;
      force = true;
    };

    programs.zsh.initContent = ''
      eval "$(mise activate zsh)"
    '';
  };
}

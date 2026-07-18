{ config, pkgs, lib, username, dotfilesPath, nix-latex, ... }:

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
    "1password"
    "discord"
    "google-chrome"

    "tailscale-app"
    "cloudflare-warp"

    "google-chrome"

    "font-genjyuugothic"

    "microsoft-word"
    "microsoft-excel"
    "microsoft-powerpoint"

    "steam"
    "prismlauncher"
    "minecraft"
    "porting-kit"
    "unity"

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
  home-manager.users.${username} = { config, lib, ... }:
  let
    inherit (import ../_common/file-helpers.nix { inherit lib config username dotfilesPath; })
      storeCopies liveSymlinks;
  in
  {
    home.packages = with pkgs; [
      nix-latex.packages.${pkgs.system}.default

      # Joke tools
      gti
      sl
      cowsay
      cmatrix

      mise
    ];

    home.file =
      storeCopies {
        ".latexmkrc" = "latex/.latexmkrc";
        ".config/latexindent/latexindent.yaml" = "latex/latexindent.yaml";
      }
      // liveSymlinks {
        "Library/Application Support/Code/User/settings.json" = "vscode/anemone/settings.json";
      };

    programs.zsh.initContent = ''
      eval "$(mise activate zsh)"
    '';
  };
}

{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    kanata
  ];

  nix.enable = false;

  nix.settings.gc = {
    automatic = true;
    interval = [ { Day = 7; } ];
    options = "--delete-older-than 30d";
  };

  system.primaryUser = username;
  nix.package = pkgs.nix;

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
  };

  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    tilesize = 40;
    magnification = true;
    largesize = 100;
    orientation = "bottom";
    mineffect = "scale";
  };

  system.stateVersion = 4;

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation.cleanup = "none";
    taps = [];
    brews = [];
    casks = [
      "raycast"
      "shottr"
      "visual-studio-code"
      "1password"
      "karabiner-elements"
      "discord"
      "ghostty"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}

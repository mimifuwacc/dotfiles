{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
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

  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping =
      let
        mkKeyMapping =
          let
            hexToInt = s: pkgs.lib.trivial.fromHexString s;
          in
          src: dst: {
            HIDKeyboardModifierMappingSrc = hexToInt src;
            HIDKeyboardModifierMappingDst = hexToInt dst;
          };
        capsLock = "0x700000039";
        leftCtrl = "0x7000000E0";
      in
      [
        (mkKeyMapping capsLock leftCtrl)
      ];
  };

  system.stateVersion = 4;

  programs._1password-gui = {
    enable = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
}

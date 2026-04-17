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

  # Kanata keyboard remapper
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.kanata}/bin/kanata" "--cfg" "/etc/kanata.kbd" ];
      KeepAlive = true;
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.err";
    };
  };

  environment.etc."kanata.kbd".text = ''
    (defsrc caps)
    (deflayer default lctl)
  '';

  system.stateVersion = 4;

  programs._1password-gui.enable = true;
  system.defaults.CustomUserPreferences = {
    "com.google.Keystone.Agent" = {
      checkInterval = 0;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
}

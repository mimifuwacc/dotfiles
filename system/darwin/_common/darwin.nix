{ pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    # System-level packages only (not for user commands)
  ];

  system.activationScripts.preActivation.text = ''if [ -f /etc/nix/nix.conf ]; then mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin || true; fi'';

  nix.settings.experimental-features = "nix-command flakes";

  nix.gc = {
    automatic = true;
    interval = { Day = 7; };
    options = "--delete-older-than 30d";
  };

  system.primaryUser = username;
  nix.package = pkgs.nix;

  # Disable documentation to fix derivation warning
  documentation.enable = false;

  nixpkgs.config.allowUnfree = true;

  ids.gids.nixbld = 350;

  # Environment variables
  environment.variables = {
    EDITOR = "nvim";
    LANG = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";
  };

  system.stateVersion = 4;

  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;

  # Finder
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
    ShowStatusBar = false;
    _FXSortFoldersFirst = true;
    FXDefaultSearchScope = "SCcf";  # Current folder
  };

  # Dock
  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    tilesize = 40;
    magnification = true;
    largesize = 100;
    orientation = "bottom";
    mineffect = "scale";
    wvous-br-corner = 14;
  };

  # Global settings
  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyle = "Dark";
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    ApplePressAndHoldEnabled = false;
    AppleScrollerPagingBehavior = true;
    "com.apple.keyboard.fnState" = true;
    "com.apple.springing.enabled" = true;
    "com.apple.springing.delay" = 0.5;
    "com.apple.swipescrolldirection" = true;
    "com.apple.trackpad.forceClick" = true;
    "com.apple.trackpad.scaling" = 1.5;
  };

  # Control Center
  system.defaults.controlcenter = {
    Sound = true;
    BatteryShowPercentage = true;
  };

  # Trackpad
  system.defaults.trackpad = {
    ActuationStrength = 0;
    FirstClickThreshold = 1;
    SecondClickThreshold = 1;
  };

  # Custom preferences
  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "64" = { enabled = 0; };   # Cmd+Space (Spotlight)
        "65" = { enabled = 0; };   # Cmd+Option+Space (Spotlight)
      };
    };
    "NSGlobalDomain" = {
      NSWindowResizeTime = 0.1;    # Faster window animations
      NSNavPanelExpandedStateForSaveMode = true;  # Expanded save dialogs
      NSNavPanelExpandedStateForSaveMode2 = true;
    };
    "com.apple.HIToolbox" = {
      AppleEnabledInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 252;
          "KeyboardLayout Name" = "ABC";
        }
        {
          "Bundle ID" = "dev.ensan.inputmethod.azooKeyMac";
          InputSourceKind = "Non Keyboard Input Method";
        }
      ];
    };
  };

  # use brew to install GUI applications
  homebrew = {
    enable = true;
    onActivation = {
    cleanup = "uninstall";
    autoUpdate = true;
    upgrade = true;
  };
    casks = [
      "raycast"
      "shottr"
      "visual-studio-code"
      "1password"
      "karabiner-elements"
      "ghostty"
      "orbstack"
      "google-chrome"
      "azooKey"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}

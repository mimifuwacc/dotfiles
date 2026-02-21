{ pkgs, lib, username, wezterm, dotfilesPath, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.go-task
    wezterm.packages.${pkgs.system}.default
    pkgs.google-chrome
    pkgs.vscode
    pkgs.discord
    pkgs.sheldon
    pkgs.starship
    pkgs.eza
    pkgs.shottr
    pkgs.raycast
    pkgs.discord
    pkgs.nodejs_24
    pkgs.rectangle
    pkgs.calex-code-jp
    pkgs.nerd-fonts.hack
    pkgs.fastfetch
  ];

  home.file = {
    "Taskfile.yaml".source = dotfilesPath "Taskfile.yaml";
    ".zshrc".source = dotfilesPath "zsh/.zshrc";
    ".config/discord".source = dotfilesPath "discord";
    ".config/wezterm".source = dotfilesPath "wezterm";
    ".config/sheldon".source = dotfilesPath "sheldon";
    ".config/starship.toml".source = dotfilesPath "starship/starship.toml";
    ".gitconfig".source = dotfilesPath "git/darwin.gitconfig";
  };

  targets.darwin.copyApps.enable = true;
  programs.home-manager.enable = true;
}

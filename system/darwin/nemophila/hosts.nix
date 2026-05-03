{ config, pkgs, lib, username, df, ... }:

{
  # Machine-specific homebrew casks (add nemophila-specific casks here)
  homebrew.casks = [
  ];

  # Home-manager configuration
  home-manager.users.${username} = { config, ... }: {
    home.packages = with pkgs; [
    ];
  };
}

{ pkgs, ... }:
{
  home.packages = [
    # Default tools for dotfiles
    pkgs.go-task
  ];
}

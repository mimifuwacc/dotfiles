{ config, pkgs, lib, username, df, ... }:

{
  home.packages = with pkgs; [
    gti
    sl
    cowsay
    cmatrix
  ];
}

{ config, pkgs, lib, username, df, ... }:

{
  home.packages = with pkgs; [
    # TeX Live packages
    (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        collection-basic
        collection-fontsrecommended
        collection-langcjk
        collection-langjapanese
        collection-latex
        collection-latexextra
        collection-latexrecommended
        collection-mathscience
        collection-pictures
        latexmk;
    })
    ghostscript
    gnuplot

    # Joke tools
    gti
    sl
    cowsay
    cmatrix
  ];

  home.file.".latexmkrc".source = /Users/mimifuwacc/dotfiles/latex/.latexmkrc;
}

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

  home.file.".latexmkrc".source = df /latex/.latexmkrc;

  # VSCode settings
  home.file."Library/Application Support/Code/User/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink /Users/${username}/dotfiles/vscode/anemone/settings.json;
    force = true;
  };
}

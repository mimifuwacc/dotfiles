{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "calex-code-jp";
  version = "unstable-2023-11-16";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/yknishidate/CalexCodeJP/main/CalexCodeJP.otf";
    hash = "sha256-BHf1RtViHMNkcMUW/9ntRRGmwH3UupSEVcVYIgXY6sI=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/share/fonts/opentype/CalexCodeJP.otf

    runHook postInstall
  '';

  meta = {
    description = "Calex Code JP is a programming font for Japanese";
    homepage = "https://github.com/yknishidate/CalexCodeJP";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}

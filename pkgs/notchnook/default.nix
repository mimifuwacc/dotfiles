{
  lib,
  stdenvNoCC,
  fetchzip,
  sourcesFile,
}:

let
  sources = builtins.fromJSON (builtins.readFile sourcesFile);
in
stdenvNoCC.mkDerivation rec {
  pname = "notchnook";
  inherit (sources) version;

  src = fetchzip {
    inherit (sources) url hash;
  };

  nativeBuildInputs = [ ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r $src $out/Applications/NotchNook.app

    runHook postInstall
  '';

  meta = {
    description = "a whole new way, full of possibilities of using your macos notch";
    homepage = "https://notchnook.com";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    maintainers = [ ];
  };
}

{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "notchnook";
  version = "1.5.5";

  src = fetchzip {
    url = "https://notchnook.com/releases/NotchNook-${version}.zip";
    hash = "sha256-7nVl8yBX2w27ZHzro0ow8qYRgfd1197/Sazr9vWooOc=";
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

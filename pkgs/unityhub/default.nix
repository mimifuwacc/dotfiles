{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation rec {
  pname = "unityhub";
  version = "3.16.2";

  src = fetchurl {
    url = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-arm64.dmg";
    hash = "sha256-fR/m85eG7gE7M2tIA2RhwO7DRmRY9bvA2SvRuHlOz3g=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Unity\ Hub.app $out/Applications/Unity\ Hub.app

    runHook postInstall
  '';

  meta = {
    description = "Unity Hub is a standalone application that manages your Unity installations and projects";
    homepage = "https://unity.com/download";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    maintainers = [ ];
  };
}

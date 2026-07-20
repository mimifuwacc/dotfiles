{
  lib,
  stdenvNoCC,
  python3,
}:

stdenvNoCC.mkDerivation {
  pname = "prompt-glyph";
  version = "1.0.0";

  # Only the build inputs, never the whole directory: uv leaves a .venv here
  # when build-font.py is iterated on locally, and that must not reach the store.
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./build-font.py
      ./glyph-success.bmp
      ./glyph-error.bmp
    ];
  };

  # pyproject.toml / uv.lock pin fonttools for local runs, but the build sandbox
  # has no network, so the Nix build takes fonttools from nixpkgs instead.
  nativeBuildInputs = [ (python3.withPackages (ps: [ ps.fonttools ps.pillow ])) ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    python build-font.py . PromptGlyphs-Regular.ttf

    runHook postBuild
  '';

  # TrueType flavoured, because the sbix colour bitmaps that Ghostty needs are
  # an Apple table that pairs with glyf.
  installPhase = ''
    runHook preInstall

    install -Dm444 PromptGlyphs-Regular.ttf \
      $out/share/fonts/truetype/PromptGlyphs-Regular.ttf

    runHook postInstall
  '';

  meta = {
    description = "Colour private-use-area glyphs (U+E000/U+E001) for the Starship prompt";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}

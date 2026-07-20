# prompt-glyph

A tiny colour font holding just two glyphs — the success and error symbols for
the Starship prompt — built from pixel-art BMPs. It renders in colour in both
Ghostty and the VSCode terminal.

<!-- Replace with a screenshot of the prompt if you like. -->

## How it fits together

```
glyph-*.bmp ──build-font.py──▶ PromptGlyphs-Regular.ttf
  (pixel art)                        (colour font)
                                          │
                     default.nix / flake.nix build it,
                     home.nix installs it to ~/Library/Fonts
                                          │
        ┌─────────────────────────────────┴──────────────┐
     Ghostty                                        VSCode terminal
  font-codepoint-map                             appended to the
  routes U+100000-1 here                         terminal fontFamily
        │                                                │
        └──────── Starship prints U+100000 / U+100001 ───┘
                  (puaChar in zsh/default.nix)
```

The idea: build a colour font that carries only the two prompt symbols, then
have the terminal route just those codepoints to it. Nothing else about the
primary font changes.

## Why a dedicated two-glyph font

Adding glyphs to a real font would mean patching every weight
(regular/bold/italic/bold-italic). Instead this font contains only U+100000 and
U+100001, and Ghostty's `font-codepoint-map` points those codepoints at it. The
primary font is untouched.

## How colour survives

Ghostty only treats a glyph as coloured if the font has an `sbix` or `SVG` table
(see `ColorState.isColorGlyph` in Ghostty's `src/font/face/coretext.zig`);
anything else is rasterised in greyscale and the colour is dropped. COLR/CPAL
alone is not enough.

So colour is stored twice:

- **sbix** — Apple's per-glyph PNG bitmaps, the same mechanism as Apple Color
  Emoji. This is what makes colour work in the terminal. Ghostty also draws sbix
  glyphs on whole pixels without smoothing, which suits pixel art.
- **COLR/CPAL** — a vector colour definition, kept as a portable fallback for
  other software.

sbix pairs with `glyf`, so the outlines are TrueType rather than CFF.

## Why the codepoints are in plane 16

U+E000–U+E00A is a Nerd Font icon range, and Ghostty reshapes those codepoints
to 79% of the cell height (`src/font/nerd_font_attributes.zig`), which squashes
square artwork. That table ends at U+F1AF0, so the private-use area in plane 16
(U+100000+) is out of its reach.

Because these are past the BMP, `puaChar` in `zsh/default.nix` emits them as a
UTF-16 surrogate pair.

## Geometry

Three constants place the artwork, all solved for empirically by rendering the
glyph next to the terminal's block cursor (which is exactly one cell) until they
lined up:

| constant     | why |
| ------------ | --- |
| `ART`        | drawn wider than the advance — a square glyph confined to the 0.6em cell renders much smaller than the surrounding text |
| `ART_ORIGIN` | left-aligned, not centred — xterm.js clips whatever spills past the cell's left edge, so all overflow goes right into the trailing space |
| `ART_DROP`   | sunk below the baseline — resting on it leaves the descender area empty and the glyph floats above the line |

## Outline / bitmap alignment

A renderer sizes its canvas from the outline's bounds, then draws the bitmap
into it, so the two must occupy the same box or the bitmap gets clipped. Three
rules keep them aligned, and `Layout` centralises the coordinate maths so both
paths derive from it:

1. the left side bearing equals the outline's `xMin` (CoreText trusts `hmtx`
   over the glyph header);
2. each sbix bitmap is cropped to its ink (transparent margin lands outside the
   canvas);
3. sbix origin offsets stay zero (CoreText places a bitmap at
   `pen + lsb + originOffset`, so an offset would be counted twice).

## Editing the artwork

Edit `glyph-success.bmp` / `glyph-error.bmp` in any pixel editor. Rules:

- both files must be the same size;
- every ink colour becomes a palette entry — the colours you paint are the
  colours that render;
- the canvas colour is read from the four corners (BMP has no alpha), so keep a
  clean, uniform border around the artwork.

Then rebuild with `task apply` (the font is baked into the Nix store, so a
rebuild is required — editing the BMP alone does nothing).

## Build and test

```sh
# Build the font locally
uv run build-font.py . PromptGlyphs-Regular.ttf

# Run the tests (also wired into CI and `task test` at the repo root)
uv run --frozen pytest -q
```

The Nix build takes its Python dependencies from nixpkgs; `pyproject.toml` /
`uv.lock` are only for running the script and its tests locally.

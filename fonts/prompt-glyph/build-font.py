#!/usr/bin/env python3
"""Build a colour font holding only the Starship prompt glyphs.

Artwork comes from the sibling glyph-*.bmp files, one pixel per dot.

Colour is stored twice. sbix, Apple's bitmap table, is the one that matters:
Ghostty only treats a glyph as coloured if it finds sbix or SVG (see
ColorState.isColorGlyph in its src/font/face/coretext.zig), and otherwise
rasterises into a linearGray context. It also draws sbix glyphs on whole pixels
without smoothing, which suits pixel art. COLR/CPAL is the portable fallback for
everything else. Outlines are TrueType because sbix pairs with glyf.
"""

import io
import os
import sys
from pathlib import Path

from fontTools.colorLib.builder import buildCOLR, buildCPAL
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import newTable
from fontTools.ttLib.tables.sbixGlyph import Glyph as SbixGlyph
from fontTools.ttLib.tables.sbixStrike import Strike as SbixStrike
from PIL import Image

UPM = 1000
ASCENT = 800
DESCENT = -440

# 0.6em, the usual monospace advance, so a glyph occupies one cell.
ADVANCE = 600

# Width the artwork is drawn at, in font units. Far wider than the advance: a
# square glyph confined to a 0.6em cell renders much smaller than the text beside
# it. This and ART_DROP were solved for by rendering against the terminal's block
# cursor, which occupies exactly one cell, until the glyph matched its box.
# Overflowing the advance costs nothing because the prompt symbol is always
# followed by a space -- but only rightwards, hence ART_ORIGIN below.
ART = 1400

# Left edge of the artwork within the advance. Zero rather than centred: xterm.js
# (VSCode's terminal) clips whatever spills past the cell's left edge, so a
# centred glyph loses its left side as it grows. Anchoring left sends the entire
# overflow into the trailing space instead.
ART_ORIGIN = 0

# How far below the baseline the artwork's bottom edge sits. Resting it on the
# baseline leaves the descender space empty, so the glyph floats above a line
# whose own descenders drop into it. This lands the glyph on the cell floor,
# level with the cursor. DESCENT has to cover it.
ART_DROP = 340

# Pixels-per-em values to bake bitmaps for. A renderer picks the nearest strike
# and scales when it has to, and that scaling is the only thing that softens a
# bitmap glyph -- an exact strike is pixel for pixel whatever the artwork
# resolution happens to be. ppem is font-size times display scale, so this
# covers roughly font-size 8 to 32 on a 2x display, plus a few larger.
STRIKE_PPEMS = tuple(range(16, 65, 2)) + (72, 80, 96, 112, 128, 160)

# Alpha at or below this counts as canvas rather than ink.
ALPHA_FLOOR = 0

FAMILY = "Prompt Glyphs"
STYLE = "Regular"
PS_NAME = "PromptGlyphs-Regular"
VERSION = "1.000"

# Plane 16, not the usual U+E000 area: Ghostty reshapes U+E000-U+E00A to 79% of
# the cell height as Nerd Font icons (src/font/nerd_font_attributes.zig), which
# distorts square artwork. Its icon table ends at U+F1AF0.
GLYPHS = [
    ("promptSuccess", 0x100000, "glyph-success.bmp"),
    ("promptError", 0x100001, "glyph-error.bmp"),
]


class Layout:
    """Maps artwork pixel coordinates onto font units.

    The outline and the sbix bitmaps have to land on exactly the same box: a
    renderer sizes its canvas from the outline's bounds and then lets the bitmap
    draw, so a bitmap even slightly larger gets clipped. Both go through this
    one mapping, including its rounding, so they cannot drift apart.
    """

    def __init__(self, image):
        self.cell = ART / image.width
        self.top = self.cell * image.height - ART_DROP

    def x(self, col):
        return round(ART_ORIGIN + col * self.cell)

    def y(self, row):
        """Font-unit y of a row's top edge; row 0 is the artwork's top."""
        return round(self.top - row * self.cell)


def ink_box(image):
    """Bounding box of everything that is not canvas."""
    return image.getchannel("A").getbbox()


def read_image(path):
    """Return the artwork as RGBA with the canvas made transparent.

    Alpha-less formats such as BMP cannot mark their canvas, so its colour is
    read off the corners; disagreeing corners are ambiguous rather than guessed.
    """
    if not path.exists():
        sys.exit(f"{path}: no such file")

    image = Image.open(path).convert("RGBA")
    pixels = list(image.getdata())

    if all(px[3] > ALPHA_FLOOR for px in pixels):
        width, height = image.size
        corners = {
            pixels[0],
            pixels[width - 1],
            pixels[(height - 1) * width],
            pixels[height * width - 1],
        }
        if len(corners) != 1:
            listed = ", ".join(
                sorted(f"#{r:02X}{g:02X}{b:02X}" for r, g, b, _ in corners)
            )
            sys.exit(f"{path}: corners disagree ({listed}), canvas colour unclear")
        canvas = corners.pop()
        image.putdata([(0, 0, 0, 0) if px == canvas else px for px in pixels])

    if not any(px[3] > ALPHA_FLOOR for px in image.getdata()):
        sys.exit(f"{path}: every pixel is canvas, nothing to draw")

    return image


def draw_cells(image, keep):
    """Draw pixels matching `keep` as rectangles, returning (glyph, left bearing).

    Runs of pixels become one rectangle each to keep the outline small; abutting
    rectangles fill without seams under the nonzero winding rule.

    The bearing must be the outline's own xMin. CoreText believes hmtx over the
    glyph header, so a mismatch shifts where the glyph is thought to begin.
    """
    layout = Layout(image)
    rows = image.load()
    pen = TTGlyphPen(None)
    lsb = None

    for r in range(image.height):
        col = 0
        while col < image.width:
            if not keep(rows[col, r]):
                col += 1
                continue

            start = col
            while col < image.width and keep(rows[col, r]):
                col += 1

            x0, x1 = layout.x(start), layout.x(col)
            # Font coordinates grow upwards, so the row below is the lower edge.
            y1, y0 = layout.y(r), layout.y(r + 1)

            pen.moveTo((x0, y0))
            pen.lineTo((x1, y0))
            pen.lineTo((x1, y1))
            pen.lineTo((x0, y1))
            pen.closePath()

            lsb = x0 if lsb is None else min(lsb, x0)

    return pen.glyph(), lsb or 0


def bitmap(image, ppem):
    """Return the PNG for one sbix strike, cropped to the inked area.

    Cropping is why the strike's origin offsets stay zero: the left side bearing
    already moves the pen to the outline's box, and an offset here would be
    counted a second time.
    """
    left, top, right, bottom = ink_box(image)
    layout = Layout(image)
    units_w = layout.x(right) - layout.x(left)
    units_h = layout.y(top) - layout.y(bottom)

    cropped = image.crop((left, top, right, bottom)).resize(
        (
            max(1, round(units_w * ppem / UPM)),
            max(1, round(units_h * ppem / UPM)),
        ),
        Image.NEAREST,
    )

    buffer = io.BytesIO()
    cropped.save(buffer, format="PNG")
    return buffer.getvalue()


def load_artwork(src):
    """Read every glyph's artwork, checking they can share one set of metrics."""
    images = {name: read_image(src / image) for name, _, image in GLYPHS}

    # One size keeps a single advance and set of strikes valid for every glyph.
    sizes = {im.size for im in images.values()}
    if len(sizes) != 1:
        sys.exit(f"images disagree on size: {sorted(sizes)}")

    return images


def build_palette(images):
    """Every ink colour, ordered by first appearance so rebuilds stay stable."""
    palette = []
    seen = set()
    for image in images.values():
        for px in image.getdata():
            if px[3] > ALPHA_FLOOR and px not in seen:
                seen.add(px)
                palette.append(px)
    return palette


def build_glyphs(images, palette):
    """Build the outlines: one base glyph per symbol plus a COLR layer per colour."""
    # .notdef is blank: the font is only reached through an explicit codepoint
    # mapping, so there is nothing to fall back to.
    glyf = {".notdef": TTGlyphPen(None).glyph()}
    metrics = {".notdef": (ADVANCE, 0)}
    order = [".notdef"]
    layers = {}

    for name, image in images.items():
        # Base glyph: the union of every layer, so renderers with neither sbix
        # nor COLR get a monochrome silhouette rather than nothing.
        glyf[name], lsb = draw_cells(image, lambda px: px[3] > ALPHA_FLOOR)
        metrics[name] = (ADVANCE, lsb)
        order.append(name)

        present = set(image.getdata())
        glyph_layers = []
        for index, color in enumerate(palette):
            if color not in present:
                continue
            layer = f"{name}.{index}"
            glyf[layer], layer_lsb = draw_cells(
                image, lambda px, color=color: px == color
            )
            metrics[layer] = (ADVANCE, layer_lsb)
            order.append(layer)
            glyph_layers.append((layer, index))

        layers[name] = glyph_layers

    return glyf, metrics, order, layers


def build_sbix(images):
    """Colour bitmaps, one strike per pixels-per-em value."""
    sbix = newTable("sbix")
    sbix.version = 1
    sbix.flags = 1
    sbix.strikes = {}

    for ppem in STRIKE_PPEMS:
        strike = SbixStrike()
        strike.ppem = ppem
        strike.resolution = 72
        strike.glyphs = {
            name: SbixGlyph(
                glyphName=name,
                graphicType="png ",
                imageData=bitmap(image, ppem),
                originOffsetX=0,
                originOffsetY=0,
            )
            for name, image in images.items()
        }
        sbix.strikes[ppem] = strike

    sbix.numStrikes = len(sbix.strikes)
    return sbix


def build_font(images):
    """Assemble the complete font from the artwork."""
    # fontTools stamps head.created/modified from SOURCE_DATE_EPOCH, falling back
    # to the clock. Pinning it keeps identical artwork producing identical bytes,
    # and stops a malformed value in the environment from failing the build --
    # a real hazard, since some shells export it empty. A valid value is left
    # alone so the Nix sandbox keeps control of it.
    if not os.environ.get("SOURCE_DATE_EPOCH", "").isdigit():
        os.environ["SOURCE_DATE_EPOCH"] = "0"

    palette = build_palette(images)
    glyf, metrics, order, layers = build_glyphs(images, palette)

    fb = FontBuilder(UPM, isTTF=True)
    fb.setupGlyphOrder(order)
    fb.setupCharacterMap({cp: name for name, cp, _ in GLYPHS})
    fb.setupGlyf(glyf)
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=ASCENT, descent=DESCENT)
    fb.setupOS2(
        sTypoAscender=ASCENT,
        sTypoDescender=DESCENT,
        usWinAscent=ASCENT,
        usWinDescent=-DESCENT,
    )
    # Monospaced, so terminals do not treat the glyphs as proportional.
    fb.setupPost(isFixedPitch=1)
    fb.setupNameTable(
        {
            "familyName": FAMILY,
            "styleName": STYLE,
            "uniqueFontIdentifier": f"{PS_NAME};{VERSION}",
            "fullName": f"{FAMILY} {STYLE}",
            "psName": PS_NAME,
            "version": VERSION,
        }
    )

    # COLR v0: flat pixel art has no use for the gradients v1 adds.
    fb.font["CPAL"] = buildCPAL([[tuple(c / 255 for c in color) for color in palette]])
    fb.font["COLR"] = buildCOLR(layers, version=0)
    fb.font["sbix"] = build_sbix(images)

    return fb.font


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: build-font.py SRC_DIR OUTPUT_TTF")

    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    font = build_font(load_artwork(src))

    out.parent.mkdir(parents=True, exist_ok=True)
    font.save(str(out))


if __name__ == "__main__":
    main()

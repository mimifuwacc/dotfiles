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
DESCENT = -200

# 0.6em, the usual monospace advance, so a glyph occupies one cell.
ADVANCE = 600

# Width the artwork is drawn at, in font units. At font-size 20 on a 2x display
# a cell is 24 device pixels, so 400 puts a 16px artwork on 16 of them: one dot
# per pixel, no resampling, and room left beside the glyph.
ART = 400

# Bitmaps are baked at whole multiples of the artwork so no strike is a blurry
# half-pixel resample.
STRIKE_SCALES = (1, 2, 3, 4)

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


def rows_of(image):
    return [
        [image.getpixel((x, y)) for x in range(image.width)]
        for y in range(image.height)
    ]


def draw_cells(image, keep):
    """Draw pixels matching `keep` as rectangles, returning (glyph, left bearing).

    Runs of pixels become one rectangle each to keep the outline small; abutting
    rectangles fill without seams under the nonzero winding rule.

    The bearing must be the outline's own xMin. CoreText believes hmtx over the
    glyph header, so a mismatch shifts where the glyph is thought to begin.
    """
    cell = ART / image.width
    # Centre the artwork in the advance and sit it on the baseline.
    x_origin = (ADVANCE - ART) / 2
    y_origin = cell * image.height

    pen = TTGlyphPen(None)
    lsb = None

    for r, row in enumerate(rows_of(image)):
        col = 0
        while col < image.width:
            if not keep(row[col]):
                col += 1
                continue

            start = col
            while col < image.width and keep(row[col]):
                col += 1

            x0 = round(x_origin + start * cell)
            x1 = round(x_origin + col * cell)
            # Row 0 is the top row, and font coordinates grow upwards.
            y1 = round(y_origin - r * cell)
            y0 = round(y_origin - (r + 1) * cell)

            pen.moveTo((x0, y0))
            pen.lineTo((x1, y0))
            pen.lineTo((x1, y1))
            pen.lineTo((x0, y1))
            pen.closePath()

            lsb = x0 if lsb is None else min(lsb, x0)

    return pen.glyph(), lsb or 0


def strike_ppem(art_width, scale):
    """The ppem at which the artwork lands on exactly `scale` pixels per dot."""
    return round(scale * art_width * UPM / ART)


def bitmap(image, scale):
    """Return the PNG for one sbix strike, cropped to the inked area.

    The bitmap must cover the same box as the outline: a renderer sizes its
    canvas from the outline's bounds, so transparent margin lands outside and is
    clipped. Cropping is also why the strike's origin offsets stay zero -- the
    left side bearing already moves the pen to that box, and an offset here
    would be counted twice.
    """
    cropped = image.crop(image.getchannel("A").getbbox())
    cropped = cropped.resize(
        (cropped.width * scale, cropped.height * scale), Image.NEAREST
    )

    buffer = io.BytesIO()
    cropped.save(buffer, format="PNG")
    return buffer.getvalue()


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: build-font.py SRC_DIR OUTPUT_TTF")

    src = Path(sys.argv[1])
    out = Path(sys.argv[2])

    images = {name: read_image(src / image) for name, _, image in GLYPHS}

    # One size keeps a single advance and set of strikes valid for every glyph.
    sizes = {im.size for im in images.values()}
    if len(sizes) != 1:
        sys.exit(f"images disagree on size: {sorted(sizes)}")
    art_width = sizes.pop()[0]

    # One CPAL palette shared by every glyph, ordered by first appearance so it
    # stays stable across rebuilds.
    palette = []
    for image in images.values():
        for px in image.getdata():
            if px[3] > ALPHA_FLOOR and px not in palette:
                palette.append(px)

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

        used = [c for c in palette if c in set(image.getdata())]
        glyph_layers = []
        for color in used:
            index = palette.index(color)
            layer = f"{name}.{index}"
            glyf[layer], layer_lsb = draw_cells(
                image, lambda px, color=color: px == color
            )
            metrics[layer] = (ADVANCE, layer_lsb)
            order.append(layer)
            glyph_layers.append((layer, index))

        layers[name] = glyph_layers

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

    sbix = newTable("sbix")
    sbix.version = 1
    sbix.flags = 1
    sbix.strikes = {}
    for scale in STRIKE_SCALES:
        strike = SbixStrike()
        strike.ppem = strike_ppem(art_width, scale)
        strike.resolution = 72
        strike.glyphs = {}
        for name, image in images.items():
            strike.glyphs[name] = SbixGlyph(
                glyphName=name,
                graphicType="png ",
                imageData=bitmap(image, scale),
                originOffsetX=0,
                originOffsetY=0,
            )
        sbix.strikes[strike.ppem] = strike
    sbix.numStrikes = len(sbix.strikes)
    fb.font["sbix"] = sbix

    out.parent.mkdir(parents=True, exist_ok=True)
    fb.save(str(out))


if __name__ == "__main__":
    main()

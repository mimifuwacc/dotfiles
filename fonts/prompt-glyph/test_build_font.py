"""Tests for the prompt glyph font build.

These lock down the properties that were painful to get right. Every renderer
disagreement met while building this font showed up as one of the invariants
below, so each test names the failure it prevents rather than just restating the
code.

The font is built in memory from the repository's own artwork, so the tests
exercise the real glyphs rather than fixtures that could drift from them.
"""

import importlib.util
import io
import struct
from pathlib import Path

import pytest
from PIL import Image

HERE = Path(__file__).parent


def _load_module():
    """Import build-font.py, whose hyphen keeps it from being a normal import."""
    spec = importlib.util.spec_from_file_location("build_font", HERE / "build-font.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


bf = _load_module()


@pytest.fixture(scope="module")
def images():
    return bf.load_artwork(HERE)


@pytest.fixture(scope="module")
def font(images):
    return bf.build_font(images)


@pytest.fixture(scope="module")
def glyph_names():
    return [name for name, _, _ in bf.GLYPHS]


def outline_bounds(font, name):
    """Raw glyf bounds.

    Deliberately not font.getGlyphSet(), which shifts a glyph by its left side
    bearing as it draws. Bounds taken that way always agree with hmtx, which
    would make the bearing test below assert nothing at all.
    """
    glyph = font["glyf"][name]
    if glyph.numberOfContours == 0:
        return None
    return glyph.xMin, glyph.yMin, glyph.xMax, glyph.yMax


# --- codepoints ---------------------------------------------------------------


def test_codepoints_avoid_ghostty_icon_ranges():
    """Ghostty reshapes anything it reads as a Nerd Font icon.

    Its table (src/font/nerd_font_attributes.zig) forces those codepoints to a
    fraction of the cell height, which squashed the square artwork into a tall
    smear. The table ends at U+F1AF0, so plane 16 is out of its reach.
    """
    for _, codepoint, _ in bf.GLYPHS:
        assert codepoint > 0xF1AF0


def test_cmap_covers_every_glyph(font, glyph_names):
    cmap = font.getBestCmap()
    assert sorted(cmap) == sorted(cp for _, cp, _ in bf.GLYPHS)
    assert sorted(cmap.values()) == sorted(glyph_names)


# --- metrics ------------------------------------------------------------------


def test_left_side_bearing_matches_outline(font):
    """CoreText trusts hmtx over the glyph header.

    Leaving the bearing at zero while the outline started further right moved
    where the renderer thought the glyph began, so it allocated a canvas in the
    wrong place and clipped the right-hand side away.
    """
    for name in font.getGlyphOrder():
        bounds = outline_bounds(font, name)
        if bounds is None:  # .notdef is intentionally blank
            continue
        advance, lsb = font["hmtx"][name]
        assert lsb == bounds[0], f"{name}: lsb {lsb} != xMin {bounds[0]}"
        assert advance == bf.ADVANCE


def test_descent_covers_the_dropped_artwork(font, glyph_names):
    """The glyph sits below the baseline to line up with the cursor.

    Declared descent has to reach at least that far, or the part below the
    baseline falls outside the font's own metrics.
    """
    assert bf.DESCENT <= -bf.ART_DROP
    for name in glyph_names:
        assert outline_bounds(font, name)[1] >= bf.DESCENT


def test_artwork_overflows_the_advance_only_rightwards():
    """xterm.js clips whatever spills past the cell's left edge.

    Centring the artwork therefore ate the glyph's left side as it grew, so it
    is anchored at the advance's left edge instead.
    """
    assert bf.ART > bf.ADVANCE
    assert bf.ART_ORIGIN == 0


# --- sbix and outline agreement -----------------------------------------------


def png_size(data):
    """Width and height from a PNG's IHDR, without decoding the image."""
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    return struct.unpack(">II", data[16:24])


def test_bitmaps_match_the_outline_box(font, glyph_names):
    """A renderer sizes its canvas from the outline, then lets the bitmap draw.

    Anything the bitmap covers beyond that box lands outside the canvas and is
    clipped, which is what cut the glyph in half when the bitmap still carried
    the artwork's transparent margin.
    """
    sbix = font["sbix"]
    for name in glyph_names:
        x0, y0, x1, y1 = outline_bounds(font, name)
        for ppem, strike in sbix.strikes.items():
            width, height = png_size(strike.glyphs[name].imageData)
            assert width == round((x1 - x0) * ppem / bf.UPM), f"{name} @{ppem} width"
            assert height == round((y1 - y0) * ppem / bf.UPM), f"{name} @{ppem} height"


def test_bitmaps_carry_no_transparent_margin(font, glyph_names):
    """The bitmap has to be cropped to the ink, not padded out to the artwork.

    Padding is area the outline does not claim, so it falls outside the canvas
    the renderer allocated and gets clipped. Ink on all four edges is what
    "cropped exactly" looks like from the outside.
    """
    for ppem, strike in font["sbix"].strikes.items():
        for name in glyph_names:
            image = Image.open(io.BytesIO(strike.glyphs[name].imageData)).convert("RGBA")
            alpha = image.getchannel("A")
            assert alpha.getbbox() == (0, 0, image.width, image.height), (
                f"{name} @{ppem}: transparent margin around the bitmap"
            )


def test_sbix_origin_offsets_are_zero(font, glyph_names):
    """CoreText places a bitmap at pen + lsb + originOffset.

    The bearing already reaches the outline's box, so a non-zero offset here
    was counted twice and pushed the bitmap off its own outline.
    """
    for strike in font["sbix"].strikes.values():
        for name in glyph_names:
            glyph = strike.glyphs[name]
            assert (glyph.originOffsetX, glyph.originOffsetY) == (0, 0)


def test_strikes_cover_the_sizes_actually_rendered(font):
    """A ppem without its own strike is scaled from a neighbour, and that
    scaling is the only thing that softens a bitmap glyph."""
    strikes = set(font["sbix"].strikes)
    assert 40 in strikes, "font-size 20 on a 2x display"
    assert 28 in strikes, "font-size 14 on a 2x display"


def test_bitmaps_introduce_no_new_colours(font, glyph_names):
    """Nearest-neighbour keeps pixel art crisp; any smooth resampling would
    blend edge pixels into colours the palette never had."""
    palette = {
        (c.red, c.green, c.blue, c.alpha) for c in font["CPAL"].palettes[0]
    }
    for strike in font["sbix"].strikes.values():
        for name in glyph_names:
            image = Image.open(io.BytesIO(strike.glyphs[name].imageData)).convert("RGBA")
            for px in set(image.getdata()):
                if px[3] > bf.ALPHA_FLOOR:
                    assert px in palette, f"{name}: {px} is not a palette colour"


# --- colour -------------------------------------------------------------------


def test_palette_holds_every_ink_colour_and_no_canvas(font, images):
    palette = {
        (c.red, c.green, c.blue, c.alpha) for c in font["CPAL"].palettes[0]
    }
    ink = {
        px
        for image in images.values()
        for px in set(image.getdata())
        if px[3] > bf.ALPHA_FLOOR
    }
    assert palette == ink
    assert all(px[3] == 255 for px in palette), "canvas leaked into the palette"


def test_every_glyph_has_a_colour_layer_per_colour_it_uses(font, images):
    layers = font["COLR"].ColorLayers
    for name, image in images.items():
        used = {px for px in set(image.getdata()) if px[3] > bf.ALPHA_FLOOR}
        assert len(layers[name]) == len(used)


# --- artwork loading ----------------------------------------------------------


def write_bmp(path, pixels, size):
    image = Image.new("RGB", size)
    image.putdata(pixels)
    image.save(path, format="BMP")


def test_canvas_colour_is_taken_from_the_corners(tmp_path):
    """BMP has no alpha, so the corners are the only signal for what is canvas."""
    path = tmp_path / "art.bmp"
    black, teal = (0, 0, 0), (0xA1, 0xD6, 0xD2)
    write_bmp(path, [black] * 4 + [black, teal, teal, black] + [black] * 8, (4, 4))

    image = bf.read_image(path)
    assert set(image.getdata()) == {(0, 0, 0, 0), teal + (255,)}


def test_disagreeing_corners_are_rejected_rather_than_guessed(tmp_path):
    path = tmp_path / "art.bmp"
    pixels = [(0, 0, 0)] * 16
    pixels[3] = (255, 0, 0)  # one corner differs
    write_bmp(path, pixels, (4, 4))

    with pytest.raises(SystemExit) as excinfo:
        bf.read_image(path)
    assert "corners disagree" in str(excinfo.value)


def test_artwork_that_is_entirely_canvas_is_rejected(tmp_path):
    path = tmp_path / "art.bmp"
    write_bmp(path, [(0, 0, 0)] * 16, (4, 4))

    with pytest.raises(SystemExit) as excinfo:
        bf.read_image(path)
    assert "nothing to draw" in str(excinfo.value)


def test_artwork_sizes_must_agree(tmp_path, monkeypatch):
    """One advance and one set of strikes serve every glyph, so a mismatch would
    make the prompt jump around when the symbol changes."""
    teal = (0xA1, 0xD6, 0xD2)
    write_bmp(tmp_path / "a.bmp", [(0, 0, 0)] * 5 + [teal] + [(0, 0, 0)] * 10, (4, 4))
    write_bmp(tmp_path / "b.bmp", [(0, 0, 0)] * 7 + [teal] + [(0, 0, 0)] * 1, (3, 3))
    monkeypatch.setattr(bf, "GLYPHS", [("a", 0x100000, "a.bmp"), ("b", 0x100001, "b.bmp")])

    with pytest.raises(SystemExit) as excinfo:
        bf.load_artwork(tmp_path)
    assert "disagree on size" in str(excinfo.value)


# --- layout -------------------------------------------------------------------


def test_layout_rows_and_columns_are_square(images):
    """Dots have to stay square, or the pixel art shears."""
    image = next(iter(images.values()))
    layout = bf.Layout(image)
    assert layout.x(1) - layout.x(0) == layout.y(0) - layout.y(1)

"""Renders the GYMTRX brand assets into assets/brand/.

The mark is a 3x3 grid of rounded "days", some logged in the accent; it matches
BrandMark in lib/presentation/widgets/brand_mark.dart.

    python tool/generate_icons.py
"""

import pathlib

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "brand"

BG = (10, 10, 11, 255)
ON = (212, 255, 63, 255)  # volt
OFF = (38, 38, 42, 255)
WHITE = (255, 255, 255, 255)
PATTERN = [True, False, True, False, True, True, True, False, False]
SS = 4  # supersampling factor for smooth edges


def squircle(draw: ImageDraw.ImageDraw, box, fill, n=5.0, steps=180):
    """Superellipse |x|^n + |y|^n = 1 inside box: continuous-curvature corners."""
    import math

    x0, y0, x1, y1 = box
    cx, cy, rx, ry = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
    pts = []
    for i in range(steps):
        t = 2 * math.pi * i / steps
        c, s = math.cos(t), math.sin(t)
        pts.append((cx + rx * math.copysign(abs(c) ** (2 / n), c), cy + ry * math.copysign(abs(s) ** (2 / n), s)))
    draw.polygon(pts, fill=fill)


def mark(size, extent, on=ON, off=OFF, bg=None):
    """The grid, `extent` wide, centred in a `size` square canvas."""
    big = size * SS
    img = Image.new("RGBA", (big, big), bg or (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    ext = extent * SS
    gap = ext * 0.08
    cell = (ext - gap * 2) / 3
    start = (big - ext) / 2
    for i, logged in enumerate(PATTERN):
        x = start + (i % 3) * (cell + gap)
        y = start + (i // 3) * (cell + gap)
        if logged or off is not None:
            squircle(d, (x, y, x + cell, y + cell), on if logged else off)
    return img.resize((size, size), Image.LANCZOS)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # Full icon (legacy launchers, Play): mark on the dark background.
    full = Image.new("RGBA", (1024, 1024), BG)
    full.alpha_composite(mark(1024, 600))
    full.save(OUT / "icon.png")
    # Adaptive foreground: content inside the 66/108 safe zone.
    mark(1024, 520).save(OUT / "icon_foreground.png")
    # Android 13 themed icon: a single-colour silhouette (logged cells only).
    mark(1024, 520, on=WHITE, off=None).save(OUT / "icon_monochrome.png")
    # Android 12+ splash icon: 1152 canvas, content within the 768 circle.
    mark(1152, 470).save(OUT / "splash.png")
    # Pre-12 splash: centred image on the background colour.
    mark(480, 220).save(OUT / "splash_legacy.png")
    print("wrote", ", ".join(sorted(p.name for p in OUT.glob("*.png"))))


if __name__ == "__main__":
    main()

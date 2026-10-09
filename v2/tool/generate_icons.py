"""Renders the GYMTRX brand assets into assets/brand/.

The mark is a 3x3 grid of round dots ("days"), some logged in lime, on the
ink colour of the app's buttons. It matches BrandMark in
lib/presentation/widgets/brand_mark.dart.

    python tool/generate_icons.py
"""

import pathlib

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "brand"

INK = (22, 27, 38, 255)  # #161B26
ON = (198, 242, 78, 255)  # volt, light theme
OFF = (48, 57, 72, 255)
WHITE = (255, 255, 255, 255)
PATTERN = [True, False, True, False, True, True, True, False, False]
SS = 4  # supersampling factor for smooth edges


def mark(size, extent, on=ON, off=OFF, bg=None, badge=None):
    """The dot grid, `extent` wide, centred in a `size` square canvas.

    `badge` draws an ink circle of that diameter behind the dots."""
    big = size * SS
    img = Image.new("RGBA", (big, big), bg or (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if badge:
        r = badge * SS / 2
        c = big / 2
        d.ellipse((c - r, c - r, c + r, c + r), fill=INK)
    ext = extent * SS
    cell = ext / 3
    start = (big - ext) / 2
    for i, logged in enumerate(PATTERN):
        if not logged and off is None:
            continue
        cx = start + (i % 3 + 0.5) * cell
        cy = start + (i // 3 + 0.5) * cell
        r = cell * 0.36
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=on if logged else off)
    return img.resize((size, size), Image.LANCZOS)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # Full icon (legacy launchers): dots on the ink background.
    full = Image.new("RGBA", (1024, 1024), INK)
    full.alpha_composite(mark(1024, 560))
    full.save(OUT / "icon.png")
    # Adaptive foreground: content inside the 66/108 safe zone.
    mark(1024, 500).save(OUT / "icon_foreground.png")
    # Android 13 themed icon: a single-colour silhouette (logged dots only).
    mark(1024, 500, on=WHITE, off=None).save(OUT / "icon_monochrome.png")
    # Android 12+ splash icon: 1152 canvas, content within the 768 circle,
    # drawn on the ink icon background set in pubspec.yaml.
    mark(1152, 430).save(OUT / "splash.png")
    # Pre-12 splash: a self-contained ink badge, readable on light or dark.
    mark(480, 150, badge=260).save(OUT / "splash_legacy.png")
    print("wrote", ", ".join(sorted(p.name for p in OUT.glob("*.png"))))


if __name__ == "__main__":
    main()

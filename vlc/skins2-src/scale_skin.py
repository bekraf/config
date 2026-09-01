#!/usr/bin/env python3
"""Schaal een VLC skins2 Winamp2-thema met een gehele factor.

Bitmaps gaan via nearest-neighbour (scherpe pixels, retro-look) en blijven
24-bits ongecomprimeerd BMP3 -- dat laatste is nodig omdat VLC 3.0.23 crasht op
palet-BMP's met ffmpeg 8.x.
"""
import re
import shutil
import subprocess
import sys
from pathlib import Path

# Per element: welke attributen zijn pixelmaten en moeten dus mee schalen.
SCALE = {
    "Anchor":           {"x", "y", "range"},
    "Button":           {"x", "y"},
    "Checkbox":         {"x", "y"},
    "Font":             {"size"},
    "Group":            {"x", "y"},
    "Image":            {"x", "y"},
    "Layout":           {"width", "height", "minwidth", "minheight",
                         "maxwidth", "maxheight"},
    "Playlist":         {"x", "y", "width", "height"},
    "Slider":           {"x", "y", "thickness"},
    "SliderBackground": {"padhoriz", "padvert"},
    "SubBitmap":        {"x", "y", "width", "height"},
    "Text":             {"x", "y", "width"},
    "Theme":            {"magnet"},
    "Window":           {"x", "y"},
}
# points="(0,0),(245,0)" -- curve-coordinaten, per getal schalen.
POINTS = {"Anchor", "Slider"}


def scale_theme(xml: str, factor: int) -> tuple[str, int]:
    changed = 0

    def do_element(m: re.Match) -> str:
        nonlocal changed
        tag, attrs = m.group(1), m.group(2)
        wanted = SCALE.get(tag, set())

        def do_attr(a: re.Match) -> str:
            nonlocal changed
            name, val = a.group(1), a.group(2)
            if name in wanted and re.fullmatch(r"-?\d+", val):
                changed += 1
                return f'{name}="{int(val) * factor}"'
            if name == "points" and tag in POINTS:
                changed += 1
                new = re.sub(r"-?\d+", lambda n: str(int(n.group()) * factor), val)
                return f'{name}="{new}"'
            return a.group(0)

        return f"<{tag}" + re.sub(r'([A-Za-z]+)="([^"]*)"', do_attr, attrs) + ">"

    out = re.sub(r"<([A-Z][A-Za-z]*)\b([^>]*?)(/?)>",
                 lambda m: do_element(m)[:-1] + m.group(3) + ">", xml)
    return out, changed


def main() -> int:
    src, dst, factor = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3])
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

    for bmp in sorted(dst.glob("*.bmp")):
        subprocess.run(
            ["magick", str(bmp), "-scale", f"{factor * 100}%",
             "-alpha", "off", "-type", "TrueColor", "-compress", "none",
             f"BMP3:{bmp}"],
            check=True,
        )
    print(f"{len(list(dst.glob('*.bmp')))} bitmaps geschaald naar {factor}x")

    theme = dst / "theme.xml"
    out, n = scale_theme(theme.read_text(), factor)
    theme.write_text(out)
    print(f"{n} geometrie-attributen herrekend in theme.xml")
    return 0


if __name__ == "__main__":
    sys.exit(main())

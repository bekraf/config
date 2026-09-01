#!/usr/bin/env python3
"""Herkleur een VLC skins2 Winamp2-thema naar een eigen palet.

Werkt op 24-bits ongecomprimeerde BMP3-bestanden en past een gradient map toe:
de helderheid van elke pixel bepaalt waar hij op een kleurenverloop landt. Zo
blijft alle vorm, schaduw en detail van de skin behouden.

De transparantiekleur uit theme.xml (alphacolor) wordt exact met rust gelaten,
anders verliest de skin zijn doorzichtige delen. Ingedrukte knopframes (de
SubBitmaps met id op `_down`) krijgen een eigen verloop met de hover-kleur.
"""
import re
import shutil
import struct
import sys
from pathlib import Path

DARK  = (0x39, 0x18, 0x07)   # Dark Orange
LIGHT = (0x89, 0x38, 0x0f)   # Light Orange
HOVER = (0x23, 0x49, 0x90)   # Hover
TEXT  = (0xff, 0xe4, 0xa7)   # Text

RAMP_NORMAL  = [(0.0, DARK), (0.55, LIGHT), (1.0, TEXT)]
RAMP_PRESSED = [(0.0, DARK), (0.55, HOVER), (1.0, TEXT)]


def ramp_lookup(ramp):
    """Bouw een tabel van 256 RGB-waarden uit een lijst (positie, kleur)."""
    table = []
    for i in range(256):
        t = i / 255.0
        for (t0, c0), (t1, c1) in zip(ramp, ramp[1:]):
            if t <= t1 or (t1, c1) is ramp[-1]:
                f = 0.0 if t1 == t0 else (t - t0) / (t1 - t0)
                f = max(0.0, min(1.0, f))
                table.append(tuple(round(a + (b - a) * f) for a, b in zip(c0, c1)))
                break
    return table


class Bmp:
    """Minimale lezer/schrijver voor 24-bits ongecomprimeerde BMP3."""

    def __init__(self, path: Path):
        self.path = path
        self.data = bytearray(path.read_bytes())
        self.offset = struct.unpack_from("<I", self.data, 10)[0]
        self.width, self.height = struct.unpack_from("<ii", self.data, 18)
        bpp = struct.unpack_from("<H", self.data, 28)[0]
        comp = struct.unpack_from("<I", self.data, 30)[0]
        if bpp != 24 or comp != 0:
            raise ValueError(f"{path.name}: verwacht 24bpp ongecomprimeerd, kreeg {bpp}bpp comp={comp}")
        self.stride = (self.width * 3 + 3) // 4 * 4

    def pixel_offset(self, x: int, y_top: int) -> int:
        """BMP slaat rijen van onder naar boven op; y_top telt van boven."""
        return self.offset + (self.height - 1 - y_top) * self.stride + x * 3

    def save(self):
        self.path.write_bytes(bytes(self.data))


def parse_theme(theme: Path):
    """Geef per bitmapbestand de alphacolor en de rechthoeken van _down-frames."""
    txt = theme.read_text()
    per_file = {}
    # Zowel <Bitmap .../> als <Bitmap ...> ... </Bitmap> afvangen.
    for blk in re.finditer(r"<Bitmap\b([^>]*?)(?:/>|>(.*?)</Bitmap>)", txt, re.S):
        attrs, body = blk.group(1), blk.group(2) or ""
        fm = re.search(r'file="([^"]*)"', attrs)
        if not fm:
            continue
        am = re.search(r'alphacolor="#?([0-9A-Fa-f]{6})"', attrs)
        alpha = tuple(int(am.group(1)[i:i + 2], 16) for i in (0, 2, 4)) if am else None
        rects = []
        for sub in re.finditer(r"<SubBitmap\b([^>]*)/?>", body):
            sa = sub.group(1)
            sid = re.search(r'id="([^"]*)"', sa)
            if not (sid and sid.group(1).endswith("_down")):
                continue
            g = {k: int(re.search(rf'{k}="(-?\d+)"', sa).group(1))
                 for k in ("x", "y", "width", "height")
                 if re.search(rf'{k}="(-?\d+)"', sa)}
            if len(g) == 4:
                rects.append((g["x"], g["y"], g["width"], g["height"]))
        prev = per_file.get(fm.group(1), (None, []))
        per_file[fm.group(1)] = (alpha or prev[0], prev[1] + rects)
    return per_file


def recolor(src: Path, dst: Path):
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

    normal = ramp_lookup(RAMP_NORMAL)
    pressed = ramp_lookup(RAMP_PRESSED)
    meta = parse_theme(dst / "theme.xml")

    total = 0
    for bmp_path in sorted(dst.glob("*.bmp")):
        alpha, rects = meta.get(bmp_path.name, (None, []))
        img = Bmp(bmp_path)

        # Masker van pixels die in een ingedrukt frame vallen.
        in_pressed = bytearray(img.width * img.height)
        for rx, ry, rw, rh in rects:
            for y in range(max(0, ry), min(img.height, ry + rh)):
                base = y * img.width
                for x in range(max(0, rx), min(img.width, rx + rw)):
                    in_pressed[base + x] = 1

        d = img.data
        for y in range(img.height):
            row = img.offset + (img.height - 1 - y) * img.stride
            mrow = y * img.width
            for x in range(img.width):
                p = row + x * 3
                b, g, r = d[p], d[p + 1], d[p + 2]
                if alpha and (r, g, b) == alpha:
                    continue  # transparantiekleur exact laten staan
                lum = (r * 299 + g * 587 + b * 114) // 1000
                nr, ng, nb = (pressed if in_pressed[mrow + x] else normal)[lum]
                d[p], d[p + 1], d[p + 2] = nb, ng, nr
        img.save()
        total += 1
    print(f"{total} bitmaps herkleurd ({len(meta)} met transparantie/frames uit theme.xml)")

    # Visualizer: kleur 0 = achtergrond, 1 = dots, 2..17 = spectrum top->bodem,
    # 18..22 = oscilloscoop, 23 = piekstipjes.
    lines = [f"{DARK[0]},{DARK[1]},{DARK[2]}, // 0 = achtergrond",
             f"{LIGHT[0]},{LIGHT[1]},{LIGHT[2]}, // 1 = dots"]
    for i in range(16):
        f = i / 15.0
        c = tuple(round(a + (b - a) * f) for a, b in zip(TEXT, LIGHT))
        lines.append(f"{c[0]},{c[1]},{c[2]}, // {i + 2} = spectrum")
    for i in range(5):
        f = i / 4.0
        c = tuple(round(a + (b - a) * f) for a, b in zip(TEXT, LIGHT))
        lines.append(f"{c[0]},{c[1]},{c[2]}, // {i + 18} = oscilloscoop")
    lines.append(f"{HOVER[0]},{HOVER[1]},{HOVER[2]}, // 23 = piek")
    (dst / "viscolor.txt").write_text("\n".join(lines) + "\n")

    (dst / "pledit.txt").write_text(
        "[Text]\n"
        f"Normal=#{TEXT[0]:02X}{TEXT[1]:02X}{TEXT[2]:02X}\n"
        "Current=#FFFFFF\n"
        f"NormalBG=#{DARK[0]:02X}{DARK[1]:02X}{DARK[2]:02X}\n"
        f"SelectedBG=#{HOVER[0]:02X}{HOVER[1]:02X}{HOVER[2]:02X}\n"
        "Font=Arial\n"
    )
    print("viscolor.txt en pledit.txt herschreven naar het palet")


if __name__ == "__main__":
    recolor(Path(sys.argv[1]), Path(sys.argv[2]))

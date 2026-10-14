"""Create per-Action GIF previews from a sprite sheet without external codecs.

Run in Blender: blender -b -P design/_tools/make_gif.py -- sheet.png sheet.json output_dir
"""

import argparse
from collections import defaultdict
import json
from pathlib import Path
import sys

import bpy
import numpy as np


def chunks(data):
    return b"".join(bytes([len(data[i:i + 255])]) + data[i:i + 255]
                    for i in range(0, len(data), 255)) + b"\x00"


def gif_pixels(rgba):
    alpha = rgba[:, :, 3] >= 128
    rgb = rgba[:, :, :3].astype(np.float32)
    bins = np.clip(np.rint(rgb * (5 / 255)), 0, 5).astype(np.uint8)
    index = (1 + bins[:, :, 0] * 36 + bins[:, :, 1] * 6 + bins[:, :, 2]).astype(np.uint8)
    index[~alpha] = 0
    return index.tobytes()


def lzw_literal_stream(pixels):
    # Frequent clear codes keep the dictionary under 512 entries, so every
    # code remains nine bits. Previews are small; this favors reliability.
    clear, end = 256, 257
    codes = [clear]
    for i, p in enumerate(pixels):
        if i and i % 200 == 0:
            codes.append(clear)
        codes.append(p)
    codes.append(end)
    out = bytearray()
    buffer = 0
    bits = 0
    for code in codes:
        buffer |= code << bits
        bits += 9
        while bits >= 8:
            out.append(buffer & 255)
            buffer >>= 8
            bits -= 8
    if bits:
        out.append(buffer & 255)
    return bytes(out)


def write_gif(path, frames, fps=12):
    h, w = frames[0].shape[:2]
    palette = bytearray([0, 0, 0])
    for r in range(6):
        for g in range(6):
            for b in range(6):
                palette.extend([r * 51, g * 51, b * 51])
    palette.extend(b"\x00" * (768 - len(palette)))
    delay = max(1, round(100 / fps))
    with open(path, "wb") as f:
        f.write(b"GIF89a")
        f.write(w.to_bytes(2, "little") + h.to_bytes(2, "little"))
        f.write(bytes([0xF7, 0, 0]))
        f.write(palette)
        f.write(b"\x21\xFF\x0BNETSCAPE2.0\x03\x01\x00\x00\x00")
        for frame in frames:
            f.write(b"\x21\xF9\x04\x09")
            f.write(delay.to_bytes(2, "little"))
            f.write(b"\x00\x00")
            f.write(b"\x2C\x00\x00\x00\x00")
            f.write(w.to_bytes(2, "little") + h.to_bytes(2, "little"))
            f.write(b"\x00\x08")
            f.write(chunks(lzw_literal_stream(gif_pixels(frame))))
        f.write(b"\x3B")


def make_previews(sheet_path, meta_path, outdir, max_size=128):
    meta = json.loads(Path(meta_path).read_text(encoding="utf-8"))
    size = int(meta["frame_size"][0])
    image = bpy.data.images.load(str(sheet_path), check_existing=False)
    width, height = image.size
    sheet = np.array(image.pixels[:], dtype=np.float32).reshape(height, width, 4)
    sheet = np.flipud(sheet)
    sheet = np.clip(sheet * 255, 0, 255).astype(np.uint8)
    bpy.data.images.remove(image)
    groups = defaultdict(list)
    for entry in meta["frames"]:
        groups[(entry["action"], entry["dir"])].append(entry)
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    for (action, direction), entries in groups.items():
        frames = []
        for e in sorted(entries, key=lambda v: v["index"]):
            crop = sheet[e["y"]:e["y"] + size, e["x"]:e["x"] + size]
            if size > max_size:
                crop = crop[::max(1, size // max_size), ::max(1, size // max_size)]
            elif size < max_size:
                factor = max_size // size
                crop = np.repeat(np.repeat(crop, factor, axis=0), factor, axis=1)
            frames.append(crop)
        suffix = "" if not direction else "_" + direction
        dest = outdir / f"{action}{suffix}.gif"
        write_gif(dest, frames, meta.get("fps", 12))
        print(f"GIF: {dest}")


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("sheet", type=Path)
    parser.add_argument("json", type=Path)
    parser.add_argument("out", type=Path)
    opt = parser.parse_args(args)
    make_previews(opt.sheet, opt.json, opt.out)

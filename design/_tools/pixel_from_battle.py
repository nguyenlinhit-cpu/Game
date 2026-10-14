"""Bản nháp map_base.txt (lưới ký tự 32×32) từ khung idle 0 của sprite trận: thu nhỏ, quy về bảng màu, lật quay phải.

Dùng cho quái chưa có sprite map vẽ tay; sau đó sửa tay map_base.txt rồi chạy pixel_map.py như nhân vật.

Chạy (từ gốc repo):
    blender -b -P design/_tools/pixel_from_battle.py -- --kind quai --id ink_rat --keys "O=#141018,K=#1C1C26,..." \
        [--size 32] [--fit 30] [--flip]

--keys: ký tự=màu, ký tự đầu tiên là viền (pixel2d tự vẽ lại viền ngoài). --fit: cạnh dài nhất của hình (px).
Ghi đè 4_rig2d/map_base.txt (dòng chú thích bảng màu ở đầu file).
"""

import json
from pathlib import Path
import sys

import bpy
import numpy as np

DESIGN = Path(__file__).resolve().parents[1]


def arg(name, default=None):
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    return argv[argv.index(name) + 1] if name in argv else default


def load_rgba(path):
    img = bpy.data.images.load(str(path), check_existing=False)
    w, h = img.size
    a = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)[::-1].copy()
    bpy.data.images.remove(img)
    return a


def hexc(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)], np.float32)


def main():
    kind, ident = arg("--kind", "quai"), arg("--id")
    size, fit = int(arg("--size", 32)), int(arg("--fit", 30))
    keys = dict(kv.split("=") for kv in arg("--keys").split(","))
    folder = DESIGN / kind / ident
    meta = json.loads((folder / "5_render" / f"battle_{ident}.json").read_text(encoding="utf-8"))
    F = meta["frame_size"][0]
    sheet = load_rgba(folder / "5_render" / f"battle_{ident}.png")
    f = sheet[:F, :F]  # idle khung 0
    ys, xs = np.nonzero(f[..., 3] > 0.3)
    f = f[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    h, w = f.shape[:2]
    k = fit / max(h, w)
    th, tw = max(1, round(h * k)), max(1, round(w * k))
    out = np.zeros((th, tw, 4), np.float32)
    for y in range(th):  # trung bình theo ô (premultiplied) – giữ mảng màu, bỏ nét mảnh
        for x in range(tw):
            cell = f[int(y / k):max(int((y + 1) / k), int(y / k) + 1), int(x / k):max(int((x + 1) / k), int(x / k) + 1)]
            a = cell[..., 3]
            out[y, x, 3] = a.mean()
            if a.sum() > 0:
                out[y, x, :3] = (cell[..., :3] * a[..., None]).sum(axis=(0, 1)) / a.sum()
    if arg("--flip") is not None or "--flip" in sys.argv:
        out = out[:, ::-1]
    chars = list(keys)
    pal = np.stack([hexc(keys[c]) for c in chars])
    grid = [["."] * size for _ in range(size)]
    oy, ox = size - 1 - th, (size - tw) // 2  # chừa 1 hàng dưới cho viền
    for y in range(th):
        for x in range(tw):
            if out[y, x, 3] < 0.5:
                continue
            d = ((pal[1:] - out[y, x, :3]) ** 2).sum(axis=1)  # không chọn màu viền khi quy màu
            grid[oy + y][ox + x] = chars[1 + int(d.argmin())]
    head = [f"# {ident} – sprite map {size}×{size}, quay phải. Nháp tự động từ sprite trận (pixel_from_battle.py); "
            f"sửa tay rồi chạy pixel_map.py.",
            "# " + "  ".join(f"{c} {keys[c]}" for c in chars)]
    (folder / "4_rig2d" / "map_base.txt").write_text("\n".join(head + ["".join(r) for r in grid]) + "\n",
                                                     encoding="utf-8")
    print(f"[{ident}] map_base.txt {tw}×{th} trong khung {size}")


main()

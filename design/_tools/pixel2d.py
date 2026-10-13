"""Lõi sprite pixel ngoài map (32×32, boss 48; chỉ hướng phải, ≤ 12 màu, viền 1 px #141018).

Khung gốc vẽ tay dạng lưới ký tự trong 4_rig2d/map_base.txt (mỗi ký tự 1 màu, '.' trống); hoạt ảnh làm bằng cách
dời nhóm pixel (đầu, thân, chân sau/trước), nghiêng, nhấc phần phụ (vạt, bím tóc), nhắm mắt.

Mỗi nhân vật có 4_rig2d/pixel_map.py:
    run({"id": "kiri", "keys": {"O": "#141018", ...}, "eyes": ["#F2A33A"], "skin": "#F6D3BE", "lid": "#5A2A1A",
         "flap_side": "left", "spark": "#FFE08A"})
Tuỳ chọn: size (32), head_ratio (0.58), feet_rows (4), flap_rows (9), flap_width (4), frames (hàm(parts) -> dict).

Chạy (từ gốc repo): blender -b -P design/nhan_vat/<id>/4_rig2d/pixel_map.py
Xuất: 4_rig2d/map_base.png, 5_render/map_<id>.png + .json (hướng "e"), 5_render/preview/map_<action>.gif/.png (×8).
"""

import json
from pathlib import Path
import sys

import bpy
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_gif import write_gif  # noqa: E402

DESIGN = Path(__file__).resolve().parents[1]
FPS = 12
OUTLINE_HEX = "#141018"
ACTIONS = {"idle": 4, "run": 6, "dash": 3, "opener": 5, "technique": 6}
HIT_FRAMES = {"opener": 2}
LOOPS = ["idle", "run"]


def hexc(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)], np.float32)


OUTLINE = hexc(OUTLINE_HEX)


def save_png(path, rgba):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    h, w = rgba.shape[:2]
    img = bpy.data.images.new(path.stem, w, h, alpha=True)
    img.pixels.foreach_set(np.ascontiguousarray(rgba[::-1], dtype=np.float32).ravel())
    img.filepath_raw = str(path)
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def read_grid(path, keys, size):
    """Đọc sprite vẽ tay dạng lưới ký tự (bỏ dòng bắt đầu bằng #)."""
    rows = [r.rstrip("\n") for r in path.read_text(encoding="utf-8").splitlines() if r and not r.startswith("#")]
    f = np.zeros((size, size, 4), np.float32)
    for y, row in enumerate(rows[:size]):
        for x, ch in enumerate(row[:size]):
            if ch in keys:
                f[y, x, :3] = hexc(keys[ch])
                f[y, x, 3] = 1
            elif ch != ".":
                raise SystemExit(f"{path.name}: ký tự '{ch}' ở hàng {y}, cột {x} không có trong bảng màu")
    return f


def outline(f):
    """Viền ngoài 1 px #141018 quanh mọi pixel đặc."""
    solid = f[..., 3] > 0.5
    ring = np.zeros_like(solid)
    ring[1:] |= solid[:-1]
    ring[:-1] |= solid[1:]
    ring[:, 1:] |= solid[:, :-1]
    ring[:, :-1] |= solid[:, 1:]
    ring &= ~solid
    f = f.copy()
    f[ring, :3] = OUTLINE
    f[ring, 3] = 1
    return f


def strip_outline(f):
    """Bỏ viền ngoài cùng (để dời phần rồi vẽ viền lại)."""
    f = f.copy()
    solid = f[..., 3] > 0.5
    pad = np.pad(~solid, 1, constant_values=True)
    near_empty = pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:]
    is_ol = (np.abs(f[..., :3] - OUTLINE).sum(axis=2) < 0.02) & solid
    f[is_ol & near_empty] = 0
    return f


class Parts:
    """Chia sprite thành nhóm: đầu (gồm mũ, tóc, vạt), thân, chân sau, chân trước."""

    def __init__(self, base, cfg):
        self.cfg = cfg
        self.size = base.shape[0]
        self.base = strip_outline(base)
        solid = self.base[..., 3] > 0.5
        rows = np.nonzero(solid.any(axis=1))[0]
        self.top, self.bottom = rows.min(), rows.max()
        h = self.bottom - self.top + 1
        self.neck = self.top + int(round(h * cfg.get("head_ratio", 0.58)))
        self.knee = self.bottom - (cfg.get("feet_rows", 4) - 1)
        feet = solid[self.knee:self.bottom + 1]
        cols = np.nonzero(feet.any(axis=0))[0]
        # tách 2 chân theo khe trống giữa chúng (không có thì chia đôi)
        gaps = [c for c in range(cols.min(), cols.max()) if not feet[:, c].any()]
        self.split = cfg.get("feet_split") or (gaps[len(gaps) // 2] if gaps else (cols.min() + cols.max()) // 2)

    def layer(self, which):
        f = np.zeros_like(self.base)
        y = np.arange(self.size)[:, None]
        x = np.arange(self.size)[None, :]
        if which == "head":
            m = y < self.neck
        elif which == "body":
            m = (y >= self.neck) & (y < self.knee)
        elif which == "foot_back":
            m = (y >= self.knee) & (x < self.split)
        else:
            m = (y >= self.knee) & (x >= self.split)
        m = np.broadcast_to(m, f.shape[:2])
        f[m] = self.base[m]
        return f

    def compose(self, head=(0, 0), body=(0, 0), back=(0, 0), front=(0, 0), lean=0, flaps=0, squint=False):
        """Ghép các nhóm với độ dời (dx, dy). lean: nghiêng đầu/thân về trước (px ở đỉnh); flaps: nhấc phần phụ."""
        out = np.zeros_like(self.base)
        for name, (dx, dy) in (("foot_back", back), ("body", body), ("foot_front", front), ("head", head)):
            part = self.layer(name)
            if name in ("head", "body") and lean:
                part = shear(part, lean, self.knee)
            if name == "head" and flaps and self.cfg.get("flap_side"):
                part = flap(part, flaps, self.neck, self.cfg)
            if name == "head" and squint:
                part = close_eyes(part, self.cfg)
            part = shift(part, dy, dx)
            m = part[..., 3] > 0.5
            out[m] = part[m]
        return outline(out)


def shift(a, dy, dx):
    """Dời ảnh (dy, dx) px, phần ra ngoài khung bị bỏ (không vòng sang phía bên kia như np.roll)."""
    out = np.zeros_like(a)
    h, w = a.shape[:2]
    ys, yd = (slice(0, h - dy), slice(dy, h)) if dy >= 0 else (slice(-dy, h), slice(0, h + dy))
    xs, xd = (slice(0, w - dx), slice(dx, w)) if dx >= 0 else (slice(-dx, w), slice(0, w + dx))
    out[yd, xd] = a[ys, xs]
    return out


def shear(part, lean, pivot_row):
    """Nghiêng: hàng càng cao dời càng nhiều (tối đa `lean` px ở đỉnh)."""
    out = np.zeros_like(part)
    rows = np.nonzero((part[..., 3] > 0.5).any(axis=1))[0]
    if not len(rows):
        return part
    top = rows.min()
    for y in range(part.shape[0]):
        k = 0 if y >= pivot_row else int(round(lean * (pivot_row - y) / max(pivot_row - top, 1)))
        out[y:y + 1] = shift(part[y:y + 1], 0, k)
    return out


def flap(part, d, neck, cfg):
    """Phần phụ ở rìa đầu (vạt mũ, bím tóc…) phía flap_side ("left" | "right" | "both") nhấc lên/hạ xuống d px."""
    out = part.copy()
    solid = part[..., 3] > 0.5
    cols = np.nonzero(solid.any(axis=0))[0]
    if not len(cols):
        return part
    w = cfg.get("flap_width", 4)
    lo = max(0, neck - cfg.get("flap_rows", 9))
    hi = cfg.get("flap_bottom", neck)
    side = cfg.get("flap_side")
    ranges = []
    if side in ("left", "both"):
        ranges.append(range(cols.min(), cols.min() + w))
    if side in ("right", "both"):
        ranges.append(range(cols.max() - w + 1, cols.max() + 1))
    for xs in ranges:
        for x in xs:
            col = part[lo:hi, x].copy()
            out[lo:hi, x:x + 1] = shift(col[:, None], -d, 0)
    return out


def close_eyes(part, cfg):
    """Nhắm mắt: pixel màu mắt trong vùng da mặt thành 1 nét mí (màu lid), phần dưới thành màu da."""
    eyes = [hexc(e) for e in cfg.get("eyes", [])]
    if not eyes:
        return part
    out = part.copy()
    skin_c = hexc(cfg["skin"])
    eye = np.zeros(part.shape[:2], bool)
    for e in eyes:
        eye |= np.abs(part[..., :3] - e).sum(axis=2) < 0.05
    skin = np.abs(part[..., :3] - skin_c).sum(axis=2) < 0.05
    ys, xs = np.nonzero(skin)
    if not len(ys):
        return part
    face = np.zeros_like(eye)
    face[ys.min():ys.max() + 1, xs.min():xs.max() + 1] = True
    eye &= face & (part[..., 3] > 0.5)
    for y, x in zip(*np.nonzero(eye)):
        below = y + 1 < part.shape[0] and eye[y + 1, x]
        out[y, x, :3] = skin_c if below else hexc(cfg.get("lid", "#2B3550"))
    return out


def speed_lines(f, color):
    """Vệt gió phía sau khi lướt (2–4 px)."""
    solid = f[..., 3] > 0.5
    cols = np.nonzero(solid.any(axis=0))[0]
    x0 = max(0, cols.min() - 1)
    h = f.shape[0]
    for y, ln in ((int(h * 0.36), 4), (int(h * 0.55), 3), (int(h * 0.72), 4)):
        for x in range(max(0, x0 - ln - 1), x0 - 1):
            if not solid[y, x]:
                f[y, x, :3] = hexc(color)
                f[y, x, 3] = 1


def default_frames(p, cfg):
    """Bộ Action chuẩn: idle 4, run 6, dash 3, opener 5 (trúng 2), technique 6."""
    seq = {}
    seq["idle"] = [p.compose(), p.compose(head=(0, 1), body=(0, 0)),
                   p.compose(head=(0, 1), body=(0, 1), flaps=1), p.compose(flaps=1)]
    bob = [0, -1, -1, 0, -1, -1]
    back = [(-1, 0), (0, -1), (1, -1), (1, 0), (0, 0), (-1, 0)]
    front = [(1, 0), (0, 0), (-1, 0), (-1, 0), (0, -1), (1, -1)]
    seq["run"] = [p.compose(head=(0, bob[i]), body=(0, bob[i]), back=back[i], front=front[i], lean=1,
                            flaps=1 if bob[i] else -1) for i in range(6)]
    seq["dash"] = [p.compose(lean=2, head=(1, 0), body=(1, 0), back=(-1, 0), front=(2, 0), flaps=-1),
                   p.compose(lean=2, head=(2, 0), body=(2, 0), back=(0, 0), front=(3, 0), flaps=-1),
                   p.compose(lean=1, head=(1, 0), body=(1, 0), front=(1, 0))]
    for f in seq["dash"][:2]:
        speed_lines(f, cfg.get("spark", "#FFFFFF"))
    seq["opener"] = [p.compose(lean=-1, head=(-1, 0), squint=True),           # lấy đà, nheo mắt
                     p.compose(lean=0, head=(0, 0)),
                     p.compose(lean=1, head=(1, 0), body=(1, 0), front=(1, 0), flaps=-1),  # ra đòn (trúng)
                     p.compose(lean=1, head=(1, 0), body=(1, 0), front=(1, 0)),
                     p.compose()]
    seq["technique"] = [p.compose(), p.compose(head=(0, -1), body=(0, -1)),
                        p.compose(head=(0, -1), body=(0, -1), flaps=1),
                        p.compose(squint=True), p.compose(squint=True, head=(0, 1)),
                        p.compose(squint=True)]
    return seq


def run(cfg):
    ident = cfg["id"]
    folder = DESIGN / cfg.get("kind", "nhan_vat") / cfg.get("folder", ident)
    size = cfg.get("size", 32)
    actions = cfg.get("actions", ACTIONS)
    hit_frames = cfg.get("hit_frames", HIT_FRAMES)
    base = read_grid(folder / "4_rig2d" / "map_base.txt", cfg["keys"], size)
    save_png(folder / "4_rig2d" / "map_base.png", base)
    parts = Parts(base, cfg)
    seq = (cfg.get("frames") or default_frames)(parts, cfg)
    out = folder / "5_render"
    cols = max(actions.values())
    sheet = np.zeros((size * len(actions), size * cols, 4), np.float32)
    meta = {"asset_id": ident, "mode": "map", "frame_size": [size, size],
            "anchor": [0.5, round((parts.bottom + 1) / size, 4)], "fps": FPS,
            "source": f"design/{cfg.get('kind', 'nhan_vat')}/{cfg.get('folder', ident)}/4_rig2d/pixel_map.py "
                      f"(map_base.txt vẽ tay theo 1d_pixel.png)",
            "loop": cfg.get("loops", LOOPS), "hit_frame": hit_frames, "frames": []}
    colors = set()
    zoom = 256 // size
    for r, (action, n) in enumerate(actions.items()):
        frames = seq[action]
        assert len(frames) == n, f"{action}: {len(frames)} khung, cần {n}"
        gif = []
        for i, f in enumerate(frames):
            sheet[r * size:(r + 1) * size, i * size:(i + 1) * size] = f
            meta["frames"].append({"action": action, "dir": "e", "index": i, "x": i * size, "y": r * size})
            colors |= {tuple(np.round(c * 255).astype(int)) for c in f[f[..., 3] > 0.5][:, :3]}
            bg = np.zeros((size, size, 4), np.float32)
            bg[..., :3] = hexc("#3B3348")
            bg[..., 3] = 1
            m = f[..., 3] > 0.5
            bg[m] = f[m]
            gif.append(np.clip(np.repeat(np.repeat(bg, zoom, 0), zoom, 1) * 255 + 0.5, 0, 255).astype(np.uint8))
        write_gif(out / "preview" / f"map_{action}.gif", gif, FPS)
        save_png(out / "preview" / f"map_{action}.png", np.concatenate(gif, axis=1).astype(np.float32) / 255)
    assert len(colors) <= 12, f"{len(colors)} màu > 12"
    save_png(out / f"map_{ident}.png", sheet)
    (out / f"map_{ident}.json").write_text(json.dumps(meta, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"[{ident} map] {sum(actions.values())} khung, {len(colors)} màu → {out / f'map_{ident}.png'}")

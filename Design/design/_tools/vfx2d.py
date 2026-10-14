"""Lõi vẽ hiệu ứng skill 2D bằng code (hàm khoảng cách + tô cel nhiều bậc) và xuất / xem trước.

Mỗi nhân vật có 6_vfx/make_<id>_vfx.py:
    import vfx2d as V
    V.set_palette(main="#E8552B", light="#FFE08A", mid="#F7A23A", deep="#B3222E", core="#FFFBEF")
    from vfx2d import *          # sau set_palette để CORE, LIGHT... là màu của nhân vật
    ... hàm vẽ từng khung (i) -> ảnh RGBA ...
    V.run({"id": "kiri", "element_color": "#E8552B", "battle": {...}, "map": {...},
           "battle_anchors": {...}, "map_anchors": {...}})

battle[skill] = {"frames", "hit_frame", "target": "enemy" | "ally", "cutin": bool,
                 "layers": {"cast"|"hit"|"screen": (khung bắt đầu, số khung, hàm)}}
map[skill]    = {"frames", "hit_frame", "fn": hàm, "char": (x chân, y chân) của nhân vật trong khung 64}

Chạy (từ gốc repo): blender -b -P design/nhan_vat/<id>/6_vfx/make_<id>_vfx.py [-- --only attack,opener]
Xuất vào 6_vfx/: <skill>/<lớp>/<khung>.png (512; screen 1024×576), ultimate/cutin/<khung>.png (1920×540),
<opener|technique>/mapvfx_<skill>_<khung>.png (64×64, ≤ 6 màu), <skill>/<skill>.json,
<skill>/preview_<skill>.gif + .png (ghép với sprite đã render ở 5_render/, chưa có thì ghép ảnh concept).
"""

import json
import math
from pathlib import Path
import random
import sys

import bpy
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_gif import write_gif  # noqa: E402

DESIGN = Path(__file__).resolve().parents[1]
FPS = 12


def hexc(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)], dtype=np.float32)


# Bảng màu đang dùng (đổi bằng set_palette trước khi `from vfx2d import *`)
CORE, LIGHT, MID = hexc("#F4FBFF"), hexc("#CDEBFF"), hexc("#7CC0F2")
MAIN, DEEP, DARK = hexc("#3A8DDE"), hexc("#1F5FB8"), hexc("#14365F")
SHARD, SHARD_EDGE = hexc("#2A2230"), hexc("#5B4A70")
PIXEL_PALETTE = {"C": CORE, "L": LIGHT, "m": MID, "M": MAIN, "D": DEEP, "O": DARK}


def set_palette(main, light, mid, deep, core="#FFFFFF", dark=None):
    """Bảng màu nguyên tố: rìa main → mid → light → lõi core; deep cho viền đậm; dark cho pixel tối nhất."""
    global CORE, LIGHT, MID, MAIN, DEEP, DARK, PIXEL_PALETTE
    CORE, LIGHT, MID, MAIN, DEEP = hexc(core), hexc(light), hexc(mid), hexc(main), hexc(deep)
    DARK = hexc(dark) if dark else DEEP * 0.55
    PIXEL_PALETTE = {"C": CORE, "L": LIGHT, "m": MID, "M": MAIN, "D": DEEP, "O": DARK}


# ---------------------------------------------------------------- vẽ vector

class Canvas:
    """RGBA premultiplied, vẽ ở độ phân giải ×ss rồi thu nhỏ để khử răng cưa."""

    def __init__(self, w, h, ss=2):
        self.w, self.h, self.ss = w, h, ss
        self.px = np.zeros((h * ss, w * ss, 4), dtype=np.float32)

    def shape(self, sdf, bbox, bands, alpha=1.0):
        """sdf(X, Y) âm ở trong; bands = [(ngưỡng, màu), ...] từ ngoài vào trong."""
        if alpha <= 0.003:
            return
        ss = self.ss
        x0 = max(0, int(math.floor(bbox[0] * ss)) - 2)
        y0 = max(0, int(math.floor(bbox[1] * ss)) - 2)
        x1 = min(self.w * ss, int(math.ceil(bbox[2] * ss)) + 2)
        y1 = min(self.h * ss, int(math.ceil(bbox[3] * ss)) + 2)
        if x1 <= x0 or y1 <= y0:
            return
        ys, xs = np.mgrid[y0:y1, x0:x1]
        d = sdf((xs + 0.5) / ss, (ys + 0.5) / ss)
        dst = self.px[y0:y1, x0:x1]
        for thr, col in bands:
            cov = (np.clip((thr - d) * ss + 0.5, 0, 1) * alpha)[..., None]
            if not cov.any():
                continue
            src = np.concatenate([col, [1.0]]).astype(np.float32)
            dst[:] = src * cov + dst * (1 - cov)

    def glow(self, cx, cy, r, col, strength):
        """Quầng sáng mềm (dùng ít, cho lõi phát sáng)."""
        if strength <= 0.003:
            return
        ss = self.ss
        x0, y0 = max(0, int((cx - r) * ss)), max(0, int((cy - r) * ss))
        x1, y1 = min(self.w * ss, int((cx + r) * ss) + 1), min(self.h * ss, int((cy + r) * ss) + 1)
        if x1 <= x0 or y1 <= y0:
            return
        ys, xs = np.mgrid[y0:y1, x0:x1]
        t = 1 - np.hypot((xs + 0.5) / ss - cx, (ys + 0.5) / ss - cy) / r
        cov = (np.clip(t, 0, 1) ** 2 * strength)[..., None]
        dst = self.px[y0:y1, x0:x1]
        src = np.concatenate([col, [1.0]]).astype(np.float32)
        dst[:] = src * cov + dst * (1 - cov)

    def tint(self, col, alpha):
        src = np.concatenate([col, [1.0]]).astype(np.float32)
        self.px[:] = src * alpha + self.px * (1 - alpha)

    def result(self):
        ss = self.ss
        a = self.px.reshape(self.h, ss, self.w, ss, 4).mean(axis=(1, 3))
        out = a.copy()
        m = a[..., 3:4] > 1e-4
        out[..., :3] = np.where(m, a[..., :3] / np.maximum(a[..., 3:4], 1e-4), 0)
        return np.clip(out, 0, 1)


def bands(size):
    """3 bậc cel: viền màu chính → sáng → lõi gần trắng."""
    return [(0, MAIN), (-0.3 * size, LIGHT), (-0.62 * size, CORE)]


def bands_deep(size):
    return [(0, DEEP), (-0.18 * size, MAIN), (-0.45 * size, LIGHT), (-0.75 * size, CORE)]


def circle(c, cx, cy, r, bands, alpha=1.0):
    c.shape(lambda X, Y: np.hypot(X - cx, Y - cy) - r, (cx - r, cy - r, cx + r, cy + r), bands, alpha)


def ellipse(c, cx, cy, rx, ry, bands, alpha=1.0):
    k = min(rx, ry)
    c.shape(lambda X, Y: (np.hypot((X - cx) / rx, (Y - cy) / ry) - 1) * k,
            (cx - rx, cy - ry, cx + rx, cy + ry), bands, alpha)


def ring(c, cx, cy, r, w, bands, alpha=1.0, sy=1.0):
    c.shape(lambda X, Y: np.abs(np.hypot(X - cx, (Y - cy) / sy) - r) - w / 2,
            (cx - r - w, cy - (r + w) * sy, cx + r + w, cy + (r + w) * sy), bands, alpha)


def _seg(X, Y, ax, ay, bx, by):
    px, py, vx, vy = X - ax, Y - ay, bx - ax, by - ay
    h = np.clip((px * vx + py * vy) / max(vx * vx + vy * vy, 1e-6), 0, 1)
    return np.hypot(px - vx * h, py - vy * h), h


def capsule(c, ax, ay, bx, by, ra, rb, bands, alpha=1.0):
    """Đoạn thẳng có bán kính thay đổi từ ra (đầu a) tới rb (đầu b)."""
    def sdf(X, Y):
        d, h = _seg(X, Y, ax, ay, bx, by)
        return d - (ra + (rb - ra) * h)
    r = max(ra, rb)
    c.shape(sdf, (min(ax, bx) - r, min(ay, by) - r, max(ax, bx) + r, max(ay, by) + r), bands, alpha)


def polyline(c, pts, radii, bands, alpha=1.0):
    if len(pts) < 2:
        return
    def sdf(X, Y):
        d = None
        for (ax, ay), (bx, by), ra, rb in zip(pts, pts[1:], radii, radii[1:]):
            s, h = _seg(X, Y, ax, ay, bx, by)
            s = s - (ra + (rb - ra) * h)
            d = s if d is None else np.minimum(d, s)
        return d
    r = max(radii)
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    c.shape(sdf, (min(xs) - r, min(ys) - r, max(xs) + r, max(ys) + r), bands, alpha)


def drop(c, x, y, r, length, angle, bands, alpha=1.0):
    """Giọt / tia: đầu tròn ở (x, y), đuôi nhọn ngược hướng bay `angle` (radian, 0 = sang phải)."""
    tx, ty = x - math.cos(angle) * length, y - math.sin(angle) * length
    capsule(c, x, y, tx, ty, r, 0.6, bands, alpha)


def star(c, cx, cy, size, bands, alpha=1.0, rot=0.0):
    """Lấp lánh 4 cánh."""
    w = size * 0.22
    co, si = math.cos(rot), math.sin(rot)
    def sdf(X, Y):
        u, v = (X - cx) * co + (Y - cy) * si, -(X - cx) * si + (Y - cy) * co
        a = np.abs(u) / size + np.abs(v) / w
        b = np.abs(u) / w + np.abs(v) / size
        return (np.minimum(a, b) - 1) * w
    c.shape(sdf, (cx - size, cy - size, cx + size, cy + size), bands, alpha)


def star5(c, cx, cy, r, bands, alpha=1.0, rot=0.0, inner=0.45):
    """Ngôi sao 5 cánh (đa giác lõm) – sdf gần đúng theo góc."""
    def sdf(X, Y):
        dx, dy = X - cx, Y - cy
        ang = np.arctan2(dy, dx) - rot + math.pi / 2
        seg = math.tau / 5
        a = np.mod(ang, seg) - seg / 2
        # bán kính biên theo góc: nội suy tuyến tính giữa đỉnh (r) và chỗ lõm (r * inner)
        k = np.abs(a) / (seg / 2)
        edge = inner * r + (r - inner * r) * (1 - k) ** 1.6
        return (np.hypot(dx, dy) - edge) * 0.8
    c.shape(sdf, (cx - r, cy - r, cx + r, cy + r), bands, alpha)


def plus(c, cx, cy, size, alpha=1.0):
    """Dấu cộng hồi máu: viền đậm, thân sáng."""
    t = size * 0.34
    def sdf(X, Y):
        def box(hw, hh):
            qx, qy = np.abs(X - cx) - hw, np.abs(Y - cy) - hh
            return np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - t * 0.25
        return np.minimum(box(size, t), box(t, size))
    c.shape(sdf, (cx - size - 3, cy - size - 3, cx + size + 3, cy + size + 3),
            [(1.5, DEEP), (0, MID), (-t * 0.35, CORE)], alpha)


def polygon(c, pts, bands, alpha=1.0):
    """Đa giác lồi (đỉnh theo thứ tự bất kỳ quanh tâm)."""
    cx = sum(p[0] for p in pts) / len(pts)
    cy = sum(p[1] for p in pts) / len(pts)
    edges = []
    for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]):
        ex, ey = bx - ax, by - ay
        ln = math.hypot(ex, ey) or 1.0
        sign = -1.0 if ((cx - ax) * ey - (cy - ay) * ex) > 0 else 1.0
        edges.append((ax, ay, ex * sign / ln, ey * sign / ln))

    def sdf(X, Y):
        d = None
        for ax, ay, ex, ey in edges:
            s = (X - ax) * ey - (Y - ay) * ex
            d = s if d is None else np.maximum(d, s)
        return d
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    c.shape(sdf, (min(xs) - 3, min(ys) - 3, max(xs) + 3, max(ys) + 3), bands, alpha)


def arrow_up(c, cx, cy, size, cols, alpha=1.0):
    """Mũi tên đi lên (tăng chỉ số), tâm (cx, cy), cao 2×size: cols = (viền, thân, lõi)."""
    head = [(cx, cy - size), (cx + size * 0.75, cy - size * 0.1), (cx - size * 0.75, cy - size * 0.1)]
    shaft = [(cx - size * 0.3, cy - size * 0.15), (cx + size * 0.3, cy - size * 0.15),
             (cx + size * 0.3, cy + size), (cx - size * 0.3, cy + size)]
    for pts in (shaft, head):
        polygon(c, pts, [(2.0, cols[0]), (0, cols[1])], alpha)
    polygon(c, [(cx, cy - size * 0.62), (cx + size * 0.3, cy - size * 0.22), (cx - size * 0.3, cy - size * 0.22)],
            [(0, cols[2])], alpha)
    polygon(c, [(cx - size * 0.1, cy - size * 0.1), (cx + size * 0.1, cy - size * 0.1),
                (cx + size * 0.1, cy + size * 0.8), (cx - size * 0.1, cy + size * 0.8)], [(0, cols[2])], alpha)


def leaf(c, x, y, size, ang, bands, alpha=1.0):
    """Chiếc lá: thon hai đầu, dài 2×size theo hướng ang (radian), tâm (x, y)."""
    dx, dy = math.cos(ang) * size, math.sin(ang) * size
    polyline(c, [(x - dx, y - dy), (x - dx * 0.2, y - dy * 0.2), (x + dx, y + dy)],
             [0.6, size * 0.42, 0.6], bands, alpha)


def bubble(c, cx, cy, r, alpha=1.0):
    ring(c, cx, cy, r, max(2.2, r * 0.3), [(0, MID), (-0.6, CORE)], alpha)
    circle(c, cx - r * 0.38, cy - r * 0.38, max(1.0, r * 0.22), [(0, CORE)], alpha)


def shard(c, cx, cy, size, rot, alpha=1.0):
    """Mảnh hiệu ứng xấu vỡ ra (tam giác tối)."""
    pts = [(math.cos(rot + k * 2.3) * size * (1.0 if k == 0 else 0.55),
            math.sin(rot + k * 2.3) * size * (1.0 if k == 0 else 0.55)) for k in range(3)]
    pts = [(cx + x, cy + y) for x, y in pts]
    edges = []
    for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]):
        ex, ey = bx - ax, by - ay
        ln = math.hypot(ex, ey)
        # dấu chọn sao cho tâm tam giác nằm phía âm (bên trong)
        sign = -1.0 if ((cx - ax) * ey - (cy - ay) * ex) > 0 else 1.0
        edges.append((ax, ay, ex * sign / ln, ey * sign / ln))

    def sdf(X, Y):
        d = None
        for ax, ay, ex, ey in edges:
            s = (X - ax) * ey - (Y - ay) * ex
            d = s if d is None else np.maximum(d, s)
        return d
    c.shape(sdf, (cx - size, cy - size, cx + size, cy + size), [(1.2, SHARD_EDGE), (0, SHARD)], alpha)


def cloud(c, cx, cy, w, h, seed, alpha=1.0, rows=2):
    """Đám mây: nhiều cụm tròn, mép trên sáng, đáy phẳng màu đậm hơn."""
    rnd = random.Random(seed)
    puffs = []
    n = max(3, int(w / (h * 0.8)))
    for i in range(n):
        px = cx - w / 2 + (i + 0.5) * w / n + rnd.uniform(-6, 6)
        r = h * rnd.uniform(0.45, 0.7) * (0.75 + 0.25 * math.sin(math.pi * (i + 0.5) / n))
        puffs.append((px, cy - r * 0.35, r))
    if rows > 1:
        for i in range(n - 1):
            px = cx - w / 2 + (i + 1) * w / n
            puffs.append((px, cy - h * 0.55, h * rnd.uniform(0.35, 0.5)))
    def sdf(X, Y):
        d = None
        for px, py, r in puffs:
            s = np.hypot(X - px, Y - py) - r
            d = s if d is None else np.minimum(d, s)
        return np.maximum(d, Y - (cy + h * 0.25))  # đáy phẳng
    bbox = (cx - w / 2 - h, cy - h * 1.3, cx + w / 2 + h, cy + h * 0.3)
    c.shape(sdf, bbox, [(0, MID), (-max(2.0, h * 0.07), LIGHT)], alpha)
    lift = h * 0.2
    c.shape(lambda X, Y: np.maximum(sdf(X, Y) + max(2.0, h * 0.07), -sdf(X, Y - lift)), bbox, [(0, CORE)], alpha)
    c.shape(lambda X, Y: np.maximum(sdf(X, Y) + max(2.0, h * 0.07), (cy + h * 0.08) - Y), bbox, [(0, MID)],
            alpha * 0.8)


def rain(c, x0, x1, y0, y1, t, seed, density, length, alpha, angle=math.radians(100), speed=60):
    """Mưa sáng rơi chéo (vệt dài + vài lấp lánh)."""
    rnd = random.Random(seed)
    span = y1 - y0
    dx, dy = math.cos(angle), math.sin(angle)
    for k in range(density):
        bx = rnd.uniform(x0 - span * 0.25, x1)
        off = rnd.uniform(0, span)
        y = y0 + (off + t * speed) % span
        x = bx + (y - y0) * dx / dy
        L = length * rnd.uniform(0.7, 1.2)
        capsule(c, x, y, x - dx * L, y - dy * L, 2.6, 0.8, [(0, MID), (-1.2, CORE)], alpha * rnd.uniform(0.7, 1))
        if rnd.random() < 0.18:
            star(c, x, y, 6, [(0, LIGHT), (-0.6, CORE)], alpha)


def fade(i, n, keep=0.45):
    """1 cho phần đầu, tan dần ở cuối."""
    t = i / max(n - 1, 1)
    return 1.0 if t <= keep else max(0.0, 1 - (t - keep) / (1 - keep)) ** 0.8


def bezier(p0, p1, p2, t):
    return tuple((1 - t) ** 2 * a + 2 * (1 - t) * t * b + t * t * d for a, b, d in zip(p0, p1, p2))


# ---------------------------------------------------------------- ảnh

def load_rgba(path):
    img = bpy.data.images.load(str(path), check_existing=False)
    w, h = img.size
    a = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)[::-1].copy()
    bpy.data.images.remove(img)
    return a


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


def resize(a, w, h, nearest=False):
    H, W = a.shape[:2]
    if nearest:
        yi = np.minimum((np.arange(h) + 0.5) * H / h, H - 1).astype(int)
        xi = np.minimum((np.arange(w) + 0.5) * W / w, W - 1).astype(int)
        return a[yi][:, xi]
    while W >= 2 * w and H >= 2 * h:  # thu nhỏ nhiều: lấy trung bình theo ô trước cho mịn
        a = a[:H // 2 * 2, :W // 2 * 2].reshape(H // 2, 2, W // 2, 2, -1).mean(axis=(1, 3))
        H, W = a.shape[:2]
    ys = np.clip((np.arange(h) + 0.5) * H / h - 0.5, 0, H - 1)
    xs = np.clip((np.arange(w) + 0.5) * W / w - 0.5, 0, W - 1)
    y0, x0 = ys.astype(int), xs.astype(int)
    y1, x1 = np.minimum(y0 + 1, H - 1), np.minimum(x0 + 1, W - 1)
    fy, fx = (ys - y0)[:, None, None], (xs - x0)[None, :, None]
    top = a[y0][:, x0] * (1 - fx) + a[y0][:, x1] * fx
    bot = a[y1][:, x0] * (1 - fx) + a[y1][:, x1] * fx
    return top * (1 - fy) + bot * fy


def over(dst, src, x, y, alpha=1.0):
    """Đặt ảnh RGBA thường (không premultiplied) lên dst tại (x, y)."""
    h, w = src.shape[:2]
    H, W = dst.shape[:2]
    sx0, sy0 = max(0, -x), max(0, -y)
    dx0, dy0 = max(0, x), max(0, y)
    dx1, dy1 = min(W, x + w), min(H, y + h)
    if dx1 <= dx0 or dy1 <= dy0:
        return
    s = src[sy0:sy0 + dy1 - dy0, sx0:sx0 + dx1 - dx0]
    a = s[..., 3:4] * alpha
    d = dst[dy0:dy1, dx0:dx1]
    out_a = a + d[..., 3:4] * (1 - a)
    d[..., :3] = (s[..., :3] * a + d[..., :3] * d[..., 3:4] * (1 - a)) / np.maximum(out_a, 1e-5)
    d[..., 3:4] = out_a


def to_u8(a):
    return np.clip(a * 255 + 0.5, 0, 255).astype(np.uint8)


def battle_cutout(folder):
    """Ảnh 1a_battle bỏ nền trắng, thu về cao 400 px (dùng khi chưa có sprite trận)."""
    a = load_rgba(folder / "1_concept" / "1a_battle.png")
    fg = a[..., :3].min(axis=2) < 0.93
    ys, xs = np.nonzero(fg)
    a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    a = resize(a, int(a.shape[1] * 400 / a.shape[0]), 400)
    a = np.pad(a, ((2, 2), (2, 2), (0, 0)), constant_values=1.0)
    white = a[..., :3].min(axis=2) > 0.9
    bg = np.zeros_like(white)
    bg[0, :] = bg[-1, :] = bg[:, 0] = bg[:, -1] = True
    bg &= white
    while True:
        grown = bg.copy()
        grown[1:] |= bg[:-1]
        grown[:-1] |= bg[1:]
        grown[:, 1:] |= bg[:, :-1]
        grown[:, :-1] |= bg[:, 1:]
        grown &= white
        if (grown == bg).all():
            break
        bg = grown
    edge = np.zeros_like(bg)
    edge[1:] |= bg[:-1]
    edge[:-1] |= bg[1:]
    edge[:, 1:] |= bg[:, :-1]
    edge[:, :-1] |= bg[:, 1:]
    edge &= ~bg
    soft = np.clip((1.0 - a[..., :3].min(axis=2)) / 0.25, 0, 1)
    a[..., 3] = np.where(bg, 0.0, np.where(edge, soft, 1.0))
    return a[2:-2, 2:-2]


def map_cutout(folder):
    a = load_rgba(folder / "1_concept" / "1d_pixel.png")
    ys, xs = np.nonzero(a[..., 3] > 0.5)
    a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    w = max(1, round(a.shape[1] * 32 / a.shape[0]))
    a = resize(a, w, 32, nearest=True)
    a[..., 3] = (a[..., 3] > 0.5).astype(np.float32)
    return a


def cutin_frames(folder, n=10):
    """Dải giữa 1920×540 cắt từ 1e_splash, trượt phải → trái 0,8 s, nền màu nguyên tố."""
    src = load_rgba(folder / "1_concept" / "1e_splash.png")
    W, H = 1920, 540
    full = resize(src, W, round(src.shape[0] * W / src.shape[1]))
    top = (full.shape[0] - H) // 2
    strip = full[top:top + H]
    frames = []
    for i in range(n):
        t = i / (n - 1)
        ease = 1 - (1 - t) ** 3
        base = np.zeros((H, W, 4), dtype=np.float32)
        base[..., :3] = MAIN
        base[..., 3] = 1
        rnd = random.Random(i)
        for k in range(26):  # vệt tốc độ sáng trên nền
            y = rnd.randrange(0, H)
            x0 = rnd.randrange(0, W)
            ln = rnd.randrange(200, 700)
            base[y:y + rnd.randrange(2, 6), x0:x0 + ln, :3] = LIGHT if k % 3 else CORE
        x = int(W * 0.75 * (1 - ease))
        over(base, strip, x, 0)
        if x > 0:  # mép trái của dải có viền sáng
            base[:, max(0, x - 8):x, :3] = CORE
        frames.append(base)
    return frames


def blit(px, pattern, x, y, flip_v=False, flip_h=False):
    """Vẽ mẫu pixel (ký tự trong PIXEL_PALETTE, '.' = trống)."""
    rows = pattern[::-1] if flip_v else pattern
    for j, row in enumerate(rows):
        row = row[::-1] if flip_h else row
        for k, ch in enumerate(row):
            if ch == ".":
                continue
            X, Y = x + k, y + j
            if 0 <= X < px.shape[1] and 0 <= Y < px.shape[0]:
                px[Y, X, :3] = PIXEL_PALETTE[ch]
                px[Y, X, 3] = 1


# ---------------------------------------------------------------- xuất + xem trước

class _Ctx:
    def __init__(self, cfg):
        self.cfg = cfg
        self.id = cfg["id"]
        self.folder = DESIGN / cfg.get("kind", "nhan_vat") / cfg.get("folder", self.id)
        self.out = self.folder / "6_vfx"
        self._sheets = {}

    def sprite_frames(self, mode, action):
        """Khung sprite đã render trong 5_render/ (None nếu chưa có)."""
        sheet_path = self.folder / "5_render" / f"{mode}_{self.id}.png"
        meta_path = sheet_path.with_suffix(".json")
        if not sheet_path.exists() or not meta_path.exists():
            return None
        if mode not in self._sheets:
            self._sheets[mode] = (json.loads(meta_path.read_text(encoding="utf-8")), load_rgba(sheet_path))
        meta, sheet = self._sheets[mode]
        w, h = meta["frame_size"]
        cells = sorted((e for e in meta["frames"] if e["action"] == action), key=lambda e: e["index"])
        return [sheet[e["y"]:e["y"] + h, e["x"]:e["x"] + w] for e in cells] or None


def preview_battle(ctx, name, layers, total, cut=None, target="enemy"):
    """Ghép: nhân vật bên trái (lớp cast), mục tiêu bên phải (lớp hit), screen phủ cả màn hình 1024×576."""
    acting = ctx.sprite_frames("battle", name)
    idle = ctx.sprite_frames("battle", "idle")
    me_img = battle_cutout(ctx.folder) if acting is None else None
    frames = []
    for f in range(total):
        bg = np.zeros((576, 1024, 4), dtype=np.float32)
        bg[..., :3] = hexc("#2A2E3B")
        bg[..., 3] = 1
        bg[470:, :, :3] = hexc("#353A49")
        ox_m, ox_t, oy = 0, 512, 40  # nhân vật và mục tiêu trong 2 khung 512, chân ở y = 430 + 40
        if acting is not None:
            me = acting[f] if f < len(acting) else idle[(f - len(acting)) % len(idle)]
            over(bg, me, ox_m, oy)
        else:
            over(bg, me_img, ox_m + 256 - me_img.shape[1] // 2, oy + 430 - me_img.shape[0])
        if target == "ally":
            if acting is not None:
                ally = idle[f % len(idle)].copy()
                over_at = (ox_t, oy)
            else:
                ally = me_img.copy()
                over_at = (ox_t + 256 - ally.shape[1] // 2, oy + 430 - ally.shape[0])
            ally[..., :3] = ally[..., :3] * 0.55 + hexc("#8C8FB8") * 0.25
            over(bg, ally, *over_at, 0.9)
        else:
            dummy = Canvas(512, 512, ss=1)
            ellipse(dummy, 256, 300, 95, 140, [(0, hexc("#141018")), (-3, hexc("#4A3A5A"))])
            circle(dummy, 226, 240, 12, [(0, hexc("#E25C5C"))])
            over(bg, dummy.result(), ox_t, oy)
        for layer, (start, imgs) in layers.items():
            k = f - start
            if not 0 <= k < len(imgs):
                continue
            if layer == "cast":
                over(bg, imgs[k], ox_m, oy)
            elif layer == "hit":
                over(bg, imgs[k], ox_t, oy)
            elif layer == "screen":
                over(bg, imgs[k], 0, 0)
        frames.append(to_u8(resize(bg, 512, 288)))
    if cut is not None:
        pre = []
        for c_ in cut:
            bg = np.zeros((288, 512, 4), dtype=np.float32)
            bg[..., :3] = hexc("#14121C")
            bg[..., 3] = 1
            over(bg, resize(c_, 512, 144), 0, 72)
            pre.append(to_u8(bg))
        frames = pre + frames
    return frames


def preview_map(ctx, name, imgs, origin):
    acting = ctx.sprite_frames("map", name)
    char = map_cutout(ctx.folder)
    frames = []
    for i, img in enumerate(imgs):
        bg = np.zeros((64, 64, 4), dtype=np.float32)
        bg[..., :3] = hexc("#3B3348")
        bg[..., 3] = 1
        for y in range(0, 64, 16):  # ô gạch sàn
            for x in range(0, 64, 16):
                if (x // 16 + y // 16) % 2:
                    bg[y:y + 16, x:x + 16, :3] = hexc("#433A52")
        cx, feet = origin
        if acting is not None:
            over(bg, acting[min(i, len(acting) - 1)], cx - 16, feet - 32)
        else:
            over(bg, char, cx - char.shape[1] // 2, feet - char.shape[0])
        over(bg, img, 0, 0)
        frames.append(to_u8(resize(bg, 256, 256, nearest=True)))
    return frames


def save_sheet(path, frames, cols):
    """Ảnh tổng các khung xem trước (để duyệt nhanh trên GitHub)."""
    h, w = frames[0].shape[:2]
    rows = (len(frames) + cols - 1) // cols
    sheet = np.zeros((rows * h, cols * w, 4), dtype=np.float32)
    for k, fr in enumerate(frames):
        y, x = (k // cols) * h, (k % cols) * w
        sheet[y:y + h, x:x + w] = fr.astype(np.float32) / 255
        sheet[y, x:x + w, :] = sheet[y:y + h, x, :] = (0.5, 0.5, 0.55, 1)
    save_png(path, sheet)


def run_battle(ctx, name, spec):
    out = ctx.out / name
    meta = {"owner": ctx.id, "skill": name, "fps": FPS, "frames": spec["frames"], "hit_frame": spec["hit_frame"],
            "element_color": ctx.cfg.get("element_color"), "anchors": ctx.cfg.get("battle_anchors", {}),
            "layers": {}}
    layers = {}
    for layer, (start, n, fn) in spec["layers"].items():
        imgs = []
        for i in range(n):
            img = fn(i)
            save_png(out / layer / f"{i:02d}.png", img)
            imgs.append(img)
        layers[layer] = (start, imgs)
        meta["layers"][layer] = {"start_frame": start, "frames": n, "size": list(imgs[0].shape[1::-1]),
                                 "placed_at": {"cast": "người dùng (khung trùng khung sprite trận, chân ở anchor)",
                                               "hit": "mục tiêu (khung trùng khung sprite mục tiêu)",
                                               "screen": "giữa màn hình"}[layer]}
        write_gif(out / f"{layer}.gif", [to_u8(resize(im, im.shape[1] // 4, im.shape[0] // 4)) for im in imgs], FPS)
    total = max(s + len(im) for s, im in layers.values())
    cut = None
    if spec.get("cutin"):
        cut = cutin_frames(ctx.folder)
        for i, fr in enumerate(cut):
            save_png(out / "cutin" / f"{i:02d}.png", fr)
        meta["cutin"] = {"frames": len(cut), "size": [1920, 540], "seconds": 0.8,
                         "source": "1_concept/1e_splash.png", "plays": f"trước khung 0 của {name}"}
    frames = preview_battle(ctx, name, layers, total, cut, spec.get("target", "enemy"))
    write_gif(out / f"preview_{name}.gif", frames, FPS)
    save_sheet(out / f"preview_{name}.png", frames, 4)
    (out / f"{name}.json").write_text(json.dumps(meta, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"[{ctx.id} vfx] {name}: {', '.join(f'{k} {len(v[1])}' for k, v in layers.items())}, tổng {total} khung")


def run_map(ctx, name, spec):
    out = ctx.out / name
    imgs = []
    for i in range(spec["frames"]):
        img = spec["fn"](i)
        save_png(out / f"mapvfx_{name}_{i:02d}.png", img)
        imgs.append(img)
    colors = {tuple(to_u8(p)[:3]) for im in imgs for p in im.reshape(-1, 4) if p[3] > 0}
    assert len(colors) <= 6, f"{name}: {len(colors)} màu > 6"
    frames = preview_map(ctx, name, imgs, spec["char"])
    write_gif(out / f"preview_{name}.gif", frames, FPS)
    save_sheet(out / f"preview_{name}.png", frames, len(frames))
    meta = {"owner": ctx.id, "skill": name, "fps": FPS, "frames": spec["frames"], "hit_frame": spec["hit_frame"],
            "size": list(imgs[0].shape[1::-1]), "colors": len(colors), "anchors": ctx.cfg.get("map_anchors", {}),
            "placed_at": "khung 64×64, điểm neo ghi trong anchors (toạ độ pixel trong khung)"}
    (out / f"{name}.json").write_text(json.dumps(meta, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"[{ctx.id} vfx] {name}: {spec['frames']} khung, {len(colors)} màu")


def run(cfg):
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    only = set(argv[argv.index("--only") + 1].split(",")) if "--only" in argv else None
    ctx = _Ctx(cfg)
    for name, spec in cfg.get("battle", {}).items():
        if only is None or name in only:
            run_battle(ctx, name, spec)
    for name, spec in cfg.get("map", {}).items():
        if only is None or name in only:
            run_map(ctx, name, spec)

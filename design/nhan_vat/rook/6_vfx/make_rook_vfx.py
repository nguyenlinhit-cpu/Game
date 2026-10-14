"""Hiệu ứng skill của Rook (Mộc #2E8B57, rìu – mùn gỗ – cây đổ), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/rook/6_vfx/make_rook_vfx.py
    blender -b -P design/nhan_vat/rook/6_vfx/make_rook_vfx.py -- --only attack,opener

Vân gỗ đỏ phát sáng theo tầng Báo Thù: tuyệt kỹ xuất bản 0 tầng (mặc định) và lớp ultimate/hit_rage/ (vân đỏ sáng)
để game chọn theo số tầng.
Xuất vào design/nhan_vat/rook/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

# Cùng bảng màu Mộc với Garren
V.set_palette(main="#2E8B57", light="#C8F2B8", mid="#6CC36A", deep="#1E5E3A", core="#F4FFF0", dark="#4A2E18")
from vfx2d import *  # noqa: E402,F401,F403

WOOD, WOOD_L, WOOD_D = hexc("#7A5232"), hexc("#B88A5A"), hexc("#4A2E18")
DUST, DUST_D = hexc("#B9A68A"), hexc("#8C7A60")
RAGE, RAGE_L = hexc("#C8282A"), hexc("#FF7A5A")

# Điểm neo trong khung trận 512 (Rook quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
AXE = {"attack": [(85, 214), (87, 140), (108, 73), (357, -11), (269, 482), (281, 485), (350, -20), (85, 214)],
       "skill": [(85, 214), (81, 141), (94, 76), (214, -20), (407, -2), (549, 132), (433, 468), (391, 474), (347, 474),
                 (347, 474)],
       "ultimate": [(85, 214), (495, 52), (352, 470), (356, 466), (363, 459), (367, 456), (272, -26), (269, 480),
                    (269, 480), (541, 118), (85, 214), (85, 214)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (232, 187), "eye": (250, 196), "chest": (226, 271),
                  "target_center": (256, 270), "target_feet": (256, 430), "side_targets_in_hit": [(70, 430), (442, 430)],
                  "axe_head_per_frame": AXE}
MAP_ANCHORS = {"opener_origin": (32, 50), "opener_feet": (16, 52), "technique_feet": (16, 52)}


def green(size):
    return [(0, DEEP), (-0.25 * size, MAIN), (-0.55 * size, MID), (-0.8 * size, LIGHT)]


def wood(size):
    return [(0, WOOD_D), (-0.3 * size, WOOD), (-0.7 * size, WOOD_L)]


def dust(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, DUST_D), (-max(1.5, r * 0.3), DUST)], alpha * 0.8)


def splinter(c, x, y, size, ang, alpha):
    dx, dy = math.cos(ang) * size, math.sin(ang) * size
    capsule(c, x - dx, y - dy, x + dx, y + dy, size * 0.28, 0.6, wood(size * 0.28), alpha)


def debris(c, cx, cy, t, n, spread, seed, alpha, leaves=True):
    """Mùn gỗ + đất + lá văng (t: khung từ lúc chạm)."""
    rnd = random.Random(seed)
    for k in range(n):
        a = rnd.uniform(-math.pi * 0.95, -math.pi * 0.05)
        v = rnd.uniform(0.5, 1.0) * spread
        x = cx + math.cos(a) * v * (t + 0.5)
        y = cy + math.sin(a) * v * (t + 0.5) + 9 * t * t
        if k % 3 == 0 and leaves:
            leaf(c, x, y, rnd.uniform(7, 11), a + t, green(4), alpha)
        elif k % 3 == 1:
            splinter(c, x, y, rnd.uniform(8, 13), a + t * 0.8, alpha)
        else:
            dust(c, x, y, rnd.uniform(4, 8), alpha)


def sweep_arc(c, cx, cy, r, a0, a1, w, alpha=1.0):
    n = 16
    pts = [(cx + math.cos(a0 + (a1 - a0) * k / n) * r, cy + math.sin(a0 + (a1 - a0) * k / n) * r) for k in range(n + 1)]
    polyline(c, pts, [max(0.6, w * math.sin(math.pi * k / n)) for k in range(n + 1)], green(w), alpha)


def log(c, x0, y0, x1, y1, w, alpha=1.0, rage=False):
    """Thân cây nằm (đổ): vỏ gỗ, vân, đầu gốc mặt cắt tròn; rage: vân đỏ phát sáng."""
    capsule(c, x0, y0, x1, y1, w, w * 0.85, wood(w), alpha)
    ang = math.atan2(y1 - y0, x1 - x0)
    nx, ny = -math.sin(ang), math.cos(ang)
    for k in (-1, 0, 1):
        o = k * w * 0.45
        col = [(0, RAGE), (-0.8, RAGE_L)] if rage else [(0, WOOD_D)]
        capsule(c, x0 + nx * o, y0 + ny * o, x1 + nx * o * 0.8, y1 + ny * o * 0.8, 1.8 if rage else 1.3, 1.2, col,
                alpha * (0.95 if rage else 0.7))
    if rage:
        c.glow((x0 + x1) / 2, (y0 + y1) / 2, w * 3, RAGE, 0.25 * alpha)
    circle(c, x0, y0, w, [(1.5, WOOD_D), (0, WOOD_L)], alpha)
    ring(c, x0, y0, w * 0.55, 1.6, [(0, WOOD)], alpha)


def canopy(c, x, y, w, h, seed, alpha):
    rnd = random.Random(seed)
    for k in range(max(3, int(w / 40))):
        bx = x - w / 2 + (k + 0.5) * w / max(3, int(w / 40)) + rnd.uniform(-8, 8)
        by = y + rnd.uniform(-h * 0.25, h * 0.15)
        r = h * rnd.uniform(0.45, 0.65)
        circle(c, bx, by, r, [(1.5, hexc("#0E2A1A")), (0, DEEP), (-r * 0.3, MAIN)], alpha)
    for k in range(int(w / 25)):
        leaf(c, x + rnd.uniform(-w / 2, w / 2), y - rnd.uniform(0, h * 0.8), rnd.uniform(5, 8),
             rnd.uniform(-2.5, -0.6), [(0, MID), (-1.5, LIGHT)], alpha * 0.9)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    if i == 3:  # bổ xuống: vệt xanh theo lưỡi rìu
        sweep_arc(c, 300, 220, 220, -1.9, 1.0, 16, 0.9)
    if i >= 4:  # chạm đất trước mặt: mùn gỗ, đất
        debris(c, 300, 430, i - 4, 12, 50, 3, fade(i - 4, 4, 0.2), leaves=False)
    return c.result()


def attack_hit(i):
    """Mùn gỗ và đất tóe trên quái."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    if i == 0:
        c.glow(cx, cy, 90, LIGHT, 0.5)
    debris(c, cx, cy, i, 18, 55, 11, al)
    for k in range(3):
        dust(c, cx - 50 + k * 50, 420 - i * 6, 14 + i * 3, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    if 4 <= i <= 6:  # quét ngang: vệt xanh lá dài
        sweep_arc(c, 330, 260, 210, -1.6 + (i - 4) * 0.4, 1.2, 20 - 2 * (i - 4), 0.9)
    if i >= 7:
        for k in range(3):
            dust(c, 320 + k * 30, 430 - (i - 7) * 8, 12 + (i - 7) * 4, fade(i - 7, 3, 0.2))
    return c.result()


def skill_hit(i):
    """Vệt quét xanh lá + mùn gỗ trên mục tiêu chính và 2 bên (mép khung)."""
    c = Canvas(512, 512)
    al = fade(i, 8, 0.4)
    if i <= 2:
        y = 300
        capsule(c, -20, y + 20, 532, y - 20, 4, 14 - 4 * i, green(14), 0.9 - 0.2 * i)
    for k, (x, y) in enumerate(((256, 300), (70, 320), (442, 320))):
        debris(c, x, y, i, 10 if k == 0 else 6, 45, 20 + k, al)
    return c.result()


def ultimate_cast(i):
    """Cây khổng lồ mọc vụt sau lưng (khung 0–5), chặt gốc: cây đổ về phía quái (6–9)."""
    c = Canvas(512, 512)
    gx, ground = 50, 430
    if i <= 5:
        g = min(1.0, (i + 1) / 4)
        h = 340 * g
        capsule(c, gx, ground, gx + 4, ground - h, 34, 24, wood(30))
        if g > 0.5:
            canopy(c, gx + 20, ground - h, 220 * g, 100 * g, 4, 1.0)
        for k in range(4):  # rễ trồi quanh gốc
            a = math.pi + (k - 1.5) * 0.4
            capsule(c, gx, ground, gx + math.cos(a) * 60 * g, ground + 6 + math.sin(a) * 6, 10, 2, wood(8), 0.9)
    if 6 <= i <= 7:  # cây đổ: xoay quanh gốc về phía phải (khung 8 trở đi thân cây ở lớp hit)
        t = (i - 5) / 3
        ang = -math.pi / 2 + t * (math.pi / 2 - 0.05)
        tx, ty = gx + math.cos(ang) * 340, ground + math.sin(ang) * 340
        log(c, gx, ground - 10, tx, ty, 26)
        canopy(c, tx, ty, 200, 100, 5, 1.0)
    if i >= 10:
        for k in range(4):
            dust(c, 200 + k * 60, 420 - (i - 10) * 10, 18, 0.7)
    return c.result()


def _ultimate_hit(i, rage):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["target_feet"]
    al = fade(i, 8, 0.45)
    if i <= 1:  # thân cây đập xuống
        drop_y = [260, 360][i]
        log(c, -40, drop_y + 10, 560, drop_y - 30, 34, 1.0, rage)
    else:
        log(c, -40, 380, 560, 350, 34, al, rage)
        for k, x in enumerate((256, 70, 442)):
            debris(c, x, 330, i - 1, 10 if k == 0 else 6, 55, 30 + k, al)
    return c.result()


def ultimate_hit(i):
    return _ultimate_hit(i, False)


def ultimate_hit_rage(i):
    """Như hit, vân gỗ đỏ sáng (có tầng Báo Thù)."""
    return _ultimate_hit(i, True)


def ultimate_screen(i):
    """Bóng cây đổ phủ màn hình, lá văng."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6)
    c.tint(hexc("#0E1A12"), 0.3 * al * min(1.0, (i + 1) / 3))  # bóng cây đổ tối dần
    rnd = random.Random(i)
    for k in range(22):
        x = (rnd.uniform(0, 1024) + i * 50) % 1024
        y = rnd.uniform(0, 576)
        leaf(c, x, y, rnd.uniform(8, 13), rnd.uniform(0, 6), green(4), al)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

ROOT_P = ["..m", ".Om", ".O.", "OO."]
CRUMB = ["O"]
VINE = ["mMm", "M.M", "mMm"]


def opener_map(i):
    """Rễ và đất văng hình quạt 120°, tầm 2 ô."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 1:
        blit(px, [".L.", "LCL", ".L."], ox - 1, oy - 20)
    if i in (2, 3):
        r = 10 if i == 2 else 18
        for a in range(-60, 61, 20):
            ra = math.radians(a - 90 + 90)
            x, y = ox + int(round(math.cos(ra) * r)), oy + int(round(math.sin(ra) * r * 0.5)) - 2
            blit(px, ROOT_P, x - 1, y - 3)
    if i >= 2:
        rnd = random.Random(i)
        for k in range(6):
            blit(px, CRUMB if k % 2 else ["M"], ox + rnd.randrange(-6, 22), oy - rnd.randrange(2, 14) + (i - 2) * 3)
    return px


def technique_map(i):
    """Rễ trồi thành hàng dài 4 ô về trước; quái trúng bị dây rễ quấn."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    fx, feet = MAP_ANCHORS["technique_feet"]
    if i >= 2:
        n = min(5, (i - 1) * 2)
        for k in range(n):
            blit(px, ROOT_P, fx + 12 + k * 8, feet - 4)
    if i == 5:
        blit(px, VINE, 56, feet - 10)
        blit(px, VINE, 56, feet - 16)
    return px


V.run({
    "id": "rook", "element_color": "#2E8B57", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "enemy",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "enemy", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
        "ultimate_rage": {"frames": 12, "hit_frame": 8, "target": "enemy",
                          "layers": {"hit": (8, 8, ultimate_hit_rage)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

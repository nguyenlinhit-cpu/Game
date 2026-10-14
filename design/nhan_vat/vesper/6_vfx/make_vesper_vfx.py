"""Hiệu ứng skill của Vesper (Độc #9BC53D, chén độc – kim – sương), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/vesper/6_vfx/make_vesper_vfx.py
    blender -b -P design/nhan_vat/vesper/6_vfx/make_vesper_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/vesper/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#9BC53D", light="#D8F28A", mid="#B8DE5A", deep="#5E8A1E", core="#F6FFE0", dark="#2A3A10")
from vfx2d import *  # noqa: E402,F401,F403

PURPLE, PURPLE_DARK = hexc("#5A3A66"), hexc("#2E2335")
SMOKE, SMOKE_EDGE = hexc("#6E8A4A"), hexc("#4A5E30")
BONE, OUTLINE, SILVER = hexc("#EDE6D6"), hexc("#141018"), hexc("#C9CCD6")

# Điểm neo trong khung trận 512 (Vesper quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
CUP = {"attack": [(365, 165), (362, 162), (359, 159), (377, 173), (380, 175), (373, 170), (365, 165), (365, 165)],
       "skill": [(365, 165), (352, 170), (328, 177), (314, 179), (310, 175), (363, 175), (406, 175), (381, 167),
                 (357, 163), (372, 167)],
       "ultimate": [(365, 165)] * 12}
HAND = {"attack": [(183, 272), (178, 267), (174, 261), (226, 276), (236, 276), (248, 255), (257, 230), (193, 268)],
        "ultimate": [(183, 272), (226, 272), (312, 272), (226, 272), (183, 272), (183, 272), (233, 269), (236, 267),
                     (238, 265), (237, 266), (275, 198), (275, 198)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (255, 175), "eye": (265, 204), "chest": (251, 254),
                  "target_center": (256, 270), "target_feet": (256, 430), "side_targets_in_hit": [(70, 430), (442, 430)],
                  "cup_mouth_per_frame": CUP, "needle_hand_per_frame": HAND}
MAP_ANCHORS = {"opener_origin": (27, 38), "opener_feet": (16, 52), "technique_feet": (32, 56),
               "technique_targets": [(10, 30), (54, 34)]}


def tox(w):
    return [(0, DEEP), (-0.25 * w, MAIN), (-0.55 * w, LIGHT), (-0.8 * w, CORE)]


def bubble_p(c, x, y, r, alpha=1.0):
    """Bong bóng độc: viền xanh, lòng mờ, đốm sáng."""
    circle(c, x, y, r, [(0, MAIN)], alpha * 0.35)
    ring(c, x, y, r, max(2.0, r * 0.22), [(0, DEEP), (-0.8, MAIN)], alpha)
    circle(c, x - r * 0.35, y - r * 0.35, max(1.2, r * 0.22), [(0, CORE)], alpha)


def smoke(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, SMOKE_EDGE), (-max(1.5, r * 0.25), SMOKE)], alpha * 0.7)


def puddle(c, cx, cy, rx, t, seed, alpha=1.0):
    """Vũng độc sủi bọt dưới chân + khói xanh bốc."""
    ellipse(c, cx, cy, rx, rx * 0.2, [(0, DEEP), (-4, MAIN), (-9, LIGHT)], alpha)
    rnd = random.Random(seed)
    for k in range(6):
        x = cx + rnd.uniform(-rx * 0.8, rx * 0.8)
        ph = (t * 0.7 + rnd.uniform(0, 1)) % 1.0
        bubble_p(c, x, cy - 6 - ph * 50, 5 + 7 * (1 - ph), alpha * (1 - ph * 0.6))
    for k in range(3):
        smoke(c, cx - rx * 0.5 + k * rx * 0.5, cy - 30 - t * 14 - k * 8, rx * 0.22 + t * 3, alpha * 0.8)


def needle(c, x, y, ang, L=40, alpha=1.0):
    """Kim tẩm độc: thân bạc, mũi xanh, vệt xanh phía sau."""
    co, si = math.cos(ang), math.sin(ang)
    capsule(c, x - co * L, y - si * L, x, y, 2.2, 1.0, [(1, OUTLINE), (0, SILVER)], alpha)
    capsule(c, x - co * 8, y - si * 8, x + co * 4, y + si * 4, 3, 1, tox(3), alpha)
    capsule(c, x - co * (L + 50), y - si * (L + 50), x - co * L, y - si * L, 0.6, 3, [(0, MAIN), (-1.2, LIGHT)],
            alpha * 0.7)


def skull(c, x, y, s, alpha=1.0):
    """Đầu lâu khói nhỏ."""
    circle(c, x, y, s, [(0, SMOKE_EDGE), (-2, LIGHT)], alpha)
    polygon(c, [(x - s * 0.55, y + s * 0.6), (x + s * 0.55, y + s * 0.6), (x + s * 0.45, y + s * 1.1),
                (x - s * 0.45, y + s * 1.1)], [(0, SMOKE_EDGE), (-1.5, LIGHT)], alpha)
    for dx in (-0.38, 0.38):
        circle(c, x + dx * s, y + s * 0.05, s * 0.26, [(0, DARK)], alpha)
    polygon(c, [(x, y + s * 0.35), (x + s * 0.12, y + s * 0.55), (x - s * 0.12, y + s * 0.55)], [(0, DARK)], alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    hx, hy = HAND["attack"][i]
    if i <= 2:  # kẹp 3 kim: đầu kim sáng xanh
        for k in range(3):
            a = -0.9 + k * 0.25
            star(c, hx + math.cos(a) * 50, hy + math.sin(a) * 50, 6 + 2 * i, [(0, MAIN), (-0.6, CORE)], 0.9, rot=i)
    if i == 3:  # phóng: 3 kim bay
        for k, dy in enumerate((-22, 0, 22)):
            needle(c, 420, 255 + dy + k * 4, 0.02 * (k - 1))
    if i == 4:
        for k, dy in enumerate((-22, 0, 22)):
            capsule(c, 360, 255 + dy, 512, 258 + dy, 0.6, 2.5, [(0, MAIN), (-1, LIGHT)], 0.6)
    if i >= 5:  # chỉnh kính: lấp lánh trên mắt kính
        ex, ey = BATTLE_ANCHORS["eye"]
        star(c, ex + 8, ey - 6, 12 - 2 * (i - 5), [(0, LIGHT), (-0.6, CORE)], 1 - 0.25 * (i - 5), rot=0.4)
    return c.result()


def attack_hit(i):
    """3 kim cắm, giọt độc tóe."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    for k, dy in enumerate((-22, 0, 22)):
        needle(c, cx - 20 + k * 6, cy + dy, 0.02 * (k - 1), 34, al if i else 1.0)
    rnd = random.Random(3)
    for k in range(10):
        a = rnd.uniform(-math.pi * 0.95, -math.pi * 0.05)
        sp = rnd.uniform(30, 60)
        x = cx + math.cos(a) * sp * (i + 0.5)
        y = cy + math.sin(a) * sp * (i + 0.5) + 8 * i * i
        drop(c, x, y, rnd.uniform(4, 7), 14, a + 0.3 * i, tox(6), al)
    if i >= 2:
        smoke(c, cx, cy - 20 - i * 8, 18 + i * 4, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    cx, cy = CUP["skill"][i]
    if i <= 4:  # chén ngang mặt: độc sủi bọt trên miệng chén
        for k in range(2 + i // 2):
            bubble_p(c, cx - 20 + k * 18, cy - 10 - ((i * 12 + k * 17) % 40), 5 + k % 2 * 3, 0.9)
    if i in (5, 6):  # hất chén: 3 dòng độc tóe về phía quái
        t = (i - 4) / 2
        for k, (dy, bend) in enumerate(((-60, -70), (0, -40), (60, -20))):
            pts = [bezier((cx, cy), ((cx + 512) / 2, cy + bend), (512, cy + 90 + dy), u * t) for u in np.linspace(0, 1, 9)]
            polyline(c, pts, [4 + 6 * u for u in np.linspace(0, 1, 9)], tox(9), 0.95)
    if i >= 7:  # lắc chén: giọt rơi
        for k in range(3):
            drop(c, cx - 10 + k * 12, cy + 20 + (i - 7) * 14 + k * 6, 4, 12, math.pi / 2, tox(4), fade(i - 7, 3, 0.2))
    return c.result()


def skill_hit(i):
    """Vũng độc sủi bọt dưới mục tiêu chính và 2 bên (mép khung), khói xanh bốc."""
    c = Canvas(512, 512)
    al = fade(i, 8, 0.55)
    if i == 0:
        for x in (70, 256, 442):
            c.glow(x, 300, 70, LIGHT, 0.5)
            circle(c, x, 300, 22, tox(22))
        return c.result()
    puddle(c, 256, 430, 120, i, 10, al)
    for k, (x, y) in enumerate(BATTLE_ANCHORS["side_targets_in_hit"]):
        puddle(c, x, y, 64, i, 11 + k, al * 0.9)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    if i <= 5:  # xoay áo choàng, sương độc dâng từ mặt đất
        g = (i + 1) / 6
        for k in range(7):
            x = cx - 180 + k * 60
            smoke(c, x, feet - 10 - 30 * g - (k % 2) * 14, 26 + 14 * g, 0.85)
        for k in range(i + 1):
            bubble_p(c, cx - 150 + k * 55, feet - 40 - ((k * 37 + i * 20) % 120), 6 + k % 3 * 2, 0.9)
    if i in (6, 7, 8):  # búng tay: chớp xanh ở đầu ngón
        hx, hy = HAND["ultimate"][i]
        c.glow(hx, hy, 50, LIGHT, 0.6 if i == 7 else 0.35)
        star(c, hx, hy, 18 if i == 7 else 10, [(0, MAIN), (-0.6, CORE)], rot=0.3)
        ring(c, hx, hy, 14 + (i - 6) * 16, 4, tox(3), 1 - (i - 6) * 0.3)
    if i >= 6:
        for k in range(5):
            smoke(c, cx - 150 + k * 75, feet - 30 - (i - 5) * 6, 24, fade(i - 6, 6, 0.0) * 0.7)
    if i >= 10:  # chỉnh mũ: lấp lánh trên vành
        hx, hy = HAND["ultimate"][i]
        star(c, hx + 10, hy - 10, 10, [(0, LIGHT), (-0.6, CORE)], 0.9, rot=i)
    return c.result()


def ultimate_hit(i):
    """Bong bóng độc nổ trên quái + đầu lâu khói nhỏ."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 8, 0.45)
    rnd = random.Random(20)
    for k in range(7):
        x, y = cx + rnd.uniform(-90, 90), cy + rnd.uniform(-110, 90)
        r = rnd.uniform(14, 26)
        if i == 0:
            bubble_p(c, x, y, r)
        elif i <= 2:  # nổ: vòng tóe
            ring(c, x, y, r + 10 * i, 3, tox(3), 1 - 0.3 * i)
            for j in range(5):
                a = j * math.tau / 5 + k
                drop(c, x + math.cos(a) * (r + 12 * i), y + math.sin(a) * (r + 12 * i), 4, 10, a, tox(4), 1 - 0.3 * i)
    if i >= 1:
        smoke(c, cx, cy - 40 - i * 6, 34 + i * 3, al * 0.7)
        skull(c, cx, cy - 150 - i * 6, 26, al)
    return c.result()


def ultimate_screen(i):
    """Sương xanh độc phủ nửa dưới màn hình, bong bóng nổi lên."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6) * min(1.0, (i + 1) / 3)
    top = 576 - 190 * min(1.0, (i + 1) / 4)
    c.shape(lambda X, Y: (top + 16 * np.sin(X / 70 + i * 0.6)) - Y, (0, top - 20, 1024, 576), [(0, MAIN)], 0.15 * al)
    rnd = random.Random(30)
    for k in range(14):
        smoke(c, rnd.uniform(0, 1024), top + rnd.uniform(-10, 40), rnd.uniform(26, 44), al * 0.3)
    for k in range(18):
        x = rnd.uniform(0, 1024)
        y = 576 - ((rnd.uniform(0, 300) + i * 30) % 300)
        bubble_p(c, x, y, rnd.uniform(6, 13), al)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

FLASK = [".D.", "MLM", "MMM"]
SPLAT = ["..m.m..", ".mMLMm.", "mMLCLMm", ".mMMMm.", "..D.D.."]
ZZZ = ["CCC", "..C", ".C.", "CCC"]
SKULL_P = [".LLL.", "LDLDL", ".LLL.", ".L.L."]


def opener_map(i):
    """Lọ độc bay 2,5 ô theo cung, vỡ thành vũng sủi bọt hình quạt hẹp."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    land = (ox + 22, oy + 10)
    if i <= 1:
        blit(px, FLASK, ox - 1 - (1 - i) * 3, oy - 3 - i * 3)
    if i == 2:
        u = 0.6
        x = ox + (land[0] - ox) * u
        y = oy + (land[1] - oy) * u - 12 * math.sin(math.pi * u)
        blit(px, FLASK, int(x) - 1, int(y) - 1)
        blit(px, SPLAT, land[0] - 3, land[1] - 2)
    if i >= 3:
        blit(px, SPLAT, land[0] - 3, land[1] - 2)
        for k in range(3):
            blit(px, ["C"] if (k + i) % 2 else ["L"], land[0] - 2 + k * 2, land[1] - 4 - (i - 3) * 2 - k % 2)
    return px


def technique_map(i):
    """Sương ngủ: sương xanh lan quanh chân (bán kính ~3 ô); quái trúng có chữ Z và dấu độc."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    cx, feet = MAP_ANCHORS["technique_feet"]
    if i <= 2:
        blit(px, [".L.", "LCL"] if i else ["L"], cx + 6, feet - 22 + i)
    if i >= 3:
        r = 10 + (i - 3) * 10
        rnd = random.Random(i)
        for k in range(60):
            a = rnd.uniform(0, math.tau)
            d = rnd.uniform(0, r)
            x, y = cx + int(math.cos(a) * d), feet - 4 + int(math.sin(a) * d * 0.4)
            if 0 <= x < 64 and 0 <= y < 64:
                blit(px, ["m" if k % 3 else "M"], x, y)
    if i == 5:
        for tx, ty in MAP_ANCHORS["technique_targets"]:
            blit(px, ZZZ, tx, ty - 10)
            blit(px, SKULL_P, tx - 1, ty - 4)
    return px


V.run({
    "id": "vesper", "element_color": "#9BC53D", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "enemy",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "enemy", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

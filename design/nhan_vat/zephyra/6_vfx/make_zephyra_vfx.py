"""Hiệu ứng skill của Zephyra (Phong #4FD1B5, gió – quạt – lụa), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/zephyra/6_vfx/make_zephyra_vfx.py
    blender -b -P design/nhan_vat/zephyra/6_vfx/make_zephyra_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/zephyra/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#4FD1B5", light="#C9F5EA", mid="#8FE3CF", deep="#2FA88E", core="#F8FFFD", dark="#17594C")
from vfx2d import *  # noqa: E402,F401,F403

SKY = hexc("#8FD3F4")
PETAL, PETAL_EDGE = hexc("#F7C6D6"), hexc("#D98AA6")
LEAF_COLS = [(0, hexc("#2E8B57")), (-1.5, hexc("#6CC36A"))]
RED, RED_DARK, RED_LIGHT = hexc("#D2312A"), hexc("#7A1018"), hexc("#FF8A6A")

# Điểm neo trong khung trận 512 (Zephyra quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
FAN = {"attack": [(417, 227), (396, 222), (374, 209), (432, 257), (435, 268), (427, 242), (413, 219), (419, 229)],
       "skill": [(417, 224), (317, 224), (133, 224), (317, 224), (417, 225), (418, 216), (419, 213), (430, 247),
                 (431, 282), (426, 258)],
       "ultimate": [(417, 227), (409, 200), (399, 175), (415, 180), (424, 190), (404, 127), (413, 129), (423, 133),
                    (425, 140), (427, 147), (417, 235), (417, 231)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (267, 212), "eye": (279, 224), "chest": (279, 278),
                  "target_center": (256, 270), "fan_center_per_frame": FAN}
MAP_ANCHORS = {"opener_origin": (30, 38), "opener_feet": (16, 52), "technique_feet": (32, 56)}


def wind_stroke(c, cx, cy, r, a0, a1, w, alpha=1.0, sy=1.0):
    """Nét gió cong: cung tròn từ góc a0 tới a1, dày giữa, nhọn hai đầu."""
    n = 14
    pts = [(cx + math.cos(a0 + (a1 - a0) * k / n) * r, cy + math.sin(a0 + (a1 - a0) * k / n) * r * sy)
           for k in range(n + 1)]
    radii = [max(0.6, w * math.sin(math.pi * k / n)) for k in range(n + 1)]
    polyline(c, pts, radii, [(0, MAIN), (-w * 0.35, LIGHT), (-w * 0.7, CORE)], alpha)


def swirl(c, cx, cy, r, rot, alpha=1.0, sy=0.35, w=6.0):
    """Vòng gió xoắn (3 nét cung lệch pha)."""
    for k in range(3):
        a = rot + k * math.tau / 3
        wind_stroke(c, cx, cy, r * (1 - 0.12 * k), a, a + 2.0, w, alpha, sy)


def petal(c, x, y, s, ang, alpha=1.0):
    dx, dy = math.cos(ang) * s, math.sin(ang) * s
    polyline(c, [(x - dx, y - dy), (x, y), (x + dx, y + dy)], [0.6, s * 0.5, 0.6], [(1.2, PETAL_EDGE), (0, PETAL)],
             alpha)


def blade(c, x, y, ang, s, alpha=1.0):
    """Lưỡi gió hình trăng lưỡi liềm, mũi hướng ang."""
    co, si = math.cos(ang), math.sin(ang)
    nx, ny = -si, co
    pts = []
    for k in range(13):
        t = -1 + 2 * k / 12
        pts.append((x + nx * t * s - co * (t * t) * s * 0.55, y + ny * t * s - si * (t * t) * s * 0.55))
    radii = [max(0.6, s * 0.16 * (1 - abs(-1 + 2 * k / 12)) ** 0.7) for k in range(13)]
    c.glow(x, y, s * 1.4, MAIN, 0.2 * alpha)
    polyline(c, pts, radii, [(0, MAIN), (-s * 0.06, LIGHT), (-s * 0.11, CORE)], alpha)


def speed_streak(c, x, y, length, alpha):
    capsule(c, x, y, x - length, y, 3.4, 0.8, [(0, MAIN), (-1.4, CORE)], alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    fx, fy = FAN["attack"][i]
    if i <= 2:  # gập quạt, xoay cổ tay: gió cuộn nhỏ quanh quạt
        swirl(c, fx, fy, 30 + 8 * i, i * 1.2, 0.8, sy=0.8, w=4)
    if i == 3:  # mở bung, phóng lưỡi gió
        c.glow(fx, fy, 60, LIGHT, 0.4)
        blade(c, fx + 60, fy - 6, 0.0, 80)
    if i == 4:
        blade(c, 490, fy - 10, 0.0, 76, 0.9)
        speed_streak(c, 470, fy - 10, 120, 0.6)
    if i >= 5:  # phe phẩy: nét gió nhỏ tan dần
        t = i - 5
        wind_stroke(c, fx + 30, fy, 34 + t * 10, -1.2, 0.6, 4, fade(t, 3, 0.0))
    return c.result()


def attack_hit(i):
    """Gió cắt chéo 2 đường (dấu X), lá bay."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    if i == 0:
        blade(c, cx - 30, cy, 0.0, 84)
        return c.result()
    g = min(1.0, i / 2)
    for k, a in enumerate((math.radians(35), math.radians(-35))):
        if i >= 1 + k * 0.5:
            L = 150 * g
            capsule(c, cx - math.cos(a) * L, cy - math.sin(a) * L, cx + math.cos(a) * L, cy + math.sin(a) * L,
                    1.5, 1.5, [(0, MAIN)], al)
            capsule(c, cx - math.cos(a) * L * 0.8, cy - math.sin(a) * L * 0.8, cx + math.cos(a) * L * 0.8,
                    cy + math.sin(a) * L * 0.8, 7 - i * 0.8, 7 - i * 0.8, [(0, MAIN), (-2, LIGHT), (-4, CORE)], al)
    rnd = random.Random(5)
    for k in range(6):
        a = rnd.uniform(0, math.tau)
        d = 40 + 25 * i
        leaf(c, cx + math.cos(a) * d, cy + math.sin(a) * d * 0.7, 9, a + i, LEAF_COLS, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    if i <= 3:  # xoay một vòng: lụa gió cuộn quanh người
        swirl(c, cx, feet - 140, 150, i * 1.6, 0.9, sy=0.5, w=7)
        for k in range(3):
            petal(c, cx - 120 + k * 120, feet - 220 + 40 * math.sin(i + k), 8, i + k, 0.9)
    if 4 <= i <= 6:  # dải gió từ quạt bay về phía đồng minh (bên phải)
        fx, fy = FAN["skill"][i]
        t = (i - 3) / 3
        for k in range(3):
            y = fy - 30 + k * 30
            x1 = fx + 110 * t + k * 10
            capsule(c, fx, y, min(512, x1 + 60), y - 10 * math.sin(k + i), 2, 6, [(0, MAIN), (-2, LIGHT), (-4, CORE)],
                    0.9)
    if i >= 7:  # cúi chào: vài cánh hoa rơi
        for k in range(4):
            petal(c, 200 + k * 40, 120 + (i - 7) * 25 + k * 12, 8, i * 0.7 + k, fade(i - 7, 3, 0.3))
    return c.result()


def skill_hit(i):
    """Đồng minh: gió xoắn nâng người, vệt tốc độ, mũi tên nhanh."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    for k in range(3):  # gió xoắn từ chân lên
        swirl(c, cx, feet - 30 - k * 90 - i * 6, 120 - k * 18, i * 0.9 + k, al * (1 - k * 0.15), sy=0.3, w=6)
    if 1 <= i <= 5:
        rnd = random.Random(30)
        for k in range(6):
            y = 140 + k * 45 + rnd.uniform(-10, 10)
            x = 160 + (i - 1) * 70 + rnd.uniform(-30, 30)
            speed_streak(c, x, y, rnd.uniform(70, 120), fade(i - 1, 5, 0.3))
    if 1 <= i <= 6:  # mũi tên nhanh (xanh ngọc, hướng sang phải = đi trước)
        y = BATTLE_ANCHORS["chest"][1] - 60
        x = cx + 20 + (i - 1) * 12
        polygon(c, [(x + 40, y), (x + 8, y - 26), (x + 8, y + 26)], [(2, DEEP), (0, MAIN), (-5, CORE)], al)
        polygon(c, [(x + 8, y - 9), (x - 40, y - 9), (x - 40, y + 9), (x + 8, y + 9)], [(2, DEEP), (0, MAIN)], al)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    fx, fy = FAN["ultimate"][i]
    if i <= 5:  # múa quạt, bay lên: gió cuộn dưới chân
        g = (i + 1) / 6
        swirl(c, cx, feet - 20 - 40 * g, 110 + 30 * g, i * 1.3, 0.9, sy=0.25, w=6)
        wind_stroke(c, fx, fy, 40, i * 0.8, i * 0.8 + 2.4, 4, 0.8)
    if 6 <= i <= 9:  # mở quạt thật to: gió lớn thổi về phía đội (sang trái)
        t = (i - 6) / 3
        c.glow(fx, fy, 120, LIGHT, 0.4 * (1 - t))
        rnd = random.Random(i)
        for k in range(7):
            y = 120 + k * 45
            x0 = fx - 40 - t * 200 + rnd.uniform(-20, 20)
            capsule(c, x0, y, max(-10, x0 - 160), y + 6, 6, 1.5, [(0, MAIN), (-2, LIGHT), (-4, CORE)], 0.85 * (1 - 0.4 * t))
        for k in range(5):
            petal(c, fx - 60 - t * 300 + k * 30, 140 + k * 50, 9, 3.4 + k, 0.9)
    if i >= 10:
        swirl(c, cx, feet - 10, 120, i, 0.6 - 0.2 * (i - 10), sy=0.2, w=5)
    return c.result()


def ultimate_hit(i):
    """Đồng minh: vòng gió sáng + mũi tên đỏ (tăng sát thương) + vệt tốc độ."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    g = min(1.0, (i + 1) / 2)
    ring(c, cx, feet - 5, 120 * g, 8, [(0, MAIN), (-2, LIGHT), (-4, CORE)], al, sy=0.3)
    swirl(c, cx, feet - 160, 130, i * 0.8, al * 0.8, sy=0.35, w=5)
    if 1 <= i <= 6:
        for k, (ox, oy, s) in enumerate(((-70, 40, 20), (0, 0, 28), (68, 30, 18))):
            y = BATTLE_ANCHORS["chest"][1] + oy - (i - 1) * 20
            arrow_up(c, cx + ox, y, s, (RED_DARK, RED, RED_LIGHT), fade(i - 1, 6, 0.4))
    if 2 <= i <= 5:
        rnd = random.Random(40)
        for k in range(5):
            y = 150 + k * 50 + rnd.uniform(-10, 10)
            speed_streak(c, 140 + (i - 2) * 80 + rnd.uniform(-20, 20), y, rnd.uniform(70, 110), fade(i - 2, 4, 0.3))
    return c.result()


def ultimate_screen(i):
    """Lá và cánh hoa bay ngang màn hình, đường gió trắng."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6) * min(1.0, (i + 1) / 2)
    rnd = random.Random(7)
    for k in range(10):  # đường gió trắng
        y = rnd.uniform(40, 540)
        x0 = (rnd.uniform(0, 1024) + i * 110) % 1300 - 150
        capsule(c, x0, y, x0 - rnd.uniform(160, 300), y + rnd.uniform(-10, 10), 3, 1, [(0, LIGHT), (-1.2, CORE)],
                al * 0.8)
    for k in range(26):  # lá + cánh hoa trôi từ phải sang trái
        y = rnd.uniform(30, 550) + 20 * math.sin(i * 0.6 + k)
        x = (rnd.uniform(0, 1024) - i * 90) % 1100 - 40
        ang = i * 0.5 + k
        if k % 2:
            petal(c, x, y, rnd.uniform(7, 11), ang, al)
        else:
            leaf(c, x, y, rnd.uniform(8, 12), ang, LEAF_COLS, al)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

LEAF_P = ["Mm", ".M"]


def opener_map(i):
    """Cuộn gió trắng-xanh quạt 120°, tầm 2 ô, lá bay."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i <= 1:
        blit(px, ["L"] if i == 0 else [".L.", "LCL", ".L."], ox - i, oy - i)
    if i in (2, 3):
        for r, col in ((10 if i == 2 else 16, "C"), (13 if i == 2 else 20, "M")):
            for a in range(-60, 61, 6):
                ra = math.radians(a)
                x, y = ox + int(round(math.cos(ra) * r)), oy + int(round(math.sin(ra) * r * 0.85))
                blit(px, [col], x, y)
        for k in range(3):
            blit(px, LEAF_P, ox + 8 + k * 6, oy - 8 + k * 7)
    if i == 4:
        for k in range(4):
            blit(px, LEAF_P if k % 2 else ["m"], ox + 14 + k * 4, oy - 6 + k * 5)
    return px


def technique_map(i):
    """Vòng gió xanh ngọc quanh chân, vệt gió sau lưng."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    cx, feet = MAP_ANCHORS["technique_feet"]
    span = [8, 14, 20, 24, 24, 24][i]
    for k in range(span):
        a = k * math.tau / 24 + i * 0.7
        x, y = cx + int(round(math.cos(a) * 12)), feet - 2 + int(round(math.sin(a) * 4))
        blit(px, ["C" if k % 4 == 0 else "M"], x, y)
    if i >= 3:
        for k, y in enumerate((feet - 18, feet - 10)):
            for x in range(cx - 22 - k * 2, cx - 14):
                blit(px, ["L" if x % 3 else "C"], x, y)
        blit(px, LEAF_P, cx - 20, feet - 24 + i)
    return px


V.run({
    "id": "zephyra", "element_color": "#4FD1B5", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "ally",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "ally", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

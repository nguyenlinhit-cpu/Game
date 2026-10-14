"""Hiệu ứng skill của Aldric (Phong #4FD1B5, khiên buồm – gió nén – lốc), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/aldric/6_vfx/make_aldric_vfx.py
    blender -b -P design/nhan_vat/aldric/6_vfx/make_aldric_vfx.py -- --only attack,opener

Tuyệt kỹ vừa khiên cả đội vừa gây sát thương: lớp hit vẽ khiên gió trên đồng minh, gió cắt trên quái nằm ở lớp screen
(toạ độ màn hình phía quái).
Xuất vào design/nhan_vat/aldric/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

# Cùng bảng màu Phong với Zephyra
V.set_palette(main="#4FD1B5", light="#C9F5EA", mid="#8FE3CF", deep="#2FA88E", core="#F8FFFD", dark="#17594C")
from vfx2d import *  # noqa: E402,F401,F403

STEEL, STEEL_DARK = hexc("#BFC6CF"), hexc("#5A616B")

# Điểm neo trong khung trận 512 (Aldric quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
SHIELD = {"attack": [(394, 271), (382, 276), (367, 281), (412, 287), (429, 293), (417, 282), (402, 271), (393, 271)],
          "skill": [(394, 271), (396, 247), (388, 201), (378, 179), (389, 199), (399, 221), (406, 239), (403, 247),
                    (396, 263), (392, 271)],
          "ultimate": [(394, 271), (398, 283), (397, 304), (400, 315), (405, 316), (403, 316), (405, 317), (407, 317),
                       (403, 316), (403, 316), (402, 316), (398, 315)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (250, 167), "eye": (262, 186), "chest": (250, 259),
                  "target_center": (256, 270), "shield_center_per_frame": SHIELD, "enemy_side_screen": (768, 300)}
MAP_ANCHORS = {"opener_origin": (32, 40), "opener_feet": (16, 52), "technique_feet": (16, 52)}


def wind(w):
    return [(0, MAIN), (-0.35 * w, LIGHT), (-0.7 * w, CORE)]


def wind_stroke(c, cx, cy, r, a0, a1, w, alpha=1.0, sy=1.0):
    n = 14
    pts = [(cx + math.cos(a0 + (a1 - a0) * k / n) * r, cy + math.sin(a0 + (a1 - a0) * k / n) * r * sy)
           for k in range(n + 1)]
    polyline(c, pts, [max(0.6, w * math.sin(math.pi * k / n)) for k in range(n + 1)], wind(w), alpha)


def swirl(c, cx, cy, r, rot, alpha=1.0, sy=0.35, w=6.0):
    for k in range(3):
        a = rot + k * math.tau / 3
        wind_stroke(c, cx, cy, r * (1 - 0.12 * k), a, a + 2.0, w, alpha, sy)


def kite(c, cx, cy, s, alpha=1.0, fill=0.22):
    """Khiên gió hình cánh diều: lớp mờ + khung sáng + gân chéo."""
    pts = [(cx, cy - s * 1.15), (cx + s * 0.8, cy - s * 0.2), (cx, cy + s * 1.2), (cx - s * 0.8, cy - s * 0.2)]
    polygon(c, pts, [(0, MAIN)], alpha * fill)
    poly = pts + pts[:1]
    polyline(c, poly, [max(2.0, s * 0.06)] * len(poly), wind(s * 0.06), alpha)
    capsule(c, cx, cy - s * 1.05, cx, cy + s * 1.1, 1.5, 1.5, [(0, LIGHT)], alpha * 0.8)
    capsule(c, cx - s * 0.7, cy - s * 0.2, cx + s * 0.7, cy - s * 0.2, 1.5, 1.5, [(0, LIGHT)], alpha * 0.8)
    wind_stroke(c, cx, cy + s * 0.2, s * 0.45, -2.6, -0.6, max(2.0, s * 0.05), alpha)


def gust_ring(c, cx, cy, r, w, alpha=1.0, sy=1.0):
    """Luồng gió nén nổ tròn: vòng + nét gió xoáy."""
    ring(c, cx, cy, r, w, wind(w), alpha, sy=sy)
    for k in range(6):
        a = k * math.tau / 6 + r * 0.01
        wind_stroke(c, cx, cy, r * 0.75, a, a + 0.8, w * 0.7, alpha, sy)


def cut(c, cx, cy, ang, L, w, alpha=1.0):
    dx, dy = math.cos(ang) * L, math.sin(ang) * L
    polyline(c, [(cx - dx, cy - dy), (cx, cy), (cx + dx, cy + dy)], [0.6, w, 0.6], wind(w), alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    sx, sy = SHIELD["attack"][i]
    if i <= 2:  # thu khiên về hông: gió tụ trước khiên
        swirl(c, sx + 90, sy, 30 + 8 * i, i * 1.3, 0.8, sy=0.8, w=4)
    if i in (3, 4):  # đâm mép khiên: vệt gió nén phía trước
        for k in range(4):
            capsule(c, sx + 60, sy - 60 + k * 40, sx + 160 + 30 * (i - 3), sy - 60 + k * 40, 1, 4, wind(4), 0.85)
    return c.result()


def attack_hit(i):
    """Luồng gió nén nổ tròn."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.3)
    if i == 0:
        c.glow(cx, cy, 100, CORE, 0.6)
        circle(c, cx, cy, 36, wind(36))
        return c.result()
    gust_ring(c, cx, cy, 40 + 30 * i, max(2.0, 10 - 1.6 * i), al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    sx, sy = SHIELD["skill"][i]
    if i <= 3:  # giương khiên: buồm căng gió
        swirl(c, sx, sy, 80 + 10 * i, i * 1.4, 0.8, sy=0.9, w=5)
    if i in (5, 6):  # ném bản sao khiên gió bay về đồng minh (ra mép phải như mẫu Kiri)
        u = 0.35 if i == 5 else 0.85
        x, y = bezier((sx, sy), (480, 60), (600, 200), u)
        kite(c, x, y, 50, 0.95, 0.3)
    if i >= 5:  # khiên mỏng quanh Aldric
        al = fade(i - 5, 5, 0.5)
        ellipse(c, cx, feet - 175, 175, 215, [(0, MAIN)], al * 0.12)
        ring(c, cx, feet - 175, 175, 4, wind(4), al, sy=215 / 175)
    return c.result()


def skill_hit(i):
    """Đồng minh: khiên gió hình cánh diều xanh ngọc."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.6)
    g = min(1.0, (i + 1) / 2)
    kite(c, cx, feet - 190, 150 * (0.6 + 0.4 * g), al)
    swirl(c, cx, feet - 10, 120, i * 0.8, al * 0.7, sy=0.25, w=5)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    sx, sy = SHIELD["ultimate"][i]
    if i <= 5:  # cắm khiên, buồm bung: gió tụ quanh buồm
        swirl(c, sx, sy, 90 + 20 * min(i, 4), i * 1.2, 0.85, sy=1.0, w=6)
    if 6 <= i <= 9:  # gió bão xoáy quanh đội rồi quét về quái
        t = (i - 6) / 3
        for k in range(3):
            swirl(c, cx - 60, feet - 60 - k * 100, 200 - 20 * k, i * 0.9 + k, 0.9 - 0.2 * t, sy=0.3, w=7)
        for k in range(5):
            capsule(c, sx + 40, 120 + k * 60, 520, 110 + k * 60, 2, 6, wind(6), 0.6 + 0.3 * t)
    if i >= 10:
        swirl(c, cx, feet - 10, 140, i, 0.5, sy=0.2, w=5)
    return c.result()


def ultimate_hit(i):
    """Đồng minh: khiên gió (cánh diều) + lốc nhỏ quanh chân."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.6)
    kite(c, cx, feet - 190, 160, al)
    swirl(c, cx, feet - 20, 130, i * 0.9, al, sy=0.25, w=6)
    return c.result()


def ultimate_screen(i):
    """Lốc xoáy trắng-xanh chạy ngang màn hình; gió cắt trên phe quái (khung trúng = khung 2 của lớp)."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6) * min(1.0, (i + 1) / 2)
    x = -200 + i * 120
    for k in range(5):  # lốc: chồng elip xoáy thu nhỏ dần xuống dưới
        y = 120 + k * 80
        wind_stroke(c, x + k * 8, y, 140 - k * 18, i * 0.8 + k, i * 0.8 + k + 4.5, 9 - k, al, sy=0.28)
    rnd = random.Random(i)
    for k in range(8):
        y = rnd.uniform(60, 540)
        capsule(c, x - 300, y, x - 60, y, 1, 3, [(0, LIGHT), (-1.2, CORE)], al * 0.6)
    if 2 <= i <= 6:  # gió cắt trên quái
        ex, ey = BATTLE_ANCHORS["enemy_side_screen"]
        rnd = random.Random(40)
        for k in range(5):
            cut(c, ex + rnd.uniform(-180, 180), ey + rnd.uniform(-150, 150), rnd.uniform(-0.8, 0.8), 90, 7,
                fade(i - 2, 5, 0.3))
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

SHIELD_ICON = ["..L..", ".LML.", "LMCML", ".LML.", "..L.."]


def opener_map(i):
    """Luồng gió nén hình quạt 140°, tầm 2 ô."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i <= 1:
        blit(px, ["L"] if i == 0 else [".L.", "LCL", ".L."], ox - i, oy - i)
    if i in (2, 3, 4):
        r = [9, 16, 22][i - 2]
        for a in range(-70, 71, 7):
            ra = math.radians(a)
            x, y = ox + int(round(math.cos(ra) * r)), oy + int(round(math.sin(ra) * r * 0.9))
            blit(px, ["C" if a % 21 == 0 else "M"] if i < 4 else ["m"], x, y)
            if i == 2:
                blit(px, ["L"], x - 1, y)
    return px


def technique_map(i):
    """Bức tường gió trắng-xanh trước mặt rồi tan; biểu tượng khiên gió trên đầu."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    fx, feet = MAP_ANCHORS["technique_feet"]
    if i >= 1:
        h = [0, 10, 20, 26, 26, 18][i]
        x0 = fx + 20 + max(0, i - 3) * 5
        for y in range(feet - h, feet + 1):
            for dx in range(3):
                if (y + dx + i) % 3:
                    blit(px, ["C" if dx == 1 else "M"] if i < 5 else ["m"], x0 + dx, y)
    if i >= 3:
        blit(px, SHIELD_ICON, fx - 2, feet - 40)
    return px


V.run({
    "id": "aldric", "element_color": "#4FD1B5", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
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

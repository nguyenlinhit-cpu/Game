"""Hiệu ứng skill của Marisol (Nước #3A8DDE, sóng biển – vỏ ốc), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/marisol/6_vfx/make_marisol_vfx.py
    blender -b -P design/nhan_vat/marisol/6_vfx/make_marisol_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/marisol/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

# Cùng bảng màu Nước với Mira
V.set_palette(main="#3A8DDE", light="#CDEBFF", mid="#7CC0F2", deep="#1F5FB8", core="#F4FBFF", dark="#14365F")
from vfx2d import *  # noqa: E402,F401,F403

FOAM, FOAM_EDGE = hexc("#F4FBFF"), hexc("#A9D3F2")
SHELL, SHELL_EDGE, BRASS = hexc("#EADBC4"), hexc("#B8A68A"), hexc("#C9A04A")
SUN, SUN_RAY = hexc("#FFE6A0"), hexc("#FFF4D6")
TAUNT, TAUNT_EDGE = hexc("#E2453A"), hexc("#7A1018")

# Điểm neo trong khung trận 512 (Marisol quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
SHIELD = {"attack": [(148, 257), (137, 268), (128, 279), (190, 242), (222, 236), (201, 243), (161, 255), (148, 257)],
          "skill": [(148, 257), (153, 263), (169, 272), (181, 274), (180, 274), (179, 274), (179, 274), (164, 266),
                    (160, 251), (149, 257)],
          "ultimate": [(148, 257), (159, 230), (175, 177), (182, 147), (186, 124), (189, 102), (189, 102), (189, 102),
                       (189, 102), (189, 102), (155, 256), (155, 256)]}
RIM = [(196, 209), (187, 205), (172, 204), (165, 208), (163, 206), (161, 205), (161, 205), (185, 199), (213, 209),
       (198, 209)]
BATTLE_ANCHORS = {"feet": (256, 430), "head": (241, 185), "mouth": (248, 209), "chest": (244, 268),
                  "target_center": (256, 270), "shield_center_per_frame": SHIELD, "horn_mouth_per_frame_skill": RIM,
                  "taunt_mark_screen": (768, 150)}
MAP_ANCHORS = {"opener_origin": (26, 40), "opener_feet": (16, 52), "technique_feet": (32, 56)}


def splash(c, cx, cy, t, scale, seed, alpha=1.0):
    """Bọt nước bắn tung: giọt văng theo cung, bọt trắng, rơi dần (t: khung từ lúc chạm)."""
    rnd = random.Random(seed)
    for k in range(12):
        a = rnd.uniform(-math.pi * 0.95, -math.pi * 0.05)
        sp = rnd.uniform(35, 70) * scale
        x = cx + math.cos(a) * sp * (t + 0.6)
        y = cy + math.sin(a) * sp * (t + 0.6) + 10 * t * t * scale
        drop(c, x, y, rnd.uniform(4, 7) * scale, 16 * scale, a + 0.3 * t, bands(6 * scale), alpha)
    for k in range(7):
        a = rnd.uniform(0, math.tau)
        d = rnd.uniform(15, 55) * scale * min(1.0, t + 0.5)
        bubble(c, cx + math.cos(a) * d, cy + math.sin(a) * d * 0.6 - t * 8, rnd.uniform(5, 10) * scale, alpha)


def mini_shell(c, x, y, s, rot, alpha=1.0):
    """Vỏ ốc nhỏ văng ra: thân kem, vòng xoắn đồng."""
    ellipse(c, x, y, s, s * 0.7, [(1.5, SHELL_EDGE), (0, SHELL)], alpha)
    ring(c, x + math.cos(rot) * s * 0.2, y + math.sin(rot) * s * 0.2, s * 0.4, max(1.5, s * 0.18), [(0, BRASS)], alpha)


def wave_crest(c, x0, x1, base, h, phase, alpha=1.0, w=8.0):
    """Mép sóng nhấp nhô từ x0 tới x1 ở độ cao base − h, bọt trắng trên đỉnh."""
    pts = [(x, base - h * (0.75 + 0.25 * math.sin(x / 34 + phase))) for x in np.linspace(x0, x1, 18)]
    polyline(c, pts, [w] * len(pts), bands(w), alpha)
    for k, (x, y) in enumerate(pts[::3]):
        circle(c, x, y - w * 0.4, w * 0.75, [(1.2, FOAM_EDGE), (0, FOAM)], alpha)


def taunt_mark(c, x, y, s, alpha=1.0):
    """Dấu chấm than đỏ (Khiêu Khích)."""
    capsule(c, x, y - s, x, y + s * 0.25, s * 0.32, s * 0.2, [(2.5, TAUNT_EDGE), (0, TAUNT)], alpha)
    circle(c, x, y + s * 0.75, s * 0.24, [(2.5, TAUNT_EDGE), (0, TAUNT)], alpha)


def water_shield(c, cx, cy, rx, ry, alpha=1.0, phase=0.0):
    """Khiên nước trong suốt bao người: lớp mờ + viền sáng + vệt bóng."""
    ellipse(c, cx, cy, rx, ry, [(0, MID)], alpha * 0.18)
    ring(c, cx, cy, rx, 6, [(0, MAIN), (-1.5, LIGHT)], alpha, sy=ry / rx)
    for k in range(3):
        a = phase + k * 2.1
        star(c, cx + math.cos(a) * rx * 0.7, cy + math.sin(a) * ry * 0.7, 9, [(0, LIGHT), (-0.6, CORE)], alpha)
    capsule(c, cx - rx * 0.55, cy - ry * 0.45, cx - rx * 0.3, cy - ry * 0.7, 6, 4, [(0, CORE)], alpha * 0.7)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    sx, sy = SHIELD["attack"][i]
    if i <= 2:  # nước nhỏ giọt từ mép khiên khi nghiêng ra sau
        for k in range(i + 1):
            drop(c, sx - 60 + k * 30, sy + 110 + i * 10 + k * 6, 5, 14, math.pi / 2, bands(5), 0.9)
    if i == 3:  # vệt nước theo khiên lao tới
        polyline(c, [(sx - 70, sy + 30), (sx + 10, sy - 10), (sx + 90, sy - 20)], [3, 9, 13], bands(13), 0.9)
    if i == 4:  # mép khiên chạm (trúng): bọt bắn ở mép trước
        c.glow(sx + 110, sy, 70, LIGHT, 0.5)
        splash(c, sx + 110, sy, 0, 1.0, 3)
    if i >= 5:
        splash(c, SHIELD["attack"][4][0] + 110, SHIELD["attack"][4][1], i - 4, 0.9, 3, fade(i - 5, 3, 0.0))
    return c.result()


def attack_hit(i):
    """Bọt nước bắn tung trên quái, vỏ ốc nhỏ văng ra."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    if i == 0:
        c.glow(cx, cy, 100, CORE, 0.6)
        ring(c, cx, cy, 30, 10, bands(6))
        return c.result()
    splash(c, cx, cy, i, 1.3, 11, al)
    ring(c, cx, cy, 30 + 24 * i, max(2.0, 9 - 1.6 * i), bands(4), al * 0.7)
    rnd = random.Random(12)
    for k in range(4):  # vỏ ốc nhỏ văng
        a = -math.pi * 0.2 - k * 0.55
        d = 40 + 30 * i
        mini_shell(c, cx + math.cos(a) * d, cy + math.sin(a) * d + 7 * i * i, 10, rnd.uniform(0, 6), al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    rx, ry = RIM[i]
    if i <= 3:  # nâng vỏ ốc lên miệng: lấp lánh ở miệng ốc
        star(c, rx, ry, 8 + 3 * i, [(0, LIGHT), (-0.6, CORE)], 0.9, rot=i * 0.5)
    if 4 <= i <= 7:  # thổi tù và: vòng âm sóng toả ra từ miệng ốc
        for k in range(3):
            r = 30 + (i - 4) * 45 + k * 40
            if r < 260:
                al = max(0.0, 1 - r / 260)
                c.shape(lambda X, Y, r=r: np.maximum(np.abs(np.hypot(X - rx, Y - ry) - r) - 4,  # cung ±40° về phải
                                                     (np.abs(Y - ry) - (X - rx) * 0.84) * 0.6),
                        (rx - r - 6, ry - r - 6, rx + r + 6, ry + r + 6), bands(5), al)
    if i >= 7:  # hạ khiên: vài giọt nước rơi
        for k in range(3):
            drop(c, rx - 20 + k * 20, ry + 40 + (i - 7) * 18, 5, 12, math.pi / 2, bands(5), fade(i - 7, 3, 0.2))
    return c.result()


def skill_hit(i):
    """Đồng minh: sóng dâng quanh chân rồi bong bóng nước bao người."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.6)
    rise = min(1.0, (i + 1) / 3)
    if i <= 3:
        wave_crest(c, cx - 150, cx + 150, feet + 10, 40 + 90 * rise, i * 0.9, al)
        for k in range(6):
            drop(c, cx - 140 + k * 56, feet - 60 * rise - k % 2 * 20, 6, 18, -math.pi / 2, bands(6), al)
    if i >= 2:
        water_shield(c, cx, feet - 175, 150, 200, al * min(1.0, (i - 1) / 2), phase=i * 0.4)
        for k in range(4):
            bubble(c, cx - 110 + k * 70, feet - 40 - ((i * 25 + k * 40) % 300), 8 + k % 2 * 4, al)
    return c.result()


def skill_screen(i):
    """Dấu chấm than đỏ trên quái (Khiêu Khích)."""
    c = Canvas(1024, 576, ss=1)
    x, y = BATTLE_ANCHORS["taunt_mark_screen"]
    pop = 1.0 + 0.3 * max(0, 1 - i) if i < 2 else 1.0
    taunt_mark(c, x, y - 4 * math.sin(i), 34 * pop, fade(i, 4, 0.5))
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    sx, sy = SHIELD["ultimate"][i]
    if i <= 9:  # mặt trời sáng phía sau (lệch lên trái để không đè khiên; lớp cast luôn nằm trên sprite)
        g = min(1.0, (i + 1) / 5)
        ux, uy = sx - 120, sy - 40
        c.glow(ux, uy, 230, SUN, 0.3 * g)
        circle(c, ux, uy, 40 * g, [(0, SUN), (-8, SUN_RAY)], 0.6 * g)
        for k in range(10):
            a = k * math.tau / 10 + i * 0.06
            capsule(c, ux + math.cos(a) * 54 * g, uy + math.sin(a) * 54 * g,
                    ux + math.cos(a) * 120 * g, uy + math.sin(a) * 120 * g, 5, 1, [(0, SUN_RAY)], 0.4 * g)
        star(c, sx + 40, sy - 40, 14 + 4 * math.sin(i), [(0, LIGHT), (-0.6, CORE)], 0.9, rot=i * 0.4)
    if 6 <= i <= 9:  # sóng lớn cuộn từ phía sau
        t = (i - 6) / 3
        x1 = -60 + 600 * t
        base = 440
        top = 260 - 40 * math.sin(math.pi * t)
        pts = [(x, base - (base - top) * (0.6 + 0.4 * math.sin(math.pi * max(0.0, min(1.0, (x + 60) / (x1 + 61))))))
               for x in np.linspace(-20, x1, 16)]
        polyline(c, pts, [10] * len(pts), bands(10), 0.95)  # chỉ vẽ mép sóng cuộn; thân nước ở lớp screen
        cx, cy = pts[-1]
        ring(c, cx - 26, cy + 26, 30, 10, bands(8), 0.95)  # mép sóng cuộn
        for x, y in pts[::2]:
            circle(c, x, y - 6, 9, [(1.2, FOAM_EDGE), (0, FOAM)], 0.95)
    if i >= 10:  # lấp lánh còn lại
        for k in range(5):
            star(c, 120 + k * 60, 160 + (k % 2) * 60 - (i - 10) * 10, 8, [(0, LIGHT), (-0.6, CORE)],
                 1 - 0.4 * (i - 10), rot=k)
    return c.result()


def ultimate_hit(i):
    """Đồng minh: khiên nước trong, mảnh hiệu ứng xấu vỡ trôi đi."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.6)
    water_shield(c, cx, feet - 180, 160 * min(1.0, 0.7 + 0.15 * i), 210 * min(1.0, 0.7 + 0.15 * i), al, i * 0.3)
    if 1 <= i <= 6:
        rnd = random.Random(70)
        for k in range(5):
            a = -math.pi / 2 + rnd.uniform(-1.0, 1.0)
            d = 60 + 28 * i
            shard(c, cx + math.cos(a) * d, feet - 200 + math.sin(a) * d, 13, rnd.uniform(0, 6) + i * 0.3,
                  fade(i - 1, 6, 0.3))
    return c.result()


def ultimate_screen(i):
    """Sóng biển dâng phủ nửa dưới màn hình rồi rút."""
    c = Canvas(1024, 576, ss=1)
    h = 230 * math.sin(math.pi * min(1.0, i / 11))  # dâng lên rồi rút
    if h < 4:
        return c.result()
    top = 576 - h
    pts = [(x, top + 14 * math.sin(x / 60 + i * 0.8)) for x in np.linspace(0, 1024, 26)]
    c.shape(lambda X, Y: (top + 14 * np.sin(X / 60 + i * 0.8)) - Y, (0, top - 20, 1024, 576), [(0, MAIN)], 0.34)
    polyline(c, pts, [9] * len(pts), bands(9), 0.85)
    for x, y in pts[::2]:
        circle(c, x, y - 5, 10, [(1.2, FOAM_EDGE), (0, FOAM)], 0.85)
    rnd = random.Random(i)
    for k in range(10):
        bubble(c, rnd.uniform(0, 1024), rnd.uniform(top + 30, 560), rnd.uniform(6, 14), 0.6)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

FOAM_P = ["C"]
DROP_P = ["L", "M"]
SHIELD_ICON = [".DDD.", "DLCLD", "DLLLD", ".DLD.", "..D.."]


def opener_map(i):
    """Sóng vỗ: cung sóng quạt 130° phía trước, tầm 2 ô, bọt trắng."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i <= 1:  # kéo khiên về, xoay người: giọt nước
        for k in range(2 + i):
            blit(px, DROP_P, 4 + k * 3, 36 + (k + i) % 3)
    if i in (2, 3):
        d = 11 if i == 2 else 20
        for a in range(-65, 66, 7):
            r = math.radians(a)
            x, y = ox + int(round(math.cos(r) * d)), oy + int(round(math.sin(r) * d * 0.8))
            blit(px, ["M", "D"] if i == 2 else ["m", "M"], x, y)
            blit(px, FOAM_P if (a // 7) % 2 == 0 else ["L"], x - 1, y - 1)
    if i == 4:
        rnd = random.Random(4)
        for k in range(6):
            a = math.radians(rnd.uniform(-60, 60))
            d = rnd.uniform(14, 24)
            blit(px, DROP_P, ox + int(math.cos(a) * d), oy + int(math.sin(a) * d * 0.8) + 2)
    return px


def technique_map(i):
    """Áo choàng sóng: nước cuộn một vòng quanh người (bán kính 1 ô) rồi tan; khiên nước trên đầu."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    cx, feet = MAP_ANCHORS["technique_feet"]
    cy = feet - 12
    n = 32
    if i <= 4:
        span = [10, 18, 26, 32, 32][i]
        for k in range(span):
            a = k * math.tau / n + i * 0.9
            x, y = cx + int(round(math.cos(a) * 16)), cy + int(round(math.sin(a) * 9))
            blit(px, ["M", "D"] if k % 3 else ["C", "M"], x, y)
            if k % 2 == 0:
                blit(px, ["L"], x, y - 1)
    if i == 5:  # tan: vài giọt
        for k in range(0, n, 3):
            a = k * math.tau / n
            blit(px, ["m"], cx + int(math.cos(a) * 17), cy + int(math.sin(a) * 10) + 2)
    if i >= 3:
        blit(px, SHIELD_ICON, cx - 2, feet - 38)
    return px


V.run({
    "id": "marisol", "element_color": "#3A8DDE", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "ally",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit), "screen": (6, 5, skill_screen)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "ally", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

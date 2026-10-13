"""Hiệu ứng skill của Garren (Mộc #2E8B57, rễ – gỗ – lá), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/garren/6_vfx/make_garren_vfx.py
    blender -b -P design/nhan_vat/garren/6_vfx/make_garren_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/garren/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#2E8B57", light="#C8F2B8", mid="#6CC36A", deep="#1E5E3A", core="#F4FFF0", dark="#4A2E18")
from vfx2d import *  # noqa: E402,F401,F403

WOOD, WOOD_L, WOOD_D = hexc("#7A5232"), hexc("#B88A5A"), hexc("#4A2E18")
BRONZE = hexc("#B8803A")
TAUNT, TAUNT_L = hexc("#D8323C"), hexc("#FF8A80")
DUST, DUST_D = hexc("#B9A68A"), hexc("#8C7A60")

# Điểm neo trong khung trận 512 (Garren quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
SHIELD_FRONT = {"attack": [(483, 331), (478, 311), (472, 291), (500, 341), (507, 356), (505, 335), (483, 331),
                           (483, 331)]}
SHIELD = {"skill": (414, 331), "ultimate": [(414, 331), (407, 312), (392, 279), (383, 261), (379, 252), (374, 244),
                                            (407, 309), (428, 374), (429, 383), (427, 381), (424, 379), (424, 379)]}
SHIELD_BOTTOM_SLAM = (409, 455)
MACE_HEAD_SKILL = [(193, 144), (195, 145), (198, 146), (200, 147), (189, 143), (178, 141), (176, 147), (229, 160),
                   (264, 196), (218, 149)]
MOUTH_SKILL = [(335, 223), (336, 225), (338, 229), (339, 231), (332, 218), (324, 205), (322, 206), (329, 214),
               (335, 223), (335, 223)]
BATTLE_ANCHORS = {"feet": (256, 430), "chest": (284, 271), "head": (300, 168), "target_center": (256, 270),
                  "shield_front_attack": SHIELD_FRONT["attack"], "shield_ultimate": SHIELD["ultimate"],
                  "mace_head_skill": MACE_HEAD_SKILL, "mouth_skill": MOUTH_SKILL}
MAP_ANCHORS = {"opener_origin": (32, 46), "opener_feet": (16, 52), "technique_feet": (16, 52),
               "technique_shield": (25, 48)}


def green(size):
    return [(0, DEEP), (-0.25 * size, MAIN), (-0.55 * size, MID), (-0.8 * size, LIGHT)]


def wood(size):
    return [(0, WOOD_D), (-0.3 * size, WOOD), (-0.7 * size, WOOD_L)]


def dust(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, DUST_D), (-max(1.5, r * 0.3), DUST)], alpha * 0.8)


def splinter(c, x, y, size, ang, alpha):
    """Vụn gỗ: mảnh dài nhọn hai đầu màu gỗ."""
    dx, dy = math.cos(ang) * size, math.sin(ang) * size
    capsule(c, x - dx, y - dy, x + dx, y + dy, size * 0.28, 0.6, wood(size * 0.28), alpha)


def flying_leaves(c, cx, cy, t, n, spread, seed, alpha, size=(7, 12)):
    rnd = random.Random(seed)
    for k in range(n):
        a = rnd.uniform(0, math.tau)
        v = rnd.uniform(0.6, 1.0) * spread
        x = cx + math.cos(a) * v * t
        y = cy + math.sin(a) * v * t + 6 * t * t
        leaf(c, x, y, rnd.uniform(*size), a + t * rnd.uniform(-1, 1), green(4), alpha)


def root(c, x0, y0, length, ang, width, wiggle, seed, alpha, grow=1.0):
    """Rễ cây: đường cong nhỏ dần, màu gỗ tối viền xanh rêu."""
    rnd = random.Random(seed)
    pts, radii = [], []
    steps = 8
    ph = rnd.uniform(0, math.tau)
    for s in range(steps + 1):
        u = s / steps * grow
        x = x0 + math.cos(ang) * length * u - math.sin(ang) * math.sin(u * 7 + ph) * wiggle
        y = y0 + math.sin(ang) * length * u + math.cos(ang) * math.sin(u * 7 + ph) * wiggle
        pts.append((x, y))
        radii.append(max(0.8, width * (1 - u * 0.85)))
    polyline(c, pts, radii, [(1.2, DEEP), (0, WOOD_D), (-width * 0.35, WOOD)], alpha)


def trunk(c, x, ground, h, w, alpha=1.0, lean=0.0):
    """Thân cây mọc từ đất lên (có vân gỗ)."""
    tx = x + lean * h
    capsule(c, x, ground, tx, ground - h, w, w * 0.7, wood(w), alpha)
    for k in range(3):  # vân gỗ
        off = (k - 1) * w * 0.45
        capsule(c, x + off, ground - h * 0.1, tx + off * 0.7, ground - h * 0.85, 1.4, 1.0, [(0, WOOD_D)], alpha * 0.7)


def canopy(c, x, y, w, h, seed, alpha):
    """Tán cây xanh đậm nhiều lớp: cụm tròn tối phía dưới, sáng dần lên trên, vài lá sáng."""
    rnd = random.Random(seed)
    blobs = []
    n = max(3, int(w / 40))
    for k in range(n):
        bx = x - w / 2 + (k + 0.5) * w / n + rnd.uniform(-8, 8)
        by = y + rnd.uniform(-h * 0.25, h * 0.15)
        blobs.append((bx, by, h * rnd.uniform(0.45, 0.65)))
    blobs.append((x + rnd.uniform(-10, 10), y - h * 0.45, h * 0.5))

    def sdf(X, Y):
        d = None
        for bx, by, r in blobs:
            s_ = np.hypot(X - bx, Y - by) - r
            d = s_ if d is None else np.minimum(d, s_)
        return d
    bb = (x - w / 2 - h, y - h * 1.2, x + w / 2 + h, y + h)
    c.shape(sdf, bb, [(1.5, hexc("#0E2A1A")), (0, DEEP), (-h * 0.18, MAIN)], alpha)
    c.shape(lambda X, Y: np.maximum(sdf(X, Y) + h * 0.18, -sdf(X - h * 0.12, Y + h * 0.22) - h * 0.1), bb,
            [(0, MID)], alpha)  # mép trên-trái sáng
    for k in range(int(w / 25)):
        leaf(c, x + rnd.uniform(-w / 2, w / 2), y - rnd.uniform(0, h * 0.8), rnd.uniform(5, 8),
             rnd.uniform(-2.5, -0.6), [(0, MID), (-1.5, LIGHT)], alpha * 0.9)


def bark_dome(c, cx, feet, w, h, t, alpha):
    """Khiên vỏ cây xanh trong suốt bao quanh người: vòm elip, mảng vỏ cây quanh viền."""
    cy = feet - h * 0.45
    ellipse(c, cx, cy, w, h * 0.55, [(0, MAIN), (-4, MID)], alpha * 0.28)
    ring(c, cx, cy, w, 9, green(4.5), alpha * 0.9, sy=h * 0.55 / w)
    for k in range(12):  # mảng vỏ cây trên viền
        a = k * math.tau / 12 + t * 0.15
        x, y = cx + math.cos(a) * w, cy + math.sin(a) * h * 0.55
        ellipse(c, x, y, 13, 9, wood(9), alpha * 0.95)
        leaf(c, x + math.cos(a) * 10, y + math.sin(a) * 8, 8, a, green(4), alpha * 0.9)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    fx, fy = SHIELD_FRONT["attack"][i]
    if i == 2:  # nâng khiên: ánh lên ở mép khiên
        star(c, fx - 10, fy - 40, 14, [(0, BRONZE), (-2, CORE)], 0.9, rot=0.3)
    if i in (3, 4):  # lao tới: vệt gió + bụi sau chân
        for k in range(4):
            y = fy - 70 + k * 40
            capsule(c, fx - 30 - k * 10, y, fx - 150 - k * 15, y + 6, 4, 0.8, [(0, MID), (-1.5, CORE)], 0.7)
        for k in range(3):
            dust(c, 150 + k * 30, 425 - k * 4, 10 + 4 * (i - 3) + k * 2, 0.7)
    if i == 4:  # chạm: chớp xanh ở mặt khiên
        c.glow(fx + 6, fy, 70, LIGHT, 0.5)
        star(c, fx + 6, fy, 30, green(7), rot=0.2)
    if i >= 5:
        for k in range(3):
            dust(c, 160 + k * 26, 420 - (i - 5) * 8, 12 + (i - 5) * 4, fade(i - 5, 3, 0.0))
    return c.result()


def attack_hit(i):
    """Vụn gỗ và lá bay, vòng sóng xanh ngắn."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.3)
    if i == 0:
        c.glow(cx, cy, 100, LIGHT, 0.6)
        circle(c, cx, cy, 34, green(34))
        for k in range(8):
            a = k * math.tau / 8 + 0.3
            splinter(c, cx + math.cos(a) * 45, cy + math.sin(a) * 45, 14, a, 1.0)
        return c.result()
    ring(c, cx, cy, 46 + 32 * i, max(3.0, 20 - 4 * i), green(8), al, sy=0.85)
    rnd = random.Random(5)
    for k in range(10):
        a = rnd.uniform(0, math.tau)
        v = rnd.uniform(45, 70)
        x, y = cx + math.cos(a) * v * i, cy + math.sin(a) * v * i * 0.8 + 9 * i * i
        splinter(c, x, y, rnd.uniform(14, 22), a + i * rnd.uniform(-0.8, 0.8), al)
    flying_leaves(c, cx, cy, i, 14, 64, 6, al, size=(10, 16))
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    sx, sy = SHIELD_BOTTOM_SLAM[0], 425
    g = min(1.0, (i + 1) / 4)
    if i <= 3:  # cắm khiên: bụi
        for k in range(3):
            dust(c, sx - 30 + k * 30, sy - i * 3, 9 + i * 3, 0.8 - 0.15 * i)
    # vòng rễ quanh Garren
    ra = fade(i, 10, 0.75)
    for k in range(10):
        a = k * math.tau / 10
        x0 = 270 + math.cos(a) * 60
        y0 = 428 + math.sin(a) * 16
        root(c, x0, y0, 70 + 20 * (k % 3), a, 7, 8, 10 + k, ra, grow=g)
    if 4 <= i <= 6:  # gầm lớn: sóng âm từ miệng
        mx, my = MOUTH_SKILL[i]
        for k in range(3):
            r = 24 + (i - 4) * 26 + k * 22
            c.shape(lambda X, Y, r=r: np.maximum(np.abs(np.hypot(X - mx, Y - my) - r) - 2.5,
                                                 np.abs(np.arctan2(Y - my, X - mx)) - 0.7),
                    (mx - r - 4, my - r - 4, mx + r + 4, my + r + 4), [(0, LIGHT), (-1, CORE)],
                    fade(k, 3, 0.2) * 0.9)
    if i == 8:  # gõ chùy vào khiên
        mx, my = MACE_HEAD_SKILL[i]
        c.glow(mx + 30, my + 30, 40, CORE, 0.5)
        star(c, mx + 30, my + 30, 22, [(0, BRONZE), (-3, CORE)], rot=0.4)
    return c.result()


def skill_hit(i):
    """Đồng minh: khiên vỏ cây xanh trong suốt bao từng người."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.6)
    g = min(1.0, (i + 1) / 3)
    for k in range(6):  # rễ mọc lên tạo khung khiên
        a = math.pi + k * math.pi / 5
        root(c, cx + math.cos(a) * 140 * 0.9, feet, 120 * g, -math.pi / 2 + (k - 2.5) * 0.12, 6, 6, 40 + k,
             al * 0.9, grow=g)
    bark_dome(c, cx, feet, 150 * (0.6 + 0.4 * g), 400 * (0.6 + 0.4 * g), i, al)
    if 1 <= i <= 5:
        flying_leaves(c, cx, feet - 200, 1 + (i - 1) * 0.6, 8, 110, 50, al * 0.9)
    return c.result()


def skill_screen(i):
    """Khiêu Khích: dấu chấm than đỏ trên đầu mọi quái (nửa phải màn hình)."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 6, 0.5)
    pop = [0.6, 1.15, 1.0, 1.0, 1.0, 1.0][i]
    for x, y in ((700, 150), (830, 125), (955, 160)):
        s = 26 * pop
        polygon(c, [(x - s * 0.35, y - s * 1.3), (x + s * 0.35, y - s * 1.3), (x + s * 0.18, y + s * 0.2),
                    (x - s * 0.18, y + s * 0.2)], [(2.5, hexc("#3A0A10")), (0, TAUNT), (-3, TAUNT_L)], al)
        circle(c, x, y + s * 0.62, s * 0.24, [(2.5, hexc("#3A0A10")), (0, TAUNT)], al)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    if i <= 5:  # giơ khiên lên trời: ánh xanh toả từ khiên
        sx, sy = SHIELD["ultimate"][i]
        g = (i + 1) / 6
        c.glow(sx, sy, 90 + 50 * g, LIGHT, 0.35 * g)
        for k in range(8):
            a = k * math.tau / 8 + i * 0.2
            capsule(c, sx + math.cos(a) * 60, sy + math.sin(a) * 60, sx + math.cos(a) * (90 + 40 * g),
                    sy + math.sin(a) * (90 + 40 * g), 4, 1, [(0, MID), (-1.5, CORE)], 0.6 * g)
        flying_leaves(c, sx, sy, 1 + i * 0.3, 6, 50, 70 + i, 0.8 * g)
    gx, gy = SHIELD_BOTTOM_SLAM
    if i == 7:  # đập khiên xuống đất: chớp + nứt đất
        c.glow(gx, gy - 10, 120, LIGHT, 0.6)
        for k in range(6):
            a = math.pi + k * math.pi / 5
            capsule(c, gx, gy, gx + math.cos(a) * 90, gy + math.sin(a) * 14, 4, 1, [(0, WOOD_D)], 0.9)
    if 7 <= i <= 10:  # tường cây trồi lên quét về phía quái (sang phải)
        t = i - 7
        for k in range(5):
            x = gx + 20 + k * 22 + t * 40
            h = (80 + 30 * (k % 2)) * min(1.0, (t + 1) / 2) * (1 - max(0, t - 2) / 3)
            if h > 4 and x < 540:
                trunk(c, x, 440, h, 11, fade(t, 4, 0.5), lean=0.15)
                canopy(c, x + 0.15 * h, 440 - h, 46, 26, 80 + k, fade(t, 4, 0.5))
        for k in range(4):
            dust(c, gx - 40 + k * 40, 445 - t * 6, 12 + t * 5, fade(t, 4, 0.0))
    return c.result()


def ultimate_hit(i):
    """Thân cây khổng lồ đập ngang qua quái, lá và gỗ vụn."""
    c = Canvas(512, 512)
    cx, cy = 256, 270
    al = fade(i, 8, 0.4)
    if i <= 3:  # khúc gỗ quét ngang từ trái sang
        x = -160 + i * 150
        capsule(c, x - 220, cy - 10, x + 120, cy + 6, 46, 42, wood(46), 1.0)
        for k in range(4):
            capsule(c, x - 200, cy - 28 + k * 14, x + 100, cy - 22 + k * 14, 2, 2, [(0, WOOD_D)], 0.7)
        circle(c, x + 120, cy + 6, 40, [(0, WOOD_D), (-4, WOOD_L), (-14, WOOD), (-24, WOOD_L)], 1.0)  # mặt cắt vòng gỗ
        for k in range(3):
            leaf(c, x - 80 + k * 70, cy - 52, 13, -0.6 + k * 0.4, green(5), 1.0)
    if i >= 2:
        t = i - 2
        if t == 0:
            c.glow(cx + 40, cy, 140, LIGHT, 0.55)
            star(c, cx + 40, cy, 42, green(9), rot=0.3)
        rnd = random.Random(90)
        for k in range(14):
            a = rnd.uniform(-1.2, 1.2)
            v = rnd.uniform(40, 80)
            splinter(c, cx + 40 + math.cos(a) * v * (t + 0.5), cy + math.sin(a) * v * (t + 0.5) + 10 * t * t,
                     rnd.uniform(10, 18), a + t, fade(t, 6, 0.3))
        flying_leaves(c, cx + 40, cy, t + 0.5, 12, 90, 91, fade(t, 6, 0.3))
    return c.result()


def ultimate_screen(i):
    """Rừng cây mọc từ dưới màn hình lên, dồn về phía quái (bên phải); lá rơi."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.7)
    c.tint(hexc("#0E2A1A"), 0.22 * min(1.0, (i + 1) / 3) * al)
    # (x, cao, rộng thân, nghiêng, khung bắt đầu mọc): phía Garren chỉ có cây nhỏ ở mép
    trees = [(30, 210, 16, 0.03, 0), (560, 300, 26, -0.05, 1), (660, 380, 32, 0.04, 0), (780, 340, 28, -0.03, 2),
             (900, 400, 34, 0.05, 1), (1000, 320, 26, -0.06, 0), (470, 200, 16, 0.08, 3)]
    for k, (x, h, w, lean, start) in enumerate(trees):
        g = min(1.0, max(0.0, (i - start + 1) / 4))
        if g <= 0:
            continue
        hh = h * (1 - (1 - g) ** 2)
        trunk(c, x, 600, hh, w, al, lean)
        canopy(c, x + lean * hh, 600 - hh, h * 0.75, h * 0.32, 200 + k, al)
    rnd = random.Random(i)
    for k in range(22):  # lá rơi
        x = rnd.uniform(0, 1024)
        y = (rnd.uniform(-50, 500) + i * 30) % 600
        leaf(c, x, y, rnd.uniform(6, 11), rnd.uniform(0, math.tau), green(4), al * 0.9)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map
# C sáng nhất, L lá sáng, m lá, M xanh rừng, D xanh tối, O nâu rễ

ROOT_UP = ["..m", ".Om", ".O.", "OO."]
ROOT_UP2 = ["m.", "Om", ".O", ".O"]
SPIKE = [".m.", "mMm", ".O.", ".O."]
CRUMB = ["O"]
LEAF_SHIELD = [".mMm.", "mLLLm", "MLCLM", ".MLM.", "..M.."]


def opener_map(i):
    """Khiên đập đất: rễ trồi lên hình quạt rộng 140° phía trước, tầm 2 ô, đất vụn bắn."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 1:
        blit(px, [".L.", "LCL", ".L."], ox - 6, oy - 14)
    if i in (2, 3):
        d = 10 if i == 2 else 22
        for a in range(-70, 71, 28):
            r = math.radians(a)
            x, y = ox + int(math.cos(r) * d), oy + int(math.sin(r) * d * 0.45)
            blit(px, SPIKE if (a // 28) % 2 else ROOT_UP, x - 1, y - 3)
        if i == 2:
            for k in range(5):
                blit(px, CRUMB, ox + 2 + k * 3, oy - 3 - k % 2 * 2)
    if i >= 3:  # đất vụn bắn
        rnd = random.Random(4)
        for k in range(8):
            x = ox + rnd.randrange(4, 28)
            y = oy - rnd.randrange(2, 10) + (i - 3) * 3
            blit(px, CRUMB if k % 2 else ["D"], x, y)
    if i == 4:
        for a in range(-70, 71, 35):
            r = math.radians(a)
            blit(px, ["O"], ox + int(math.cos(r) * 22), oy + int(math.sin(r) * 10))
    return px


def technique_map(i):
    """Cắm khiên, vòng rễ xanh mọc quanh rồi chìm xuống; khiên lá nhỏ trên đầu báo trận sau có khiên."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    fx, fy = MAP_ANCHORS["technique_feet"]
    sx, sy = MAP_ANCHORS["technique_shield"]
    if i <= 2:
        blit(px, [".L.", "LCL", ".L."], sx - 1, sy - 4 + i)
        for k in range(i + 1):
            blit(px, ["O"], sx - 3 + k * 3, sy + 3)
    if i >= 3:  # vòng rễ quanh bán kính ~1 ô
        h = {3: 3, 4: 4, 5: 2}[i]
        for k in range(10):
            a = k * math.tau / 10
            x = fx + 3 + int(math.cos(a) * 18)
            y = fy - 2 + int(math.sin(a) * 6)
            pat = ROOT_UP2 if k % 2 else ROOT_UP
            blit(px, pat[-h:], x, y - h)
    if i == 5:
        blit(px, LEAF_SHIELD, fx + 6, 12)
    return px


V.run({
    "id": "garren", "element_color": "#2E8B57", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "ally",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit),
                             "screen": (5, 6, skill_screen)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "enemy", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

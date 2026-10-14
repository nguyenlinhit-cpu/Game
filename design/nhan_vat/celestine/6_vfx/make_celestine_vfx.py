"""Hiệu ứng skill của Celestine (Hồn #F2D58A, kiếm – con mắt phán xử), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/celestine/6_vfx/make_celestine_vfx.py
    blender -b -P design/nhan_vat/celestine/6_vfx/make_celestine_vfx.py -- --only attack,opener

Hai tư thế: attack (Canh Giữ – vệt trắng mảnh), attack_judge (Phán Xử – chữ X vàng); skill (đổi sang Phán Xử – X lớn
+ con mắt), skill_guard (đổi về Canh Giữ – vệt tốc độ vàng).
Xuất vào design/nhan_vat/celestine/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#F2D58A", light="#FFF1B8", mid="#F7E2A8", deep="#C9A04A", core="#FFFDF4", dark="#5A4420")
from vfx2d import *  # noqa: E402,F401,F403

NIGHT, OUTLINE = hexc("#1E2A55"), hexc("#141018")

# Điểm neo trong khung trận 512 (Celestine quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
T1 = {"attack": [(481, 398), (434, 473), (366, 532), (363, 49), (494, 186), (507, 277), (490, 370), (481, 398)],
      "attack_judge": [(359, 44), (279, 18), (195, 17), (456, 122), (500, 396), (512, 240), (437, 101), (359, 44)],
      "skill": [(481, 398), (481, 398), (359, 44), (359, 44), (147, 28), (466, 133), (465, 464), (520, 303), (471, 140),
                (359, 44)],
      "ultimate": [(359, 44), (330, 29), (263, 10), (194, 6), (164, 9), (164, 9), (585, 363), (489, 71), (184, 50),
                   (594, 374), (72, 183), (62, 210)]}
T2 = {"attack_judge": [(74, 113), (118, 67), (170, 31), (24, 220), (75, 459), (20, 334), (28, 199), (74, 113)],
      "skill": [(221, 301), (327, 272), (158, 27), (74, 113), (215, 14), (22, 230), (124, 509), (38, 391), (20, 246),
                (74, 113)],
      "ultimate": [(74, 113), (94, 88), (146, 42), (206, 10), (235, 0), (235, 0), (117, 406), (162, 115), (442, 18),
                   (176, 473), (535, 199), (541, 217)]}
GRIP = {"attack": [(225, 303), (219, 306), (211, 308), (238, 291), (244, 295), (235, 299), (226, 303), (225, 303)],
        "attack_judge": [(238, 288), (235, 287), (231, 287), (242, 290), (247, 297), (245, 293), (240, 289), (238, 288)],
        "skill": [(225, 303), (225, 303), (238, 288), (238, 288), (229, 287), (243, 290), (248, 298), (248, 295),
                  (244, 291), (238, 288)],
        "ultimate": [(238, 288), (237, 285), (233, 280), (230, 276), (228, 274), (228, 274), (321, 296), (323, 288),
                     (319, 287), (333, 297), (322, 292), (322, 293)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (246, 188), "eye": (260, 201), "chest": (242, 262), "halo": (212, 118),
                  "target_center": (256, 270), "sword_tip_per_frame": T1, "sword2_tip_per_frame": T2,
                  "grip_per_frame": GRIP}
MAP_ANCHORS = {"opener_origin": (30, 40), "opener_feet": (16, 52), "technique_feet": (16, 52), "halo": (9, 14)}


def gold(w):
    return [(0, DEEP), (-0.3 * w, MAIN), (-0.6 * w, CORE)]


def slash_arc(c, grip, a, b, w, alpha=1.0, white=False):
    """Vệt chém: dải cong theo đường đầu kiếm từ a tới b quanh tay cầm, dày ở giữa."""
    ang0 = math.atan2(a[1] - grip[1], a[0] - grip[0])
    ang1 = math.atan2(b[1] - grip[1], b[0] - grip[0])
    d = (ang1 - ang0 + math.pi) % math.tau - math.pi
    r0, r1 = math.hypot(a[0] - grip[0], a[1] - grip[1]), math.hypot(b[0] - grip[0], b[1] - grip[1])
    n = 16
    pts = [(grip[0] + math.cos(ang0 + d * k / n) * (r0 + (r1 - r0) * k / n) * 0.95,
            grip[1] + math.sin(ang0 + d * k / n) * (r0 + (r1 - r0) * k / n) * 0.95) for k in range(n + 1)]
    radii = [max(0.6, w * math.sin(math.pi * k / n) ** 0.7) for k in range(n + 1)]
    bands = [(0, MID), (-w * 0.3, CORE)] if white else gold(w)
    polyline(c, pts, radii, bands, alpha)


def cut_line(c, cx, cy, ang, L, w, alpha=1.0):
    """Đường cắt thẳng nhọn hai đầu qua (cx, cy)."""
    dx, dy = math.cos(ang) * L, math.sin(ang) * L
    polyline(c, [(cx - dx, cy - dy), (cx, cy), (cx + dx, cy + dy)], [0.6, w, 0.6], gold(w), alpha)


def eye(c, cx, cy, s, alpha=1.0, open_=1.0):
    """Con mắt vàng (biểu tượng phán xử): hai cung mi, tròng sáng, con ngươi."""
    h = s * 0.55 * open_
    c.glow(cx, cy, s * 1.4, MAIN, 0.3 * alpha)
    for sgn in (-1, 1):
        pts = [(cx + s * t, cy + sgn * h * (1 - t * t)) for t in np.linspace(-1, 1, 13)]
        polyline(c, pts, [max(1.5, s * 0.08)] * len(pts), gold(s * 0.08), alpha)
    if open_ > 0.2:
        circle(c, cx, cy, s * 0.38 * open_, [(0, DEEP), (-s * 0.08, MAIN), (-s * 0.2, CORE)], alpha)
        circle(c, cx, cy, s * 0.12 * open_, [(0, DARK)], alpha)


def x_mark(c, cx, cy, L, w, alpha=1.0):
    cut_line(c, cx, cy, math.radians(45), L, w, alpha)
    cut_line(c, cx, cy, math.radians(-45), L, w, alpha)


def speed_streak(c, x, y, length, alpha):
    capsule(c, x, y, x + length, y, 3.4, 0.8, gold(3.4), alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    if i in (3, 4):  # chém một đường gọn: vệt trắng mảnh theo đầu kiếm
        slash_arc(c, GRIP["attack"][i], T1["attack"][i - 1], T1["attack"][i], 10, 1.0, white=True)
    if i == 5:
        slash_arc(c, GRIP["attack"][4], T1["attack"][3], T1["attack"][4], 6, 0.5, white=True)
    return c.result()


def attack_hit(i):
    """Canh Giữ: vệt trắng mảnh chéo qua quái."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 5, 0.3)
    L = 120 + 40 * min(i, 2)
    capsule(c, cx - L * 0.8, cy - L * 0.5, cx + L * 0.8, cy + L * 0.5, 0.8, 0.8, [(0, MID)], al)
    polyline(c, [(cx - L * 0.8, cy - L * 0.5), (cx, cy), (cx + L * 0.8, cy + L * 0.5)], [0.6, 6 - i, 0.6],
             [(0, MID), (-2, CORE)], al)
    for k in range(5):
        star(c, cx + (k - 2) * 30, cy + (k - 2) * 18 - i * 5, 5, [(0, MAIN), (-0.6, CORE)], al, rot=k)
    return c.result()


def attack_judge_cast(i):
    c = Canvas(512, 512)
    if i <= 2:  # bắt chéo 2 kiếm: lấp lánh ở chỗ giao
        g = GRIP["attack_judge"][i]
        star(c, g[0] + 10, g[1] - 60, 10 + 4 * i, [(0, MAIN), (-0.6, CORE)], 0.9, rot=i)
    if i in (3, 4):
        slash_arc(c, GRIP["attack_judge"][i], T1["attack_judge"][i - 1], T1["attack_judge"][i], 12)
        g = GRIP["attack_judge"][i]
        slash_arc(c, (g[0] + 10, g[1]), T2["attack_judge"][i - 1], T2["attack_judge"][i], 12)
    return c.result()


def attack_judge_hit(i):
    """Phán Xử: chữ X vàng trên quái."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    if i == 0:
        c.glow(cx, cy, 100, CORE, 0.5)
    x_mark(c, cx, cy, 110 + 15 * min(i, 2), 10 - i, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    if i <= 3:  # rút kiếm thứ hai: vệt vàng theo kiếm, con mắt nhỏ mở sau đầu
        if i >= 1:
            slash_arc(c, (BATTLE_ANCHORS["chest"][0] + 40, BATTLE_ANCHORS["chest"][1]), T2["skill"][i - 1], T2["skill"][i], 8)
        hx, hy = BATTLE_ANCHORS["halo"]
        eye(c, hx, hy, 26, 0.9, min(1.0, (i + 1) / 3))
    if i in (5, 6):
        g = GRIP["skill"][i]
        slash_arc(c, g, T1["skill"][i - 1], T1["skill"][i], 16)
        slash_arc(c, (g[0] + 10, g[1]), T2["skill"][i - 1], T2["skill"][i], 16)
    return c.result()


def skill_hit(i):
    """Chữ X vàng lớn + con mắt nhỏ chớp."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 8, 0.45)
    if i == 0:
        c.glow(cx, cy, 160, CORE, 0.6)
    x_mark(c, cx, cy, 170 + 20 * min(i, 2), 16 - 1.5 * i, al)
    if i >= 1:
        blink = [1.0, 0.1, 1.0, 1.0, 1.0, 1.0, 1.0][min(i - 1, 6)]
        eye(c, cx, cy - 180, 30, fade(i - 1, 7, 0.5), blink)
    return c.result()


def skill_guard_cast(i):
    """Đổi về Canh Giữ: tra kiếm (lấp lánh ở lưng), lướt lùi: vệt tốc độ vàng."""
    c = Canvas(512, 512)
    if i <= 3:
        star(c, 180, 150, 8 + 3 * i, [(0, MAIN), (-0.6, CORE)], 0.9, rot=i)
    if 4 <= i <= 7:
        rnd = random.Random(i)
        for k in range(6):
            y = 140 + k * 45 + rnd.uniform(-8, 8)
            speed_streak(c, 260 + (i - 4) * 15 + rnd.uniform(-20, 20), y, rnd.uniform(60, 110), fade(i - 4, 4, 0.3))
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    hx, hy = BATTLE_ANCHORS["halo"]
    if i <= 5:  # vầng sáng mắt mở to, hai kiếm giơ lên
        o = min(1.0, (i + 1) / 4)
        eye(c, hx, hy - 10, 40 + 20 * o, 0.9, o)
        for t in (T1["ultimate"][i], T2["ultimate"][i]):
            star(c, *t, 10 + 4 * o, [(0, MAIN), (-0.6, CORE)], 0.9, rot=i)
    if 6 <= i <= 9:  # lướt xuyên qua: vệt kiếm
        g = GRIP["ultimate"][i]
        slash_arc(c, g, T1["ultimate"][i - 1], T1["ultimate"][i], 14, 0.9)
        slash_arc(c, (g[0] + 10, g[1]), T2["ultimate"][i - 1], T2["ultimate"][i], 14, 0.9)
        for k in range(5):
            speed_streak(c, g[0] - 220, 160 + k * 50, 160, 0.6)
    return c.result()


def ultimate_hit(i):
    """6 đường cắt trắng-vàng đan nhau rồi nổ."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    angs = [15, -40, 70, -75, 120, -10]
    al = fade(i, 8, 0.4)
    if i <= 2:
        for k, a in enumerate(angs[:2 * (i + 1)]):
            cut_line(c, cx + (k % 3 - 1) * 12, cy + (k % 2) * 10, math.radians(a), 190, 9, 1.0)
    else:
        t = (i - 3) / 4
        c.glow(cx, cy, 180, CORE, 0.6 * (1 - t))
        for k, a in enumerate(angs):
            cut_line(c, cx, cy, math.radians(a), 190 + 40 * t, 9 * (1 - t) + 1, al)
        ring(c, cx, cy, 40 + 180 * t, 10 * (1 - t) + 2, gold(5), al)
        rnd = random.Random(5)
        for k in range(14):
            a = rnd.uniform(0, math.tau)
            d = (60 + 140 * t) * rnd.uniform(0.6, 1.1)
            star(c, cx + math.cos(a) * d, cy + math.sin(a) * d, rnd.uniform(4, 8), [(0, MAIN), (-0.6, CORE)], al)
    return c.result()


def ultimate_screen(i):
    """Con mắt khổng lồ nhìn xuống, nền trắng-vàng, đường cắt ngang màn hình."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6) * min(1.0, (i + 1) / 2)
    c.tint(hexc("#FFF6D8"), 0.08 * al)
    o = min(1.0, (i + 1) / 3)
    eye(c, 512, 110, 220, 0.32 * al, o)
    if 2 <= i <= 5:  # đường cắt ngang màn hình (khung trúng ~ khung 2 của lớp)
        for k, y in enumerate((230, 300, 370)):
            t = min(1.0, (i - 1) / 2)
            capsule(c, -20, y + k * 10, 1044 * t, y - 20 + k * 10, 1, 4, gold(4), 1 - 0.25 * (i - 2))
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

EYE_P = [".LLL.", "LCMCL", ".LLL."]
EYE_S = [".L.", "LML", ".L."]


def opener_map(i):
    """Vệt chém trắng-vàng 110°, tầm 2 ô, con mắt nhỏ chớp ở cuối vệt."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 1:
        blit(px, [".L.", "LCL", ".L."], ox - 1, oy - 1)
    if i in (2, 3):
        r = 14 if i == 2 else 20
        for a in range(-55, 56, 6):
            ra = math.radians(a)
            x, y = ox + int(round(math.cos(ra) * r)), oy + int(round(math.sin(ra) * r))
            blit(px, ["C"] if abs(a) < 30 else ["M"], x, y)
            if i == 2:
                blit(px, ["L"], x - 1, y)
        if i == 3:
            blit(px, EYE_S, ox + int(math.cos(math.radians(55)) * 20) - 1, oy + int(math.sin(math.radians(55)) * 20) - 1)
    if i == 4:
        blit(px, EYE_P, ox + 9, oy + 14)
    return px


def technique_map(i):
    """Vầng sáng hình mắt phóng to rồi thu lại; 2 viên sáng trên đầu (+2 Điểm Chiến Kỹ)."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    hx, hy = MAP_ANCHORS["halo"]
    hx, hy = hx + 6, hy + 4  # khung 64: nhân vật đặt chân ở (16, 52)
    r = [6, 10, 13, 10, 7, 6][i]
    for a in range(0, 360, 12):
        ra = math.radians(a)
        blit(px, ["M" if a % 36 else "C"], hx + int(round(math.cos(ra) * r)), hy + int(round(math.sin(ra) * r * 0.6)))
    blit(px, EYE_P if i >= 1 else EYE_S, hx - 2, hy - 1)
    if i >= 3:
        blit(px, [".L.", "LCL", ".L."], 12, 4)
        blit(px, [".L.", "LCL", ".L."], 18, 4)
    return px


V.run({
    "id": "celestine", "element_color": "#F2D58A", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 5, attack_hit)}},
        "attack_judge": {"frames": 8, "hit_frame": 4, "target": "enemy",
                         "layers": {"cast": (0, 8, attack_judge_cast), "hit": (4, 6, attack_judge_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "enemy",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit)}},
        "skill_guard": {"frames": 10, "hit_frame": 6, "target": "enemy",
                        "layers": {"cast": (0, 10, skill_guard_cast)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "enemy", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

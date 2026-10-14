"""Hiệu ứng skill của Raiko (Sét #A65BF2, tên sét – cung), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/raiko/6_vfx/make_raiko_vfx.py
    blender -b -P design/nhan_vat/raiko/6_vfx/make_raiko_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/raiko/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

# Cùng bảng màu Sét với Nyx; thêm vàng chanh (mắt, điểm nhấn của Raiko) cho lõi tên
V.set_palette(main="#A65BF2", light="#D9B8FF", mid="#C08AF7", deep="#6A2FB8", core="#F7F0FF", dark="#2A1446")
from vfx2d import *  # noqa: E402,F401,F403

LIME = hexc("#D9F25A")
SHAFT, OUTLINE = hexc("#3A3550"), hexc("#141018")
CLOUD, CLOUD_DARK = hexc("#3A3350"), hexc("#221E30")
STAR_Y = hexc("#FFE680")

# Điểm neo trong khung trận 512 (Raiko quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
FRONT = {"attack": [(381, 228), (381, 228), (381, 228), (381, 224), (381, 225), (385, 242), (386, 260), (386, 252)],
         "skill": [(381, 228), (381, 228), (381, 228), (381, 228), (381, 227), (380, 226), (382, 229), (386, 250),
                   (385, 272), (385, 272)]}
HAND = {"attack": [(247, 241), (235, 241), (223, 240), (206, 229), (202, 226), (214, 241), (224, 257), (227, 252)],
        "skill": [(208, 273), (226, 257), (244, 240), (244, 240), (232, 240), (221, 241), (204, 228), (240, 230),
                  (275, 233), (275, 233)],
        "ultimate": [(226, 240), (222, 256), (224, 285), (228, 300), (225, 300), (222, 300), (204, 293), (204, 293),
                     (204, 293), (204, 293), (228, 255), (228, 255)]}
ARROW_MID_SKILL = [(203, 238), (210, 236), (311, 229), (311, 233), (303, 232), (295, 232), (203, 238), (207, 224),
                   (215, 211), (215, 211)]
TIP_ULT = [(438, 228), (422, 189), (372, 127), (337, 102), (337, 102), (337, 102), (195, 292), (195, 292), (195, 292),
           (195, 292), (211, 221), (211, 221)]
AIM_ULT = math.atan2(102 - 310, 337 - 180)  # hướng tên chĩa lên trời (từ khấc tên tới mũi tên, khung 3–5)
BATTLE_ANCHORS = {"feet": (256, 430), "head": (253, 178), "eye": (271, 208), "chest": (253, 273),
                  "target_center": (256, 270), "mark_above_target": (256, 90), "bow_front_per_frame": FRONT,
                  "draw_hand_per_frame": HAND, "arrow_tip_per_frame_ultimate": TIP_ULT}
MAP_ANCHORS = {"opener_origin": (31, 35), "opener_feet": (16, 52), "technique_feet": (16, 52),
               "technique_target": (56, 34)}


def volt(w):
    return [(0, MAIN), (-0.35 * w, LIGHT), (-0.68 * w, CORE)]


def zigzag(p0, p1, seed, segs=7, jit=0.22):
    rnd = random.Random(seed)
    (x0, y0), (x1, y1) = p0, p1
    L = math.hypot(x1 - x0, y1 - y0) or 1.0
    nx, ny = -(y1 - y0) / L, (x1 - x0) / L
    pts = [p0]
    for k in range(1, segs):
        t = k / segs
        off = rnd.uniform(-1, 1) * jit * L / segs * 2
        pts.append((x0 + (x1 - x0) * t + nx * off, y0 + (y1 - y0) * t + ny * off))
    return pts + [p1]


def bolt(c, p0, p1, seed, w=6.0, alpha=1.0, branches=0, glow=True):
    pts = zigzag(p0, p1, seed, segs=max(4, int(math.hypot(p1[0] - p0[0], p1[1] - p0[1]) / 26)))
    if glow:
        for x, y in pts[::2]:
            c.glow(x, y, w * 5, MAIN, 0.12 * alpha)
    polyline(c, pts, [w * (1 - 0.5 * k / (len(pts) - 1)) for k in range(len(pts))], volt(w), alpha)
    rnd = random.Random(seed + 99)
    for b in range(branches):
        k = rnd.randrange(1, len(pts) - 1)
        x, y = pts[k]
        a = math.atan2(p1[1] - p0[1], p1[0] - p0[0]) + rnd.choice((-1, 1)) * rnd.uniform(0.5, 1.0)
        ln = rnd.uniform(0.18, 0.35) * math.hypot(p1[0] - p0[0], p1[1] - p0[1])
        bp = zigzag((x, y), (x + math.cos(a) * ln, y + math.sin(a) * ln), seed + b * 7, segs=3)
        polyline(c, bp, [w * 0.6] + [w * 0.35] * (len(bp) - 1), volt(w * 0.6), alpha * 0.9)
    return pts


def crackle(c, cx, cy, r, n, seed, w=3.0, alpha=1.0):
    rnd = random.Random(seed)
    for k in range(n):
        a = rnd.uniform(0, math.tau)
        d0, d1 = rnd.uniform(0, r * 0.4), rnd.uniform(r * 0.6, r)
        a2 = a + rnd.uniform(-0.6, 0.6)
        polyline(c, zigzag((cx + math.cos(a) * d0, cy + math.sin(a) * d0),
                           (cx + math.cos(a2) * d1, cy + math.sin(a2) * d1), seed * 31 + k, segs=3, jit=0.3),
                 [w, w * 0.6, w * 0.5, w * 0.4], volt(w), alpha)


def spark(c, x, y, size, alpha=1.0, rot=0.0):
    star(c, x, y, size, volt(size * 0.3), alpha, rot=rot)


def electric_ring(c, cx, cy, rx, ry, seed, w=4.0, alpha=1.0, segs=28):
    rnd = random.Random(seed)
    pts = [(cx + math.cos(k * math.tau / segs) * rx * (1 + rnd.uniform(-0.08, 0.08)),
            cy + math.sin(k * math.tau / segs) * ry * (1 + rnd.uniform(-0.08, 0.08))) for k in range(segs)]
    polyline(c, pts + pts[:1], [w] * (segs + 1), volt(w), alpha)


def light_arrow(c, x, y, ang, L=90, alpha=1.0):
    """Tên sét: thân sáng, mũi tên kim cương tím – lõi vàng chanh, đuôi tia điện."""
    co, si = math.cos(ang), math.sin(ang)
    tx, ty = x - co * L, y - si * L
    c.glow(x, y, 50, MAIN, 0.35 * alpha)
    capsule(c, tx, ty, x - co * 14, y - si * 14, 2, 4.5, volt(4.5), alpha)
    nx, ny = -si, co
    head = [(x + co * 14, y + si * 14), (x + nx * 9, y + ny * 9), (x - co * 10, y - si * 10), (x - nx * 9, y - ny * 9)]
    polygon(c, head, [(1.5, DEEP), (0, MAIN), (-3, LIME)], alpha)
    for s in (-1, 1):  # lông đuôi
        polygon(c, [(tx, ty), (tx - co * 16 + nx * 9 * s, ty - si * 16 + ny * 9 * s), (tx + co * 8, ty + si * 8)],
                [(1.2, DEEP), (0, LIGHT)], alpha)


def mark_glyph(c, x, y, s, alpha=1.0):
    """Dấu Sấm: hình thoi khắc tia sét."""
    polygon(c, [(x, y - s), (x + s * 0.8, y), (x, y + s), (x - s * 0.8, y)], [(2, OUTLINE), (0, DEEP), (-3, MAIN)], alpha)
    pts = [(x + s * 0.15, y - s * 0.6), (x - s * 0.25, y + s * 0.05), (x + s * 0.12, y + s * 0.05), (x - s * 0.15, y + s * 0.6)]
    polyline(c, pts, [s * 0.13, s * 0.11, s * 0.11, s * 0.05], [(0, LIME), (-s * 0.05, CORE)], alpha)


def storm_cloud(c, cx, cy, w, h, seed, alpha=1.0):
    """Mây sấm: các elip dẹt chồng nhau, đáy tối, mép trên ánh tím nhạt."""
    rnd = random.Random(seed)
    n = max(3, int(w / (h * 1.2)))
    for k in range(n):
        x = cx - w / 2 + (k + 0.5) * w / n + rnd.uniform(-h * 0.3, h * 0.3)
        rx, ry = h * rnd.uniform(1.0, 1.5), h * rnd.uniform(0.35, 0.5)
        y = cy + rnd.uniform(-h * 0.15, h * 0.15)
        ellipse(c, x, y - ry * 0.25, rx, ry, [(0, DEEP)], alpha * 0.5)
        ellipse(c, x, y, rx, ry, [(0, CLOUD_DARK), (-ry * 0.3, CLOUD)], alpha * 0.9)


def stun_stars(c, cx, cy, t, alpha=1.0):
    for k in range(3):
        a = t * 0.9 + k * math.tau / 3
        star(c, cx + math.cos(a) * 34, cy + math.sin(a) * 10, 9, [(1.2, OUTLINE), (0, STAR_Y)], alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    fx, fy = FRONT["attack"][i]
    if i <= 2:  # lắp tên, kéo cung: mũi tên tích điện
        g = (i + 1) / 3
        c.glow(fx + 55, fy, 30 + 25 * g, MAIN, 0.3 + 0.2 * g)
        crackle(c, fx + 55, fy, 18 + 10 * g, 1 + i, 10 + i, 2.2)
    if i == 3:  # buông: tên sét bay, vệt điện mảnh phía sau
        c.glow(fx, fy, 50, CORE, 0.5)
        bolt(c, (fx, fy), (470, fy - 2), 20, w=3, glow=False)
        light_arrow(c, 480, fy - 2, 0.0)
    if i == 4:
        bolt(c, (fx + 40, fy), (512, fy - 4), 21, w=2.5, alpha=0.6, glow=False)
    if i >= 5:  # ngón tay còn tia điện
        hx, hy = HAND["attack"][i]
        crackle(c, hx, hy, 18, 2, 30 + i, 2.0, fade(i - 5, 3, 0.2))
        spark(c, hx + 8, hy - 8, 7, fade(i - 5, 3, 0.2), rot=i)
    return c.result()


def attack_hit(i):
    """Tên tới, nổ nhỏ hình chữ thập."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.3)
    if i == 0:
        bolt(c, (0, cy - 6), (cx - 30, cy), 40, w=2.5, glow=False)
        light_arrow(c, cx - 10, cy, 0.0)
        c.glow(cx, cy, 80, CORE, 0.6)
        return c.result()
    ln = 40 + 35 * min(i, 3)
    for k, a in enumerate((0, math.pi / 2, math.pi, -math.pi / 2)):  # chữ thập
        bolt(c, (cx, cy), (cx + math.cos(a) * ln, cy + math.sin(a) * ln), 50 + k + i * 4, w=6 - i, alpha=al,
             glow=i < 3)
    spark(c, cx, cy, 30 - 4 * i, al, rot=math.pi / 4)
    ring(c, cx, cy, 20 + 18 * i, max(1.5, 6 - i), volt(3), al * 0.6)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    if i <= 3:  # rút tên khắc: ký hiệu sét sáng dần
        ax, ay = ARROW_MID_SKILL[i]
        g = (i + 1) / 4
        c.glow(ax, ay, 40 + 20 * g, MAIN, 0.3 + 0.3 * g)
        mark_glyph(c, ax, ay - 22, 12 + 6 * g, 0.6 + 0.4 * g)
    if i in (4, 5):  # kéo căng: mũi tên tích điện
        fx, fy = FRONT["skill"][i]
        crackle(c, fx + 55, fy, 26, 3, 60 + i, 2.6)
        c.glow(fx + 55, fy, 50, MAIN, 0.45)
    if i == 6:  # bắn
        fx, fy = FRONT["skill"][i]
        bolt(c, (fx, fy), (470, fy - 2), 61, w=3, glow=False)
        light_arrow(c, 480, fy - 2, 0.0)
    if i >= 7:  # chỉ tay vào quái: vệt chấm nhỏ nối tới quái
        hx, hy = HAND["skill"][i]
        al = fade(i - 7, 3, 0.4)
        spark(c, hx + 10, hy, 9, al, rot=i)
        for k in range(6):
            circle(c, hx + 40 + k * 32, hy - k * 2, 3.5, volt(3.5), al * (1 - k / 8))
    return c.result()


def skill_hit(i):
    """Tên cắm vào quái; Dấu Sấm lơ lửng trên đầu quái, nhấp nháy."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    mx, my = BATTLE_ANCHORS["mark_above_target"]
    al = fade(i, 8, 0.6)
    light_arrow(c, cx - 30, cy + 4, 0.08, 80, al)  # tên cắm
    if i == 0:
        c.glow(cx - 30, cy, 90, CORE, 0.6)
        spark(c, cx - 30, cy, 26)
    else:
        crackle(c, cx - 30, cy, 40, 2, 70 + i, 2.5, al)
    if i >= 1:
        blink = 1.0 if i % 2 else 0.55
        mark_glyph(c, mx, my, 26, al * blink)
        c.glow(mx, my, 50, MAIN, 0.3 * al * blink)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    if i <= 5:  # chĩa lên trời: mũi tên tích điện, mây sấm tụ ở đỉnh khung
        tx, ty = TIP_ULT[i]
        g = (i + 1) / 6
        c.glow(tx, ty, 40 + 40 * g, MAIN, 0.3 + 0.3 * g)
        crackle(c, tx, ty, 24 + 16 * g, 2 + i, 100 + i, 2.6)
        storm_cloud(c, 300, 20, 360 * g, 60, 3, 0.85 * g)
    if i == 6:  # buông: tên vọt lên trời
        x0, y0 = TIP_ULT[5]
        x1, y1 = x0 + math.cos(AIM_ULT) * 140, y0 + math.sin(AIM_ULT) * 140
        bolt(c, (x0, y0), (x1, y1), 110, w=4, glow=False)
        light_arrow(c, x1, y1, AIM_ULT)
        storm_cloud(c, 300, 20, 360, 60, 3, 0.85)
    if 7 <= i <= 9:
        storm_cloud(c, 300, 20, 360, 60, 3, 0.85 - 0.2 * (i - 7))
        crackle(c, *HAND["ultimate"][i], 20, 2, 120 + i, 2.0, 0.8)
    if i >= 10:  # tóc còn dựng vì điện
        hx, hy = BATTLE_ANCHORS["head"]
        crackle(c, hx - 60, hy - 30, 50, 3, 130 + i, 2.4, 0.9)
        crackle(c, hx + 10, hy - 70, 30, 2, 140 + i, 2.0, 0.8)
    return c.result()


def ultimate_hit(i):
    """Cột sét trắng-tím giáng thẳng xuống quái; Dấu Sấm nổ thêm một vòng điện."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    feet = BATTLE_ANCHORS["feet"][1]
    al = fade(i, 8, 0.4)
    if i <= 2:
        w = [30, 22, 12][i]
        c.glow(cx, cy, 200, CORE, [0.7, 0.45, 0.25][i])
        bolt(c, (cx + 10, -10), (cx, feet - 10), 200 + i, w=w, branches=4, glow=True)
        bolt(c, (cx - 40, -10), (cx - 10, cy), 210 + i, w=w * 0.4, alpha=0.8, glow=False)
        ellipse(c, cx, feet, 150 - 20 * i, 26, [(0, MAIN), (-8, LIGHT), (-16, CORE)], 0.8)
    if 2 <= i <= 6:  # Dấu Sấm nổ: vòng điện lan
        t = (i - 2) / 4
        electric_ring(c, cx, cy, 80 + 120 * t, 100 + 140 * t, 220 + i, 5 - 3 * t, 1 - t)
        mark_glyph(c, cx, BATTLE_ANCHORS["mark_above_target"][1] - 20 * t, 26 * (1 + t), (1 - t) ** 1.5)
    if i >= 3:
        crackle(c, cx, cy, 90, 3, 230 + i, 3.0, al)
    return c.result()


def ultimate_screen(i):
    """Trời tối, mây sấm, chớp trắng toàn màn hình 1 khung (khung trúng)."""
    c = Canvas(1024, 576, ss=1)
    g = min(1.0, (i + 1) / 2)
    al = fade(i, 12, 0.6)
    c.tint(hexc("#100A1C"), 0.5 * g * al)
    for k in range(6):
        storm_cloud(c, 90 + k * 170, 40 + (k % 2) * 20, 260, 70, 300 + k, al)
    rnd = random.Random(400 + i)
    if i in (1, 4, 6):  # chớp nhỏ trong mây
        x = rnd.uniform(100, 900)
        bolt(c, (x, 40), (x + rnd.uniform(-60, 60), 150), 410 + i, w=4, alpha=0.8 * al, glow=False)
    if i == 2:  # khung trúng (toàn cục khung 8): chớp trắng
        c.tint(CORE, 0.75)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

SPARK = [".L.", "LCL", ".L."]
ARROW_P = ["...D.", "MMMLC", "...D."]
MARK_P = ["..L..", ".LCL.", "LC.CL", ".LCL.", "..L.."]
BOLT_ICON = ["..LC", ".LC.", "LCCL", ".CL.", "CL.."]


def pix_line(px, x0, x1, y, col):
    for x in range(max(0, x0), min(64, x1)):
        px[y, x, :3] = PIXEL_PALETTE[col]
        px[y, x, 3] = 1


def opener_map(i):
    """Tên sấm: mũi tên sét bay thẳng tầm 4 ô, vệt điện mảnh."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 0:
        blit(px, ["L"], ox - 1, oy)
    if i == 1:
        blit(px, SPARK, ox - 1, oy - 1)
    if i in (2, 3):
        x = ox + (12 if i == 2 else 27)
        pix_line(px, ox, x - 2, oy, "m" if i == 2 else "D")
        for k in range(ox + 2, x - 3, 4):  # vệt điện gấp khúc mảnh
            blit(px, ["L"], k, oy - 1 + (k // 4) % 3 - 1 if (k // 4) % 2 else oy + 1)
        blit(px, ARROW_P, x - 4, oy - 1)
    if i == 4:
        blit(px, SPARK, 60, oy - 1)
    return px


def technique_map(i):
    """Lôi tiễn: tên khắc sáng, cung sáng, bắn xa; quái trúng có ký hiệu tia sét và sao choáng."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    tx, ty = MAP_ANCHORS["technique_target"]
    if i <= 1:
        blit(px, ["L"] if i == 0 else SPARK, 18, oy - 1 - i)
    if i in (2, 3):  # cung sáng
        for y in range(22, 46, 3):
            blit(px, ["M" if (y + i) % 2 else "L"], 30, y)
        blit(px, SPARK, ox - 1, oy - 1)
    if i == 4:
        pix_line(px, ox, 60, oy, "m")
        blit(px, ARROW_P, 59, oy - 1)
    if i == 5:  # quái trúng: tia sét trên đầu + sao choáng (vòng chấm)
        blit(px, BOLT_ICON, tx - 2, ty - 16)
        for k in range(3):
            blit(px, ["C"], tx - 5 + k * 5, ty - 8 + (k % 2))
    return px


V.run({
    "id": "raiko", "element_color": "#A65BF2", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
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

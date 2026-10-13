"""Hiệu ứng skill của Nyx (Sét #A65BF2, điện tím), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/nyx/6_vfx/make_nyx_vfx.py
    blender -b -P design/nhan_vat/nyx/6_vfx/make_nyx_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/nyx/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#A65BF2", light="#D9B8FF", mid="#C08AF7", deep="#6A2FB8", core="#F7F0FF", dark="#2A1446")
from vfx2d import *  # noqa: E402,F401,F403

SMOKE, SMOKE_EDGE = hexc("#8C8098"), hexc("#6B5E78")
CABLE, CABLE_HI, OUTLINE = hexc("#1E1B26"), hexc("#3E3850"), hexc("#141018")
COPPER, COPPER_DARK = hexc("#C77A3A"), hexc("#8A4E22")
ICON_BG = hexc("#2A1446")

# Điểm neo trong khung trận 512 (Nyx quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
FINGER = {"attack": [(101, 195), (89, 206), (79, 219), (136, 177), (153, 173), (165, 178), (173, 179), (101, 195)],
          "ultimate": [(101, 195), (110, 188), (120, 183), (67, 261), (88, 355), (88, 358), (88, 358), (88, 358),
                       (88, 358), (88, 357), (89, 208), (89, 208)]}
PALM = {"attack": [(109, 234), (103, 243), (99, 254), (131, 217), (142, 211), (146, 213), (151, 212), (109, 234)],
        "ultimate": [(109, 234), (114, 228), (119, 222), (97, 285), (127, 347), (127, 351), (127, 351), (127, 351),
                     (127, 350), (127, 349), (104, 244), (104, 244)]}
PLUG = [(359, 369), (363, 332), (349, 297), (306, 266), (325, 303), (330, 298), (331, 301), (331, 339), (321, 411),
        (350, 388)]
CABLE_END = [(315, 359), (321, 347), (322, 333), (317, 310), (324, 304), (330, 298), (331, 302), (330, 339),
             (310, 368), (313, 363)]
ANTENNA = [(126, 56), (122, 57), (118, 65), (153, 75), (189, 94), (187, 112), (190, 100), (195, 92), (190, 99),
           (189, 98), (121, 58), (120, 63)]
BATTLE_ANCHORS = {"feet": (256, 430), "head": (222, 143), "eye": (237, 159), "chest": (218, 252),
                  "target_center": (256, 270), "fingertip_per_frame": FINGER, "palm_per_frame": PALM,
                  "plug_per_frame_skill": PLUG, "cable_end_per_frame_skill": CABLE_END,
                  "antenna_tip_per_frame_ultimate": ANTENNA}
MAP_ANCHORS = {"opener_origin": (28, 41), "opener_feet": (16, 52), "technique_feet": (16, 52),
               "technique_button": (27, 41)}
APEX = (215, 36)  # đỉnh vòng cung của tia đánh thường (trên mũ)
CABLE_Y = 266  # độ cao dây cáp khi băng qua mép giữa khung người dùng và khung mục tiêu


def volt(w):
    """Bậc cel tia điện: viền tím → tím nhạt → lõi gần trắng."""
    return [(0, MAIN), (-0.35 * w, LIGHT), (-0.68 * w, CORE)]


def zigzag(p0, p1, seed, segs=7, jit=0.22):
    """Điểm gấp khúc từ p0 tới p1, lệch vuông góc tối đa jit × độ dài đoạn (hai đầu giữ nguyên)."""
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


def bolt(c, p0, p1, seed, w=6.0, alpha=1.0, branches=0, glow=True, taper=True):
    """Tia sét gấp khúc có nhánh phụ; quầng sáng mờ ở hai đầu."""
    pts = zigzag(p0, p1, seed, segs=max(4, int(math.hypot(p1[0] - p0[0], p1[1] - p0[1]) / 26)))
    if glow:
        for x, y in pts[::2]:
            c.glow(x, y, w * 5, MAIN, 0.12 * alpha)
    radii = [w * (1 - 0.55 * k / (len(pts) - 1)) if taper else w for k in range(len(pts))]
    polyline(c, pts, radii, volt(w), alpha)
    rnd = random.Random(seed + 99)
    for b in range(branches):
        k = rnd.randrange(1, len(pts) - 1)
        x, y = pts[k]
        base = math.atan2(p1[1] - p0[1], p1[0] - p0[0])
        a = base + rnd.choice((-1, 1)) * rnd.uniform(0.5, 1.0)
        ln = rnd.uniform(0.18, 0.35) * math.hypot(p1[0] - p0[0], p1[1] - p0[1])
        q = (x + math.cos(a) * ln, y + math.sin(a) * ln)
        bp = zigzag((x, y), q, seed + b * 7, segs=3)
        polyline(c, bp, [w * 0.6] + [w * 0.35] * (len(bp) - 1), volt(w * 0.6), alpha * 0.9)
    return pts


def crackle(c, cx, cy, r, n, seed, w=3.0, alpha=1.0):
    """n tia điện nhỏ nhảy loạn quanh một điểm."""
    rnd = random.Random(seed)
    for k in range(n):
        a = rnd.uniform(0, math.tau)
        d0, d1 = rnd.uniform(0, r * 0.4), rnd.uniform(r * 0.6, r)
        p0 = (cx + math.cos(a) * d0, cy + math.sin(a) * d0)
        a2 = a + rnd.uniform(-0.6, 0.6)
        p1 = (cx + math.cos(a2) * d1, cy + math.sin(a2) * d1)
        polyline(c, zigzag(p0, p1, seed * 31 + k, segs=3, jit=0.3), [w, w * 0.6, w * 0.5, w * 0.4], volt(w), alpha)


def spark(c, x, y, size, alpha=1.0, rot=0.0):
    star(c, x, y, size, volt(size * 0.3), alpha, rot=rot)


def smoke(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, SMOKE_EDGE), (-max(1.5, r * 0.25), SMOKE)], alpha * 0.7)


def electric_ring(c, cx, cy, rx, ry, seed, w=4.0, alpha=1.0, segs=28):
    """Vòng điện gấp khúc (elip) quanh mục tiêu."""
    rnd = random.Random(seed)
    pts = []
    for k in range(segs + 1):
        a = k * math.tau / segs
        j = 1 + rnd.uniform(-0.08, 0.08) if k < segs else None
        if j is None:
            pts.append(pts[0])
            break
        pts.append((cx + math.cos(a) * rx * j, cy + math.sin(a) * ry * j))
    polyline(c, pts, [w] * len(pts), volt(w), alpha)


def plug_head(c, x, y, ang, s=1.0, alpha=1.0):
    """Phích cắm 2 chân đồng ở đầu dây cáp, hướng ang (radian)."""
    co, si = math.cos(ang), math.sin(ang)

    def at(u, v):
        return x + co * u * s - si * v * s, y + si * u * s + co * v * s
    body = [at(-22, -12), at(4, -12), at(4, 12), at(-22, 12)]
    polygon(c, body, [(2.0, OUTLINE), (0, CABLE), (-4 * s, CABLE_HI)], alpha)
    polygon(c, [at(-8, -12.5), at(-3, -12.5), at(-3, 12.5), at(-8, 12.5)], [(0, MAIN), (-1.2, LIGHT)], alpha)
    for v in (-6, 6):
        capsule(c, *at(4, v), *at(18, v), 2.8 * s, 2.8 * s, [(1.2, OUTLINE), (0, COPPER_DARK), (-1.2, COPPER)],
                alpha)


def cable_line(c, pts, alpha=1.0, w=5.0):
    polyline(c, pts, [w + 2] * len(pts), [(0, OUTLINE)], alpha)
    polyline(c, pts, [w] * len(pts), [(0, CABLE), (-w * 0.55, CABLE_HI)], alpha)


def sag(p0, p1, depth, n=10):
    """Dây võng xuống giữa (depth px)."""
    return [(p0[0] + (p1[0] - p0[0]) * t, p0[1] + (p1[1] - p0[1]) * t + depth * math.sin(math.pi * t))
            for t in (k / n for k in range(n + 1))]


def pulses(c, pts, t, n=3, alpha=1.0):
    """Hạt điện sáng chạy dọc dây (t: pha 0–1)."""
    L = len(pts) - 1
    for k in range(n):
        u = (t + k / n) % 1.0
        j = min(int(u * L), L - 1)
        f = u * L - j
        x = pts[j][0] + (pts[j + 1][0] - pts[j][0]) * f
        y = pts[j][1] + (pts[j + 1][1] - pts[j][1]) * f
        c.glow(x, y, 22, LIGHT, 0.5 * alpha)
        circle(c, x, y, 5.5, volt(5.5), alpha)


def static_icon(c, x, y, s, alpha=1.0):
    """Biểu tượng Tĩnh Điện: huy hiệu tròn tím đậm, tia sét trắng tím ở giữa."""
    circle(c, x, y, s, [(1.5, OUTLINE), (0, MAIN), (-s * 0.14, ICON_BG)], alpha)
    pts = [(x + s * 0.18, y - s * 0.62), (x - s * 0.3, y + s * 0.08), (x + s * 0.02, y + s * 0.08),
           (x - s * 0.18, y + s * 0.62)]
    polyline(c, pts, [s * 0.16, s * 0.13, s * 0.13, s * 0.06], [(0, LIGHT), (-s * 0.06, CORE)], alpha)


def cracked_shield(c, x, y, s, alpha=1.0, split=0.0):
    """Biểu tượng Đoản Mạch (−Phòng Thủ): khiên nứt đôi theo đường sét, hai nửa tách ra split px."""
    for side in (-1, 1):
        dx = side * split
        half = [(x + dx, y - s), (x + dx + side * s * 0.85, y - s * 0.7), (x + dx + side * s * 0.75, y + s * 0.2),
                (x + dx, y + s)]
        polygon(c, half, [(2.0, OUTLINE), (0, hexc("#7D7F8C")), (-s * 0.15, hexc("#BFC3CC"))], alpha)
    crack = [(x - s * 0.05, y - s), (x + s * 0.12, y - s * 0.4), (x - s * 0.1, y), (x + s * 0.08, y + s * 0.45),
             (x, y + s)]
    polyline(c, crack, [s * 0.1] * len(crack), volt(s * 0.1), alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    fx, fy = FINGER["attack"][i]
    px, py = PALM["attack"][i]
    if i <= 2:  # tích điện: tia điện nhảy giữa các ngón, sáng dần
        g = (i + 1) / 3
        c.glow((fx + px) / 2, (fy + py) / 2, 50 + 30 * g, MAIN, 0.25 + 0.25 * g)
        crackle(c, (fx + px) / 2, (fy + py) / 2, 34 + 10 * g, 2 + 2 * i, 10 + i, 2.5 + g)
        spark(c, fx, fy, 8 + 6 * g, 0.9, rot=i * 0.5)
    if i == 3:  # búng tay: chớp ở đầu ngón, tia sét phóng sang phải
        c.glow(fx, fy, 70, CORE, 0.6)
        spark(c, fx, fy, 26, rot=0.2)
        bolt(c, (fx, fy - 4), APEX, 31, w=7, branches=1)  # vòng qua trên đầu, không cắt ngang mặt
        bolt(c, APEX, (512, 252), 33, w=7, branches=2)
    if i == 4:
        c.glow(fx, fy, 46, LIGHT, 0.4)
        spark(c, fx, fy, 14, 0.8, rot=0.6)
        bolt(c, (fx, fy - 4), APEX, 34, w=4.5, alpha=0.75)
        bolt(c, APEX, (512, 262), 32, w=4.5, alpha=0.75, branches=1)
    if i >= 5:  # thổi đầu ngón như thổi súng: khói tím xám bay lên, tia nhỏ tắt dần
        t = i - 5
        for k in range(3):
            smoke(c, fx + 4 + k * 6 + t * 4, fy - 10 - t * 12 - k * 7, 5 + t * 2.5 + k, fade(t, 3, 0.0) * 0.9)
        if t == 0:
            crackle(c, fx, fy, 16, 2, 50, 2.0, 0.8)
    return c.result()


def attack_hit(i):
    """Tia sét zigzag nhỏ đánh xuống quái, nổ thành 3 tia."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.3)
    if i == 0:
        bolt(c, (0, 258), (cx, cy), 40, w=7, branches=1)
        c.glow(cx, cy, 90, CORE, 0.7)
        spark(c, cx, cy, 34, rot=0.3)
        return c.result()
    t = min(1.0, i / 2)
    for k, a in enumerate((-0.9, 0.5, 2.3)):  # 3 tia toả ra
        ln = (60 + 50 * t) * (1 - max(0, i - 3) * 0.2)
        bolt(c, (cx, cy), (cx + math.cos(a) * ln, cy + math.sin(a) * ln), 60 + k + i * 3, w=5 - 0.6 * i, alpha=al,
             glow=i < 3)
    ring(c, cx, cy, 24 + 20 * i, max(1.5, 6 - 1.2 * i), volt(3), al * 0.7)
    rnd = random.Random(70)
    for k in range(8):
        a = rnd.uniform(0, math.tau)
        d = rnd.uniform(40, 100) * t
        spark(c, cx + math.cos(a) * d, cy + math.sin(a) * d, rnd.uniform(4, 8), al, rot=rnd.uniform(0, 1))
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    px, py = PLUG[i]
    ex, ey = CABLE_END[i]
    if i <= 3:  # rút dây: phích cắm tích điện
        g = (i + 1) / 4
        c.glow(px, py, 30 + 20 * g, MAIN, 0.2 + 0.3 * g)
        crackle(c, px, py, 22 + 10 * g, 1 + i, 80 + i, 2.5)
    if i == 4:  # quăng: dây vươn ra, phích cắm bay giữa đường
        head = (448, 252)
        pts = sag((ex, ey), head, -26)
        cable_line(c, pts)
        plug_head(c, *head, math.atan2(head[1] - pts[-2][1], head[0] - pts[-2][0]))
        crackle(c, *head, 20, 2, 84, 2.0, 0.8)
    if i in (5, 6, 7):  # dây căng tới mép khung (nối sang lớp hit), điện chạy dọc dây
        depth = {5: -10, 6: 6, 7: 34}[i]
        pts = sag((ex, ey), (512, CABLE_Y), depth)
        al = 1.0 if i < 7 else 0.85
        cable_line(c, pts, al)
        if i >= 6:
            pulses(c, pts, 0.15 + 0.35 * (i - 6), 3, al)
            for k in range(0, len(pts) - 1, 3):
                crackle(c, *pts[k], 14, 1, 90 + k + i, 1.8, 0.7 * al)
    if i >= 8:  # giật về, quấn hông: tàn điện ở phích cắm
        t = i - 8
        crackle(c, px, py, 18, 2, 95 + i, 2.0, fade(t, 2, 0.0) * 0.9 + 0.1)
        spark(c, px + 10, py - 12 - t * 6, 7, fade(t, 2, 0.0) * 0.9 + 0.1)
    return c.result()


def skill_hit(i):
    """Dây cắm vào quái (khung 6), vòng điện tím quanh quái, khiên nứt (Đoản Mạch), giọt điện rò (Rò Điện)."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    plug_at = (196, 272)
    if i == 0:  # phích cắm đang lao tới
        head = (110, 266)
        cable_line(c, sag((0, CABLE_Y), head, -4, 4))
        plug_head(c, *head, 0.0)
        return c.result()
    if i in (1, 2):  # cắm vào (trúng) và điện chạy
        pts = sag((0, CABLE_Y), (plug_at[0] - 18, plug_at[1]), 4 if i == 1 else 14, 6)
        cable_line(c, pts)
        plug_head(c, plug_at[0] - 18, plug_at[1], 0.0)
        if i == 1:
            c.glow(*plug_at, 80, CORE, 0.7)
            spark(c, *plug_at, 30, rot=0.2)
        pulses(c, pts, 0.3 * i, 2)
    al = fade(i - 1, 8, 0.5)
    g = min(1.0, i / 2)
    electric_ring(c, cx, cy + 10, 120 * (0.7 + 0.3 * g), 160 * (0.7 + 0.3 * g), 100 + i, 4.5, al)
    electric_ring(c, cx, cy + 10, 96 * (0.7 + 0.3 * g), 132 * (0.7 + 0.3 * g), 200 + i, 3.0, al * 0.7)
    crackle(c, cx, cy, 70, 3, 300 + i, 3.0, al)
    if i >= 2:  # khiên nứt, hai nửa tách dần
        cracked_shield(c, cx + 70, cy - 150, 30, fade(i - 2, 7, 0.5), split=min(8.0, (i - 2) * 2.5))
    rnd = random.Random(400)
    for k in range(6):  # giọt điện rò rỉ nhỏ xuống
        x = cx + rnd.uniform(-80, 80)
        y = cy + rnd.uniform(-40, 60) + ((i * 18 + k * 23) % 90)
        drop(c, x, y, 4.5, 14, math.pi / 2, volt(4.5), al * 0.9)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    ground = BATTLE_ANCHORS["feet"][1]
    ax, ay = ANTENNA[i]
    if i == 2:  # kéo kính xuống: lấp lánh trên kính
        ex, ey = BATTLE_ANCHORS["eye"]
        spark(c, ex + 12, ey - 4, 16, rot=0.3)
    if 2 <= i <= 9:  # ăng-ten sáng rực
        g = min(1.0, (i - 1) / 4)
        c.glow(ax, ay, 40 + 40 * g, MAIN, 0.35 + 0.3 * g)
        circle(c, ax, ay, 6 + 4 * g, volt(8))
        if i >= 4:
            crackle(c, ax, ay, 30 + 12 * g, 3, 500 + i, 2.5)
    fx, fy = FINGER["ultimate"][i]
    if i in (4, 5):  # găng cắm xuống đất: chớp + nứt điện trên mặt đất
        c.glow(fx, ground - 6, 90, CORE, 0.55 if i == 4 else 0.35)
        spark(c, fx, ground - 6, 30 if i == 4 else 20, rot=0.4)
        bolt(c, (fx, fy), (fx + 10, ground - 4), 600 + i, w=6)
    if 4 <= i <= 9:  # vết nứt điện lan ra hai phía trên mặt đất
        reach = min(1.0, (i - 3) / 4)
        al = 1.0 if i < 9 else 0.6
        for k, (dx, dy) in enumerate(((-1, 0.18), (1, 0.12), (1, -0.04), (1, 0.25))):
            ln = (130 + 280 * reach) * (0.5 if dx < 0 else 1.0)
            bolt(c, (fx, ground - 4), (fx + dx * ln, ground - 4 + dy * ln * 0.3), 700 + k * 13 + i, w=4.5, alpha=al,
                 branches=1, glow=False)
    if 6 <= i <= 9:  # bão điện từ toả ra quanh người
        t = (i - 6) / 3
        r = 120 + 300 * t
        al = 1.0 - 0.6 * t
        electric_ring(c, 210, 300, r, r * 0.75, 800 + i, 6 - 2 * t, al)
        for k in range(3):  # tia từ ăng-ten vọt lên
            a = -math.pi / 2 + (k - 1) * 0.5
            bolt(c, (ax, ay), (ax + math.cos(a) * 110, ay + math.sin(a) * 110), 900 + k + i, w=4, alpha=al)
    if i >= 10:  # phủi găng: tàn điện
        t = i - 10
        crackle(c, fx, fy + 20, 26, 2, 990 + i, 2.2, 0.8 - 0.3 * t)
        for k in range(4):
            spark(c, fx - 10 + k * 12, fy + 50 + t * 10 + k * 4, 5, 0.8 - 0.3 * t, rot=k)
    return c.result()


def ultimate_hit(i):
    """Lưới điện tím bọc quanh quái + biểu tượng Tĩnh Điện."""
    c = Canvas(512, 512)
    cx, cy, rx, ry = 256, 280, 118, 160
    al = fade(i, 8, 0.5)
    if i == 0:
        c.glow(cx, cy, 160, CORE, 0.6)
    grow = min(1.0, (i + 1) / 2)
    for k in range(-2, 3):  # các đường dọc + ngang, gấp khúc, bọc trong elip
        x = cx + k * rx * 0.42
        h = ry * math.sqrt(max(0.0, 1 - (k * 0.42) ** 2)) * grow
        bolt(c, (x, cy - h), (x, cy + h), 1000 + k * 7 + i, w=3.5, alpha=al, glow=False, taper=False)
        y = cy + k * ry * 0.42
        w = rx * math.sqrt(max(0.0, 1 - (k * 0.42) ** 2)) * grow
        bolt(c, (cx - w, y), (cx + w, y), 1100 + k * 7 + i, w=3.5, alpha=al, glow=False, taper=False)
    electric_ring(c, cx, cy, rx * grow, ry * grow, 1200 + i, 5, al)
    if i >= 1:
        static_icon(c, cx + 80, cy - ry - 30, 24, fade(i - 1, 7, 0.6))
    return c.result()


def ultimate_screen(i):
    """Màn hình tối tím, lưới điện phủ màn hình, chớp sáng 2 lần, sét nhánh từ trên giáng xuống."""
    c = Canvas(1024, 576, ss=1)
    g = min(1.0, (i + 1) / 2)
    al = fade(i, 12, 0.6)
    c.tint(hexc("#140A24"), 0.42 * g * al)
    pulse = 0.55 + 0.45 * math.sin(i * 1.7)
    for k in range(1, 8):  # lưới dọc
        x = k * 128
        bolt(c, (x, 0), (x, 576), 1300 + k + i * 11, w=2.5, alpha=0.45 * al * pulse, glow=False, taper=False)
    for k in range(1, 6):  # lưới ngang
        y = k * 96
        bolt(c, (0, y), (1024, y), 1400 + k + i * 11, w=2.5, alpha=0.45 * al * pulse, glow=False, taper=False)
    if 1 <= i <= 6:  # sét nhánh giáng xuống phe quái (bên phải)
        rnd = random.Random(1500 + i)
        for k in range(2):
            x = rnd.uniform(560, 980)
            bolt(c, (x + rnd.uniform(-60, 60), 0), (x, rnd.uniform(300, 470)), 1600 + i * 5 + k, w=7, branches=3,
                 alpha=al)
    if i in (2, 4):  # chớp sáng
        c.tint(LIGHT, 0.34 if i == 2 else 0.24)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

SPARK = [".L.", "LCL", ".L."]
SPARK_L = ["..L..", ".LML.", "LMCML", ".LML.", "..L.."]
DOT = ["L"]


def pix_bolt(px, x0, y0, ang, length, seed, col="M", head="C"):
    """Tia sét pixel gấp khúc: đi theo hướng ang, cứ 3 px lệch ngang ±1–2; đầu tia sáng."""
    rnd = random.Random(seed)
    nx, ny = -math.sin(ang), math.cos(ang)
    off = 0
    last = None
    for s in range(1, int(length) + 1):
        if s % 3 == 0:
            off = max(-2, min(2, off + rnd.choice((-1, 1))))
        x = int(round(x0 + math.cos(ang) * s + nx * off))
        y = int(round(y0 + math.sin(ang) * s + ny * off))
        if 0 <= x < 64 and 0 <= y < 64:
            px[y, x, :3] = PIXEL_PALETTE[col if s < length - 1 else head]
            px[y, x, 3] = 1
            last = (x, y)
    return last


def opener_map(i):
    """Cú chích điện: quạt 70°, tia sét tím gấp khúc tầm ~2,5 ô."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 0:  # nắm găng
        blit(px, DOT, ox, oy)
        blit(px, ["m"], ox + 1, oy - 1)
    if i == 1:  # tích điện
        blit(px, SPARK_L, ox - 2, oy - 2)
    if i in (2, 3):  # đấm ra, 4 tia toả quạt ±35°
        ln = 34 if i == 2 else 22
        for k, a in enumerate((-35, -12, 12, 35)):
            pix_bolt(px, ox, oy, math.radians(a), ln - (abs(a) > 20) * 4, 20 + k + i * 5,
                     col="L" if i == 2 else "M", head="C" if i == 2 else "m")
        if i == 2:
            blit(px, SPARK, ox - 1, oy - 1)
    if i == 4:  # tàn điện
        rnd = random.Random(7)
        for k in range(6):
            a = math.radians(rnd.uniform(-35, 35))
            d = rnd.uniform(12, 30)
            blit(px, DOT if k % 2 else ["m"], ox + int(math.cos(a) * d), oy + int(math.sin(a) * d))
    return px


def technique_map(i):
    """Màn tĩnh điện: bấm nút trên găng, sọc nhiễu tím lướt qua người; sau đó chỉ còn vài tia nhỏ."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    bx, by = MAP_ANCHORS["technique_button"]
    fx, feet = MAP_ANCHORS["technique_feet"]
    if i <= 1:
        blit(px, DOT if i == 0 else SPARK, bx - i, by - i)
    if 2 <= i <= 4:  # sọc nhiễu quét từ trên xuống
        rnd = random.Random(30 + i)
        top = feet - 32 + (i - 2) * 9
        for k in range(5):
            y = top + k * 4 + rnd.randrange(0, 2)
            x0 = fx - 14 + rnd.randrange(-2, 4)
            ln = rnd.randrange(8, 20)
            for x in range(x0, min(64, x0 + ln)):
                if 0 <= y < 64 and 0 <= x:
                    px[y, x, :3] = PIXEL_PALETTE["M" if (x + k) % 5 else "L"]
                    px[y, x, 3] = 1
        blit(px, DOT, bx, by)
    if i == 5:  # chỉ còn viền mờ + vài tia điện nhỏ
        for (x, y) in ((fx - 10, feet - 20), (fx + 9, feet - 26), (fx + 2, feet - 6)):
            blit(px, ["m"], x, y)
            blit(px, DOT, x + 1, y - 1)
    return px


V.run({
    "id": "nyx", "element_color": "#A65BF2", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "enemy",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (5, 9, skill_hit)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "enemy", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

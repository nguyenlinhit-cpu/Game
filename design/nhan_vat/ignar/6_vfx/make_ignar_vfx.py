"""Hiệu ứng skill của Ignar (Lửa #E8552B, lò rèn – dung nham, tàn than), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/ignar/6_vfx/make_ignar_vfx.py
    blender -b -P design/nhan_vat/ignar/6_vfx/make_ignar_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/ignar/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#E8552B", light="#FFD37A", mid="#FF8A3A", deep="#A8281C", core="#FFF6E0", dark="#3A1410")
from vfx2d import *  # noqa: E402,F401,F403

SMOKE, SMOKE_EDGE = hexc("#5E5550"), hexc("#3E3632")       # khói đen lò rèn
ROCK, ROCK_EDGE = hexc("#4A3A34"), hexc("#241A16")
OUTLINE = hexc("#141018")
HP_RED, HP_LIGHT = hexc("#D2231E"), hexc("#FF8A80")

# Điểm neo trong khung trận 512 (Ignar quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
HEAD = {"attack": [(165, 191), (161, 259), (183, 322), (300, 42), (344, 451), (360, 449), (412, 45), (165, 191)],
        "skill": [(165, 191), (145, 270), (162, 353), (164, 357), (216, 52), (447, 75), (388, 447), (453, 398),
                  (293, 41), (165, 191)],
        "ultimate": [(165, 191), (205, 161), (152, 127), (112, 121), (113, 106), (114, 92), (444, 68), (331, 462),
                     (328, 463), (333, 462), (158, 210), (158, 210)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (286, 173), "mouth": (307, 200), "chest": (278, 258),
                  "target_center": (256, 270), "target_feet": (256, 430), "side_targets_in_hit": [(70, 300), (442, 300)],
                  "hammer_head_per_frame": HEAD}
MAP_ANCHORS = {"opener_feet": (16, 52), "opener_impact": (40, 50), "hammer_head": (3, 31),
               "technique_feet": (40, 52), "technique_mark": (56, 30)}


def warm(size):
    """Bậc cel lửa: viền đỏ thẫm → cam → vàng → lõi trắng ấm."""
    return [(0, DEEP), (-0.2 * size, MAIN), (-0.45 * size, LIGHT), (-0.75 * size, CORE)]


def smoke(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, SMOKE_EDGE), (-max(1.5, r * 0.25), SMOKE)], alpha * 0.8)


def ember(c, x, y, s, alpha=1.0, rot=0.0):
    star(c, x, y, s, [(0, MAIN), (-0.4, LIGHT), (-0.9, CORE)], alpha, rot=rot)


def rock(c, x, y, s, rot, alpha=1.0):
    pts = [(x + math.cos(rot + k * 2.1) * s * (1.0 if k % 2 else 0.7), y + math.sin(rot + k * 2.1) * s * 0.8)
           for k in range(3)]
    polygon(c, pts, [(1.5, ROCK_EDGE), (0, ROCK)], alpha)


def flame_tongue(c, x, y, h, w, alpha=1.0, lean=0.0):
    """Lưỡi lửa mọc lên từ (x, y), cao h."""
    drop(c, x, y, w, h, math.pi / 2 + lean, warm(w), alpha)


def fireball(c, cx, cy, t, R, seed, alpha=1.0):
    """Vụ nổ lửa (t: khung từ lúc nổ): chớp → cầu lửa cánh hoa → khói đen + tàn than bay lên."""
    if t < 0:
        return
    rnd = random.Random(seed)
    if t == 0:
        c.glow(cx, cy, R * 1.3, CORE, 0.85 * alpha)
        circle(c, cx, cy, R * 0.45, warm(R * 0.45), alpha)
        return
    k = min(1.0, t / 5)
    al = alpha * (1 - k) ** 0.6
    if t <= 3:
        c.glow(cx, cy, R * 1.1, LIGHT, 0.35 * al)
        for j in range(9):  # cánh lửa toả ra
            a = j * math.tau / 9 + rnd.uniform(-0.2, 0.2)
            d = R * (0.35 + 0.4 * min(1.0, t / 2))
            drop(c, cx + math.cos(a) * d, cy + math.sin(a) * d * 0.85, R * 0.22, R * 0.5, a, warm(R * 0.22), al)
        circle(c, cx, cy, R * (0.55 - 0.1 * t), warm(R * 0.5), al)
    for j in range(5):  # khói đen bốc lên
        sx = cx + rnd.uniform(-R * 0.6, R * 0.6)
        smoke(c, sx, cy - R * 0.2 - t * R * 0.12 - j * 6, R * (0.18 + 0.05 * t), al * (0.5 if t <= 2 else 0.9))
    for j in range(10):  # tàn than bắn tung
        a = rnd.uniform(-math.pi * 0.95, -math.pi * 0.05)
        d = R * (0.5 + 0.18 * t) * rnd.uniform(0.7, 1.3)
        ember(c, cx + math.cos(a) * d, cy + math.sin(a) * d + 6 * t * t, rnd.uniform(3, 6), al, rot=rnd.uniform(0, 1))


def lava_crack(c, x0, y0, x1, y1, seed, w=4.0, alpha=1.0):
    """Vết nứt dung nham gấp khúc trên mặt đất."""
    rnd = random.Random(seed)
    n = 6
    pts = [(x0 + (x1 - x0) * k / n + (rnd.uniform(-8, 8) if 0 < k < n else 0),
            y0 + (y1 - y0) * k / n + (rnd.uniform(-5, 5) if 0 < k < n else 0)) for k in range(n + 1)]
    polyline(c, pts, [w * 1.8] * len(pts), [(0, DARK)], alpha)
    polyline(c, pts, [w] * (len(pts) - 1) + [w * 0.4], warm(w), alpha)


def seg_text(c, text, x, y, h, alpha=1.0):
    """Chữ số dạng nét (chỉ '-', '1', '5', '%') – số máu mất màu đỏ."""
    w = h * 0.55
    bands = [(2.2, OUTLINE), (0, HP_RED), (-1.6, HP_LIGHT)]
    r = max(2.5, h * 0.09)
    for ch in text:
        if ch == "-":
            capsule(c, x, y + h / 2, x + w * 0.8, y + h / 2, r, r, bands, alpha)
            x += w * 1.1
        elif ch == "1":
            polyline(c, [(x + w * 0.1, y + h * 0.2), (x + w * 0.45, y), (x + w * 0.45, y + h)], [r] * 3, bands, alpha)
            x += w * 0.8
        elif ch == "5":
            pts = [(x + w, y), (x, y), (x, y + h * 0.45), (x + w * 0.75, y + h * 0.42), (x + w, y + h * 0.7),
                   (x + w * 0.75, y + h), (x, y + h)]
            polyline(c, pts, [r] * len(pts), bands, alpha)
            x += w * 1.3
        elif ch == "%":
            circle(c, x + w * 0.2, y + h * 0.2, h * 0.14, bands, alpha)
            circle(c, x + w * 0.85, y + h * 0.8, h * 0.14, bands, alpha)
            capsule(c, x + w, y, x, y + h, r, r, bands, alpha)
            x += w * 1.3


def trail(c, pts, w, alpha=1.0):
    """Vệt lửa theo đường vung búa (mỏng ở đuôi, dày ở đầu)."""
    if len(pts) < 2:
        return
    polyline(c, pts, [w * (0.25 + 0.75 * k / (len(pts) - 1)) for k in range(len(pts))], warm(w), alpha)


def arc(p0, p1, bulge, n=8):
    """Cung tròn gần đúng giữa hai điểm, phồng sang trái hướng đi bulge px."""
    (x0, y0), (x1, y1) = p0, p1
    L = math.hypot(x1 - x0, y1 - y0) or 1.0
    nx, ny = (y1 - y0) / L, -(x1 - x0) / L
    return [(x0 + (x1 - x0) * t + nx * bulge * math.sin(math.pi * t),
             y0 + (y1 - y0) * t + ny * bulge * math.sin(math.pi * t)) for t in (k / n for k in range(n + 1))]


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    hx, hy = HEAD["attack"][i]
    rnd = random.Random(i)
    if i <= 2:  # đầu búa nung: hơi nóng, tàn than bay khi kéo ra sau
        c.glow(hx, hy, 70, MAIN, 0.25 + 0.1 * i)
        for k in range(3 + i):
            ember(c, hx + rnd.uniform(-50, 50), hy - rnd.uniform(10, 70), rnd.uniform(3, 6), 0.9, rot=k)
    if i == 3:  # vung qua đầu: vệt lửa
        trail(c, arc(HEAD["attack"][2], (hx, hy), 70), 16)
    if i == 4:  # nện xuống (khung trúng): vệt bổ xuống + chớp ở đất
        trail(c, arc(HEAD["attack"][3], (hx, hy), 60), 18)
        fireball(c, hx, 430, 0, 90, 5)
    if i >= 5:  # khói ngắn và tàn than ở chỗ nện
        t = i - 4
        mx = HEAD["attack"][4][0]
        fireball(c, mx, 430, t, 70, 5, 0.8)
    return c.result()


def attack_hit(i):
    """Tia lửa than bắn tung lên, vòng khói ngắn quanh chân quái."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.3)
    if i == 0:
        c.glow(cx, cy + 40, 110, CORE, 0.75)
        circle(c, cx, cy + 40, 34, warm(34))
        return c.result()
    rnd = random.Random(20)
    for k in range(14):  # than bắn tung lên rồi rơi
        a = rnd.uniform(-math.pi * 0.9, -math.pi * 0.1)
        sp = rnd.uniform(40, 70)
        x = cx + math.cos(a) * sp * i * 0.8
        y = cy + 40 + math.sin(a) * sp * i * 0.8 + 9 * i * i
        drop(c, x, y, rnd.uniform(4, 6), 18, a + 0.25 * i, warm(5), al)
    for k in range(9):  # vòng khói ngắn
        a = k * math.tau / 9
        r = 60 + 22 * i
        smoke(c, cx + math.cos(a) * r, cy + 150 + math.sin(a) * r * 0.25 - i * 3, 14 + 3 * i, al * 0.9)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["chest"]
    rnd = random.Random(40 + i)
    if i <= 7:  # lửa bao thân (tiêu máu): lưỡi lửa quanh người, mạnh nhất khung 3
        g = min(1.0, (i + 1) / 3) * (1.0 if i <= 4 else max(0.0, 1 - (i - 4) / 4))
        c.glow(cx, cy + 30, 200, MAIN, 0.3 * g)  # da đỏ rực
        for k in range(22):  # lưỡi lửa dọc hai bên và dưới thân, chừa mặt
            a = -0.15 * math.pi + k * 1.3 * math.pi / 21
            x = cx + math.cos(a) * 100
            y = cy + 50 + math.sin(a) * 130
            h = (34 + 40 * math.sin(i * 1.9 + k * 2.3) ** 2) * g
            if h > 4:
                flame_tongue(c, x, y, h, 13, 0.9, lean=rnd.uniform(-0.25, 0.25) - math.cos(a) * 0.3)
    if i == 2:  # đấm búa vào ngực: chớp
        c.glow(cx + 10, cy - 10, 70, CORE, 0.6)
    if 2 <= i <= 6:  # số máu mất bay lên
        t = i - 2
        seg_text(c, "-15%", cx - 120, cy - 230 - t * 10, 34, fade(t, 5, 0.6))
    if 4 <= i <= 7:  # vệt quét ngang theo đầu búa
        pts = HEAD["skill"][max(4, i - 2):i + 1]
        if len(pts) >= 2:
            dense = []
            for a, b in zip(pts, pts[1:]):
                dense += arc(a, b, 50, 5)[:-1]
            trail(c, dense + [pts[-1]], 20, 1.0 if i <= 6 else 0.6)
    if i >= 7:  # thở ra khói
        t = i - 7
        mx, my = BATTLE_ANCHORS["mouth"]
        for k in range(3):
            smoke(c, mx + 20 + t * 18 + k * 12, my - 6 - t * 6 - k * 5, 8 + t * 3, fade(t, 3, 0.2))
    return c.result()


def skill_hit(i):
    """Vụ nổ lửa lớn trên mục tiêu chính, 2 vụ nhỏ ở hai quái bên cạnh (mép khung)."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    fireball(c, cx, cy, i, 150, 60)
    for k, (sx, sy) in enumerate(BATTLE_ANCHORS["side_targets_in_hit"]):
        fireball(c, sx, sy, i - 1, 70, 61 + k, 0.95)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    hx, hy = HEAD["ultimate"][i]
    rnd = random.Random(80 + i)
    if i <= 5:  # đầu búa nóng rực khi nhảy lên
        g = (i + 1) / 6
        c.glow(hx, hy, 60 + 50 * g, MAIN, 0.3 + 0.3 * g)
        for k in range(2 + i):
            ember(c, hx + rnd.uniform(-60, 60), hy + rnd.uniform(-40, 60), rnd.uniform(3, 7), 0.9, rot=k)
    if i in (6, 7):  # bổ xuống: vệt lửa lớn
        a, b = HEAD["ultimate"][i - 1], HEAD["ultimate"][i]
        trail(c, arc(a, b, 90 if i == 6 else 60), 24)
    gx = HEAD["ultimate"][7][0]
    if i == 7:
        fireball(c, gx, 430, 0, 130, 90)
    if 7 <= i <= 10:  # nứt đất dung nham lan về phía quái + sóng chấn
        t = (i - 6) / 4
        al = 1.0 if i < 10 else 0.6
        for k, (dx, dy) in enumerate(((1, 0.0), (1, 0.12), (1, -0.08), (-1, 0.06))):
            ln = (90 + 260 * t) * (0.4 if dx < 0 else 1.0)
            lava_crack(c, gx, 432, gx + dx * ln, 432 + dy * ln, 100 + k, 5, al)
        ring(c, gx, 432, 60 + 220 * t, 10 - 6 * t, warm(5), al * 0.8, sy=0.22)
        for k in range(4):
            smoke(c, gx - 40 + k * 30, 410 - (i - 7) * 20 - k * 5, 16 + (i - 7) * 5, al * 0.8)
    if i >= 9:  # 5 đốm lửa hồi máu bay về ngực Ignar
        tx, ty = BATTLE_ANCHORS["chest"]
        u = (i - 8) / 3
        for k in range(5):
            sx, sy = 520, 140 + k * 55
            p0, p1, p2 = (sx, sy), ((sx + tx) / 2, sy - 90), (tx, ty)
            x, y = bezier(p0, p1, p2, min(1.0, u + k * 0.04))
            x2, y2 = bezier(p0, p1, p2, min(1.0, u + k * 0.04) - 0.05)
            drop(c, x, y, 13, 44, math.atan2(y - y2, x - x2), warm(13))
            plus(c, x, y - 24, 10)
        if i == 11:
            c.glow(tx, ty, 90, LIGHT, 0.35)
    return c.result()


def ultimate_hit(i):
    """Cột dung nham phun lên dưới chân quái."""
    c = Canvas(512, 512)
    cx, ground = BATTLE_ANCHORS["target_feet"]
    al = fade(i, 8, 0.45)
    ellipse(c, cx, ground, 120, 26, [(0, DARK), (-6, DEEP), (-12, MAIN), (-18, LIGHT)], al)
    if i == 0:
        lava_crack(c, cx - 110, ground, cx + 110, ground + 4, 300, 5)
        return c.result()
    h = min(1.0, i / 2) * 250 * (1 - max(0, i - 5) * 0.25)
    if h > 10:
        c.glow(cx, ground - h / 2, 150, MAIN, 0.3 * al)
        capsule(c, cx, ground, cx + 6 * math.sin(i), ground - h, 78, 40, warm(40), al)
        for k in range(5):  # đỉnh cột sủi bọt
            bx = cx - 44 + k * 22 + 6 * math.sin(i + k)
            circle(c, bx, ground - h + 8 + 10 * math.cos(i * 1.7 + k), 22 - abs(k - 2) * 3, warm(20), al)
        for k in range(5):  # cục dung nham bắn ra từ đỉnh cột
            a = -math.pi / 2 + (k - 2) * 0.45
            d = 40 + 30 * i
            x, y = cx + math.cos(a) * d, ground - h + math.sin(a) * d * 0.5 + 6 * i * i
            circle(c, x, y, 12 - k % 2 * 3, warm(11), al)
    for k in range(4):
        smoke(c, cx - 70 + k * 46, ground - h - 20 - i * 6, 22 + i * 3, al * min(1.0, i / 3))
    return c.result()


def ultimate_screen(i):
    """Mặt đất nứt đỏ, dung nham sáng dưới nền, khói đen bốc lên."""
    c = Canvas(1024, 576, ss=1)
    g = min(1.0, (i + 1) / 2)
    al = fade(i, 12, 0.6)
    c.tint(hexc("#1A0C08"), 0.4 * g * al)
    if i >= 1:
        glow = 0.6 + 0.4 * math.sin(i * 1.3)
        for k in range(9):  # vết nứt ngang mặt đất
            y = 470 + (k % 3) * 30
            x0 = k * 115 - 40
            lava_crack(c, x0, y, x0 + 180, y + (k % 2) * 16 - 8, 400 + k, 5 * glow + 2, al)
        rnd = random.Random(500)
        for k in range(6):  # vũng dung nham
            x = rnd.uniform(60, 980)
            ellipse(c, x, 520 + rnd.uniform(-20, 30), 50, 10, [(0, DEEP), (-3, MAIN), (-6, LIGHT)], al * glow)
    if i >= 3:  # khói đen bốc lên
        rnd = random.Random(600)
        for k in range(14):
            x = rnd.uniform(0, 1024)
            y = 470 - (i - 3) * 30 - rnd.uniform(0, 80)
            smoke(c, x, y, 30 + (i - 3) * 5 + rnd.uniform(0, 10), al * 0.4)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

BOOM = ["...L.L.L...", "..LmLmLmL..", ".LmCCCCCmL.", "LmCCCCCCCmL", ".mCCCCCCCm.", "MmmCCCCCmmM",
        ".MMmmmmmMM."]
SMALL_BOOM = ["..L..", ".LmL.", "LmCmL", ".mMm."]
EMBER = ["L"]
ROCKP = ["OO", "DO"]
FLAME = [".L.", "LCL", "mCm", "MmM"]
MARK = ["..L..", ".LCL.", ".mCm.", "MmMmM"]


def opener_map(i):
    """Búa lửa giáng: vụ nổ tàn lửa quạt 100° phía trước, tầm 2 ô, đá vụn."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_impact"]
    hx, hy = MAP_ANCHORS["hammer_head"]
    if i <= 1:  # nhấc búa, giơ cao: đầu búa toả tàn than
        for k in range(2 + i):
            blit(px, EMBER, hx + 2 + k * 3, hy - 4 - k * 2 - i * 3)
    if i == 2:  # nện xuống (trúng)
        blit(px, BOOM, ox - 5, oy - 5)
    if i == 3:
        blit(px, SMALL_BOOM, ox - 2, oy - 2)
    if i in (2, 3):  # tàn lửa quạt ±50°, tầm 2 ô
        d = 12 if i == 2 else 22
        for a in (-50, -25, 0, 25, 50):
            r = math.radians(a - 10)
            x, y = ox + int(round(math.cos(r) * d)), oy + int(round(math.sin(r) * d * 0.7))
            blit(px, ["MmLC", ".MmL"] if i == 2 else ["DMmL"], x - 2, y)
    if i >= 3:  # đá vụn rơi
        rnd = random.Random(5)
        for k in range(5):
            x = ox + rnd.randrange(-6, 16)
            y = oy - 6 + (i - 3) * 4 + rnd.randrange(-4, 4)
            blit(px, ROCKP if k % 2 else ["O"], x, y)
    if i == 4:
        blit(px, ["D", "M"], ox, oy + 1)
    return px


def technique_map(i):
    """Bước chân lửa: lao tới để lại vệt lửa trên đất, quái chạm vệt có dấu lửa trên đầu."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    fx, feet = MAP_ANCHORS["technique_feet"]
    if i >= 1:  # vệt lửa dài dần phía sau
        tail = fx - 12
        start = max(0, tail - 10 * i)
        rnd = random.Random(i)
        for x in range(start, tail):
            h = rnd.randrange(1, 4)
            for k in range(h):
                ch = "C" if k == h - 1 and (x + i) % 4 == 0 else ("L" if k else "M")
                px[feet - k, x, :3] = PIXEL_PALETTE[ch]
                px[feet - k, x, 3] = 1
            px[feet + 1, x, :3] = PIXEL_PALETTE["D"]
            px[feet + 1, x, 3] = 1
    if i == 5:  # dấu lửa trên đầu quái
        blit(px, MARK, MAP_ANCHORS["technique_mark"][0] - 2, MAP_ANCHORS["technique_mark"][1])
    if 1 <= i <= 4:
        blit(px, FLAME, fx - 14, feet - 3)
    return px


V.run({
    "id": "ignar", "element_color": "#E8552B", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
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

"""Hiệu ứng skill của Kiri (Lửa #E8552B, pháo hoa), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/kiri/6_vfx/make_kiri_vfx.py
    blender -b -P design/nhan_vat/kiri/6_vfx/make_kiri_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/kiri/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#E8552B", light="#FFE08A", mid="#F7A23A", deep="#B3222E", core="#FFFBEF", dark="#5A1A10")
from vfx2d import *  # noqa: E402,F401,F403

SMOKE, SMOKE_EDGE = hexc("#8C8088"), hexc("#6B5E66")
# Bộ màu pháo hoa (viền, sáng, lõi) cho pháo hoa nhiều màu ở tuyệt kỹ
FIRE = (MAIN, LIGHT, CORE)
GOLD = (hexc("#E0A21E"), LIGHT, CORE)
RED = (DEEP, hexc("#FF8A6A"), CORE)
PINK = (hexc("#E84A8A"), hexc("#FFB3D1"), hexc("#FFF4F8"))
CYAN = (hexc("#2E9BE0"), hexc("#A8E4FF"), hexc("#F2FBFF"))
GREEN = (hexc("#4CB848"), hexc("#C4F29A"), hexc("#F6FFEE"))

# Điểm neo trong khung trận 512 (Kiri quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
STAR = {"attack": [(389, 55), (352, 40), (312, 35), (458, 143), (466, 207), (397, 75), (394, 62), (389, 55)],
        "skill": [(386, 55), (372, 40), (315, 43), (415, 72), (305, 37), (444, 112), (465, 182), (446, 117),
                  (401, 65), (389, 55)],
        "ultimate": [(389, 55), (463, 176), (427, 301), (414, 312), (387, 327), (371, 333), (463, 180), (338, 20),
                     (358, 33), (377, 50), (372, 67), (372, 67)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (268, 147), "eye": (300, 140), "chest": (277, 216),
                  "thumb": (172, 252), "target_center": (256, 270), "tubes_ground": (428, 430),
                  "wand_star_per_frame": STAR}
MAP_ANCHORS = {"opener_origin": (28, 37), "opener_feet": (16, 52), "technique_feet": (16, 52),
               "technique_bag": (6, 46)}
TUBES = [372, 400, 428, 456, 484]


def warm(size):
    """Bậc cel lửa: viền đỏ thẫm → cam → vàng → lõi trắng ấm."""
    return [(0, DEEP), (-0.2 * size, MAIN), (-0.45 * size, LIGHT), (-0.75 * size, CORE)]


def tri(cols, size):
    edge, mid, core = cols
    return [(0, edge), (-0.35 * size, mid), (-0.7 * size, core)]


def sparkle_tail(c, x, y, ang, n, gap, seed, alpha, cols=FIRE):
    """Chuỗi tàn lửa nhỏ phía sau một vật bay (ngược hướng ang)."""
    rnd = random.Random(seed)
    for k in range(1, n + 1):
        d = gap * k
        px = x - math.cos(ang) * d + rnd.uniform(-4, 4)
        py = y - math.sin(ang) * d + rnd.uniform(-4, 4)
        star(c, px, py, max(2.0, 7 - k * 0.9), tri(cols, 2), alpha * (1 - k / (n + 1)), rot=rnd.uniform(0, 1))


def bolt(c, x, y, ang, size, alpha=1.0, seed=0):
    """Tia pháo: đầu sáng, đuôi lửa, tàn lửa rơi phía sau."""
    c.glow(x, y, size * 3.2, LIGHT, 0.45 * alpha)
    drop(c, x, y, size, size * 4.2, ang, warm(size), alpha)
    sparkle_tail(c, x, y, ang, 5, size * 1.6, seed, alpha)


def smoke(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, SMOKE_EDGE), (-max(1.5, r * 0.25), SMOKE)], alpha * 0.75)


def petals(c, cx, cy, t, n, length, width, rot, alpha, cols=FIRE):
    """Hoa lửa n cánh: mỗi cánh là một giọt lửa toả ra từ tâm."""
    for k in range(n):
        a = rot + k * math.tau / n
        d = length * t
        x, y = cx + math.cos(a) * d, cy + math.sin(a) * d + 6 * t * t
        drop(c, x, y, width, max(width * 1.5, d * 0.8), a, tri(cols, width), alpha)


def firework(c, cx, cy, t, R, seed, cols, alpha=1.0, n=14):
    """Pháo hoa nổ: chớp sáng → 2 vòng tia toả ra, rơi dần, lấp lánh cuối (t tính bằng khung từ lúc nổ)."""
    if t < 0:
        return
    rnd = random.Random(seed)
    if t < 1:
        c.glow(cx, cy, R * 0.9, cols[2], 0.8 * alpha)
        star5(c, cx, cy, R * 0.32, tri(cols, R * 0.32), alpha, rot=rnd.uniform(0, 1))
        return
    life = 6.0
    k = min(1.0, (t - 1) / life)
    al = alpha * (1 - k) ** 0.7
    ease = 1 - (1 - min(1.0, (t - 0.5) / 2.5)) ** 2
    for ring_i, (rr, m, w) in enumerate(((R, n, 4.5), (R * 0.58, max(5, n * 2 // 3), 3.5))):
        rot = rnd.uniform(0, math.tau)
        for j in range(m):
            a = rot + j * math.tau / m
            d = rr * ease
            x = cx + math.cos(a) * d
            y = cy + math.sin(a) * d + 22 * k * k * R / 120  # rơi dần
            tail = max(6.0, d * 0.35)
            capsule(c, x, y, x - math.cos(a) * tail, y - math.sin(a) * tail - 4 * k, w, 0.8,
                    tri(cols, w), al)
            if t > 3 and rnd.random() < 0.35:
                star(c, x + rnd.uniform(-6, 6), y + rnd.uniform(-6, 6), rnd.uniform(4, 7), tri(cols, 1.5), al)


def tube(c, x, ground, h, alpha=1.0):
    """Ống pháo cắm đất: thân đỏ, sọc vàng, miệng tối."""
    hw = 11
    top = ground - h
    def box(X, Y):
        qx, qy = np.abs(X - x) - hw, np.abs(Y - (top + h / 2)) - h / 2
        return np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - 2
    bb = (x - hw - 4, top - 4, x + hw + 4, ground + 4)
    c.shape(box, bb, [(1.5, hexc("#141018")), (0, DEEP), (-4, hexc("#D4383E"))], alpha)
    for sy in (top + h * 0.3, top + h * 0.62):  # sọc vàng
        c.shape(lambda X, Y, sy=sy: np.maximum(box(X, Y), np.abs(Y - sy) - 4), bb, [(0, LIGHT)], alpha)
    ellipse(c, x, top + 1, hw - 1, 4, [(0, hexc("#141018")), (-1.5, hexc("#3A2A30"))], alpha)


def speed_streak(c, x, y, length, alpha):
    capsule(c, x, y, x - length, y, 3.2, 0.8, [(0, MID), (-1.2, CORE)], alpha)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    sx, sy = STAR["attack"][i]
    if i <= 2:  # thổi vào đầu gậy: sao bùng sáng dần
        g = (i + 1) / 3
        c.glow(sx, sy, 30 + 30 * g, LIGHT, 0.3 + 0.3 * g)
        star(c, sx, sy, 12 + 14 * g, tri(FIRE, 4), 0.9, rot=i * 0.4)
        for k in range(3 + 2 * i):
            a = k * math.tau / (3 + 2 * i) + i
            star(c, sx + math.cos(a) * (18 + 10 * g), sy + math.sin(a) * (18 + 10 * g), 5, tri(GOLD, 1.5), 0.8)
    if i == 3:  # bắn: chớp ở đầu gậy + tia pháo bay ra
        c.glow(sx, sy, 70, CORE, 0.6)
        star5(c, sx, sy, 26, warm(26), rot=0.3)
        bolt(c, sx + 40, sy + 12, 0.28, 13, seed=3)
    if i == 4:
        c.glow(sx, sy, 50, LIGHT, 0.35)
        star(c, sx, sy, 18, tri(FIRE, 4), 0.8)
        bolt(c, sx + 105, sy + 30, 0.28, 12, seed=4)
    if i >= 4:  # khói và tàn lửa ở đầu gậy
        t = i - 4
        mx, my = STAR["attack"][4]
        for k in range(3):
            smoke(c, mx - 6 + k * 9 - t * 3, my - 6 - t * 9 - k * 4, 7 + t * 2.5, fade(t, 4, 0.0) * 0.9)
        rnd = random.Random(8)
        for k in range(6):
            star(c, mx + rnd.uniform(-20, 20), my + rnd.uniform(0, 10) + t * 14, 5 - t * 0.6, tri(FIRE, 1.5),
                 fade(t, 4, 0.2), rot=rnd.uniform(0, 1))
    return c.result()


def attack_hit(i):
    """Nổ hoa lửa nhỏ 5 cánh trên quái."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    if i == 0:
        c.glow(cx, cy, 90, CORE, 0.7)
        star5(c, cx, cy, 34, warm(34), rot=0.2)
        return c.result()
    t = min(1.0, i / 3)
    petals(c, cx, cy, 0.4 + 0.6 * t, 5, 78, 13 - 2 * min(i, 4), 0.2 - math.pi / 2, al)
    petals(c, cx, cy, 0.3 + 0.5 * t, 5, 46, 8, 0.2 - math.pi / 2 + math.pi / 5, al, GOLD)
    ring(c, cx, cy, 30 + 22 * i, max(1.5, 7 - 1.4 * i), tri(FIRE, 3), al * 0.8)
    rnd = random.Random(12)
    for k in range(10):  # tàn lửa rơi
        a = rnd.uniform(0, math.tau)
        d = rnd.uniform(40, 90) * t
        star(c, cx + math.cos(a) * d, cy + math.sin(a) * d + 8 * i * i * 0.6, rnd.uniform(3, 6), tri(FIRE, 1.5), al)
    if i >= 3:
        for k in range(3):
            smoke(c, cx - 30 + k * 30, cy - 10 - (i - 3) * 10, 10 + (i - 3) * 4, fade(i - 3, 3, 0.0) * 0.8)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    path = STAR["skill"]
    if i <= 4:  # đầu gậy vẽ vòng: dải tia lửa theo sau
        pts = path[max(0, i - 2):i + 1]
        if len(pts) >= 2:
            polyline(c, pts, [2 + 5 * k / (len(pts) - 1) for k in range(len(pts))], tri(FIRE, 5), 0.9)
        sx, sy = path[i]
        c.glow(sx, sy, 40, LIGHT, 0.4)
        star(c, sx, sy, 16, tri(FIRE, 4), rot=i * 0.7)
        rnd = random.Random(i)
        for k in range(4):
            star(c, sx + rnd.uniform(-30, 30), sy + rnd.uniform(-20, 30), rnd.uniform(4, 7), tri(GOLD, 1.5), 0.85)
    if i in (5, 6):  # quả pháo bay vòng cung về phía đồng minh
        sx, sy = path[i]
        p0, p1, p2 = (sx, sy), (sx + 80, sy - 90), (600, 220)
        u = 0.25 if i == 5 else 0.8
        x, y = bezier(p0, p1, p2, u)
        x2, y2 = bezier(p0, p1, p2, u + 0.05)
        ang = math.atan2(y2 - y, x2 - x)
        bolt(c, x, y, ang, 11, seed=i)
        c.glow(sx, sy, 36, LIGHT, 0.35)
    if i >= 7:  # nháy mắt, giơ ngón cái: lấp lánh nhỏ
        t = i - 7
        ex, ey = BATTLE_ANCHORS["eye"]
        star(c, ex + 18, ey - 14 - t * 3, 13 - t * 2, tri(GOLD, 3), fade(t, 3, 0.3), rot=0.4)
        tx, ty = BATTLE_ANCHORS["thumb"]
        for k in range(3):
            a = -1.8 + k * 0.6
            star(c, tx + math.cos(a) * (24 + t * 6), ty - 10 + math.sin(a) * (24 + t * 6), 6, tri(FIRE, 1.5),
                 fade(t, 3, 0.3))
    return c.result()


def skill_hit(i):
    """Đồng minh: vòng lửa vàng quanh chân, mũi tên đỏ đi lên (tăng tấn công), vệt tốc độ ngang (kéo lượt)."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    if i == 0:  # quả pháo rơi xuống chân
        bolt(c, cx - 30, feet - 70, math.radians(70), 11, seed=20)
        return c.result()
    g = min(1.0, i / 2)
    ring(c, cx, feet, 80 + 30 * g, 14 - 2 * min(i, 4), warm(7), al, sy=0.3)
    flames = sorted(range(12), key=lambda k: math.sin(k * math.tau / 12 + i * 0.25))  # sau trước
    for k in flames:  # lưỡi lửa vàng mọc quanh chân
        a = k * math.tau / 12 + i * 0.25
        x = cx + math.cos(a) * (88 + 22 * g)
        y = feet + math.sin(a) * (88 + 22 * g) * 0.3
        h = (52 + 22 * math.sin(i * 1.7 + k * 2.1)) * g * (1 - max(0, i - 4) / 4)
        if h > 4:
            drop(c, x, y, 11, h, math.pi / 2, warm(11), al * (0.75 if math.sin(a) < 0 else 1.0))
    if 1 <= i <= 6:  # mũi tên đỏ đi lên
        for k, (ox, oy, s) in enumerate(((-72, 40, 22), (0, 0, 30), (70, 30, 20))):
            y = BATTLE_ANCHORS["chest"][1] + 40 + oy - (i - 1) * 22
            arrow_up(c, cx + ox, y, s, (hexc("#7A1018"), DEEP, hexc("#FF8A6A")), fade(i - 1, 6, 0.4))
    if 2 <= i <= 5:  # vệt tốc độ ngang
        rnd = random.Random(30)
        for k in range(6):
            y = 140 + k * 45 + rnd.uniform(-10, 10)
            x = 120 + (i - 2) * 90 + rnd.uniform(-30, 30)
            speed_streak(c, x, y, rnd.uniform(70, 120), fade(i - 2, 4, 0.3))
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    ground = BATTLE_ANCHORS["feet"][1]
    tube_al = 1.0 if i <= 8 else fade(i - 8, 4, 0.0)
    for k, x in enumerate(TUBES):  # 5 ống pháo cắm đất
        h = 64 * min(1.0, (i + 1) / 3) + (k % 2) * 6
        if i <= 1 and k > 2 * i + 2:
            continue
        tube(c, x, ground, h, tube_al)
    if 3 <= i <= 5:  # châm ngòi lần lượt
        lit = {3: 2, 4: 4, 5: 5}[i]
        for k in range(lit):
            x = TUBES[k]
            top = ground - 64 - (k % 2) * 6
            c.glow(x, top - 8, 22, LIGHT, 0.5)
            star(c, x, top - 8, 9 + (i + k) % 3 * 2, tri(FIRE, 3), rot=i + k)
        sx, sy = STAR["ultimate"][i]
        c.glow(sx, sy, 30, LIGHT, 0.5)
    if i == 6:  # 5 quả pháo phóng lên
        for k, x in enumerate(TUBES):
            top = ground - 64 - (k % 2) * 6
            c.glow(x, top, 40, CORE, 0.5)
            capsule(c, x, top - 10, x + (k - 2) * 6, top - 190, 7, 2, warm(7))
            bolt(c, x + (k - 2) * 8, top - 210 - k * 12, -math.pi / 2 + (k - 2) * 0.05, 9, seed=k)
    if i == 7:
        for k, x in enumerate(TUBES):
            top = ground - 64 - (k % 2) * 6
            capsule(c, x + (k - 2) * 10, top - 150, x + (k - 2) * 16, -20, 4, 1, tri(FIRE, 4), 0.8)
    if 7 <= i <= 10:  # khói ở miệng ống
        t = i - 7
        for k, x in enumerate(TUBES):
            top = ground - 64 - (k % 2) * 6
            smoke(c, x + (k - 2) * 3, top - 12 - t * 16, 9 + t * 3, fade(t, 4, 0.2))
    return c.result()


def ultimate_hit(i):
    """Pháo hoa nổ cam-vàng-đỏ trên đầu từng quái."""
    c = Canvas(512, 512)
    cx, cy = 256, 200
    firework(c, cx, cy, i, 150, 40, FIRE, 1.0, n=16)
    firework(c, cx - 50, cy + 60, i - 1, 90, 41, RED, 0.95, n=12)
    firework(c, cx + 60, cy + 30, i - 2, 80, 42, GOLD, 0.95, n=11)
    return c.result()


def ultimate_screen(i):
    """Nền tối lại, pháo hoa nhiều màu nở khắp nửa trên; ánh sáng vàng rọi xuống phe ta (bên trái)."""
    c = Canvas(1024, 576, ss=1)
    g = min(1.0, (i + 1) / 2)
    al = fade(i, 12, 0.7)
    c.tint(hexc("#14101C"), 0.38 * g * al)
    shows = [(160, 120, 0, PINK), (520, 80, 1, FIRE), (860, 140, 1, CYAN), (330, 210, 2, GOLD),
             (700, 230, 3, GREEN), (90, 250, 4, RED), (960, 60, 4, PINK), (450, 140, 5, CYAN)]
    for k, (x, y, start, cols) in enumerate(shows):
        firework(c, x, y, i - start, 110 + (k % 3) * 20, 60 + k, cols, al, n=14)
    if 3 <= i <= 10:  # ánh sáng vàng rọi xuống đồng minh
        a2 = fade(i - 3, 8, 0.5) * min(1.0, (i - 2) / 2)
        for k, x in enumerate((120, 240, 360)):
            capsule(c, x, -10, x - 30, 560, 46, 60, [(0, hexc("#E0A21E"))], 0.07 * a2)
            capsule(c, x, -10, x - 30, 560, 20, 28, [(0, LIGHT)], 0.10 * a2)
        rnd = random.Random(i)
        for k in range(12):
            star(c, rnd.uniform(60, 420), rnd.uniform(200, 540), rnd.uniform(4, 8), tri(GOLD, 1.5), a2)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

SPARK = [".L.", "LCL", ".L."]
SPARK_L = ["..L..", ".LML.", "LMCML", ".LML.", "..L.."]
STREAK_R = ["DMmLC"]
STREAK_UR = ["...C", "..L.", ".m..", "M..."]
EMBER = ["M"]
ROCKET = [".OO.", "OMDO", "OMDO", ".LL."]
BOOM = ["...L...", ".L.m.L.", "..mCm..", "LmCCCmL", "..mCm..", ".L.m.L.", "...L..."]
STAR_ICON = ["..L..", ".LCL.", "LCCCL", ".LCL.", "L...L"]


def opener_map(i):
    """Quạt tia lửa 90°, tầm 2 ô, tàn lửa rơi."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 0:
        blit(px, SPARK, ox - 1, oy - 1)
    if i == 1:
        blit(px, SPARK_L, ox - 2, oy - 2)
    if i in (2, 3):  # 5 tia toả quạt ±45°
        d = 8 if i == 2 else 18
        for a in (-45, -22, 0, 22, 45):
            r = math.radians(a)
            x, y = ox + int(round(math.cos(r) * d)), oy + int(round(math.sin(r) * d))
            if abs(a) < 30:
                blit(px, STREAK_R, x - 2, y)
            else:
                blit(px, STREAK_UR, x - 1, y - 2 if a < 0 else y - 1, flip_v=a > 0)
        if i == 2:
            blit(px, SPARK, ox - 1, oy - 1)
    if i >= 3:  # tàn lửa rơi
        rnd = random.Random(7)
        for k in range(9):
            a = math.radians(rnd.uniform(-45, 45))
            d = rnd.uniform(14, 28)
            x = ox + int(math.cos(a) * d)
            y = oy + int(math.sin(a) * d) + (i - 3) * 3
            if i == 4 and k % 2:
                continue
            blit(px, EMBER if k % 3 else ["L"], x, y)
    return px


def technique_map(i):
    """Rút pháo từ túi, ném vòng cung 3 ô, nổ hoa lửa; quái trúng có dấu sao vàng."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    bx, by = MAP_ANCHORS["technique_bag"]
    land = (54, 50)
    if i <= 1:
        blit(px, ROCKET, bx - 1, by - 6 - i * 3)
        if i == 1:
            blit(px, SPARK, bx, by - 11)
    if i in (2, 3):  # bay vòng cung
        u = 0.35 if i == 2 else 0.8
        x = bx + (land[0] - bx) * u
        y = by - 6 + (land[1] - by + 6) * u - 26 * math.sin(math.pi * u)
        blit(px, ROCKET, int(x) - 2, int(y) - 2)
        tx = bx + (land[0] - bx) * (u - 0.12)
        ty = by - 6 + (land[1] - by + 6) * (u - 0.12) - 26 * math.sin(math.pi * (u - 0.12))
        blit(px, ["L"], int(tx), int(ty))
    if i >= 4:  # nổ hoa lửa + dấu sao trên đầu quái
        blit(px, BOOM, land[0] - 3, land[1] - 3 - (i - 4) * 2)
        rnd = random.Random(9)
        for k in range(8):
            a = k * math.tau / 8
            d = 7 + (i - 4) * 4
            blit(px, ["m" if k % 2 else "L"], land[0] + int(math.cos(a) * d), land[1] - 3 + int(math.sin(a) * d))
        if i == 5:
            blit(px, STAR_ICON, land[0] - 2, land[1] - 16)
    return px


V.run({
    "id": "kiri", "element_color": "#E8552B", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "ally",
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

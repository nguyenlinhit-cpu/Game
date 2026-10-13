"""Hiệu ứng skill của Mira (Nước #3A8DDE), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/mira/6_vfx/make_mira_vfx.py
    blender -b -P design/nhan_vat/mira/6_vfx/make_mira_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/mira/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#3A8DDE", light="#CDEBFF", mid="#7CC0F2", deep="#1F5FB8", core="#F4FBFF", dark="#14365F")
from vfx2d import *  # noqa: E402,F401,F403

water, water_deep = bands, bands_deep

# Điểm neo trong khung trận 512 (Mira quay phải, chân ở (256, 430) = anchor 0.5/0.84 như sprite trận).
BATTLE_ANCHORS = {"feet": (256, 430), "wand_tip": (352, 168), "flask": (195, 250),
                  "hands": (300, 185), "chest": (262, 230), "target_center": (256, 270)}
MAP_ANCHORS = {"opener_origin": (29, 34), "opener_feet": (16, 52), "technique_feet": (32, 56)}


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    wx, wy = BATTLE_ANCHORS["wand_tip"]
    if i <= 2:  # tụ sáng ở đầu đũa
        s = [7, 12, 18][i]
        for k in range(4 if i else 0):
            a = k * math.pi / 2 + 0.6
            d = 30 - i * 10
            circle(c, wx + math.cos(a) * d, wy + math.sin(a) * d, 3, water(3))
        c.glow(wx, wy, s * 1.8, LIGHT, 0.35)
        star(c, wx, wy, s, water(s * 0.22), rot=i * 0.3)
    if i in (3, 4):  # chớp sáng ở đầu đũa khi bắn
        s = 30 if i == 3 else 20
        c.glow(wx, wy, s * 2.2, LIGHT, 0.5)
        star(c, wx, wy, s, water(s * 0.25), rot=0.2)
        circle(c, wx, wy, s * 0.45, water(s * 0.45))
    if 3 <= i <= 7:
        for k in range(3):
            t = i - (3 + k * 0.4)
            if t < 0:
                continue
            x = wx + 22 + t * 115
            y = wy + 10 * t - [0, 12, -10][k]
            if x < 580:
                drop(c, x, y, 13, 46, math.atan2(10, 115), water_deep(13))
    if i >= 4:  # vài giọt nhỏ văng ngược và rơi xuống do lực bắn
        rnd = random.Random(3)
        t = i - 3
        for k in range(5):
            vx, vy = rnd.uniform(-30, 5), rnd.uniform(-28, -10)
            x, y = wx + vx * t, wy + vy * t + 7 * t * t
            drop(c, x, y, max(2.0, 5.5 - t * 0.7), 12, math.atan2(vy + 14 * t, vx), water(5), fade(t, 5, 0.3))
    return c.result()


def splash_burst(c, cx, cy, t, scale, seed):
    """Giọt nước vỡ: vương miện tia nước + vòng sóng + giọt văng + bọt."""
    rnd = random.Random(seed)
    s = scale
    if t == 0:  # khoảnh khắc chạm: khối nước dẹt + tia nước ngắn dày
        c.glow(cx, cy, 90 * s, LIGHT, 0.55)
        for k in range(9):
            a = k * math.tau / 9 + 0.3
            ln = (52 + 14 * (k % 2)) * s
            drop(c, cx + math.cos(a) * ln, cy + math.sin(a) * ln, 10 * s, ln - 8 * s, a, water(10 * s))
        ellipse(c, cx, cy, 40 * s, 32 * s, water_deep(32 * s))
        return
    al = fade(t, 6, 0.3)
    ring(c, cx, cy, (50 + 24 * t) * s, max(1.5, (9 - 2.2 * t) * s), water(4 * s), al * 0.85, sy=0.8)
    if t <= 2:  # vương miện nước bung ra
        for k in range(9):
            a = k * math.tau / 9 + 0.3
            r1 = (70 + 26 * t + 10 * (k % 2)) * s
            drop(c, cx + math.cos(a) * r1, cy + math.sin(a) * r1, (10 - 3 * t) * s, (34 - 8 * t) * s, a,
                 water((10 - 3 * t) * s), al)
        ellipse(c, cx, cy, (30 - 9 * t) * s, (24 - 7 * t) * s, water(24 * s), al)
    for k in range(12):  # giọt văng theo đường parabol
        a = rnd.uniform(-math.pi, 0.1)
        v = rnd.uniform(40, 70) * s
        x = cx + math.cos(a) * v * t
        y = cy + math.sin(a) * v * t + 10 * s * t * t
        vy = math.sin(a) * v + 20 * s * t
        r = max(2.0, rnd.uniform(6, 10) * s * (1 - t / 7))
        drop(c, x, y, r, r * 2.8, math.atan2(vy, math.cos(a) * v), water(r), al)
    for k in range(8):  # bọt trắng nổi lên rồi vỡ dần
        bx = cx + rnd.uniform(-55, 55) * s
        by = cy + rnd.uniform(-25, 30) * s - t * 8 * s
        r = rnd.uniform(6, 13) * s
        if t >= 1 and rnd.random() < t / 6:
            continue
        bubble(c, bx, by, r, al)


def attack_hit(i):
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    splash_burst(c, cx, cy, i, 1.0, 11)
    if i >= 1:  # giọt 2 và 3 tới sau, vỡ nhỏ hơn
        splash_burst(c, cx + 26, cy - 34, i - 1, 0.55, 12)
    if i >= 2:
        splash_burst(c, cx - 22, cy + 30, i - 2, 0.5, 13)
    return c.result()


def whirl(c, cx, cy, r, rot, width, alpha=1.0, sy=0.45):
    """Xoáy nước: 3 nhánh cung xoắn nằm nghiêng quanh tâm."""
    for k in range(3):
        a0 = rot + k * math.tau / 3
        pts, radii = [], []
        for s in range(12):
            u = s / 11
            a = a0 + u * 2.1
            rr = r * (0.55 + 0.45 * u)
            pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr * sy))
            radii.append(width * math.sin(math.pi * min(1, u * 1.15)) + 0.6)
        polyline(c, pts, radii, water(width), alpha)


def skill_cast(i):
    c = Canvas(512, 512)
    fx, fy = BATTLE_ANCHORS["flask"]
    neck = (fx + 14, fy - 38)
    if i <= 6:
        g = min(1.0, (i + 1) / 4)
        whirl(c, fx, fy + 4, 30 + 26 * g, i * 0.9, 4 + 3 * g, fade(i, 9, 0.6))
        c.glow(fx, fy, 60 * g, LIGHT, 0.25 * g)
    if 1 <= i <= 3:  # nước xoáy dâng lên khỏi miệng bình
        h = 25 * i
        whirl(c, neck[0], neck[1] - h * 0.6, 12 + 4 * i, -i * 1.1, 3 + i, 1.0, sy=0.35)
        capsule(c, neck[0], neck[1], neck[0] + 4, neck[1] - h, 6, 3, water(6))
    if 4 <= i <= 7:  # dòng nước bay vòng cung về phía đồng minh (lên trên, ra khỏi khung bên phải)
        p0, p1, p2 = neck, (300, -90), (600, 120)
        head = [0.35, 0.7, 1.05, 1.3][i - 4]
        tail = max(0.0, head - 0.55)
        pts, radii = [], []
        steps = 18
        for s in range(steps + 1):
            u = tail + (head - tail) * s / steps
            if u > 1.15:
                break
            pts.append(bezier(p0, p1, p2, u))
            radii.append(1 + 11 * (s / steps) ** 0.7)
        polyline(c, pts, radii, water_deep(11), fade(i - 4, 4, 0.5))
        rnd = random.Random(i)
        for k in range(6):
            u = tail + (head - tail) * rnd.random()
            x, y = bezier(p0, p1, p2, u)
            circle(c, x + rnd.uniform(-16, 16), y + rnd.uniform(-10, 18), rnd.uniform(2, 4.5), water(4))
    if i >= 7:  # đóng nắp: giọt lấp lánh còn lại
        rnd = random.Random(7)
        for k in range(6):
            x = fx + rnd.uniform(-40, 40)
            y = fy + rnd.uniform(-50, 10) - (i - 7) * 6
            star(c, x, y, rnd.uniform(5, 9) * (1 - (i - 7) / 4), water(1.5), fade(i - 7, 3, 0.0))
    return c.result()


def heal_column(c, cx, feet, height, width, t_phase, alpha):
    """Cột nước trong bao lấy người, mép gợn sóng."""
    top = feet - height
    def sdf(X, Y):
        wob = 4 * np.sin(Y * 0.07 + t_phase) + 2.5 * np.sin(Y * 0.17 - t_phase * 1.7)
        side = np.abs(X - cx) - (width / 2 + wob)
        r = width / 2
        capc = np.hypot(np.maximum(np.abs(X - cx) - 0, 0), np.maximum(top + r - Y, 0)) - (r + wob)
        body = np.where(Y < top + r, capc, side)
        bottom = Y - feet
        return np.maximum(body, bottom)
    bbox = (cx - width / 2 - 8, top - 8, cx + width / 2 + 8, feet + 2)
    c.shape(sdf, bbox, [(0, MAIN), (-4, MID)], alpha * 0.32)
    c.shape(lambda X, Y: sdf(X, Y) + 3, bbox, [(0, LIGHT)], alpha * 0.22)
    # viền sáng mảnh + vệt sáng dọc
    c.shape(lambda X, Y: np.abs(sdf(X, Y) + 1.5) - 1.5, bbox, [(0, LIGHT)], alpha * 0.85)
    for k, side in enumerate((-1, 1)):
        x = cx + side * (width / 2 - 16 - 6 * k)
        capsule(c, x, top + width * 0.45, x, feet - 16, 3, 1.5, [(0, CORE)], alpha * 0.7)


def skill_hit(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    body = BATTLE_ANCHORS["chest"][1]
    rnd = random.Random(21)
    al = fade(i, 8, 0.55)
    # vòng nước dưới chân
    ring(c, cx, feet, 70 + 12 * min(i, 3), 7, water(4), al, sy=0.3)
    h = [0.3, 0.75, 1.0, 1.0, 1.0, 0.95, 0.9, 0.85][i] * 390
    w = 210 if i < 5 else 210 - (i - 4) * 30
    heal_column(c, cx, feet, h, w, i * 1.3, al)
    for k in range(12):  # bong bóng bay lên
        if i < 1:
            break
        bx = cx + rnd.uniform(-85, 85)
        by = feet - 20 - ((rnd.uniform(0, 300) + i * 45) % 340)
        bubble(c, bx, by, rnd.uniform(4, 10), al)
    if 2 <= i <= 6:  # dấu cộng lớn ở giữa + 2 dấu nhỏ bay lên
        s = [16, 26, 24, 22, 20][i - 2]
        plus(c, cx, body - (i - 2) * 6, s, fade(i - 2, 5, 0.5))
        plus(c, cx - 60, body + 40 - (i - 2) * 18, 9, fade(i - 2, 5, 0.3))
        plus(c, cx + 58, body + 10 - (i - 2) * 16, 11, fade(i - 2, 5, 0.3))
    if 1 <= i <= 4:  # hiệu ứng xấu vỡ thành mảnh đen bay đi
        for k in range(9):
            a = k * math.tau / 9 + 0.3
            d = 20 + (i - 1) * 42
            shard(c, cx + math.cos(a) * d, body + math.sin(a) * d * 0.8, 11 - (i - 1) * 1.5,
                  a + i, fade(i - 1, 4, 0.3))
    if i == 0:  # dòng nước tới từ trên
        drop(c, cx - 30, body - 120, 14, 70, math.radians(70), water_deep(14))
    return c.result()


FLASK_H = 46


def flask_glyph(c, x, y, s=1.0, alpha=1.0, spin=0.0):
    """Bình thuỷ tinh giọt nước đang bay: thân tròn, cổ, nút bần, nước phát sáng."""
    c.glow(x, y, 50 * s, LIGHT, 0.4 * alpha)
    nx, ny = x + math.sin(spin) * 20 * s, y - math.cos(spin) * 20 * s
    capsule(c, x, y, nx, ny, 9 * s, 7 * s, [(0, DEEP), (-1.5, LIGHT)], alpha)
    cx2, cy2 = x + math.sin(spin) * 29 * s, y - math.cos(spin) * 29 * s
    circle(c, cx2, cy2, 6 * s, [(0, hexc("#5A3A28")), (-1.5, hexc("#8A6040"))], alpha)
    circle(c, x, y + 4 * s, 19 * s, [(0, DEEP), (-1.5, LIGHT)], alpha)
    c.shape(lambda X, Y: np.maximum(np.hypot(X - x, Y - y - 4 * s) - 16 * s, (y - 1 * s) - Y),
            (x - 20 * s, y - 20 * s, x + 20 * s, y + 24 * s), [(0, MAIN), (-4 * s, MID), (-9 * s, CORE)], alpha)
    circle(c, x - 8 * s, y - 2 * s, 3.5 * s, [(0, CORE)], alpha)


def ultimate_cast(i):
    c = Canvas(512, 512)
    fx, fy = BATTLE_ANCHORS["flask"]
    hx, hy = BATTLE_ANCHORS["hands"]
    if i <= 5:  # tung bình lên cao, vệt lấp lánh theo sau
        path = [(fx, fy), (hx + 10, hy), (hx + 45, 130), (hx + 60, 80), (hx + 55, 48), (hx + 40, 34)]
        x, y = path[i]
        for k in range(1, 4):
            if i - k >= 0:
                px, py = path[i - k]
                star(c, px + 6 * k, py + 8 * k, 9 - 2 * k, water(1.6), 1 - k * 0.25, rot=i)
        flask_glyph(c, x, y, 1.0, 1.0, spin=i * 0.5)
    if 3 <= i <= 9:  # chắp tay cầu nguyện: sáng nhẹ ở tay
        c.glow(hx, hy + 5, 34, LIGHT, 0.35 * fade(i - 3, 7, 0.6))
        star(c, hx + 4, hy - 4, 10, water(2), fade(i - 3, 7, 0.6), rot=i * 0.4)
    if i == 6:  # bình vỡ
        cx, cy = BATTLE_ANCHORS["hands"][0] + 40, 34
        c.glow(cx, cy, 120, CORE, 0.7)
        circle(c, cx, cy, 34, water_deep(34))
        for k in range(10):
            a = k * math.tau / 10
            capsule(c, cx + math.cos(a) * 30, cy + math.sin(a) * 30,
                    cx + math.cos(a) * 75, cy + math.sin(a) * 75, 6, 1, water(6))
    if 6 <= i <= 9:  # bình vỡ thành mây nhỏ rồi tan (mây lớn và mưa nằm ở lớp screen)
        g = min(1.0, (i - 5) / 2)
        cloud(c, BATTLE_ANCHORS["hands"][0] + 40, 44, 120 + 90 * g, 40, 5, fade(i - 6, 4, 0.5))
    return c.result()


def ultimate_hit(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    body = BATTLE_ANCHORS["chest"][1]
    al = fade(i, 8, 0.5)
    c.glow(cx, body, 190, LIGHT, 0.18 * al)
    rain(c, cx - 130, cx + 130, 20, feet, i, 41, 22, 40, al)
    for k in range(3):  # gợn nước dưới chân
        t = i - k * 1.5
        if t >= 0:
            ring(c, cx + (k - 1) * 50, feet - 2, 14 + t * 14, max(1.2, 4 - t * 0.5), water(2.5),
                 al * max(0, 1 - t / 6), sy=0.32)
    rnd = random.Random(42)
    for k in range(10):
        if i < 1:
            break
        bx = cx + rnd.uniform(-80, 80)
        by = feet - 30 - ((rnd.uniform(0, 260) + i * 38) % 300)
        bubble(c, bx, by, rnd.uniform(4, 9), al)
    if 1 <= i <= 6:
        plus(c, cx, body - 10 - (i - 1) * 7, 14 + min(i, 3) * 4, fade(i - 1, 6, 0.5))
        plus(c, cx - 64, body + 50 - (i - 1) * 16, 10, fade(i - 1, 6, 0.3))
        plus(c, cx + 62, body + 24 - (i - 1) * 14, 9, fade(i - 1, 6, 0.3))
    if 1 <= i <= 4:  # mỗi người giải 1 hiệu ứng xấu
        for k in range(7):
            a = k * math.tau / 7 + 1.1
            d = 22 + (i - 1) * 40
            shard(c, cx + math.cos(a) * d, body + math.sin(a) * d * 0.8, 9 - (i - 1) * 1.3, a - i,
                  fade(i - 1, 4, 0.3))
    return c.result()


def ultimate_screen(i):
    c = Canvas(1024, 576, ss=1)
    g = min(1.0, (i + 1) / 3)
    al = fade(i, 12, 0.7)
    c.tint(LIGHT, 0.10 * g * al)
    rnd_c = random.Random(9)
    back = [(rnd_c.uniform(-40, 1060), rnd_c.uniform(70, 95), rnd_c.uniform(200, 300)) for _ in range(5)]
    front = [(-30 + k * 230 + rnd_c.uniform(-40, 40), rnd_c.uniform(40, 62), rnd_c.uniform(240, 340)) for k in range(5)]
    drop_in = (1 - g) * 120
    for k, (x, y, w) in enumerate(back):
        cloud(c, x + i * 3, y - drop_in, w, 46, 30 + k, al * 0.75, rows=1)
    for k, (x, y, w) in enumerate(front):
        cloud(c, x - i * 4, y - drop_in, w, 64, 50 + k, al)
    if i >= 2:
        rain(c, 0, 1024, 90, 576, i - 2, 77, 70, 46, al, speed=70)
    rnd = random.Random(i)
    for k in range(10):
        star(c, rnd.uniform(0, 1024), rnd.uniform(160, 560), rnd.uniform(5, 11), water(2), al * 0.9,
             rot=rnd.uniform(0, 1))
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

DROP_R = ["..MM.",
          "OMmCM",
          "..MM."]
DROP_UR = ["..MM",
           ".MCM",
           "OmM.",
           "O..."]
GLINT_S = [".L.", "LCL", ".L."]
GLINT_L = ["..L..", "..L..", "LLCLL", "..L..", "..L.."]
DROP_ICON = ["..M..",
             ".MMM.",
             "MmCmM",
             "MLLmM",
             "DMMMD",
             ".DDD."]
RAIN = ["C", "L", "M"]


def opener_map(i):
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i == 0:
        blit(px, GLINT_S, ox - 1, oy - 1)
    if i == 1:
        blit(px, GLINT_L, ox - 2, oy - 2)
    dist = {1: 5, 2: 16, 3: 27}
    if i in dist:
        d = dist[i]
        if i < 3:
            blit(px, DROP_R, ox + d - 2, oy - 1)
            dd = d * 0.82  # quạt hẹp 60°: ±30°
            blit(px, DROP_UR, ox + int(dd) - 2, oy - int(d * 0.5) - 2)
            blit(px, DROP_UR, ox + int(dd) - 2, oy + int(d * 0.5) - 1, flip_v=True)
    if i >= 3:  # vỡ thành 4 chấm
        spread = 2 if i == 3 else 5
        for ex, ey in [(ox + 29, oy), (ox + 25, oy - 14), (ox + 25, oy + 14)]:
            for sx, sy in [(-1, -1), (1, -1), (-1, 1), (1, 1)]:
                X, Y = ex + sx * spread, ey + sy * spread + (1 if i == 4 else 0)
                col = "C" if i == 3 else "M"
                blit(px, [col + col] if i == 3 else [col], X, Y)
            if i == 3:
                blit(px, GLINT_S, ex - 1, ey - 1)
    return px


def technique_map(i):
    px = np.zeros((64, 64, 4), dtype=np.float32)
    fx, fy = MAP_ANCHORS["technique_feet"]
    flask = (fx - 11, fy - 9)
    if i == 0:
        blit(px, GLINT_S, flask[0] - 1, flask[1] - 1)
    if 1 <= i <= 2:  # mở nắp, nước bắn lên trời
        for k in range(4 + i * 4):
            y = flask[1] - 3 - k * 3
            if y < 2:
                break
            blit(px, ["C" if k % 2 else "L"], flask[0] + (k % 2), y)
        if i == 2:
            blit(px, GLINT_L, flask[0] - 2, 2)
    if i >= 3:  # mưa sương nhỏ rơi quanh, bán kính ~1 ô
        rnd = random.Random(5)
        for k in range(12):
            a = rnd.uniform(0, math.tau)
            r = rnd.uniform(8, 22)
            x = fx + int(math.cos(a) * r)
            y0 = rnd.randrange(4, 40)
            y = (y0 + (i - 3) * 7) % 52 + 2
            if i == 5 and k % 3 == 0:
                continue
            blit(px, RAIN[:3 - (k % 2)], x, y)  # hạt mưa dọc 2–3 px
        for k in range(3):
            blit(px, GLINT_S, fx - 18 + k * 16, fy - 30 + ((k + i) % 3) * 9)
    if i == 5:
        blit(px, DROP_ICON, fx - 2, 6)
    return px


V.run({
    "id": "mira", "element_color": "#3A8DDE", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
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

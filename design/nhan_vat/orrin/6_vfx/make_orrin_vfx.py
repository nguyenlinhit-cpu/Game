"""Hiệu ứng skill của Orrin (Hồn #F2D58A, chữ cổ – trang sách – thư viện), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/orrin/6_vfx/make_orrin_vfx.py
    blender -b -P design/nhan_vat/orrin/6_vfx/make_orrin_vfx.py -- --only attack,opener

Xuất vào design/nhan_vat/orrin/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#F2D58A", light="#FFF0C2", mid="#F7E2A8", deep="#C9A04A", core="#FFFDF4", dark="#5A4420")
from vfx2d import *  # noqa: E402,F401,F403

PAPER, PAPER_EDGE, INK = hexc("#F4EEDF"), hexc("#B8A882"), hexc("#7A5A2A")
NIGHT, LEATHER = hexc("#1E2747"), hexc("#7A4E2D")

# Điểm neo trong khung trận 512 (Orrin quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
TIP = {"attack": [(413, 67), (381, 49), (346, 38), (482, 149), (501, 200), (473, 130), (423, 74), (413, 67)],
       "skill": [(413, 67), (407, 63), (395, 56), (388, 53), (445, 95), (484, 154), (494, 182), (481, 147), (442, 91),
                 (413, 67)],
       "ultimate": [(413, 67), (392, 53), (341, 30), (286, 22), (261, 23), (389, 45), (475, 145), (471, 136), (461, 119),
                    (455, 110), (427, 78), (427, 78)]}
BOOK_ATTACK = [(135, 230), (184, 220), (233, 212), (238, 212), (242, 214), (211, 220), (180, 225), (135, 232)]
BOOKS_SKILL = [(151, 94), (308, 97), (151, 202), (377, 242)]
BATTLE_ANCHORS = {"feet": (256, 430), "head": (243, 171), "eye": (260, 194), "chest": (248, 270),
                  "target_center": (256, 270), "quill_tip_per_frame": TIP, "front_book_attack": BOOK_ATTACK,
                  "books_skill_frame5": BOOKS_SKILL}
MAP_ANCHORS = {"opener_origin": (30, 32), "opener_feet": (16, 52), "technique_feet": (32, 56)}


def glow_band(w):
    return [(0, DEEP), (-0.3 * w, MAIN), (-0.6 * w, CORE)]


def rune(c, cx, cy, s, seed, alpha=1.0, rot=0.0):
    """Chữ cổ vàng: vòng tròn + 3–4 nét gấp ngẫu nhiên bên trong (giống ký tự thư tịch)."""
    rnd = random.Random(seed)
    c.glow(cx, cy, s * 1.6, MAIN, 0.3 * alpha)
    ring(c, cx, cy, s, max(1.8, s * 0.12), glow_band(s * 0.12), alpha)
    co, si = math.cos(rot), math.sin(rot)
    for k in range(rnd.randint(3, 4)):
        pts = []
        for _ in range(rnd.randint(2, 3)):
            u, v = rnd.uniform(-0.6, 0.6) * s, rnd.uniform(-0.6, 0.6) * s
            pts.append((cx + u * co - v * si, cy + u * si + v * co))
        polyline(c, pts, [max(1.5, s * 0.09)] * len(pts), glow_band(s * 0.09), alpha)


def page(c, x, y, s, ang, alpha=1.0, glow=True):
    """Trang giấy bay (hình bình hành nghiêng), dòng chữ nhạt, mép vàng."""
    co, si = math.cos(ang), math.sin(ang)

    def at(u, v):
        return x + u * co - v * si, y + u * si + v * co
    if glow:
        c.glow(x, y, s * 1.8, MAIN, 0.2 * alpha)
    polygon(c, [at(-s, -s * 0.7), at(s, -s * 0.8), at(s * 0.9, s * 0.7), at(-s * 1.05, s * 0.75)],
            [(1.5, DEEP), (0, PAPER)], alpha)
    for k in range(3):
        v = -s * 0.35 + k * s * 0.35
        capsule(c, *at(-s * 0.6, v), *at(s * 0.55, v), 1.2, 1.2, [(0, PAPER_EDGE)], alpha)


def dust(c, cx, cy, t, n, seed, r, alpha=1.0):
    rnd = random.Random(seed)
    for k in range(n):
        a = rnd.uniform(0, math.tau)
        d = r * (0.3 + 0.7 * rnd.random()) * (0.4 + 0.6 * t)
        star(c, cx + math.cos(a) * d, cy + math.sin(a) * d - 10 * t, rnd.uniform(3, 7), [(0, MAIN), (-0.6, CORE)],
             alpha, rot=a)


def big_book(c, cx, cy, w, open_, alpha=1.0):
    """Sách khổng lồ mở trên đầu: bìa da xanh đêm, 2 trang giấy toả sáng."""
    h = w * 0.55
    c.glow(cx, cy, w * 1.1, MAIN, 0.35 * alpha * open_)
    ang = (1 - open_) * 1.2
    for side in (-1, 1):
        spread = w * (0.25 + 0.75 * open_)
        cover = [(cx, cy - h * 0.5), (cx + side * spread, cy - h * 0.5 - side * 0 + ang * 20),
                 (cx + side * spread, cy + h * 0.5), (cx, cy + h * 0.5)]
        polygon(c, cover, [(2, OUTLINE_C), (0, NIGHT)], alpha)
        inner = [(cx, cy - h * 0.42), (cx + side * spread * 0.94, cy - h * 0.42 + ang * 20),
                 (cx + side * spread * 0.94, cy + h * 0.42), (cx, cy + h * 0.42)]
        polygon(c, inner, [(0, PAPER), (-6, CORE)], alpha)
        for k in range(4):
            y = cy - h * 0.25 + k * h * 0.17
            capsule(c, cx + side * 12, y, cx + side * spread * 0.8, y, 1.5, 1.5, [(0, MAIN)], alpha * open_)


OUTLINE_C = hexc("#141018")


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    bx, by = BOOK_ATTACK[i]
    if 1 <= i <= 6:  # sách mở trước mặt: trang sáng
        c.glow(bx + 10, by - 10, 50, MAIN, 0.35)
    tx, ty = TIP["attack"][i]
    if i in (3, 4):  # vạch bút: vệt mực vàng, chữ bay ra
        a, b = TIP["attack"][i - 1], (tx, ty)
        polyline(c, [a, ((a[0] + b[0]) / 2 + 20, (a[1] + b[1]) / 2), b], [2, 7, 3], glow_band(7), 0.9)
        rune(c, 470 if i == 3 else 520, 250, 34, 3, 1.0, rot=i * 0.3)
    if i >= 5:  # đẩy kính: lấp lánh
        ex, ey = BATTLE_ANCHORS["eye"]
        star(c, ex + 10, ey - 4, 12 - 2 * (i - 5), [(0, LIGHT), (-0.6, CORE)], 1 - 0.25 * (i - 5), rot=0.4)
    return c.result()


def attack_hit(i):
    """Chữ cổ vàng nổ thành bụi sáng."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    if i == 0:
        rune(c, cx, cy, 40, 3, rot=0.4)
        c.glow(cx, cy, 90, CORE, 0.5)
        return c.result()
    al = fade(i, 6, 0.3)
    ring(c, cx, cy, 30 + 26 * i, max(1.5, 6 - i), glow_band(4), al)
    dust(c, cx, cy, i / 5, 22, 7, 130, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    if i <= 3:  # 3 cuốn sách mở cùng lúc: trang sáng
        for k, (x, y) in enumerate(BOOKS_SKILL):
            c.glow(x, y, 40 + 10 * i, MAIN, 0.2 + 0.1 * i)
            if i >= 2:
                page(c, x + 20, y - 30 - i * 6, 10, 0.4 * k, 0.8)
    if 4 <= i <= 6:  # bão trang giấy về phía quái
        rnd = random.Random(i)
        for k in range(14):
            x = rnd.uniform(200, 520) + (i - 4) * 50
            y = rnd.uniform(60, 400)
            page(c, x, y, rnd.uniform(9, 14), rnd.uniform(-0.6, 0.6) + i, 0.9, glow=k % 3 == 0)
    if i >= 7:
        for k, (x, y) in enumerate(BOOKS_SKILL):
            star(c, x, y - 20, 8, [(0, MAIN), (-0.6, CORE)], fade(i - 7, 3, 0.2), rot=k)
    return c.result()


def skill_hit(i):
    """Trang giấy vàng cắt qua quái (lên mọi quái)."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 8, 0.5)
    rnd = random.Random(11)
    for k in range(10):
        y = cy - 140 + k * 30 + rnd.uniform(-10, 10)
        x = -40 + ((rnd.uniform(0, 200) + i * 90) % 560)
        capsule(c, x - 80, y + 20, x, y - 5, 0.8, 3, glow_band(3), al * 0.8)  # vệt cắt
        page(c, x, y - 6, 11, -0.3, al, glow=False)
    if i <= 3:
        dust(c, cx, cy, i / 3, 10, 13, 90, 1 - i * 0.2)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    bx, by = 240, 70
    if i <= 9:  # sách khổng lồ mở trên đầu, chữ xoay quanh
        o = min(1.0, (i + 1) / 4)
        big_book(c, bx, by, 150, o, 1.0 if i < 9 else 0.7)
        for k in range(6):
            a = k * math.tau / 6 + i * 0.35
            rune(c, bx + math.cos(a) * 190, by + 50 + math.sin(a) * 50, 16, 20 + k, 0.9 * o, rot=a)
    if i >= 10:  # gập sách lớn
        big_book(c, bx, by, 150, 0.15, 0.8 - 0.3 * (i - 10))
    return c.result()


def ultimate_hit(i):
    """Cột chữ vàng giáng xuống; 3 tia chữ nhỏ ở khung 9, 10, 11 (khung hit 1, 2, 3)."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    feet = BATTLE_ANCHORS["feet"][1]
    al = fade(i, 8, 0.4)
    if i <= 2:
        w = [70, 54, 36][i]
        c.glow(cx, cy, 200, MAIN, 0.45 - 0.1 * i)
        capsule(c, cx, -20, cx, feet, w, w, [(0, DEEP)], 0.35)
        capsule(c, cx, -20, cx, feet, w * 0.7, w * 0.7, [(0, MAIN)], 0.5)
        capsule(c, cx, -20, cx, feet, w * 0.3, w * 0.3, [(0, CORE)], 0.8)
        for k in range(6):
            rune(c, cx + (k % 2 * 2 - 1) * 20, 40 + k * 65 + i * 20, 18, 30 + k, 0.9, rot=i)
    if 1 <= i <= 3:  # tia chữ ngẫu nhiên
        rnd = random.Random(40 + i)
        x0 = rnd.uniform(-40, 0)
        y1 = cy + rnd.uniform(-80, 80)
        capsule(c, x0, rnd.uniform(40, 120), cx - 10, y1, 3, 6, glow_band(6), 0.9)
        rune(c, cx - 10, y1, 22, 50 + i, 1.0, rot=i)
    if i >= 3:
        dust(c, cx, cy, (i - 3) / 4, 18, 60, 140, al)
    return c.result()


def ultimate_screen(i):
    """Thư viện vàng hiện mờ sau nền, chữ cổ trôi."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6) * min(1.0, (i + 1) / 3)
    c.tint(hexc("#1A1408"), 0.18 * al)
    for k in range(7):  # giá sách: cột + kệ
        x = 40 + k * 150
        polygon(c, [(x, 40), (x + 110, 40), (x + 110, 560), (x, 560)], [(3, DEEP), (0, hexc("#3A2E18"))], 0.1 * al)
        for j in range(5):
            y = 120 + j * 95
            capsule(c, x, y, x + 110, y, 3, 3, [(0, MAIN)], 0.12 * al)
            rnd = random.Random(k * 10 + j)
            xx = x + 6
            while xx < x + 100:
                w = rnd.uniform(8, 16)
                polygon(c, [(xx, y - rnd.uniform(45, 70)), (xx + w, y - 60), (xx + w, y - 3), (xx, y - 3)],
                        [(0, rnd.choice([NIGHT, LEATHER, DEEP]))], 0.1 * al)
                xx += w + 2
    rnd = random.Random(70)
    for k in range(16):
        x = (rnd.uniform(0, 1024) + i * 12) % 1024
        y = (rnd.uniform(0, 576) - i * 18) % 576
        rune(c, x, y, rnd.uniform(10, 18), 80 + k, al * 0.8, rot=i * 0.2 + k)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

PAGE_P = ["CCL", "LmL", "LLD"]
EYE_P = [".LLL.", "LCMCL", ".LLL."]


def opener_map(i):
    """3 trang giấy vàng bay quạt 90°, tầm 2,5 ô."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i <= 1:
        blit(px, ["L"] if i == 0 else [".L.", "LCL", ".L."], ox - i, oy + 6 - i)
    if i in (2, 3, 4):
        d = [10, 20, 28][i - 2]
        for a in (-40, 0, 40):
            r = math.radians(a)
            blit(px, PAGE_P if i < 4 else ["m"], ox + int(math.cos(r) * d), oy + 6 + int(math.sin(r) * d))
    return px


def technique_map(i):
    """Con mắt vàng nhỏ trên đầu; vòng sáng vàng lan trên mặt đất."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    cx, feet = MAP_ANCHORS["technique_feet"]
    if i >= 1:
        blit(px, EYE_P if i >= 2 else ["LCL"], cx - 2, feet - 44)
    if i >= 3:
        r = 8 + (i - 3) * 9
        for k in range(36):
            a = k * math.tau / 36
            x, y = cx + int(round(math.cos(a) * r)), feet - 2 + int(round(math.sin(a) * r * 0.3))
            if 0 <= x < 64 and 0 <= y < 64:
                blit(px, ["M" if k % 3 else "C"], x, y)
    return px


V.run({
    "id": "orrin", "element_color": "#F2D58A", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
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

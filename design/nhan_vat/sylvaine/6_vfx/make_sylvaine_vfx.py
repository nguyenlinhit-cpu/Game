"""Hiệu ứng skill của Sylvaine (Mộc #2E8B57, hoa – phấn hoa – Cây Sự Sống), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/sylvaine/6_vfx/make_sylvaine_vfx.py
    blender -b -P design/nhan_vat/sylvaine/6_vfx/make_sylvaine_vfx.py -- --only attack,opener

Ngoài các lớp chuẩn còn xuất 6_vfx/life_tree/<khung>.png (512, 8 khung mọc + lặp lá rung): sprite Cây Sự Sống đặt sau
đội hình đồng minh khi gieo cây.
Xuất vào design/nhan_vat/sylvaine/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

V.set_palette(main="#2E8B57", light="#B8E8A0", mid="#6CC36A", deep="#1E5E3A", core="#FBFFF2", dark="#123A24")
from vfx2d import *  # noqa: E402,F401,F403

PETAL, PETAL_EDGE, PETAL_CORE = hexc("#F5A89A"), hexc("#D9776A"), hexc("#FFE6DE")
POLLEN, POLLEN_EDGE = hexc("#F7D86A"), hexc("#C9A030")
BARK, BARK_DARK = hexc("#7A5A3A"), hexc("#4A3420")
LEAVES = [(0, DEEP), (-1.5, MAIN), (-4, MID)]

# Điểm neo trong khung trận 512 (Sylvaine quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
TOP = {"attack": [(344, 66), (292, 54), (239, 58), (423, 126), (449, 194), (421, 128), (367, 78), (344, 66)],
       "skill": [(344, 66), (342, 55), (340, 44), (350, 81), (350, 81), (350, 81), (350, 81), (347, 75), (344, 70),
                 (344, 66)],
       "ultimate": [(344, 66), (330, 61), (305, 53), (291, 50), (291, 48), (291, 47), (291, 47), (291, 47), (291, 47),
                    (345, 65), (394, 97), (394, 97)]}
STAFF_FOOT_SKILL = (216, 436)
BATTLE_ANCHORS = {"feet": (256, 430), "head": (246, 119), "eye": (270, 119), "chest": (258, 222),
                  "target_center": (256, 270), "staff_top_per_frame": TOP, "staff_foot_skill": STAFF_FOOT_SKILL,
                  "life_tree": "6_vfx/life_tree/, chân cây ở (256, 470) của khung 512, đặt sau đội hình đồng minh"}
MAP_ANCHORS = {"opener_origin": (28, 30), "opener_feet": (16, 52), "technique_feet": (24, 52), "technique_seed": (32, 52)}


def flower(c, x, y, s, rot=0.0, alpha=1.0, open_=1.0):
    """Hoa 5 cánh hồng đào, nhuỵ vàng; open_ 0→1 cánh nở dần."""
    for k in range(5):
        a = rot + k * math.tau / 5
        d = s * 0.55 * open_
        ellipse(c, x + math.cos(a) * d, y + math.sin(a) * d, s * 0.5 * (0.4 + 0.6 * open_), s * 0.38,
                [(1.2, PETAL_EDGE), (0, PETAL), (-s * 0.18, PETAL_CORE)], alpha)
    circle(c, x, y, s * 0.24, [(1, POLLEN_EDGE), (0, POLLEN)], alpha)


def petal(c, x, y, s, ang, alpha=1.0):
    dx, dy = math.cos(ang) * s, math.sin(ang) * s
    polyline(c, [(x - dx, y - dy), (x, y), (x + dx, y + dy)], [0.6, s * 0.5, 0.6], [(1.2, PETAL_EDGE), (0, PETAL)], alpha)


def pollen(c, x, y, r, alpha=1.0):
    c.glow(x, y, r * 3, POLLEN, 0.25 * alpha)
    circle(c, x, y, r, [(0, POLLEN_EDGE), (-r * 0.3, POLLEN), (-r * 0.65, CORE)], alpha)


def leaf_whirl(c, cx, cy, t, r, n, seed, alpha=1.0):
    rnd = random.Random(seed)
    for k in range(n):
        a = k * math.tau / n + t * 0.9
        d = r * (0.6 + 0.4 * rnd.random())
        x, y = cx + math.cos(a) * d, cy + math.sin(a) * d * 0.6
        if k % 3 == 0:
            petal(c, x, y, 9, a + 1.6, alpha)
        else:
            leaf(c, x, y, 11, a + 1.6, LEAVES, alpha)


def light_column(c, cx, feet, h, w, alpha=1.0):
    capsule(c, cx, feet, cx, feet - h, w, w * 0.8, [(0, MAIN)], alpha * 0.18)
    capsule(c, cx, feet, cx, feet - h, w * 0.6, w * 0.5, [(0, LIGHT)], alpha * 0.25)
    capsule(c, cx, feet, cx, feet - h, w * 0.25, w * 0.2, [(0, POLLEN)], alpha * 0.35)


# ---------------------------------------------------------------- Cây Sự Sống (sprite riêng)

def life_tree(i, c=None, ox=0, oy=0, scale=1.0):
    """Cây mọc lên trong 6 khung đầu, sau đó lá rung (lặp 2 khung)."""
    own = c is None
    if own:
        c = Canvas(512, 512)
    g = min(1.0, (i + 1) / 6)
    cx, base = 256 * scale + ox, 470 * scale + oy
    h = 330 * g * scale
    capsule(c, cx, base, cx + 6 * scale, base - h, 22 * scale * g + 4, 9 * scale * g + 2,
            [(2, BARK_DARK), (0, BARK)])
    for k, (a, L) in enumerate(((-2.4, 0.5), (-0.7, 0.55), (-1.9, 0.4), (-1.1, 0.42))):  # cành
        if g > 0.4:
            bx, by = cx + 4 * scale, base - h * (0.55 + 0.1 * k)
            capsule(c, bx, by, bx + math.cos(a) * L * h, by + math.sin(a) * L * h, 8 * scale * g, 3 * scale,
                    [(1.5, BARK_DARK), (0, BARK)])
    if g > 0.5:  # tán lá tròn nhiều cụm
        sway = 4 * math.sin(i * 1.7) * scale
        for k, (dx, dy, r) in enumerate(((0, -1.0, 0.42), (-0.4, -0.82, 0.32), (0.42, -0.84, 0.32), (-0.2, -1.2, 0.3),
                                         (0.25, -1.18, 0.3))):
            rr = r * h * min(1.0, (g - 0.5) * 2)
            circle(c, cx + dx * h + sway, base + dy * h, rr, [(2, DEEP), (0, MAIN), (-rr * 0.35, MID)])
        rnd = random.Random(5)
        for k in range(7):
            flower(c, cx + rnd.uniform(-0.45, 0.45) * h + sway, base - rnd.uniform(0.75, 1.3) * h,
                   9 * scale, rnd.uniform(0, 6), 1.0, min(1.0, (g - 0.5) * 2))
    if own:
        return c.result()


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    tx, ty = TOP["attack"][i]
    if i <= 2:  # xoay gậy ra sau: lá rơi từ ngọn
        for k in range(i + 1):
            leaf(c, tx - 20 + k * 14, ty + 30 + k * 10, 9, 0.6 + k, LEAVES, 0.9)
    if i in (3, 4):  # quất cành: vệt lá theo ngọn gậy
        a, b = TOP["attack"][i - 1], TOP["attack"][i]
        pts = [bezier(a, ((a[0] + b[0]) / 2 + 40, (a[1] + b[1]) / 2 - 30), b, u) for u in np.linspace(0, 1, 9)]
        polyline(c, pts, [2 + 8 * u for u in np.linspace(0, 1, 9)], [(0, DEEP), (-2, MAIN), (-5, LIGHT)], 0.85)
        for k, (x, y) in enumerate(pts[::2]):
            leaf(c, x, y + 8, 9, k, LEAVES, 0.9)
    if i >= 5:
        for k in range(3):
            petal(c, TOP["attack"][4][0] - 20 + k * 20, TOP["attack"][4][1] + (i - 4) * 20, 7, i + k, fade(i - 5, 3, 0.2))
    return c.result()


def attack_hit(i):
    """Lá xoáy và cánh hoa bung."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    if i == 0:
        c.glow(cx, cy, 80, LIGHT, 0.6)
        flower(c, cx, cy, 30, 0.2)
        return c.result()
    leaf_whirl(c, cx, cy, i, 50 + 25 * i, 12, 7, al)
    rnd = random.Random(9)
    for k in range(8):
        a = rnd.uniform(0, math.tau)
        d = 30 + 30 * i
        petal(c, cx + math.cos(a) * d, cy + math.sin(a) * d + 6 * i * i, 8, a + i, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    tx, ty = TOP["skill"][i]
    if i == 3:  # cắm gậy: vòng lá ở chân gậy
        fx, fy = STAFF_FOOT_SKILL
        ring(c, fx, fy - 4, 40, 6, LEAVES, 0.9, sy=0.3)
    if 4 <= i <= 7:  # hoa nở trên ngọn gậy, phấn hoa vàng bay lên
        o = min(1.0, (i - 3) / 2)
        for k, (dx, dy) in enumerate(((0, 0), (-26, 18), (24, 14), (-8, -24))):
            flower(c, tx + dx, ty + dy, 14, k, 1.0, o)
        rnd = random.Random(i)
        for k in range(8):
            pollen(c, tx + rnd.uniform(-60, 120), ty - rnd.uniform(0, 60) - (i - 4) * 10, rnd.uniform(3, 5), 0.9)
    if i >= 8:  # mỉm cười: cánh hoa rơi
        for k in range(3):
            petal(c, tx - 30 + k * 30, ty + 40 + (i - 8) * 20, 8, i + k, 0.8)
    return c.result()


def skill_hit(i):
    """Đồng minh: phấn hoa sáng rơi + dấu cộng xanh; Cây Sự Sống mọc phía sau (lần đầu)."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    life_tree(i, c, ox=-55, oy=165, scale=0.55)  # cây mọc sau lưng đồng minh (lệch trái, nhỏ hơn)
    rnd = random.Random(20)
    for k in range(18):
        x = cx + rnd.uniform(-140, 140)
        y = 60 + ((rnd.uniform(0, 340) + i * 40) % 360)
        pollen(c, x, y, rnd.uniform(3, 6), al)
    if i >= 1:
        for k, (dx, dy) in enumerate(((-60, -200), (50, -260), (10, -150))):
            plus(c, cx + dx, feet + dy - i * 8, 13 - k * 2, fade(i - 1, 7, 0.4))
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    if i <= 5:  # cầu nguyện: hoa và cánh hoa bay lên quanh người
        g = (i + 1) / 6
        c.glow(BATTLE_ANCHORS["chest"][0], BATTLE_ANCHORS["chest"][1], 120 + 60 * g, LIGHT, 0.2 + 0.2 * g)
        rnd = random.Random(30)
        for k in range(10):
            a = k * math.tau / 10 + i * 0.4
            r = 120 + 20 * math.sin(k)
            petal(c, cx + math.cos(a) * r, feet - 160 - i * 12 + math.sin(a) * r * 0.5, 9, a + i, 0.9)
    if 6 <= i <= 9:  # cả khu vườn nở bung quanh chân
        g = min(1.0, (i - 5) / 2)
        rnd = random.Random(40)
        for k in range(14):
            x = cx + rnd.uniform(-230, 230)
            y = feet + rnd.uniform(-10, 30)
            leaf(c, x - 8, y, 10 * g, -2.2, LEAVES)
            flower(c, x, y - 14 * g, 12 * g + 2, k, 1.0, g)
        light_column(c, cx, feet, 420 * g, 70, 1 - 0.3 * (i - 6))
    if i >= 10:
        for k in range(5):
            petal(c, 120 + k * 70, 120 + (i - 10) * 30 + k * 10, 8, k + i, 0.8)
    return c.result()


def ultimate_hit(i):
    """Đồng minh: cột sáng xanh-vàng + hoa nở dưới chân; cánh hoa xoáy nâng người (hồi sinh)."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    light_column(c, cx, feet, 440 * min(1.0, (i + 1) / 2), 90, al)
    for k in range(7):
        a = k * math.tau / 7
        flower(c, cx + math.cos(a) * 90, feet + math.sin(a) * 22, 14, a, al, min(1.0, (i + 1) / 3))
    for k in range(12):  # cánh hoa xoáy đi lên
        a = k * math.tau / 12 + i * 0.7
        h = (k * 30 + i * 35) % 360
        petal(c, cx + math.cos(a) * (110 - h * 0.15), feet - h, 9, a + 1.6, al)
    return c.result()


def ultimate_screen(i):
    """Hoa nở kín viền màn hình, ánh sáng xanh vàng."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6)
    g = min(1.0, (i + 1) / 4)
    c.tint(hexc("#F7FFE0"), 0.12 * g * al)
    rnd = random.Random(50)
    for k in range(30):  # dọc 4 viền
        side = k % 4
        t = rnd.uniform(0, 1)
        x, y = [(t * 1024, rnd.uniform(0, 40)), (t * 1024, 576 - rnd.uniform(0, 40)),
                (rnd.uniform(0, 50), t * 576), (1024 - rnd.uniform(0, 50), t * 576)][side]
        leaf(c, x + 10, y + 6, 14 * g, rnd.uniform(0, 6), LEAVES, al)
        flower(c, x, y, rnd.uniform(14, 22), rnd.uniform(0, 6), al, g)
    for k in range(10):
        pollen(c, rnd.uniform(80, 940), (rnd.uniform(80, 500) - i * 15) % 576, rnd.uniform(3, 6), al)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

V.PIXEL_PALETTE["O"] = PETAL  # pixel map: "O" = cánh hoa hồng đào (không dùng màu tối nhất)
THORN = ["MmLO"]
PETAL_P = ["O"]
SPROUT = [["...m...", "..mMm..", "...D..."],
          ["..mMm..", ".mMLMm.", "mM.D.Mm", "...D...", "...D..."],
          [".mMOMm.", "mMLDLMm", "mM.D.Mm", "..mDm..", "...D...", "...D..."]]
SEED_ICON = [".mm.", "mLLm", "mLLm", ".DD."]


def opener_map(i):
    """Gai hoa hồng-xanh quạt 100°, tầm 2 ô, cánh hoa rơi."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i <= 1:
        blit(px, ["L"] if i == 0 else [".L.", "LCL", ".L."], ox - i, oy - i)
    if i in (2, 3):
        d = 10 if i == 2 else 20
        for a in range(-50, 51, 20):
            r = math.radians(a + 15)
            x, y = ox + int(round(math.cos(r) * d)), oy + 6 + int(round(math.sin(r) * d))
            blit(px, THORN, x - 1, y)
    if i >= 3:
        rnd = random.Random(3)
        for k in range(6):
            blit(px, PETAL_P if k % 2 else ["L"], ox + rnd.randrange(8, 24), oy + rnd.randrange(0, 12) + (i - 3) * 3)
    return px


def technique_map(i):
    """Gieo hạt: mầm mọc lên rồi thu nhỏ thành biểu tượng hạt giống trên đầu."""
    px = np.zeros((64, 64, 4), dtype=np.float32)
    sx, sy = MAP_ANCHORS["technique_seed"]
    if i <= 2:
        blit(px, ["D"], sx, sy - 1 - i)
    if 3 <= i <= 4:
        pat = SPROUT[i - 2]
        blit(px, pat, sx - 3, sy - len(pat))
    if i == 5:
        blit(px, SPROUT[0], sx - 3, sy - 3)
        blit(px, SEED_ICON, MAP_ANCHORS["technique_feet"][0] - 2, sy - 40)
    return px


def export_life_tree():
    out = Path(V.DESIGN) / "nhan_vat" / "sylvaine" / "6_vfx" / "life_tree"
    frames = [life_tree(i) for i in range(8)]
    for i, f in enumerate(frames):
        V.save_png(out / f"{i:02d}.png", f)
    V.write_gif(out / "preview_life_tree.gif", [V.to_u8(V.resize(f, 256, 256)) for f in frames], V.FPS)
    print("[sylvaine vfx] life_tree: 8 khung")


V.run({
    "id": "sylvaine", "element_color": "#2E8B57", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
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
if "--only" not in sys.argv or "life_tree" in sys.argv[-1]:
    export_life_tree()

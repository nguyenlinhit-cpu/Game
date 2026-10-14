"""Hiệu ứng skill của Quill (Độc #9BC53D, ống tiêm – ống nghiệm – sương thuốc), vẽ 2D bằng code (lõi ở design/_tools/vfx2d.py).

Chạy từ gốc repo (sau khi đã có sprite ở 5_render/ để ảnh xem ghép đúng):
    blender -b -P design/nhan_vat/quill/6_vfx/make_quill_vfx.py
    blender -b -P design/nhan_vat/quill/6_vfx/make_quill_vfx.py -- --only attack,opener

Skill vừa hồi đồng minh vừa độc quái: lớp hit vẽ trên đồng minh (preview ghép đồng minh), phần độc trên quái để ở lớp
screen (toạ độ màn hình, phía quái bên phải).
Xuất vào design/nhan_vat/quill/6_vfx/ (xem vfx2d.py). Không chép gì vào assets/.
"""

import math
from pathlib import Path
import random
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
import vfx2d as V  # noqa: E402

# Cùng bảng màu Độc với Vesper
V.set_palette(main="#9BC53D", light="#D8F28A", mid="#B8DE5A", deep="#5E8A1E", core="#F6FFE0", dark="#2A3A10")
from vfx2d import *  # noqa: E402,F401,F403

MINT, MINT_EDGE = hexc("#CFEFD8"), hexc("#7FC8A0")
GLASS, BRASS, OUTLINE = hexc("#E8F8EE"), hexc("#C9A04A"), hexc("#141018")
SMOKE, SMOKE_EDGE = hexc("#6E8A4A"), hexc("#4A5E30")

# Điểm neo trong khung trận 512 (Quill quay phải, chân ở (256, 430)); tính bằng rig2d.locate từ rig_battle.py.
NEEDLE = {"attack": [(459, 221), (458, 193), (457, 243), (482, 285), (497, 305), (479, 241), (445, 179), (459, 221)],
          "ultimate": [(459, 221), (459, 219), (462, 231), (456, 210), (462, 231), (456, 210), (464, 239), (464, 241),
                       (465, 243), (465, 244), (456, 320), (456, 320)]}
HAND = {"skill": [(193, 217), (185, 214), (176, 212), (191, 214), (202, 219), (212, 225), (216, 227), (204, 215),
                  (189, 205), (190, 208)],
        "ultimate": [(183, 200), (183, 198), (192, 203), (173, 196), (192, 203), (173, 196), (203, 217), (203, 217),
                     (203, 218), (204, 219), (199, 264), (199, 264)]}
BATTLE_ANCHORS = {"feet": (256, 430), "head": (193, 154), "eye": (196, 175), "chest": (204, 252),
                  "target_center": (256, 270), "needle_tip_per_frame": NEEDLE, "free_hand_per_frame": HAND,
                  "poison_on_enemy_screen": (768, 300)}
MAP_ANCHORS = {"opener_origin": (24, 40), "opener_feet": (16, 52), "technique_feet": (32, 56)}


def tox(w):
    return [(0, DEEP), (-0.25 * w, MAIN), (-0.55 * w, LIGHT), (-0.8 * w, CORE)]


def mint(w):
    return [(0, MINT_EDGE), (-0.3 * w, MINT), (-0.65 * w, CORE)]


def vial(c, x, y, ang, s=1.0, liquid=None, alpha=1.0):
    """Ống nghiệm: thân thuỷ tinh, nước thuốc, nút đồng."""
    co, si = math.cos(ang), math.sin(ang)
    L = 26 * s
    capsule(c, x - co * L, y - si * L, x + co * L, y + si * L, 8 * s, 8 * s, [(1.5, OUTLINE), (0, GLASS)], alpha)
    capsule(c, x - co * L * 0.1, y - si * L * 0.1, x + co * L, y + si * L, 6 * s, 6 * s,
            liquid or tox(6 * s), alpha)
    capsule(c, x - co * L * 1.15, y - si * L * 1.15, x - co * L * 0.85, y - si * L * 0.85, 9 * s, 9 * s,
            [(1.2, OUTLINE), (0, BRASS)], alpha)


def bubble_p(c, x, y, r, cols=None, alpha=1.0):
    circle(c, x, y, r, [(0, (cols or (MAIN,))[0])], alpha * 0.3)
    ring(c, x, y, r, max(2.0, r * 0.22), [(0, DEEP if cols is None else MINT_EDGE), (-0.8, MAIN if cols is None else MINT)],
         alpha)
    circle(c, x - r * 0.35, y - r * 0.35, max(1.2, r * 0.22), [(0, CORE)], alpha)


def smoke(c, x, y, r, alpha):
    circle(c, x, y, r, [(0, SMOKE_EDGE), (-max(1.5, r * 0.25), SMOKE)], alpha * 0.75)


def poison_mark(c, x, y, s, alpha=1.0):
    """Dấu độc: giọt xanh có đầu lâu nhỏ."""
    drop(c, x, y + s * 0.3, s * 0.7, s * 1.3, -math.pi / 2, tox(s * 0.7), alpha)
    circle(c, x, y + s * 0.2, s * 0.32, [(0, CORE)], alpha)
    for dx in (-0.12, 0.12):
        circle(c, x + dx * s, y + s * 0.16, s * 0.08, [(0, DARK)], alpha)


def sparkle_mist(c, x0, x1, y0, y1, t, n, seed, alpha=1.0):
    rnd = random.Random(seed)
    for k in range(n):
        x = rnd.uniform(x0, x1) + t * rnd.uniform(-20, 20)
        y = rnd.uniform(y0, y1) - t * rnd.uniform(0, 20)
        circle(c, x, y, rnd.uniform(16, 30), [(0, MINT)], alpha * 0.1)
        if k % 3 == 0:
            star(c, x, y, rnd.uniform(4, 8), mint(2), alpha, rot=k)


# ---------------------------------------------------------------- skill trong trận

def attack_cast(i):
    c = Canvas(512, 512)
    nx, ny = NEEDLE["attack"][i]
    if i <= 2:  # lắc ống tiêm: bong bóng trong ống, giọt ở đầu kim
        drop(c, nx, ny + 10, 4, 10, math.pi / 2, tox(4), 0.9)
    if i in (3, 4):  # lao tới chích: vệt kim
        capsule(c, nx - 120, ny - 20, nx, ny, 1, 5, tox(5), 0.8)
        if i == 4:
            c.glow(nx, ny, 40, LIGHT, 0.5)
    if i >= 5:  # thổi đầu kim: khói xanh nhỏ
        t = i - 5
        for k in range(2):
            smoke(c, nx + 6 + t * 8, ny - 12 - t * 12 - k * 8, 5 + t * 2, fade(t, 3, 0.0))
    return c.result()


def attack_hit(i):
    """Giọt xanh bắn + dấu độc nhỏ."""
    c = Canvas(512, 512)
    cx, cy = BATTLE_ANCHORS["target_center"]
    al = fade(i, 6, 0.35)
    rnd = random.Random(3)
    for k in range(10):
        a = rnd.uniform(-math.pi * 0.95, -math.pi * 0.05)
        sp = rnd.uniform(30, 55)
        x = cx - 40 + math.cos(a) * sp * (i + 0.5)
        y = cy + math.sin(a) * sp * (i + 0.5) + 8 * i * i
        drop(c, x, y, rnd.uniform(4, 7), 14, a + 0.3 * i, tox(6), al)
    if i >= 1:
        poison_mark(c, cx + 40, cy - 150 - i * 4, 22, al)
    return c.result()


def skill_cast(i):
    c = Canvas(512, 512)
    hx, hy = HAND["skill"][i]
    if i <= 4:  # cầm 2 ống nghiệm: xanh nhạt và xanh độc
        vial(c, hx + 6, hy + 60, -1.2, 0.9, mint(5.4))  # cầm thấp trước ngực, không che mặt
        vial(c, hx + 34, hy + 60, -1.9, 0.9)
    if i in (5, 6):  # ném: ống xanh nhạt bay ra sau (đồng minh), ống độc bay về quái
        u = 0.35 if i == 5 else 0.85
        x, y = bezier((hx, hy - 30), (hx + 160, hy - 200), (520, 220), u)
        vial(c, x, y, i * 1.4, 0.9, mint(5.4))
        x2, y2 = bezier((hx, hy - 30), (hx + 200, hy - 160), (540, 260), u)
        vial(c, x2, y2, -i * 1.3, 0.9)
    if i >= 7:  # lau mồ hôi: giọt mồ hôi
        ex, ey = BATTLE_ANCHORS["eye"]
        drop(c, ex + 30, ey - 30 + (i - 7) * 8, 6, 10, math.pi / 2, mint(6), fade(i - 7, 3, 0.2))
    return c.result()


def skill_hit(i):
    """Đồng minh: bong bóng xanh nhạt + dấu cộng."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    if i == 0:
        vial(c, cx, feet - 260, 0.8, 1.0, mint(6))
        return c.result()
    rnd = random.Random(10)
    for k in range(10):
        x = cx + rnd.uniform(-130, 130)
        y = feet - 30 - ((rnd.uniform(0, 320) + i * 30) % 340)
        bubble_p(c, x, y, rnd.uniform(8, 16), (MINT,), al)
    for k, (dx, dy) in enumerate(((-60, -200), (50, -260), (10, -150))):
        plus(c, cx + dx, feet + dy - i * 8, 13 - k * 2, fade(i - 1, 7, 0.4))
    return c.result()


def skill_screen(i):
    """Quái ngẫu nhiên: ống độc vỡ, khói độc (toạ độ màn hình, phía quái)."""
    c = Canvas(1024, 576, ss=1)
    x, y = BATTLE_ANCHORS["poison_on_enemy_screen"]
    al = fade(i, 8, 0.5)
    if i == 0:
        circle(c, x, y, 26, tox(26))
        return c.result()
    for k in range(6):
        a = k * math.tau / 6 + i * 0.3
        smoke(c, x + math.cos(a) * (20 + 14 * i), y + math.sin(a) * (10 + 6 * i) - i * 6, 18 + 3 * i, al)
    poison_mark(c, x + 30, y - 140, 22, al)
    return c.result()


def ultimate_cast(i):
    c = Canvas(512, 512)
    hx, hy = HAND["ultimate"][i]
    hx, hy = hx + 30, hy + 120  # bình ôm trước bụng, không che mặt
    if i <= 5:  # bình thuốc lớn, lắc mạnh: bong bóng sủi
        polygon(c, [(hx - 22, hy - 80), (hx + 22, hy - 80), (hx + 34, hy - 10), (hx - 34, hy - 10)],
                [(2, OUTLINE), (0, GLASS)])
        polygon(c, [(hx - 20, hy - 60), (hx + 20, hy - 60), (hx + 31, hy - 13), (hx - 31, hy - 13)], mint(10))
        capsule(c, hx - 14, hy - 86, hx + 14, hy - 86, 7, 7, [(1.5, OUTLINE), (0, BRASS)])
        for k in range(2 + i):
            bubble_p(c, hx - 20 + k * 9, hy - 40 - (k * 13 + i * 9) % 40, 4, (MINT,), 0.9)
    if 6 <= i <= 9:  # bật nắp, phun sương thuốc về đội (sau lưng, bên trái)
        t = (i - 5) / 4
        c.glow(hx, hy - 90, 60, MINT, 0.5)
        sparkle_mist(c, hx - 260 * t, hx + 40, hy - 220, hy - 40, t, 16, 30 + i, 1.0)
    if i >= 10:  # ngồi thở: giọt mồ hôi
        ex, ey = BATTLE_ANCHORS["eye"]
        drop(c, ex + 30, ey + 40, 6, 10, math.pi / 2, mint(6), 0.8)
    return c.result()


def ultimate_hit(i):
    """Đồng minh: sương bạc hà lấp lánh + dấu cộng; mảnh hiệu ứng xấu vỡ."""
    c = Canvas(512, 512)
    cx, feet = BATTLE_ANCHORS["feet"]
    al = fade(i, 8, 0.55)
    sparkle_mist(c, cx - 150, cx + 150, feet - 330, feet - 20, i / 7, 22, 40, al)
    for k, (dx, dy) in enumerate(((-60, -210), (55, -270), (5, -150))):
        plus(c, cx + dx, feet + dy - i * 8, 14 - k * 2, al)
    if 1 <= i <= 5:
        rnd = random.Random(70)
        for k in range(4):
            a = -math.pi / 2 + rnd.uniform(-1.0, 1.0)
            shard(c, cx + math.cos(a) * (60 + 28 * i), feet - 200 + math.sin(a) * (60 + 28 * i), 12, k + i * 0.3,
                  fade(i - 1, 5, 0.3))
    return c.result()


def ultimate_screen(i):
    """Sương xanh bạc hà lấp lánh trôi ngang màn hình."""
    c = Canvas(1024, 576, ss=1)
    al = fade(i, 12, 0.6) * min(1.0, (i + 1) / 3)
    rnd = random.Random(80)
    for k in range(26):
        x = (rnd.uniform(0, 1100) - i * 40) % 1100 - 40
        y = rnd.uniform(60, 540)
        circle(c, x, y, rnd.uniform(30, 60), [(0, MINT)], al * 0.06)
        if k % 2 == 0:
            star(c, x, y, rnd.uniform(5, 9), mint(2), al, rot=k)
    return c.result()


# ---------------------------------------------------------------- pixel ngoài map

VIAL_P = [".G.", "TTT", "TPT", "TPT", ".T."]
GLASS_P = ["T.T", ".T."]
POTION_P = [".G.", "LmL", "LmL"]
PLUS_P = [".M.", "MLM", ".M."]


def opener_map(i):
    """Ống nghiệm ném, vỡ: khói xanh quạt 90°, tầm 2,5 ô."""
    V.PIXEL_PALETTE["T"] = MINT
    V.PIXEL_PALETTE["G"] = BRASS
    V.PIXEL_PALETTE["P"] = MAIN
    px = np.zeros((64, 64, 4), dtype=np.float32)
    ox, oy = MAP_ANCHORS["opener_origin"]
    if i <= 1:
        blit(px, VIAL_P, ox - 1 - (1 - i) * 3, oy - 6 - i * 4)
    if i == 2:
        blit(px, VIAL_P, ox + 10, oy - 6)
    if i >= 2:
        r = [0, 0, 8, 16, 22][i]
        rnd = random.Random(i)
        for k in range(18 + 8 * (i - 2)):  # khói xanh lấp đầy quạt 90°
            ra = math.radians(rnd.uniform(-45, 45))
            d = rnd.uniform(r * 0.35, r)
            x, y = ox + 14 + int(round(math.cos(ra) * d)), oy + int(round(math.sin(ra) * d))
            blit(px, [["M", "m"], ["L"], ["m"]][k % 3], x, y)
        if i >= 3:
            blit(px, GLASS_P, ox + 14, oy + 3)
    return px


def technique_map(i):
    """Lọ thuốc nhỏ bay vòng, dấu cộng xanh bay lên quanh nhân vật."""
    V.PIXEL_PALETTE["G"] = BRASS
    px = np.zeros((64, 64, 4), dtype=np.float32)
    cx, feet = MAP_ANCHORS["technique_feet"]
    if i <= 2:
        blit(px, ["L"] if i < 2 else POTION_P, cx - 8 + i * 2, feet - 22 + i)
    if i >= 3:
        for k in range(3):
            a = (i - 3) * 1.2 + k * math.tau / 3
            blit(px, POTION_P, cx + int(math.cos(a) * 14) - 1, feet - 18 + int(math.sin(a) * 5))
        for k, (dx, h) in enumerate(((-12, 0), (10, 4), (-2, 8))):
            blit(px, PLUS_P, cx + dx, feet - 30 - (i - 3) * 4 - h)
    return px


V.run({
    "id": "quill", "element_color": "#9BC53D", "battle_anchors": BATTLE_ANCHORS, "map_anchors": MAP_ANCHORS,
    "battle": {
        "attack": {"frames": 8, "hit_frame": 4, "target": "enemy",
                   "layers": {"cast": (0, 8, attack_cast), "hit": (4, 6, attack_hit)}},
        "skill": {"frames": 10, "hit_frame": 6, "target": "ally",
                  "layers": {"cast": (0, 10, skill_cast), "hit": (6, 8, skill_hit), "screen": (6, 8, skill_screen)}},
        "ultimate": {"frames": 12, "hit_frame": 8, "target": "ally", "cutin": True,
                     "layers": {"cast": (0, 12, ultimate_cast), "hit": (8, 8, ultimate_hit),
                                "screen": (6, 12, ultimate_screen)}},
    },
    "map": {
        "opener": {"frames": 5, "hit_frame": 2, "fn": opener_map, "char": MAP_ANCHORS["opener_feet"]},
        "technique": {"frames": 6, "hit_frame": None, "fn": technique_map, "char": MAP_ANCHORS["technique_feet"]},
    },
})

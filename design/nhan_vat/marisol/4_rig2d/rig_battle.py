"""Sprite trận của Marisol bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/marisol/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/marisol/4_rig2d/rig_battle.py -- --only idle,attack

Bước làm sạch: trắng tinh trên vỏ ốc, mũ, áo hạ xuống 0.95 (ghi ra 4_rig2d/1a_clean.png) để white_holes chỉ khoét
nền trắng lọt (giữa các lọn tóc, giữa hai chân).

Xuất 5_render/battle_marisol.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, load_rgba, run, save_png, zone_mask  # noqa: E402

HERE = Path(__file__).resolve().parent

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn rộng, khiên vỏ ốc khổng lồ che bên trái (tay phải cầm sau khiên), tay trái chạm vành mũ
# thuyền trưởng, tóc dài bay sang phải, hai vạt áo khoác dài.
BONES = {
    "root":     {"parent": None,     "pivot": (760, 950), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":    {"parent": "root",   "pivot": (720, 700),
                 "zone": [(690, 760, 580, 880, 58), (520, 925, 570, 930, 55)], "prio": 1, "depth": 1},
    "leg_r":    {"parent": "root",   "pivot": (890, 700),
                 "zone": [(915, 760, 945, 880, 58), (990, 925, 1030, 930, 55)], "prio": 1, "depth": 1},
    "hips":     {"parent": "root",   "pivot": (790, 650), "zone": [(720, 640, 880, 660, 70)], "prio": 1, "depth": 1.2},
    "coat_l":   {"parent": "hips",   "pivot": (640, 700),
                 "zone": [(560, 780, 430, 850, 55), (660, 800, 690, 880, 40)], "prio": 2, "depth": 0.9},
    "coat_r":   {"parent": "hips",   "pivot": (900, 690),
                 "zone": [(990, 780, 1050, 850, 55), (1130, 740, 1135, 750, 42)], "prio": 2, "depth": 0.9},
    "chest":    {"parent": "hips",   "pivot": (790, 640), "zone": [(790, 420, 800, 560, 110)], "prio": 1.2, "depth": 2},
    "arm_hat":  {"parent": "chest",  "pivot": (880, 400),
                 "zone": [(920, 370, 1040, 320, 52), (1020, 255, 1025, 265, 45)], "prio": 2.2, "depth": 3.2},
    "head":     {"parent": "chest",  "pivot": (790, 390),
                 "zone": [(740, 230, 820, 260, 150), (620, 110, 940, 80, 100), (530, 90, 540, 100, 70)],
                 "prio": 1.4, "depth": 3},
    "hair1":    {"parent": "head",   "pivot": (885, 420), "zone": [(940, 455, 1030, 480, 62)], "prio": 2.5, "depth": 2.8},
    "hair2":    {"parent": "hair1",  "pivot": (1040, 485), "zone": [(1075, 510, 1130, 545, 62)], "prio": 3,
                 "depth": 2.8},
    "hair3":    {"parent": "hair2",  "pivot": (1140, 550), "zone": [(1165, 580, 1195, 645, 50)], "prio": 3.2,
                 "depth": 2.8},
    # Lớp trên trọng số cứng: khiên vỏ ốc (tay phải cầm phía sau khiên, không thấy).
    "arm_sh":   {"parent": "chest",  "pivot": (720, 420), "zone": [], "prio": 0, "depth": 2.5},
    "shield":   {"parent": "arm_sh", "pivot": (630, 470), "zone": [], "prio": 0, "depth": 10},
}


def poly_zone(pts, step=14, pad=-6):
    """Đa giác lồi → các dải ngang (zone) để làm vùng lớp trên; pad âm nới rộng sang hai bên."""
    ys = [p[1] for p in pts]
    out = []
    for y in range(int(min(ys)), int(max(ys)) + 1, step):
        xs = []
        for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]):
            if ((ay <= y <= by) or (by <= y <= ay)) and ay != by:
                xs.append(ax + (bx - ax) * (y - ay) / (by - ay))
        if len(xs) >= 2:
            out.append((min(xs) + pad, y, max(xs) - pad, y, step // 2 + 4))
    return out


SHIELD_ZONE = poly_zone([(318, 470), (365, 300), (430, 170), (560, 225), (660, 300), (695, 420), (690, 620),
                         (600, 740), (520, 770), (420, 720), (345, 620)])


CLEAN = "1a_clean.png"


def clean_concept():
    """Trắng tinh trên vỏ ốc, mũ + lông vũ, thân áo hạ xuống 0.95 (nhìn không khác) để white_holes không khoét."""
    a = load_rgba(HERE.parent / "1_concept" / "1a_battle.png")
    glare = zone_mask(a.shape[:2], PROTECT) & (a[..., :3].min(axis=2) > 0.96)
    a[glare, :3] = 0.95
    a[..., 3] = 1.0
    save_png(HERE / CLEAN, a)

PROTECT = SHIELD_ZONE + [(500, 90, 960, 110, 125), (790, 420, 800, 600, 115)]


def sway(i, n, amp=1.0, speed=1.0):
    """Tóc dài và hai vạt áo bay như gió biển (trễ dần về đuôi tóc)."""
    p = math.tau * i / n * speed
    out = {"coat_l": {"rot": -2.5 * amp * math.sin(p + 0.6)}, "coat_r": {"rot": 3 * amp * math.sin(p + 1.0)}}
    for j, name in enumerate(("hair1", "hair2", "hair3")):
        out[name] = {"rot": (3 + 2 * j) * amp * math.sin(p + 0.5 + 0.8 * j)}
    return out


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.012 * math.sin(p)}, "head": {"rot": 1.2 * math.sin(p + 0.4)},
            "shield": {"dy": -5 * math.sin(p), "rot": 1 * math.sin(p)}, "arm_hat": {"rot": 1.5 * math.sin(p + 1)}}
    return add(base, sway(i, n, 1.2))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"shield": {"rot": -14, "dx": -40, "dy": 10}, "chest": {"rot": -4}, "hips": {"dx": -14},  # nghiêng khiên ra sau
             "head": {"rot": -3}}),
        (3, {"shield": {"rot": 10, "dx": 90, "dy": -10}, "chest": {"rot": 4}, "hips": {"dx": 16}}),
        (4, {"shield": {"rot": 18, "dx": 160, "dy": -16}, "chest": {"rot": 6}, "hips": {"dx": 26},  # đập mép khiên (trúng)
             "head": {"rot": 2}, "arm_hat": {"rot": -8}}),
        (5, {"shield": {"rot": 12, "dx": 120, "dy": -8}, "chest": {"rot": 4}, "hips": {"dx": 18}}),
        (6, {"shield": {"rot": 2, "dx": 30}, "chest": {"rot": 1}, "hips": {"dx": 4}}),               # kéo khiên về ngực
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_skill(i, n):
    horn = {"shield": {"rot": -55, "dx": 50, "dy": -60}, "head": {"rot": -6}, "chest": {"rot": -3}}  # vỏ ốc lên miệng
    keys = [
        (0, {}),
        (3, horn),
        (4, {**horn, "chest": {"rot": -4, "sy": 1.03}}),
        (5, {**horn, "chest": {"rot": -5, "sy": 1.05}, "head": {"rot": -8}}),                    # thổi tù và
        (6, {**horn, "chest": {"rot": -5, "sy": 1.05}, "head": {"rot": -8}}),
        (8, {"shield": {"rot": 4, "dx": 20}, "head": {"rot": 4}, "chest": {"rot": 2}, "hips": {"dx": 8}}),  # nhìn quái
        (9, {"head": {"rot": 3}, "hips": {"dx": 4}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.9))


def pose_ultimate(i, n):
    up = {"shield": {"rot": 8, "dx": 170, "dy": -420}, "arm_hat": {"rot": -20}, "head": {"rot": -7}, "chest": {"rot": -5},
          "root": {"sy": 1.03}}
    keys = [
        (0, {}),
        (3, {**up, "shield": {"rot": 6, "dx": 140, "dy": -300}}),
        (5, up),                                                                                 # giơ khiên cao
        (9, {**up, "head": {"rot": -8}}),                                                         # sóng ôm cả đội
        (10, {"shield": {"rot": 2, "dx": 20}, "head": {"rot": 3}}),                                # hạ khiên, mỉm cười
        (11, {"shield": {"rot": 2, "dx": 20}, "head": {"rot": 3}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.6, 2))


def pose_hit(i, n):
    fly = {"hair1": {"rot": -10}, "hair2": {"rot": -12}, "hair3": {"rot": -14}, "coat_l": {"rot": -8},
           "coat_r": {"rot": -10}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "shield": {"dx": -20, "rot": -6},
             "arm_hat": {"rot": 10}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "shield": {"dx": -24, "rot": -7},
             "arm_hat": {"rot": 12}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "shield": {"dy": 30}}),
        (2, {"root": {"sy": 0.86, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10},
             "shield": {"dy": 50, "rot": -10}, "arm_hat": {"rot": 30}}),
        (4, {"root": {"sy": 0.86, "rot": -72, "dx": 440, "dy": -230}, "chest": {"rot": 6}, "head": {"rot": 12},
             "shield": {"dy": 40, "rot": -20}, "arm_hat": {"rot": 50}, "hair1": {"rot": 15}}),
        (5, {"root": {"sy": 0.86, "rot": -84, "dx": 490, "dy": -290}, "chest": {"rot": 4}, "head": {"rot": 10},
             "shield": {"dy": 40, "rot": -24}, "arm_hat": {"rot": 56}, "hair1": {"rot": 20}, "hair2": {"rot": 10}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    keys = [
        (0, {}),
        (2, {"arm_hat": {"rot": 8, "dy": 6}, "head": {"rot": 3}}),            # chỉnh vành mũ
        (3, {"arm_hat": {"rot": -4, "dy": -4}, "head": {"rot": 1}}),
        (5, {"arm_hat": {"rot": -14, "dy": -10}, "head": {"rot": -3}, "chest": {"sy": 1.02},  # chào kiểu thuyền trưởng
             "shield": {"dy": -6}}),
        (6, {"arm_hat": {"rot": -14, "dy": -10}, "head": {"rot": 4}, "chest": {"sy": 1.02}}),  # gật đầu
        (7, {"arm_hat": {"rot": -6}, "head": {"rot": 1}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "marisol", "concept": f"../4_rig2d/{CLEAN}", "bones": BONES, "top": [("shield", SHIELD_ZONE)], "poses": POSES,
          "shadow_below": 925, "white_holes": 30,  # bóng đổ xám dưới chân; nền trắng lọt giữa các lọn tóc
          # bóng đổ ngả xanh dưới chân (shadow_below không bắt được vì có màu): xoá dải dưới đất, giữ ủng
          "erase": [(350, 948, 1160, 948, 36)], "keep": [(520, 925, 570, 945, 62), (995, 925, 1035, 945, 52)],
          "char_h": 330}  # ảnh rất ngang (khiên lớn): thu nhỏ để giơ khiên lên cao không ra khung

if __name__ == "__main__":
    clean_concept()
    run(CONFIG)

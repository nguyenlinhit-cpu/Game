"""Sprite trận của Ignar bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/ignar/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/ignar/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_ignar.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1215×1295), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn, tay phải (bên phải ảnh) vác búa rèn cán dài qua sau cổ, đầu búa nung đỏ ở sau lưng
# (bên trái ảnh); tay trái bọc giáp, vai quấn xích, buông thõng; tạp dề da và vạt áo đỏ rách.
BONES = {
    "root":    {"parent": None,     "pivot": (640, 1240), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":   {"parent": "root",   "pivot": (500, 1000),
                "zone": [(490, 1030, 450, 1170, 70), (400, 1210, 480, 1215, 60)], "prio": 1, "depth": 1},
    "leg_r":   {"parent": "root",   "pivot": (760, 1000),
                "zone": [(760, 1030, 790, 1170, 65), (830, 1205, 920, 1205, 60)], "prio": 1, "depth": 1},
    "hips":    {"parent": "root",   "pivot": (640, 820), "zone": [(560, 800, 760, 860, 90)], "prio": 1, "depth": 1.2},
    "apron":   {"parent": "hips",   "pivot": (720, 870),
                "zone": [(720, 900, 740, 980, 70), (420, 960, 380, 1000, 40), (930, 960, 960, 1000, 40)],
                "prio": 2, "depth": 1.4},
    "chest":   {"parent": "hips",   "pivot": (650, 800), "zone": [(650, 560, 660, 700, 130)], "prio": 1.2, "depth": 2},
    "arm_l":   {"parent": "chest",  "pivot": (500, 500), "zone": [(430, 600, 400, 870, 92)], "prio": 2, "depth": 2.6},
    "chain1":  {"parent": "arm_l",  "pivot": (470, 560), "zone": [(360, 600, 315, 640, 34)], "prio": 3, "depth": 2.7},
    "chain2":  {"parent": "chain1", "pivot": (315, 645), "zone": [(300, 670, 310, 720, 30)], "prio": 3.2,
                "depth": 2.7},
    "arm_r":   {"parent": "chest",  "pivot": (800, 520), "zone": [(840, 570, 910, 680, 72)], "prio": 2, "depth": 2.4},
    "head":    {"parent": "chest",  "pivot": (650, 470), "zone": [(600, 230, 700, 260, 220)], "prio": 1.4, "depth": 3},
    # Lớp trên trọng số cứng: búa rèn (đầu búa, cán, chuôi xích) kèm bàn tay phải đang cầm, xoay quanh nắm tay.
    "hammer":  {"parent": "arm_r",  "pivot": (900, 490), "zone": [], "prio": 0, "depth": 10},
}


def poly_zone(pts, step=14, pad=6):
    """Đa giác lồi → các dải ngang (zone) để làm vùng lớp trên; pad âm nới rộng sang hai bên."""
    ys = [p[1] for p in pts]
    out = []
    for y in range(int(min(ys)), int(max(ys)) + 1, step):
        xs = []
        for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]):
            if (ay <= y <= by) or (by <= y <= ay):
                if ay != by:
                    xs.append(ax + (bx - ax) * (y - ay) / (by - ay))
        if len(xs) >= 2:
            out.append((min(xs) + pad, y, max(xs) - pad, y, step // 2 + 4))
    return out


HAMMER_ZONE = (poly_zone([(8, 450), (195, 106), (414, 170), (414, 492), (255, 630)], pad=-8)  # đầu búa + đai
               + [(395, 378, 845, 470, 24), (845, 470, 975, 510, 56),                  # cán + nắm tay
                  (970, 515, 1150, 575, 38), (1140, 560, 1195, 590, 48), (1120, 610, 1125, 705, 40)])  # chuôi + vòng


def sway(i, n, amp=1.0, speed=1.0):
    """Xích ở vai đung đưa (trễ dần), vạt tạp dề lắc."""
    p = math.tau * i / n * speed
    return {"chain1": {"rot": 3 * amp * math.sin(p + 0.4)}, "chain2": {"rot": 5 * amp * math.sin(p + 1.2)},
            "apron": {"rot": 2 * amp * math.sin(p + 0.8)}}


def pose_idle(i, n):
    p = math.tau * i / n
    up = max(0.0, math.sin(p))  # nhún vai vác búa
    base = {"chest": {"sy": 1 + 0.014 * math.sin(p)}, "hips": {"sy": 1 - 0.005 * math.sin(p)},
            "arm_r": {"dy": -10 * up}, "hammer": {"rot": -2.5 * up}, "arm_l": {"dy": -6 * up, "rot": 1.5 * math.sin(p)},
            "head": {"rot": 1.2 * math.sin(p + 0.5), "dy": -3 * up}}
    return add(base, sway(i, n))


SLAM = {"hammer": {"rot": 223, "dx": 20, "dy": 90}, "arm_r": {"rot": 30}, "chest": {"rot": 9}, "head": {"rot": 6},
        "hips": {"dx": 26}, "root": {"sy": 0.95}, "arm_l": {"rot": -10}}


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"hammer": {"rot": -28, "dy": 20}, "arm_r": {"rot": -12}, "chest": {"rot": -5}, "head": {"rot": -4},  # ra sau lưng
             "hips": {"dx": -12}}),
        (3, {"hammer": {"rot": 92, "dy": 60}, "arm_r": {"rot": -24}, "chest": {"rot": -2}, "hips": {"dx": 6},  # vung qua đầu
             "root": {"sy": 1.02}}),
        (4, SLAM),                                                                                   # nện xuống (trúng)
        (5, {**SLAM, "hammer": {"rot": 218, "dx": 20, "dy": 85}}),
        (6, {"hammer": {"rot": 110, "dy": -30}, "arm_r": {"rot": -10}, "chest": {"rot": 2}}),          # kéo về vai
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_skill(i, n):
    beat = {"hammer": {"rot": -16, "dx": -150, "dy": 30}, "arm_r": {"rot": -30}, "chest": {"rot": -4, "sy": 1.02},
            "head": {"rot": -6}}
    keys = [
        (0, {}),
        (2, beat),                                                                                   # đấm búa vào ngực
        (3, {**beat, "chest": {"rot": -6, "sy": 1.04}, "head": {"rot": -9}, "root": {"sy": 1.02}}),  # lửa bùng khắp thân
        (4, {"hammer": {"rot": 70, "dy": -40}, "arm_r": {"rot": -20}, "chest": {"rot": -6}, "hips": {"dx": -10}}),
        (5, {"hammer": {"rot": 100, "dx": -40, "dy": -20}, "arm_r": {"rot": 10}, "chest": {"rot": 4},  # quét ngang
             "hips": {"dx": 14}}),
        (6, {"hammer": {"rot": 212, "dx": 20, "dy": 90}, "arm_r": {"rot": 28}, "chest": {"rot": 8},  # quét qua 3 quái
             "hips": {"dx": 24}, "head": {"rot": 4}}),
        (7, {"hammer": {"rot": 200, "dx": -20, "dy": 80}, "arm_r": {"rot": 18}, "chest": {"rot": 4}, "hips": {"dx": 14},
             "head": {"rot": -5}}),                                                                  # thở ra khói
        (8, {"hammer": {"rot": 70, "dy": -20}, "arm_r": {"rot": -6}, "head": {"rot": -4}}),           # xoay búa về vai
        (9, {"head": {"rot": -2}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_ultimate(i, n):
    lift = {"hammer": {"rot": 45, "dx": -150, "dy": -20}, "arm_r": {"rot": -40}, "arm_l": {"rot": 32},
            "chest": {"rot": -6}, "head": {"rot": -8}}
    keys = [
        (0, {}),
        (1, {"root": {"sy": 0.9}, "hips": {"dy": 30}, "chest": {"rot": 6}, "hammer": {"rot": 20}}),   # nhún lấy đà
        (3, {**lift, "root": {"dy": -260, "sy": 1.04}, "leg_l": {"rot": 16}, "leg_r": {"rot": -14}}),  # nhảy cao, giơ búa
        (5, {**lift, "root": {"dy": -280, "sy": 1.04}, "leg_l": {"rot": 20}, "leg_r": {"rot": -18},
             "hammer": {"rot": 52, "dx": -150, "dy": -30}}),
        (6, {"hammer": {"rot": 100, "dx": -60}, "root": {"dy": -60}, "chest": {"rot": 6}, "arm_r": {"rot": 10}}),  # bổ xuống
        (7, {**SLAM, "root": {"sy": 0.88}, "hips": {"dx": 26, "dy": 40}, "chest": {"rot": 14}}),          # nện xuống đất
        (8, {**SLAM, "root": {"sy": 0.86}, "hips": {"dx": 26, "dy": 48}, "chest": {"rot": 15}}),
        (9, {**SLAM, "root": {"sy": 0.87}, "hips": {"dx": 24, "dy": 44}, "chest": {"rot": 13}}),
        (10, {"hammer": {"rot": -4}, "chest": {"rot": -3}, "head": {"rot": -4}}),                       # đứng dậy
        (11, {"hammer": {"rot": -4}, "chest": {"rot": -3}, "head": {"rot": -4}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8, 2))


def pose_hit(i, n):
    fly = {"chain1": {"rot": -10}, "chain2": {"rot": -14}, "apron": {"rot": -8}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "hammer": {"rot": -7},
             "arm_l": {"rot": 8}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "hammer": {"rot": -8},
             "arm_l": {"rot": 10}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8},
             "hammer": {"rot": -20, "dy": 20}}),
        (2, {"root": {"sy": 0.86, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10},
             "hammer": {"rot": -40, "dy": 40}, "leg_l": {"rot": 14}}),
        (4, {"root": {"sy": 0.86, "rot": -72, "dx": 460, "dy": -230}, "chest": {"rot": 6}, "head": {"rot": 12},
             "hammer": {"rot": -60, "dy": 30}, "arm_l": {"rot": 20}, "chain2": {"rot": 20}}),
        (5, {"root": {"sy": 0.86, "rot": -84, "dx": 510, "dy": -290}, "chest": {"rot": 4}, "head": {"rot": 10},
             "hammer": {"rot": -66, "dy": 30}, "arm_l": {"rot": 24}, "chain2": {"rot": 26}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    plant = {"hammer": {"rot": -100, "dx": -40, "dy": -20}, "arm_r": {"rot": 6}}  # cán dựng, đầu búa nện xuống đất
    punch = {"arm_l": {"rot": -46}, "chest": {"sy": 1.03}, "head": {"rot": -7}}  # đấm ngực, ngửa cổ cười
    keys = [
        (0, {}),
        (2, {**plant, "root": {"sy": 0.97}, "chest": {"rot": 4}}),
        (3, {**plant}),
        (4, {**plant, **punch}),
        (5, {**plant, **punch, "head": {"rot": -9}, "chest": {"sy": 1.035, "rot": -2}}),
        (6, {**plant, "arm_l": {"rot": -30}, "head": {"rot": -8}}),
        (7, {**plant, "head": {"rot": -4}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "ignar", "bones": BONES, "top": [("hammer", HAMMER_ZONE)], "poses": POSES,
          "white_holes": 30,  # nền trắng lọt giữa cán búa, tóc và giáp vai
          "char_h": 330}  # búa rất dài: thu nhỏ để vung qua đầu và nện xuống không ra ngoài khung

if __name__ == "__main__":
    run(CONFIG)

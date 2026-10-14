"""Sprite trận của Hồn Ảnh Lang Thang (wandering_shade) bằng xương 2D (lõi ở design/_tools/rig2d.py).

Chạy từ gốc repo:
    blender -b -P design/quai/wandering_shade/4_rig2d/rig_battle.py
    blender -b -P design/quai/wandering_shade/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_wandering_shade.png + .json (khung 256, quay trái như concept) và ảnh xem trong
5_render/preview/. Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1254×1254), xem 4_rig2d/grid.png.
# Bay lơ lửng: mũ trùm có mắt lửa, áo choàng rách, thân hồn trong suốt thành đuôi xoắn, 2 bàn tay phát sáng.
BONES = {
    "root":    {"parent": None,     "pivot": (640, 1220), "zone": [], "prio": 0.03, "depth": 0},
    "body":    {"parent": "root",   "pivot": (620, 720), "zone": [(560, 560, 760, 720, 190)], "prio": 1, "depth": 1},
    "head":    {"parent": "body",   "pivot": (560, 500), "zone": [(430, 340, 580, 230, 170)], "prio": 1.3, "depth": 2},
    "hood_tip": {"parent": "head",  "pivot": (760, 170), "zone": [(800, 170, 960, 200, 42)], "prio": 2, "depth": 1.9},
    "cape_r":  {"parent": "body",   "pivot": (820, 430),
                "zone": [(880, 420, 1040, 470, 50), (900, 660, 1130, 790, 70)], "prio": 1.8, "depth": 0.8},
    "cape_lo": {"parent": "body",   "pivot": (720, 820),
                "zone": [(820, 860, 1050, 1120, 60), (370, 850, 390, 960, 40)], "prio": 1.8, "depth": 0.8},
    "tail":    {"parent": "body",   "pivot": (560, 880), "zone": [(540, 950, 640, 1080, 70)], "prio": 1.6, "depth": 1.2},
    "tail2":   {"parent": "tail",   "pivot": (660, 1090), "zone": [(670, 1120, 640, 1220, 42)], "prio": 2, "depth": 1.2},
    "arm_l":   {"parent": "body",   "pivot": (440, 640),
                "zone": [(420, 650, 280, 670, 30), (200, 760, 190, 790, 95)], "prio": 2, "depth": 3},
    "arm_r":   {"parent": "body",   "pivot": (720, 640),
                "zone": [(760, 700, 850, 800, 30), (910, 880, 940, 930, 95)], "prio": 2, "depth": 0.5},
}


def sway(i, n, amp=1.0, speed=1.0):
    """Áo choàng và đuôi hồn bay phấp phới."""
    p = math.tau * i / n * speed
    return {"cape_r": {"rot": 4 * amp * math.sin(p)}, "cape_lo": {"rot": -3 * amp * math.sin(p + 0.7)},
            "hood_tip": {"rot": 6 * amp * math.sin(p + 1.1)},
            "tail": {"rot": 5 * amp * math.sin(p + 0.3)}, "tail2": {"rot": 9 * amp * math.sin(p - 0.5)}}


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"root": {"dy": -30 * math.sin(p)},     # lơ lửng lên xuống
            "head": {"rot": 2 * math.sin(p + 0.5)},
            "arm_l": {"rot": 5 * math.sin(p + 0.8)}, "arm_r": {"rot": -5 * math.sin(p + 0.2)}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    # Lướt tới cào bằng tay trái phát sáng (trúng khung 4).
    keys = [
        (0, {}),
        (2, {"root": {"dx": 50, "dy": -20}, "body": {"rot": 6}, "head": {"rot": 4},
             "arm_l": {"rot": 40}, "arm_r": {"rot": -10}}),                                    # rút tay về
        (4, {"root": {"dx": -160, "dy": 10}, "body": {"rot": -10}, "head": {"rot": -8},
             "arm_l": {"rot": -40}, "arm_r": {"rot": 14}, "cape_r": {"rot": 14}, "cape_lo": {"rot": 10},
             "tail": {"rot": 12}, "tail2": {"rot": 16}}),                                       # cào (trúng)
        (5, {"root": {"dx": -140}, "body": {"rot": -8}, "arm_l": {"rot": -48}, "cape_r": {"rot": 10}}),
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.6))


def pose_skill(i, n):
    # Giơ hai tay hút hồn: bay cao, mũ ngửa ra sau, xả sóng hồn (trúng khung 6) – vẽ ở 6_vfx.
    keys = [
        (0, {}),
        (3, {"root": {"dy": -70}, "body": {"rot": 4}, "head": {"rot": 10},
             "arm_l": {"rot": 60}, "arm_r": {"rot": -50}, "hood_tip": {"rot": -12}}),
        (5, {"root": {"dy": -80}, "body": {"rot": 6, "sy": 1.04}, "head": {"rot": 14},
             "arm_l": {"rot": 74}, "arm_r": {"rot": -64}, "hood_tip": {"rot": -18}}),
        (6, {"root": {"dy": -40, "dx": -30}, "body": {"rot": -8}, "head": {"rot": -10},
             "arm_l": {"rot": -30}, "arm_r": {"rot": 20}, "cape_r": {"rot": 16}, "cape_lo": {"rot": 12}}),  # xả (trúng)
        (7, {"root": {"dy": -30, "dx": -24}, "body": {"rot": -6}, "head": {"rot": -7},
             "arm_l": {"rot": -24}, "arm_r": {"rot": 16}}),
        (9, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8, 2))


def pose_hit(i, n):
    keys = [
        (0, {"root": {"dx": 70, "dy": -10}, "body": {"rot": 10}, "head": {"rot": 14}, "arm_l": {"rot": 30},
             "arm_r": {"rot": 20}, "cape_r": {"rot": -10}, "tail": {"rot": -12}, "tail2": {"rot": -16}}),
        (1, {"root": {"dx": 80, "dy": -12}, "body": {"rot": 12}, "head": {"rot": 16}, "arm_l": {"rot": 34},
             "arm_r": {"rot": 22}, "cape_r": {"rot": -12}, "tail": {"rot": -14}, "tail2": {"rot": -18}}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    # Tan rã: chìm xuống, co dúm, tay buông.
    keys = [
        (0, {"head": {"rot": 8}}),
        (2, {"root": {"dy": 30, "sy": 0.9}, "body": {"rot": 8}, "head": {"rot": -14}, "arm_l": {"rot": -50},
             "arm_r": {"rot": 40}, "hood_tip": {"rot": 20}}),
        (4, {"root": {"dy": 90, "sy": 0.72, "sx": 1.08}, "body": {"rot": 12}, "head": {"rot": -24},
             "arm_l": {"rot": -70}, "arm_r": {"rot": 60}, "hood_tip": {"rot": 30}, "cape_r": {"rot": 24},
             "cape_lo": {"rot": 16}, "tail": {"rot": 30}, "tail2": {"rot": 40}}),
        (5, {"root": {"dy": 100, "sy": 0.68, "sx": 1.1}, "body": {"rot": 13}, "head": {"rot": -26},
             "arm_l": {"rot": -74}, "arm_r": {"rot": 64}, "hood_tip": {"rot": 32}, "cape_r": {"rot": 26},
             "cape_lo": {"rot": 18}, "tail": {"rot": 34}, "tail2": {"rot": 44}}),
    ]
    return lerp_keys(keys, i)


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "hit": pose_hit, "down": pose_down}

run({"id": "wandering_shade", "kind": "quai", "frame": 256, "char_h": 185, "feet": (128, 232),
     "drop_islands": True, "bones": BONES, "poses": POSES,
     "actions": {"idle": 6, "attack": 8, "skill": 10, "hit": 4, "down": 6},
     "hit_frames": {"attack": 4, "skill": 6}, "loops": ["idle"]})

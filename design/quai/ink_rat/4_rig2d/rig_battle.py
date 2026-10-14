"""Sprite trận của Chuột Mực Sách (ink_rat) bằng xương 2D (lõi ở design/_tools/rig2d.py).

Chạy từ gốc repo:
    blender -b -P design/quai/ink_rat/4_rig2d/rig_battle.py
    blender -b -P design/quai/ink_rat/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_ink_rat.png + .json (khung 256, quay trái như concept) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: chồm về trái, chân trước trái bước lên, đuôi cong chữ S, ngòi bút ở đầu đuôi.
BONES = {
    "root":    {"parent": None,     "pivot": (760, 880), "zone": [], "prio": 0.03, "depth": 0},
    "hips":    {"parent": "root",   "pivot": (900, 660),
                "zone": [(820, 560, 1040, 640, 120)], "prio": 1, "depth": 1},
    "leg_hr":  {"parent": "hips",   "pivot": (1030, 720), "zone": [(1050, 760, 1120, 880, 48)], "prio": 1.6, "depth": 1.4},
    "leg_hl":  {"parent": "hips",   "pivot": (800, 740), "zone": [(780, 770, 660, 830, 40)], "prio": 1.6, "depth": 0.6},
    "chest":   {"parent": "hips",   "pivot": (760, 600), "zone": [(520, 520, 720, 600, 115)], "prio": 1, "depth": 1.2},
    "leg_fl":  {"parent": "chest",  "pivot": (440, 650), "zone": [(415, 690, 365, 865, 46)], "prio": 1.6, "depth": 2},
    "leg_fr":  {"parent": "chest",  "pivot": (560, 700), "zone": [(545, 720, 540, 800, 40)], "prio": 1.6, "depth": 0.8},
    "head":    {"parent": "chest",  "pivot": (500, 470),
                "zone": [(260, 500, 440, 430, 115), (80, 520, 220, 540, 30)], "prio": 1.5, "depth": 3},
    "ear_l":   {"parent": "head",   "pivot": (300, 330), "zone": [(270, 300, 260, 190, 65)], "prio": 2, "depth": 2.8},
    "ear_r":   {"parent": "head",   "pivot": (560, 360), "zone": [(600, 300, 640, 170, 85)], "prio": 2, "depth": 2.6},
    "tail1":   {"parent": "hips",   "pivot": (1080, 640), "zone": [(1100, 640, 1290, 600, 42)], "prio": 2, "depth": 0.9},
    "tail2":   {"parent": "tail1",  "pivot": (1300, 580), "zone": [(1310, 560, 1190, 430, 42)], "prio": 2.2, "depth": 0.9},
    "tail3":   {"parent": "tail2",  "pivot": (1150, 425), "zone": [(1100, 415, 1025, 300, 42)], "prio": 2.2, "depth": 0.9},
    "tail4":   {"parent": "tail3",  "pivot": (1030, 280), "zone": [(1040, 240, 1190, 145, 42)], "prio": 2.2, "depth": 0.9},
    "nib":     {"parent": "tail4",  "pivot": (1210, 150), "zone": [(1230, 160, 1450, 300, 62)], "prio": 2.5, "depth": 0.95},
}
TAIL = ("tail1", "tail2", "tail3", "tail4", "nib")


def sway(i, n, amp=1.0, speed=1.0):
    """Đuôi uốn sóng (trễ dần về ngòi), tai giật nhẹ."""
    p = math.tau * i / n * speed
    out = {b: {"rot": (3 + 1.5 * k) * amp * math.sin(p - 0.8 * k)} for k, b in enumerate(TAIL)}
    out["ear_l"] = {"rot": 3 * amp * math.sin(p + 1.2)}
    out["ear_r"] = {"rot": -3 * amp * math.sin(p + 0.6)}
    return out


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.02 * math.sin(p)}, "hips": {"sy": 1 + 0.015 * math.sin(p + 0.5)},
            "head": {"rot": -2.5 * math.sin(p), "dy": 4 * math.sin(p)},  # đánh hơi
            "root": {"dy": 6 * max(0.0, math.sin(p))}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"root": {"dx": 60, "sy": 0.93}, "chest": {"rot": 5}, "head": {"rot": 6},          # lùi lấy đà
             "leg_fl": {"rot": 10}, "tail1": {"rot": -8}, "tail2": {"rot": -6}}),
        (4, {"root": {"dx": -150, "sy": 1.02}, "chest": {"rot": -8}, "head": {"rot": -14},     # lao cắn (trúng)
             "leg_fl": {"rot": -24}, "leg_fr": {"rot": -16}, "leg_hl": {"rot": 18}, "leg_hr": {"rot": 22},
             "ear_l": {"rot": 12}, "ear_r": {"rot": 14}, "tail1": {"rot": 10}, "tail2": {"rot": 8}}),
        (5, {"root": {"dx": -120}, "chest": {"rot": -5}, "head": {"rot": -6}, "leg_fl": {"rot": -14}}),
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.5))


def pose_skill(i, n):
    # Đuôi ngòi bút dựng lên qua lưng rồi đâm về phía trước (trúng khung 6) – vệt mực vẽ ở 6_vfx.
    keys = [
        (0, {}),
        (2, {"root": {"sy": 0.95}, "chest": {"rot": 3}, "head": {"rot": 4},
             "tail1": {"rot": -18}, "tail2": {"rot": -6}}),
        (4, {"root": {"sy": 0.93, "dx": 20}, "chest": {"rot": 5}, "head": {"rot": 6},           # dựng đuôi lấy đà
             "tail1": {"rot": -34}, "tail2": {"rot": -8}, "tail3": {"rot": 4}, "nib": {"rot": -10}}),
        (6, {"root": {"dx": -40}, "chest": {"rot": -5}, "head": {"rot": -8}, "leg_fl": {"rot": -10},  # đâm (trúng)
             "tail1": {"rot": -48}, "tail2": {"rot": 6}, "tail3": {"rot": 16}, "tail4": {"rot": 18},
             "nib": {"rot": 30}}),
        (7, {"root": {"dx": -30}, "chest": {"rot": -4}, "head": {"rot": -5},
             "tail1": {"rot": -44}, "tail2": {"rot": 4}, "tail3": {"rot": 12}, "tail4": {"rot": 14},
             "nib": {"rot": 24}}),
        (9, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.4))


def pose_hit(i, n):
    keys = [
        (0, {"root": {"dx": 70}, "chest": {"rot": 10}, "head": {"rot": 16}, "ear_l": {"rot": -14},
             "ear_r": {"rot": -10}, "tail1": {"rot": 12}, "tail2": {"rot": 10}, "leg_fl": {"rot": 16}}),
        (1, {"root": {"dx": 85}, "chest": {"rot": 12}, "head": {"rot": 18}, "ear_l": {"rot": -16},
             "ear_r": {"rot": -12}, "tail1": {"rot": 14}, "tail2": {"rot": 12}, "leg_fl": {"rot": 18}}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": 6}, "head": {"rot": 10}}),
        (2, {"root": {"sy": 0.85, "dx": 20}, "chest": {"rot": -6}, "head": {"rot": -12},
             "leg_fl": {"rot": 30}, "leg_fr": {"rot": 24}, "tail1": {"rot": 20}}),
        (4, {"root": {"sy": 0.72, "dy": 30, "dx": 30}, "chest": {"rot": -10}, "head": {"rot": -20},
             "leg_fl": {"rot": 60}, "leg_fr": {"rot": 50}, "leg_hl": {"rot": -40}, "leg_hr": {"rot": -40},
             "ear_l": {"rot": -20}, "ear_r": {"rot": 20},
             "tail1": {"rot": 34}, "tail2": {"rot": 30}, "tail3": {"rot": 20}, "tail4": {"rot": 20}}),
        (5, {"root": {"sy": 0.7, "dy": 34, "dx": 30}, "chest": {"rot": -11}, "head": {"rot": -22},
             "leg_fl": {"rot": 64}, "leg_fr": {"rot": 54}, "leg_hl": {"rot": -44}, "leg_hr": {"rot": -44},
             "ear_l": {"rot": -22}, "ear_r": {"rot": 22},
             "tail1": {"rot": 38}, "tail2": {"rot": 34}, "tail3": {"rot": 24}, "tail4": {"rot": 24}}),
    ]
    return lerp_keys(keys, i)


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "hit": pose_hit, "down": pose_down}

run({"id": "ink_rat", "kind": "quai", "frame": 256, "char_h": 105, "feet": (140, 200),
     "drop_islands": (700, 600), "bones": BONES, "poses": POSES,
     "actions": {"idle": 6, "attack": 8, "skill": 10, "hit": 4, "down": 6},
     "hit_frames": {"attack": 4, "skill": 6}, "loops": ["idle"]})

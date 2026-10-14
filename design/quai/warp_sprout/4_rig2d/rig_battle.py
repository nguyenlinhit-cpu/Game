"""Sprite trận của Mầm Ma Biến (warp_sprout) bằng xương 2D (lõi ở design/_tools/rig2d.py).

Chạy từ gốc repo:
    blender -b -P design/quai/warp_sprout/4_rig2d/rig_battle.py
    blender -b -P design/quai/warp_sprout/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_warp_sprout.png + .json (khung 256, quay trái như concept) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1254×1254), xem 4_rig2d/grid.png.
# Củ tròn có miệng răng cưa phát sáng bên trái, 2 lá mầm trên đỉnh, 3 chân rễ.
BONES = {
    "root":   {"parent": None,    "pivot": (610, 1150), "zone": [], "prio": 0.03, "depth": 0},
    "bulb":   {"parent": "root",  "pivot": (600, 1010), "zone": [(480, 720, 760, 760, 250)], "prio": 1, "depth": 1},
    # hàm dưới: phần củ dưới đường miệng, xoay quanh góc miệng bên phải để há miệng
    "jaw":    {"parent": "bulb",  "pivot": (760, 900), "zone": [(330, 900, 640, 950, 70)], "prio": 1.4, "depth": 1.1},
    "leg_l":  {"parent": "bulb",  "pivot": (390, 1040), "zone": [(380, 1060, 300, 1110, 48)], "prio": 1.6, "depth": 1.2},
    "leg_m":  {"parent": "bulb",  "pivot": (650, 1050), "zone": [(660, 1080, 640, 1180, 55)], "prio": 1.6, "depth": 1.3},
    "leg_r":  {"parent": "bulb",  "pivot": (830, 1030), "zone": [(850, 1050, 900, 1100, 48)], "prio": 1.6, "depth": 0.8},
    "stem":   {"parent": "bulb",  "pivot": (610, 480), "zone": [(600, 450, 640, 360, 38)], "prio": 1.6, "depth": 1.5},
    "leaf_l": {"parent": "stem",  "pivot": (640, 330), "zone": [(600, 280, 450, 150, 90), (390, 90, 380, 60, 30)],
               "prio": 2, "depth": 1.6},
    "leaf_r": {"parent": "stem",  "pivot": (690, 330), "zone": [(760, 300, 990, 350, 80), (1050, 390, 1110, 405, 25)],
               "prio": 2, "depth": 1.4},
}
# Pha lê Ma Biến chìa ra ngoài thân (pha lê bay rời đã bỏ bằng drop_islands; pha lê đè trên củ giữ lại).
ERASE = [(395, 340, 420, 450, 42), (1005, 585, 985, 700, 34)]


def sway(i, n, amp=1.0, speed=1.0):
    """Lá mầm phe phẩy lệch pha."""
    p = math.tau * i / n * speed
    return {"leaf_l": {"rot": 5 * amp * math.sin(p)}, "leaf_r": {"rot": -5 * amp * math.sin(p + 0.9)},
            "stem": {"rot": 2 * amp * math.sin(p + 0.4)}}


def pose_idle(i, n):
    p = math.tau * i / n
    squash = math.sin(p)
    base = {"bulb": {"sy": 1 + 0.03 * squash, "sx": 1 - 0.02 * squash},   # thở phồng xẹp
            "jaw": {"rot": -2 * max(0.0, squash)},
            "leg_l": {"rot": 3 * squash}, "leg_r": {"rot": -3 * squash}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"root": {"sy": 0.88, "dx": 30}, "bulb": {"rot": 6}, "jaw": {"rot": -10},           # nhún lấy đà, há miệng
             "leg_l": {"rot": 10}, "leg_m": {"rot": 6}}),
        (3, {"root": {"sy": 1.06, "dx": -90, "dy": -60}, "bulb": {"rot": -10}, "jaw": {"rot": -22},  # bật nhảy
             "leg_l": {"rot": -16}, "leg_m": {"rot": -14}, "leg_r": {"rot": -12}}),
        (4, {"root": {"sy": 0.94, "dx": -150, "dy": -10}, "bulb": {"rot": -12}, "jaw": {"rot": 2},   # đớp (trúng)
             "leg_l": {"rot": -8}, "leg_m": {"rot": -6}}),
        (5, {"root": {"sy": 0.9, "dx": -130}, "bulb": {"rot": -6}, "jaw": {"rot": 0}}),
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.2))


def pose_skill(i, n):
    # Phun bào tử ma biến: rung lắc, phồng to rồi há miệng xả (trúng khung 6), hạt bào tử vẽ ở 6_vfx.
    shake = 4 * math.sin(i * 2.6) if 1 <= i <= 4 else 0
    keys = [
        (0, {}),
        (4, {"root": {"sy": 0.9}, "bulb": {"sx": 1.06, "sy": 1.08}, "jaw": {"rot": 4},
             "leaf_l": {"rot": -18}, "leaf_r": {"rot": 18}}),
        (6, {"root": {"sy": 1.04}, "bulb": {"sx": 0.98, "sy": 0.96, "rot": -6}, "jaw": {"rot": -26},
             "leaf_l": {"rot": 14}, "leaf_r": {"rot": -14}, "stem": {"rot": -6}}),
        (7, {"bulb": {"rot": -4}, "jaw": {"rot": -20}, "leaf_l": {"rot": 8}, "leaf_r": {"rot": -8}}),
        (9, {}),
    ]
    return add(add(lerp_keys(keys, i), {"bulb": {"rot": shake}}), sway(i, n, 0.6, 2))


def pose_hit(i, n):
    keys = [
        (0, {"root": {"dx": 60, "sy": 0.9}, "bulb": {"rot": 10, "sx": 1.05}, "jaw": {"rot": -6},
             "leaf_l": {"rot": 20}, "leaf_r": {"rot": 16}}),
        (1, {"root": {"dx": 70, "sy": 0.92}, "bulb": {"rot": 12}, "jaw": {"rot": -8},
             "leaf_l": {"rot": 24}, "leaf_r": {"rot": 20}}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    # Héo rũ: lá cụp, củ xẹp nghiêng sang bên.
    keys = [
        (0, {"bulb": {"rot": 6}, "leaf_l": {"rot": 10}}),
        (2, {"root": {"sy": 0.86}, "bulb": {"rot": 12}, "jaw": {"rot": 4}, "stem": {"rot": 14},
             "leaf_l": {"rot": -40}, "leaf_r": {"rot": 30}}),
        (4, {"root": {"sy": 0.72, "rot": 14, "dx": 40}, "bulb": {"rot": 8}, "jaw": {"rot": 6}, "stem": {"rot": 30},
             "leaf_l": {"rot": -70}, "leaf_r": {"rot": 55}, "leg_l": {"rot": 30}, "leg_r": {"rot": -30}}),
        (5, {"root": {"sy": 0.7, "rot": 16, "dx": 44}, "bulb": {"rot": 8}, "jaw": {"rot": 6}, "stem": {"rot": 34},
             "leaf_l": {"rot": -76}, "leaf_r": {"rot": 60}, "leg_l": {"rot": 34}, "leg_r": {"rot": -34}}),
    ]
    return lerp_keys(keys, i)


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "hit": pose_hit, "down": pose_down}

run({"id": "warp_sprout", "kind": "quai", "frame": 256, "char_h": 115, "feet": (128, 210),
     "drop_islands": True, "erase": ERASE, "bones": BONES, "poses": POSES,
     "actions": {"idle": 6, "attack": 8, "skill": 10, "hit": 4, "down": 6},
     "hit_frames": {"attack": 4, "skill": 6}, "loops": ["idle"]})

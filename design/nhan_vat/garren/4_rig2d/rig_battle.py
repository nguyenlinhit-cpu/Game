"""Sprite trận của Garren bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/garren/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/garren/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_garren.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1312×1199), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn rộng, tay trái vác chùy trên vai, khiên gỗ tròn lớn che nửa người bên phải.
BONES = {
    "root":     {"parent": None,     "pivot": (590, 1125), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":    {"parent": "root",   "pivot": (390, 880), "zone": [(370, 900, 270, 1110, 95)], "prio": 1, "depth": 1},
    "leg_r":    {"parent": "root",   "pivot": (760, 900), "zone": [(780, 940, 880, 1100, 75)], "prio": 1, "depth": 1},
    "hips":     {"parent": "root",   "pivot": (600, 880),
                 "zone": [(450, 800, 720, 840, 120), (620, 850, 620, 1050, 95)], "prio": 1, "depth": 1.2},
    "cape":     {"parent": "hips",   "pivot": (320, 660), "zone": [(270, 720, 170, 880, 80)], "prio": 2, "depth": 0.8},
    "chest":    {"parent": "hips",   "pivot": (600, 800), "zone": [(440, 560, 740, 680, 140)], "prio": 1.2, "depth": 2},
    "head":     {"parent": "chest",  "pivot": (640, 540), "zone": [(560, 230, 760, 330, 205)], "prio": 1.4, "depth": 3},
    "arm_l":    {"parent": "chest",  "pivot": (380, 560), "zone": [(330, 580, 210, 570, 72)], "prio": 2, "depth": 2.6},
    "branch_l": {"parent": "chest",  "pivot": (350, 480), "zone": [(300, 440, 140, 380, 72)], "prio": 2.6, "depth": 2.4},
    "branch_r": {"parent": "chest",  "pivot": (870, 520), "zone": [(930, 470, 1060, 470, 72)], "prio": 2.6, "depth": 2.4},
    # Lớp trên trọng số cứng: chùy (kèm bàn tay cầm) và khiên.
    "mace":     {"parent": "arm_l",  "pivot": (215, 525), "zone": [], "prio": 0, "depth": 10},
    "shield":   {"parent": "chest",  "pivot": (900, 800), "zone": [], "prio": 0, "depth": 11},
}
MACE_ZONE = [(165, 640, 290, 320, 34), (318, 255, 318, 255, 98), (205, 505, 245, 540, 52), (130, 625, 170, 655, 30)]
# Khiên elip hơi nghiêng, tâm khoảng (1010, 840), bán trục 240 × 276 (gồm viền ngoài): ghép bằng các dải ngang.
SHIELD_ZONE = []
for _y in range(566, 1114, 16):
    _w = 240 * math.sqrt(max(0.0, 1 - ((_y - 840) / 276) ** 2))
    if _w > 12:
        _cx = 1010 + (_y - 840) * 0.06  # mép dưới lệch sang phải
        SHIELD_ZONE.append((_cx - _w + 12, _y, _cx + _w - 12, _y, 12))


def sway(i, n, amp=1.0, speed=1.0):
    """Cành lá trên vai rung nhẹ, vạt áo choàng đung đưa."""
    p = math.tau * i / n * speed
    return {"branch_l": {"rot": 3 * amp * math.sin(p + 0.4)}, "branch_r": {"rot": -3 * amp * math.sin(p + 1.1)},
            "cape": {"rot": 2.5 * amp * math.sin(p + 0.8)}}


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.016 * math.sin(p)}, "hips": {"sy": 1 - 0.005 * math.sin(p)},  # thở sâu
            "head": {"dy": -4 * math.sin(p), "rot": 0.8 * math.sin(p)},
            "shield": {"dy": -3 * math.sin(p)}, "mace": {"rot": 1.5 * math.sin(p)}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"hips": {"dx": -22}, "chest": {"rot": -3}, "shield": {"dy": -70, "dx": -10, "rot": -4},  # nâng khiên ngang mặt
             "head": {"rot": -2}}),
        (3, {"hips": {"dx": 22}, "chest": {"rot": 5}, "shield": {"dy": -40, "dx": 36, "rot": 3}}),
        (4, {"hips": {"dx": 34}, "chest": {"rot": 7}, "shield": {"dy": -30, "dx": 52, "rot": 5},       # đập mặt khiên (trúng)
             "head": {"rot": 3}, "cape": {"rot": -8}}),
        (5, {"hips": {"dx": 20}, "chest": {"rot": 2}, "shield": {"dy": -10, "dx": 50}, "cape": {"rot": -4}}),
        (6, {"hips": {"dx": 0}, "head": {"rot": 4}, "arm_l": {"rot": 6}}),                             # phủi râu
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.7))


def pose_skill(i, n):
    keys = [
        (0, {}),
        (3, {"root": {"sy": 0.96}, "shield": {"dy": 30}, "chest": {"sy": 1.035, "rot": 2}, "head": {"rot": 2}}),  # cắm khiên, hít sâu
        (5, {"root": {"sy": 1.03}, "shield": {"dy": 30}, "chest": {"rot": -5, "sy": 1.02}, "head": {"rot": -8},   # gầm lớn
             "branch_l": {"rot": -8}, "branch_r": {"rot": 8}}),
        (6, {"root": {"sy": 1.03}, "shield": {"dy": 30}, "chest": {"rot": -6}, "head": {"rot": -9},
             "branch_l": {"rot": -10}, "branch_r": {"rot": 10}}),
        (8, {"shield": {"dy": 30}, "arm_l": {"rot": 28}, "mace": {"rot": 34}}),                      # gõ chùy vào khiên
        (9, {"shield": {"dy": 20}, "arm_l": {"rot": 8}, "mace": {"rot": 8}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_ultimate(i, n):
    grow = {"branch_l": {"sx": 1.35, "sy": 1.35, "rot": -6}, "branch_r": {"sx": 1.35, "sy": 1.35, "rot": 6}}
    keys = [
        (0, {}),
        (3, {"shield": {"dy": -170, "dx": -90, "rot": -8}, "chest": {"rot": -4}, "head": {"rot": -6},   # giơ khiên lên trời
             "arm_l": {"rot": 20}, "root": {"sy": 1.02},
             "branch_l": {"sx": 1.15, "sy": 1.15}, "branch_r": {"sx": 1.15, "sy": 1.15}}),
        (5, {"shield": {"dy": -210, "dx": -110, "rot": -10}, "chest": {"rot": -5}, "head": {"rot": -8},
             "arm_l": {"rot": 24}, "root": {"sy": 1.03}, **grow}),                                     # cành vai mọc dài
        (7, {"shield": {"dy": 30, "dx": 60, "rot": 4}, "chest": {"rot": 8}, "head": {"rot": 4},        # đập khiên xuống đất
             "root": {"sy": 0.92}, "hips": {"dy": 20}, **grow}),
        (8, {"shield": {"dy": 40, "dx": 70, "rot": 5}, "chest": {"rot": 9}, "head": {"rot": 5},
             "root": {"sy": 0.9}, "hips": {"dy": 26}, **grow}),
        (10, {"shield": {"dy": 30, "dx": 40}, "chest": {"rot": 6}, "head": {"rot": 2},                 # quỳ một gối sau khiên
              "root": {"sy": 0.86}, "hips": {"dy": 50}, "leg_l": {"rot": -14}, **grow}),
        (11, {"shield": {"dy": 30, "dx": 40}, "chest": {"rot": 6}, "head": {"rot": 2},
              "root": {"sy": 0.86}, "hips": {"dy": 50}, "leg_l": {"rot": -14}, **grow}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.6, 2))


def pose_hit(i, n):
    keys = [
        (0, {"chest": {"rot": -8}, "head": {"rot": -8}, "hips": {"dx": -18}, "shield": {"dx": -20, "rot": -6},
             "cape": {"rot": 10}, "branch_l": {"rot": 10}, "branch_r": {"rot": 10}}),
        (1, {"chest": {"rot": -10}, "head": {"rot": -9}, "hips": {"dx": -24}, "shield": {"dx": -26, "rot": -7},
             "cape": {"rot": 12}, "branch_l": {"rot": 12}, "branch_r": {"rot": 12}}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    """Khuỵu xuống rồi gục quỳ, tì người vào khiên cắm đất (giữ khung cuối)."""
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8},
             "shield": {"dy": 30}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 70}, "chest": {"rot": 16}, "head": {"rot": 18, "dy": 10},
             "shield": {"dy": 50, "rot": 4}, "arm_l": {"rot": -22}, "mace": {"rot": -30}, "leg_l": {"rot": -16}}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 92}, "chest": {"rot": 22}, "head": {"rot": 26, "dy": 16},
             "shield": {"dy": 60, "rot": 7}, "arm_l": {"rot": -34}, "mace": {"rot": -50}, "leg_l": {"rot": -22},
             "branch_l": {"rot": 18}, "branch_r": {"rot": 14}, "cape": {"rot": 6}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    p = math.tau * i / n
    nod = max(0.0, math.sin(math.pi * (i - 2) / 4)) if 2 <= i <= 6 else 0.0  # gật đầu nghiêm
    base = {"shield": {"dy": 26}, "head": {"rot": 7 * nod, "dy": 4 * nod},     # chống khiên xuống đất
            "chest": {"sy": 1 + 0.015 * math.sin(p)}, "arm_l": {"rot": -4 * math.sin(p)}}
    return add(base, sway(i, n, 1.2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

run({"id": "garren", "bones": BONES, "top": [("mace", MACE_ZONE), ("shield", SHIELD_ZONE)], "poses": POSES,
     "shadow_below": 1110, "white_holes": 30,  # bóng đổ xám dưới chân; nền trắng lọt giữa lá
     "char_h": 360})  # Garren rất ngang (khiên + chùy): thu nhỏ hơn để đập khiên không ra ngoài khung

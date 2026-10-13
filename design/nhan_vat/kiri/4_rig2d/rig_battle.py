"""Sprite trận của Kiri bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/kiri/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/kiri/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_kiri.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1145×1374), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng trụ chân phải, chân trái co ra sau, tay phải giơ gậy pháo lên trời, tay trái dang ngang.
BONES = {
    "root":    {"parent": None,     "pivot": (555, 1345), "zone": [], "prio": 0.03, "depth": 0},
    "leg_r":   {"parent": "root",   "pivot": (600, 905),  "zone": [(600, 930, 556, 1345, 58)], "prio": 1, "depth": 1},
    "hips":    {"parent": "root",   "pivot": (640, 880),
                "zone": [(610, 780, 720, 870, 80), (790, 830, 810, 940, 50)], "prio": 1, "depth": 1.2},
    "leg_l":   {"parent": "hips",   "pivot": (600, 925),
                "zone": [(560, 955, 400, 965, 58), (320, 960, 300, 960, 75)], "prio": 1.3, "depth": 1.5},
    "chest":   {"parent": "hips",   "pivot": (630, 760), "zone": [(560, 570, 680, 720, 110)], "prio": 1.2, "depth": 2},
    "bag":     {"parent": "hips",   "pivot": (560, 740),
                "zone": [(340, 830, 470, 850, 78), (470, 735, 520, 735, 42)], "prio": 2.5, "depth": 4},
    "arm_out": {"parent": "chest",  "pivot": (470, 585), "zone": [(420, 610, 225, 680, 58)], "prio": 2, "depth": 2.5},
    "arm_up":  {"parent": "chest",  "pivot": (715, 530), "zone": [(745, 545, 880, 555, 68)], "prio": 2, "depth": 2.5},
    "head":    {"parent": "chest",  "pivot": (612, 545), "zone": [(560, 340, 660, 400, 160)], "prio": 1.4, "depth": 3},
    "braid_l": {"parent": "head",   "pivot": (395, 300), "zone": [(365, 275, 295, 205, 52)], "prio": 2.5, "depth": 2.8},
    "braid_l2": {"parent": "braid_l", "pivot": (290, 185), "zone": [(285, 165, 300, 120, 40)], "prio": 3, "depth": 2.8},
    "braid_l3": {"parent": "braid_l2", "pivot": (300, 110), "zone": [(310, 95, 330, 45, 38)], "prio": 3.2, "depth": 2.8},
    "braid_r": {"parent": "head",   "pivot": (670, 275), "zone": [(680, 255, 705, 195, 40)], "prio": 2.5, "depth": 2.8},
    "braid_r2": {"parent": "braid_r", "pivot": (712, 180), "zone": [(720, 170, 748, 152, 30)], "prio": 3, "depth": 2.8},
    "braid_r3": {"parent": "braid_r2", "pivot": (752, 150), "zone": [(770, 145, 825, 140, 32)], "prio": 3.2, "depth": 2.8},
    # Bàn tay giơ + gậy pháo: lớp riêng trọng số cứng, xoay quanh chỗ cầm.
    "wand":    {"parent": "arm_up", "pivot": (842, 425), "zone": [], "prio": 0, "depth": 10},
}
WAND_ZONE = [(828, 385, 852, 462, 30), (812, 466, 992, 136, 21), (1000, 118, 1000, 118, 50)]

# Tia lửa vẽ sẵn trong concept (hiệu ứng làm riêng ở 6_vfx/): xoá, trừ gậy, ngôi sao và đuôi bím tóc.
ERASE = [(415, 72, 415, 72, 52), (848, 212, 848, 212, 42), (570, 45, 1140, 45, 46), (870, 150, 1140, 150, 72),
         (950, 255, 1140, 255, 62), (995, 320, 1060, 320, 32), (715, 85, 760, 85, 22)]
KEEP = [(812, 462, 990, 140, 18), (1000, 118, 1000, 118, 46), (745, 150, 822, 140, 36), (300, 70, 330, 45, 40)]


def sway(i, n, amp=1.0, speed=1.0):
    """Bím tóc nảy theo nhịp (trễ dần về đuôi), túi đeo đung đưa."""
    p = math.tau * i / n * speed
    out = {"bag": {"rot": 4 * amp * math.sin(p + 0.6)}}
    for k, (side, sign) in enumerate((("braid_l", -1), ("braid_r", 1))):
        for j, suffix in enumerate(("", "2", "3")):
            out[side + suffix] = {"rot": sign * (3 + 2 * j) * amp * math.sin(p + 0.7 + 0.9 * j)}
    return out


def pose_idle(i, n):
    p = math.tau * i / n
    hop = abs(math.sin(p))  # nhún nhảy tại chỗ
    base = {"root": {"dy": -26 * hop, "sy": 1 + 0.02 * hop}, "chest": {"sy": 1 + 0.012 * math.sin(p)},
            "head": {"rot": 2 * math.sin(p)}, "arm_out": {"rot": -5 * math.sin(p)},
            "arm_up": {"rot": 8 * math.cos(p)},
            "wand": {"rot": 28 * math.sin(p)},  # đầu gậy vẽ một vòng (cổ tay xoay), không quét qua mặt
            "leg_l": {"rot": 6 * math.sin(p)}}
    return add(base, sway(i, n, 1.2, 2))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"arm_up": {"rot": -14}, "wand": {"rot": -20}, "head": {"rot": 6}, "chest": {"rot": -2}}),  # thổi vào đầu gậy
        (3, {"arm_up": {"rot": 30}, "wand": {"rot": 10}, "head": {"rot": 2}, "chest": {"rot": 4}, "hips": {"dx": 6}}),
        (4, {"arm_up": {"rot": 46}, "wand": {"rot": 18}, "head": {"rot": 1}, "chest": {"rot": 6},       # chĩa gậy, bắn (trúng)
             "hips": {"dx": 12}, "arm_out": {"rot": -10}}),
        (5, {"arm_up": {"rot": 28}, "wand": {"rot": -16}, "head": {"rot": -7}, "chest": {"rot": -6},     # gậy giật lùi
             "hips": {"dx": -10}}),
        (6, {"arm_up": {"rot": 10}, "wand": {"rot": -6}, "head": {"rot": -4}, "chest": {"rot": -2}}),    # cười hì hì
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_skill(i, n):
    if i <= 4:  # khung 0–4: tay và đầu gậy vẽ hai vòng tròn như nhạc trưởng
        a = math.tau * 2 * i / 5  # mỗi khung 144°: 5 vị trí khác nhau trên vòng tròn
        base = {"arm_up": {"rot": -12 + 14 * math.cos(a), "dy": -10 * math.sin(a)},
                "wand": {"rot": 32 * math.sin(a)}, "head": {"rot": 3 * math.sin(a)},
                "chest": {"rot": -2 * math.cos(a)}}
        return add(base, sway(i, n, 0.8))
    keys = [
        (4, {"arm_up": {"rot": 2}}),
        (6, {"arm_up": {"rot": 40}, "wand": {"rot": 15}, "chest": {"rot": 5}, "hips": {"dx": 8},  # chỉ gậy về đồng minh
             "head": {"rot": 2}}),
        (8, {"arm_up": {"rot": 6}, "head": {"rot": 7}, "arm_out": {"rot": -24}}),                # nháy mắt, ngón cái
        (9, {"head": {"rot": 4}, "arm_out": {"rot": -14}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_ultimate(i, n):
    keys = [
        (0, {}),
        (2, {"root": {"sy": 0.93}, "chest": {"rot": 10}, "head": {"rot": 6}, "arm_up": {"rot": 62},   # cắm ống pháo
             "wand": {"rot": 40}, "arm_out": {"rot": 14}, "hips": {"dx": 8}}),
        (5, {"root": {"sy": 0.92}, "chest": {"rot": 12}, "head": {"rot": 8}, "arm_up": {"rot": 72},   # châm ngòi
             "wand": {"rot": 60}, "arm_out": {"rot": 18}, "hips": {"dx": 10}}),
        (7, {"root": {"sy": 1.03, "dy": -12}, "chest": {"rot": -4}, "head": {"rot": -10}, "arm_up": {"rot": -8},
             "wand": {"rot": -10}}),                                                                   # pháo phóng lên
        (9, {"chest": {"rot": -6}, "head": {"rot": -13}, "arm_up": {"rot": 4}, "arm_out": {"rot": -30}}),
        (10, {"chest": {"rot": -6}, "head": {"rot": -12}, "arm_up": {"rot": 34}, "wand": {"rot": -40},  # chống hông
              "arm_out": {"rot": -48}}),
        (11, {"chest": {"rot": -6}, "head": {"rot": -12}, "arm_up": {"rot": 34}, "wand": {"rot": -40},
              "arm_out": {"rot": -48}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.7, 2))


def pose_hit(i, n):
    fly = {"braid_l": {"rot": 14}, "braid_l2": {"rot": 10}, "braid_r": {"rot": 12}, "braid_r2": {"rot": 10},
           "bag": {"rot": 8}}
    keys = [
        (0, {"chest": {"rot": -10}, "head": {"rot": -9}, "hips": {"dx": -14}, "arm_up": {"rot": -12},
             "arm_out": {"rot": 10}, **fly}),
        (1, {"chest": {"rot": -12}, "head": {"rot": -10}, "hips": {"dx": -18}, "arm_up": {"rot": -14},
             "arm_out": {"rot": 12}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.9}, "chest": {"rot": 5}, "head": {"rot": 8}, "arm_up": {"rot": 40}, "leg_l": {"rot": 18}}),
        (2, {"root": {"sy": 0.85, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10},
             "arm_up": {"rot": 70}, "wand": {"rot": 40}, "leg_l": {"rot": 24}}),
        (4, {"root": {"sy": 0.85, "rot": -72, "dx": 470, "dy": -230}, "chest": {"rot": 6}, "head": {"rot": 12},
             "arm_up": {"rot": 80}, "wand": {"rot": 50}, "leg_l": {"rot": 10}, "braid_l": {"rot": 20}}),
        (5, {"root": {"sy": 0.85, "rot": -84, "dx": 520, "dy": -290}, "chest": {"rot": 4}, "head": {"rot": 10},
             "arm_up": {"rot": 84}, "wand": {"rot": 56}, "leg_l": {"rot": 4}, "braid_l": {"rot": 26},
             "braid_r": {"rot": 30}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    p = math.tau * i / n
    jump = max(0.0, math.sin(p))  # nhảy lên giơ hai tay
    base = {"root": {"dy": -70 * jump, "sy": 1 + 0.03 * jump - 0.04 * max(0.0, -math.sin(p))},
            "arm_out": {"rot": 60 * jump}, "arm_up": {"rot": -10 * jump}, "wand": {"rot": 30 * math.sin(p)},
            "head": {"rot": -4 * jump}, "leg_l": {"rot": 12 * jump}, "leg_r": {"rot": -6 * jump}}
    return add(base, sway(i, n, 1.5, 2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

run({"id": "kiri", "bones": BONES, "top": [("wand", WAND_ZONE)], "erase": ERASE, "keep": KEEP,
     "poses": POSES})

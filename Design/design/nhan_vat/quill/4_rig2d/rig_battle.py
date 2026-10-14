"""Sprite trận của Quill bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/quill/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/quill/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_quill.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn, vác ống tiêm đồng khổng lồ trên vai trái (bên phải ảnh, tay trái đỡ), tay phải giơ ngón cái;
# ba lô đầy ống nghiệm xanh sau lưng (bên trái ảnh), mũ phi công có kính và hai tai mũ lông, áo blouse trắng.
BONES = {
    "root":      {"parent": None,     "pivot": (720, 990), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":     {"parent": "root",   "pivot": (620, 760), "zone": [(600, 790, 530, 940, 60)], "prio": 1, "depth": 1},
    "leg_r":     {"parent": "root",   "pivot": (840, 760), "zone": [(860, 800, 910, 920, 60)], "prio": 1, "depth": 1},
    "hips":      {"parent": "root",   "pivot": (720, 690), "zone": [(640, 660, 860, 700, 80)], "prio": 1, "depth": 1.2},
    "coat":      {"parent": "hips",   "pivot": (930, 600), "zone": [(1000, 680, 1080, 760, 50)], "prio": 2, "depth": 1.3},
    "chest":     {"parent": "hips",   "pivot": (720, 640), "zone": [(720, 480, 760, 560, 95)], "prio": 1.2, "depth": 2},
    "pack":      {"parent": "chest",  "pivot": (520, 420), "zone": [(430, 420, 440, 640, 110)], "prio": 2.5,
                  "depth": 1.5},
    "tube":      {"parent": "pack",   "pivot": (335, 565), "zone": [(330, 610, 335, 670, 32)], "prio": 3, "depth": 1.6},
    "head":      {"parent": "chest",  "pivot": (680, 340), "zone": [(680, 200, 720, 250, 160)], "prio": 1.4,
                  "depth": 3},
    "plunger":   {"parent": "head",   "pivot": (470, 170),
                  "zone": [(350, 100, 450, 100, 30), (360, 200, 440, 240, 30), (360, 150, 470, 150, 30)], "prio": 5,
                  "depth": 2.9},
    "ear_l":     {"parent": "head",   "pivot": (520, 240), "zone": [(500, 280, 530, 340, 40)], "prio": 2.6, "depth": 3.1},
    "ear_r":     {"parent": "head",   "pivot": (800, 260), "zone": [(830, 290, 860, 320, 35)], "prio": 2.6, "depth": 3.1},
    "arm_thumb": {"parent": "chest",  "pivot": (620, 440), "zone": [(640, 420, 690, 400, 50)], "prio": 2.4, "depth": 3.4},
    "arm_syr":   {"parent": "chest",  "pivot": (880, 420), "zone": [(920, 410, 980, 390, 45)], "prio": 2.2, "depth": 3.2},
    # Lớp trên trọng số cứng: ống tiêm khổng lồ (phần trước vai + cán đẩy thò ra sau đầu) kèm bàn tay đỡ.
    "syringe":   {"parent": "arm_syr", "pivot": (970, 380), "zone": [], "prio": 0, "depth": 10},
}
SYRINGE_ZONE = [(900, 240, 1240, 300, 80), (1240, 310, 1300, 360, 50), (1290, 368, 1450, 412, 12),
                (1110, 400, 1150, 490, 32), (950, 380, 990, 380, 40),
                (870, 200, 910, 260, 36), (960, 420, 990, 500, 36), (1000, 470, 1020, 500, 24)]  # nắp sau, dây đeo                     # ống, đầu kim, lọ treo, tay
# Cán đẩy thò ra sau đầu dính liền mũ: để ở lớp nền (đi theo đầu/ba lô), không xoay theo ống tiêm.
ERASE = [(1465, 425, 1468, 450, 16)]  # giọt thuốc vẽ sẵn ở đầu kim


def sway(i, n, amp=1.0, speed=1.0):
    """Ba lô nảy, ống nghiệm treo lắc, tai mũ đung đưa."""
    p = math.tau * i / n * speed
    return {"pack": {"rot": 2 * amp * math.sin(p + 0.5), "dy": 4 * amp * math.sin(p * 2)},
            "tube": {"rot": 8 * amp * math.sin(p + 1.2)}, "ear_l": {"rot": 4 * amp * math.sin(p + 0.3)},
            "ear_r": {"rot": -4 * amp * math.sin(p + 0.9)}, "coat": {"rot": 2 * amp * math.sin(p + 0.7)}}


def pose_idle(i, n):
    p = math.tau * i / n
    hop = abs(math.sin(p))
    base = {"root": {"dy": -10 * hop, "sy": 1 + 0.015 * hop}, "head": {"rot": 1.5 * math.sin(p)},
            "syringe": {"rot": -1.5 * math.sin(p)}, "arm_thumb": {"rot": 3 * math.sin(p)}}
    return add(base, sway(i, n, 1.0, 2))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (1, {"syringe": {"rot": -6}, "arm_syr": {"rot": -3}}),                                     # lắc ống tiêm
        (2, {"syringe": {"rot": 5}, "arm_syr": {"rot": 2}, "head": {"rot": -2}}),
        (3, {"syringe": {"rot": 10, "dx": 40, "dy": 20}, "hips": {"dx": 30}, "chest": {"rot": 6}}),  # lao tới
        (4, {"syringe": {"rot": 12, "dx": 70, "dy": 30}, "hips": {"dx": 50}, "chest": {"rot": 8}, "head": {"rot": 3}}),
        (6, {"syringe": {"rot": -10, "dx": -10}, "hips": {"dx": -10}, "chest": {"rot": -3}}),         # lùi, thổi đầu kim
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


def pose_skill(i, n):
    keys = [
        (0, {}),
        (2, {"arm_thumb": {"rot": -18, "dx": -16}, "chest": {"rot": -4}}),                        # rút 2 ống nghiệm
        (3, {"arm_thumb": {"rot": -8}}),
        (5, {"arm_thumb": {"rot": 16, "dx": 16}, "chest": {"rot": 5}, "hips": {"dx": 10}}),        # ném
        (6, {"arm_thumb": {"rot": 20, "dx": 20}, "chest": {"rot": 6}, "hips": {"dx": 14}}),
        (8, {"arm_thumb": {"rot": -14, "dy": -20}, "head": {"rot": -4}}),               # lau mồ hôi trán
        (9, {"arm_thumb": {"rot": -10, "dy": -14}, "head": {"rot": -3}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


def pose_ultimate(i, n):
    if i <= 5:  # lôi bình thuốc lớn, lắc thật mạnh
        shake = [0, 0, 14, -14, 14, -14][i]
        base = {"arm_thumb": {"rot": -30 + shake, "dy": -20}, "chest": {"rot": shake * 0.15},
                "pack": {"rot": -shake * 0.3}, "root": {"dy": -6 * (i % 2)}}
        return add(base, sway(i, n, 1.5, 2))
    keys = [
        (6, {"arm_thumb": {"rot": 30, "dy": -40}, "chest": {"rot": 4}}),          # bật nắp, phun
        (9, {"arm_thumb": {"rot": 36, "dy": -44}, "chest": {"rot": 5}}),
        (10, {"root": {"sy": 0.86}, "hips": {"dy": 60}, "chest": {"rot": 4}, "arm_thumb": {"rot": 0},   # ngồi bệt
              "syringe": {"rot": 10, "dy": 40}, "leg_l": {"rot": 30}, "leg_r": {"rot": -30}}),
        (11, {"root": {"sy": 0.86}, "hips": {"dy": 60}, "chest": {"rot": 4}, "arm_thumb": {"rot": 0},
              "syringe": {"rot": 10, "dy": 40}, "leg_l": {"rot": 30}, "leg_r": {"rot": -30}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


def pose_hit(i, n):
    fly = {"ear_l": {"rot": -10}, "ear_r": {"rot": 10}, "tube": {"rot": 20}, "pack": {"rot": -4}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "syringe": {"rot": -8}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "syringe": {"rot": -9}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "syringe": {"rot": 14}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 80}, "chest": {"rot": 14}, "head": {"rot": 16, "dy": 8},
             "syringe": {"rot": 14, "dy": 90}, "leg_l": {"rot": 24}, "leg_r": {"rot": -24}}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 110}, "chest": {"rot": 22}, "head": {"rot": 24, "dy": 14},
             "syringe": {"rot": 18, "dy": 120}, "leg_l": {"rot": 30}, "leg_r": {"rot": -30}, "tube": {"rot": 30}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Giơ ngón cái (sẵn trong concept), ống nghiệm treo suýt rơi (văng ra) rồi chụp lại."""
    keys = [(0, {}), (2, {"arm_thumb": {"rot": -10, "dy": -10}, "head": {"rot": -3}}),
            (3, {"tube": {"rot": 60, "dy": 40}, "head": {"rot": 4}}),
            (4, {"tube": {"rot": 80, "dy": 70}, "arm_thumb": {"rot": 14, "dy": 24}, "chest": {"rot": -4}}),
            (5, {"tube": {"rot": 40, "dy": 30}, "arm_thumb": {"rot": 8, "dy": 14}}),
            (7, {"head": {"rot": -2}})]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "quill", "bones": BONES, "top": [("syringe", SYRINGE_ZONE)], "poses": POSES, "erase": ERASE,
          "strict_pockets": 300, "char_h": 350, "foot_x": 870}  # ống tiêm dài: lệch tâm để mũi kim không ra khung

if __name__ == "__main__":
    run(CONFIG)

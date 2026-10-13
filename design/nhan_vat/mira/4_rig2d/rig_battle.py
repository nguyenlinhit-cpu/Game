"""Sprite trận của Mira bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/mira/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/mira/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_mira.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1145×1374), xem 4_rig2d/grid.png. pivot = khớp xoay.
# zone = các đoạn (ax, ay, bx, by, bán kính) quyết định vùng ảnh hưởng; prio = ưu tiên khi vùng chồng nhau;
# depth = lớp trước/sau khi các vùng chồng lên nhau sau biến dạng.
BONES = {
    "root":   {"parent": None,    "pivot": (575, 1360), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":  {"parent": "root",  "pivot": (525, 1090), "zone": [(520, 1110, 500, 1370, 45)], "prio": 1, "depth": 1},
    "leg_r":  {"parent": "root",  "pivot": (670, 1090), "zone": [(672, 1110, 650, 1370, 45)], "prio": 1, "depth": 1},
    "hips":   {"parent": "root",  "pivot": (600, 1060),
               "zone": [(250, 960, 880, 960, 105), (380, 800, 820, 800, 70), (200, 900, 300, 1000, 60)],
               "prio": 1, "depth": 1},
    "chest":  {"parent": "hips",  "pivot": (610, 720), "zone": [(560, 470, 640, 700, 105)], "prio": 1.2, "depth": 2},
    "flask":  {"parent": "hips",  "pivot": (455, 650),
               "zone": [(310, 720, 410, 840, 68), (320, 860, 320, 950, 28), (430, 620, 470, 660, 28)],
               "prio": 3, "depth": 4},
    "head":   {"parent": "chest", "pivot": (615, 445), "zone": [(520, 160, 690, 320, 165)], "prio": 1.4, "depth": 3},
    "flap_l": {"parent": "head",  "pivot": (430, 270), "zone": [(390, 320, 230, 470, 60)], "prio": 2.5, "depth": 1.5},
    "flap_l2": {"parent": "flap_l", "pivot": (250, 440), "zone": [(225, 480, 140, 620, 48)], "prio": 3, "depth": 1.5},
    "flap_r": {"parent": "head",  "pivot": (800, 300), "zone": [(835, 350, 930, 450, 55)], "prio": 2.5, "depth": 1.5},
    "flap_r2": {"parent": "flap_r", "pivot": (930, 440), "zone": [(955, 470, 1000, 615, 40)], "prio": 3, "depth": 1.5},
    # Tay và đũa nằm ở lớp riêng (cắt cứng theo HAND_ZONE / WAND_ZONE), không ảnh hưởng lớp nền.
    "hands":  {"parent": "chest", "pivot": (640, 470), "zone": [], "prio": 0, "depth": 10},
    "wand":   {"parent": "hands", "pivot": (712, 560), "zone": [], "prio": 0, "depth": 10},
}
SOFT = 22.0  # độ mềm mép vùng (px ảnh gốc)
# Lớp trên: hai bàn tay ôm đũa và cây đũa (đè trước mặt nên phải tách để xoay không kéo lem mặt).
HAND_ZONE = [(700, 520, 735, 578, 40)]
WAND_ZONE = [(690, 690, 755, 400, 13), (765, 318, 765, 385, 26), (775, 300, 790, 296, 8)]
# Lớp trên: hai bàn tay ôm đũa và cây đũa (đè trước mặt nên phải tách để xoay không kéo lem mặt).
HAND_ZONE = [(700, 520, 735, 578, 40)]
WAND_ZONE = [(690, 690, 755, 400, 13), (765, 318, 765, 385, 26), (775, 300, 790, 296, 8)]


def split_arms(pose):
    """"arms" trong tư thế = vẩy cổ tay: tay xoay ít + dời, đũa xoay nhiều quanh chỗ cầm."""
    pose = dict(pose)
    arms = pose.pop("arms", None)
    if arms:
        pose["hands"] = {"rot": arms.get("rot", 0) * 0.2, "dx": arms.get("dx", 0), "dy": arms.get("dy", 0)}
        pose["wand"] = {"rot": arms.get("rot", 0) * 0.8}
    return pose


def sway(i, n, amp=1.0, speed=1.0):
    """Vạt tai mũ, bình nước đung đưa nhẹ theo nhịp (phần phụ, cộng thêm vào mọi Action)."""
    p = math.tau * i / n * speed
    return {"flap_l": {"rot": 3.5 * amp * math.sin(p + 0.8)}, "flap_l2": {"rot": 5 * amp * math.sin(p + 1.7)},
            "flap_r": {"rot": -3.5 * amp * math.sin(p + 0.8)}, "flap_r2": {"rot": -5 * amp * math.sin(p + 1.7)},
            "flask": {"rot": 4 * amp * math.sin(p + 0.5)}}


def pose_idle(i, n):
    p = math.tau * i / n
    look = -2.5 if i in (3, 4) else 0.0  # thỉnh thoảng liếc sang đồng đội
    base = {"chest": {"sy": 1 + 0.014 * math.sin(p)}, "hips": {"sy": 1 - 0.006 * math.sin(p)},
            "head": {"dy": -3 * math.sin(p), "rot": 1.2 * math.sin(p) + look},
            "arms": {"dy": -2 * math.sin(p), "rot": 1.5 * math.sin(p)}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"arms": {"rot": 30, "dx": 10}, "chest": {"rot": -4}, "head": {"rot": -5}, "hips": {"dx": -6}}),  # chĩa đũa, nheo
        (3, {"arms": {"rot": 46, "dx": 22}, "chest": {"rot": 3}, "head": {"rot": 1}, "hips": {"dx": 6}}),
        (4, {"arms": {"rot": 58, "dx": 30, "dy": 6}, "chest": {"rot": 6}, "head": {"rot": 3}, "hips": {"dx": 10}}),  # vẩy đũa (trúng)
        (5, {"arms": {"rot": 28, "dx": 8}, "chest": {"rot": -6}, "head": {"rot": -7}, "hips": {"dx": -10},  # giật mình
             "flap_l": {"rot": -10}, "flap_r": {"rot": 10}}),
        (6, {"arms": {"rot": 8}, "chest": {"rot": -1}, "head": {"rot": -3},                                  # chỉnh mũ
             "flap_r": {"rot": -8}, "flap_l": {"rot": 5}}),
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.6))


def pose_skill(i, n):
    keys = [
        (0, {}),
        (2, {"flask": {"rot": -16, "dy": -10, "dx": 6}, "chest": {"rot": -2}, "head": {"rot": 3}}),  # mở nắp bình
        (3, {"flask": {"rot": -20, "dy": -14, "dx": 8}, "arms": {"rot": -12}, "chest": {"rot": -3}, "head": {"rot": 4}}),
        (4, {"flask": {"rot": -12, "dy": -8}, "arms": {"rot": -18}, "chest": {"rot": -4}}),          # lấy đà
        (6, {"flask": {"rot": 4}, "arms": {"rot": 30}, "chest": {"rot": 5}, "hips": {"dx": 5},       # vung tay (trúng)
             "head": {"rot": 2}}),
        (8, {"arms": {"rot": 6}, "chest": {"rot": 1}, "head": {"rot": 5}}),                           # mỉm cười
        (9, {"head": {"rot": 2}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.7))


def pose_ultimate(i, n):
    up = {"flap_l": {"rot": 22}, "flap_l2": {"rot": 14}, "flap_r": {"rot": -22}, "flap_r2": {"rot": -14}}
    keys = [
        (0, {}),
        (2, {"root": {"sy": 0.95}, "flask": {"rot": -28, "dy": -24, "dx": 10}, "chest": {"rot": 3}}),  # lấy đà tung bình
        (3, {"root": {"sy": 1.03}, "flask": {"rot": -6, "dy": -6}, "arms": {"rot": -16}, "chest": {"rot": -3},
             "head": {"rot": -5}, **{k: {"rot": v["rot"] * 0.6} for k, v in up.items()}}),
        (5, {"arms": {"rot": -22, "dy": -10}, "chest": {"rot": -2}, "head": {"rot": -8}, **up}),       # chắp tay cầu nguyện
        (8, {"root": {"sy": 1.02}, "arms": {"rot": -24, "dy": -12}, "chest": {"rot": -5}, "head": {"rot": -11},
             "flap_l": {"rot": 26}, "flap_l2": {"rot": 18}, "flap_r": {"rot": -26}, "flap_r2": {"rot": -18}}),
        (10, {"arms": {"rot": 8}, "chest": {"rot": -6}, "head": {"rot": -10}, **up}),                  # đón mưa
        (11, {"arms": {"rot": 8}, "chest": {"rot": -6}, "head": {"rot": -10}, **up}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.5, 2))


def pose_hit(i, n):
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -8}, "hips": {"dx": -12}, "arms": {"rot": -6},
             "flap_l": {"rot": -10}, "flap_r": {"rot": 12}, "flap_l2": {"rot": -8}, "flap_r2": {"rot": 8}}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -9}, "hips": {"dx": -16}, "arms": {"rot": -8},
             "flap_l": {"rot": -12}, "flap_r": {"rot": 14}}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.9}, "chest": {"rot": 4}, "head": {"rot": 8}, "arms": {"rot": 10}}),     # khuỵu xuống
        (2, {"root": {"sy": 0.84, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10},
             "arms": {"rot": 14}, "leg_l": {"rot": 10}, "leg_r": {"rot": -6}}),
        (4, {"root": {"sy": 0.84, "rot": -72, "dx": 470, "dy": -250}, "chest": {"rot": 6}, "head": {"rot": 14},
             "arms": {"rot": 16}, "flap_l": {"rot": 20}, "flap_r": {"rot": 30}}),
        (5, {"root": {"sy": 0.84, "rot": -84, "dx": 520, "dy": -310}, "chest": {"rot": 4}, "head": {"rot": 12},
             "arms": {"rot": 12}, "flap_l": {"rot": 30}, "flap_r": {"rot": 40}, "flap_l2": {"rot": 10},
             "flap_r2": {"rot": 16}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    p = math.tau * i / n
    bow = max(0.0, math.sin(math.pi * (i - 2) / 4)) if 2 <= i <= 6 else 0.0  # cúi chào nhỏ ở giữa vòng
    base = {"root": {"sy": 1 - 0.025 * abs(math.sin(p)), "dy": 0},
            "hips": {"dy": -4 * abs(math.sin(p))},
            "chest": {"rot": 9 * bow, "sy": 1 + 0.02 * math.sin(p)},       # thở phào
            "head": {"rot": 7 * bow}, "arms": {"rot": -6 + 4 * bow},       # ôm đũa sát người
            "flask": {"rot": -8 * bow}}
    return add(base, sway(i, n, 1.3))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}


run({"id": "mira", "bones": BONES, "top": [("hands", HAND_ZONE), ("wand", WAND_ZONE)],
     "pose_filter": split_arms, "poses": POSES})

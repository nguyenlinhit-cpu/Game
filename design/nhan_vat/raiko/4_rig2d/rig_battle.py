"""Sprite trận của Raiko bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/raiko/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/raiko/4_rig2d/rig_battle.py -- --only idle,attack

Bước làm sạch: tóc và áo trắng tinh, nên chỉ cho white_holes khoét nền lọt giữa cung, dây cung và tay (tìm bằng
loang từ SEEDS); trắng tinh còn lại hạ xuống 0.95 (ghi ra 4_rig2d/1a_clean.png).

Xuất 5_render/battle_raiko.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, load_rgba, neighbours, run, save_png  # noqa: E402

HERE = Path(__file__).resolve().parent

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn, đang kéo cung hết cỡ: tay trái (bên phải ảnh) duỗi cầm cung dài cao hơn người, tay phải kéo
# tên sát má; đuôi ngựa dài buộc cao bay sang trái (ngọn tóc hình tia sét), áo choàng rách phía sau.
BONES = {
    "root":     {"parent": None,     "pivot": (780, 975), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":    {"parent": "root",   "pivot": (720, 700),
                 "zone": [(705, 760, 645, 880, 50), (620, 935, 625, 960, 52)], "prio": 1, "depth": 1},
    "leg_r":    {"parent": "root",   "pivot": (860, 700),
                 "zone": [(870, 760, 915, 880, 48), (930, 935, 940, 960, 52)], "prio": 1, "depth": 1},
    "hips":     {"parent": "root",   "pivot": (780, 640), "zone": [(720, 630, 860, 665, 70)], "prio": 1, "depth": 1.2},
    "cape":     {"parent": "hips",   "pivot": (650, 560),
                 "zone": [(570, 680, 470, 790, 60), (780, 790, 790, 860, 40)], "prio": 2, "depth": 0.8},
    "chest":    {"parent": "hips",   "pivot": (780, 630), "zone": [(780, 520, 790, 590, 90)], "prio": 1.2, "depth": 2},
    "head":     {"parent": "chest",  "pivot": (770, 450),
                 "zone": [(770, 290, 800, 330, 165), (690, 110, 720, 140, 75)], "prio": 1.4, "depth": 3},
    "tail1":    {"parent": "head",   "pivot": (620, 175), "zone": [(570, 160, 480, 190, 60)], "prio": 2.6, "depth": 2.7},
    "tail2":    {"parent": "tail1",  "pivot": (470, 220), "zone": [(445, 290, 420, 400, 72)], "prio": 2.8, "depth": 2.7},
    "tail3":    {"parent": "tail2",  "pivot": (420, 420), "zone": [(400, 480, 385, 580, 70)], "prio": 3, "depth": 2.7},
    "tail4":    {"parent": "tail3",  "pivot": (385, 600), "zone": [(375, 650, 365, 745, 55)], "prio": 3.2, "depth": 2.7},
    "arm_draw": {"parent": "chest",  "pivot": (620, 515), "zone": [(650, 490, 740, 482, 46)], "prio": 2.4, "depth": 3.4},
    "arm_bow":  {"parent": "chest",  "pivot": (850, 510), "zone": [(880, 500, 1040, 486, 34)], "prio": 2.2, "depth": 3.2},
    # Lớp trên trọng số cứng: mũi tên (thu về ≈ 0 khi đã buông, tên bay vẽ ở 6_vfx/) và cung (cả tay cầm).
    "arrow":    {"parent": "arm_bow", "pivot": (640, 465), "zone": [], "prio": 0, "depth": 10},
    "bow":      {"parent": "arm_bow", "pivot": (1090, 485), "zone": [], "prio": 0, "depth": 11},
}
ARROW_ZONE = [(560, 466, 1050, 443, 15), (1128, 438, 1292, 436, 24), (560, 455, 655, 470, 34)]
BOW_PTS = [(985, 12), (998, 90), (1060, 200), (1112, 300), (1122, 400), (1100, 485), (1102, 560), (1135, 700),
           (1095, 800), (1005, 880), (990, 955)]
BOW_ZONE = [(ax, ay, bx, by, 58) for (ax, ay), (bx, by) in zip(BOW_PTS, BOW_PTS[1:])] + [(1085, 485, 1085, 485, 48)]

# Hạt giống loang tìm nền lọt (trắng/xám nhạt ≥ 0.88) giữa dây cung, thân cung, mặt và tay; loang dừng ở nét viền
# và dây cung nên không ăn vào tóc trắng.
SEEDS = [(960, 180), (1040, 300), (930, 380), (1060, 650), (960, 620), (1000, 470)]
CLEAN = "1a_clean.png"


def clean_concept():
    """Nền lọt tìm bằng loang từ SEEDS → tô trắng tinh (white_holes khoét); trắng tinh còn lại (tóc, áo) hạ 0.95."""
    a = load_rgba(HERE.parent / "1_concept" / "1a_battle.png")
    light = a[..., :3].min(axis=2) > 0.88
    pocket = np.zeros_like(light)
    for x, y in SEEDS:
        pocket[y, x] = light[y, x]
    while True:
        grown = neighbours(pocket) & light
        if (grown == pocket).all():
            break
        pocket = grown
    glare = ~pocket & (a[..., :3].min(axis=2) > 0.96)
    a[glare, :3] = 0.95
    a[pocket, :3] = 1.0
    a[..., 3] = 1.0
    save_png(HERE / CLEAN, a)


HIDE = {"sx": 0.01, "sy": 0.01}  # tên đã bắn: thu về điểm cầm


def sway(i, n, amp=1.0, speed=1.0):
    """Đuôi ngựa đung đưa (trễ dần về ngọn), áo choàng bay."""
    p = math.tau * i / n * speed
    out = {"cape": {"rot": 2.5 * amp * math.sin(p + 0.9)}}
    for j, name in enumerate(("tail1", "tail2", "tail3", "tail4")):
        out[name] = {"rot": (2 + 1.5 * j) * amp * math.sin(p + 0.4 + 0.7 * j)}
    return out


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.01 * math.sin(p)}, "head": {"rot": 1 * math.sin(p + 0.3)},
            "arm_bow": {"rot": 1.2 * math.sin(p)}, "arm_draw": {"dx": 2 * math.sin(p)}, "hips": {"dx": 3 * math.sin(p)}}
    return add(base, sway(i, n, 1.2))


def pose_attack(i, n):
    keys = [
        (0, {"arm_draw": {"dx": 60, "dy": 4}, "arrow": {"dx": 40}}),                       # lắp tên
        (2, {"arm_draw": {"dx": -6}, "head": {"rot": 1}}),                                  # kéo căng
        (3, {"arm_draw": {"dx": -40, "dy": -10, "rot": -14}, "arrow": HIDE, "bow": {"rot": 4},  # buông
             "arm_bow": {"rot": -3}, "head": {"rot": -2}, "tail1": {"rot": -6}}),
        (4, {"arm_draw": {"dx": -46, "dy": -14, "rot": -18}, "arrow": HIDE, "bow": {"rot": 2},  # (trúng)
             "arm_bow": {"rot": -2}, "head": {"rot": -2}}),
        (6, {"arm_draw": {"dx": -10, "dy": 30, "rot": 10}, "arrow": HIDE, "arm_bow": {"rot": 16},  # hạ cung
             "bow": {"rot": 6}}),
        (7, {"arm_draw": {"dx": 0, "dy": 24, "rot": 6}, "arrow": HIDE, "arm_bow": {"rot": 12}, "bow": {"rot": 4}}),
    ]
    pose = add(lerp_keys(keys, i), sway(i, n, 0.8))
    if 3 <= i:
        pose["arrow"] = {**pose.get("arrow", {}), **HIDE}
    return pose


def pose_skill(i, n):
    keys = [
        (0, {"arrow": HIDE, "arm_draw": {"dx": -60, "dy": 60, "rot": 20}, "head": {"rot": 3}}),   # rút tên khắc
        (2, {"arrow": {"dx": 40, "dy": -10}, "arm_draw": {"dx": 50, "dy": 0}, "head": {"rot": 2}}),  # tên sáng ký hiệu
        (3, {"arrow": {"dx": 40}, "arm_draw": {"dx": 50}}),
        (5, {"arm_draw": {"dx": -10}, "head": {"rot": 1}, "chest": {"rot": -1}}),                   # kéo căng
        (6, {"arm_draw": {"dx": -44, "dy": -12, "rot": -16}, "arrow": HIDE, "bow": {"rot": 3}}),   # bắn (trúng)
        (8, {"arm_draw": {"dx": 140, "dy": -14, "rot": -4}, "arrow": HIDE, "arm_bow": {"rot": 22},  # chỉ tay vào quái
             "bow": {"rot": 8}, "head": {"rot": 2}}),
        (9, {"arm_draw": {"dx": 140, "dy": -14, "rot": -4}, "arrow": HIDE, "arm_bow": {"rot": 22}, "bow": {"rot": 8}}),
    ]
    pose = add(lerp_keys(keys, i), sway(i, n, 0.8))
    if i in (0, 1) or i >= 6:
        pose["arrow"] = {**pose.get("arrow", {}), **HIDE}
    return pose


def pose_ultimate(i, n):
    aim = {"chest": {"rot": -22}, "arm_bow": {"rot": -28}, "arm_draw": {"dx": 10, "dy": 120, "rot": 20},
           "head": {"rot": 12}, "hips": {"dx": -14}, "root": {"sy": 1.02}}  # ngả người, cung chĩa chếch lên trời
    keys = [
        (0, {}),
        (3, aim),                                                                         # chĩa cung lên trời
        (5, {**aim, "arm_draw": {"dx": -6, "dy": 116, "rot": 18}}),                        # kéo căng
        (6, {**aim, "arm_draw": {"dx": -40, "dy": 100, "rot": 6}, "arrow": HIDE}),          # buông
        (9, {**aim, "arm_draw": {"dx": -40, "dy": 100, "rot": 6}, "arrow": HIDE,
             "tail1": {"rot": -14}, "tail2": {"rot": -10}}),
        (10, {"arrow": HIDE, "arm_bow": {"rot": 14}, "bow": {"rot": 6}, "arm_draw": {"dy": 30, "rot": 8},  # hạ cung
              "tail1": {"rot": -16}, "tail2": {"rot": -12}, "tail3": {"rot": -8}}),          # tóc còn dựng vì điện
        (11, {"arrow": HIDE, "arm_bow": {"rot": 14}, "bow": {"rot": 6}, "arm_draw": {"dy": 30, "rot": 8},
              "tail1": {"rot": -16}, "tail2": {"rot": -12}, "tail3": {"rot": -8}}),
    ]
    pose = add(lerp_keys(keys, i), sway(i, n, 0.7, 2))
    if i >= 6:
        pose["arrow"] = {**pose.get("arrow", {}), **HIDE}
    return pose


def pose_hit(i, n):
    fly = {"tail1": {"rot": 10}, "tail2": {"rot": 10}, "tail3": {"rot": 12}, "cape": {"rot": 8}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "arm_bow": {"rot": 10},
             "arm_draw": {"dx": 20, "dy": 20}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "arm_bow": {"rot": 12},
             "arm_draw": {"dx": 24, "dy": 24}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}, "arrow": HIDE}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "arrow": HIDE,
             "arm_bow": {"rot": 30}}),
        (2, {"root": {"sy": 0.86, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10}, "arrow": HIDE,
             "arm_bow": {"rot": 50}, "arm_draw": {"dy": 40}}),
        (4, {"root": {"sy": 0.86, "rot": -72, "dx": 440, "dy": -230}, "chest": {"rot": 6}, "head": {"rot": 12},
             "arrow": HIDE, "arm_bow": {"rot": 70}, "tail1": {"rot": 20}}),
        (5, {"root": {"sy": 0.86, "rot": -84, "dx": 490, "dy": -290}, "chest": {"rot": 4}, "head": {"rot": 10},
             "arrow": HIDE, "arm_bow": {"rot": 76}, "tail1": {"rot": 26}, "tail2": {"rot": 10}}),
    ]
    pose = lerp_keys(keys, i)
    pose["arrow"] = {**pose.get("arrow", {}), **HIDE}
    return pose


def pose_victory(i, n):
    """Xoay cung một vòng trên tay (lặp), tay kéo thả lỏng, gió thổi tóc."""
    base = {"arrow": HIDE, "bow": {"rot": 360 * i / n}, "arm_bow": {"rot": 18}, "arm_draw": {"dx": 40, "dy": 50, "rot": 12},
            "head": {"rot": 2}}
    return add(base, sway(i, n, 1.6, 2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "raiko", "concept": f"../4_rig2d/{CLEAN}", "bones": BONES, "top": [("arrow", ARROW_ZONE), ("bow", BOW_ZONE)], "poses": POSES,
          "shadow_below": 960, "white_holes": 30,  # bóng đổ xám dưới chân; nền trắng lọt giữa tóc, cung và dây
          "char_h": 360}  # cung cao hơn người: thu nhỏ để chĩa lên trời không ra khung

if __name__ == "__main__":
    clean_concept()
    run(CONFIG)

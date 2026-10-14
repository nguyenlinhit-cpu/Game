"""Sprite trận của Vesper bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/vesper/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/vesper/4_rig2d/rig_battle.py -- --only idle,attack

Bước làm sạch (ghi ra 4_rig2d/1a_clean.png): nền lọt giữa tóc và vạt áo rách là trắng tuyệt đối (≥ 0.995); lấy các vùng
đó làm hạt, loang tới nét viền rồi tô trắng tinh cho white_holes khoét; trắng còn lại (cổ áo, váy lót) hạ xuống 0.95.
Độc vẽ sẵn bắn trên chén và giọt độc ở kim bị xoá (hiệu ứng làm riêng ở 6_vfx/).

Xuất 5_render/battle_vesper.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import _components, add, lerp_keys, load_rgba, neighbours, run, save_png, zone_mask  # noqa: E402

HERE = Path(__file__).resolve().parent

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng thẳng, tay trái (bên phải ảnh) nâng chén vàng chứa độc, tay phải (bên trái ảnh) kẹp kim độc;
# mũ nhọn rộng vành, kính tròn, tóc dài đỏ tím bên trái, áo choàng rách tà nhọn hai bên.
BONES = {
    "root":       {"parent": None,         "pivot": (800, 1000), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":      {"parent": "root",       "pivot": (760, 720), "zone": [(755, 760, 745, 960, 40)], "prio": 1,
                   "depth": 1},
    "leg_r":      {"parent": "root",       "pivot": (830, 720), "zone": [(830, 760, 845, 960, 42)], "prio": 1,
                   "depth": 1},
    "hips":       {"parent": "root",       "pivot": (790, 640), "zone": [(720, 620, 880, 680, 75)], "prio": 1,
                   "depth": 1.2},
    "cape3":      {"parent": "hips",       "pivot": (620, 700), "zone": [(520, 790, 400, 880, 75)], "prio": 2,
                   "depth": 0.8},
    "chest":      {"parent": "hips",       "pivot": (790, 620), "zone": [(790, 470, 800, 560, 85)], "prio": 1.2,
                   "depth": 2},
    "cape1":      {"parent": "chest",      "pivot": (940, 480), "zone": [(1040, 590, 1230, 680, 70)], "prio": 2,
                   "depth": 0.8},
    "cape2":      {"parent": "cape1",      "pivot": (1210, 690),
                   "zone": [(1260, 770, 1320, 860, 60), (1100, 880, 1150, 960, 50)], "prio": 2.3, "depth": 0.8},
    "head":       {"parent": "chest",      "pivot": (800, 430),
                   "zone": [(790, 290, 820, 330, 150), (570, 60, 600, 170, 75), (700, 110, 950, 110, 90)],
                   "prio": 1.4, "depth": 3},
    "hair":       {"parent": "head",       "pivot": (560, 470), "zone": [(450, 560, 330, 720, 95)], "prio": 2.2,
                   "depth": 2.6},
    "brim_l":     {"parent": "head",       "pivot": (560, 260), "zone": [(450, 300, 270, 360, 55)], "prio": 2.6,
                   "depth": 3.1},
    "brim_r":     {"parent": "head",       "pivot": (980, 140), "zone": [(1060, 80, 1190, 40, 55)], "prio": 2.6,
                   "depth": 3.1},
    "arm_cup":    {"parent": "chest",      "pivot": (930, 455), "zone": [(975, 445, 1040, 410, 42)], "prio": 2.2,
                   "depth": 3.2},
    "arm_needle": {"parent": "chest",      "pivot": (700, 500), "zone": [(660, 555, 620, 575, 40)], "prio": 2.2,
                   "depth": 3.2},
    # Lớp trên trọng số cứng: chén (kèm bàn tay cầm, mặt dây) và bó kim (kèm bàn tay kẹp).
    "cup":        {"parent": "arm_cup",    "pivot": (1080, 400), "zone": [], "prio": 0, "depth": 11},
    "needles":    {"parent": "arm_needle", "pivot": (590, 575), "zone": [], "prio": 0, "depth": 10},
}
CUP_ZONE = [(1020, 255, 1200, 255, 34), (1035, 300, 1185, 300, 42), (1090, 350, 1110, 460, 34),
            (1060, 455, 1140, 460, 22), (1100, 480, 1100, 515, 18), (1045, 380, 1110, 400, 38)]
NEEDLE_ZONE = [(455, 600, 565, 515, 14), (470, 605, 580, 535, 14), (570, 570, 620, 585, 38)]
# Độc vẽ sẵn bắn lên trên chén và giọt độc ở kim (hiệu ứng làm riêng ở 6_vfx/): xoá theo màu xanh độc sáng trong
# SPLASH_AREA, trừ lòng chén.
SPLASH_AREA = ([(1000, y, 1265, y, 8) for y in range(60, 236, 12)]  # trên miệng chén
               + [(1215, 235, 1255, 420, 32), (1175, 330, 1215, 410, 30), (440, 600, 520, 700, 35)])
CLEAN = "1a_clean.png"


def clean_concept():
    a = load_rgba(HERE.parent / "1_concept" / "1a_battle.png")
    mn = a[..., :3].min(axis=2)
    strict = mn > 0.995
    bg = np.zeros_like(strict)
    bg[0, :] = bg[-1, :] = bg[:, 0] = bg[:, -1] = True
    bg &= strict
    while True:
        grown = neighbours(bg) & strict
        if (grown == bg).all():
            break
        bg = grown
    pocket = _components(strict & ~bg, 40)
    light = mn > 0.97
    for _ in range(6):
        pocket = neighbours(pocket) & light | pocket
    rgb = a[..., :3]
    green = (rgb[..., 1] - rgb[..., 0] > 0.04) & (rgb[..., 1] - rgb[..., 2] > 0.3) & (rgb[..., 1] > 0.5)
    halo = (rgb[..., 1] - rgb[..., 2] > 0.08) & (rgb[..., 1] >= rgb[..., 0])  # viền/quầng xanh quanh độc
    splash = (green | halo) & zone_mask(a.shape[:2], SPLASH_AREA) 
    for _ in range(3):
        splash = neighbours(splash) & ~zone_mask(a.shape[:2], CUP_ZONE) & (zone_mask(a.shape[:2], SPLASH_AREA)) \
            & ((mn > 0.5) | green) | splash
    a[splash, :3] = 1.0
    a[~pocket & ~splash & (mn > 0.96), :3] = 0.95
    a[pocket, :3] = 1.0
    a[..., 3] = 1.0
    save_png(HERE / CLEAN, a)


HIDE = {"sx": 0.01, "sy": 0.01}


def sway(i, n, amp=1.0, speed=1.0):
    """Vạt áo choàng và tóc khẽ bay, vành mũ rung nhẹ."""
    p = math.tau * i / n * speed
    return {"cape1": {"rot": -2 * amp * math.sin(p + 0.6)}, "cape2": {"rot": -3 * amp * math.sin(p + 1.3)},
            "cape3": {"rot": 2.5 * amp * math.sin(p + 0.9)}, "hair": {"rot": 2 * amp * math.sin(p + 0.4)},
            "brim_l": {"rot": 1.5 * amp * math.sin(p + 0.2)}, "brim_r": {"rot": -1.2 * amp * math.sin(p + 0.7)}}


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"cup": {"rot": 6 * math.sin(p * 2)}, "arm_cup": {"rot": 1.5 * math.sin(p)},  # lắc chén nhẹ
            "chest": {"sy": 1 + 0.01 * math.sin(p)}, "head": {"rot": 1 * math.sin(p + 0.5)},
            "needles": {"rot": 3 * math.sin(p)}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"arm_needle": {"rot": 22}, "needles": {"rot": 20}, "chest": {"rot": -3}, "head": {"rot": -2}}),  # kẹp kim
        (3, {"arm_needle": {"rot": -40, "dx": 40, "dy": -30}, "needles": {"rot": -30}, "chest": {"rot": 4},  # phóng
             "hips": {"dx": 10}}),
        (4, {"arm_needle": {"rot": -48, "dx": 50, "dy": -36}, "needles": HIDE, "chest": {"rot": 5},
             "hips": {"dx": 12}}),
        (6, {"arm_needle": {"rot": -78, "dx": 60, "dy": -160}, "needles": HIDE, "head": {"rot": 3}}),        # chỉnh kính
        (7, {"arm_needle": {"rot": -20, "dy": -40}, "needles": HIDE}),
    ]
    pose = add(lerp_keys(keys, i), sway(i, n, 0.8))
    if i >= 4:
        pose["needles"] = {**pose.get("needles", {}), **HIDE}
    return pose


def pose_skill(i, n):
    face = {"cup": {"dx": -150, "dy": 40, "rot": -8}, "arm_cup": {"rot": 10}, "head": {"rot": 2}}  # chén ngang mặt
    keys = [
        (0, {}),
        (3, face),
        (4, {**face, "cup": {"dx": -140, "dy": 30, "rot": -18}}),
        (6, {"cup": {"dx": 20, "dy": -20, "rot": 55}, "arm_cup": {"rot": -12}, "chest": {"rot": 4},  # hất chén
             "hips": {"dx": 10}}),
        (7, {"cup": {"rot": 30}, "arm_cup": {"rot": -6}}),
        (8, {"cup": {"rot": -10}}),                                                                 # lắc chén
        (9, {"cup": {"rot": 8}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_ultimate(i, n):
    if i <= 4:  # xoay áo choàng một vòng (lật ngang), vạt áo tung
        sx = [1.0, 0.4, -0.8, 0.4, 1.0][i]
        return add({"root": {"sx": sx}}, sway(i, n, 3.0, 2))
    keys = [
        (5, {}),
        (6, {"arm_needle": {"rot": -60, "dx": 30, "dy": -60}, "needles": HIDE, "head": {"rot": -2}}),  # búng tay
        (8, {"arm_needle": {"rot": -66, "dx": 34, "dy": -70}, "needles": HIDE, "head": {"rot": -3}, "chest": {"rot": -2}}),
        (9, {"arm_needle": {"rot": -64, "dx": 34, "dy": -68}, "needles": HIDE, "head": {"rot": -3}}),
        (10, {"arm_needle": {"rot": -95, "dx": 80, "dy": -230}, "needles": HIDE, "head": {"rot": 3},  # chỉnh mũ
              "brim_l": {"rot": 5}, "brim_r": {"rot": -3}}),
        (11, {"arm_needle": {"rot": -95, "dx": 80, "dy": -230}, "needles": HIDE, "head": {"rot": 3},
              "brim_l": {"rot": 5}, "brim_r": {"rot": -3}}),
    ]
    pose = add(lerp_keys(keys, i), sway(i, n, 1.2, 2))
    if i >= 6:
        pose["needles"] = {**pose.get("needles", {}), **HIDE}
    return pose


def pose_hit(i, n):
    fly = {"cape1": {"rot": 8}, "cape2": {"rot": 10}, "cape3": {"rot": -8}, "hair": {"rot": -8}, "brim_r": {"rot": -6}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "cup": {"rot": -14},
             "arm_cup": {"rot": 8}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "cup": {"rot": -16},
             "arm_cup": {"rot": 10}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    """Khuỵu xuống rồi gục ngồi (áo choàng rộng: không ngã nằm), chén nghiêng đổ."""
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "cup": {"rot": 20}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 80}, "chest": {"rot": 14}, "head": {"rot": 16, "dy": 8},
             "cup": {"rot": 60, "dy": 120}, "arm_cup": {"rot": 40}, "arm_needle": {"rot": 30},
             "leg_l": {"rot": 20}, "leg_r": {"rot": -20}}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 110}, "chest": {"rot": 22}, "head": {"rot": 24, "dy": 14},
             "cup": {"rot": 90, "dy": 200, "dx": -20}, "arm_cup": {"rot": 55}, "arm_needle": {"rot": 40},
             "leg_l": {"rot": 28}, "leg_r": {"rot": -28}, "brim_l": {"rot": 8}, "brim_r": {"rot": 6}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Đưa chén lên môi nhấp một ngụm, hạ xuống, mỉm cười (mặt giữ từ concept)."""
    sip = {"cup": {"dx": -205, "dy": 30, "rot": -42}, "arm_cup": {"rot": 14}, "head": {"rot": -4}}
    keys = [(0, {}), (2, sip), (4, {**sip, "head": {"rot": -6}}), (6, {"head": {"rot": 2}}), (7, {})]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "vesper", "concept": f"../4_rig2d/{CLEAN}", "bones": BONES,
          "top": [("needles", NEEDLE_ZONE), ("cup", CUP_ZONE)], "poses": POSES,
          "white_holes": 30, "char_h": 360, "foot_x": 805}  # áo choàng + mũ rất rộng: thu nhỏ, đặt giữa khung

if __name__ == "__main__":
    clean_concept()
    run(CONFIG)

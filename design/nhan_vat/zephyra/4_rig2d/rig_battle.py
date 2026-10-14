"""Sprite trận của Zephyra bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/zephyra/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/zephyra/4_rig2d/rig_battle.py -- --only idle,attack

Bước làm sạch (ghi ra 4_rig2d/1a_clean.png): nền lọt giữa tóc, dải lụa và quạt là trắng tinh tuyệt đối (≥ 0.995),
còn áo/lụa trắng không bao giờ trắng tới mức đó; lấy các vùng ≥ 0.995 bị bao kín làm hạt, loang ra tới nét viền rồi tô
trắng tinh cho white_holes khoét; trắng còn lại hạ xuống 0.95 để giữ nguyên.

Xuất 5_render/battle_zephyra.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import _components, add, lerp_keys, load_rgba, neighbours, run, save_png  # noqa: E402

HERE = Path(__file__).resolve().parent

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: múa trên một chân (chân phải trụ, chân trái co), tay trái (bên phải ảnh) duỗi cầm quạt bán nguyệt mở,
# tay phải đưa ra sau; tóc dài và hai dải lụa có tua bay dạt sang hai bên.
BONES = {
    "root":     {"parent": None,      "pivot": (790, 1000), "zone": [], "prio": 0.03, "depth": 0},
    "leg_st":   {"parent": "root",    "pivot": (790, 760), "zone": [(790, 790, 800, 960, 45)], "prio": 1, "depth": 1},
    "leg_bt":   {"parent": "root",    "pivot": (740, 700), "zone": [(735, 725, 705, 780, 42)], "prio": 1, "depth": 1.1},
    "hips":     {"parent": "root",    "pivot": (800, 620), "zone": [(760, 610, 850, 640, 75)], "prio": 1, "depth": 1.2},
    "skirt":    {"parent": "hips",    "pivot": (840, 650), "zone": [(780, 770, 960, 830, 90)], "prio": 1.6, "depth": 1.3},
    "chest":    {"parent": "hips",    "pivot": (810, 580), "zone": [(840, 420, 850, 520, 80)], "prio": 1.2, "depth": 2},
    "head":     {"parent": "chest",   "pivot": (800, 410),
                 "zone": [(770, 250, 790, 300, 165), (650, 80, 700, 90, 80)], "prio": 1.4, "depth": 3},
    "hair1":    {"parent": "head",    "pivot": (620, 280), "zone": [(520, 250, 300, 230, 55)], "prio": 2.4, "depth": 2.6},
    "hair2":    {"parent": "head",    "pivot": (630, 390), "zone": [(530, 420, 400, 470, 62)], "prio": 2.4, "depth": 2.6},
    "hair3":    {"parent": "head",    "pivot": (620, 520), "zone": [(530, 600, 440, 700, 60)], "prio": 2.4, "depth": 2.6},
    "arm_back": {"parent": "chest",   "pivot": (760, 445), "zone": [(700, 452, 600, 452, 34)], "prio": 2.2, "depth": 2.8},
    "arm_fan":  {"parent": "chest",   "pivot": (905, 425), "zone": [(960, 420, 1130, 402, 40)], "prio": 2.2, "depth": 3.2},
    # Dải lụa trái 3 xương (dải trên bay ra mép trái + dải dưới có tua), dải phải 3 xương.
    "sashL1":   {"parent": "chest",   "pivot": (600, 440),
                 "zone": [(480, 420, 300, 360, 55), (220, 330, 80, 380, 60), (50, 450, 50, 520, 45)], "prio": 2,
                 "depth": 0.7},
    "sashL2":   {"parent": "sashL1",  "pivot": (450, 520), "zone": [(400, 560, 220, 620, 60)], "prio": 2.2, "depth": 0.7},
    "sashL3":   {"parent": "sashL2",  "pivot": (230, 650), "zone": [(260, 720, 340, 830, 55)], "prio": 2.4, "depth": 0.7},
    "sashR1":   {"parent": "chest",   "pivot": (980, 560), "zone": [(1050, 600, 1200, 650, 60)], "prio": 2, "depth": 0.7},
    "sashR2":   {"parent": "sashR1",  "pivot": (1220, 660),
                 "zone": [(1300, 700, 1420, 780, 60), (1100, 850, 1250, 900, 55)], "prio": 2.2, "depth": 0.7},
    "sashR3":   {"parent": "sashR2",  "pivot": (1430, 800), "zone": [(1460, 860, 1490, 940, 50)], "prio": 2.4,
                 "depth": 0.7},
    # Lớp trên trọng số cứng: quạt (kèm bàn tay cầm và tua quạt).
    "fan":      {"parent": "arm_fan", "pivot": (1190, 405), "zone": [], "prio": 0, "depth": 10},
}


def poly_zone(pts, step=14, pad=-8):
    ys = [p[1] for p in pts]
    out = []
    for y in range(int(min(ys)), int(max(ys)) + 1, step):
        xs = []
        for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]):
            if ((ay <= y <= by) or (by <= y <= ay)) and ay != by:
                xs.append(ax + (bx - ax) * (y - ay) / (by - ay))
        if len(xs) >= 2:
            out.append((min(xs) + pad, y, max(xs) - pad, y, step // 2 + 4))
    return out


FAN_ZONE = (poly_zone([(1015, 245), (1100, 180), (1250, 168), (1400, 225), (1465, 330), (1475, 470), (1450, 565),
                       (1330, 515), (1215, 445), (1165, 425)])
            + [(1210, 430, 1215, 545, 32), (1460, 570, 1480, 670, 34), (1482, 495, 1498, 595, 28), (1165, 400, 1200, 400, 34)])
# Cánh hoa vẽ sẵn bay quanh nhân vật (hiệu ứng làm riêng ở 6_vfx/): xoá.
ERASE = [(70, 615, 105, 665, 30), (130, 705, 190, 745, 30), (1270, 525, 1330, 560, 28), (1355, 578, 1392, 618, 26),
         (235, 760, 250, 772, 16)]
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
    pocket = _components(strict & ~bg, 600)
    light = mn > 0.97
    for _ in range(6):  # loang ra tới nét viền (vùng hạt lốm đốm do nhiễu nén ảnh)
        pocket = neighbours(pocket) & light | pocket
    glare = ~pocket & (mn > 0.96)
    a[glare, :3] = 0.95
    a[pocket, :3] = 1.0
    a[..., 3] = 1.0
    save_png(HERE / CLEAN, a)


def sway(i, n, amp=1.0, speed=1.0):
    """Dải lụa và tóc bay (trễ dần về đuôi)."""
    p = math.tau * i / n * speed
    out = {"skirt": {"rot": 1.5 * amp * math.sin(p + 0.5)}}
    for j, name in enumerate(("hair1", "hair2", "hair3")):
        out[name] = {"rot": (2 + j) * amp * math.sin(p + 0.3 + 0.6 * j)}
    for side, sign in (("sashL", 1), ("sashR", -1)):
        for j in range(3):
            out[f"{side}{j + 1}"] = {"rot": sign * (2.5 + 1.5 * j) * amp * math.sin(p + 0.6 + 0.8 * j)}
    return out


def pose_idle(i, n):
    p = math.tau * i / n
    hop = abs(math.sin(p))  # nhún theo nhịp múa
    base = {"root": {"dy": -14 * hop}, "leg_bt": {"rot": 5 * math.sin(p)}, "head": {"rot": 2 * math.sin(p)},
            "fan": {"rot": 7 * math.sin(p * 2)}, "arm_fan": {"rot": 2 * math.sin(p)},
            "arm_back": {"rot": -4 * math.sin(p)}}
    return add(base, sway(i, n, 1.2, 2))


FOLD = {"fan": {"sx": 0.35, "sy": 0.9, "rot": -30}}  # quạt gập


def pose_attack(i, n):
    keys = [
        (0, {}),
        (1, {"fan": {"sx": 0.6, "rot": -18}}),
        (2, {**FOLD, "arm_fan": {"rot": -8}, "chest": {"rot": -3}, "head": {"rot": -2}}),   # gập quạt, xoay cổ tay
        (3, {"fan": {"sx": 1.08, "sy": 1.06, "rot": 14}, "arm_fan": {"rot": 6}, "chest": {"rot": 3},  # mở bung
             "hips": {"dx": 10}}),
        (4, {"fan": {"sx": 1.1, "sy": 1.08, "rot": 20}, "arm_fan": {"rot": 8}, "chest": {"rot": 4},   # phóng lưỡi gió
             "hips": {"dx": 14}, "head": {"rot": 2}}),
        (6, {"fan": {"rot": -8}, "arm_fan": {"rot": -2}}),                                          # phe phẩy về
        (7, {"fan": {"rot": 4}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


def pose_skill(i, n):
    if i <= 3:  # xoay một vòng: lật ngang dần (nhìn như xoay người), dải lụa cuộn
        sx = [1.0, 0.35, -0.85, 0.35][i]
        base = {"root": {"sx": sx, "dy": -10}, "leg_bt": {"rot": 10}}
        return add(base, sway(i, n, 2.2, 2))
    keys = [
        (4, {"root": {"dy": -6}}),
        (5, {"fan": {"rot": -12, "dx": 20}, "arm_fan": {"rot": -6}, "chest": {"rot": 3}}),         # chỉ quạt về đồng minh
        (6, {"fan": {"rot": -16, "dx": 30}, "arm_fan": {"rot": -8}, "chest": {"rot": 4}, "head": {"rot": 2}}),
        (8, {"chest": {"rot": 10}, "head": {"rot": 9}, "fan": {"rot": 10}, "arm_fan": {"rot": 10},   # cúi chào nhẹ
             "hips": {"dx": 6}}),
        (9, {"chest": {"rot": 6}, "head": {"rot": 5}, "fan": {"rot": 4}, "arm_fan": {"rot": 6}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


def pose_ultimate(i, n):
    keys = [
        (0, {}),
        (2, {"root": {"dy": -80}, "fan": {"rot": -20}, "arm_fan": {"rot": -10}, "leg_bt": {"rot": 14}}),  # múa quạt
        (4, {"root": {"dy": -200}, "fan": {"rot": 16}, "arm_fan": {"rot": 6}, "leg_st": {"rot": -8},     # bay lên
             "leg_bt": {"rot": 20}, "head": {"rot": -3}}),
        (5, {"root": {"dy": -230}, "fan": {"rot": -6}, "arm_fan": {"rot": -14}, "leg_st": {"rot": -10},
             "leg_bt": {"rot": 22}, "head": {"rot": -4}}),
        (7, {"root": {"dy": -230}, "fan": {"rot": 10, "sx": 1.35, "sy": 1.35}, "arm_fan": {"rot": -6},  # mở quạt thật to
             "chest": {"rot": -4}, "leg_st": {"rot": -10}, "leg_bt": {"rot": 22}}),
        (9, {"root": {"dy": -210}, "fan": {"rot": 14, "sx": 1.35, "sy": 1.35}, "arm_fan": {"rot": -4},
             "chest": {"rot": -4}, "leg_st": {"rot": -8}, "leg_bt": {"rot": 20}}),
        (10, {"root": {"dy": 0, "sy": 0.96}, "leg_bt": {"rot": 6}}),                                   # đáp xuống
        (11, {"root": {"dy": 0, "sy": 0.98}, "leg_bt": {"rot": 6}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.5, 2))


def pose_hit(i, n):
    fly = {"hair1": {"rot": -8}, "hair2": {"rot": -8}, "sashL1": {"rot": -8}, "sashR1": {"rot": 8}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "fan": {"rot": -14},
             "arm_fan": {"rot": 8}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "fan": {"rot": -16},
             "arm_fan": {"rot": 10}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    """Khuỵu xuống rồi gục ngồi (không ngã nằm: dải lụa quá rộng sẽ ra ngoài khung), quạt gập rơi xuống."""
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "fan": {**FOLD["fan"]},
             "arm_fan": {"rot": 30}}),
        (3, {"root": {"sy": 0.82}, "hips": {"dy": 90}, "chest": {"rot": 16}, "head": {"rot": 18, "dy": 10},
             "fan": {**FOLD["fan"], "dy": 120}, "arm_fan": {"rot": 55}, "arm_back": {"rot": -30},
             "leg_bt": {"rot": -30}, "sashL1": {"rot": 12}, "sashR1": {"rot": -12}}),
        (5, {"root": {"sy": 0.78}, "hips": {"dy": 120}, "chest": {"rot": 24}, "head": {"rot": 26, "dy": 16},
             "fan": {**FOLD["fan"], "dy": 150}, "arm_fan": {"rot": 62}, "arm_back": {"rot": -36},
             "leg_bt": {"rot": -40}, "sashL1": {"rot": 18}, "sashR1": {"rot": -18}, "hair1": {"rot": 10}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Gập quạt, đưa lên che nửa mặt dưới (lặp: lắc nhẹ, mắt cười giữ từ concept)."""
    p = math.tau * i / n
    cover = {"arm_fan": {"sx": 0.45, "rot": -10}, "fan": {"sx": 0.4, "sy": 0.75, "rot": -78, "dx": -470, "dy": -20},
             "head": {"rot": 3 + 2 * math.sin(p)}, "root": {"dy": -6 * abs(math.sin(p))}}
    keys = [(0, {}), (2, cover), (7, cover)]
    pose = lerp_keys(keys, min(i, 7))
    return add(pose, sway(i, n, 1.2, 2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "zephyra", "concept": f"../4_rig2d/{CLEAN}", "bones": BONES, "top": [("fan", FAN_ZONE)],
          "poses": POSES, "erase": ERASE, "white_holes": 30,
          "char_h": 300, "foot_x": 765}  # dải lụa + quạt dang rất rộng (x 20–1510): thu nhỏ và đặt giữa khung

if __name__ == "__main__":
    clean_concept()
    run(CONFIG)

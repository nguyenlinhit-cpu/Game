"""Sprite trận của Aldric bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/aldric/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/aldric/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_aldric.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1377×1142), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn rộng, tay trái (bên phải ảnh) đưa khiên buồm hình cánh diều lên trước người; áo choàng đỏ rách
# bay dạt sang trái; giáp thép, áo khoác trắng có hoa văn gió.
BONES = {
    "root":    {"parent": None,     "pivot": (680, 1100), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":   {"parent": "root",   "pivot": (520, 800), "zone": [(480, 840, 330, 1060, 70)], "prio": 1, "depth": 1},
    "leg_r":   {"parent": "root",   "pivot": (860, 800), "zone": [(900, 850, 980, 1050, 65)], "prio": 1, "depth": 1},
    "hips":    {"parent": "root",   "pivot": (690, 700), "zone": [(580, 680, 820, 720, 90), (650, 820, 720, 920, 60)],
                "prio": 1, "depth": 1.2},
    "chest":   {"parent": "hips",   "pivot": (690, 680), "zone": [(660, 500, 700, 580, 95)], "prio": 1.2, "depth": 2},
    "cape1":   {"parent": "chest",  "pivot": (540, 430), "zone": [(450, 440, 330, 470, 70)], "prio": 2, "depth": 0.8},
    "cape2":   {"parent": "cape1",  "pivot": (310, 470), "zone": [(230, 460, 100, 470, 70), (300, 560, 300, 650, 60)],
                "prio": 2.3, "depth": 0.8},
    "cape3":   {"parent": "cape2",  "pivot": (100, 480), "zone": [(60, 470, 40, 560, 45)], "prio": 2.6, "depth": 0.8},
    "head":    {"parent": "chest",  "pivot": (680, 390), "zone": [(670, 210, 690, 260, 165)], "prio": 1.4, "depth": 3},
    "arm":     {"parent": "chest",  "pivot": (760, 480), "zone": [(780, 500, 860, 490, 50)], "prio": 2, "depth": 3.2},
    # Lớp trên trọng số cứng: khiên buồm (cả khung thép, vải buồm) kèm nắm tay cầm.
    "shield":  {"parent": "arm",    "pivot": (920, 470), "zone": [], "prio": 0, "depth": 10},
}


def poly_zone(pts, step=14, pad=-16):
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


SHIELD_ZONE = poly_zone([(950, 170), (1100, 280), (1370, 405), (1290, 490), (1365, 640), (1320, 890), (1170, 1075),
                         (1140, 1060), (1010, 840), (930, 640), (905, 460), (950, 350)]) \
    + [(890, 400, 930, 420, 40)]  # nắm tay đeo găng sau khung khiên


def sway(i, n, amp=1.0, speed=1.0):
    """Áo choàng phấp phới (trễ dần về mép), buồm khiên phồng xẹp nhẹ (co giãn ngang)."""
    p = math.tau * i / n * speed
    return {"cape1": {"rot": 2 * amp * math.sin(p + 0.4)}, "cape2": {"rot": 3 * amp * math.sin(p + 1.1)},
            "cape3": {"rot": 4 * amp * math.sin(p + 1.8)}, "shield": {"sx": 1 + 0.02 * amp * math.sin(p * 2)}}


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.012 * math.sin(p)}, "head": {"rot": 1 * math.sin(p + 0.4)},
            "shield": {"dy": -4 * math.sin(p)}}
    return add(base, sway(i, n, 1.2))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"shield": {"dx": -60, "dy": 30, "rot": -6}, "arm": {"rot": 8}, "hips": {"dx": -16}, "chest": {"rot": -3}}),
        (3, {"shield": {"dx": 50, "rot": 4}, "hips": {"dx": 20}, "chest": {"rot": 4}}),
        (4, {"shield": {"dx": 90, "dy": -10, "rot": 6}, "hips": {"dx": 34}, "chest": {"rot": 6}, "head": {"rot": 2},
             "cape1": {"rot": -6}}),                                                   # đâm mép khiên (trúng)
        (6, {"shield": {"dx": 20}, "hips": {"dx": 6}}),
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_skill(i, n):
    high = {"shield": {"dy": -150, "dx": -30, "rot": -6, "sx": 1.08}, "arm": {"rot": -16}, "head": {"rot": -4},
            "chest": {"rot": -3}}
    keys = [
        (0, {}),
        (3, high),                                                                     # giương khiên buồm cao
        (5, {**high, "shield": {"dy": -120, "dx": 20, "rot": 6, "sx": 1.1}, "arm": {"rot": -6}}),
        (6, {**high, "shield": {"dy": -100, "dx": 40, "rot": 8, "sx": 1.1}, "arm": {"rot": -2}}),   # ném khiên gió
        (9, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


def pose_ultimate(i, n):
    plant = {"shield": {"dy": 60, "dx": -20, "sx": 1.18, "sy": 1.06}, "root": {"sy": 0.94}, "hips": {"dy": 20},
             "chest": {"rot": 4}, "head": {"rot": 3}}
    keys = [
        (0, {}),
        (3, plant),                                                                    # cắm khiên, buồm bung to
        (5, {**plant, "shield": {"dy": 60, "dx": -20, "sx": 1.25, "sy": 1.08}}),
        (8, {**plant, "shield": {"dy": 60, "dx": -20, "sx": 1.25, "sy": 1.08}, "cape1": {"rot": -10},
             "cape2": {"rot": -12}}),
        (10, {**plant, "cape1": {"rot": -14}, "cape2": {"rot": -16}, "cape3": {"rot": -18}}),   # áo choàng tung
        (11, {**plant, "cape1": {"rot": -14}, "cape2": {"rot": -16}, "cape3": {"rot": -18}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.4, 2))


def pose_hit(i, n):
    fly = {"cape1": {"rot": 8}, "cape2": {"rot": 10}, "cape3": {"rot": 12}}
    keys = [
        (0, {"chest": {"rot": -8}, "head": {"rot": -8}, "hips": {"dx": -18}, "shield": {"dx": -20, "rot": -6}, **fly}),
        (1, {"chest": {"rot": -10}, "head": {"rot": -9}, "hips": {"dx": -24}, "shield": {"dx": -26, "rot": -7}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    """Khuỵu xuống quỳ, tì vào khiên cắm đất (giữ khung cuối)."""
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "shield": {"dy": 30}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 70}, "chest": {"rot": 16}, "head": {"rot": 18, "dy": 10},
             "shield": {"dy": 50, "rot": 4}, "leg_l": {"rot": -14}}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 92}, "chest": {"rot": 22}, "head": {"rot": 26, "dy": 16},
             "shield": {"dy": 60, "rot": 7}, "leg_l": {"rot": -20}, "cape1": {"rot": 10}, "cape2": {"rot": 14}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Chống khiên xuống đất, đầu gật nhẹ (tay phải chào bị khiên che: thể hiện bằng ngực ưỡn + gật đầu)."""
    p = math.tau * i / n
    nod = max(0.0, math.sin(math.pi * (i - 2) / 4)) if 2 <= i <= 6 else 0.0
    base = {"shield": {"dy": 40}, "head": {"rot": 6 * nod, "dy": 3 * nod}, "chest": {"sy": 1.02 + 0.01 * math.sin(p)}}
    return add(base, sway(i, n, 1.2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "aldric", "bones": BONES, "top": [("shield", SHIELD_ZONE)], "poses": POSES,
          "shadow_below": 1080, "strict_pockets": 300,
          "char_h": 340, "foot_x": 700}  # áo choàng + khiên rất ngang: thu nhỏ để không ra ngoài khung

if __name__ == "__main__":
    run(CONFIG)

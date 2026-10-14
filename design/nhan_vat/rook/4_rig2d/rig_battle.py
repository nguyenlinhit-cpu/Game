"""Sprite trận của Rook bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/rook/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/rook/4_rig2d/rig_battle.py -- --only idle,attack

Bố cục giống Ignar (vũ khí nặng vác qua vai, đầu vũ khí trên-trái, tay cầm bên phải) nên tư thế làm theo mẫu Ignar.
Cán rìu chạy sau đầu: đoạn bị đầu che không có trong ảnh nên chép đoạn cán thấy được lấp vào (clones có dời), đặt
sau đầu (layer_depth) để lúc vác trên vai vẫn bị đầu che.

Xuất 5_render/battle_rook.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn, tay trái (bên phải ảnh) nắm cán rìu hai lưỡi vác qua vai sau đầu, lưỡi rìu ở trên-trái;
# tay phải (bên trái ảnh) bao tay đá thả xuống chống hông; người to vuông, áo ca rô đỏ, giáp gỗ.
BONES = {
    "root":   {"parent": None,    "pivot": (780, 1000), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":  {"parent": "root",  "pivot": (650, 790), "zone": [(620, 830, 560, 980, 75)], "prio": 1, "depth": 1},
    "leg_r":  {"parent": "root",  "pivot": (930, 790), "zone": [(960, 830, 1000, 960, 70)], "prio": 1, "depth": 1},
    "hips":   {"parent": "root",  "pivot": (800, 700), "zone": [(660, 650, 1000, 700, 80)], "prio": 1, "depth": 1.2},
    "chest":  {"parent": "hips",  "pivot": (800, 640), "zone": [(800, 430, 820, 540, 120)], "prio": 1.2, "depth": 2},
    "head":   {"parent": "chest", "pivot": (820, 330), "zone": [(820, 150, 830, 220, 160)], "prio": 1.4, "depth": 3},
    "arm_l":  {"parent": "chest", "pivot": (520, 400), "zone": [(500, 450, 480, 650, 90)], "prio": 2, "depth": 2.6},
    "arm_r":  {"parent": "chest", "pivot": (1030, 400), "zone": [(1080, 440, 1120, 470, 60)], "prio": 2, "depth": 2.4},
    # Lớp trên trọng số cứng: rìu (lưỡi + đoạn cán thấy được) kèm bàn tay trái cầm, xoay quanh nắm tay.
    "axe":    {"parent": "arm_r", "pivot": (1130, 320), "zone": [], "prio": 0, "depth": 10},
    # Đoạn cán bị đầu che (không có trong ảnh): chép đoạn cán thấy được bên phải đầu, nằm sau đầu (layer_depth).
    "axe_mid": {"parent": "axe",  "pivot": (1130, 320), "zone": [], "prio": 0, "depth": 2.2, "layer_depth": 2.2},
}
HANDLE_PIECE = [(965, 296, 1055, 304, 19)]
HANDLE_FILL = [("axe_mid", HANDLE_PIECE, (-90, -8)), ("axe_mid", HANDLE_PIECE, (-180, -17)),
               ("axe_mid", HANDLE_PIECE, (-270, -25))]


def poly_zone(pts, step=14, pad=-14):
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


AXE_ZONE = (poly_zone([(150, 200), (260, 60), (530, 15), (520, 160), (470, 240), (530, 330), (440, 480), (400, 525),
                       (290, 480), (150, 310)])                                              # hai lưỡi rìu
            + [(150, 205, 265, 55, 20), (150, 310, 300, 490, 20), (280, 470, 430, 545, 26), (265, 55, 535, 15, 18),  # mép ngoài lưỡi rìu
               (430, 230, 690, 265, 42),                                                     # cán trước đầu
               (960, 290, 1330, 380, 36), (1300, 340, 1425, 420, 46),                        # cán sau tay, đốc rìu
               (1070, 300, 1200, 330, 55)])                                                  # bàn tay nắm cán


def pose_idle(i, n):
    p = math.tau * i / n
    up = max(0.0, math.sin(p))  # lắc vai vác rìu
    stomp = max(0.0, -math.sin(p))  # giậm chân
    base = {"chest": {"sy": 1 + 0.014 * math.sin(p)}, "arm_r": {"dy": -10 * up}, "axe": {"rot": -2.5 * up},
            "head": {"rot": 1.2 * math.sin(p + 0.5), "dy": -3 * up}, "leg_l": {"dy": -14 * stomp},
            "arm_l": {"rot": 1.5 * math.sin(p)}}
    return base


SLAM = {"axe": {"rot": 249}, "arm_r": {"rot": 30}, "chest": {"rot": 9}, "head": {"rot": 6},
        "hips": {"dx": 26}, "root": {"sy": 0.95}}


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"axe": {"rot": 60, "dy": 30}, "arm_r": {"rot": -24}, "chest": {"rot": -4}, "head": {"rot": -4},  # giơ cao
             "hips": {"dx": -8}, "root": {"sy": 1.02}}),
        (3, {"axe": {"rot": 110, "dy": 40}, "arm_r": {"rot": -14}, "hips": {"dx": 6}}),
        (4, SLAM),                                                                                # bổ thẳng xuống
        (5, {**SLAM, "axe": {"rot": 246}}),
        (6, {"axe": {"rot": 100, "dy": -10}, "arm_r": {"rot": -8}, "chest": {"rot": 2}}),           # giật lên vai
        (7, {}),
    ]
    return lerp_keys(keys, i)


def pose_skill(i, n):
    """Xoay người kéo rìu ngang rồi quét qua 3 quái, chống rìu."""
    keys = [
        (0, {}),
        (2, {"axe": {"rot": 40, "dx": -40}, "chest": {"rot": -8}, "head": {"rot": -5}, "hips": {"dx": -20}}),
        (3, {"axe": {"rot": 80, "dx": -40}, "chest": {"rot": -10}, "hips": {"dx": -24}}),             # kéo rìu ngang
        (5, {"axe": {"rot": 150, "dx": -20}, "chest": {"rot": 4}, "hips": {"dx": 10}}),
        (6, {"axe": {"rot": 229}, "arm_r": {"rot": 10}, "chest": {"rot": 8},                           # quét qua 3 quái
             "hips": {"dx": 24}, "head": {"rot": 4}}),
        (8, {"axe": {"rot": 259}, "chest": {"rot": 6}}),                                                # chống rìu
        (9, {"axe": {"rot": 259}, "chest": {"rot": 6}}),
    ]
    return lerp_keys(keys, i)


def pose_ultimate(i, n):
    plant = {"axe": {"rot": 259}, "chest": {"rot": 4}}
    keys = [
        (0, {}),
        (2, plant),                                                                               # cắm rìu xuống
        (5, {**plant, "head": {"rot": -8}, "chest": {"rot": -2}}),                                 # cây mọc sau lưng
        (6, {"axe": {"rot": 100, "dy": 20}, "arm_r": {"rot": -14}, "chest": {"rot": -6}, "hips": {"dx": -14}}),
        (7, {**SLAM, "root": {"sy": 0.92}}),                                                       # chặt gốc
        (8, {**SLAM, "root": {"sy": 0.92}}),
        (9, {**SLAM}),
        (10, {"head": {"rot": 4}, "arm_l": {"rot": -10}}),                                          # phủi tay
        (11, {"head": {"rot": 4}, "arm_l": {"rot": -14}}),
    ]
    return lerp_keys(keys, i)


def pose_hit(i, n):
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "axe": {"rot": -7}, "arm_l": {"rot": 8}}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "axe": {"rot": -8}, "arm_l": {"rot": 10}}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    """Khuỵu gối, chống rìu xuống đất, gục đầu (to vuông: không ngã nằm)."""
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 70}, "chest": {"rot": 14}, "head": {"rot": 16, "dy": 10},
             "axe": {"rot": 232}, "leg_l": {"rot": -14}}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 92}, "chest": {"rot": 20}, "head": {"rot": 24, "dy": 16},
             "axe": {"rot": 230, "dy": 10}, "leg_l": {"rot": -20}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Vác rìu, ngửa cổ cười lớn, tay phải vỗ ngực."""
    p = math.tau * i / n
    beat = max(0.0, math.sin(p * 2))
    base = {"arm_l": {"rot": -38 * beat, "dy": -20 * beat}, "head": {"rot": -6 - 2 * beat},
            "chest": {"sy": 1.02 + 0.02 * beat}, "axe": {"rot": -2 * beat}}
    return base


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "rook", "bones": BONES, "top": [("axe", AXE_ZONE)], "clones": HANDLE_FILL, "poses": POSES,
          "shadow_below": 990, "strict_pockets": 300,
          "char_h": 300, "foot_x": 900}  # rìu dài: thu nhỏ để bổ xuống/quét không ra ngoài khung

if __name__ == "__main__":
    run(CONFIG)

"""Sprite trận của Sylvaine bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/sylvaine/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/sylvaine/4_rig2d/rig_battle.py -- --only idle,attack

Xuất 5_render/battle_sylvaine.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng thẳng, hai tay ôm gậy gỗ quấn dây leo chéo trước người (chân gậy chạm đất bên trái, ngọn trổ cành
# hoa và đèn búp bên phải trên đầu); tóc nâu rất dài kết hoa, áo choàng lá, cánh hoa bay quanh.
BONES = {
    "root":   {"parent": None,     "pivot": (740, 975), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":  {"parent": "root",   "pivot": (700, 700), "zone": [(695, 760, 705, 920, 42)], "prio": 1, "depth": 1},
    "leg_r":  {"parent": "root",   "pivot": (800, 700), "zone": [(810, 760, 835, 930, 44)], "prio": 1, "depth": 1},
    "hips":   {"parent": "root",   "pivot": (750, 620), "zone": [(700, 600, 840, 650, 75)], "prio": 1, "depth": 1.2},
    "cape1":  {"parent": "hips",   "pivot": (610, 560), "zone": [(560, 640, 500, 720, 60)], "prio": 2, "depth": 1.4},
    "cape2":  {"parent": "cape1",  "pivot": (510, 740), "zone": [(510, 780, 570, 840, 45)], "prio": 2.3, "depth": 1.4},
    "chest":  {"parent": "hips",   "pivot": (750, 600), "zone": [(735, 420, 750, 520, 80)], "prio": 1.2, "depth": 2},
    "head":   {"parent": "chest",  "pivot": (720, 420),
               "zone": [(720, 190, 725, 240, 140), (610, 90, 740, 80, 70)], "prio": 1.4, "depth": 3},
    "hair1":  {"parent": "head",   "pivot": (560, 300), "zone": [(510, 380, 480, 470, 55)], "prio": 2.4, "depth": 2.6},
    "hair2":  {"parent": "hair1",  "pivot": (480, 500), "zone": [(470, 560, 475, 690, 55)], "prio": 2.6, "depth": 2.6},
    "hair3":  {"parent": "head",   "pivot": (900, 340), "zone": [(950, 430, 1000, 540, 50)], "prio": 2.4, "depth": 2.6},
    "hair4":  {"parent": "hair3",  "pivot": (1000, 560), "zone": [(1000, 610, 975, 720, 45), (950, 780, 975, 820, 38)],
               "prio": 2.6, "depth": 2.6},
    "arms":   {"parent": "chest",  "pivot": (790, 400), "zone": [(790, 410, 800, 400, 30)], "prio": 2, "depth": 3.2},
    # Lớp trên trọng số cứng: gậy (cả ngọn cành hoa, đèn búp) kèm hai bàn tay ôm gậy; xoay quanh chỗ cầm.
    "staff":  {"parent": "arms",   "pivot": (840, 380), "zone": [], "prio": 0, "depth": 10},
}
STAFF_PTS = [(618, 962), (660, 840), (705, 700), (760, 560), (810, 450), (850, 340), (900, 220), (935, 110), (960, 40)]
def poly_zone(pts, step=12, pad=-6):
    """Đa giác lồi → các dải ngang (zone) để làm vùng lớp trên; pad âm nới rộng sang hai bên."""
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


STAFF_ZONE = ([(ax, ay, bx, by, 34) for (ax, ay), (bx, by) in zip(STAFF_PTS, STAFF_PTS[1:])]
              + poly_zone([(835, 8), (1010, 10), (1090, 70), (1085, 250), (1000, 300), (940, 270), (895, 150),
                           (830, 70)])                                                     # ngọn: cành, lá, hoa, đèn
              + [(800, 340, 870, 345, 36), (790, 400, 865, 400, 34)])                      # hai bàn tay

# Cánh hoa vẽ sẵn bay quanh nhân vật (hiệu ứng làm riêng ở 6_vfx/): xoá.
ERASE = [(455, 310, 455, 310, 18), (480, 375, 480, 375, 10), (965, 322, 965, 322, 18), (1040, 628, 1040, 628, 20),
         (1000, 758, 1000, 758, 16), (918, 882, 918, 882, 20), (875, 915, 875, 915, 16), (518, 862, 518, 862, 20),
         (580, 932, 580, 932, 20), (630, 935, 630, 935, 8)]


def sway(i, n, amp=1.0, speed=1.0):
    """Tóc dài và áo choàng lá đung đưa (trễ dần về đuôi)."""
    p = math.tau * i / n * speed
    return {"hair1": {"rot": 2 * amp * math.sin(p + 0.3)}, "hair2": {"rot": 3 * amp * math.sin(p + 1.0)},
            "hair3": {"rot": -2 * amp * math.sin(p + 0.5)}, "hair4": {"rot": -3 * amp * math.sin(p + 1.2)},
            "cape1": {"rot": 2 * amp * math.sin(p + 0.8)}, "cape2": {"rot": 3 * amp * math.sin(p + 1.5)}}


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"head": {"rot": 3 * math.sin(p)}, "chest": {"sy": 1 + 0.01 * math.sin(p)},  # nghiêng đầu, ôm gậy
            "staff": {"rot": 1.5 * math.sin(p + 0.5)}}
    return add(base, sway(i, n))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"staff": {"rot": -30, "dx": -20}, "arms": {"rot": -6}, "chest": {"rot": -4}, "head": {"rot": -3},  # ra sau
             "hips": {"dx": -10}}),
        (3, {"staff": {"rot": 30, "dx": 20}, "arms": {"rot": 4}, "chest": {"rot": 4}, "hips": {"dx": 10}}),
        (4, {"staff": {"rot": 52, "dx": 34, "dy": 10}, "arms": {"rot": 8}, "chest": {"rot": 6}, "hips": {"dx": 16},  # quất
             "head": {"rot": 2}}),
        (6, {"staff": {"rot": 10}, "chest": {"rot": 1}}),                                                   # ôm gậy lại
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.9))


def pose_skill(i, n):
    plant = {"staff": {"dy": 20, "dx": 10, "rot": -4}, "arms": {"dy": 12}, "chest": {"rot": 3}, "head": {"rot": 4}}
    keys = [
        (0, {}),
        (2, {"staff": {"dy": -30, "rot": -2}, "arms": {"dy": -20}}),             # nhấc gậy
        (3, plant),                                                               # cắm xuống đất
        (6, {**plant, "head": {"rot": -3}}),                                      # hoa nở trên gậy
        (8, {"staff": {"dy": 10}, "head": {"rot": 5}}),                           # rút gậy, mỉm cười
        (9, {"head": {"rot": 4}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.9))


def pose_ultimate(i, n):
    pray = {"staff": {"rot": -8, "dx": -30}, "arms": {"rot": -4, "dx": -20}, "head": {"rot": -5, "dy": 4},
            "chest": {"rot": -2}, "root": {"dy": -16}}
    lift = {"hair1": {"rot": 14}, "hair2": {"rot": 12}, "hair3": {"rot": -14}, "hair4": {"rot": -12},
            "cape1": {"rot": 10}, "cape2": {"rot": 12}}  # tóc và áo bay lên
    keys = [
        (0, {}),
        (3, {**pray, **lift}),                                                    # chắp tay cầu nguyện
        (5, {**pray, **lift, "root": {"dy": -24}}),
        (8, {**pray, **lift, "root": {"dy": -24}, "head": {"rot": -7, "dy": 4}}),  # vườn nở bung
        (10, {"staff": {"rot": 18, "dx": 30}, "arms": {"rot": 8}, "head": {"rot": 3}, "chest": {"rot": -3}}),  # dang tay
        (11, {"staff": {"rot": 18, "dx": 30}, "arms": {"rot": 8}, "head": {"rot": 3}, "chest": {"rot": -3}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0, 2))


def pose_hit(i, n):
    fly = {"hair1": {"rot": -8}, "hair2": {"rot": -10}, "hair3": {"rot": -8}, "hair4": {"rot": -10}, "cape1": {"rot": -6}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "staff": {"rot": -10}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "staff": {"rot": -12}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "staff": {"rot": -14}}),
        (2, {"root": {"sy": 0.86, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10},
             "staff": {"rot": -30}}),
        (4, {"root": {"sy": 0.86, "rot": -72, "dx": 440, "dy": -230}, "chest": {"rot": 6}, "head": {"rot": 12},
             "staff": {"rot": -40}, "hair1": {"rot": 15}}),
        (5, {"root": {"sy": 0.86, "rot": -84, "dx": 490, "dy": -290}, "chest": {"rot": 4}, "head": {"rot": 10},
             "staff": {"rot": -44}, "hair1": {"rot": 20}, "hair2": {"rot": 10}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Kéo ngọn gậy về gần mặt ngửi hoa, rồi xoay một vòng (lật ngang)."""
    smell = {"staff": {"rot": -24, "dx": -40, "dy": 70}, "arms": {"rot": -4}, "head": {"rot": 6}}
    if i <= 3:
        return add(lerp_keys([(0, {}), (2, smell), (3, smell)], i), sway(i, n, 1.0))
    sx = [0.4, -0.85, 0.4, 1.0][i - 4]
    return add({"root": {"sx": sx, "dy": -10 if i < 7 else 0}}, sway(i, n, 2.0, 2))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "sylvaine", "bones": BONES, "top": [("staff", STAFF_ZONE)], "poses": POSES, "erase": ERASE,
          "shadow_below": 935, "white_holes": 30, "char_h": 400, "foot_x": 745,
          "close": 45}  # gậy chéo rộng ~70 px cắt qua váy: đóng hình rộng hơn để tô lấp chỗ gậy che

if __name__ == "__main__":
    run(CONFIG)

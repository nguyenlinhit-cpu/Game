"""Sprite trận của Nyx bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/nyx/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/nyx/4_rig2d/rig_battle.py -- --only idle,attack

Bước làm sạch: tia điện tím nhạt vẽ sẵn quanh găng (hiệu ứng làm riêng ở 6_vfx/) bị xoá theo màu, ghi ra
4_rig2d/1a_clean.png rồi mới dựng xương trên ảnh đó. Tia điện tím đậm chạy trên mặt găng được giữ (là nét của găng).

Xuất 5_render/battle_nyx.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, cutout, drop_specks, lerp_keys, load_rgba, run, save_png, zone_mask  # noqa: E402

HERE = Path(__file__).resolve().parent

# Toạ độ theo ảnh gốc 1a_battle.png (1145×1374), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng lệch hông, tay phải (bên trái ảnh) giơ găng đồng lên ngang vai, tay trái đút túi áo khoác,
# dây cáp thả từ thắt lưng ra sau (bên phải ảnh) thành đuôi, ăng-ten cong trên mũ.
BONES = {
    "root":     {"parent": None,     "pivot": (590, 1330), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":    {"parent": "root",   "pivot": (530, 1000),
                 "zone": [(525, 1010, 510, 1180, 70), (470, 1250, 560, 1250, 75)], "prio": 1, "depth": 1},
    "leg_r":    {"parent": "root",   "pivot": (690, 1000),
                 "zone": [(690, 1010, 705, 1180, 65), (720, 1270, 720, 1290, 85)], "prio": 1, "depth": 1},
    "hips":     {"parent": "root",   "pivot": (590, 920),
                 "zone": [(500, 905, 690, 930, 70), (760, 950, 800, 975, 45)], "prio": 1, "depth": 1.2},
    "pouch":    {"parent": "hips",   "pivot": (450, 885), "zone": [(430, 930, 425, 1030, 55)], "prio": 2.2,
                 "depth": 4},
    "cable1":   {"parent": "hips",   "pivot": (790, 990), "zone": [(795, 1000, 815, 1050, 20)], "prio": 3,
                 "depth": 0.9},
    "cable2":   {"parent": "cable1", "pivot": (818, 1055), "zone": [(822, 1062, 862, 1096, 20)], "prio": 3,
                 "depth": 0.9},
    "cable3":   {"parent": "cable2", "pivot": (866, 1098), "zone": [(870, 1101, 912, 1108, 20)], "prio": 3,
                 "depth": 0.9},
    "plug":     {"parent": "cable3", "pivot": (915, 1110), "zone": [(930, 1112, 1060, 1140, 52)], "prio": 3.2,
                 "depth": 0.9},
    "chest":    {"parent": "hips",   "pivot": (590, 900), "zone": [(580, 720, 590, 830, 120)], "prio": 1.2,
                 "depth": 2},
    "arm_pocket": {"parent": "chest", "pivot": (730, 720), "zone": [(775, 780, 800, 900, 62)], "prio": 2,
                   "depth": 2.6},
    "arm_up":   {"parent": "chest",  "pivot": (460, 720), "zone": [(450, 745, 430, 850, 42)], "prio": 2,
                 "depth": 2.5},
    "head":     {"parent": "chest",  "pivot": (600, 650),
                 "zone": [(450, 320, 750, 380, 215), (835, 560, 845, 620, 70)], "prio": 1.4, "depth": 3},
    "antenna":  {"parent": "head",   "pivot": (482, 135),
                 "zone": [(472, 115, 410, 40, 26), (395, 35, 285, 112, 34)], "prio": 4, "depth": 2.9},
    # Lớp trên trọng số cứng: găng đồng giơ lên (cả ống cuộn dây), kính bảo hộ (kéo xuống mắt ở tuyệt kỹ, thắng).
    "glove":    {"parent": "arm_up", "pivot": (382, 858), "zone": [], "prio": 0, "depth": 10},
    "goggles":  {"parent": "head",   "pivot": (690, 260), "zone": [], "prio": 0, "depth": 11},
}
GLOVE_ZONE = [(382, 845, 240, 765, 66), (230, 800, 340, 890, 36), (395, 780, 425, 850, 40),
              (228, 700, 228, 700, 84), (175, 688, 132, 582, 34), (215, 682, 200, 572, 34),
              (250, 690, 262, 612, 34), (282, 702, 322, 652, 32), (300, 722, 356, 682, 32)]
GOGGLES_ZONE = [(540, 228, 725, 222, 68), (730, 250, 790, 250, 42), (800, 235, 845, 330, 44)]
# Vùng có tia điện vẽ sẵn quanh găng: xoá điểm tím nhạt (không đụng tóc, kính, mắt).
SPARK_AREA = [(240, 640, 240, 640, 175), (360, 620, 400, 690, 40)]
CLEAN = "1a_clean.png"


def clean_concept():
    """Xoá tia điện tím nhạt quanh găng và mẩu tia tím đậm nằm ngoài găng: tô trắng để cutout coi là nền, bỏ mẩu sót."""
    a = load_rgba(HERE.parent / "1_concept" / "1a_battle.png")
    rgb = a[..., :3]
    mn = rgb.min(axis=2)
    lavender = (mn > 0.55) & (rgb[..., 2] - rgb[..., 1] > 0.04) & (rgb[..., 2] > 0.85)
    violet = (rgb[..., 2] - rgb[..., 0] > 0.1) & (rgb[..., 2] - rgb[..., 1] > 0.25)  # mẩu tia tím đậm ngoài găng
    area = zone_mask(a.shape[:2], SPARK_AREA)
    kill = (lavender & area) | (violet & area & ~zone_mask(a.shape[:2], GLOVE_ZONE))
    a[kill, :3] = 1.0
    # Ánh loá trắng tinh trên mắt kính không phải nền lọt: hạ xuống 0.95 để white_holes không khoét thủng.
    glare = zone_mask(a.shape[:2], GOGGLES_ZONE) & (rgb.min(axis=2) > 0.96)
    a[glare, :3] = 0.95
    cut = drop_specks(cutout(a.copy(), white_holes=40), kill)
    a[cut[..., 3] < 0.02, :3] = 1.0
    a[..., 3] = 1.0
    save_png(HERE / CLEAN, a)


def sway(i, n, amp=1.0, speed=1.0):
    """Đuôi dây cáp lắc (trễ dần về phích cắm), ăng-ten rung, túi đồ nghề đung đưa."""
    p = math.tau * i / n * speed
    out = {"antenna": {"rot": 4 * amp * math.sin(p * 2 + 0.3)}, "pouch": {"rot": 2.5 * amp * math.sin(p + 0.6)}}
    for j, name in enumerate(("cable1", "cable2", "cable3", "plug")):
        out[name] = {"rot": (3 + 1.5 * j) * amp * math.sin(p + 0.5 + 0.8 * j)}
    return out


GOG_DOWN = {"goggles": {"dx": -40, "dy": 205, "rot": 6}}  # kính kéo xuống che mắt


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"hips": {"dx": 4 * math.sin(p), "rot": 1.2 * math.sin(p)}, "chest": {"sy": 1 + 0.012 * math.sin(p)},
            "head": {"rot": 1.5 * math.sin(p + 0.5)}, "arm_up": {"rot": 2 * math.sin(p)},
            "glove": {"rot": 3 * math.sin(p + 1)}, "arm_pocket": {"rot": -1.5 * math.sin(p)}}
    return add(base, sway(i, n, 1.0))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"glove": {"rot": -10}, "arm_up": {"rot": -5}, "head": {"rot": -2}, "chest": {"rot": -2},  # tích điện
             "hips": {"dx": -6}}),
        (3, {"glove": {"rot": 12, "dx": 12}, "arm_up": {"rot": 4}, "chest": {"rot": 3}, "hips": {"dx": 8}}),
        (4, {"glove": {"rot": 18, "dx": 18}, "arm_up": {"rot": 6}, "chest": {"rot": 4}, "hips": {"dx": 10},  # búng (trúng)
             "head": {"rot": 1}}),
        (5, {"glove": {"rot": 34}, "arm_up": {"rot": 8}, "head": {"rot": -5}, "chest": {"rot": -1}}),  # đưa ngón lên miệng
        (6, {"glove": {"rot": 38}, "arm_up": {"rot": 9}, "head": {"rot": -6}, "chest": {"rot": -1}}),  # thổi như thổi súng
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_skill(i, n):
    """Khung 4–7 phích cắm thu về điểm đầu dây (sx/sy ≈ 0): dây quăng tới quái và phích cắm vẽ ở 6_vfx/skill."""
    keys = [
        (0, {}),
        (2, {"cable1": {"rot": -18}, "cable2": {"rot": -16}, "cable3": {"rot": -14}, "plug": {"rot": -12},   # rút dây
             "arm_pocket": {"rot": -8, "dy": 8}, "hips": {"dx": -6}, "chest": {"rot": -2}}),
        (3, {"cable1": {"rot": -40}, "cable2": {"rot": -24}, "cable3": {"rot": -20}, "plug": {"rot": -24},
             "arm_pocket": {"rot": -12, "dy": 12}, "hips": {"dx": -10}, "chest": {"rot": -3}, "head": {"rot": -2}}),
        (5, {"cable1": {"rot": -72}, "cable2": {"rot": 6}, "cable3": {"rot": 4}, "plug": {"rot": 2},           # quăng
             "arm_pocket": {"rot": 6}, "hips": {"dx": 12}, "chest": {"rot": 5}, "head": {"rot": 2}}),
        (6, {"cable1": {"rot": -66}, "cable2": {"rot": 4}, "cable3": {"rot": 2}, "plug": {"rot": 0},           # cắm (trúng)
             "hips": {"dx": 10}, "chest": {"rot": 4}, "head": {"rot": 2}, "glove": {"rot": 4}}),
        (7, {"cable1": {"rot": -40}, "cable2": {"rot": 18}, "cable3": {"rot": 20}, "plug": {"rot": 14},        # giật về
             "hips": {"dx": -4}, "chest": {"rot": -2}}),
        (8, {"cable1": {"rot": -8}, "cable2": {"rot": 22}, "cable3": {"rot": 26}, "plug": {"rot": 24}}),       # quấn hông
        (9, {"cable2": {"rot": 6}, "cable3": {"rot": 8}, "plug": {"rot": 6}}),
    ]
    pose = add(lerp_keys(keys, i), sway(i, n, 0.4))
    if 4 <= i <= 7:
        pose["plug"] = {**pose.get("plug", {}), "sx": 0.02, "sy": 0.02}
    return pose


def pose_ultimate(i, n):
    kneel = {"root": {"sy": 0.9}, "hips": {"dy": 46, "dx": -8}, "chest": {"rot": 12}, "head": {"rot": 5},
             "glove": {"rot": -78}, "arm_up": {"rot": -24}, "arm_pocket": {"rot": 26}, "leg_l": {"rot": 10},
             "leg_r": {"rot": -8}, "pouch": {"rot": 10}, **GOG_DOWN}
    keys = [
        (0, {}),
        (2, {"head": {"rot": -3}, "glove": {"rot": 10}, "arm_up": {"rot": 4}, **GOG_DOWN}),          # kéo kính xuống
        (4, {**kneel, "antenna": {"rot": -8}}),                                                     # cắm găng xuống đất
        (5, {**kneel, "root": {"sy": 0.88}, "hips": {"dy": 52, "dx": -8}, "antenna": {"rot": -12}}),
        (7, {**kneel, "root": {"sy": 0.88}, "hips": {"dy": 52, "dx": -8}, "antenna": {"rot": 6}}),
        (9, {**kneel, "root": {"sy": 0.89}, "hips": {"dy": 50, "dx": -8}, "antenna": {"rot": -6}}),   # bão lan ra
        (10, {"glove": {"rot": -6}, "arm_up": {"rot": -4}, "head": {"rot": -2}}),                   # đứng dậy phủi găng
        (11, {"glove": {"rot": -6}, "arm_up": {"rot": -4}, "head": {"rot": -2}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8, 2))


def pose_hit(i, n):
    fly = {"cable1": {"rot": -14}, "cable2": {"rot": -10}, "cable3": {"rot": -8}, "plug": {"rot": -8},
           "antenna": {"rot": 12}, "pouch": {"rot": -10}}
    keys = [
        (0, {"chest": {"rot": -10}, "head": {"rot": -9}, "hips": {"dx": -16}, "glove": {"rot": -14},
             "arm_up": {"rot": -6}, "arm_pocket": {"rot": 6}, **fly}),
        (1, {"chest": {"rot": -12}, "head": {"rot": -10}, "hips": {"dx": -20}, "glove": {"rot": -16},
             "arm_up": {"rot": -7}, "arm_pocket": {"rot": 7}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.9}, "chest": {"rot": 5}, "head": {"rot": 8}, "glove": {"rot": -30},
             "leg_l": {"rot": 14}, "antenna": {"rot": 8}}),
        (2, {"root": {"sy": 0.85, "rot": -8, "dx": 10}, "chest": {"rot": 8}, "head": {"rot": 10},
             "glove": {"rot": -20}, "leg_l": {"rot": 20}, "antenna": {"rot": 12}}),
        (4, {"root": {"sy": 0.85, "rot": -72, "dx": 470, "dy": -230}, "chest": {"rot": 6}, "head": {"rot": 12},
             "glove": {"rot": 30}, "leg_l": {"rot": 8}, "antenna": {"rot": 18}, "cable1": {"rot": 20}}),
        (5, {"root": {"sy": 0.85, "rot": -84, "dx": 520, "dy": -290}, "chest": {"rot": 4}, "head": {"rot": 10},
             "glove": {"rot": 40}, "leg_l": {"rot": 4}, "antenna": {"rot": 24}, "cable1": {"rot": 26},
             "cable2": {"rot": 10}}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    shrug = {"chest": {"sy": 1.03}, "arm_pocket": {"dy": -14}, "arm_up": {"dy": -10}, "head": {"rot": -4}}
    keys = [
        (0, {}),
        (2, {"glove": {"rot": 20}, "arm_up": {"rot": 6}, "head": {"rot": -2}, **GOG_DOWN}),       # kéo kính xuống mắt
        (4, {**shrug, **GOG_DOWN}),                                                                # nhún vai
        (5, {**GOG_DOWN}),
        (7, {"root": {"sx": 0.94}, "hips": {"dx": -12}, "chest": {"rot": -3}, "head": {"rot": -7},  # quay đi
             "glove": {"rot": -8}, **GOG_DOWN}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "nyx", "concept": f"../4_rig2d/{CLEAN}", "bones": BONES,
          # vùng găng nới thêm 8 px để kéo theo cả viền mờ ngoài ngón (không sót mẩu ở chỗ cũ khi găng xoay)
          "top": [("glove", [(ax, ay, bx, by, r + 8) for ax, ay, bx, by, r in GLOVE_ZONE]),
                  ("goggles", GOGGLES_ZONE)], "poses": POSES,
          "fill_under": ["goggles"],  # kính kéo xuống thì chỗ cũ trên mũ được tô lấp
          "white_holes": 40}  # nền trắng lọt giữa ngón găng sau khi xoá tia điện

if __name__ == "__main__":
    clean_concept()
    run(CONFIG)

"""Sprite trận của Orrin bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/orrin/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/orrin/4_rig2d/rig_battle.py -- --only idle,attack

Bước làm sạch (ghi ra 4_rig2d/1a_clean.png): vòng chữ vàng phát sáng vẽ sẵn quanh người (hiệu ứng làm riêng ở 6_vfx/)
xoá theo màu vàng sáng trong GLOW_AREA, trừ bút lông, bàn tay, 4 cuốn sách và tua mũ; mẩu vòng còn sót không nối với
thân bị drop_specks bỏ. Đoạn vòng chạy ngang trước áo chùng (khó tách) được giữ.

Xuất 5_render/battle_orrin.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import _components, add, cutout, drop_specks, lerp_keys, load_rgba, neighbours, run, save_png, zone_mask  # noqa: E402,E501

HERE = Path(__file__).resolve().parent

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn, lưng hơi gù, tay trái (bên phải ảnh) giơ bút lông vàng to như gậy; mũ chóp mềm gập sang trái
# có tua; râu dài buộc túm; 4 cuốn sách bay lơ lửng quanh vai (trên-trái, trên-giữa, trái, phải).
BONES = {
    "root":    {"parent": None,     "pivot": (760, 960), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":   {"parent": "root",   "pivot": (650, 800), "zone": [(650, 840, 620, 920, 55)], "prio": 1, "depth": 1},
    "leg_r":   {"parent": "root",   "pivot": (860, 800), "zone": [(870, 840, 905, 940, 55)], "prio": 1, "depth": 1},
    "hips":    {"parent": "root",   "pivot": (750, 640),
                "zone": [(640, 680, 880, 700, 110), (460, 760, 1100, 800, 60)], "prio": 1, "depth": 1.2},
    "chest":   {"parent": "hips",   "pivot": (750, 640), "zone": [(720, 500, 780, 560, 90)], "prio": 1.2, "depth": 2},
    "head":    {"parent": "chest",  "pivot": (720, 470),
                "zone": [(730, 300, 740, 360, 130), (600, 150, 700, 150, 70)], "prio": 1.4, "depth": 3},
    "hat":     {"parent": "head",   "pivot": (560, 220), "zone": [(500, 200, 360, 280, 50)], "prio": 2.6, "depth": 3.1},
    "beard1":  {"parent": "head",   "pivot": (720, 420), "zone": [(700, 460, 710, 500, 55)], "prio": 2.6, "depth": 3.2},
    "beard2":  {"parent": "beard1", "pivot": (720, 520), "zone": [(730, 545, 740, 580, 45)], "prio": 3, "depth": 3.2},
    "arm":     {"parent": "chest",  "pivot": (860, 470), "zone": [(890, 450, 920, 420, 40)], "prio": 2.2, "depth": 3.4},
    # Sách bay: trọng số cứng, mỗi cuốn 1 xương (cha là ngực để bay theo vai).
    "book_a":  {"parent": "chest",  "pivot": (465, 150), "zone": [], "prio": 0, "depth": 4},
    "book_b":  {"parent": "chest",  "pivot": (880, 135), "zone": [], "prio": 0, "depth": 1.5},
    "book_c":  {"parent": "chest",  "pivot": (450, 455), "zone": [], "prio": 0, "depth": 4.2},
    "book_d":  {"parent": "chest",  "pivot": (1100, 530), "zone": [], "prio": 0, "depth": 4.4},
    # Bút lông vàng kèm bàn tay cầm.
    "quill":   {"parent": "arm",    "pivot": (940, 390), "zone": [], "prio": 0, "depth": 10},
}
BOOK_A = [(385, 90, 540, 215, 44), (440, 60, 510, 60, 28)]
BOOK_B = [(800, 70, 965, 200, 44)]
BOOK_C = [(355, 370, 545, 545, 46)]
BOOK_D = [(1015, 450, 1185, 612, 44)]
QUILL_ZONE = [(1000, 255, 1190, 20, 52), (1020, 200, 1100, 60, 46), (990, 260, 905, 470, 20), (935, 390, 935, 390, 42),
              (1030, 290, 1030, 290, 26)]
GLOW_AREA = [(330, 200, 560, 200, 40), (330, 480, 420, 560, 60), (420, 60, 500, 60, 30), (930, 220, 1220, 220, 60),
             (960, 330, 1220, 330, 70), (1000, 450, 1220, 450, 70), (900, 620, 1180, 640, 60), (880, 80, 980, 120, 40),
             (420, 300, 470, 330, 30), (880, 520, 1000, 580, 40), (780, 540, 870, 540, 25), (860, 500, 1060, 640, 50),
             (1000, 600, 1150, 680, 40)]
PROTECT = QUILL_ZONE + BOOK_A + BOOK_B + BOOK_C + BOOK_D + [(340, 250, 375, 310, 28), (940, 380, 940, 380, 45)]
CLEAN = "1a_clean.png"


def clean_concept():
    a = load_rgba(HERE.parent / "1_concept" / "1a_battle.png")
    rgb = a[..., :3]
    mn = rgb.min(axis=2)
    glow = (rgb[..., 0] > 0.8) & (rgb[..., 1] > 0.62) & (rgb[..., 0] - rgb[..., 2] > 0.12) & (mn < 0.985)
    kill = glow & zone_mask(a.shape[:2], GLOW_AREA) & ~zone_mask(a.shape[:2], PROTECT)
    a[kill, :3] = 1.0
    cut = drop_specks(cutout(a.copy()), kill, reach=40)
    a[(cut[..., 3] < 0.02) & ~zone_mask(a.shape[:2], PROTECT), :3] = 1.0  # sách bay rời thân: giữ
    # Nền lọt: vùng trắng tuyệt đối (≥ 0.995) bị bao kín, loang tới nét viền → trắng tinh cho white_holes khoét;
    # trắng còn lại (râu, tóc, áo) hạ 0.95 để giữ.
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
    pocket = _components(strict & ~bg, 300)
    for _ in range(4):
        pocket = neighbours(pocket) & (mn > 0.97) | pocket
    a[~pocket & ~bg & (mn > 0.96), :3] = 0.95
    a[pocket, :3] = 1.0
    a[..., 3] = 1.0
    save_png(HERE / CLEAN, a)


def sway(i, n, amp=1.0, speed=1.0):
    """Sách bay chậm lên xuống lệch pha, râu và mũ rung nhẹ."""
    p = math.tau * i / n * speed
    out = {"beard1": {"rot": 1.5 * amp * math.sin(p + 0.4)}, "beard2": {"rot": 2.5 * amp * math.sin(p + 1.0)},
           "hat": {"rot": 2 * amp * math.sin(p + 0.7)}}
    for k, b in enumerate(("book_a", "book_b", "book_c", "book_d")):
        out[b] = {"dy": 10 * amp * math.sin(p + k * 1.6), "rot": 3 * amp * math.sin(p + k)}
    return out


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.01 * math.sin(p)}, "head": {"rot": 1.2 * math.sin(p + 0.3)},
            "beard1": {"rot": 3 * math.sin(p)}, "quill": {"rot": 2 * math.sin(p + 1)}}  # vuốt râu: râu lắc nhẹ
    return add(base, sway(i, n))


def pose_attack(i, n):
    open_book = {"book_c": {"dx": 260, "dy": -40}}  # sách bay ra trước mặt
    keys = [
        (0, {}),
        (2, {**open_book, "quill": {"rot": -18}, "arm": {"rot": -6}}),
        (3, {**open_book, "quill": {"rot": 22}, "arm": {"rot": 8}, "chest": {"rot": 3}}),       # vạch bút
        (4, {**open_book, "quill": {"rot": 34}, "arm": {"rot": 12}, "chest": {"rot": 4}, "hips": {"dx": 8}}),
        (6, {"book_c": {"dx": 120, "dy": -20}, "quill": {"rot": 4}, "head": {"rot": -3}}),      # đẩy kính
        (7, {}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_skill(i, n):
    up = {"book_a": {"dy": -40, "rot": -10}, "book_b": {"dy": -30, "rot": 8}, "book_c": {"dy": -60, "dx": 30},
          "book_d": {"dy": -70, "dx": -20}}
    keys = [
        (0, {}),
        (3, {**up, "quill": {"rot": -10}, "head": {"rot": -3}}),                 # 3 cuốn bay lên
        (5, {**up, "quill": {"rot": 24}, "arm": {"rot": 8}, "chest": {"rot": 3}}),
        (6, {**up, "quill": {"rot": 30}, "arm": {"rot": 10}, "chest": {"rot": 4}}),
        (9, {}),                                                                   # sách quay về vai
    ]
    return add(lerp_keys(keys, i), sway(i, n, 0.8))


def pose_ultimate(i, n):
    raise_ = {"quill": {"rot": -30, "dy": -30}, "arm": {"rot": -14}, "head": {"rot": -6}, "chest": {"rot": -4},
              "book_a": {"dy": -50}, "book_b": {"dy": -50}, "book_c": {"dy": -50}, "book_d": {"dy": -50}}
    keys = [
        (0, {}),
        (4, raise_),                                                               # sách lớn mở trên đầu
        (6, {**raise_, "quill": {"rot": 30, "dy": -10}, "arm": {"rot": 10}}),       # giáng cột chữ
        (9, {**raise_, "quill": {"rot": 20}, "arm": {"rot": 6}}),
        (10, {"quill": {"rot": 6}, "head": {"rot": 3}}),                           # gập sách
        (11, {"quill": {"rot": 6}, "head": {"rot": 3}}),
    ]
    return add(lerp_keys(keys, i), sway(i, n, 1.0, 2))


def pose_hit(i, n):
    fly = {"beard1": {"rot": -8}, "beard2": {"rot": -10}, "hat": {"rot": 8}, "book_a": {"dx": -30},
           "book_b": {"dx": -30}, "book_c": {"dx": -30}, "book_d": {"dx": -40}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "quill": {"rot": -12}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "quill": {"rot": -14}, **fly}),
        (3, {}),
    ]
    return lerp_keys(keys, i)


def pose_down(i, n):
    """Khuỵu xuống ngồi bệt, sách rơi xuống đất quanh người."""
    fall = {"book_a": {"dy": 620, "rot": 80}, "book_b": {"dy": 640, "rot": -70}, "book_c": {"dy": 380, "rot": 90},
            "book_d": {"dy": 300, "rot": -90}}
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "quill": {"rot": -20}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 80}, "chest": {"rot": 14}, "head": {"rot": 16, "dy": 8},
             "quill": {"rot": -60, "dy": 120}, "arm": {"rot": 30}, **fall}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 110}, "chest": {"rot": 22}, "head": {"rot": 24, "dy": 14},
             "quill": {"rot": -80, "dy": 160}, "arm": {"rot": 40}, **fall}),
    ]
    return lerp_keys(keys, i)


def pose_victory(i, n):
    """Sách bay về trước mặt, đóng cái bộp (co ngang), rồi vuốt râu cười."""
    shut = {"book_c": {"dx": 230, "dy": -20, "sx": 0.35}}
    keys = [(0, {}), (2, {"book_c": {"dx": 230, "dy": -20}}), (3, {**shut, "head": {"rot": 2}}),
            (5, {"book_c": {"dx": 60}, "beard1": {"rot": 5}, "head": {"rot": -3}}),
            (7, {"beard1": {"rot": -3}, "head": {"rot": -2}})]
    return add(lerp_keys(keys, i), sway(i, n, 1.0))


POSES = {"idle": pose_idle, "attack": pose_attack, "skill": pose_skill, "ultimate": pose_ultimate,
         "hit": pose_hit, "down": pose_down, "victory": pose_victory}

CONFIG = {"id": "orrin", "concept": f"../4_rig2d/{CLEAN}", "bones": BONES,
          "top": [("book_b", BOOK_B), ("book_a", BOOK_A), ("book_c", BOOK_C), ("book_d", BOOK_D),
                  ("quill", QUILL_ZONE)],
          "poses": POSES, "shadow_below": 930, "white_holes": 30, "char_h": 370, "foot_x": 770}

if __name__ == "__main__":
    clean_concept()
    run(CONFIG)

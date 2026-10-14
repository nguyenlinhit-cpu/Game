"""Sprite trận của Celestine bằng xương 2D (lõi ở design/_tools/rig2d.py): uốn ảnh concept 1a_battle.png theo xương.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/celestine/4_rig2d/rig_battle.py
    blender -b -P design/nhan_vat/celestine/4_rig2d/rig_battle.py -- --only idle,idle_judge

Hai tư thế: Canh Giữ (mặc định: một kiếm cầm thấp, kiếm thứ hai trên lưng) và Phán Xử (hai kiếm bắt chéo trước người).
Kiếm thứ hai trên lưng chỉ thấy chuôi, nên ở Phán Xử dùng bản sao thanh kiếm đang cầm (clones) gắn vào tay kia và ẩn
chuôi trên lưng. Action thêm: idle_judge, attack_judge (đánh thường ở Phán Xử), skill_guard (đổi về Canh Giữ);
skill là đổi sang Phán Xử.

Xuất 5_render/battle_celestine.png + .json (khung 512, quay phải, anchor 0.5/0.84) và ảnh xem trong 5_render/preview/.
Không chép gì vào assets/.
"""

import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from rig2d import add, lerp_keys, run  # noqa: E402

# Toạ độ theo ảnh gốc 1a_battle.png (1536×1024), xem 4_rig2d/grid.png.
# Tư thế gốc: đứng tấn, tay phải cầm kiếm dài thấp chéo xuống bên phải, tay trái thả; kiếm thứ hai trên lưng (thấy chuôi
# bên trái trên vai); vầng sáng vàng hình mắt sau đầu; tóc bạc rất dài; áo choàng xanh lam đêm viền vàng.
BONES = {
    "root":     {"parent": None,      "pivot": (750, 980), "zone": [], "prio": 0.03, "depth": 0},
    "leg_l":    {"parent": "root",    "pivot": (690, 720), "zone": [(660, 760, 610, 930, 50)], "prio": 1, "depth": 1},
    "leg_r":    {"parent": "root",    "pivot": (840, 720), "zone": [(860, 770, 900, 940, 45)], "prio": 1, "depth": 1},
    "hips":     {"parent": "root",    "pivot": (760, 640), "zone": [(720, 620, 840, 660, 70)], "prio": 1, "depth": 1.2},
    "coat_l":   {"parent": "hips",    "pivot": (560, 620), "zone": [(450, 720, 330, 880, 75), (200, 700, 240, 850, 40)],
                 "prio": 2, "depth": 0.9},
    "coat_r":   {"parent": "hips",    "pivot": (900, 700), "zone": [(980, 800, 1060, 900, 60)], "prio": 2, "depth": 0.9},
    "chest":    {"parent": "hips",    "pivot": (770, 580), "zone": [(770, 450, 780, 540, 85)], "prio": 1.2, "depth": 2},
    "head":     {"parent": "chest",   "pivot": (780, 420), "zone": [(770, 250, 800, 300, 150)], "prio": 1.4, "depth": 3},
    "halo":     {"parent": "head",    "pivot": (680, 95),
                 "zone": [(450, 120, 560, 105, 22), (540, 40, 600, 70, 20), (560, 180, 520, 205, 22),
                          (580, 60, 690, 0, 22), (700, 40, 800, 45, 22)], "prio": 3, "depth": 2.5},
    "hair1":    {"parent": "head",    "pivot": (620, 350), "zone": [(520, 450, 420, 560, 70)], "prio": 2.4, "depth": 2.6},
    "hair2":    {"parent": "hair1",   "pivot": (400, 560), "zone": [(330, 620, 290, 720, 60)], "prio": 2.6, "depth": 2.6},
    "hair3":    {"parent": "head",    "pivot": (930, 380), "zone": [(960, 450, 990, 620, 45)], "prio": 2.4, "depth": 2.6},
    "arm":      {"parent": "chest",   "pivot": (700, 500), "zone": [(690, 540, 680, 580, 40)], "prio": 2.2, "depth": 3.3},
    "arm_l":    {"parent": "chest",   "pivot": (850, 520), "zone": [(880, 560, 905, 630, 34)], "prio": 2.2, "depth": 3.3},
    # Lớp trên trọng số cứng: kiếm đang cầm (kèm bàn tay), chuôi kiếm trên lưng, bản sao kiếm cho tay trái (Phán Xử).
    "sword":    {"parent": "arm",     "pivot": (700, 630), "zone": [], "prio": 0, "depth": 10},
    "sword_bk": {"parent": "chest",   "pivot": (500, 380), "zone": [], "prio": 0, "depth": 1.8},
    "sword2":   {"parent": "arm_l",   "pivot": (700, 630), "zone": [], "prio": 0, "depth": 10.5},
}
SWORD_ZONE = [(760, 684, 1478, 920, 32), (690, 560, 770, 720, 34), (720, 600, 800, 700, 40), (590, 585, 690, 615, 22),
              (650, 600, 710, 640, 34)]
SWORD_BK_ZONE = [(425, 155, 560, 420, 30), (460, 380, 560, 330, 26), (460, 420, 465, 440, 15)]
HIDE = {"sx": 0.01, "sy": 0.01}
TO_LEFT_HAND = {"dx": 205, "dy": 0}  # chỗ cầm kiếm (700, 630) → bàn tay trái (905, 630)


def stance(judge, pose):
    """Ẩn/hiện kiếm theo tư thế: Canh Giữ ẩn bản sao; Phán Xử ẩn chuôi kiếm trên lưng."""
    p = {b: dict(v) for b, v in pose.items()}
    if judge:
        p["sword_bk"] = {**p.get("sword_bk", {}), **HIDE}
    else:
        p["sword2"] = {**p.get("sword2", {}), **HIDE}
    return p


def sway(i, n, amp=1.0, speed=1.0):
    """Tóc dài và vạt áo bay nhẹ, vầng sáng xoay chậm."""
    p = math.tau * i / n * speed
    return {"hair1": {"rot": 2 * amp * math.sin(p + 0.3)}, "hair2": {"rot": 3 * amp * math.sin(p + 1.0)},
            "hair3": {"rot": -2 * amp * math.sin(p + 0.6)}, "coat_l": {"rot": 2 * amp * math.sin(p + 0.8)},
            "coat_r": {"rot": -2 * amp * math.sin(p + 1.2)}, "halo": {"rot": 4 * math.sin(p)}}


JUDGE = {"arm": {"rot": -20, "dy": -10}, "sword": {"rot": -62}, "arm_l": {"rot": -10},
         "sword2": {**TO_LEFT_HAND, "rot": -150, "dy": -20}, "chest": {"rot": -2}}   # hai kiếm bắt chéo trước người


def pose_idle(i, n):
    p = math.tau * i / n
    base = {"chest": {"sy": 1 + 0.01 * math.sin(p)}, "head": {"rot": 0.8 * math.sin(p + 0.4)},
            "sword": {"rot": 1.5 * math.sin(p)}}
    return stance(False, add(base, sway(i, n)))


def pose_idle_judge(i, n):
    p = math.tau * i / n
    base = add(JUDGE, {"chest": {"sy": 1 + 0.01 * math.sin(p)}, "sword": {"rot": 1.5 * math.sin(p)},
                       "sword2": {"rot": -1.5 * math.sin(p)}})
    return stance(True, add(base, sway(i, n)))


def pose_attack(i, n):
    keys = [
        (0, {}),
        (2, {"hips": {"dx": -16}, "sword": {"rot": 30}, "arm": {"rot": 8}, "chest": {"rot": -3}}),       # lùi nửa bước
        (3, {"hips": {"dx": 10}, "sword": {"rot": -70}, "arm": {"rot": -16}, "chest": {"rot": 3}}),
        (4, {"hips": {"dx": 20}, "sword": {"rot": -40, "dx": 20}, "arm": {"rot": -8}, "chest": {"rot": 4}}),  # chém gọn
        (6, {"sword": {"rot": -6}}),
        (7, {}),
    ]
    return stance(False, add(lerp_keys(keys, i), sway(i, n, 0.8)))


def pose_attack_judge(i, n):
    keys = [
        (0, JUDGE),
        (2, add(JUDGE, {"sword": {"rot": -30}, "sword2": {"rot": 30}, "chest": {"rot": -4}, "hips": {"dx": -10}})),
        (4, add(JUDGE, {"sword": {"rot": 80}, "sword2": {"rot": -80}, "chest": {"rot": 5}, "hips": {"dx": 20}})),  # chéo
        (6, add(JUDGE, {"sword": {"rot": 20}, "sword2": {"rot": -20}})),
        (7, JUDGE),
    ]
    return stance(True, add(lerp_keys(keys, i), sway(i, n, 0.8)))


def pose_skill(i, n):
    """Đổi sang Phán Xử: rút kiếm thứ hai từ lưng (tay trái vòng ra sau), chém chéo chữ X mạnh."""
    draw = {"arm_l": {"rot": -120, "dy": -40}, "head": {"rot": -3}}
    if i <= 1:
        return stance(False, add(lerp_keys([(0, {}), (1, draw)], i), sway(i, n, 0.8)))
    keys = [
        (2, add(JUDGE, {"sword2": {"rot": 60}, "arm_l": {"rot": -40}})),                    # kiếm thứ hai rút ra
        (3, JUDGE),
        (4, add(JUDGE, {"sword": {"rot": -40}, "sword2": {"rot": 40}, "hips": {"dx": -12}, "chest": {"rot": -4}})),
        (6, add(JUDGE, {"sword": {"rot": 95}, "sword2": {"rot": -95}, "hips": {"dx": 28}, "chest": {"rot": 6}})),  # X
        (8, add(JUDGE, {"sword": {"rot": 30}, "sword2": {"rot": -30}, "hips": {"dx": 10}})),
        (9, JUDGE),
    ]
    return stance(True, add(lerp_keys(keys, i), sway(i, n, 0.8)))


def pose_skill_guard(i, n):
    """Đổi về Canh Giữ: tra kiếm trái vào lưng, lướt lùi nhanh."""
    if i <= 3:
        t = i / 3
        p = lerp_keys([(0, JUDGE), (3, add(JUDGE, {"arm_l": {"rot": -120, "dy": -40}, "sword2": {"sx": 0.05}}))], i)
        return stance(t < 0.9, add(p, sway(i, n, 0.8)))
    keys = [(4, {"hips": {"dx": -20}}), (6, {"root": {"dx": -90}, "hips": {"dx": -20}, "chest": {"rot": -6},
                                             "hair1": {"rot": 12}, "hair2": {"rot": 10}}),
            (8, {"root": {"dx": -40}}), (9, {})]
    return stance(False, add(lerp_keys(keys, i), sway(i, n, 0.8)))


def pose_ultimate(i, n):
    raise_ = add(JUDGE, {"sword": {"rot": -40, "dy": -40}, "sword2": {"rot": 40, "dy": -40}, "head": {"rot": -4},
                         "halo": {"sx": 1.25, "sy": 1.25}})
    keys = [
        (0, JUDGE),
        (4, raise_),                                                                                  # giơ hai kiếm
        (5, raise_),
        (6, add(JUDGE, {"root": {"dx": 240}, "sword": {"rot": 70}, "sword2": {"rot": -70}, "chest": {"rot": 8}})),  # lướt
        (8, add(JUDGE, {"root": {"dx": 260}, "sword": {"rot": -60}, "sword2": {"rot": 60}, "chest": {"rot": 4}})),
        (9, add(JUDGE, {"root": {"dx": 270}, "sword": {"rot": 80}, "sword2": {"rot": -80}})),
        (10, add(JUDGE, {"root": {"dx": 270, "sx": -1}, "sword": {"rot": 40}, "sword2": {"rot": -20}})),   # quay lưng
        (11, add(JUDGE, {"root": {"dx": 270, "sx": -1}, "sword": {"rot": 46}, "sword2": {"rot": -24}})),   # vẩy kiếm
    ]
    return stance(True, add(lerp_keys(keys, i), sway(i, n, 1.0, 2)))


def pose_hit(i, n):
    fly = {"hair1": {"rot": -8}, "hair2": {"rot": -10}, "hair3": {"rot": -8}, "coat_l": {"rot": -6}}
    keys = [
        (0, {"chest": {"rot": -9}, "head": {"rot": -9}, "hips": {"dx": -18}, "sword": {"rot": -10}, **fly}),
        (1, {"chest": {"rot": -11}, "head": {"rot": -10}, "hips": {"dx": -22}, "sword": {"rot": -12}, **fly}),
        (3, {}),
    ]
    return stance(False, lerp_keys(keys, i))


def pose_down(i, n):
    """Khuỵu một gối, chống kiếm xuống đất, gục đầu (giữ khung cuối)."""
    keys = [
        (0, {"chest": {"rot": -6}, "head": {"rot": -6}}),
        (1, {"root": {"sy": 0.92}, "hips": {"dy": 20}, "chest": {"rot": 6}, "head": {"rot": 8}, "sword": {"rot": 20}}),
        (3, {"root": {"sy": 0.84}, "hips": {"dy": 80}, "chest": {"rot": 14}, "head": {"rot": 16, "dy": 8},
             "sword": {"rot": 50, "dy": 40}, "leg_l": {"rot": -16}, "halo": {"sx": 0.8, "sy": 0.8}}),
        (5, {"root": {"sy": 0.8}, "hips": {"dy": 110}, "chest": {"rot": 22}, "head": {"rot": 24, "dy": 14},
             "sword": {"rot": 62, "dy": 50}, "leg_l": {"rot": -22}, "halo": {"sx": 0.6, "sy": 0.6}}),
    ]
    return stance(False, lerp_keys(keys, i))


def pose_victory(i, n):
    """Tra kiếm vào lưng (kiếm thu về chuôi trên vai), đứng nghiêm, vầng sáng thu nhỏ dần."""
    keys = [(0, {}), (2, {"sword": {"rot": -110, "dx": -60, "dy": -120}, "arm": {"rot": -40}}),
            (3, {"sword": {**HIDE}, "arm": {"rot": -20}}),
            (5, {"sword": {**HIDE}, "head": {"rot": 3}, "halo": {"sx": 0.85, "sy": 0.85}}),
            (7, {"sword": {**HIDE}, "head": {"rot": 3}, "halo": {"sx": 0.75, "sy": 0.75}})]
    return stance(False, add(lerp_keys(keys, i), sway(i, n, 1.0)))


POSES = {"idle": pose_idle, "idle_judge": pose_idle_judge, "attack": pose_attack, "attack_judge": pose_attack_judge,
         "skill": pose_skill, "skill_guard": pose_skill_guard, "ultimate": pose_ultimate, "hit": pose_hit,
         "down": pose_down, "victory": pose_victory}
ACTIONS = {"idle": 6, "idle_judge": 6, "attack": 8, "attack_judge": 8, "skill": 10, "skill_guard": 10, "ultimate": 12,
           "hit": 4, "down": 6, "victory": 8}

CONFIG = {"id": "celestine", "bones": BONES, "poses": POSES, "actions": ACTIONS,
          "hit_frames": {"attack": 4, "attack_judge": 4, "skill": 6, "skill_guard": 6, "ultimate": 8},
          "loops": ["idle", "idle_judge", "victory"],
          "top": [("sword_bk", SWORD_BK_ZONE), ("sword", SWORD_ZONE)], "clones": [("sword2", SWORD_ZONE)],
          "strict_pockets": 300, "shadow_below": 975, "char_h": 345, "foot_x": 810}

if __name__ == "__main__":
    run(CONFIG)

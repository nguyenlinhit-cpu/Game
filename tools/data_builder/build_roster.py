#!/usr/bin/env python3
"""Sinh dữ liệu 20 nhân vật Phase 7 (kỹ năng, hiệu ứng, Bí Kỹ, Đòn Mở Màn, Đặc tính, Tinh Mệnh) + file dịch.
Tên, mô tả lấy từ roster_design.py; số liệu kỹ năng khai báo ở đây (khớp mô tả trong thiết kế).
Chạy: python3 tools/data_builder/build_roster.py [nhóm...]   (nhóm 1–4; bỏ trống = tất cả)."""
import csv, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from build_characters import skill, status, opener, technique, character, ELCOL, EL, STAT  # noqa: E402
from roster_design import ROSTER  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DESIGN = {c["id"]: c for c in ROSTER}
GROUPS = {
    1: ["ignar", "marisol", "raiko", "zephyra", "vesper"],
    2: ["sylvaine", "orrin", "celestine", "quill", "aldric"],
    3: ["rook", "fenna", "kestrel", "vael", "wisp"],
    4: ["selka", "ember", "neris", "pip", "echo"],
}
E35 = [{"bonus": 0.15, "kinds": ["BASIC", "SKILL"]}, {"bonus": 0.15, "kinds": ["ULTIMATE"]}]
SHIELD = "shield"
# Tên/mô tả hiệu ứng mới (ghi vào file dịch).
STATUS_TEXT = {}


def st(sid, name, desc, *args, **kwargs):
    STATUS_TEXT[sid] = (name, desc)
    status(sid, *args, **kwargs)


def standard_eidolons(extra=None):
    """6 Tinh Mệnh: E3/E5 tăng hệ số; `extra` = {index: dict} cho Tinh Mệnh dạng số liệu."""
    result = [{}, {}, E35[0], {}, E35[1], {}]
    for k, v in (extra or {}).items():
        result[k - 1] = v
    return result


def basic(cid, stat="ATK", extra=()):
    skill("%s_basic" % cid, "BASIC", "SINGLE_ENEMY", [("damage", {"stat": stat, "mult": 1.0, "tough": 10})] + list(extra),
          sp=1, en=20)


def make_character(cid, eidolons):
    d = DESIGN[cid]
    (lv1, lv80) = d["stats"]
    ex = d.get("extras", {})
    full1 = (lv1[0], lv1[1], lv1[2], lv1[3], ex.get("crit_rate", 0.05), ex.get("crit_dmg", 0.5), 0,
             ex.get("energy_regen", 1.0), ex.get("effect_hit", 0.0), ex.get("outgoing_healing", 0.0))
    full80 = (lv80[0], lv80[1], lv80[2], lv1[3]) + full1[4:]
    color = ELCOL[EL[d["element"]]]
    character(cid, d["rarity"], d["element"], d["path"], d["energy"], full1, full80,
              [("default", "", color, "Color(1, 1, 1, 1)")], eidolons)
    o = d["opener"]
    opener("%s_opener" % cid, EL[d["element"]], o[2], o[3], o[4])


# ============================ NHÓM 1 ============================
def group1():
    # --- Ignar (Lửa, Hủy Diệt) ---
    basic("ignar")
    skill("ignar_skill", "SKILL", "BLAST_ENEMY", [("hp_cost", {"scope": "SELF", "ratio": 0.15}),
          ("damage", {"mult": 1.62, "adj": 0.81, "tough": 20, "tough_adj": 10})], sp=-1, en=30)
    skill("ignar_skill_enhanced", "SKILL", "ALL_ENEMIES", [("hp_cost", {"scope": "SELF", "ratio": 0.15}),
          ("damage", {"mult": 1.6, "tough": 20})], sp=-1, en=30)
    skill("ignar_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 2.44, "tough": 20})], en=5)
    st("ignar_fervor", "Nhiệt Huyết", "Tăng sát thương +8% mỗi tầng (tối đa 5).", "buff", "NH", ELCOL[0],
       dur=99, stacks=5, add=True, ignore=True, mods=[("DAMAGE_BONUS", 0.08, 0)])
    st("ignar_fervor_e2", "Nhiệt Huyết", "Tăng sát thương +8%, Tỉ Lệ Bạo Kích +3% mỗi tầng (tối đa 5).", "buff", "NH", ELCOL[0],
       dur=99, stacks=5, add=True, ignore=True, mods=[("DAMAGE_BONUS", 0.08, 0), ("CRIT_RATE", 0.03, 0)])
    st("ignar_iron_skin", "Da Sắt", "Phòng Thủ +40% khi dưới 30% máu.", "buff", "DS", ELCOL[0], dur=99, ignore=True,
       mods=[("DEF", 0, 0.4)])
    technique("ignar_technique", "MAP_ENEMIES", "DASH_TRAIL", [("tough_pct", {"scope": "ALL_ENEMIES", "ratio": 0.2})],
              distance=5, radius=1.5)
    make_character("ignar", standard_eidolons())

    # --- Marisol (Nước, Bảo Hộ) ---
    basic("marisol", "DEF")
    st("marisol_taunt", "Khiêu Khích", "Quái phải nhắm người này bằng đòn đơn/lan.", "buff", "KK", ELCOL[1], dur=1,
       ignore=True, taunt=True)
    st("marisol_tide_guard", "Đại Dương Bảo Hộ", "Phòng Thủ +20%.", "buff", "ĐD", ELCOL[1], dur=2, ignore=True,
       mods=[("DEF", 0, 0.2)])
    st("marisol_wave_coat", "Áo Choàng Sóng", "Phòng Thủ +30%.", "buff", "AS", ELCOL[1], dur=2, ignore=True,
       mods=[("DEF", 0, 0.3)])
    skill("marisol_skill", "SKILL", "SELF", [("shield", {"scope": "ALL_ALLIES", "mult": 0.2, "flat": 55, "status": SHIELD}),
          ("status", {"scope": "SELF", "status": "marisol_taunt"})], sp=-1, en=30)
    skill("marisol_ultimate", "ULTIMATE", "ALL_ALLIES", [("shield", {"mult": 0.27, "flat": 80, "status": SHIELD}),
          ("cleanse", {"count": 1}), ("status", {"status": "marisol_tide_guard"})], en=5)
    technique("marisol_technique", "NEXT_BATTLE", "NONE", [("status", {"scope": "ALL_ALLIES", "status": "marisol_wave_coat"})])
    make_character("marisol", standard_eidolons())

    # --- Raiko (Sét, Săn Bắn) ---
    basic("raiko")
    st("raiko_mark", "Dấu Sấm", "Nhận thêm Sát thương bạo kích từ Raiko; bị hạ thì dấu chuyển sang quái khác.", "debuff",
       "DS", ELCOL[2], dur=3, ignore=True)
    skill("raiko_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 1.47, "tough": 20}),
          ("status", {"status": "raiko_mark"})], sp=-1, en=30)
    skill("raiko_ultimate", "ULTIMATE", "SINGLE_ENEMY", [("damage", {"mult": 3.15, "tough": 30})], en=5)
    technique("raiko_technique", "MAP_ENEMIES", "ARROW", [("status", {"scope": "FIRST_ENEMY", "status": "raiko_mark"})],
              distance=8, duration=6)
    make_character("raiko", standard_eidolons())

    # --- Zephyra (Phong, Hòa Hợp) ---
    basic("zephyra")
    st("zephyra_tailwind", "Thuận Buồm", "Tốc Độ +20%.", "buff", "TB", ELCOL[3], dur=1, ignore=True, mods=[("SPD", 0, 0.2)])
    st("zephyra_gale", "Trời Lộng Gió", "Tăng sát thương +45%, Tốc Độ +10%.", "buff", "TL", ELCOL[3], dur=2, ignore=True,
       mods=[("DAMAGE_BONUS", 0.45, 0), ("SPD", 0, 0.1)])
    skill("zephyra_skill", "SKILL", "SINGLE_ALLY", [("turn", {"amount": 1.0}), ("status", {"status": "zephyra_tailwind"})],
          sp=-1, en=30, self_ok=False)
    skill("zephyra_ultimate", "ULTIMATE", "ALL_ALLIES", [("turn", {"amount": 0.25}), ("status", {"status": "zephyra_gale"})], en=5)
    technique("zephyra_technique", "EXPLORATION", "SPEED_BOOST", [], duration=15, speed=0.4)
    make_character("zephyra", standard_eidolons())

    # --- Vesper (Độc, Hư Vô) ---
    basic("vesper")
    st("vesper_poison", "Độc Vesper", "Chịu sát thương Độc đầu mỗi lượt; quái bị hạ thì độc lan sang bên cạnh.", "debuff",
       "ĐV", ELCOL[4], dur=3, chance=1.0, dot=(3, EL["poison"], 0.12))
    st("vesper_weaken", "Kháng Thể Ngược", "Kháng Hiệu Ứng −10%.", "debuff", "KT", ELCOL[4], dur=3, chance=1.0,
       mods=[("EFFECT_RES", -0.1, 0)])
    skill("vesper_skill", "SKILL", "BLAST_ENEMY", [("damage", {"mult": 0.3, "adj": 0.3, "tough": 20}),
          ("status", {"status": "vesper_poison", "base_mult": 1.0})], sp=-1, en=30)
    skill("vesper_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 0.4, "tough": 10})], en=5)
    technique("vesper_technique", "MAP_ENEMIES", "FIREWORK_DAZE",
              [("status", {"scope": "ALL_ENEMIES", "status": "vesper_poison", "base_mult": 1.0})],
              distance=0, radius=3, duration=10)
    make_character("vesper", standard_eidolons())


# ============================ NHÓM 2 ============================
def group2():
    # --- Sylvaine (Mộc, Trù Phú) ---
    basic("sylvaine")
    skill("sylvaine_tree_heal", "FOLLOW_UP", "SINGLE_ALLY", [("heal", {"target_max_hp": True, "mult": 0.06})])
    tree = {"name_key": "SUMMON_SYLVAINE_TREE", "letter": "C", "color": ELCOL[5], "speed": 80, "hp_ratio": 0.5,
            "skill": "sylvaine_tree_heal", "turns": 3}
    skill("sylvaine_skill", "SKILL", "ALL_ALLIES", [("heal", {"mult": 0.12, "flat": 33}),
          ("summon", dict(tree, scope="SELF", only_if_absent=True))], sp=-1, en=30)
    skill("sylvaine_ultimate", "ULTIMATE", "ALL_ALLIES", [("heal", {"mult": 0.19, "flat": 57}),
          ("revive", {"scope": "SELF", "ratio": 0.4, "uses": 1})], en=5)
    technique("sylvaine_technique", "NEXT_BATTLE", "NONE", [("summon", dict(tree, scope="SELF"))])
    make_character("sylvaine", standard_eidolons())

    # --- Orrin (Hồn, Tri Thức) ---
    basic("orrin")
    skill("orrin_skill", "SKILL", "ALL_ENEMIES", [("damage", {"mult": 0.56, "tough": 10})], sp=-1, en=30)
    skill("orrin_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 1.28, "tough": 20})], en=5)
    technique("orrin_technique", "EXPLORATION", "REVEAL_SECRETS", [], duration=60)
    make_character("orrin", standard_eidolons())

    # --- Celestine (Hồn, Săn Bắn, giới hạn) ---
    st("celestine_watch", "Canh Giữ", "Tốc Độ +20%. Đánh thường cho thêm năng lượng.", "buff", "CG", ELCOL[6], dur=999,
       ignore=True, mods=[("SPD", 0, 0.2)])
    st("celestine_judgment", "Phán Xử", "Sát thương bạo kích +50%, Tỉ Lệ Bạo Kích +15%.", "buff", "PX", ELCOL[6], dur=999,
       ignore=True, mods=[("CRIT_DMG", 0.5, 0), ("CRIT_RATE", 0.15, 0)])
    st("celestine_judgment_e2", "Phán Xử", "Sát thương bạo kích +50%, Tỉ Lệ Bạo Kích +15%, Tăng sát thương +20%.", "buff",
       "PX", ELCOL[6], dur=999, ignore=True, mods=[("CRIT_DMG", 0.5, 0), ("CRIT_RATE", 0.15, 0), ("DAMAGE_BONUS", 0.2, 0)])
    basic("celestine", extra=[("energy", {"scope": "SELF", "amount": 10})])
    skill("celestine_basic_judgment", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.6, "tough": 10})], sp=1, en=20)
    skill("celestine_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 2.8, "tough": 20})], sp=-1, en=30)
    skill("celestine_skill_judgment", "SKILL", "SELF", [("turn", {"scope": "SELF", "amount": 0.3})], sp=-1, en=30)
    skill("celestine_ultimate", "ULTIMATE", "SINGLE_ENEMY", [("damage", {"mult": 5.5, "tough": 30})], en=5)
    technique("celestine_technique", "NEXT_BATTLE", "NONE", [("sp", {"scope": "SELF", "amount": 2}),
              ("status", {"scope": "SELF", "status": "celestine_judgment"})])
    make_character("celestine", standard_eidolons())

    # --- Quill (Độc, Trù Phú) ---
    basic("quill")
    st("quill_poison", "Độc Quill", "Chịu sát thương Độc đầu mỗi lượt.", "debuff", "ĐQ", ELCOL[4], dur=2, chance=1.0,
       dot=(3, EL["poison"], 0.4))
    st("quill_resist", "Kháng Sinh", "Kháng Hiệu Ứng +20%.", "buff", "KS", ELCOL[4], dur=2, ignore=True,
       mods=[("EFFECT_RES", 0.2, 0)])
    skill("quill_skill", "SKILL", "SINGLE_ALLY", [("heal", {"mult": 0.35, "flat": 70}),
          ("status", {"scope": "RANDOM_ENEMY", "status": "quill_poison", "base_mult": 1.0})], sp=-1, en=30)
    skill("quill_ultimate", "ULTIMATE", "ALL_ALLIES", [("heal", {"mult": 0.25, "flat": 60}), ("cleanse", {"count": 1})], en=5)
    technique("quill_technique", "EXPLORATION", "HEAL_TEAM", [])
    make_character("quill", standard_eidolons())

    # --- Aldric (Phong, Bảo Hộ) ---
    basic("aldric", "DEF")
    skill("aldric_skill", "SKILL", "SINGLE_ALLY", [("shield", {"mult": 0.4, "flat": 100, "status": SHIELD}),
          ("shield", {"scope": "SELF", "mult": 0.2, "flat": 50, "status": SHIELD})], sp=-1, en=30)
    skill("aldric_ultimate", "ULTIMATE", "ALL_ALLIES", [("shield", {"mult": 0.3, "flat": 80, "status": SHIELD}),
          ("damage", {"scope": "ALL_ENEMIES", "stat": "DEF", "mult": 0.7, "tough": 20})], en=5)
    technique("aldric_technique", "NEXT_BATTLE", "NONE", [("turn", {"scope": "ALL_ENEMIES", "amount": -0.2})])
    make_character("aldric", standard_eidolons())


# ============================ NHÓM 3 ============================
def group3():
    # --- Rook (Mộc, Hủy Diệt) ---
    basic("rook")
    st("rook_revenge", "Báo Thù", "Tấn Công +25% mỗi tầng (tối đa 3).", "buff", "BT", ELCOL[5], dur=999, stacks=3, add=True,
       ignore=True, mods=[("ATK", 0, 0.25)])
    st("rook_revenge_e4", "Báo Thù", "Tấn Công +25%, Phòng Thủ +10% mỗi tầng (tối đa 3).", "buff", "BT", ELCOL[5], dur=999,
       stacks=3, add=True, ignore=True, mods=[("ATK", 0, 0.25), ("DEF", 0, 0.1)])
    skill("rook_skill", "SKILL", "BLAST_ENEMY", [("damage", {"mult": 1.4, "adj": 0.7, "tough": 20, "tough_adj": 10})], sp=-1, en=30)
    skill("rook_ultimate", "ULTIMATE", "BLAST_ENEMY", [("damage", {"mult": 2.4, "adj": 1.4, "tough": 30, "tough_adj": 20})], en=5)
    technique("rook_technique", "MAP_ENEMIES", "FIREWORK_DAZE",
              [("status", {"scope": "ALL_ENEMIES", "status": "entangle"})], distance=2, radius=2, duration=8)
    make_character("rook", standard_eidolons())

    # --- Fenna (Mộc, Săn Bắn) ---
    basic("fenna")
    skill("fenna_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 1.8, "tough": 20})], sp=-1, en=30)
    skill("fenna_ultimate", "ULTIMATE", "SINGLE_ENEMY", [("damage", {"mult": 3.6, "tough": 30})], en=5)
    skill("fenna_arrow", "FOLLOW_UP", "SINGLE_ENEMY", [("damage", {"mult": 0.6, "tough": 5})])
    technique("fenna_technique", "MAP_ENEMIES", "TRAP", [], radius=1.0, duration=8, force_adv=True)
    make_character("fenna", standard_eidolons())

    # --- Kestrel (Phong, Hủy Diệt) ---
    basic("kestrel")
    st("kestrel_gale", "Lốc Tích Tụ", "Xoáy Liềm +20% hệ số mỗi tầng (tối đa 3).", "buff", "LT", ELCOL[3], dur=999, stacks=3,
       add=True, ignore=True)
    st("kestrel_gale_e4", "Lốc Tích Tụ", "Xoáy Liềm +20% hệ số, Tốc Độ +4% mỗi tầng (tối đa 3).", "buff", "LT", ELCOL[3],
       dur=999, stacks=3, add=True, ignore=True, mods=[("SPD", 0, 0.04)])
    skill("kestrel_skill", "SKILL", "BLAST_ENEMY", [("damage", {"mult": 1.3, "adj": 0.65, "tough": 20, "tough_adj": 10})], sp=-1, en=30)
    skill("kestrel_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 2.0, "tough": 20})], en=5)
    technique("kestrel_technique", "EXPLORATION", "LONG_DASH", [], distance=6)
    make_character("kestrel", standard_eidolons())

    # --- Vael (Độc, Tri Thức) ---
    basic("vael")
    st("vael_def_down", "Mở Màn", "Phòng Thủ −10%.", "debuff", "MM", ELCOL[4], dur=2, chance=0.5,
       mods=[("DEF_REDUCTION", 0.1, 0)])
    skill("vael_skill", "SKILL", "ALL_ENEMIES", [("damage", {"mult": 0.9, "tough": 10})], sp=-1, en=30)
    skill("vael_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 1.8, "tough": 20})], en=5)
    technique("vael_technique", "MAP_ENEMIES", "FIREWORK_DAZE", [("maxhp", {"scope": "ALL_ENEMIES", "ratio": 0.1})],
              distance=3, radius=2, duration=0)
    make_character("vael", standard_eidolons())

    # --- Wisp (Phong, Hư Vô) ---
    basic("wisp")
    st("wisp_forget", "Lãng Quên", "Tốc Độ −12%.", "debuff", "LQ", ELCOL[3], dur=2, chance=1.0, mods=[("SPD", 0, -0.12)])
    st("wisp_weaken", "Yếu Ớt", "Tấn Công −15%.", "debuff", "YO", ELCOL[3], dur=2, chance=1.0, mods=[("ATK", 0, -0.15)])
    skill("wisp_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 0.7, "tough": 20}), ("status", {"status": "wisp_forget"}),
          ("status", {"status": "wisp_weaken"})], sp=-1, en=30)
    skill("wisp_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 0.6, "tough": 20}),
          ("status", {"status": "wisp_forget"})], en=5)
    technique("wisp_technique", "EXPLORATION", "MAGNET", [], radius=6, duration=20)
    make_character("wisp", standard_eidolons({1: {"mods": [("EFFECT_HIT", 0.2, 0)]}}))


# ============================ NHÓM 4 ============================
def group4():
    # --- Selka (Độc, Hòa Hợp) ---
    basic("selka")
    st("selka_courage", "Hương Dũng Khí", "Tấn Công +25%, Tăng sát thương +15%.", "buff", "DK", ELCOL[4], dur=2, ignore=True,
       mods=[("ATK", 0, 0.25), ("DAMAGE_BONUS", 0.15, 0)])
    st("selka_chorus", "Hội Tụ Hương", "Tăng sát thương +20%.", "buff", "HT", ELCOL[4], dur=2, ignore=True,
       mods=[("DAMAGE_BONUS", 0.2, 0)])
    st("selka_harmony", "Đồng Điệu", "Tăng sát thương +8% mỗi cặp đồng minh cùng nguyên tố (tối đa 3).", "buff", "ĐĐ", ELCOL[4],
       dur=999, stacks=3, add=True, ignore=True, mods=[("DAMAGE_BONUS", 0.08, 0)])
    st("selka_harmony_e6", "Đồng Điệu", "Tăng sát thương +10% mỗi cặp đồng minh cùng nguyên tố (tối đa 3).", "buff", "ĐĐ",
       ELCOL[4], dur=999, stacks=3, add=True, ignore=True, mods=[("DAMAGE_BONUS", 0.1, 0)])
    st("selka_resonance", "Cộng Hưởng Hương", "Tấn Công +10%.", "buff", "CH", ELCOL[4], dur=2, ignore=True,
       mods=[("ATK", 0, 0.1)])
    st("selka_aroma", "Hương Đồng Điệu", "Tấn Công +15%.", "buff", "HĐ", ELCOL[4], dur=3, ignore=True, mods=[("ATK", 0, 0.15)])
    skill("selka_skill", "SKILL", "SINGLE_ALLY", [("status", {"status": "selka_courage"})], sp=-1, en=30)
    skill("selka_ultimate", "ULTIMATE", "ALL_ALLIES", [("status", {"status": "selka_chorus"}), ("energy", {"amount": 10})], en=5)
    technique("selka_technique", "NEXT_BATTLE", "NONE", [("status", {"scope": "ALL_ALLIES", "status": "selka_aroma"})])
    make_character("selka", standard_eidolons())

    # --- Ember (Lửa, Tri Thức) ---
    basic("ember")
    skill("ember_skill", "SKILL", "ALL_ENEMIES", [("damage", {"mult": 0.85, "tough": 10})], sp=-1, en=30)
    skill("ember_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 1.7, "tough": 20})], en=5)
    technique("ember_technique", "MAP_ENEMIES", "FIREWORK_DAZE", [("tough_pct", {"scope": "ALL_ENEMIES", "ratio": 0.15})],
              distance=0, radius=3, duration=0)
    make_character("ember", standard_eidolons())

    # --- Neris (Nước, Săn Bắn) ---
    basic("neris")
    st("neris_patience", "Nhẫn Nại", "Tỉ Lệ Bạo Kích +12% mỗi tầng; bạo kích thì mất hết.", "buff", "NN", ELCOL[1], dur=999,
       stacks=10, add=True, ignore=True, mods=[("CRIT_RATE", 0.12, 0)])
    st("neris_patience_e1", "Nhẫn Nại", "Tỉ Lệ Bạo Kích +15% mỗi tầng; bạo kích thì mất hết.", "buff", "NN", ELCOL[1], dur=999,
       stacks=10, add=True, ignore=True, mods=[("CRIT_RATE", 0.15, 0)])
    skill("neris_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 1.9, "tough": 20})], sp=-1, en=30)
    skill("neris_ultimate", "ULTIMATE", "SINGLE_ENEMY", [("damage", {"mult": 3.8, "tough": 30})], en=5)
    technique("neris_technique", "EXPLORATION", "REVEAL_ENEMIES", [], duration=30)
    make_character("neris", standard_eidolons())

    # --- Pip (Sét, Hòa Hợp) ---
    basic("pip")
    st("pip_charge", "Sạc Nhanh", "Tấn Công +15%.", "buff", "SN", ELCOL[2], dur=2, ignore=True, mods=[("ATK", 0, 0.15)])
    st("pip_overvolt", "Quá Áp", "Tốc Độ +12%.", "buff", "QA", ELCOL[2], dur=2, ignore=True, mods=[("SPD", 0, 0.12)])
    skill("pip_skill", "SKILL", "SINGLE_ALLY", [("energy", {"amount": 25}), ("status", {"status": "pip_charge"})],
          sp=-1, en=30, self_ok=False)
    skill("pip_ultimate", "ULTIMATE", "ALL_ALLIES", [("energy", {"amount": 20}), ("status", {"status": "pip_overvolt"})], en=5)
    technique("pip_technique", "NEXT_BATTLE", "NONE", [("energy", {"scope": "ALL_ALLIES", "amount": 30})])
    make_character("pip", standard_eidolons())

    # --- Echo (Hồn, Hư Vô) ---
    basic("echo")
    st("echo_crack", "Rạn Hồn", "Dễ tổn thương +12%.", "debuff", "RH", ELCOL[6], dur=2, chance=1.0,
       mods=[("VULNERABILITY", 0.12, 0)])
    skill("echo_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 0.75, "tough": 20}), ("status", {"status": "echo_crack"})],
          sp=-1, en=30)
    skill("echo_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 0.7, "tough": 20})], en=5)
    technique("echo_technique", "EXPLORATION", "RETURN_TO_REST", [])
    make_character("echo", standard_eidolons())


# ============================ Dịch ============================
def write_translations(ids):
    path = os.path.join(ROOT, "localization", "roster.csv")
    rows = {}
    if os.path.exists(path):
        with open(path) as f:
            for r in list(csv.reader(f))[1:]:
                rows[r[0]] = r
    def put(key, text):
        # Bản tiếng Anh tạm dùng lại tiếng Việt (dịch sau, xem DESIGN_NOTES Phase 7).
        rows[key] = [key, text, text]
    for cid in ids:
        d = DESIGN[cid]
        up = cid.upper()
        put("CHAR_%s_NAME" % up, d["name"])
        put("SKILL_%s_OPENER" % up, d["opener"][0])
        put("SKILL_%s_TECHNIQUE" % up, d["technique"][0])
        put("SKILL_%s_TECHNIQUE_DESC" % up, d["technique"][2])
        for key in ("basic", "skill"):
            put("SKILL_%s_%s" % (up, key.upper()), d[key][0])
            put("SKILL_%s_%s_DESC" % (up, key.upper()), d[key][1])
        put("SKILL_%s_ULTIMATE" % up, d["ultimate"][0])
        put("SKILL_%s_ULTIMATE_DESC" % up, d["ultimate"][2])
        put("TALENT_%s" % up, d["talent"][0])
        put("TALENT_%s_DESC" % up, d["talent"][2])
        for i, (name, desc) in enumerate(d["eidolons"]):
            put("EIDOLON_%s_%d" % (up, i + 1), name)
            put("EIDOLON_%s_%d_DESC" % (up, i + 1), desc)
    for sid, (name, desc) in STATUS_TEXT.items():
        put("STATUS_%s" % sid.upper(), name)
        put("STATUS_%s_DESC" % sid.upper(), desc)
    for key, text in EXTRA_TEXT.items():
        put(key, text)
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["keys", "vi", "en"])
        for key in sorted(rows):
            w.writerow(rows[key])


# Chuỗi phụ (tên kỹ năng biến thể, vật triệu hồi...).
EXTRA_TEXT = {
    "SKILL_IGNAR_SKILL_ENHANCED": "Lò Rèn Tự Thiêu (cường hóa)",
    "SKILL_IGNAR_SKILL_ENHANCED_DESC": "Tiêu 15% máu hiện tại. 160% Tấn Công lên toàn bộ quái.",
    "SKILL_SYLVAINE_TREE_HEAL": "Nhựa Sống",
    "SKILL_SYLVAINE_TREE_HEAL_DESC": "Hồi đồng minh ít máu nhất 6% máu tối đa.",
    "SUMMON_SYLVAINE_TREE": "Cây Sự Sống",
    "SKILL_CELESTINE_BASIC_JUDGMENT": "Nhát Phán",
    "SKILL_CELESTINE_BASIC_JUDGMENT_DESC": "Tư thế Phán Xử: 130% Tấn Công lên 1 quái.",
    "SKILL_CELESTINE_SKILL_JUDGMENT": "Đổi Kiếm (về Canh Giữ)",
    "SKILL_CELESTINE_SKILL_JUDGMENT_DESC": "Về tư thế Canh Giữ và kéo lượt bản thân 30%.",
    "BATTLE_SUMMONED": "Triệu hồi!",
    "BATTLE_INTERCEPTED": "Đỡ thay!",
    "BATTLE_BLAST": "Nổ!",
    "ENEMY_BALANCE_BRUTE": "Quái Thử Sức",
    "SANDBOX_SETUP": "Đội & quái…",
    "SANDBOX_ENCOUNTER": "Trận quái:",
    "SANDBOX_LEVEL": "Cấp đội:",
    "SKILL_FENNA_ARROW": "Mũi Tên Thứ Hai",
    "SKILL_FENNA_ARROW_DESC": "60% Tấn Công lên quái đang Phá Vỡ.",
    "TOAST_TEAM_HEALED": "Đã hồi %d%% máu cả đội",
}


if __name__ == "__main__":
    wanted = [int(a) for a in sys.argv[1:]] or [1, 2, 3, 4]
    builders = {1: group1, 2: group2, 3: group3, 4: group4}
    ids = []
    for g in wanted:
        if g in builders:
            builders[g]()
            ids += GROUPS[g]
    write_translations(ids)
    print("Xong nhóm", wanted, ":", ", ".join(ids))

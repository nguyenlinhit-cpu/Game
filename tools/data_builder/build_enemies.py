#!/usr/bin/env python3
"""Sinh dữ liệu quái Phase 8: 8 quái thường (mỗi loại ≥2 biến thể nguyên tố), 3 tinh anh, 4 boss nhiều giai đoạn,
kỹ năng, hiệu ứng, EncounterData cho 4 khu, file dịch localization/enemies.csv và docs/ENEMIES.md.
Chạy: python3 tools/data_builder/build_enemies.py   (từ thư mục dự án). Ghi đè file cũ.
Cân bằng: sửa số ở đây rồi chạy lại (hoặc sửa thẳng .tres trong editor), kiểm bằng tools/balance/boss_report.tscn."""
import csv, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from build_characters import Tres, res, f, skill, status, EL, STAT, ELCOL  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
os.chdir(ROOT)

EL_NAME = {"fire": ("Lửa", "Fire"), "water": ("Nước", "Water"), "lightning": ("Sét", "Lightning"), "wind": ("Phong", "Wind"),
           "poison": ("Độc", "Poison"), "wood": ("Mộc", "Wood"), "soul": ("Hồn", "Soul")}
KIND = {"normal": 0, "elite": 1, "boss": 2}
RULE = {"AGGRO": 0, "LOWEST_HP": 1, "HIGHEST_ATK": 2, "RANDOM": 3, "MARKED": 4, "MOST_BUFFS": 5}
# Đường cong chỉ số "quái chuẩn" (cấp 1 / cấp 80); từng loại nhân hệ số máu / tấn công.
BASE_LV1 = {"hp": 90.0, "atk": 30.0, "def": 50.0}
BASE_LV80 = {"hp": 900.0, "atk": 240.0, "def": 500.0}
DEBUFF_COL = "Color(0.55, 0.3, 0.75, 1)"

TEXT = {}      # key -> (vi, en)
DOC = []       # dòng cho docs/ENEMIES.md


def text(key, vi, en=None):
    TEXT[key] = (vi, en or vi)


def eskill(sid, name, desc, target, effects, kind="BASIC"):
    """Kỹ năng quái (tên/mô tả ghi vào file dịch)."""
    text("SKILL_%s" % sid.upper(), *name)
    text("SKILL_%s_DESC" % sid.upper(), *desc)
    skill(sid, kind, target, effects)
    return sid


def estatus(sid, name, desc, *args, **kwargs):
    text("STATUS_%s" % sid.upper(), *name)
    text("STATUS_%s_DESC" % sid.upper(), *desc)
    status(sid, *args, **kwargs)
    return sid


def act(sid, w=1.0, **kw):
    """Một EnemyAction: kỹ năng + trọng số + tuỳ chọn (xem systems/resources/enemy_action.gd)."""
    d = {"skill": sid, "weight": w}
    d.update(kw)
    return d


ACTION_FIELDS = [  # (khóa trong builder, tên thuộc tính, kiểu)
    ("rule", "target_rule", "rule"), ("min_hp", "min_hp_ratio", "f"), ("max_hp", "max_hp_ratio", "f"),
    ("cd", "cooldown_turns", "i"), ("first", "first_turn", "i"), ("uses", "max_uses", "i"),
    ("family_max", "max_family_alive", "i"), ("slot", "needs_free_slot", "b"), ("foe_status", "requires_foe_status", "s"),
    ("foe_buff", "requires_foe_buff", "b"), ("self_status", "self_status", "s"), ("self_stacks", "self_status_min_stacks", "i"),
    ("priority", "priority", "b"), ("phase_start", "priority_on_phase_start", "b"),
    ("low_hp", "low_hp_weight_mult", "f"), ("ally_fallen", "ally_fallen_weight_mult", "f"),
    ("after_break", "after_break_weight_mult", "f"), ("injured", "injured_ally_weight_mult", "f"),
    ("charge", "charge_turns", "i"), ("act_charging", "act_while_charging", "b"), ("cancel_break", "cancel_on_break", "b"),
    ("cancel_dmg", "cancel_damage_ratio", "f"),
]


def action_refs(t, actions, prefix):
    script = res("systems/resources/enemy_action.gd")
    refs = []
    for i, a in enumerate(actions):
        props = [("skill", t.ext_id("Resource", res("data/skills/%s.tres" % a["skill"]))), ("weight", f(a["weight"]))]
        for key, name, kind in ACTION_FIELDS:
            if key not in a:
                continue
            v = a[key]
            props.append((name, RULE[v] if kind == "rule" else f(v) if kind == "f" else str(int(v)) if kind == "i"
                          else ("true" if v else "false") if kind == "b" else '&"%s"' % v))
        refs.append(t.sub("%s_%d" % (prefix, i + 1), script, props))
    return "Array[%s]([%s])" % (t.ext_id("Script", script), ", ".join(refs))


def stat_block(t, sid, values):
    return t.sub(sid, res("systems/resources/stat_block.gd"), [(k, f(v)) for k, v in values.items()])


def mods_ref(t, mods, prefix):
    script = res("systems/resources/stat_modifier_data.gd")
    refs = [t.sub("%s_%d" % (prefix, i), script, [("stat", STAT[m[0]]), ("flat", f(m[1])), ("percent", f(m[2]))])
            for i, m in enumerate(mods)]
    return "Array[%s]([%s])" % (t.ext_id("Script", script), ", ".join(refs))


def enemy(eid, name, desc, kind, family, element, weak, tough, color, hp, atk, spd, actions, eres=0.0, death=None,
          behavior=None, params=None, phases=(), music="", size=1.0, doc_role=""):
    t = Tres("EnemyData", res("systems/resources/enemy_data.gd"))
    text("ENEMY_%s" % eid.upper(), *name)
    text("ENEMY_%s_DESC" % eid.upper(), *desc)
    lv1 = dict(hp=BASE_LV1["hp"] * hp, atk=BASE_LV1["atk"] * atk, defense=BASE_LV1["def"], spd=spd, effect_res=eres)
    lv80 = dict(hp=BASE_LV80["hp"] * hp, atk=BASE_LV80["atk"] * atk, defense=BASE_LV80["def"], spd=spd, effect_res=eres)
    s1 = stat_block(t, "Stats_lv1", {("def" if k == "defense" else k): v for k, v in lv1.items()})
    s80 = stat_block(t, "Stats_lv80", {("def" if k == "defense" else k): v for k, v in lv80.items()})
    props = [("id", '&"%s"' % eid), ("name_key", '"ENEMY_%s"' % eid.upper()), ("desc_key", '"ENEMY_%s_DESC"' % eid.upper()),
             ("kind", KIND[kind]), ("family", '&"%s"' % family), ("element", EL[element]),
             ("weaknesses", "Array[int]([%s])" % ", ".join(str(EL[w]) for w in weak)),
             ("max_toughness", f(tough)), ("placeholder_color", color), ("size_scale", f(size)),
             ("stats_lv1", s1), ("stats_lv80", s80), ("actions", action_refs(t, actions, "Action"))]
    if death:
        props.append(("death_skill", t.ext_id("Resource", res("data/skills/%s.tres" % death))))
    if behavior:
        props.append(("behavior_script", t.ext_id("Script", res("data/enemies/scripts/%s.gd" % behavior))))
    if params:
        items = []
        for k, v in params.items():
            if isinstance(v, tuple) and v[0] == "res":
                items.append('"%s": %s' % (k, t.ext_id("Resource", res(v[1]))))
            elif isinstance(v, tuple) and v[0] == "enemies":
                items.append('"%s": [%s]' % (k, ", ".join(t.ext_id("Resource", res("data/enemies/%s.tres" % e)) for e in v[1])))
            elif isinstance(v, str):
                items.append('"%s": &"%s"' % (k, v))
            else:
                items.append('"%s": %s' % (k, v))
        props.append(("behavior_params", "{\n%s\n}" % ",\n".join(items)))
    phase_refs = []
    for i, p in enumerate(phases):
        key = "BOSS_PHASE_%s_%d" % (eid.upper(), i + 2)
        text(key, *p["name"])
        pp = [("name_key", '"%s"' % key), ("hp_threshold", f(p["hp"]))]
        if p.get("weak"):
            pp.append(("weaknesses", "Array[int]([%s])" % ", ".join(str(EL[w]) for w in p["weak"])))
        if p.get("tough"):
            pp.append(("max_toughness", f(p["tough"])))
        if p.get("actions"):
            pp.append(("actions", action_refs(t, p["actions"], "Phase%d_Action" % (i + 2))))
        if p.get("mods"):
            pp.append(("stat_modifiers", mods_ref(t, p["mods"], "Phase%d_Mod" % (i + 2))))
        if p.get("advance"):
            pp.append(("action_advance", f(p["advance"])))
        pp += [("color", p.get("color", color)), ("music_id", '&"%s"' % p.get("music", ""))]
        phase_refs.append(t.sub("Phase_%d" % (i + 2), res("systems/resources/boss_phase_data.gd"), pp))
    if phase_refs:
        props.append(("phases", "Array[%s]([%s])" % (t.ext_id("Script", res("systems/resources/boss_phase_data.gd")),
                                                       ", ".join(phase_refs))))
    if music:
        props.append(("music_id", '&"%s"' % music))
    t.write("data/enemies/%s.tres" % eid, props)
    DOC.append(dict(id=eid, name=name[0], kind=kind, element=element, weak=weak, tough=tough, hp=hp, atk=atk, spd=spd,
                    role=doc_role, desc=desc[0], phases=[(p["name"][0], p["hp"], p.get("weak") or weak) for p in phases]))


def encounter(eid, zone, kind, rec, waves, music=""):
    """waves: [[(enemy_id, level, count), ...], ...]"""
    t = Tres("EncounterData", res("systems/resources/encounter_data.gd"))
    entry_script = res("systems/resources/encounter_enemy_entry.gd")
    wave_script = res("systems/resources/encounter_wave.gd")
    wave_refs = []
    for wi, wave in enumerate(waves):
        entries = [t.sub("Entry_w%d_%d" % (wi + 1, ei + 1), entry_script,
                         [("enemy", t.ext_id("Resource", res("data/enemies/%s.tres" % e))), ("level", lv), ("count", n)])
                   for ei, (e, lv, n) in enumerate(wave)]
        wave_refs.append(t.sub("Wave_%d" % (wi + 1), wave_script,
                               [("entries", "Array[%s]([%s])" % (t.ext_id("Script", entry_script), ", ".join(entries)))]))
    props = [("id", '&"%s"' % eid), ("waves", "Array[%s]([%s])" % (t.ext_id("Script", wave_script), ", ".join(wave_refs))),
             ("kind", KIND[kind]), ("zone", '&"%s"' % zone), ("recommended_level", rec)]
    if music:
        props.append(("music_id", '&"%s"' % music))
    t.write("data/encounters/%s.tres" % eid, props)
    ENCOUNTERS.append((eid, zone, kind, rec, waves))


ENCOUNTERS = []


# ============================ Hiệu ứng ============================
def build_statuses():
    estatus("en_guard", ("Thủ Thế", "Guard Stance"), ("Giảm 40% sát thương nhận.", "Takes 40% less damage."),
            "buff", "Th", "Color(0.75, 0.75, 0.8, 1)", dur=1, ignore=True, mods=[("VULNERABILITY", -0.4, 0)])
    estatus("en_void_mark", ("Bị Ngắm", "Targeted"), ("Xạ Thủ Hư Không sẽ bắn gấp đôi vào người này ở lượt sau.",
            "The Void Archer will fire a double shot at this target next turn."),
            "debuff", "⌖", "Color(0.9, 0.3, 0.35, 1)", dur=3, ignore=True)
    for el, (vi, en) in [("fire", ("Bỏng Ma Biến", "Warp Burn")), ("poison", ("Độc Ma Biến", "Warp Venom")),
                         ("wind", ("Gió Cắt Ma Biến", "Warp Shear")), ("lightning", ("Điện Ma Biến", "Warp Shock"))]:
        estatus("en_hex_%s" % el, (vi, en), ("Mất máu đầu mỗi lượt (theo Tấn Công của Pháp Sư Méo).",
                "Loses HP at the start of each turn (scales with the Warped Mage's ATK)."),
                "debuff", vi[0] + "M", ELCOL[EL[el]], dur=2, chance=0.9, dot=(3, EL[el], 0.45))
    estatus("en_bee_venom", ("Nọc Ong", "Bee Venom"), ("Mất máu đầu mỗi lượt.", "Loses HP at the start of each turn."),
            "debuff", "NO", ELCOL[EL["poison"]], dur=2, chance=0.6, dot=(3, EL["poison"], 0.3))
    estatus("en_seal", ("Phong Ấn", "Sealed"), ("Không dùng được Chiến kỹ.", "Cannot use Skill."),
            "debuff", "PA", DEBUFF_COL, dur=2, chance=1.0, extra=[("seal_skill", "true")])
    estatus("en_curse_seal", ("Lời Nguyền Câm Lặng", "Curse of Silence"), ("Cả đội không dùng được Chiến kỹ.",
            "The whole team cannot use Skills."), "debuff", "NG", DEBUFF_COL, dur=2, ignore=True, extra=[("seal_skill", "true")])
    estatus("en_frozen", ("Đông Cứng", "Frozen Solid"), ("Mất lượt kế tiếp.", "Loses the next turn."),
            "debuff", "ĐC", "Color(0.6, 0.85, 1, 1)", dur=1, chance=0.8, extra=[("skip_turn", "true")])
    estatus("en_heat", ("Nhiệt", "Heat"), ("Đủ 5 tầng thì Lõi Lò nổ cả đội. Phá Vỡ giảm 3 tầng.",
            "At 5 stacks the Core explodes on the whole team. Breaking it removes 3 stacks."),
            "buff", "N", ELCOL[EL["fire"]], dur=99, stacks=5, add=True, ignore=True)


# ============================ Quái thường ============================
SPECIES = {}


def species(fid, name, desc, role, color, hp, atk, spd, tough, actions, death=None, eres=0.0):
    SPECIES[fid] = dict(name=name, desc=desc, role=role, color=color, hp=hp, atk=atk, spd=spd, tough=tough,
                        actions=actions, death=death, eres=eres)


def variant(fid, element, weak, actions=None):
    sp = SPECIES[fid]
    eid = "%s_%s" % (fid, element)
    vi, en = EL_NAME[element]
    enemy(eid, ("%s %s" % (sp["name"][0], vi), "%s %s" % (en, sp["name"][1])), sp["desc"], "normal", fid, element, weak,
          sp["tough"], sp["color"], sp["hp"], sp["atk"], sp["spd"], actions or sp["actions"], eres=sp["eres"],
          death=sp["death"], doc_role=sp["role"])
    return eid


def build_normals():
    # Mầm Ma Biến – yếu, đông, nổ khi chết.
    eskill("en_sprout_bite", ("Cắn", "Bite"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."), "SINGLE_ENEMY",
           [("damage", {"mult": 1.0})])
    eskill("en_sprout_burst", ("Nổ Mầm", "Sprout Burst"), ("Khi chết: 45% Tấn Công lên cả đội.", "On death: 45% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.45})], kind="FOLLOW_UP")
    species("warp_sprout", ("Mầm Ma Biến", "Warp Sprout"), ("Mầm nhỏ nhiễm Ma Biến, đi thành bầy, nổ tung khi bị hạ.",
            "Tiny warp-infected sprouts that come in swarms and burst when defeated."), "Yếu, đông",
            "Color(0.56, 0.16, 0.23, 1)", 0.6, 0.8, 90, 20, [act("en_sprout_bite")], death="en_sprout_burst")
    # Hồn Ảnh Lang Thang – hỗ trợ, tạo khiên cho quái đồng minh.
    eskill("en_shade_touch", ("Chạm Lạnh", "Cold Touch"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_shade_veil", ("Màn Hồn", "Soul Veil"), ("Tạo khiên (50% Phòng Thủ) cho mọi quái đồng minh trong 2 lượt.",
           "Shields all allied monsters (50% DEF) for 2 turns."), "ALL_ALLIES",
           [("shield", {"scope": "ALL_ALLIES", "stat": "DEF", "mult": 0.5, "status": "shield"})], kind="SKILL")
    species("wandering_shade", ("Hồn Ảnh Lang Thang", "Wandering Shade"), ("Linh hồn lạc lối che chắn cho đồng bọn.",
            "A lost spirit that shields its companions."), "Hỗ trợ", "Color(0.42, 0.45, 0.62, 1)", 0.9, 0.8, 105, 30,
            [act("en_shade_touch", 2), act("en_shade_veil", 1, cd=2, injured=3.0, ally_fallen=1.5)])
    # Giáp Sĩ Rỉ Sét – khiên dày, thủ thế.
    eskill("en_knight_slash", ("Chém Gỉ", "Rusty Slash"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_knight_sweep", ("Quét Giáp", "Armored Sweep"), ("70% Tấn Công lên 1 người và 40% lên 2 người bên cạnh.",
           "70% ATK to one target and 40% to adjacent targets."), "BLAST_ENEMY", [("damage", {"mult": 0.7, "adj": 0.4})])
    eskill("en_knight_guard", ("Thủ Thế", "Guard Stance"), ("Giảm 40% sát thương nhận tới hết lượt sau.",
           "Takes 40% less damage until the end of its next turn."), "SELF",
           [("status", {"scope": "SELF", "status": "en_guard", "extend_if_self": True})], kind="SKILL")
    species("rusted_knight", ("Giáp Sĩ Rỉ Sét", "Rusted Knight"), ("Bộ giáp rỗng gỉ sét, khiên dày, biết thủ thế khi bị dồn ép.",
            "Hollow rusted armor with thick toughness that guards when pressed."), "Khiên dày",
            "Color(0.55, 0.38, 0.25, 1)", 1.3, 1.0, 80, 60,
            [act("en_knight_slash", 2), act("en_knight_sweep", 1, first=2),
             act("en_knight_guard", 0.6, cd=2, after_break=5.0, low_hp=2.5)])
    # Xạ Thủ Hư Không – đánh dấu, lượt sau bắn gấp đôi.
    eskill("en_archer_shot", ("Tên Hư Không", "Void Arrow"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_archer_mark", ("Ngắm Bắn", "Take Aim"), ("40% Tấn Công và gắn Bị Ngắm lên 1 người.",
           "40% ATK and marks one target as Targeted."), "SINGLE_ENEMY",
           [("damage", {"mult": 0.4}), ("status", {"status": "en_void_mark"})], kind="SKILL")
    eskill("en_archer_snipe", ("Phát Bắn Xuyên Hư Không", "Void Piercer"), ("200% Tấn Công lên người Bị Ngắm.",
           "200% ATK to the Targeted ally."), "SINGLE_ENEMY",
           [("damage", {"mult": 2.0}), ("remove_status", {"status": "en_void_mark"})], kind="ULTIMATE")
    species("void_archer", ("Xạ Thủ Hư Không", "Void Archer"), ("Cung thủ đứng xa, ngắm trước rồi bắn xuyên.",
            "A distant archer that takes aim, then fires a piercing shot."), "Đánh xa",
            "Color(0.25, 0.22, 0.4, 1)", 0.9, 1.1, 100, 30,
            [act("en_archer_shot", 1), act("en_archer_mark", 2, cd=2),
             act("en_archer_snipe", 1, rule="MARKED", foe_status="en_void_mark", priority=True)])
    # Pháp Sư Méo – gắn sát thương theo lượt theo nguyên tố.
    eskill("en_mage_bolt", ("Tia Méo", "Warped Bolt"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_mage_storm", ("Mưa Méo", "Warped Rain"), ("35% Tấn Công lên cả đội.", "35% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.35})], kind="SKILL")
    for el, (vi, en) in [("fire", ("Phù Lửa Méo", "Warped Flame Hex")), ("poison", ("Phù Độc Méo", "Warped Venom Hex")),
                         ("wind", ("Phù Gió Méo", "Warped Gale Hex"))]:
        eskill("en_mage_hex_%s" % el, (vi, en), ("50%% Tấn Công, 90%% gắn %s 2 lượt." % TEXT["STATUS_EN_HEX_%s" % el.upper()][0],
               "50%% ATK, 90%% chance to apply %s for 2 turns." % TEXT["STATUS_EN_HEX_%s" % el.upper()][1]), "SINGLE_ENEMY",
               [("damage", {"mult": 0.5}), ("status", {"status": "en_hex_%s" % el, "base_mult": 1.0})], kind="SKILL")
    species("warped_mage", ("Pháp Sư Méo", "Warped Mage"), ("Pháp sư bị Ma Biến bẻ cong, gieo nguyên tố độc hại.",
            "A mage bent by the warp who sows harmful elements."), "Gây hiệu ứng",
            "Color(0.48, 0.2, 0.5, 1)", 0.9, 1.0, 100, 30, [])
    # Chuột Mực Sách – nhanh, trộm Điểm Chiến Kỹ.
    eskill("en_rat_steal", ("Cắn Trộm", "Thieving Bite"), ("90% Tấn Công lên 1 người, trộm 1 Điểm Chiến Kỹ.",
           "90% ATK to one target and steals 1 Skill Point."), "SINGLE_ENEMY",
           [("damage", {"mult": 0.9}), ("sp", {"amount": -1})])
    eskill("en_rat_shred", ("Xé Trang", "Page Shred"), ("60% Tấn Công lên 1 người và 30% lên người bên cạnh.",
           "60% ATK to one target and 30% to adjacent targets."), "BLAST_ENEMY", [("damage", {"mult": 0.6, "adj": 0.3})])
    species("ink_rat", ("Chuột Mực Sách", "Ink Rat"), ("Chuột ăn mực sách, chạy nhanh, cắn ai là trộm mất nhịp chiến đấu.",
            "A fast ink-eating rat; its bite steals Skill Points."), "Nhanh", "Color(0.2, 0.2, 0.25, 1)",
            0.7, 0.8, 125, 20, [act("en_rat_steal", 3), act("en_rat_shred", 1)])
    # Bầy Ong Độc – 3 con nhỏ, gọi thêm khi còn 1.
    eskill("en_bee_sting", ("Chích", "Sting"), ("80% Tấn Công lên 1 người, 60% gắn Nọc Ong.",
           "80% ATK to one target, 60% chance to apply Bee Venom."), "SINGLE_ENEMY",
           [("damage", {"mult": 0.8}), ("status", {"status": "en_bee_venom", "base_mult": 1.0})])
    species("venom_bee", ("Ong Độc", "Venom Bee"), ("Bầy ong nhiễm Ma Biến; còn một con là nó gọi cả tổ tới.",
            "Warp-infected bees; the last one standing calls the hive."), "Nhiều mục tiêu",
            "Color(0.75, 0.62, 0.12, 1)", 0.45, 0.6, 110, 10, [])
    # Bóng Gương – sao chép buff của phe ta.
    eskill("en_mirror_strike", ("Đòn Phản Chiếu", "Mirrored Strike"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_mirror_copy", ("Soi Gương", "Mirror Image"), ("50% Tấn Công lên người nhiều buff nhất và sao chép 1 buff của họ.",
           "50% ATK to the most-buffed ally and copies one of their buffs."), "SINGLE_ENEMY",
           [("damage", {"mult": 0.5}), ("buff_transfer", {"count": 1})], kind="SKILL")
    eskill("en_mirror_flash", ("Lóe Gương", "Mirror Flash"), ("40% Tấn Công lên cả đội.", "40% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.4})], kind="SKILL")
    species("mirror_shade", ("Bóng Gương", "Mirror Shade"), ("Cái bóng trong gương vỡ, bắt chước sức mạnh của đối thủ.",
            "A shadow from a shattered mirror that mimics its foes' power."), "Gây rối",
            "Color(0.6, 0.7, 0.78, 1)", 1.0, 1.0, 100, 30,
            [act("en_mirror_strike", 2), act("en_mirror_copy", 4, rule="MOST_BUFFS", foe_buff=True, cd=1),
             act("en_mirror_flash", 1, first=2)])

    variant("warp_sprout", "poison", ["fire", "wind"])
    variant("warp_sprout", "water", ["lightning", "wood"])
    variant("warp_sprout", "fire", ["water", "wind"])
    variant("wandering_shade", "wind", ["soul", "fire"])
    variant("wandering_shade", "water", ["lightning", "soul"])
    variant("wandering_shade", "soul", ["fire", "poison"])
    variant("rusted_knight", "water", ["lightning", "fire", "wind"])
    variant("rusted_knight", "lightning", ["wood", "water", "fire"])
    variant("void_archer", "wind", ["lightning", "soul"])
    variant("void_archer", "lightning", ["wood", "wind"])
    for el, weak in [("poison", ["fire", "water"]), ("fire", ["water", "soul"]), ("wind", ["lightning", "wood"])]:
        variant("warped_mage", el, weak, [act("en_mage_bolt", 1), act("en_mage_hex_%s" % el, 2, cd=1),
                                          act("en_mage_storm", 1, first=2)])
    variant("ink_rat", "wind", ["fire", "lightning"])
    variant("ink_rat", "lightning", ["wood", "soul"])
    for el, weak in [("poison", ["fire", "wind"]), ("wind", ["lightning", "water"])]:
        # Ong thợ gọi ra không gọi tiếp (tránh vòng tham chiếu dữ liệu và gọi vô hạn).
        drone = "venom_bee_%s_drone" % el
        sp = SPECIES["venom_bee"]
        vi, en = EL_NAME[el]
        enemy(drone, ("Ong Thợ %s" % vi, "%s Worker Bee" % en), sp["desc"], "normal", "venom_bee", el, weak, sp["tough"],
              sp["color"], sp["hp"], sp["atk"], sp["spd"], [act("en_bee_sting")], doc_role="Ong được gọi thêm")
        eskill("en_bee_call_%s" % el, ("Gọi Tổ", "Call the Hive"), ("Còn 1 con: gọi thêm 2 Ong Thợ (tối đa 2 lần).",
               "When only one is left: calls 2 Worker Bees (up to twice)."), "SELF",
               [("summon_enemy", {"enemy": drone, "count": 2})], kind="SKILL")
        variant("venom_bee", el, weak, [act("en_bee_sting", 1),
                                        act("en_bee_call_%s" % el, 1, family_max=1, slot=True, uses=2, priority=True)])
    variant("mirror_shade", "water", ["lightning", "wood"])
    variant("mirror_shade", "soul", ["fire", "water", "soul"])


# ============================ Tinh anh ============================
def build_elites():
    eskill("en_sk_slash", ("Kiếm Gãy", "Broken Blade"), ("110% Tấn Công lên 1 người.", "110% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.1})])
    eskill("en_sk_sweep", ("Vung Mảnh Vỡ", "Shard Swing"), ("80% Tấn Công lên 1 người và 50% lên người bên cạnh.",
           "80% ATK to one target and 50% to adjacent targets."), "BLAST_ENEMY", [("damage", {"mult": 0.8, "adj": 0.5})])
    eskill("en_sk_charge", ("Lao Vỡ Vụn", "Shattering Charge"), ("Tích tụ 1 lượt rồi lao tới: 350% Tấn Công lên 1 người. "
           "Phá khiên lúc đang tích tụ thì hủy đòn.", "Charges for 1 turn, then rams: 350% ATK to one target. "
           "Breaking it while charging cancels the attack."), "SINGLE_ENEMY", [("damage", {"mult": 3.5})], kind="ULTIMATE")
    enemy("shattered_knight", ("Kỵ Sĩ Vỡ Vụn", "Shattered Knight"), ("Kỵ sĩ canh kho xưa, thân giáp nứt toác nhưng cú lao "
          "vẫn đủ sức xuyên tường.", "An old vault knight; its armor is cracked, but its charge still breaks walls."),
          "elite", "shattered_knight", "water", ["fire", "lightning", "wind"], 100, "Color(0.3, 0.42, 0.55, 1)",
          5.0, 1.6, 95, [act("en_sk_slash", 2), act("en_sk_sweep", 1),
                         act("en_sk_charge", 3, cd=2, first=2, charge=1, cancel_break=True, low_hp=1.5)],
          eres=0.2, size=1.25, doc_role="Tinh anh: tích tụ rồi lao")
    eskill("en_matrix_spawn", ("Nảy Mầm", "Sprouting"), ("Gọi 2 Mầm Ma Biến (cứ 2 lượt một lần, còn chỗ).",
           "Summons 2 Warp Sprouts (every other turn, if there is room)."), "SELF",
           [("summon_enemy", {"enemy": "warp_sprout_poison", "count": 2, "level_offset": -1})], kind="SKILL")
    eskill("en_matrix_lash", ("Roi Rễ Méo", "Warped Lash"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_matrix_spew", ("Phun Ma Biến", "Warp Spew"), ("50% Tấn Công lên cả đội.", "50% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.5})], kind="SKILL")
    enemy("warp_matrix", ("Mẫu Thể Ma Biến", "Warp Matrix"), ("Khối mầm mẹ đập thình thịch; mỗi Mầm còn sống làm khiên "
          "của nó dày thêm.", "A pulsing mother-mass; each living Sprout thickens its toughness."),
          "elite", "warp_matrix", "poison", ["fire", "wood", "water"], 60, "Color(0.45, 0.12, 0.3, 1)",
          5.0, 1.5, 90, [act("en_matrix_spawn", 1, slot=True, cd=1, priority=True), act("en_matrix_lash", 2),
                         act("en_matrix_spew", 1, ally_fallen=1.5)],
          eres=0.2, size=1.3, behavior="warp_matrix_behavior",
          params={"base_toughness": 60.0, "toughness_per_sprout": 30.0, "sprout_family": "warp_sprout"},
          doc_role="Tinh anh: triệu hồi, khiên theo số Mầm")
    eskill("en_ml_strike", ("Gáy Sách", "Spine Strike"), ("110% Tấn Công lên 1 người.", "110% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.1})])
    eskill("en_ml_seal", ("Suỵt", "Hush"), ("60% Tấn Công lên người Tấn Công cao nhất, Phong Ấn Chiến kỹ của họ 2 lượt.",
           "60% ATK to the highest-ATK ally and Seals their Skill for 2 turns."), "SINGLE_ENEMY",
           [("damage", {"mult": 0.6}), ("status", {"status": "en_seal"})], kind="SKILL")
    eskill("en_ml_hush", ("Tĩnh Lặng", "Silence"), ("45% Tấn Công lên cả đội.", "45% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.45})], kind="SKILL")
    enemy("mute_librarian", ("Thủ Thư Câm", "Mute Librarian"), ("Thủ thư đã mất giọng, bắt cả thư viện câm theo mình.",
          "A librarian who lost their voice and silences everyone else."), "elite", "mute_librarian", "wind",
          ["fire", "soul", "lightning"], 90, "Color(0.32, 0.27, 0.22, 1)", 4.6, 1.6, 105,
          [act("en_ml_strike", 2), act("en_ml_seal", 3, rule="HIGHEST_ATK", cd=2), act("en_ml_hush", 1, first=2)],
          eres=0.2, size=1.25, doc_role="Tinh anh: Phong Ấn Chiến kỹ")


# ============================ Boss ============================
def build_bosses():
    # --- Người Gác Thư Viện (Chương 1) ---
    eskill("en_book_cut", ("Lật Trang Cắt", "Paper Cut"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    enemy("flying_book", ("Sách Bay", "Flying Tome"), ("Cuốn sách bị gọi dậy, lượn vòng quanh Người Gác.",
          "A tome roused to circle the Warden."), "normal", "flying_book", "wind", ["fire", "wind"], 20,
          "Color(0.6, 0.5, 0.35, 1)", 0.6, 0.7, 110, [act("en_book_cut")], size=0.8, doc_role="Triệu hồi của boss")
    eskill("en_warden_strike", ("Gáy Sách Nặng", "Heavy Spine"), ("120% Tấn Công lên 1 người.", "120% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.2})])
    eskill("en_warden_pages", ("Bão Trang", "Page Storm"), ("50% Tấn Công lên cả đội.", "50% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.5})], kind="SKILL")
    eskill("en_warden_books", ("Gọi Sách", "Summon Tomes"), ("Gọi 2 Sách Bay.", "Summons 2 Flying Tomes."), "SELF",
           [("summon_enemy", {"enemy": "flying_book", "count": 2, "level_offset": -1})], kind="SKILL")
    eskill("en_warden_curse", ("Lời Nguyền Câm Lặng", "Curse of Silence"), ("Đếm ngược 3 lượt (vẫn hành động). Hết giờ: "
           "60% Tấn Công lên cả đội và Phong Ấn Chiến kỹ cả đội 2 lượt. Phá khiên để ngắt.",
           "3-turn countdown (keeps acting). At zero: 60% ATK to the whole team and Seals everyone's Skill for 2 turns. "
           "Break its toughness to interrupt."), "ALL_ENEMIES",
           [("damage", {"mult": 0.6}), ("status", {"status": "en_curse_seal"})], kind="ULTIMATE")
    warden_p1 = [act("en_warden_books", 3, slot=True, cd=3, phase_start=True), act("en_warden_strike", 3),
                 act("en_warden_pages", 1.5, first=2, ally_fallen=1.5)]
    warden_p2 = [act("en_warden_curse", 1, charge=3, act_charging=True, cancel_break=True, phase_start=True, cd=6),
                 act("en_warden_books", 2, slot=True, cd=3), act("en_warden_strike", 3), act("en_warden_pages", 1.5)]
    enemy("library_warden", ("Người Gác Thư Viện", "Library Warden"), ("Người gác cổng Thư Viện Câm Lặng, giữ từng trang sách "
          "bằng lời nguyền.", "Keeper of the Silent Library, guarding every page with a curse."), "boss", "library_warden",
          "wind", ["fire", "soul"], 160, "Color(0.36, 0.28, 0.5, 1)", 22.0, 2.2, 105, warden_p1, eres=0.3, size=1.6,
          music="boss_library",
          phases=[dict(name=("Lời Nguyền Câm Lặng", "Curse of Silence"), hp=0.5, weak=["wind", "soul"],
                       actions=warden_p2, mods=[("ATK", 0, 0.15)], color="Color(0.3, 0.15, 0.45, 1)",
                       music="boss_library_2")],
          doc_role="Boss Chương 1")

    # --- Cự Thú Kho Chứa (Chương 2) ---
    eskill("en_beh_claw", ("Vuốt Băng", "Frost Claw"), ("120% Tấn Công lên 1 người.", "120% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.2})])
    eskill("en_beh_freeze", ("Hơi Thở Đóng Băng", "Freezing Breath"), ("60% Tấn Công lên người Tấn Công cao nhất, 80% Đông Cứng 1 lượt.",
           "60% ATK to the highest-ATK ally, 80% chance to Freeze them for 1 turn."), "SINGLE_ENEMY",
           [("damage", {"mult": 0.6}), ("status", {"status": "en_frozen"})], kind="SKILL")
    eskill("en_beh_roar", ("Gầm Băng Giá", "Glacial Roar"), ("Báo trước 1 lượt: 100% Tấn Công lên cả đội. Phá khiên để hủy.",
           "Telegraphed 1 turn: 100% ATK to the whole team. Break to cancel."), "ALL_ENEMIES", [("damage", {"mult": 1.0})],
           kind="ULTIMATE")
    eskill("en_beh_rampage", ("Giẫm Nát", "Rampage"), ("100% Tấn Công lên 1 người và 60% lên người bên cạnh.",
           "100% ATK to one target and 60% to adjacent targets."), "BLAST_ENEMY", [("damage", {"mult": 1.0, "adj": 0.6})])
    eskill("en_beh_shards", ("Mưa Mảnh Băng", "Shard Hail"), ("60% Tấn Công lên cả đội.", "60% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.6})], kind="SKILL")
    eskill("en_beh_avalanche", ("Lở Băng", "Avalanche"), ("Báo trước 1 lượt: 130% Tấn Công lên cả đội. Phá khiên để hủy.",
           "Telegraphed 1 turn: 130% ATK to the whole team. Break to cancel."), "ALL_ENEMIES", [("damage", {"mult": 1.3})],
           kind="ULTIMATE")
    enemy("vault_behemoth", ("Cự Thú Kho Chứa", "Vault Behemoth"), ("Con thú khổng lồ ngủ đông giữa kho băng, lớp băng trên lưng "
          "dày như tường thành.", "A colossal beast hibernating in the ice vault, its frozen hide thick as a rampart."),
          "boss", "vault_behemoth", "water", ["fire", "soul"], 180, "Color(0.4, 0.6, 0.75, 1)", 24.0, 2.2, 95,
          [act("en_beh_claw", 3), act("en_beh_freeze", 2, rule="HIGHEST_ATK", cd=2),
           act("en_beh_roar", 2, charge=1, cancel_break=True, cd=3, first=2)],
          eres=0.3, size=1.7, music="boss_vault",
          phases=[dict(name=("Băng Vỡ", "Shattered Ice"), hp=0.5, weak=["lightning", "soul"], tough=150,
                       actions=[act("en_beh_rampage", 3), act("en_beh_shards", 2),
                                act("en_beh_freeze", 1, rule="HIGHEST_ATK", cd=3),
                                act("en_beh_avalanche", 2, charge=1, cancel_break=True, cd=3, phase_start=True)],
                       mods=[("SPD", 0, 0.2), ("ATK", 0, 0.1)], advance=0.3, color="Color(0.2, 0.45, 0.7, 1)",
                       music="boss_vault_2")],
          doc_role="Boss Chương 2")

    # --- Lõi Lò Biến Dạng (Chương 3) ---
    eskill("en_arm_strike", ("Kẹp Máy", "Clamp"), ("90% Tấn Công lên 1 người.", "90% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 0.9})])
    eskill("en_arm_stoke", ("Nạp Nhiệt", "Stoke"), ("Thêm 1 tầng Nhiệt cho Lõi Lò.", "Adds 1 Heat stack to the Core."),
           "SELF", [], kind="SKILL")
    enemy("furnace_arm", ("Tay Máy Lò", "Furnace Arm"), ("Cánh tay máy nối vào lõi lò, đánh người và nạp thêm nhiệt.",
          "A mechanical arm wired to the core that strikes and stokes its heat."), "normal", "furnace_arm", "fire",
          ["water", "wood"], 40, "Color(0.45, 0.4, 0.38, 1)", 2.5, 1.8, 95,
          [act("en_arm_strike", 2), act("en_arm_stoke", 1.2)], size=0.9, doc_role="Mục tiêu phụ của boss")
    eskill("en_core_flare", ("Lửa Lõi", "Core Flare"), ("110% Tấn Công lên 1 người.", "110% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.1})])
    eskill("en_core_wave", ("Sóng Nhiệt", "Heat Wave"), ("50% Tấn Công lên cả đội.", "50% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.5})], kind="SKILL")
    eskill("en_core_meltdown", ("Quá Nhiệt", "Meltdown"), ("Từ 4 tầng Nhiệt: báo trước 1 lượt rồi nổ, 160% Tấn Công lên cả đội "
           "và xả hết Nhiệt. Phá khiên để hủy (và mất 3 tầng).", "From 4 Heat: telegraphs 1 turn, then explodes for 160% ATK "
           "on the whole team and vents all Heat. Break to cancel (and remove 3 stacks)."), "ALL_ENEMIES",
           [("damage", {"mult": 1.6}), ("remove_status", {"scope": "SELF", "status": "en_heat"})], kind="ULTIMATE")
    core_actions = [act("en_core_meltdown", 1, self_status="en_heat", self_stacks=4, priority=True, charge=1, cancel_break=True),
                    act("en_core_flare", 3), act("en_core_wave", 1.5, first=2)]
    enemy("warped_core", ("Lõi Lò Biến Dạng", "Warped Core"), ("Trái tim của Lò Năng Lượng bị Ma Biến nuốt, nóng dần tới khi "
          "nổ tung.", "The Energy Furnace's heart, swallowed by the warp, heating until it bursts."), "boss", "warped_core",
          "fire", ["water", "soul"], 170, "Color(0.75, 0.3, 0.12, 1)", 18.0, 3.2, 95, core_actions, eres=0.3, size=1.7,
          behavior="warped_core_behavior", music="boss_furnace",
          params={"heat_status": ("res", "data/status_effects/en_heat.tres"), "heat_per_turn": 1, "break_heat_loss": 3,
                  "stoke_skill_id": "en_arm_stoke", "arm_enemy": ("res", "data/enemies/furnace_arm.tres"), "arm_count": 2},
          phases=[dict(name=("Lò Quá Tải", "Overload"), hp=0.5, weak=["wood", "soul"], actions=core_actions,
                       mods=[("ATK", 0, 0.15)], color="Color(0.8, 0.2, 0.05, 1)", music="boss_furnace_2")],
          doc_role="Boss Chương 3")

    # --- Kẻ Nuốt Mảnh Hồn (Chương 4, trùm cuối) ---
    clones = []
    for cid, el, weak, vi, en in [("devourer_clone_flame", "fire", ["fire", "wind"], "Phân Thân Lửa", "Flame Fragment"),
                                  ("devourer_clone_tide", "water", ["water", "poison"], "Phân Thân Nước", "Tide Fragment"),
                                  ("devourer_clone_storm", "lightning", ["lightning", "wood"], "Phân Thân Sét", "Storm Fragment")]:
        clones.append(cid)
        enemy(cid, (vi, en), ("Mảnh hồn bị Kẻ Nuốt tách ra; hạ nó làm bản thể bị thương.",
              "A soul shard split off by the Devourer; destroying it wounds the true body."), "normal", "devourer_clone", el,
              weak, 60, ELCOL[EL[el]], 4.0, 2.0, 100, [act("en_clone_strike", 2), act("en_clone_wail", 1, first=2)],
              eres=0.2, size=1.1, doc_role="Phân thân của trùm cuối")
    eskill("en_clone_strike", ("Vuốt Hồn", "Soul Claw"), ("100% Tấn Công lên 1 người.", "100% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    eskill("en_clone_wail", ("Tiếng Vọng", "Echoing Wail"), ("35% Tấn Công lên cả đội.", "35% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.35})], kind="SKILL")
    eskill("en_dev_bite", ("Cắn Hồn", "Soul Bite"), ("120% Tấn Công lên 1 người.", "120% ATK to one target."),
           "SINGLE_ENEMY", [("damage", {"mult": 1.2})])
    eskill("en_dev_devour", ("Nuốt Ánh Sáng", "Devour Light"), ("50% Tấn Công lên cả đội và hút 1 buff của mỗi người.",
           "50% ATK to the whole team and steals one buff from each."), "ALL_ENEMIES",
           [("damage", {"mult": 0.5}), ("buff_transfer", {"steal": True, "count": 1})], kind="SKILL")
    eskill("en_dev_pulse", ("Xung Hư Không", "Void Pulse"), ("Báo trước 1 lượt: 110% Tấn Công lên cả đội. Phá khiên để hủy.",
           "Telegraphed 1 turn: 110% ATK to the whole team. Break to cancel."), "ALL_ENEMIES", [("damage", {"mult": 1.1})],
           kind="ULTIMATE")
    eskill("en_dev_shadow", ("Bóng Nuốt", "Engulfing Shade"), ("40% Tấn Công lên cả đội.", "40% ATK to the whole team."),
           "ALL_ENEMIES", [("damage", {"mult": 0.4})], kind="SKILL")
    eskill("en_dev_swallow", ("Nuốt Hồn", "Soul Swallow"), ("Đếm ngược 2 lượt (vẫn hành động). Hết giờ: 180% Tấn Công lên cả đội. "
           "Gây đủ 10% máu tối đa của nó trong lúc đếm ngược để ngắt.", "2-turn countdown (keeps acting). At zero: 180% ATK "
           "to the whole team. Deal 10% of its max HP during the countdown to interrupt."), "ALL_ENEMIES",
           [("damage", {"mult": 1.8})], kind="ULTIMATE")
    enemy("soul_devourer", ("Kẻ Nuốt Mảnh Hồn", "Soul Devourer"), ("Kẻ đánh cắp Mảnh Hồn, lớn lên bằng ánh sáng của người khác.",
          "The thief of Soul Shards, grown fat on the light of others."), "boss", "soul_devourer", "soul",
          ["soul", "water"], 180, "Color(0.2, 0.1, 0.3, 1)", 22.0, 2.7, 105,
          [act("en_dev_bite", 2), act("en_dev_devour", 3, foe_buff=True, cd=1),
           act("en_dev_pulse", 1.5, charge=1, cancel_break=True, cd=3, first=2)],
          eres=0.3, size=1.8, behavior="soul_devourer_behavior", music="boss_devourer",
          params={"clones": ("enemies", clones), "clone_phase": 1, "clone_backlash": 0.08, "drain_phase": 2},
          phases=[dict(name=("Phân Thân", "Splitting"), hp=0.66, actions=[act("en_dev_shadow", 1)],
                       color="Color(0.35, 0.1, 0.45, 1)", music="boss_devourer_2"),
                  dict(name=("Nuốt Hồn", "Soul Swallow"), hp=-1, weak=["soul", "fire", "lightning"],
                       actions=[act("en_dev_swallow", 1, charge=2, act_charging=True, cancel_dmg=0.10, phase_start=True, cd=4),
                                act("en_dev_bite", 2), act("en_dev_devour", 2, foe_buff=True, cd=1)],
                       mods=[("ATK", 0, 0.2)], color="Color(0.55, 0.05, 0.15, 1)", music="boss_devourer_3")],
          doc_role="Trùm cuối Chương 4")


# ============================ Trận theo khu ============================
def build_encounters():
    Z = "library"
    encounter("library_01_sprouts", Z, "normal", 3, [[("warp_sprout_poison", 1, 3)]])
    encounter("library_02_shade", Z, "normal", 3, [[("wandering_shade_wind", 2, 1), ("warp_sprout_poison", 2, 2)]])
    encounter("library_03_rats", Z, "normal", 4, [[("ink_rat_wind", 3, 2)]])
    encounter("library_04_archer", Z, "normal", 5, [[("void_archer_wind", 4, 1), ("ink_rat_wind", 4, 1)]])
    encounter("library_05_mage", Z, "normal", 6, [[("warp_sprout_poison", 5, 1), ("warped_mage_poison", 5, 1),
                                                   ("warp_sprout_poison", 5, 1)]])
    encounter("library_06_bees", Z, "normal", 7, [[("venom_bee_poison", 6, 3)]])
    encounter("library_07_patrol", Z, "normal", 8, [[("void_archer_wind", 7, 1), ("wandering_shade_wind", 7, 1)],
                                                    [("ink_rat_wind", 7, 1), ("warped_mage_poison", 7, 1), ("warp_sprout_poison", 7, 1)]])
    encounter("library_elite_librarian", Z, "elite", 10, [[("ink_rat_wind", 8, 1), ("mute_librarian", 8, 1), ("ink_rat_wind", 8, 1)]])
    encounter("library_boss_warden", Z, "boss", 10, [[("library_warden", 8, 1)]])
    Z = "vault"
    encounter("vault_01_sprouts", Z, "normal", 10, [[("warp_sprout_water", 9, 3), ("wandering_shade_water", 9, 1)]])
    encounter("vault_02_knight", Z, "normal", 11, [[("warp_sprout_water", 10, 1), ("rusted_knight_water", 10, 1),
                                                    ("warp_sprout_water", 10, 1)]])
    encounter("vault_03_mirror", Z, "normal", 12, [[("mirror_shade_water", 11, 1), ("wandering_shade_water", 11, 1)]])
    encounter("vault_04_guards", Z, "normal", 13, [[("rusted_knight_water", 12, 2)]])
    encounter("vault_05_mixed", Z, "normal", 14, [[("mirror_shade_water", 13, 1), ("rusted_knight_water", 13, 1),
                                                   ("warp_sprout_water", 13, 1)]])
    encounter("vault_06_patrol", Z, "normal", 15, [[("wandering_shade_water", 14, 1), ("warp_sprout_water", 14, 2)],
                                                   [("rusted_knight_water", 14, 1), ("mirror_shade_water", 14, 1)]])
    encounter("vault_elite_knight", Z, "elite", 17, [[("shattered_knight", 15, 1), ("wandering_shade_water", 15, 1)]])
    encounter("vault_boss_behemoth", Z, "boss", 18, [[("vault_behemoth", 16, 1)]])
    Z = "furnace"
    encounter("furnace_01_sprouts", Z, "normal", 18, [[("warp_sprout_fire", 17, 3)]])
    encounter("furnace_02_mage", Z, "normal", 19, [[("warp_sprout_fire", 18, 1), ("warped_mage_fire", 18, 1),
                                                    ("warp_sprout_fire", 18, 1)]])
    encounter("furnace_03_knight", Z, "normal", 20, [[("rusted_knight_lightning", 19, 1), ("ink_rat_lightning", 19, 1)]])
    encounter("furnace_04_bees", Z, "normal", 21, [[("venom_bee_poison", 20, 3)]])
    encounter("furnace_05_rats", Z, "normal", 22, [[("ink_rat_lightning", 21, 1), ("warped_mage_fire", 21, 1),
                                                    ("ink_rat_lightning", 21, 1)]])
    encounter("furnace_06_patrol", Z, "normal", 23, [[("warp_sprout_fire", 22, 2), ("warped_mage_fire", 22, 1)],
                                                     [("rusted_knight_lightning", 22, 1), ("ink_rat_lightning", 22, 1)]])
    encounter("furnace_elite_matrix", Z, "elite", 25, [[("warp_sprout_poison", 23, 1), ("warp_matrix", 23, 1),
                                                         ("warp_sprout_poison", 23, 1)]])
    encounter("furnace_boss_core", Z, "boss", 26, [[("furnace_arm", 24, 1), ("warped_core", 24, 1), ("furnace_arm", 24, 1)]])
    Z = "tower"
    encounter("tower_01_shade", Z, "normal", 26, [[("wandering_shade_soul", 25, 1), ("void_archer_lightning", 25, 1)]])
    encounter("tower_02_mirror", Z, "normal", 27, [[("mirror_shade_soul", 26, 1), ("warped_mage_wind", 26, 1)]])
    encounter("tower_03_bees", Z, "normal", 28, [[("venom_bee_wind", 27, 3)]])
    encounter("tower_04_archers", Z, "normal", 28, [[("void_archer_lightning", 27, 1), ("wandering_shade_soul", 27, 1),
                                                     ("void_archer_lightning", 27, 1)]])
    encounter("tower_05_patrol", Z, "normal", 29, [[("warped_mage_wind", 28, 1), ("mirror_shade_soul", 28, 1)],
                                                   [("rusted_knight_lightning", 28, 1), ("void_archer_lightning", 28, 1),
                                                    ("wandering_shade_soul", 28, 1)]])
    encounter("tower_06_sprouts", Z, "normal", 29, [[("warp_sprout_fire", 28, 2), ("mirror_shade_soul", 28, 1),
                                                     ("warp_sprout_poison", 28, 1)]])
    encounter("tower_elite_knight", Z, "elite", 30, [[("shattered_knight", 28, 1), ("wandering_shade_soul", 28, 1)]])
    encounter("tower_elite_librarian", Z, "elite", 30, [[("mirror_shade_soul", 29, 1), ("mute_librarian", 29, 1)]])
    encounter("tower_elite_matrix", Z, "elite", 30, [[("warp_sprout_poison", 29, 1), ("warp_matrix", 29, 1),
                                                      ("warp_sprout_poison", 29, 1)]])
    encounter("tower_boss_devourer", Z, "boss", 30, [[("soul_devourer", 30, 1)]])


# ============================ Dịch + tài liệu ============================
def write_translations():
    path = os.path.join(ROOT, "localization", "enemies.csv")
    with open(path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["keys", "vi", "en"])
        for key in sorted(TEXT):
            w.writerow([key, TEXT[key][0], TEXT[key][1]])


ZONE_NAME = {"library": "Thư Viện Câm Lặng (Chương 1, cấp 1–8)", "vault": "Kho Chứa Băng Giá (Chương 2, cấp 8–16)",
             "furnace": "Lò Năng Lượng (Chương 3, cấp 16–24)", "tower": "Đỉnh Tháp Quan Sát (Chương 4, cấp 24–30)"}
KIND_NAME = {"normal": "Thường", "elite": "Tinh anh", "boss": "Boss"}


def write_doc():
    def els(lst):
        return ", ".join(EL_NAME[e][0] for e in lst)
    lines = ["# Quái và boss", "", "File sinh tự động bởi `tools/data_builder/build_enemies.py` – đừng sửa tay.", "",
             "Chỉ số = đường cong quái chuẩn (Máu %g→%g, Tấn Công %g→%g từ cấp 1→80) × hệ số trong bảng." % (
                 BASE_LV1["hp"], BASE_LV80["hp"], BASE_LV1["atk"], BASE_LV80["atk"]), "",
             "| Id | Tên | Loại | Vai trò | Nguyên tố | Điểm yếu | Khiên | ×Máu | ×Tấn Công | Tốc Độ |",
             "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
    for d in DOC:
        lines.append("| `%s` | %s | %s | %s | %s | %s | %g | %g | %g | %g |" % (
            d["id"], d["name"], KIND_NAME[d["kind"]], d["role"], EL_NAME[d["element"]][0], els(d["weak"]), d["tough"],
            d["hp"], d["atk"], d["spd"]))
    lines += ["", "## Giai đoạn boss", ""]
    for d in DOC:
        if d["kind"] != "boss":
            continue
        lines.append("- **%s**: GĐ1 điểm yếu %s; " % (d["name"], els(d["weak"])) + "; ".join(
            "GĐ%d \"%s\" (%s) điểm yếu %s" % (i + 2, n, "máu ≤ %d%%" % round(hp * 100) if hp >= 0 else "hạ hết phân thân", els(w))
            for i, (n, hp, w) in enumerate(d["phases"])))
    lines += ["", "## Trận theo khu", ""]
    for zone in ZONE_NAME:
        lines += ["### " + ZONE_NAME[zone], "", "| Trận | Loại | Cấp khuyến nghị | Đợt |", "| --- | --- | --- | --- |"]
        for eid, z, kind, rec, waves in ENCOUNTERS:
            if z == zone:
                lines.append("| `%s` | %s | %d | %s |" % (eid, KIND_NAME[kind], rec, " → ".join(
                    ", ".join("%s Lv%d%s" % (e, lv, " ×%d" % n if n > 1 else "") for e, lv, n in wave) for wave in waves)))
        lines.append("")
    with open(os.path.join(ROOT, "docs", "ENEMIES.md"), "w") as fh:
        fh.write("\n".join(lines))


if __name__ == "__main__":
    build_statuses()
    build_normals()
    build_elites()
    build_bosses()
    build_encounters()
    write_translations()
    write_doc()
    print("Xong: %d quái, %d trận." % (len(DOC), len(ENCOUNTERS)))

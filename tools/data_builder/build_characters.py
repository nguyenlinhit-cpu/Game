#!/usr/bin/env python3
"""Sinh dữ liệu nhân vật Phase 6 (kỹ năng, hiệu ứng, Bí Kỹ, Đòn Mở Màn, Đặc tính, Tinh Mệnh) ra .tres.
Chạy: python3 tools/data_builder/build_characters.py   (từ thư mục dự án). Ghi đè file cũ.
Muốn cân bằng thì sửa số ở đây rồi chạy lại, hoặc sửa thẳng file .tres trong editor."""
import os
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
os.chdir(ROOT)

STAT = {"HP": 0, "ATK": 1, "DEF": 2, "SPD": 3, "CRIT_RATE": 4, "CRIT_DMG": 5, "BREAK_EFFECT": 6, "ENERGY_REGEN": 7,
        "EFFECT_HIT": 8, "EFFECT_RES": 9, "OUTGOING_HEALING": 10,
        "DAMAGE_BONUS": 11, "VULNERABILITY": 12, "DEF_REDUCTION": 13, "RES": 14, "AGGRO": 15}
KIND = {"BASIC": 0, "SKILL": 1, "ULTIMATE": 2, "FOLLOW_UP": 3}
TGT = {"SINGLE_ENEMY": 0, "BLAST_ENEMY": 1, "ALL_ENEMIES": 2, "SINGLE_ALLY": 3, "ALL_ALLIES": 4, "SELF": 5}
SCOPE = {"TARGETS": 0, "MAIN": 1, "ADJACENT": 2, "SELF": 3, "ALL_ALLIES": 4, "ALLIES_EXCEPT_SELF": 5, "ALL_ENEMIES": 6,
         "FIRST_ENEMY": 7, "RANDOM_ENEMY": 8}
EL = {"fire": 0, "water": 1, "lightning": 2, "wind": 3, "poison": 4, "wood": 5, "soul": 6}
PATH = {"destruction": 0, "hunt": 1, "erudition": 2, "harmony": 3, "nihility": 4, "preservation": 5, "abundance": 6}
ELCOL = {0: "Color(0.909804, 0.333333, 0.168627, 1)", 1: "Color(0.227451, 0.552941, 0.870588, 1)",
         2: "Color(0.65098, 0.356863, 0.94902, 1)", 3: "Color(0.309804, 0.819608, 0.709804, 1)",
         4: "Color(0.607843, 0.772549, 0.239216, 1)", 5: "Color(0.180392, 0.545098, 0.341176, 1)",
         6: "Color(0.94902, 0.835294, 0.541176, 1)"}
EFFECT_SCRIPTS = {
    "damage": "damage_effect", "heal": "heal_effect", "shield": "shield_effect", "status": "apply_status_effect",
    "turn": "turn_shift_effect", "energy": "energy_effect", "sp": "skill_point_effect", "cleanse": "cleanse_effect",
    "hp_cost": "hp_cost_effect", "revive": "revive_effect", "summon": "summon_effect", "maxhp": "max_hp_damage_effect",
    "tough_pct": "toughness_damage_effect", "summon_enemy": "summon_enemy_effect", "buff_transfer": "buff_transfer_effect",
    "remove_status": "remove_status_effect"}


class Tres:
    """Ghép file .tres: ext_resource, sub_resource, resource."""
    def __init__(self, script_class, script_path):
        self.script_class = script_class
        self.ext = []
        self.ext_ids = {}
        self.subs = []
        self.main_script = self.ext_id("Script", script_path)

    def ext_id(self, kind, path):
        if path not in self.ext_ids:
            rid = "%d_%s" % (len(self.ext) + 1, os.path.basename(path).split(".")[0][:24])
            self.ext_ids[path] = rid
            self.ext.append('[ext_resource type="%s" path="%s" id="%s"]' % (kind, path, rid))
        return 'ExtResource("%s")' % self.ext_ids[path]

    def sub(self, sid, script_path, props):
        lines = ['[sub_resource type="Resource" id="%s"]' % sid, "script = " + self.ext_id("Script", script_path)]
        lines += ["%s = %s" % (k, v) for k, v in props]
        self.subs.append("\n".join(lines) + "\n")
        return 'SubResource("%s")' % sid

    def write(self, path, props):
        body = ['[gd_resource type="Resource" script_class="%s" format=3]' % self.script_class, ""]
        body += self.ext + [""]
        body += self.subs
        body += ["[resource]", "script = " + self.main_script] + ["%s = %s" % (k, v) for k, v in props]
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write("\n".join(body) + "\n")


def res(path):
    return "res://" + path


def f(x):
    return repr(float(x))


def effect_list(t, effects, prefix="Effect"):
    """effects: list of (type, dict). Trả về biểu thức mảng typed SkillEffect."""
    base = t.ext_id("Script", res("systems/skill_effects/skill_effect.gd"))
    refs = []
    for i, (etype, p) in enumerate(effects):
        props = []
        if "scope" in p:
            props.append(("scope", SCOPE[p["scope"]]))
        if etype == "damage":
            props += [("scaling_stat", STAT[p.get("stat", "ATK")]), ("multiplier", f(p["mult"]))]
            if p.get("adj"): props.append(("adjacent_multiplier", f(p["adj"])))
            if p.get("tough"): props.append(("toughness", f(p["tough"])))
            if p.get("tough_adj"): props.append(("toughness_adjacent", f(p["tough_adj"])))
        elif etype == "heal":
            if p.get("target_max_hp"): props.append(("source", 1))
            props += [("scaling_stat", STAT[p.get("stat", "ATK")]), ("multiplier", f(p["mult"]))]
            if p.get("flat"): props.append(("flat", f(p["flat"])))
        elif etype == "shield":
            props += [("scaling_stat", STAT[p.get("stat", "DEF")]), ("multiplier", f(p["mult"])), ("flat", f(p.get("flat", 0))),
                      ("status", t.ext_id("Resource", res("data/status_effects/%s.tres" % p["status"])))]
        elif etype == "status":
            props.append(("status", t.ext_id("Resource", res("data/status_effects/%s.tres" % p["status"]))))
            if p.get("base_mult"):
                props += [("base_stat", STAT[p.get("stat", "ATK")]), ("base_multiplier", f(p["base_mult"]))]
            if p.get("extend_if_self"):
                props.append(("extend_if_self", "true"))
        elif etype == "turn":
            props.append(("amount", f(p["amount"])))
        elif etype == "energy":
            props.append(("amount", f(p["amount"])))
        elif etype == "sp":
            props.append(("amount", p["amount"]))
        elif etype == "cleanse":
            props.append(("count", p.get("count", 1)))
        elif etype == "hp_cost":
            props.append(("current_hp_ratio", f(p["ratio"])))
        elif etype == "revive":
            props += [("hp_ratio", f(p["ratio"])), ("max_uses", p.get("uses", 1))]
        elif etype == "summon":
            props += [("name_key", '"%s"' % p["name_key"]), ("letter", '"%s"' % p["letter"]), ("color", p["color"]),
                      ("speed", f(p["speed"])), ("hp_ratio", f(p["hp_ratio"])),
                      ("skill", t.ext_id("Resource", res("data/skills/%s.tres" % p["skill"]))), ("turns", p["turns"])]
            if p.get("only_if_absent"): props.append(("only_if_absent", "true"))
        elif etype in ("maxhp", "tough_pct"):
            props.append(("ratio", f(p["ratio"])))
        elif etype == "summon_enemy":
            props += [("enemy", t.ext_id("Resource", res("data/enemies/%s.tres" % p["enemy"]))), ("count", p.get("count", 1))]
            if p.get("level_offset"): props.append(("level_offset", p["level_offset"]))
        elif etype == "buff_transfer":
            props += [("steal", "true" if p.get("steal") else "false"), ("count", p.get("count", 1))]
        elif etype == "remove_status":
            props.append(("status_id", '&"%s"' % p["status"]))
            if p.get("any_source"): props.append(("only_own", "false"))
        refs.append(t.sub("%s_%d" % (prefix, i + 1), res("systems/skill_effects/%s.gd" % EFFECT_SCRIPTS[etype]), props))
    return "Array[%s]([%s])" % (base, ", ".join(refs))


def skill(sid, kind, target, effects, sp=0, en=0.0, self_ok=True, alternate=None):
    t = Tres("SkillData", res("systems/resources/skill_data.gd"))
    props = [("id", '&"%s"' % sid), ("name_key", '"SKILL_%s"' % sid.upper()), ("desc_key", '"SKILL_%s_DESC"' % sid.upper()),
             ("kind", KIND[kind]), ("target", TGT[target])]
    if not self_ok: props.append(("can_target_self", "false"))
    props.append(("effects", effect_list(t, effects)))
    if sp: props.append(("sp_change", sp))
    if en: props.append(("energy_gain", f(en)))
    if alternate: props.append(("alternate", t.ext_id("Resource", res("data/skills/%s.tres" % alternate))))
    t.write("data/skills/%s.tres" % sid, props)


def status(sid, kind, text, color, dur=2, stacks=1, add=False, chance=1.0, ignore=False, mods=(), dot=None,
           taunt=False, shield=False, hot=0.0, extra=()):
    t = Tres("StatusEffectData", res("systems/resources/status_effect_data.gd"))
    props = [("id", '&"%s"' % sid), ("name_key", '"STATUS_%s"' % sid.upper()), ("desc_key", '"STATUS_%s_DESC"' % sid.upper()),
             ("kind", 0 if kind == "buff" else 1), ("icon_text", '"%s"' % text), ("icon_color", color),
             ("duration_turns", dur), ("max_stacks", stacks)]
    if add: props.append(("stack_mode", 1))
    props.append(("base_chance", f(chance)))
    if ignore: props.append(("ignores_resistance", "true"))
    if mods:
        refs = [t.sub("Mod_%d" % i, res("systems/resources/stat_modifier_data.gd"),
                      [("stat", STAT[m[0]]), ("flat", f(m[1])), ("percent", f(m[2]))]) for i, m in enumerate(mods)]
        props.append(("stat_modifiers", "Array[%s]([%s])" % (t.ext_id("Script", res("systems/resources/stat_modifier_data.gd")), ", ".join(refs))))
    if hot: props.append(("heal_per_turn_ratio", f(hot)))
    if dot:
        mode, el, mult = dot
        props += [("dot_mode", mode), ("dot_element", el), ("dot_multiplier", f(mult))]
    if taunt: props.append(("taunt", "true"))
    if shield: props.append(("shield", "true"))
    props += list(extra)
    t.write("data/status_effects/%s.tres" % sid, props)


def opener(sid, element, rng, arc, cd):
    t = Tres("OpenerAttackData", res("systems/resources/opener_attack_data.gd"))
    t.write("data/skills/%s.tres" % sid, [("name_key", '"SKILL_%s"' % sid.upper()), ("element", element),
            ("range_px", f(rng)), ("arc_degrees", f(arc)), ("cooldown_sec", f(cd))])


def technique(sid, kind, action, effects, distance=4.0, radius=2.0, duration=8.0, speed=0.0, force_adv=False):
    t = Tres("TechniqueData", res("systems/resources/technique_data.gd"))
    kinds = {"NEXT_BATTLE": 0, "MAP_ENEMIES": 1, "EXPLORATION": 2}
    actions = {"NONE": 0, "PHASE_DASH": 1, "FIREWORK_DAZE": 2, "INVISIBILITY": 3, "DASH_TRAIL": 4, "ARROW": 5, "TRAP": 6,
               "SPEED_BOOST": 7, "REVEAL_SECRETS": 8, "HEAL_TEAM": 9, "LONG_DASH": 10, "MAGNET": 11,
               "REVEAL_ENEMIES": 12, "RETURN_TO_REST": 13}
    props = [("id", '&"%s"' % sid), ("name_key", '"SKILL_%s"' % sid.upper()), ("desc_key", '"SKILL_%s_DESC"' % sid.upper()),
             ("kind", kinds[kind]), ("battle_start_effects", effect_list(t, effects)), ("map_action", actions[action]),
             ("distance_tiles", f(distance)), ("radius_tiles", f(radius)), ("duration_sec", f(duration)), ("speed_bonus", f(speed))]
    if force_adv: props.append(("marks_force_advantage", "true"))
    t.write("data/skills/%s.tres" % sid, props)


def character(cid, rarity, element, path, energy, lv1, lv80, skins, eidolons, gacha=True):
    t = Tres("CharacterData", res("systems/resources/character_data.gd"))
    stats = res("systems/resources/stat_block.gd")
    keys = ["hp", "atk", "def", "spd", "crit_rate", "crit_dmg", "break_effect", "energy_regen", "effect_hit", "outgoing_healing"]
    s1 = t.sub("Stats_lv1", stats, [(k, f(v)) for k, v in zip(keys, lv1)])
    s80 = t.sub("Stats_lv80", stats, [(k, f(v)) for k, v in zip(keys, lv80)])
    skin_refs = [t.sub("Skin_%s" % sk, res("systems/resources/character_skin.gd"),
                       [("skin_id", '&"%s"' % sk), ("label_key", '"%s"' % label), ("placeholder_color", col), ("accent_color", acc)])
                 for sk, label, col, acc in skins]
    talent = t.sub("Talent", res("systems/resources/talent_data.gd"),
                   [("name_key", '"TALENT_%s"' % cid.upper()), ("desc_key", '"TALENT_%s_DESC"' % cid.upper()),
                    ("script_class", t.ext_id("Script", res("data/characters/scripts/%s_talent.gd" % cid)))])
    eid_refs = []
    for i, e in enumerate(eidolons):
        props = [("name_key", '"EIDOLON_%s_%d"' % (cid.upper(), i + 1)), ("desc_key", '"EIDOLON_%s_%d_DESC"' % (cid.upper(), i + 1))]
        if e.get("bonus"):
            props += [("multiplier_bonus", f(e["bonus"])), ("bonus_kinds", "Array[int]([%s])" % ", ".join(str(KIND[k]) for k in e["kinds"]))]
        if e.get("mods"):
            mod_refs = [t.sub("Eidolon%d_Mod_%d" % (i + 1, j), res("systems/resources/stat_modifier_data.gd"),
                              [("stat", STAT[m[0]]), ("flat", f(m[1])), ("percent", f(m[2]))]) for j, m in enumerate(e["mods"])]
            props.append(("stat_modifiers", "Array[%s]([%s])" % (t.ext_id("Script", res("systems/resources/stat_modifier_data.gd")), ", ".join(mod_refs))))
        eid_refs.append(t.sub("Eidolon_%d" % (i + 1), res("systems/resources/eidolon_data.gd"), props))
    props = [("id", '&"%s"' % cid), ("name_key", '"CHAR_%s_NAME"' % cid.upper()), ("rarity", rarity), ("element", EL[element]),
             ("path", PATH[path])]
    if not gacha: props.append(("in_gacha_pool", "false"))
    props += [("skins", "Array[%s]([%s])" % (t.ext_id("Script", res("systems/resources/character_skin.gd")), ", ".join(skin_refs))),
              ("stats_lv1", s1), ("stats_lv80", s80), ("max_energy", f(energy)),
              ("basic_attack", t.ext_id("Resource", res("data/skills/%s_basic.tres" % cid))),
              ("skill", t.ext_id("Resource", res("data/skills/%s_skill.tres" % cid))),
              ("ultimate", t.ext_id("Resource", res("data/skills/%s_ultimate.tres" % cid))),
              ("talent", talent),
              ("eidolons", "Array[%s]([%s])" % (t.ext_id("Script", res("systems/resources/eidolon_data.gd")), ", ".join(eid_refs))),
              ("opener", t.ext_id("Resource", res("data/skills/%s_opener.tres" % cid))),
              ("technique", t.ext_id("Resource", res("data/skills/%s_technique.tres" % cid)))]
    t.write("data/characters/%s.tres" % cid, props)


def build_phase6():
    BUFF_COL = "Color(1, 0.75, 0.4, 1)"
    # ---------------- Hiệu ứng trạng thái ----------------
    status("shield", "buff", "Kh", "Color(0.85, 0.9, 1, 1)", dur=2, ignore=True, shield=True)
    status("soul_resonance", "buff", "CH", ELCOL[6], dur=2, stacks=2, add=True, ignore=True, mods=[("ATK", 0, 0.2)])
    status("soul_resonance_e1", "buff", "CH", ELCOL[6], dur=2, stacks=3, add=True, ignore=True, mods=[("ATK", 0, 0.2)])
    status("mira_mist", "buff", "SD", ELCOL[1], dur=2, ignore=True, hot=0.06)
    status("kiri_kindle", "buff", "TB", ELCOL[0], dur=2, ignore=True, mods=[("ATK", 0, 0.2)])
    status("kiri_kindle_e1", "buff", "TB", ELCOL[0], dur=2, ignore=True, mods=[("ATK", 0, 0.3)])
    status("kiri_kindle_e6", "buff", "TB", ELCOL[0], dur=2, ignore=True, mods=[("ATK", 0, 0.3), ("SPD", 0, 0.1)])
    status("kiri_festival", "buff", "LH", BUFF_COL, dur=2, ignore=True, mods=[("DAMAGE_BONUS", 0.2, 0)])
    status("kiri_rhythm", "buff", "NL", BUFF_COL, dur=99, stacks=3, add=True, ignore=True)
    status("kiri_firework_burn", "debuff", "TĐ", ELCOL[0], dur=2, chance=1.0, dot=(3, EL["fire"], 0.5))
    status("garren_taunt", "buff", "KK", ELCOL[5], dur=1, ignore=True, taunt=True)
    status("nyx_leak", "debuff", "RĐ", ELCOL[2], dur=2, chance=1.0, dot=(3, EL["lightning"], 0.5))
    status("nyx_short_circuit", "debuff", "ĐM", ELCOL[2], dur=2, chance=1.0, mods=[("DEF_REDUCTION", 0.15, 0)])
    status("nyx_static", "debuff", "TĐi", ELCOL[2], dur=2, chance=1.0, mods=[("VULNERABILITY", 0.15, 0)])
    status("nyx_slow", "debuff", "CH", "Color(0.6, 0.7, 1, 1)", dur=1, chance=1.0, mods=[("SPD", 0, -0.1)])

    # ---------------- Kỹ năng ----------------
    # Nhân vật chính (Hồn, Hủy Diệt) – theo mẫu mục 7.
    skill("traveler_basic", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.0, "tough": 10})], sp=1, en=20)
    skill("traveler_skill", "SKILL", "BLAST_ENEMY", [("damage", {"mult": 1.25, "adj": 0.5, "tough": 20, "tough_adj": 10})], sp=-1, en=30)
    skill("traveler_ultimate_single", "ULTIMATE", "SINGLE_ENEMY", [("damage", {"mult": 4.5, "tough": 30})], en=5)
    skill("traveler_ultimate", "ULTIMATE", "BLAST_ENEMY", [("damage", {"mult": 2.7, "adj": 1.6, "tough": 30, "tough_adj": 20})],
          en=5, alternate="traveler_ultimate_single")
    # Mira (Nước, Trù Phú).
    skill("mira_basic", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.0, "tough": 10})], sp=1, en=20)
    skill("mira_skill", "SKILL", "SINGLE_ALLY", [("heal", {"mult": 0.4, "flat": 80}), ("cleanse", {"count": 1})], sp=-1, en=30)
    skill("mira_ultimate", "ULTIMATE", "ALL_ALLIES", [("heal", {"mult": 0.3, "flat": 60}), ("cleanse", {"count": 1})], en=5)
    skill("mira_talent_heal", "FOLLOW_UP", "SINGLE_ALLY", [("heal", {"target_max_hp": True, "mult": 0.15})])
    # Kiri (Lửa, Hòa Hợp).
    skill("kiri_basic", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.0, "tough": 10})], sp=1, en=20)
    skill("kiri_skill", "SKILL", "SINGLE_ALLY", [("turn", {"amount": 0.5}), ("status", {"status": "kiri_kindle"})],
          sp=-1, en=30, self_ok=False)
    skill("kiri_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 0.6, "tough": 10}),
          ("status", {"status": "kiri_festival", "scope": "ALL_ALLIES"})], en=5)
    # Garren (Mộc, Bảo Hộ).
    skill("garren_basic", "BASIC", "SINGLE_ENEMY", [("damage", {"stat": "DEF", "mult": 1.0, "tough": 10})], sp=1, en=20)
    skill("garren_skill", "SKILL", "SELF", [("shield", {"scope": "ALL_ALLIES", "mult": 0.3, "flat": 80, "status": "shield"}),
          ("status", {"status": "garren_taunt", "scope": "SELF"})], sp=-1, en=30)
    skill("garren_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"stat": "DEF", "mult": 0.9, "tough": 20}),
          ("turn", {"amount": -0.15})], en=5)
    skill("garren_counter", "FOLLOW_UP", "SINGLE_ENEMY", [("damage", {"stat": "DEF", "mult": 0.5, "tough": 10})])
    skill("garren_counter_e6", "FOLLOW_UP", "SINGLE_ENEMY", [("damage", {"stat": "DEF", "mult": 0.75, "tough": 10}),
          ("turn", {"amount": -0.1})])
    # Nyx (Sét, Hư Vô).
    skill("nyx_basic", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.0, "tough": 10})], sp=1, en=20)
    skill("nyx_skill", "SKILL", "SINGLE_ENEMY", [("damage", {"mult": 0.6, "tough": 20}),
          ("status", {"status": "nyx_leak", "base_mult": 1.0}), ("status", {"status": "nyx_short_circuit"})], sp=-1, en=30)
    skill("nyx_ultimate", "ULTIMATE", "ALL_ENEMIES", [("damage", {"mult": 0.7, "tough": 20}), ("status", {"status": "nyx_static"})], en=5)
    # Quái (dữ liệu cũ chuyển sang hiệu ứng ghép).
    skill("warp_sprout_bite", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    skill("wandering_shade_touch", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 0.9})])
    skill("wandering_shade_wail", "SKILL", "ALL_ENEMIES", [("damage", {"mult": 0.45})])
    skill("rusted_knight_slash", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 1.0})])
    skill("rusted_knight_sweep", "SKILL", "BLAST_ENEMY", [("damage", {"mult": 0.7, "adj": 0.4})])
    skill("training_dummy_poke", "BASIC", "SINGLE_ENEMY", [("damage", {"mult": 0.05})])

    # ---------------- Đòn Mở Màn ----------------
    opener("traveler_opener", EL["soul"], 120, 120, 0.6)
    opener("mira_opener", EL["water"], 150, 60, 0.7)
    opener("kiri_opener", EL["fire"], 130, 90, 0.6)
    opener("garren_opener", EL["wood"], 110, 140, 0.8)
    opener("nyx_opener", EL["lightning"], 140, 70, 0.5)

    # ---------------- Bí Kỹ ----------------
    technique("traveler_technique", "EXPLORATION", "PHASE_DASH", [("turn", {"scope": "SELF", "amount": 0.25})], distance=4)
    technique("mira_technique", "NEXT_BATTLE", "NONE", [("status", {"scope": "ALL_ALLIES", "status": "mira_mist"})])
    technique("kiri_technique", "MAP_ENEMIES", "FIREWORK_DAZE",
              [("status", {"scope": "ALL_ENEMIES", "status": "kiri_firework_burn", "base_mult": 1.0})], distance=3, radius=2.5, duration=8)
    technique("garren_technique", "NEXT_BATTLE", "NONE",
              [("shield", {"scope": "ALL_ALLIES", "mult": 0.25, "flat": 60, "status": "shield"})])
    technique("nyx_technique", "EXPLORATION", "INVISIBILITY", [], duration=10, speed=0.2)

    # ---------------- Nhân vật ----------------
    GOLD = ELCOL[6]
    STD_E35 = [{"bonus": 0.15, "kinds": ["BASIC", "SKILL"]}, {"bonus": 0.15, "kinds": ["ULTIMATE"]}]
    character("traveler", 5, "soul", "destruction", 120,
              (160, 80, 60, 100, 0.05, 0.5, 0, 1, 0), (1200, 620, 460, 100, 0.05, 0.5, 0, 1, 0),
              [("male", "CHARSEL_MALE", "Color(0.168627, 0.298039, 0.494118, 1)", GOLD),
               ("female", "CHARSEL_FEMALE", "Color(0.494118, 0.168627, 0.360784, 1)", GOLD)],
              [{}, {}, STD_E35[0], {}, STD_E35[1], {}], gacha=False)
    character("mira", 4, "water", "abundance", 100,
              (150, 60, 55, 105, 0.05, 0.5, 0, 1, 0), (1100, 480, 420, 105, 0.05, 0.5, 0, 1, 0),
              [("default", "", "Color(0.227, 0.553, 0.871, 1)", "Color(0.8, 0.93, 1, 1)")],
              [{"bonus": 0.1, "kinds": ["SKILL"]}, {}, STD_E35[0], {}, STD_E35[1], {}])
    character("kiri", 4, "fire", "harmony", 110,
              (140, 70, 50, 110, 0.05, 0.5, 0, 1, 0), (1050, 540, 400, 110, 0.05, 0.5, 0, 1, 0),
              [("default", "", "Color(0.91, 0.333, 0.169, 1)", "Color(1, 0.85, 0.5, 1)")],
              [{}, {}, STD_E35[0], {}, STD_E35[1], {}])
    character("garren", 4, "wood", "preservation", 120,
              (200, 55, 80, 92, 0.05, 0.5, 0, 1, 0), (1500, 420, 600, 92, 0.05, 0.5, 0, 1, 0),
              [("default", "", "Color(0.18, 0.545, 0.341, 1)", "Color(0.75, 0.95, 0.6, 1)")],
              [{"bonus": 0.1, "kinds": ["SKILL"]}, {}, STD_E35[0], {}, STD_E35[1], {}])
    character("nyx", 4, "lightning", "nihility", 110,
              (135, 75, 50, 106, 0.05, 0.5, 0, 1, 0.1), (1000, 580, 380, 106, 0.05, 0.5, 0, 1, 0.1),
              [("default", "", "Color(0.4, 0.22, 0.6, 1)", "Color(0.85, 0.7, 1, 1)")],
              [{}, {}, STD_E35[0], {}, STD_E35[1], {"mods": [("EFFECT_HIT", 0.2, 0)]}])
    print("Xong: dữ liệu 5 nhân vật.")


if __name__ == "__main__":
    build_phase6()

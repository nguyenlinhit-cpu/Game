#!/usr/bin/env python3
"""Sinh dữ liệu tiến trình Phase 9: vật phẩm (data/items), bảng EXP / đột phá / chi phí kỹ năng
(data/config/progression.tres), 7 cây vận mệnh (data/progression/traces), file dịch localization/progression.csv
và bảng chi phí docs/PROGRESSION.md.
Chạy: python3 tools/data_builder/build_progression.py   (từ thư mục dự án). Ghi đè file cũ."""
import csv, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from build_characters import Tres, res, f, STAT, EL, PATH, ELCOL  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
os.chdir(ROOT)

TEXT = {}
CAT = {"CURRENCY": 0, "EXP": 1, "ASCENSION": 2, "SIGIL": 3, "UPGRADE": 4, "WISH": 5, "CONSUMABLE": 6}
EL_NAME = {"fire": ("Lửa", "Fire"), "water": ("Nước", "Water"), "lightning": ("Sét", "Lightning"), "wind": ("Phong", "Wind"),
           "poison": ("Độc", "Poison"), "wood": ("Mộc", "Wood"), "soul": ("Hồn", "Soul")}
PATH_NAME = {"destruction": ("Hủy Diệt", "Destruction"), "hunt": ("Săn Bắn", "The Hunt"), "erudition": ("Tri Thức", "Erudition"),
             "harmony": ("Hòa Hợp", "Harmony"), "nihility": ("Hư Vô", "Nihility"), "preservation": ("Bảo Hộ", "Preservation"),
             "abundance": ("Trù Phú", "Abundance")}
PATH_COLOR = {"destruction": "Color(0.85, 0.35, 0.3, 1)", "hunt": "Color(0.4, 0.75, 0.45, 1)",
              "erudition": "Color(0.55, 0.5, 0.9, 1)", "harmony": "Color(0.95, 0.75, 0.35, 1)",
              "nihility": "Color(0.6, 0.4, 0.7, 1)", "preservation": "Color(0.5, 0.65, 0.8, 1)",
              "abundance": "Color(0.45, 0.8, 0.65, 1)"}
PATH_ABBR = {"destruction": "HD", "hunt": "SB", "erudition": "TT", "harmony": "HH", "nihility": "HV", "preservation": "BH",
             "abundance": "TP"}
TIER_NAME = {1: ("Thô", "Rough"), 2: ("Tinh", "Refined"), 3: ("Thuần", "Pure")}
PASSIVE = {"NONE": 0, "START_ENERGY": 1, "LOW_HP_DAMAGE": 2, "DEBUFFED_TARGET_DAMAGE": 3, "BREAK_ENERGY": 4,
           "LOW_HP_HEAL": 5, "START_SHIELD": 6}

# ---------------- Bảng số (cân bằng ở đây) ----------------
MAX_DESIGN_LEVEL = 80
# EXP cần để lên cấp L+1 từ cấp L.
def exp_to_next(level):
    return int(round((120 + 30 * level + 4 * level * level) / 10.0)) * 10

COIN_PER_EXP = 0.1
# (cấp đột phá, giới hạn mới, xu, tinh thể). Mốc 30–70 chừa sẵn, bị khóa khi MAX_LEVEL = 30.
ASCENSIONS = [(10, 20, 4000, 4), (20, 30, 12000, 10), (30, 40, 30000, 15), (40, 50, 60000, 20),
              (50, 60, 100000, 25), (60, 70, 160000, 30), (70, 80, 240000, 40)]
SKILL_CAP_BY_ASCENSION = [2, 4, 5]
# (cấp, xu, bậc Dấu Ấn, số Dấu Ấn, Lõi Ma Biến, số lần đột phá cần)
# Phase 10 cân lại theo nguồn tài nguyên toàn bản đồ (docs/ECONOMY_REPORT.md): 4–5 nhân vật tối đa.
SKILL_COSTS = [(2, 800, 1, 2, 0, 0), (3, 2000, 2, 1, 0, 1), (4, 4000, 2, 1, 0, 1), (5, 6000, 3, 2, 1, 2)]
SKILL_MULT = [1.0, 1.1, 1.2, 1.3, 1.4]
SKILL_STATUS = [1.0, 1.05, 1.1, 1.15, 1.2]
EXP_ITEMS = [(1, 100), (2, 500), (3, 2000)]

# Cây vận mệnh: mỗi vận mệnh 2 chỉ số nhỏ (3 bậc mỗi chỉ số) + 3 nút lớn.
# Chỉ số nhỏ: (STAT, kiểu "pct"|"flat", giá trị bậc 1, 2, 3)
SMALL = {
    "destruction": [("ATK", "pct", [0.04, 0.04, 0.06]), ("HP", "pct", [0.04, 0.06, 0.06])],
    "hunt": [("ATK", "pct", [0.04, 0.04, 0.06]), ("CRIT_RATE", "flat", [0.02, 0.03, 0.03])],
    "erudition": [("ATK", "pct", [0.04, 0.06, 0.06]), ("DAMAGE_BONUS", "flat", [0.03, 0.03, 0.04])],
    "harmony": [("HP", "pct", [0.04, 0.04, 0.06]), ("SPD", "flat", [2, 2, 3])],
    "nihility": [("ATK", "pct", [0.04, 0.04, 0.06]), ("EFFECT_HIT", "flat", [0.03, 0.04, 0.05])],
    "preservation": [("DEF", "pct", [0.05, 0.05, 0.075]), ("HP", "pct", [0.04, 0.04, 0.06])],
    "abundance": [("HP", "pct", [0.04, 0.06, 0.06]), ("OUTGOING_HEALING", "flat", [0.03, 0.03, 0.04])],
}
# Nút lớn: (tên vi, tên en, mô tả vi, mô tả en, [chỉ số], passive, giá trị)
MAJORS = {
    "destruction": [
        ("Thân Thép", "Iron Body", "+10% Máu tối đa.", "+10% Max HP.", [("HP", 0, 0.1)], "NONE", 0),
        ("Liều Mạng", "Desperation", "Máu dưới 50%: +15% sát thương gây ra.", "Below 50% HP: +15% DMG.", [], "LOW_HP_DAMAGE", 0.15),
        ("Đà Phá Vỡ", "Breaking Momentum", "Phá Vỡ khiên quái thì hồi 10 năng lượng.", "Breaking an enemy restores 10 Energy.",
         [], "BREAK_ENERGY", 10),
    ],
    "hunt": [
        ("Mắt Diều Hâu", "Hawk Eye", "+12% Sát Thương Bạo Kích.", "+12% CRIT DMG.", [("CRIT_DMG", 0.12, 0)], "NONE", 0),
        ("Phục Kích", "Lie in Wait", "Vào trận với thêm 15% năng lượng.", "Starts battle with +15% Energy.", [], "START_ENERGY", 0.15),
        ("Kết Liễu", "Finisher", "+12% sát thương lên quái đang mang debuff.", "+12% DMG to debuffed enemies.", [],
         "DEBUFFED_TARGET_DAMAGE", 0.12),
    ],
    "erudition": [
        ("Uyên Bác", "Erudite", "+8% Tấn Công.", "+8% ATK.", [("ATK", 0, 0.08)], "NONE", 0),
        ("Phân Tích", "Analysis", "+12% sát thương lên quái đang mang debuff.", "+12% DMG to debuffed enemies.", [],
         "DEBUFFED_TARGET_DAMAGE", 0.12),
        ("Chuẩn Bị", "Preparation", "Vào trận với thêm 20% năng lượng.", "Starts battle with +20% Energy.", [], "START_ENERGY", 0.2),
    ],
    "harmony": [
        ("Nhịp Chung", "Common Beat", "+5 Tốc Độ.", "+5 SPD.", [("SPD", 5, 0)], "NONE", 0),
        ("Khởi Xướng", "Opening Act", "Vào trận với thêm 20% năng lượng.", "Starts battle with +20% Energy.", [], "START_ENERGY", 0.2),
        ("Hòa Âm", "Resonance", "+8% Hiệu Suất Hồi Năng Lượng.", "+8% Energy Regeneration.", [("ENERGY_REGEN", 0.08, 0)], "NONE", 0),
    ],
    "nihility": [
        ("Ám Ảnh", "Haunting", "+10% Chính Xác Hiệu Ứng.", "+10% Effect Hit Rate.", [("EFFECT_HIT", 0.1, 0)], "NONE", 0),
        ("Bào Mòn", "Erosion", "+15% sát thương lên quái đang mang debuff.", "+15% DMG to debuffed enemies.", [],
         "DEBUFFED_TARGET_DAMAGE", 0.15),
        ("Rạn Vỡ", "Fracture", "Phá Vỡ khiên quái thì hồi 10 năng lượng.", "Breaking an enemy restores 10 Energy.", [],
         "BREAK_ENERGY", 10),
    ],
    "preservation": [
        ("Tường Thành", "Rampart", "+10% Phòng Thủ.", "+10% DEF.", [("DEF", 0, 0.1)], "NONE", 0),
        ("Kiên Định", "Steadfast", "+15% Kháng Hiệu Ứng.", "+15% Effect RES.", [("EFFECT_RES", 0.15, 0)], "NONE", 0),
        ("Lá Chắn Đầu Trận", "Opening Guard", "Đầu trận nhận khiên bằng 40% Phòng Thủ trong 2 lượt.",
         "Gains a shield equal to 40% DEF at battle start for 2 turns.", [], "START_SHIELD", 0.4),
    ],
    "abundance": [
        ("Mạch Sống", "Lifeblood", "+8% Tăng Trị Liệu.", "+8% Outgoing Healing.", [("OUTGOING_HEALING", 0.08, 0)], "NONE", 0),
        ("Cấp Cứu", "Triage", "+15% lượng hồi lên đồng minh dưới 50% máu.", "+15% healing on allies below 50% HP.", [],
         "LOW_HP_HEAL", 0.15),
        ("Chuẩn Bị", "Preparation", "Vào trận với thêm 20% năng lượng.", "Starts battle with +20% Energy.", [], "START_ENERGY", 0.2),
    ],
}
# (xu, bậc Dấu Ấn, số Dấu Ấn, số lần đột phá cần) cho bậc 1–3 của nút nhỏ và nút lớn 1–3.
SMALL_COST = {1: (800, 1, 2, 0), 2: (2000, 2, 1, 1), 3: (4000, 2, 1, 2)}
MAJOR_COST = {1: (1500, 1, 3, 0), 2: (4000, 2, 1, 1), 3: (6000, 3, 1, 2)}
STAT_NAME = {"ATK": ("Tấn Công", "ATK"), "HP": ("Máu", "HP"), "DEF": ("Phòng Thủ", "DEF"), "SPD": ("Tốc Độ", "SPD"),
             "CRIT_RATE": ("Tỉ Lệ Bạo Kích", "CRIT Rate"), "DAMAGE_BONUS": ("Tăng Sát Thương", "DMG Boost"),
             "EFFECT_HIT": ("Chính Xác Hiệu Ứng", "Effect Hit Rate"), "OUTGOING_HEALING": ("Tăng Trị Liệu", "Outgoing Healing")}


def text(key, vi, en=None):
    TEXT[key] = (vi, en or vi)


def item(iid, vi, en, desc_vi, desc_en, cat, rarity, icon, color, **extra):
    t = Tres("ItemData", res("systems/resources/item_data.gd"))
    text("ITEM_%s" % iid.upper(), vi, en)
    text("ITEM_%s_DESC" % iid.upper(), desc_vi, desc_en)
    props = [("id", '&"%s"' % iid), ("name_key", '"ITEM_%s"' % iid.upper()), ("desc_key", '"ITEM_%s_DESC"' % iid.upper()),
             ("category", CAT[cat]), ("rarity", rarity), ("icon_text", '"%s"' % icon), ("icon_color", color)]
    for k, v in extra.items():
        props.append((k, "true" if v is True else str(v)))
    t.write("data/items/%s.tres" % iid, props)


def build_items():
    item("aether_coin", "Xu Aether", "Aether Coin", "Đồng tiền chung của Pháo Đài, dùng cho mọi loại nâng cấp.",
         "The Fortress's common currency, used for every upgrade.", "CURRENCY", 2, "Xu", "Color(0.95, 0.8, 0.35, 1)")
    for tier, exp in EXP_ITEMS:
        vi = ["Ký Ức Mảnh Hồn Vụn", "Ký Ức Mảnh Hồn", "Ký Ức Mảnh Hồn Sáng"][tier - 1]
        en = ["Faint Soul Memory", "Soul Memory", "Radiant Soul Memory"][tier - 1]
        item("soul_memory_%d" % tier, vi, en, "Nhân vật nhận %d EXP." % exp, "Grants a character %d EXP." % exp, "EXP",
             tier + 1, "K%d" % tier, "Color(0.55, 0.75, 1, 1)", exp_value=exp)
    for el, (vi, en) in EL_NAME.items():
        item("crystal_%s" % el, "Tinh Thể %s" % vi, "%s Crystal" % en,
             "Dùng để đột phá nhân vật hệ %s ở cấp 10 và 20." % vi, "Ascends %s characters at levels 10 and 20." % en,
             "ASCENSION", 4, vi[0] + "T", ELCOL[EL[el]], element=EL[el])
    for path, (vi, en) in PATH_NAME.items():
        for tier in (1, 2, 3):
            item("sigil_%s_%d" % (path, tier), "Dấu Ấn %s (%s)" % (vi, TIER_NAME[tier][0]),
                 "%s Sigil (%s)" % (en, TIER_NAME[tier][1]),
                 "Nâng kỹ năng và cây vận mệnh của nhân vật vận mệnh %s." % vi,
                 "Upgrades skills and traces of %s characters." % en, "SIGIL", tier + 1, "%s%d" % (PATH_ABBR[path], tier),
                 PATH_COLOR[path], path=PATH[path], tier=tier)
    item("warp_core", "Lõi Ma Biến", "Warp Core", "Lõi năng lượng méo mó rơi từ boss, cần để nâng kỹ năng cấp cao.",
         "A twisted energy core dropped by bosses, needed for high skill levels.", "UPGRADE", 5, "LÕ", "Color(0.75, 0.3, 0.6, 1)")
    item("star_tear", "Lệ Tinh", "Star Tear", "Đá quý dùng để Ước Nguyện (gacha).", "A gem used to make Wishes (gacha).",
         "WISH", 5, "LT", "Color(0.75, 0.85, 1, 1)")
    item("wish_ticket_standard", "Vé Ước Nguyện Thường", "Standard Wish Ticket", "1 lượt quay banner thường.",
         "One pull on the standard banner.", "WISH", 4, "VT", "Color(0.6, 0.75, 0.95, 1)")
    item("wish_ticket_limited", "Vé Ước Nguyện Giới Hạn", "Limited Wish Ticket", "1 lượt quay banner giới hạn.",
         "One pull on the limited banner.", "WISH", 5, "VG", "Color(0.95, 0.6, 0.8, 1)")
    item("stardust", "Bụi Sao", "Stardust", "Nhận khi có nhân vật trùng; đổi vé và Tinh Thể ở cửa hàng.",
         "Earned from duplicate characters; exchange for tickets and crystals.", "WISH", 3, "BS", "Color(0.85, 0.85, 0.95, 1)")
    item("technique_box", "Hộp Bí Kỹ", "Technique Box", "Dùng: hồi 1 Điểm Bí Kỹ.", "Use: restores 1 Technique Point.",
         "CONSUMABLE", 3, "BK", "Color(0.78, 0.55, 1, 1)", usable=True)


def build_config():
    t = Tres("ProgressionConfig", res("systems/resources/progression_config.gd"))
    asc_script = res("systems/resources/ascension_data.gd")
    asc = [t.sub("Ascension_%d" % i, asc_script, [("at_level", a), ("new_cap", c), ("coin", coin), ("crystals", cr)])
           for i, (a, c, coin, cr) in enumerate(ASCENSIONS)]
    cost_script = res("systems/resources/skill_level_cost.gd")
    costs = [t.sub("SkillCost_%d" % lv, cost_script, [("level", lv), ("coin", coin), ("sigil_tier", tier),
                                                        ("sigil_count", n), ("warp_cores", core), ("required_ascension", a)])
             for lv, coin, tier, n, core, a in SKILL_COSTS]
    table = [exp_to_next(lv) for lv in range(1, MAX_DESIGN_LEVEL)]
    t.write("data/config/progression.tres", [
        ("exp_to_next", "PackedInt32Array(%s)" % ", ".join(map(str, table))),
        ("coin_per_exp", f(COIN_PER_EXP)),
        ("ascensions", "Array[%s]([%s])" % (t.ext_id("Script", asc_script), ", ".join(asc))),
        ("skill_cap_by_ascension", "PackedInt32Array(%s)" % ", ".join(map(str, SKILL_CAP_BY_ASCENSION))),
        ("max_skill_level", 5),
        ("skill_costs", "Array[%s]([%s])" % (t.ext_id("Script", cost_script), ", ".join(costs))),
        ("skill_multiplier_scale", "PackedFloat32Array(%s)" % ", ".join(map(str, SKILL_MULT))),
        ("skill_status_scale", "PackedFloat32Array(%s)" % ", ".join(map(str, SKILL_STATUS))),
    ])


def fmt_stat(stat, kind, value):
    vi, en = STAT_NAME[stat]
    if kind == "pct":
        return "+%g%% %s" % (value * 100, vi), "+%g%% %s" % (value * 100, en)
    if stat == "SPD":
        return "+%g %s" % (value, vi), "+%g %s" % (value, en)
    return "+%g%% %s" % (value * 100, vi), "+%g%% %s" % (value * 100, en)


def build_traces():
    node_script = res("systems/resources/trace_node_data.gd")
    mod_script = res("systems/resources/stat_modifier_data.gd")
    for path in PATH_NAME:
        t = Tres("TraceTreeData", res("systems/resources/trace_tree_data.gd"))
        refs = []
        order = []
        # Thứ tự: bậc 1 (2 nhỏ + lớn 1), bậc 2 (2 nhỏ + lớn 2), bậc 3 (2 nhỏ + lớn 3).
        for tier in (1, 2, 3):
            for si, (stat, kind, values) in enumerate(SMALL[path]):
                order.append(("small", tier, si, stat, kind, values[tier - 1]))
            order.append(("major", tier))
        previous_small = {}
        for entry in order:
            if entry[0] == "small":
                _, tier, si, stat, kind, value = entry
                nid = "%s_s%d_%d" % (path, si + 1, tier)
                vi, en = fmt_stat(stat, kind, value)
                key = "TRACE_%s" % nid.upper()
                text(key, vi, en)
                text(key + "_DESC", vi, en)
                mod = t.sub("Mod_%s" % nid, mod_script, [("stat", STAT[stat]),
                                                        ("flat", f(0 if kind == "pct" else value)),
                                                        ("percent", f(value if kind == "pct" else 0))])
                coin, stier, n, asc = SMALL_COST[tier]
                props = [("id", '&"%s"' % nid), ("name_key", '"%s"' % key), ("desc_key", '"%s_DESC"' % key),
                         ("required_ascension", asc), ("coin", coin), ("sigil_tier", stier), ("sigil_count", n),
                         ("stat_modifiers", "Array[%s]([%s])" % (t.ext_id("Script", mod_script), mod))]
                if si in previous_small:
                    props.append(("requires", '&"%s"' % previous_small[si]))
                previous_small[si] = nid
            else:
                tier = entry[1]
                vi, en, dvi, den, mods, passive, value = MAJORS[path][tier - 1]
                nid = "%s_m%d" % (path, tier)
                key = "TRACE_%s" % nid.upper()
                text(key, vi, en)
                text(key + "_DESC", dvi, den)
                coin, stier, n, asc = MAJOR_COST[tier]
                props = [("id", '&"%s"' % nid), ("name_key", '"%s"' % key), ("desc_key", '"%s_DESC"' % key), ("major", "true"),
                         ("required_ascension", asc), ("coin", coin), ("sigil_tier", stier), ("sigil_count", n)]
                if tier > 1:
                    props.append(("requires", '&"%s_m%d"' % (path, tier - 1)))
                if mods:
                    mrefs = [t.sub("Mod_%s_%d" % (nid, i), mod_script, [("stat", STAT[m[0]]), ("flat", f(m[1])),
                                                                        ("percent", f(m[2]))]) for i, m in enumerate(mods)]
                    props.append(("stat_modifiers", "Array[%s]([%s])" % (t.ext_id("Script", mod_script), ", ".join(mrefs))))
                if passive != "NONE":
                    props += [("passive", PASSIVE[passive]), ("passive_value", f(value))]
            refs.append(t.sub("Node_%s" % nid, node_script, props))
        t.write("data/progression/traces/%s.tres" % path, [
            ("path", PATH[path]), ("nodes", "Array[%s]([%s])" % (t.ext_id("Script", node_script), ", ".join(refs)))])


def write_translations():
    with open(os.path.join(ROOT, "localization", "progression.csv"), "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["keys", "vi", "en"])
        for key in sorted(TEXT):
            w.writerow([key, TEXT[key][0], TEXT[key][1]])


def write_doc():
    lines = ["# Tiến trình nhân vật – bảng chi phí", "", "Sinh tự động bởi `tools/data_builder/build_progression.py` – đừng sửa tay.",
             "Giới hạn cấp hiện tại: 30 (`GameConfig.MAX_LEVEL`). Ký Ức Mảnh Hồn: bậc 1/2/3 = 100/500/2000 EXP; "
             "nạp EXP tốn %g Xu mỗi EXP." % COIN_PER_EXP, "", "## EXP lên cấp", "",
             "| Cấp | EXP lên cấp kế | Cộng dồn từ cấp 1 |", "| --- | --- | --- |"]
    total = 0
    for lv in range(1, 30):
        total += exp_to_next(lv)
        lines.append("| %d → %d | %d | %d |" % (lv, lv + 1, exp_to_next(lv), total))
    exp_total = total
    lines += ["", "## Đột phá", "", "| Ở cấp | Giới hạn mới | Xu Aether | Tinh Thể đúng nguyên tố | Trạng thái |",
              "| --- | --- | --- | --- | --- |"]
    for a, c, coin, cr in ASCENSIONS:
        lines.append("| %d | %d | %d | %d | %s |" % (a, c, coin, cr, "Mở" if c <= 30 else "Khóa (chờ nâng giới hạn)"))
    lines += ["", "## Nâng kỹ năng (mỗi kỹ năng: Đánh thường, Chiến kỹ, Tuyệt kỹ, Đặc tính)", "",
              "Cấp kỹ năng tối đa theo số lần đột phá: %s. Hệ số sát thương/hồi/khiên theo cấp: %s; độ mạnh buff/debuff: %s." % (
                  " / ".join("%d lần → cấp %d" % (i, c) for i, c in enumerate(SKILL_CAP_BY_ASCENSION)),
                  ", ".join("×%g" % m for m in SKILL_MULT), ", ".join("×%g" % m for m in SKILL_STATUS)), "",
              "| Lên cấp | Xu Aether | Dấu Ấn Vận Mệnh | Lõi Ma Biến | Cần đột phá |", "| --- | --- | --- | --- | --- |"]
    for lv, coin, tier, n, core, a in SKILL_COSTS:
        lines.append("| %d | %d | %d × bậc %d | %d | %d lần |" % (lv, coin, n, tier, core, a))
    lines += ["", "## Cây vận mệnh (mỗi vận mệnh 6 nút nhỏ + 3 nút lớn)", "",
              "| Nút | Xu Aether | Dấu Ấn | Cần đột phá |", "| --- | --- | --- | --- |"]
    for tier in (1, 2, 3):
        coin, st, n, a = SMALL_COST[tier]
        lines.append("| 2 nút nhỏ bậc %d (mỗi nút) | %d | %d × bậc %d | %d lần |" % (tier, coin, n, st, a))
        coin, st, n, a = MAJOR_COST[tier]
        lines.append("| Nút lớn %d | %d | %d × bậc %d | %d lần |" % (tier, coin, n, st, a))
    lines += ["", "### Nút lớn theo vận mệnh", ""]
    for path, majors in MAJORS.items():
        lines.append("- **%s**: " % PATH_NAME[path][0] + "; ".join("%s – %s" % (m[0], m[2]) for m in majors))
    # Tổng một nhân vật lên tối đa.
    coin_level = exp_total * COIN_PER_EXP
    coin_asc = sum(c for a, cap, c, cr in ASCENSIONS if cap <= 30)
    crystals = sum(cr for a, cap, c, cr in ASCENSIONS if cap <= 30)
    sig = {1: 0, 2: 0, 3: 0}
    coin_skill = 0
    cores = 0
    for lv, coin, tier, n, core, a in SKILL_COSTS:
        coin_skill += coin * 4
        sig[tier] += n * 4
        cores += core * 4
    coin_trace = 0
    for tier in (1, 2, 3):
        coin, st, n, a = SMALL_COST[tier]
        coin_trace += coin * 2
        sig[st] += n * 2
        coin, st, n, a = MAJOR_COST[tier]
        coin_trace += coin
        sig[st] += n
    total_coin = coin_level + coin_asc + coin_skill + coin_trace
    lines += ["", "## Tổng chi phí 1 nhân vật lên tối đa (cấp 30, 4 kỹ năng cấp 5, đủ cây vận mệnh)", "",
              "| Hạng mục | Số lượng |", "| --- | --- |",
              "| EXP (cấp 1 → 30) | %d (≈ %.1f Ký Ức bậc 3) |" % (exp_total, exp_total / 2000.0),
              "| Xu Aether | %d (cấp %d + đột phá %d + kỹ năng %d + cây %d) |" % (total_coin, coin_level, coin_asc, coin_skill, coin_trace),
              "| Tinh Thể Nguyên Tố | %d |" % crystals,
              "| Dấu Ấn Vận Mệnh | bậc 1: %d, bậc 2: %d, bậc 3: %d |" % (sig[1], sig[2], sig[3]),
              "| Lõi Ma Biến | %d |" % cores,
              "", "Mục tiêu mục 11: 4–5 nhân vật như trên → nhân 4–5 lần. Phase 10 cân bảng rơi đồ theo con số này.", ""]
    with open(os.path.join(ROOT, "docs", "PROGRESSION.md"), "w") as fh:
        fh.write("\n".join(lines))
    return exp_total, total_coin, crystals, sig, cores


if __name__ == "__main__":
    build_items()
    build_config()
    build_traces()
    write_translations()
    print("Xong. Tổng 1 nhân vật (EXP, Xu, Tinh Thể, Dấu Ấn, Lõi):", write_doc())

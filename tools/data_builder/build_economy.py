#!/usr/bin/env python3
"""Sinh dữ liệu kinh tế Phase 10:
- data/loot_tables/enemies/*.tres  (bảng rơi đồ quái theo loại / họ / boss, mục 11)
- data/loot_tables/chests/<khu>_<bậc>.tres  (rương thường / quý / giải đố từng khu)
- data/zones/<khu>.tres  (kế hoạch nội dung khu: trận đặt trên map, số rương – Phase 12 dựng map theo đây)
- data/config/economy_model.tres  (giả định "chơi hết bản đồ" + mục tiêu cho báo cáo kinh tế)
- data/quests/quest_config.tres  (nhiệm vụ ngày / tuần / thành tựu / người mới, mốc Hoạt Động, thưởng chương)
- localization/economy.csv
Chạy: python3 tools/data_builder/build_economy.py   (từ thư mục dự án). Ghi đè file cũ.
Báo cáo kinh tế: godot --headless --path . res://systems/economy_report.tscn  → docs/ECONOMY_REPORT.md"""
import csv, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from build_characters import Tres, res, f  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
os.chdir(ROOT)

TEXT = {}

# ---------------- Bảng rơi đồ quái (mục 11, cộng theo từng con) ----------------
# Dòng: (item, min, max, tỉ lệ, nhân theo mức Khó) ; item "pool:a,b" = chọn 1 trong danh sách mỗi món.
# Id đặc biệt: crystal_enemy (đúng nguyên tố quái), crystal_team / sigil_team_N (theo nguyên tố / vận mệnh của
# 1 nhân vật ngẫu nhiên trong đội đang dùng – người chơi nhận nguyên liệu cho chính đội mình).
NORMAL = [("aether_coin", 20, 40, 1.0, True), ("soul_memory_1", 1, 1, 0.6, False), ("sigil_team_1", 1, 1, 0.25, True),
          ("crystal_enemy", 1, 1, 0.03, True)]
ELITE = [("aether_coin", 200, 300, 1.0, True), ("soul_memory_2", 2, 2, 1.0, False), ("sigil_team_2", 1, 2, 1.0, True),
         ("crystal_enemy", 1, 1, 0.4, True)]
ELITE_FIRST = [("star_tear", 20, 20, 1.0, False)]
BOSS = [("aether_coin", 1500, 1500, 1.0, True), ("soul_memory_3", 3, 3, 1.0, False), ("sigil_team_3", 2, 2, 1.0, True),
        ("crystal_enemy", 3, 4, 1.0, False)]
BOSS_FIRST = [("star_tear", 100, 100, 1.0, False), ("warp_core", 1, 1, 1.0, False)]
# Mức Khó: các dòng trên ×2 (DifficultyConfig.reward_multiplier, trừ Ký Ức) + dòng thêm dưới đây.
BOSS_HARD_EXTRA = [("warp_core", 2, 2, 1.0, False)]
BOSS_FULL_CLAIMS_PER_DAY = 3

# ---------------- Khu và rương ----------------
# (id, tên vi, tên en, chương, số phòng, [(trận, số nhóm đặt trên map)], rương [thường, quý, giải đố], Hộp Bí Kỹ)
def normals(zone, ids, n=2):
    return [("%s_%s" % (zone, i), n) for i in ids]

ZONES = [
    ("library", "Thư Viện Câm Lặng", "Silent Library", 1, 11,
     normals("library", ["01_sprouts", "02_shade", "03_rats", "04_archer", "05_mage", "06_bees", "07_patrol"])
     + [("library_elite_librarian", 1), ("library_boss_warden", 1)], [6, 4, 4], 8),
    ("vault", "Kho Chứa Băng Giá", "Frozen Vault", 2, 10,
     normals("vault", ["01_sprouts", "02_knight", "03_mirror", "04_guards", "05_mixed", "06_patrol"])
     + [("vault_elite_knight", 1), ("vault_boss_behemoth", 1)], [6, 4, 4], 8),
    ("furnace", "Lò Năng Lượng", "Energy Furnace", 3, 10,
     normals("furnace", ["01_sprouts", "02_mage", "03_knight", "04_bees", "05_rats", "06_patrol"])
     + [("furnace_elite_matrix", 1), ("furnace_boss_core", 1)], [6, 4, 4], 8),
    ("tower", "Đỉnh Tháp Quan Sát", "Observatory Spire", 4, 12,
     normals("tower", ["01_shade", "02_mirror", "03_bees", "04_archers", "05_patrol", "06_sprouts"])
     + [("tower_elite_knight", 1), ("tower_elite_librarian", 1), ("tower_elite_matrix", 1), ("tower_boss_devourer", 1)],
     [6, 4, 4], 8),
]
CHEST_TIERS = ["normal", "precious", "puzzle"]
CHEST_STAR_TEARS = [5, 10, 20]  # mục 11, chỉ lần mở đầu (rương mở 1 lần)
# Theo khu (library, vault, furnace, tower): xu, Ký Ức [(bậc, số)], số Tinh Thể theo nguyên tố đội đang dùng.
CHEST_CONTENT = {
    "normal": {"coin": [1000, 1500, 2500, 3500], "memory": [(1, 1), (2, 1), (2, 2), (2, 3)], "crystals": 0},
    "precious": {"coin": [2500, 4000, 6000, 8000], "memory": [(1, 3), (2, 3), (3, 2), (3, 2)], "crystals": 2},
    "puzzle": {"coin": [4000, 6000, 9000, 12000], "memory": [(2, 1), (2, 4), (3, 3), (3, 3)], "crystals": 3},
}

# ---------------- Nhiệm vụ (mục 11b) ----------------
DAILY = [  # (id, tên vi, tên en, trigger, mục tiêu, Hoạt Động)
    ("daily_login", "Đăng nhập", "Log in", "login", 1, 100),
    ("daily_win_3", "Thắng 3 trận", "Win 3 battles", "battle_won", 3, 100),
    ("daily_elite", "Hạ 1 quái tinh anh hoặc boss", "Defeat 1 elite or boss", "elite_or_boss", 1, 100),
    ("daily_break_5", "Phá vỡ khiên quái 5 lần", "Break enemy Toughness 5 times", "weakness_broken", 5, 100),
    ("daily_technique_2", "Dùng Bí Kỹ 2 lần", "Use Techniques 2 times", "technique_used", 2, 50),
    ("daily_upgrade", "Nâng cấp nhân vật hoặc kỹ năng 1 lần", "Upgrade a character or skill once", "upgrade", 1, 50),
]
MILESTONES = [  # (điểm, thưởng)
    (100, {"star_tear": 10, "aether_coin": 1000, "soul_memory_1": 3}),
    (200, {"star_tear": 15, "aether_coin": 1500, "soul_memory_1": 3}),
    (300, {"star_tear": 20, "aether_coin": 2000, "soul_memory_2": 1}),
    (400, {"star_tear": 25, "aether_coin": 2500, "soul_memory_2": 1}),
    (500, {"star_tear": 30, "aether_coin": 3000, "soul_memory_2": 1, "technique_box": 1}),
]
WEEKLY = [
    ("weekly_full_days", "Đủ 500 Hoạt Động trong 5 ngày", "Reach 500 Activity on 5 days", "daily_full", 5),
    ("weekly_boss_3", "Hạ boss 3 lần", "Defeat bosses 3 times", "boss_defeated", 3),
    ("weekly_win_30", "Thắng 30 trận", "Win 30 battles", "battle_won", 30),
]
WEEKLY_REWARD = {"star_tear": 160, "wish_ticket_limited": 1, "wish_ticket_standard": 1}
# (id, tên vi, tên en, trigger, param, mục tiêu, Lệ Tinh, track_max)
ACHIEVEMENTS = [
    ("ach_win_1", "Trận thắng đầu tiên", "First Victory", "battle_won", "", 1, 20, False),
    ("ach_win_50", "Chiến binh Pháo Đài: thắng 50 trận", "Fortress Warrior: win 50 battles", "battle_won", "", 50, 40, False),
    ("ach_win_200", "Bất bại: thắng 200 trận", "Unyielding: win 200 battles", "battle_won", "", 200, 60, False),
    ("ach_break_50", "Kẻ phá khiên: Phá Vỡ 50 lần", "Shieldbreaker: 50 Breaks", "weakness_broken", "", 50, 40, False),
    ("ach_break_300", "Búa tạ: Phá Vỡ 300 lần", "Sledgehammer: 300 Breaks", "weakness_broken", "", 300, 60, False),
    ("ach_elite_1", "Hạ quái tinh anh đầu tiên", "First elite defeated", "elite_or_boss", "", 1, 20, False),
    ("ach_boss_library", "Hạ Người Gác Thư Viện", "Defeat the Library Warden", "boss_defeated", "library_boss_warden", 1, 60, False),
    ("ach_boss_vault", "Hạ Cự Thú Kho Chứa", "Defeat the Vault Behemoth", "boss_defeated", "vault_boss_behemoth", 1, 60, False),
    ("ach_boss_furnace", "Hạ Lõi Lò Biến Dạng", "Defeat the Warped Core", "boss_defeated", "furnace_boss_core", 1, 60, False),
    ("ach_boss_tower", "Hạ Kẻ Nuốt Mảnh Hồn", "Defeat the Soul Devourer", "boss_defeated", "tower_boss_devourer", 1, 100, False),
    ("ach_hard_boss", "Thắng 1 boss mức Khó", "Defeat a boss on Hard", "hard_boss_defeated", "", 1, 60, False),
    ("ach_level_30", "Một nhân vật đạt cấp 30", "Raise a character to level 30", "max_level", "", 30, 60, False),
    ("ach_skill_5", "Một kỹ năng đạt cấp 5", "Raise a skill to level 5", "max_skill", "", 5, 60, False),
    ("ach_chests_30", "Thợ săn kho báu: mở 30 rương", "Treasure Hunter: open 30 chests", "chest_opened", "", 30, 40, False),
    ("ach_technique_50", "Bậc thầy Bí Kỹ: dùng 50 lần", "Technique Master: use 50 Techniques", "technique_used", "", 50, 60, False),
]
EXPLORATION_REWARD = 160  # Lệ Tinh mỗi khu khám phá 100%
# Quà đăng nhập 7 ngày đầu: tổng 10 Vé Thường (mục 11b).
LOGIN = [
    {"wish_ticket_standard": 2}, {"wish_ticket_standard": 1, "aether_coin": 5000}, {"wish_ticket_standard": 1, "soul_memory_2": 4},
    {"wish_ticket_standard": 1, "technique_box": 2}, {"wish_ticket_standard": 1, "aether_coin": 10000},
    {"wish_ticket_standard": 1, "soul_memory_3": 2}, {"wish_ticket_standard": 3},
]
CHAPTER_REWARD = {"star_tear": 400, "wish_ticket_standard": 5, "wish_ticket_limited": 3}
GACHA_OPEN_GIFT = {"wish_ticket_limited": 10}

# ---------------- Giả định "chơi hết bản đồ" (báo cáo kinh tế) ----------------
MODEL = {"story_days": 14, "days_before_daily_unlock": 2, "grind_battles_per_chapter": 8, "grind_enemies_per_battle": 3.0,
         "elite_repeat_days": 5, "boss_repeat_runs": 0, "boss_hard_runs": 2}
FREE_TEAM = ["traveler", "mira", "kiri", "garren", "nyx"]


def text(key, vi, en=None):
    TEXT[key] = (vi, en or vi)


def sn(x):
    return '&"%s"' % x


def gd_dict(d):
    return "{" + ", ".join('"%s": %d' % (k, v) for k, v in d.items()) + "}"


def entry_list(t, rows, prefix):
    script = res("systems/resources/loot_entry.gd")
    refs = []
    for i, (item, lo, hi, chance, scale) in enumerate(rows):
        props = []
        if item.startswith("pool:"):
            props.append(("pool", "Array[StringName]([%s])" % ", ".join(sn(x) for x in item[5:].split(","))))
        else:
            props.append(("item_id", sn(item)))
        props += [("min_count", lo), ("max_count", hi), ("chance", f(chance)), ("scales_with_difficulty", "true" if scale else "false")]
        refs.append(t.sub("%s_%d" % (prefix, i), script, props))
    return "Array[%s]([%s])" % (t.ext_id("Script", script), ", ".join(refs))


def loot_table(path, tid, rows, first=(), hard=(), claims=0):
    t = Tres("LootTable", res("systems/resources/loot_table.gd"))
    props = [("id", sn(tid)), ("entries", entry_list(t, rows, "Entry"))]
    if first:
        props.append(("first_clear", entry_list(t, first, "First")))
    if hard:
        props.append(("hard_extra", entry_list(t, hard, "Hard")))
    if claims:
        props.append(("full_claims_per_day", claims))
    t.write(path, props)


def build_enemy_tables():
    """Một bảng mỗi loại quái. Muốn quái/họ quái rơi khác thì thêm data/loot_tables/enemies/<id hoặc họ>.tres
    (Loot tìm theo id → họ → mặc định)."""
    d = "data/loot_tables/enemies/"
    for name in os.listdir(d) if os.path.isdir(d) else []:
        os.remove(d + name)
    loot_table(d + "default_normal.tres", "default_normal", NORMAL)
    loot_table(d + "default_elite.tres", "default_elite", ELITE, ELITE_FIRST)
    loot_table(d + "default_boss.tres", "default_boss", BOSS, BOSS_FIRST, BOSS_HARD_EXTRA, BOSS_FULL_CLAIMS_PER_DAY)


def build_zones():
    for zi, (zid, vi, en, chapter, rooms, encs, chests, boxes) in enumerate(ZONES):
        text("ZONE_%s" % zid.upper(), vi, en)
        table_paths = []
        for ti, tier in enumerate(CHEST_TIERS):
            c = CHEST_CONTENT[tier]
            mem_tier, mem_n = c["memory"][zi]
            rows = [("aether_coin", c["coin"][zi], c["coin"][zi], 1.0, False),
                    ("soul_memory_%d" % mem_tier, mem_n, mem_n, 1.0, False)]
            if c["crystals"]:
                rows.append(("crystal_team", c["crystals"], c["crystals"], 1.0, False))
            path = "data/loot_tables/chests/%s_%s.tres" % (zid, tier)
            loot_table(path, "%s_%s" % (zid, tier), rows, first=[("star_tear", CHEST_STAR_TEARS[ti], CHEST_STAR_TEARS[ti], 1.0, False)])
            table_paths.append(path)
        t = Tres("ZoneData", res("systems/resources/zone_data.gd"))
        enc_script = res("systems/resources/encounter_data.gd")
        table_script = res("systems/resources/loot_table.gd")
        for eid, _ in encs:
            assert os.path.exists("data/encounters/%s.tres" % eid), eid
        t.write("data/zones/%s.tres" % zid, [
            ("id", sn(zid)), ("name_key", '"ZONE_%s"' % zid.upper()), ("chapter", chapter), ("room_count", rooms),
            ("encounters", "Array[%s]([%s])" % (t.ext_id("Script", enc_script),
                                                ", ".join(t.ext_id("Resource", res("data/encounters/%s.tres" % e)) for e, _ in encs))),
            ("encounter_counts", "PackedInt32Array(%s)" % ", ".join(str(n) for _, n in encs)),
            ("chest_counts", "PackedInt32Array(%s)" % ", ".join(map(str, chests))),
            ("chest_tables", "Array[%s]([%s])" % (t.ext_id("Script", table_script),
                                                  ", ".join(t.ext_id("Resource", res(p)) for p in table_paths))),
            ("technique_boxes", boxes),
        ])


def build_model():
    t = Tres("EconomyModel", res("systems/resources/economy_model.gd"))
    zone_script = res("systems/resources/zone_data.gd")
    props = [("zones", "Array[%s]([%s])" % (t.ext_id("Script", zone_script),
                                            ", ".join(t.ext_id("Resource", res("data/zones/%s.tres" % z[0])) for z in ZONES)))]
    props += [(k, f(v) if isinstance(v, float) else v) for k, v in MODEL.items()]
    props.append(("free_team", "Array[StringName]([%s])" % ", ".join(sn(x) for x in FREE_TEAM)))
    t.write("data/config/economy_model.tres", props)


def build_quests():
    t = Tres("QuestConfig", res("systems/resources/quest_config.gd"))
    script = res("systems/resources/quest_data.gd")
    refs = []

    def quest(qid, qtype, vi, en, trigger, target, activity=0, rewards=None, param="", track_max=False):
        text("QUEST_%s" % qid.upper(), vi, en)
        props = [("id", sn(qid)), ("type", qtype), ("name_key", '"QUEST_%s"' % qid.upper()), ("trigger", sn(trigger)),
                 ("target", target)]
        if param:
            props.append(("param", sn(param)))
        if activity:
            props.append(("activity", activity))
        if rewards:
            props.append(("rewards", gd_dict(rewards)))
        if track_max:
            props.append(("track_max", "true"))
        refs.append(t.sub("Quest_%s" % qid, script, props))

    for qid, vi, en, trig, target, act in DAILY:
        quest(qid, 0, vi, en, trig, target, activity=act)
    for qid, vi, en, trig, target in WEEKLY:
        quest(qid, 1, vi, en, trig, target)
    for qid, vi, en, trig, param, target, lt, tmax in ACHIEVEMENTS:
        quest(qid, 2, vi, en, trig, target, rewards={"star_tear": lt}, param=param,
              track_max=tmax or trig in ("max_level", "max_skill"))
    for zid, vi, en, *_ in ZONES:
        quest("explore_%s" % zid, 2, "Khám phá 100%% %s" % vi, "Explore 100%% of the %s" % en, "zone_explored", 100,
              rewards={"star_tear": EXPLORATION_REWARD}, param=zid, track_max=True)
    for day, rewards in enumerate(LOGIN, 1):
        quest("login_day_%d" % day, 3, "Đăng nhập ngày %d" % day, "Login day %d" % day, "login_day", day, rewards=rewards)
    t.write("data/quests/quest_config.tres", [
        ("quests", "Array[%s]([%s])" % (t.ext_id("Script", script), ", ".join(refs))),
        ("daily_milestones", "PackedInt32Array(%s)" % ", ".join(str(p) for p, _ in MILESTONES)),
        ("daily_milestone_rewards", "Array[Dictionary]([%s])" % ", ".join(gd_dict(r) for _, r in MILESTONES)),
        ("weekly_reward", gd_dict(WEEKLY_REWARD)),
        ("unlock_flag", sn("chapter_1_complete")),
        ("reset_hour", 4),
        ("chapter_reward", gd_dict(CHAPTER_REWARD)),
        ("chapter_count", 4),
        ("gacha_open_gift", gd_dict(GACHA_OPEN_GIFT)),
    ])


def check():
    assert sum(a for *_, a in DAILY) == 500, "Tổng Hoạt Động phải 500"
    assert sum(r["star_tear"] for _, r in MILESTONES) == 100, "Mốc Hoạt Động phải tổng 100 Lệ Tinh"
    assert sum(a[6] for a in ACHIEVEMENTS) == 800, "Thành tựu phải tổng 800 Lệ Tinh"
    assert sum(r.get("wish_ticket_standard", 0) for r in LOGIN) == 10, "Quà 7 ngày phải tổng 10 Vé Thường"


def write_translations():
    with open("localization/economy.csv", "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["keys", "vi", "en"])
        for k, (vi, en) in TEXT.items():
            w.writerow([k, vi, en])


if __name__ == "__main__":
    check()
    build_enemy_tables()
    build_zones()
    build_model()
    build_quests()
    write_translations()
    print("Đã sinh bảng rơi đồ, %d khu, mô hình kinh tế, %d chữ dịch" % (len(ZONES), len(TEXT)))

#!/usr/bin/env python3
"""Sinh bảng thông số hình (mục 12, Phase 13) vào art_specs/<asset_id>.md + art_specs/README.md.

Nguồn:
- docs/CHARACTERS.md (tiểu sử, tính cách, ngoại hình, tên kỹ năng) cho nhân vật chính (2 skin) và 24 nhân vật;
- data/enemies/*.tres + localization/enemies.csv + mô tả dáng trong ENEMY_DESIGNS bên dưới cho quái / boss
  (mỗi họ quái 1 file, biến thể nguyên tố dùng chung hình, khác màu);
- data/config/art_requirements.json (hành động, số khung, kích thước) – cùng file mà game và tools/import_assets đọc;
- data/story/story.json (NPC chỉ cần chân dung).
Chạy: python3 tools/data_builder/build_art_specs.py   (ghi đè art_specs/)
"""
import csv
import json
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
os.chdir(ROOT)
OUT = "art_specs"

ELEMENTS = ["Lửa", "Nước", "Sét", "Phong", "Độc", "Mộc", "Hồn"]
ELEMENT_COLORS = ["#E8552B", "#3A8DDE", "#A65BF2", "#4FD1B5", "#9BC53D", "#2E8B57", "#F2D58A"]
KINDS = ["normal", "elite", "boss"]
KIND_NAMES = ["Thường", "Tinh anh", "Boss"]
DIRECTIONS = "e, se, s, sw, w, nw, n, ne"

ACTION_NOTES = {
    "map": {
        "idle": "đứng thở nhẹ, lặp",
        "run": "chạy, lặp; chân chạm đất ở khung 0 và giữa chu kỳ",
        "dash": "lướt nhanh, người đổ về trước, vạt áo bay",
        "opener": "Đòn Mở Màn – vung vũ khí theo hướng nhìn, khung 2–3 là lúc trúng",
        "technique": "Bí Kỹ – tư thế dùng kỹ năng ngoài map",
    },
    "battle": {
        "idle": "đứng thủ thế, lặp",
        "attack": "Đánh thường – khung trúng khoảng 50%",
        "skill": "Chiến kỹ",
        "ultimate": "Tuyệt kỹ – động tác lớn nhất, giữ dáng cuối 2 khung",
        "hit": "bị đánh, giật lùi",
        "down": "ngã, giữ khung cuối",
        "victory": "ăn mừng khi thắng, lặp",
    },
}

# Dáng quái theo họ (mô tả tay; bảng màu theo nguyên tố của từng biến thể).
ENEMY_DESIGNS = {
    "warp_sprout": ("Mầm cây Ma Biến tròn, thấp, hai lá mầm trên đầu, miệng nứt phát sáng; nổ khi chết.",
                    "Tròn trịa, cao bằng nửa nhân vật. Bóng đen: củ tròn + 2 lá dựng."),
    "wandering_shade": ("Hồn ma nửa trong suốt, áo choàng rách trôi lơ lửng, đôi tay dài tỏa khiên sáng cho đồng minh.",
                        "Đuôi áo vuốt nhọn thay chân. Bóng đen: hình giọt nước ngược, hai tay dài."),
    "rusted_knight": ("Bộ giáp rỗng gỉ sét, khiên tháp to, mũ có khe sáng; tư thế Thủ Thế chống khiên xuống đất.",
                      "Vuông, nặng. Bóng đen: khiên tháp cao bằng người."),
    "void_archer": ("Cung thủ hư không gầy, mặt trùm kín, cung dài tạo từ vết nứt; Ngắm: dây cung kéo căng phát sáng.",
                    "Cao gầy. Bóng đen: cung dài cong hơn người."),
    "warped_mage": ("Pháp sư méo mó, mũ chóp gãy gập, sách phép lơ lửng trước ngực.",
                    "Áo chùng loe. Bóng đen: mũ chóp gãy gập."),
    "ink_rat": ("Chuột ăn mực, lông bết mực, đuôi như ngòi bút; cắn trộm nhịp chiến đấu.",
                "Nhỏ, thấp, nhanh. Bóng đen: đuôi ngòi bút dựng cong."),
    "venom_bee": ("Ong độc to bằng mèo, cánh trong, đuôi kim nhỏ giọt. Ong thợ (drone) nhỏ hơn 30%.",
                  "Bay. Bóng đen: 4 cánh + thân đốt."),
    "mirror_shade": ("Bóng người làm từ mảnh gương ghép, phản chiếu lại kẻ đối diện; sao chép buff.",
                     "Mảnh gương lởm chởm. Bóng đen: người cắt mảnh vỡ."),
    "shattered_knight": ("Tinh anh: kỵ sĩ giáp vỡ nứt lộ băng xanh bên trong, thương dài; tích tụ rồi lao.",
                         "To hơn người 1,5 lần. Bóng đen: thương dài chĩa trước + vai giáp vỡ."),
    "warp_matrix": ("Tinh anh: khối mẫu thể Ma Biến như tổ kén, các Mầm bám quanh; triệu hồi Mầm.",
                    "Khối tròn có xúc tu. Bóng đen: tổ kén nhiều nhánh."),
    "mute_librarian": ("Tinh anh: thủ thư câm, miệng khâu chỉ, tay cầm đèn lồng sách; Phong Ấn Chiến kỹ.",
                       "Cao, áo dài phủ đất. Bóng đen: đèn lồng hình sách giơ cao."),
    "flying_book": ("Sách bay mở trang như cánh, triệu hồi của Người Gác Thư Viện.", "Nhỏ. Bóng đen: sách mở như chim."),
    "library_warden": ("Boss Chương 1: người gác thư viện khoác áo choàng giấy, hàng trăm sách xoay quanh như vệ tinh. "
                       "Giai đoạn 2 (Lời Nguyền Câm Lặng): áo giấy bung ra thành chữ đen bay, mắt phát sáng tím.",
                       "Rất cao, áo choàng xòe. Bóng đen: vòng sách quanh người."),
    "vault_behemoth": ("Boss Chương 2: thú khổng lồ bốn chân, lưng mọc thùng hàng đóng băng. Giai đoạn 2 (Băng Vỡ): "
                       "lớp băng nứt toác, lộ thân đỏ hằn, nhanh và hung dữ hơn.",
                       "Rộng, thấp, đầu cúi. Bóng đen: lưng chất thùng như núi."),
    "furnace_arm": ("Tay máy cắm vào tường lò, khớp nối tóe lửa; mục tiêu phụ của Lõi Lò.", "Cánh tay cơ khí cong."),
    "warped_core": ("Boss Chương 3: lõi lò khổng lồ quay chậm, vỏ kim loại nứt lộ lửa tím, hai tay máy. Giai đoạn 2 "
                    "(Lò Quá Tải): lửa chuyển trắng chói, vỏ bung các tấm tản nhiệt.",
                    "Hình cầu cơ khí có vành quay. Bóng đen: vành khuyên quanh lõi."),
    "devourer_clone": ("Phân thân của Kẻ Nuốt Mảnh Hồn: bóng người mờ một nguyên tố (Lửa / Nước / Sét).",
                       "Giống bản thể nhưng nhỏ hơn, viền rực màu nguyên tố."),
    "soul_devourer": ("Trùm cuối: bóng người từng là bạn của nhân vật chính, miệng là một vết nứt mở rộng, vòng Mảnh Hồn trôi quanh. "
                      "Giai đoạn 2 (Phân Thân): thân tách mảnh, vòng sáng chia 3 màu. Giai đoạn 3 (Nuốt Hồn): vết nứt nuốt "
                      "nửa thân, nền tối lại.",
                      "Cao, áo khoác dài rách, vết nứt dọc mặt. Bóng đen: vòng Mảnh Hồn sau lưng."),
}


def load_requirements():
    with open("data/config/art_requirements.json", encoding="utf-8") as fh:
        return json.load(fh)


def parse_characters():
    text = open("docs/CHARACTERS.md", encoding="utf-8").read()
    sections = re.split(r"\n(?=## )", text)
    result = {}
    for sec in sections:
        m = re.match(r"## (.+?) \((\S+), ([^,]+), (\d)★\)", sec)
        if not m:
            continue
        name, element, path, rarity = m.groups()

        def field(label):
            fm = re.search(r"- \*\*%s:\*\* (.+)" % label, sec)
            return fm.group(1).strip() if fm else ""

        def skill(label):
            sm = re.search(r"\| %s – ([^|]+?) \|" % label, sec)
            return sm.group(1).strip() if sm else ""

        result[name.split(" – ")[0].strip()] = {
            "name": name, "element": element, "path": path, "rarity": int(rarity),
            "bio": field("Tiểu sử"), "personality": field("Tính cách"), "look": field("Ngoại hình"),
            "opener": skill("Đòn Mở Màn"), "technique": skill("Bí Kỹ"), "basic": skill("Đánh thường"),
            "skill": skill("Chiến kỹ"), "ultimate": skill("Tuyệt kỹ"),
        }
    return result


def character_ids():
    ids = {}
    for f in sorted(os.listdir("data/characters")):
        if f.endswith(".tres"):
            t = open("data/characters/" + f, encoding="utf-8").read()
            key = re.search(r'name_key = "([^"]+)"', t)
            ids[f[:-5]] = key.group(1) if key else ""
    return ids


def translations(path):
    out = {}
    with open(path, encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            out[row["keys"]] = row["vi"]
    return out


def tres_field(text, name):
    m = re.search(r"^%s = (.+)$" % name, text, re.M)
    return m.group(1).strip() if m else ""


def enemy_families():
    tr = translations("localization/enemies.csv")
    fams = {}
    for f in sorted(os.listdir("data/enemies")):
        if not f.endswith(".tres") or f.startswith("training_dummy") or f.startswith("balance_"):
            continue
        full = open("data/enemies/" + f, encoding="utf-8").read()
        # Trường của quái nằm ở khối [resource]; phía trên là sub_resource (giai đoạn boss, kỹ năng...).
        t = full.split("\n[resource]\n")[-1]
        eid = tres_field(t, "id").strip('&"')
        family = tres_field(t, "family").strip('&"') or eid
        kind = int(tres_field(t, "kind") or 0)
        element = int(tres_field(t, "element") or 4)
        phases = len(set(re.findall(r'"(BOSS_PHASE_[A-Z_0-9]+)"', full)))
        name_key = tres_field(t, "name_key").strip('"')
        design_key = family if family in ENEMY_DESIGNS else ("devourer_clone" if family.startswith("devourer_clone") else family)
        fam = fams.setdefault(design_key, {"kind": kind, "variants": [], "phases": 1, "name": "", "desc": ""})
        fam.setdefault("id", design_key)
        fam["kind"] = max(fam["kind"], kind)
        fam["phases"] = max(fam["phases"], 1 + (phases or 0))
        name = tr.get(name_key, eid)
        fam["variants"].append((eid, name, element))
        # Tên họ quái: tên của quái trùng id họ (nếu có), không thì tên biến thể đầu (không phải ong thợ)
        # bỏ chữ nguyên tố của chính nó ở cuối ("Mầm Ma Biến Độc" → "Mầm Ma Biến").
        if name_key in tr:
            if eid == family:
                fam["name"] = name
                fam["exact"] = True
            elif not fam.get("exact") and not fam["name"] and "_drone" not in eid:
                el = ELEMENTS[element]
                fam["name"] = name[: -len(el) - 1] if name.endswith(" " + el) else name
        if not fam["desc"]:
            fam["desc"] = tr.get(name_key + "_DESC", "")
    return fams


def anim_table(spec, directions):
    lines = ["| Hành động | Số khung | Ghi chú |", "| --- | --- | --- |"]
    for action, count in spec["actions"].items():
        base = action.split("-p")[0]
        note = ACTION_NOTES.get("map" if directions else "battle", {}).get(base, "")
        lines.append("| `%s` | %d | %s |" % (action, count, note))
    return lines


def naming(asset_id, kind_dir, map_spec, battle_spec):
    return [
        "## Đặt tên file (mục 12)",
        "",
        "Thư mục: `assets/%s/%s/` – thả file vào rồi chạy `tools/import_assets` (hoặc mở editor) là game tự nhận." % (kind_dir, asset_id),
        "",
        "- Blender (khuyên dùng): `blender -b <file>.blend -P tools/blender/render_sprites.py -- --character %s%s --mode map` "
        "và `--mode battle` → tự sinh `map/map_%s.png/.json`, `battle/battle_%s.png/.json`."
        % (asset_id, " --kind enemies" if kind_dir == "enemies" else "", asset_id, asset_id),
        "- Hoặc từng khung (Krita): `map/map_%s_<hành động>_<hướng>_<khung>.png` (hướng: %s, khung 00, 01…), "
        "`battle/battle_%s_<hành động>_<khung>.png`." % (asset_id, DIRECTIONS, asset_id),
    ]


def write(path, lines):
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines).rstrip() + "\n")


def character_spec(asset_id, info, req, skin_note=""):
    c = req["character"]
    lines = ["# %s%s" % (info["name"], skin_note), "",
             "Sinh tự động bởi `tools/data_builder/build_art_specs.py` – sửa thiết kế trong `docs/CHARACTERS.md` / "
             "`tools/data_builder/roster_design.py` rồi chạy lại.", "",
             "| Mục | Nội dung |", "| --- | --- |",
             "| Id asset | `%s` |" % asset_id,
             "| Hạng · nguyên tố · vận mệnh | %d★ · %s · %s |" % (info["rarity"], info["element"], info["path"]),
             "| Màu nguyên tố (viền, hiệu ứng) | `%s` |" % ELEMENT_COLORS[ELEMENTS.index(info["element"])],
             "", "## Thiết kế", "",
             "- **Ngoại hình, mã màu, dáng bóng đen:** %s" % info["look"],
             "- **Tính cách (biểu cảm, tư thế):** %s" % info["personality"],
             "- **Tiểu sử:** %s" % info["bio"],
             "- **Vũ khí / đạo cụ & động tác kỹ năng:** Đòn Mở Màn *%s*; Bí Kỹ *%s*; Đánh thường *%s*; Chiến kỹ *%s*; "
             "Tuyệt kỹ *%s*." % (info["opener"], info["technique"], info["basic"], info["skill"], info["ultimate"]),
             "", "## Ngoài map (Blender) – %d×%d px/khung, 8 hướng (%s)" % (c["map"]["frame_size"], c["map"]["frame_size"], DIRECTIONS), ""]
    lines += anim_table(c["map"], True)
    lines += ["", "## Trong trận (Blender + Krita sửa nét) – %d×%d px/khung, nghiêng 3/4 quay sang phải"
              % (c["battle"]["frame_size"], c["battle"]["frame_size"]), ""]
    lines += anim_table(c["battle"], False)
    lines += ["", "## Krita", "",
              "| Hình | Kích thước | File |", "| --- | --- | --- |"]
    for exp in c["portrait"]["expressions"]:
        lines.append("| Chân dung %s | %d×%d | `portrait/portrait_%s_%s.png` |" % (exp, c["portrait"]["size"], c["portrait"]["size"], asset_id, exp))
    lines.append("| Tranh gacha + cắt cảnh Tuyệt kỹ | %d×%d | `splash/splash_%s.png` |" % (c["splash"]["size"][0], c["splash"]["size"][1], asset_id))
    for skill, count in c["vfx"]["skills"].items():
        lines.append("| Hiệu ứng %s (%d khung) | %d×%d/khung | `vfx/vfx_%s_%s_<khung>.png` |" % (
            skill, count, c["vfx"]["frame_size"], c["vfx"]["frame_size"], asset_id, skill))
    lines += [""] + naming(asset_id, "characters", c["map"], c["battle"])
    write(os.path.join(OUT, asset_id + ".md"), lines)


def enemy_spec(family, data, req):
    e = req["enemy"]
    kind = data["kind"]
    size = e["battle"]["frame_size"][KINDS[kind]]
    map_spec = dict(e["map"])
    if isinstance(map_spec["frame_size"], dict):
        map_spec["frame_size"] = map_spec["frame_size"][KINDS[kind]]
    design, silhouette = ENEMY_DESIGNS.get(family, ("", ""))
    lines = ["# %s (%s)" % (data["name"], KIND_NAMES[kind]), "",
             "Sinh tự động bởi `tools/data_builder/build_art_specs.py`.", "",
             "- **Mô tả:** %s" % (design or data["desc"]),
             "- **Dáng / bóng đen:** %s" % silhouette,
             "- **Trong game:** %s" % data["desc"], "",
             "## Biến thể (dùng chung hình, đổi màu theo nguyên tố – vẽ màu trung tính hoặc làm 1 bản mỗi biến thể)", "",
             "| Id | Tên | Nguyên tố | Màu |", "| --- | --- | --- | --- |"]
    for eid, name, element in data["variants"]:
        lines.append("| `%s` | %s | %s | `%s` |" % (eid, name, ELEMENTS[element], ELEMENT_COLORS[element]))
    direction_text = "hướng e, lật ngang khi đi trái" if e.get("directions") == ["e"] else "8 hướng"
    lines += ["", "## Ngoài map – %d×%d px/khung, %s" % (map_spec["frame_size"], map_spec["frame_size"], direction_text), ""]
    lines += anim_table(map_spec, True)
    battle = dict(e["battle"])
    actions = dict(battle["actions"])
    if data["phases"] > 1:
        for p in range(2, data["phases"] + 1):
            for a, n in e["battle"]["actions"].items():
                actions["%s-p%d" % (a, p)] = n
    battle["actions"] = actions
    lines += ["", "## Trong trận – %d×%d px/khung, nghiêng 3/4 quay sang trái%s" % (
        size, size, " · %d giai đoạn: hành động giai đoạn n ≥ 2 thêm hậu tố `-p<n>`" % data["phases"] if data["phases"] > 1 else ""), ""]
    lines += anim_table(battle, False)
    lines += [""] + naming(family, "enemies", map_spec, battle)
    lines.append("- Muốn biến thể có hình riêng: đặt thư mục theo id biến thể (`assets/enemies/<id>/`), game ưu tiên id trước họ quái.")
    write(os.path.join(OUT, family + ".md"), lines)


def main():
    os.makedirs(OUT, exist_ok=True)
    req = load_requirements()
    chars = parse_characters()
    ids = character_ids()
    roster_md = translations("localization/roster.csv") if os.path.exists("localization/roster.csv") else {}
    index = ["# Bảng thông số hình", "", "Sinh tự động bởi `tools/data_builder/build_art_specs.py`. Quy trình: "
             "`docs/KRITA_PIPELINE.md`, `tools/blender/README.md`. Tình trạng: `docs/ASSET_STATUS.md`.", "",
             "## Nhân vật", ""]
    for cid in ids:
        info = None
        for name, data in chars.items():
            if cid == "traveler" and name.startswith("Lữ khách"):
                info = data
            elif name.lower() == cid:
                info = data
        if info is None:
            print("Thiếu mục trong CHARACTERS.md cho", cid)
            continue
        if cid == "traveler":
            for skin, note in (("male", " – skin Nam (Kael)"), ("female", " – skin Nữ (Kaela)")):
                character_spec("traveler_" + skin, info, req, note)
                index.append("- [%s%s](traveler_%s.md)" % (info["name"], note, skin))
        else:
            character_spec(cid, info, req)
            index.append("- [%s](%s.md) – %d★ %s" % (info["name"], cid, info["rarity"], info["element"]))
    index += ["", "## Quái và boss", ""]
    fams = enemy_families()
    for family in sorted(fams, key=lambda f: (fams[f]["kind"], f)):
        fams[family]["name"] = fams[family]["name"] or family
        enemy_spec(family, fams[family], req)
        index.append("- [%s](%s.md) – %s" % (fams[family]["name"], family, KIND_NAMES[fams[family]["kind"]]))
    story = json.load(open("data/story/story.json", encoding="utf-8"))
    index += ["", "## NPC (chỉ chân dung %s, 1024×1024)" % ", ".join(req["character"]["portrait"]["expressions"]), ""]
    for sid, sp in story["speakers"].items():
        if sid != "narrator" and "character" not in sp:
            index.append("- `%s` → `assets/characters/%s/portrait/portrait_%s_<biểu cảm>.png`" % (sid, sid, sid))
    index += ["", "## Tileset (Krita, ô 64×64)", "",
              "Mỗi khu 1 ảnh `assets/tilesets/<khu>/tiles_<khu>.png` 320×64: 5 ô hàng ngang theo thứ tự "
              "sàn A, sàn B, tường, sàn hành lang, tường hành lang (tường có va chạm). Khu: %s." % ", ".join(req["tileset"]["zones"])]
    write(os.path.join(OUT, "README.md"), index)
    print("Xong: %d file trong %s/" % (len(os.listdir(OUT)), OUT))


if __name__ == "__main__":
    main()

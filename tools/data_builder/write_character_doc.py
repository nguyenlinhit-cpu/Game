#!/usr/bin/env python3
"""Ghi phần thiết kế 20 nhân vật (Phase 7) + bảng tổng hợp vào docs/CHARACTERS.md từ roster_design.py.
Chạy: python3 tools/data_builder/write_character_doc.py (ghi đè phần từ dấu PHASE7_MARKER trở xuống)."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from roster_design import ROSTER

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DOC = os.path.join(ROOT, "docs", "CHARACTERS.md")
MARKER = "<!-- PHASE7_MARKER -->"
EL = {"fire": "Lửa", "water": "Nước", "lightning": "Sét", "wind": "Phong", "poison": "Độc", "wood": "Mộc", "soul": "Hồn"}
PATH = {"destruction": "Hủy Diệt", "hunt": "Săn Bắn", "erudition": "Tri Thức", "harmony": "Hòa Hợp",
        "nihility": "Hư Vô", "preservation": "Bảo Hộ", "abundance": "Trù Phú"}
KIND = {"NEXT_BATTLE": "Lợi thế trận kế tiếp", "MAP_ENEMIES": "Tác động quái trên map", "EXPLORATION": "Tiện ích khám phá"}
# Theo mục 8 (để kiểm tra khớp bảng).
SPEC = {"ignar": ("fire", "destruction", 5), "marisol": ("water", "preservation", 5), "raiko": ("lightning", "hunt", 5),
        "zephyra": ("wind", "harmony", 5), "vesper": ("poison", "nihility", 5), "sylvaine": ("wood", "abundance", 5),
        "orrin": ("soul", "erudition", 5), "celestine": ("soul", "hunt", 5), "quill": ("poison", "abundance", 4),
        "aldric": ("wind", "preservation", 4), "rook": ("wood", "destruction", 4), "fenna": ("wood", "hunt", 4),
        "kestrel": ("wind", "destruction", 4), "vael": ("poison", "erudition", 4), "wisp": ("wind", "nihility", 4),
        "selka": ("poison", "harmony", 4), "ember": ("fire", "erudition", 4), "neris": ("water", "hunt", 4),
        "pip": ("lightning", "harmony", 4), "echo": ("soul", "nihility", 4)}
# 5 nhân vật Phase 6 (cho bảng tổng hợp cuối).
PHASE6 = [
    ("Lữ khách (Kael/Kaela)", "5★", "soul", "destruction", "tích tầng khi Phá Vỡ", "Phá Vỡ khiên quái → Tấn Công +20%, tối đa 2 tầng.", "EXPLORATION", "Nhân vật chính"),
    ("Mira", "4★", "water", "abundance", "hồi khẩn cấp", "Đồng minh vừa rơi dưới 30% máu → hồi ngay 15% máu tối đa.", "NEXT_BATTLE", "Miễn phí (Mở đầu) + 2 banner"),
    ("Kiri", "4★", "fire", "harmony", "hoàn Điểm Chiến Kỹ", "Đồng minh đang Thổi Bùng dùng Chiến kỹ 3 lần → đội +1 Điểm Chiến Kỹ.", "MAP_ENEMIES", "Miễn phí (Chương 1) + 2 banner"),
    ("Garren", "4★", "wood", "preservation", "phản công", "Bị quái đánh trúng → phản công 50% Phòng Thủ.", "NEXT_BATTLE", "Miễn phí (Chương 2) + 2 banner"),
    ("Nyx", "4★", "lightning", "nihility", "kích nổ sát thương theo lượt", "Đánh thường kích nổ ngay sát thương theo lượt trên quái (50%).", "EXPLORATION", "Miễn phí (Chương 3) + 2 banner"),
]


def lv30(a, b):
    return round(a + (b - a) * 29 / 79)


def section(c):
    (h1, a1, d1, s), (h80, a80, d80) = c["stats"]
    ex = c.get("extras", {})
    extra_bits = []
    if "crit_rate" in ex: extra_bits.append("Bạo kích %d%%" % round(ex["crit_rate"] * 100))
    if "crit_dmg" in ex: extra_bits.append("Sát thương bạo kích %d%%" % round(ex["crit_dmg"] * 100))
    if "effect_hit" in ex: extra_bits.append("Chính Xác Hiệu Ứng %d%%" % round(ex["effect_hit"] * 100))
    if "outgoing_healing" in ex: extra_bits.append("Tăng Trị Liệu %d%%" % round(ex["outgoing_healing"] * 100))
    if "energy_regen" in ex: extra_bits.append("Hồi năng lượng %d%%" % round(ex["energy_regen"] * 100))
    star = "★" * 0
    src = "Banner giới hạn" if c["id"] == "celestine" else ("Banner thường" if c["rarity"] == 5 else "Cả 2 banner")
    o = c["opener"]; t = c["technique"]; u = c["ultimate"]; tal = c["talent"]
    lines = [
        "## %s (%s, %s, %d★) – %s" % (c["name"], EL[c["element"]], PATH[c["path"]], c["rarity"], src), "",
        "- **Vai trò:** %s" % c["role"],
        "- **Tiểu sử:** %s" % c["bio"],
        "- **Tính cách:** %s" % c["personality"],
        "- **Ngoại hình:** %s" % c["look"],
        "- **Chỉ số:** năng lượng tối đa %d%s." % (c["energy"], (", " + ", ".join(extra_bits)) if extra_bits else ""), "",
        "| | Máu | Tấn Công | Phòng Thủ | Tốc Độ |", "| --- | --- | --- | --- | --- |",
        "| Cấp 1 | %d | %d | %d | %d |" % (h1, a1, d1, s),
        "| Cấp 30 | %d | %d | %d | %d |" % (lv30(h1, h80), lv30(a1, a80), lv30(d1, d80), s), "",
        "| Kỹ năng | Nội dung |", "| --- | --- |",
        "| Đòn Mở Màn – %s | %s |" % (o[0], o[1]),
        "| Bí Kỹ – %s (%s) | %s |" % (t[0], KIND[t[1]].lower(), t[2]),
        "| Đánh thường – %s | %s |" % c["basic"],
        "| Chiến kỹ – %s | %s |" % c["skill"],
        "| Tuyệt kỹ – %s (%d) | %s |" % (u[0], u[1], u[2]),
        "| Đặc tính – %s | %s |" % (tal[0], tal[2]), "",
        "| Tinh Mệnh | Nội dung |", "| --- | --- |",
    ]
    for i, (name, desc) in enumerate(c["eidolons"]):
        lines.append("| %d – %s | %s |" % (i + 1, name, desc))
    return "\n".join(lines) + "\n"


def main():
    errors = []
    mechanics = [p[4] for p in PHASE6] + [c["talent"][1] for c in ROSTER]
    dups = {m for m in mechanics if mechanics.count(m) > 1}
    if dups: errors.append("Trùng cơ chế Đặc tính: %s" % dups)
    for c in ROSTER:
        spec = SPEC[c["id"]]
        if (c["element"], c["path"], c["rarity"]) != spec:
            errors.append("%s lệch bảng mục 8" % c["id"])
        if len(c["eidolons"]) != 6: errors.append("%s thiếu Tinh Mệnh" % c["id"])
    roster24 = [p for p in PHASE6[1:]] + ROSTER
    counts = {}
    for p in PHASE6[1:]:
        counts[p[6]] = counts.get(p[6], 0) + 1
    for c in ROSTER:
        counts[c["technique"][1]] = counts.get(c["technique"][1], 0) + 1
    if sorted(counts.values()) != [8, 8, 8]: errors.append("Bí Kỹ không chia đều: %s" % counts)
    if errors:
        print("\n".join(errors)); sys.exit(1)

    with open(DOC) as f:
        text = f.read()
    if MARKER in text:
        text = text[:text.index(MARKER)]
    out = [text.rstrip() + "\n", MARKER, "",
           "# Phase 7 – 20 nhân vật còn lại (bước A: thiết kế, chờ duyệt)", "",
           "Nguồn: `tools/data_builder/roster_design.py` (bước B sinh dữ liệu từ chính file này).",
           "Quy ước chung như phần trên. Tinh Mệnh 3 = Đánh thường + Chiến kỹ +15% hệ số; Tinh Mệnh 5 = Tuyệt kỹ +15% hệ số.",
           "5★ đặt chỉ số và hệ số cao hơn 4★ cùng vai trò khoảng 15–25% (bước B mô phỏng 10 lượt để kiểm chứng).", ""]
    out.append("## 5★\n")
    for c in ROSTER:
        if c["rarity"] == 5:
            out.append(section(c))
    out.append("## 4★\n")
    for c in ROSTER:
        if c["rarity"] == 4:
            out.append(section(c))
    # Bảng tổng hợp cuối file.
    out += ["---", "", "## Bảng tổng hợp 25 nhân vật", "",
            "| # | Nhân vật | Hạng | Nguyên tố | Vận mệnh | Cơ chế Đặc tính | Đặc tính (1 câu) | Kiểu Bí Kỹ | Nguồn |",
            "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
    n = 0
    for name, rar, el, path, mech, one, kind, src in PHASE6:
        n += 1
        out.append("| %d | %s | %s | %s | %s | %s | %s | %s | %s |" % (n, name, rar, EL[el], PATH[path], mech, one, KIND[kind], src))
    for c in ROSTER:
        n += 1
        one = c["talent"][2]
        src = "Banner giới hạn" if c["id"] == "celestine" else ("Banner thường" if c["rarity"] == 5 else "Cả 2 banner")
        out.append("| %d | %s | %d★ | %s | %s | %s | %s | %s | %s |" % (n, c["name"], c["rarity"], EL[c["element"]],
                   PATH[c["path"]], c["talent"][1], one, KIND[c["technique"][1]], src))
    out += ["", "**Kiểm tra tự động (khi sinh file):**", "",
            "- 25 cơ chế Đặc tính khác nhau (cột \"Cơ chế Đặc tính\" không có dòng trùng).",
            "- Bí Kỹ của 24 nhân vật trong banner/miễn phí chia đều: Lợi thế trận kế tiếp %d, Tác động quái trên map %d, Tiện ích khám phá %d "
            "(nhân vật chính thêm 1 Tiện ích khám phá)." % (counts["NEXT_BATTLE"], counts["MAP_ENEMIES"], counts["EXPLORATION"]),
            "- Nguyên tố / vận mệnh / hạng khớp bảng mục 8."]
    by_el = {}
    by_path = {}
    for p in PHASE6[1:]:
        by_el[p[2]] = by_el.get(p[2], 0) + 1; by_path[p[3]] = by_path.get(p[3], 0) + 1
    for c in ROSTER:
        by_el[c["element"]] = by_el.get(c["element"], 0) + 1; by_path[c["path"]] = by_path.get(c["path"], 0) + 1
    out.append("- Mỗi nguyên tố (24 người): " + ", ".join("%s %d" % (EL[k], v) for k, v in by_el.items()) + ".")
    out.append("- Mỗi vận mệnh (24 người): " + ", ".join("%s %d" % (PATH[k], v) for k, v in by_path.items()) + ".")
    out.append("")
    out.append("**Vật cản nguyên tố có người mở sau Phase 7:** Phong (Zephyra, Aldric, Kestrel, Wisp) mở sương mù; "
               "Độc (Vesper, Quill, Vael, Selka) mở cổng gỉ – chỉ dùng cho rương ẩn, không chặn đường chính.")
    with open(DOC, "w") as f:
        f.write("\n".join(out) + "\n")
    print("Đã ghi docs/CHARACTERS.md:", counts, "nguyên tố", by_el, "vận mệnh", by_path)


main()

# Nhân vật design đã đưa vào game — 15/10/2026

Đồng bộ 26 bộ hình (25 nhân vật, Lữ khách có hai skin) từ `design/nhan_vat` theo yêu cầu đưa tài nguyên hiện có vào game. Giữ nguyên quyết định trong `design/REVIEW.md`; việc nhập tài nguyên không có nghĩa bản vẽ đã được duyệt hoàn thiện.

Thêm 11 bộ còn thiếu: Fenna, Kestrel, Neris, Pip, Ember, Selka, Vael, Wisp, Echo, traveler_male (Kael), traveler_female (Kaela). Đồng bộ lại 15 bộ đã có.

- Sprite map 32×32: idle, run, dash, opener, technique; hướng e, game lật ngang khi đi trái.
- Sprite trận 512×512: idle, attack, skill, ultimate, hit, down, victory; Celestine có thêm hoạt ảnh riêng.
- VFX: hit dùng tên hành động; cast dùng `<hành động>-cast`, tương thích SkillVfx và UnitView. Đồng thời nhập các khung screen, cutin, opener và technique để có sẵn trong SpriteFrames; luồng game hiện tại chỉ tự phát hit và cast trong trận.
- Chưa bổ sung chân dung hội thoại hoặc splash gacha: concept/sketch không được coi là tài nguyên thay thế hoàn thiện cho các mục này.

Các bản render đủ cấu trúc để game sử dụng nhưng vẫn là bản nháp: chưa đủ tám hướng map, một số hành động map ít khung hơn bảng yêu cầu, và các giới hạn biểu cảm/chuyển động trong tài liệu design vẫn còn. Xem `docs/ASSET_STATUS.md` để biết tài nguyên còn thiếu của toàn dự án.

Chạy lại từ gốc dự án:

```bash
python3 tools/import_assets/sync_design_characters.py
godot --headless --path . --import
godot --headless --path . res://tools/import_assets/import_assets.tscn
godot --headless --path . res://tests/phase13_test.tscn
```

Công cụ đồng bộ kiểm tra PNG RGBA8, vùng cắt từng khung, các hành động chính và số khung/kích thước VFX trước khi chép. Chạy lại chỉ cập nhật file thay đổi.

Kiểm tra Godot Phase 13: **63/63 đạt**, gồm tải tất cả 26 skin, chuyển động map, chiến đấu và phát/tự hủy VFX Fenna. Không có lỗi engine/script trong lúc kiểm thử. Khi thoát, Godot vẫn báo ObjectDB còn giữ đối tượng và 48 tài nguyên chưa được giải phóng; chưa xử lý phần dọn tài nguyên khi tắt game trong đợt nhập hình này.

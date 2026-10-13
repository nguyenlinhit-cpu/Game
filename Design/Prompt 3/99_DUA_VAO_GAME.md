# 99 – Đưa thiết kế đã duyệt vào game

Chỉ dùng prompt này khi mọi dòng của id đó trong `design/REVIEW.md` đều là `duyệt`. Thay `<ID>` bằng id (ví dụ `mira`, hoặc nhiều id cách nhau bởi dấu phẩy).

```text
Đưa thiết kế đã duyệt của <ID> từ design/ vào game Aethelgard (Godot 4).

0. Kiểm tra trước:
   - Đọc design/REVIEW.md. Chỉ làm với id có mọi dòng (B2 phác thảo, B4 sprite trận và sprite map, từng skill/chiêu) ở trạng thái "duyệt".
   - Id nào còn dòng "chờ duyệt", "sửa" hoặc thiếu dòng thì bỏ qua và báo tôi. Không tự đổi trạng thái.

1. Chỉnh code một lần (lần đầu chạy prompt này; các lần sau bỏ qua phần đã có):
   a. Ngoài map:
      - sprite pixel 32 px (boss 48) chỉ hướng "e", lật ngang khi đi sang trái, đi lên/xuống giữ hướng ngang cuối;
      - cảnh map lọc NEAREST, phóng nguyên ×4;
      - cảnh trận giữ lọc mượt;
      - cập nhật data/config/art_requirements.json và systems/art_library.gd.
   b. Trong trận:
      - đọc hit_frame từ JSON; số sát thương, nháy trúng và hiệu ứng hit xuất hiện đúng khung trúng;
      - SkillVfx phát 3 lớp: cast (tại người dùng), hit (tại mục tiêu), screen (cả màn hình).
   c. Hiệu ứng quái theo từng chiêu: assets/enemies/<họ>/vfx/vfx_<họ>_<chiêu>_<lớp>_<khung>.png.
   d. Hiệu ứng pixel ngoài map: vfx/mapvfx_<id>_<opener|technique>_<khung>.png.
   e. Hoạt ảnh thêm, nối vào đúng lúc dùng:
      - quái: guard, aim, charge, summon, curse, telegraph, swallow, phase2, phase3; hậu tố -p2/-p3 cho boss;
      - Celestine: idle-judge, attack-judge khi ở tư thế Phán Xử;
      - vật triệu hồi: Cây Sự Sống (Sylvaine), bẫy dây (Fenna).
   f. Thiếu file thì giữ hình tạm như hiện nay. Viết test cho từng mục.

2. Chép file đã duyệt (chỉ đúng bản ghi trong REVIEW.md, ví dụ v2 nếu v2 được duyệt):
   - design/nhan_vat/<id>/5_render/battle_<id>.* → assets/characters/<id>/battle/
   - design/nhan_vat/<id>/5_render/map_<id>.* → assets/characters/<id>/map/
   - design/nhan_vat/<id>/6_vfx/<skill>/<lớp>/<khung>.png → assets/characters/<id>/vfx/vfx_<id>_<skill>_<lớp>_<khung>.png
   - design/nhan_vat/<id>/6_vfx/<opener|technique>/ → assets/characters/<id>/vfx/mapvfx_<id>_<skill>_<khung>.png
   - design/nhan_vat/<id>/1_concept/1e_splash.png (đã duyệt) → assets/characters/<id>/splash/splash_<id>.png (2048×1152)
   - Quái: design/quai/<họ>/5_render/<id biến thể>/ → assets/enemies/<id biến thể>/{battle,map}/; hiệu ứng như trên.
   - Nhân vật chính: traveler_male và traveler_female là 2 thư mục riêng, dùng chung hiệu ứng skill.

3. Chạy tools/import_assets. Xem docs/ASSET_STATUS.md: id vừa đưa vào phải hết "còn thiếu" (trừ chân dung nếu chưa làm).

4. Chạy toàn bộ test (Phase 1–14 + test mới), phòng thử trận với id đó, chụp GIF trong game vào design/<nhan_vat|quai>/<id>/7_ingame/.

5. Thêm dòng "B6 trong game" vào design/REVIEW.md (chờ duyệt), cập nhật docs/PROGRESS.md mục Đồ họa. Tạo 1 commit riêng "art: đưa <ID> vào game".

Không xóa gì trong design/. Không sửa file của id chưa được duyệt.
```

# PHASE 13/14 – Đồ họa 2D với Blender và Krita

Bạn đang xây game 2D "Aethelgard: Mảnh Hồn" bằng Godot 4. Đặc tả đầy đủ ở `docs/GAME_SPEC.md`. Trước khi làm, đọc `docs/PROGRESS.md`, `docs/CHARACTERS.md` và mục 12. Phase này làm song song được từ sau Phase 6. Chỉ làm phần việc dưới đây.

Bạn không vẽ thay tôi. Việc của bạn là chuẩn bị mọi thứ để tôi vẽ/dựng trong Krita và Blender rồi thả file vào là game tự nhận.

## Việc cần làm

1. `art_specs/<id>.md` cho nhân vật chính (2 skin), 24 nhân vật, toàn bộ quái và boss: mã màu, dáng, trang phục, vũ khí, danh sách animation và số khung, kích thước theo bảng mục 12.
2. `tools/blender/render_sprites.py`:
    - Camera trực giao, ánh sáng cố định, shader hoạt hình (Shader to RGB + Color Ramp), viền (Freestyle hoặc Solidify lật pháp tuyến).
    - Render từng Action ra PNG nền trong suốt: 8 hướng cho map, 1 góc nghiêng 3/4 cho trận.
    - Ghép thành sprite sheet kèm file JSON mô tả khung.
    - Chạy: `blender -b file.blend -P render_sprites.py -- --character ignar --mode map` (hoặc `--mode battle`).
    - Kèm script tạo file .blend mẫu (hình khối đơn giản có rig và 2 Action) để thử. Nếu máy có Blender thì chạy thử; nếu không, viết hướng dẫn từng bước để tôi chạy.
3. `docs/KRITA_PIPELINE.md`: kích thước canvas, cách đặt lớp, chân dung 3 biểu cảm, tranh gacha 2048×1152, hiệu ứng kỹ năng bằng Animation Docker, xuất chuỗi PNG, quy tắc đặt tên.
4. `tools/import_assets`: EditorScript hoặc plugin quét `assets/`, đọc tên file theo quy tắc mục 12, tự tạo SpriteFrames và gắn vào nhân vật/quái. File nào thiếu thì giữ hình tạm và in danh sách còn thiếu.
5. Shader 2D dùng chung: viền khi chọn mục tiêu, nháy trắng khi bị đánh, tan biến khi ngã, đổi màu nền khi dùng tuyệt kỹ.
6. Hiệu ứng kỹ năng tạm bằng GPUParticles2D theo màu nguyên tố, dễ thay bằng sprite Krita sau.

## Tiêu chí hoàn thành

- [ ] Render mô hình mẫu ra sprite sheet, chép vào `assets/`, Godot tự nhận; nhân vật hiện đúng hoạt ảnh ngoài map và trong trận.
- [ ] Danh sách asset còn thiếu được in ra đầy đủ.

## Khi xong

Cập nhật `docs/PROGRESS.md`. Báo cáo: danh sách file tạo/sửa, hướng dẫn tôi dùng Blender/Krita theo từng bước, việc còn nợ. Dừng lại chờ tôi duyệt.

# Render sprite bằng Blender (Phase 13)

Thư mục này có `.gdignore` để Godot không import file `.blend`.

## Thử ngay với mô hình mẫu

```bash
# 1. Tạo file mẫu (nhân vật khối đơn giản, rig 7 xương, Action idle / run / attack)
blender -b -P tools/blender/make_sample_blend.py -- --out tools/blender/sample_character.blend

# 2. Render ra sprite sheet (mẫu đang gắn cho Mira để thấy ngay trong game)
blender -b tools/blender/sample_character.blend -P tools/blender/render_sprites.py -- --character mira --mode map
blender -b tools/blender/sample_character.blend -P tools/blender/render_sprites.py -- --character mira --mode battle

# 3. Cho Godot nhận
godot --headless --path . --import
godot --headless --path . res://tools/import_assets/import_assets.tscn
```

Muốn bỏ hình mẫu của Mira: xóa thư mục `assets/characters/mira/map` và `.../battle` rồi chạy lại bước 3.

## Dựng nhân vật thật – từng bước

1. Mở `art_specs/<id>.md` (bảng màu, dáng, danh sách hành động + số khung).
2. Dựng mesh, mặt trước nhìn về **trục −Y**, chân đứng ở gốc toạ độ, cao khoảng 2 đơn vị.
3. Vật liệu: Principled BSDF, chỉ cần đặt *Base Color* (script tự đổi sang shader hoạt hình:
   Diffuse → Shader to RGB → Color Ramp 3 bậc × màu gốc → Emission).
4. Rig một Armature, gắn mesh bằng Automatic Weights (Ctrl+P → With Automatic Weights).
5. Mỗi hành động là một **Action đặt đúng tên**: map `idle, run, dash, opener, technique`;
   trận `idle, attack, skill, ultimate, hit, down, victory`; boss giai đoạn 2 thêm `idle-p2`… (trong Action Editor bấm New,
   đổi tên, bật Fake User). Đặt *Manual Frame Range* nếu Action cần khoảng khung riêng.
   Hoạt ảnh lặp (idle, run, victory): khung cuối giống khung đầu – script tự bỏ khung cuối.
6. Lưu file `.blend` (ngoài `assets/`, vd. `art_source/blender/ignar.blend`).
7. Render:
   ```bash
   blender -b art_source/blender/ignar.blend -P tools/blender/render_sprites.py -- --character ignar --mode map
   blender -b art_source/blender/ignar.blend -P tools/blender/render_sprites.py -- --character ignar --mode battle
   # Quái / boss:
   blender -b boss.blend -P tools/blender/render_sprites.py -- --character library_warden --kind enemies --enemy-kind boss --mode battle
   ```
8. Chạy bước 3 ở trên. Sửa nét tay trong Krita nếu cần (`docs/KRITA_PIPELINE.md` mục 6).

## Script làm gì

- Camera trực giao, mặt trời + đèn viền cố định, EEVEE, nền trong suốt.
- Viền đen: Solidify lật pháp tuyến + vật liệu viền chỉ hiện mặt sau (tắt bằng `--no-outline`; tắt shader hoạt hình bằng `--no-toon`).
- `--mode map`: nhìn chéo 35° từ trên xuống, xoay nhân vật đủ 8 hướng `e se s sw w nw n ne`, khung 128 px.
- `--mode battle`: góc 3/4 (nhân vật quay phải, quái quay trái), khung 512 px (quái 256 / 384 / 768 theo `--enemy-kind`).
- Mỗi Action lấy đều số khung yêu cầu trong `data/config/art_requirements.json` (đổi bằng `--frames N`,
  chọn Action bằng `--actions idle,run`).
- Ghép `<mode>_<id>.png` (hàng = hành động × hướng, cột = khung) + `<mode>_<id>.json`
  (kích thước khung, điểm neo chân, fps, vị trí từng khung) vào `assets/<characters|enemies>/<id>/<mode>/`
  (đổi bằng `--out`).
- In các Action còn thiếu (game tạm dùng `idle` thay).

Đã thử với Blender 5.2 (EEVEE, chạy nền `-b`): 96 khung map 128 px ≈ 15 giây.

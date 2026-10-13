# Quy trình Krita (Phase 13)

Hướng dẫn vẽ chân dung, tranh gacha, hiệu ứng kỹ năng, sửa nét sprite trận và tileset bằng Krita để game tự nhận.
Thông số từng nhân vật / quái: `art_specs/<id>.md`. Danh sách còn thiếu: `docs/ASSET_STATUS.md`.
Sprite 3D render bằng Blender: `tools/blender/README.md`.

## 1. Quy tắc chung

- **Đặt tên** (mục 12): `<loại>_<id>_<hành động>_<hướng>_<khung>.png`, chữ thường, không dấu, khung đánh số 2 chữ số
  từ `00`. Ví dụ `map_ignar_run_se_03.png`, `battle_ignar_attack_05.png` (trận không có hướng), `vfx_ignar_ultimate_11.png`.
- **Thư mục**: `assets/characters/<id>/{map,battle,portrait,splash,vfx}/`, quái `assets/enemies/<họ quái>/{map,battle}/`.
  Nhân vật chính có 2 thư mục `traveler_male/` và `traveler_female/`. NPC chỉ nói chuyện: `assets/characters/<orwen|lio|bram|devourer>/portrait/`.
- **Định dạng**: PNG RGBA 8 bit, nền trong suốt, hệ màu sRGB. Không để viền trắng / pixel nửa trong suốt rác quanh hình.
- **Điểm neo**: sprite trận và map đặt chân nhân vật ở giữa chiều ngang, cách đáy khung 15% (game mặc định neo 0,5 / 0,85).
- Sau khi thả file: mở editor Godot (tự import) rồi chạy `tools/import_assets/import_assets_editor.gd` (File → Run),
  hoặc dòng lệnh `godot --headless --path . --import && godot --headless --path . res://tools/import_assets/import_assets.tscn`.

## 2. Kích thước canvas

| Loại | Canvas | Ghi chú |
| --- | --- | --- |
| Chân dung hội thoại | 1024×1024, 300 dpi | 3 biểu cảm: `neutral`, `happy`, `serious` |
| Tranh gacha / cắt cảnh Tuyệt kỹ | 2048×1152 | Nhân vật lệch phải 1/3, chừa trái cho tên; game cắt dải giữa 1920×540 khi cắt cảnh |
| Hiệu ứng kỹ năng | 512×512 mỗi khung (256–1024 tùy cỡ hiệu ứng), 8–16 khung | `attack` 8, `skill` 12, `ultimate` 16 khung |
| Sửa nét sprite trận | 512×512 (quái 256 / 384 / 768) | Mở PNG render từ Blender, vẽ đè lớp nét |
| Tileset | 320×64 | 5 ô 64×64 hàng ngang |

Tạo canvas: File → New → Custom Document → nhập Width/Height, Resolution 300, Color Model RGB/Alpha 8-bit, sRGB-elle-V2-srgbtrc,
Background **Transparent**. Lưu file gốc `.kra` ngoài thư mục `assets/` (vd. `art_source/`), chỉ xuất PNG vào `assets/`.

## 3. Lớp (Layers)

Đặt tên và thứ tự từ dưới lên (giữ giống nhau giữa các file để dễ chỉnh hàng loạt):

1. `ref` – ảnh tham khảo / render Blender (ẩn khi xuất).
2. `sketch` – phác thảo (ẩn khi xuất).
3. `flat` – mảng màu phẳng theo bảng màu trong `art_specs/<id>.md` (mã HEX dùng trong Palette Docker).
4. `shade` – Group, blending Multiply, đổ bóng 2 bậc (giống shader hoạt hình của sprite).
5. `light` – blending Screen/Add, ánh viền màu nguyên tố.
6. `line` – nét viền đen #0A0A0F, 3–6 px (chân dung), 2 px (sprite 128).
7. `fx` – hào quang, hạt sáng (chỉ chân dung / tranh).

Chân dung 3 biểu cảm: vẽ chung một file, Group `face_neutral`, `face_happy`, `face_serious` chỉ chứa phần mặt; bật từng
Group rồi xuất 3 lần. Thân, tóc, trang phục dùng chung.

## 4. Chân dung và tranh gacha

1. Mở `art_specs/<id>.md`, thêm bảng màu vào Palette Docker (Settings → Dockers → Palette).
2. Chân dung: khung từ ngực lên, mắt ở 1/3 trên; nhìn hơi sang phải (hộp thoại đặt chân dung bên trái).
3. Xuất: File → Export → `portrait_<id>_<neutral|happy|serious>.png` vào `assets/characters/<id>/portrait/`.
4. Tranh gacha: 2048×1152, nền đầy (không trong suốt), xuất `splash_<id>.png` vào `assets/characters/<id>/splash/`.
   Tranh này dùng cho màn nhận nhân vật, banner (nhân vật nổi bật) và cắt cảnh Tuyệt kỹ.

## 5. Hiệu ứng kỹ năng bằng Animation Docker

1. Canvas 512×512 nền trong suốt. Settings → Workspaces → **Animation**.
2. Animation Docker: Frame rate **12**, Start 0, End = số khung − 1 (attack 7, skill 11, ultimate 15).
3. Trong Timeline, chuột phải lớp → *Create Blank Frame* ở từng khung (hoặc *Duplicate Frame* rồi sửa). Bật Onion Skin
   (Onion Skins Docker, 2 khung trước / sau) để nét liên tục.
4. Màu chủ đạo theo nguyên tố (`Element.COLORS`): Lửa #E8552B, Nước #3A8DDE, Sét #A65BF2, Phong #4FD1B5,
   Độc #9BC53D, Mộc #2E8B57, Hồn #F2D58A. Lõi sáng gần trắng, rìa đậm, tan dần về trong suốt ở khung cuối.
5. Tâm hiệu ứng ở giữa canvas (game đặt tâm khung lên mục tiêu bị đánh).
6. Xuất chuỗi PNG: File → Render Animation → *Image Sequence*, định dạng PNG, Base name `vfx_<id>_<attack|skill|ultimate>_`,
   thư mục `assets/characters/<id>/vfx/`, *First frame* 0. Krita đánh số `0000`, game đọc mọi số nguyên ở cuối tên
   (`vfx_ignar_skill_0003.png` hoặc `vfx_ignar_skill_03.png` đều được).
7. Chưa có hiệu ứng vẽ tay thì game phát chùm hạt GPUParticles2D màu nguyên tố (tự thay khi có file).

## 6. Sửa nét sprite render từ Blender

1. Render bằng Blender (`tools/blender/README.md`) → được `battle_<id>.png` (sheet) + `.json`.
2. Nếu muốn sửa tay từng khung: tách sheet bằng Image → *Split Image* (số cột = số khung, số hàng = số hành động), hoặc
   render thêm từng khung bằng `--frames`. Mỗi khung mở như một lớp, thêm lớp `line` vẽ đè nét tay, đổ bóng tay ở lớp `shade`.
3. Xuất lại thành từng khung `battle_<id>_<hành động>_<khung>.png` cùng thư mục. Khi có cả sheet và khung lẻ trùng
   hành động, game ghép cả hai (khung lẻ thêm vào sau) – nên xóa sheet cũ nếu đã sửa toàn bộ.

## 7. Tileset

Ảnh 320×64, 5 ô theo thứ tự: sàn A, sàn B (xen kẽ ô cờ), tường (có va chạm), sàn hành lang, tường hành lang (có va chạm).
Bật View → *Wrap Around Mode* (W) để vẽ ô lặp liền mạch. Xuất `assets/tilesets/<khu>/tiles_<khu>.png`
(khu: hub, library, vault, furnace, tower). Game thay tileset tạm của khu đó khi có file.

## 8. Kiểm tra

- Chạy công cụ nhập asset → đọc `docs/ASSET_STATUS.md`: mục đã nhận, cảnh báo (thiếu khung), mục còn thiếu.
- Vào game: nhân vật ngoài map đổi hướng 8 phía, trong trận phát idle / đánh / bị đánh / ngã / thắng; hội thoại hiện chân dung.

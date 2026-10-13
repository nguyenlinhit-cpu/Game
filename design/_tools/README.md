# Công cụ thiết kế Prompt 3

Game 2D nên không làm mô hình 3D. Script chạy bằng `blender -b -P`, chỉ để có sẵn Python, numpy và đọc/ghi PNG, không dựng cảnh 3D. Đã thử với Blender 5.2.2 LTS. Krita 6.0.4 xuất không giao diện bị treo trên máy này, nên `build_sketch.py` tạo `.ora` có lớp và PNG xem trước; mở `.ora` trong Krita rồi lưu `.kra`.

Script dùng chung trong thư mục này:

| Script | Việc |
| --- | --- |
| `bootstrap.py` | Tạo thư mục `nhan_vat/<id>/`, `quai/<id>/` (1_concept, 2_sketch, 4_rig2d, 5_render/preview, 6_vfx) và `REVIEW.md` |
| `build_sketch.py` | Bước 2: ghép concept + bảng màu + ghi chú thành `.ora` có lớp và PNG xem |
| `make_gif.py` | Ghi GIF không cần thư viện ngoài (`write_gif`), và tách GIF từng Action từ sheet + JSON |

Thư viện dùng chung (mỗi con chỉ khai báo, không chép lõi):

| Thư viện | Việc | File khai báo của mỗi con |
| --- | --- | --- |
| `rig2d.py` | Sprite trận bằng xương 2D uốn ảnh 1a: cắt nền, xoá hiệu ứng vẽ sẵn (`erase`/`keep`), bóng đổ dưới chân (`shadow_below`), nền trắng lọt giữa chi tiết (`white_holes`), lớp trên trọng số cứng (tay, vũ khí) + tô lấp lớp nền, xuất sheet + JSON + GIF, `grid.png` (lưới toạ độ), `weights.png` (vùng xương). `locate()` tính vị trí một điểm ở khung bất kỳ để đặt hiệu ứng | `4_rig2d/rig_battle.py`: xương, tư thế từng Action |
| `pixel2d.py` | Sprite pixel map từ lưới ký tự: dời nhóm pixel, nghiêng, nhấc phần phụ, nhắm mắt, vệt gió | `4_rig2d/map_base.txt` + `pixel_map.py`: bảng màu, màu mắt/da |
| `vfx2d.py` | Hiệu ứng 2D: hình vẽ (giọt, vòng, tia, sao 4/5 cánh, mây, mưa, mũi tên, đa giác…), bảng màu nguyên tố (`set_palette`), cắt cảnh, xuất cast/hit/screen + pixel map + GIF ghép với sprite | `6_vfx/make_<id>_vfx.py`: hàm vẽ từng khung của mỗi skill |

Mẫu đầy đủ: Mira (Nước), Kiri (Lửa), Garren (Mộc – vũ khí + khiên lớn, nhân vật ngang dùng `char_h` 360), Nyx (Sét – xoá tia điện vẽ sẵn theo màu, kính kéo xuống bằng `fill_under`, technique map tự làm khung) trong `nhan_vat/<id>/`.

Chạy từ gốc repo `/home/linh/Game`:

```bash
python3 design/_tools/bootstrap.py
blender -b -P design/_tools/build_sketch.py -- --id mira
blender -b -P design/nhan_vat/mira/4_rig2d/rig_battle.py
blender -b -P design/nhan_vat/mira/4_rig2d/pixel_map.py
blender -b -P design/nhan_vat/mira/6_vfx/make_mira_vfx.py   # chạy sau sprite để GIF ghép đúng sprite
blender -b -P design/nhan_vat/kiri/4_rig2d/rig_battle.py      # tương tự cho kiri (pixel_map.py, make_kiri_vfx.py)
```

Không script nào chép file sang `assets/` hoặc sửa code game.

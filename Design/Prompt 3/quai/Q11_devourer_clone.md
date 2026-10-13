# Q11. Phân Thân – Thường

Mọi file của họ quái này nằm trong `design/quai/devourer_clone/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `devourer_clone_flame` | Lửa | `#E8552B` |
| `devourer_clone_tide` | Nước | `#3A8DDE` |
| `devourer_clone_storm` | Sét | `#A65BF2` |

Khung trận 256 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 2,4 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Lưu ý: Chỉ có trong trận trùm cuối giai đoạn 2. Không cần sprite map.

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/devourer_clone/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`devourer_clone_flame`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a blurred smaller shadow copy of a tall figure in a long tattered coat with a vertical crack across its face, its outline burning with one element color, smoky edges, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a blurred smaller shadow copy of a tall figure in a long tattered coat with a vertical crack across its face, its outline burning with one element color, smoky edges. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Thân bóng | `#1E1A26` |
| Áo khoác rách | `#2E2838` |
| Viền nguyên tố (màu biến thể) | `#E8552B` |
| Vết nứt mặt | `#F2D58A` |

```text
Trong design/quai/devourer_clone/, tạo 2_sketch/devourer_clone_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/devourer_clone_sketch_v1.png. Thêm dòng vào design/REVIEW.md: devourer_clone | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/devourer_clone/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: lắc lư như ngọn lửa, viền nguyên tố nhấp nháy
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: tan thành khói rồi bay về phía Kẻ Nuốt Mảnh Hồn
5. Không cần bản ngoài map.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 256, quay trái, có hit_frame) cho mỗi biến thể
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/devourer_clone/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Vuốt Hồn (`clone_strike`, Action attack)

```text
Chiêu devourer_clone.clone_strike – "Vuốt Hồn". Cơ chế: 100% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: rút tay vuốt
- ra đòn: vuốt hồn
- kết thúc: trôi về
Hiệu ứng: hit: 3 vệt vuốt màu biến thể
Xuất 6_vfx/clone_strike/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Tiếng Vọng (`clone_wail`, Action skill)

```text
Chiêu devourer_clone.clone_wail – "Tiếng Vọng". Cơ chế: 35% Tấn Công lên cả đội.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: ngửa đầu, vết nứt mở
- ra đòn: gào lên
- kết thúc: cúi xuống
Hiệu ứng: screen-nhỏ: sóng âm màu biến thể; hit (mọi đồng minh): nhiễu nhỏ
Xuất 6_vfx/clone_wail/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `devourer_clone`.

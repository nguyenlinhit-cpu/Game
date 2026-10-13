# Q04. Xạ Thủ Hư Không – Thường

Mọi file của họ quái này nằm trong `design/quai/void_archer/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `void_archer_wind` | Phong | `#4FD1B5` |
| `void_archer_lightning` | Sét | `#A65BF2` |

Khung trận 256 px, quay sang trái. Ngoài map 32×32 px. Cao khoảng 2,2 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/void_archer/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`void_archer_wind`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a gaunt tall faceless archer wrapped in dark cloth with the face fully hooded and masked, holding a long curved bow made from a glowing rift in space, arrows of dark void energy, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a gaunt tall faceless archer wrapped in dark cloth with the face fully hooded and masked, holding a long curved bow made from a glowing rift in space, arrows of dark void energy. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 32x32 pixels, small fantasy monster, side view facing right, tall thin hooded archer with a long glowing rift bow taller than itself, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Vải tối | `#2B2838` |
| Băng quấn | `#5A566A` |
| Cung vết nứt (màu biến thể) | `#4FD1B5` |
| Lõi hư không | `#120F1A` |
| Mắt sáng | `#E8E8FF` |

```text
Trong design/quai/void_archer/, tạo 2_sketch/void_archer_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/void_archer_sketch_v1.png. Thêm dòng vào design/REVIEW.md: void_archer | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/void_archer/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: đứng nghiêng, cung nứt sáng nhấp nháy, vải bay
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: tan vào vết nứt hư không, cung gãy đôi
   - hoạt ảnh thêm: aim (6 khung, lặp): Ngắm – kéo căng dây cung, dây sáng dần, giữ khi đang ngắm 1 người
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 256, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 32, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/void_archer/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Tên Hư Không (`archer_shot`, Action attack)

```text
Chiêu void_archer.archer_shot – "Tên Hư Không". Cơ chế: 100% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: kéo cung
- ra đòn: buông tên hư không
- kết thúc: hạ cung
Hiệu ứng: đạn: tên hư không đen viền màu biến thể; hit: vết nứt nhỏ
Xuất 6_vfx/archer_shot/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Ngắm Bắn (`archer_mark`, Action skill)

```text
Chiêu void_archer.archer_mark – "Ngắm Bắn". Cơ chế: 40% Tấn Công và gắn Bị Ngắm lên 1 người.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: chĩa cung, mắt sáng
- ra đòn: bắn tên đánh dấu
- kết thúc: chuyển sang hoạt ảnh aim
Hiệu ứng: hit: tâm ngắm màu biến thể trên đầu người bị ngắm (giữ tới phát bắn xuyên)
Xuất 6_vfx/archer_mark/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Phát Bắn Xuyên Hư Không (`archer_snipe`, Action skill)

```text
Chiêu void_archer.archer_snipe – "Phát Bắn Xuyên Hư Không". Cơ chế: 200% Tấn Công lên người Bị Ngắm.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: kéo căng tối đa, vết nứt mở rộng
- ra đòn: bắn xuyên hư không
- kết thúc: lùi một bước vì lực giật
Hiệu ứng: đạn: tia hư không dày xuyên màn hình; hit: vết nứt lớn
Xuất 6_vfx/archer_snipe/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `void_archer`.

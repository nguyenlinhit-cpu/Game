# Q16. Cự Thú Kho Chứa – Boss

Mọi file của họ quái này nằm trong `design/quai/vault_behemoth/`. Không sửa code, `assets/` hay `data/` của game cho tới khi bạn duyệt và chạy `99_DUA_VAO_GAME.md`.

| Biến thể (id) | Nguyên tố | Màu nhấn |
| --- | --- | --- |
| `vault_behemoth` | Nước | `#3A8DDE` |

Khung trận 768 px, quay sang trái. Ngoài map 48×48 px. Cao khoảng 5,0 m so với nhân vật phe ta 2,0 m (để đặt tỉ lệ trong khung).

Giai đoạn:

- GĐ1: lưng phủ băng và thùng hàng, chậm
- GĐ2 – Băng Vỡ (máu ≤ 50%): băng nứt rơi, lộ thân đỏ, hơi nóng, nhanh và dữ hơn

## Bước 1 – Tạo ảnh concept

Tạo 1a trước, các ảnh sau đính kèm 1a làm tham chiếu. Lưu vào `design/quai/vault_behemoth/1_concept/`. Vẽ bằng màu của biến thể đầu tiên (`vault_behemoth`); biến thể khác đổi màu trên ảnh ở Bước 4.

### 1a. Trong trận (`1a_battle.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, a huge imposing boss: a massive four-legged beast, wide and low with its head lowered, its back piled high with frozen cargo crates like a mountain, thick frost and icicles all over, small fierce eyes, heavy tusks, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

### 1a-p2. Giai đoạn 2 (`1a_battle_p2.png`)

```text
Cute-but-creepy chibi fantasy monster for a turn-based RPG, a large imposing boss monster with a strong readable silhouette, the same massive four-legged beast in its second phase: the ice on its back has cracked and fallen apart revealing an angry red scarred body underneath, steam rising, eyes blazing, crates shattered, corrupted by a magical rift: glowing cracks and small floating crystal shards. Three-quarter view facing left. Clean cel shading with two tones, colored dark lineart, bright readable colors, plain white background, single creature, no text.
```

Tránh (negative):

```text
realistic, photo, 3d render, extra fingers, extra limbs, deformed hands, blurry, low quality, watermark, text, logo, signature, multiple characters, cropped body, busy background
```

### 1b. Dáng trung tính – tham chiếu dựng xương 2D (`1b_front.png`, `1b_side.png`)

```text
Same creature as the reference image: a huge imposing boss: a massive four-legged beast, wide and low with its head lowered, its back piled high with frozen cargo crates like a mountain, thick frost and icicles all over, small fierce eyes, heavy tusks. Neutral standing pose, full body, front view, even flat lighting, no cast shadows, plain white background, clean readable shapes, character turnaround reference.
```

```text
Same creature as the reference image, full body side view, neutral pose, even flat lighting, plain white background, character turnaround reference.
```

### 1c. Sprite ngoài map – pixel (`1c_pixel.png`, tham khảo)

```text
Pixel art game sprite, 48x48 pixels, small fantasy monster, side view facing right, huge low four-legged beast with a mountain of frozen crates on its back, glowing rift cracks, 1-pixel dark outline, at most 12 colors, light from the top-left, crisp pixels, no anti-aliasing, roguelike dungeon crawler style, plain transparent background, single sprite.
```

## Bước 2 – Phác thảo Krita để duyệt

Bảng màu gốc:

| Bộ phận | Mã màu |
| --- | --- |
| Da thú | `#4A5A6E` |
| Băng | `#BFE8F7` |
| Thùng hàng | `#8A6A4A` |
| Ngà | `#EDE6D6` |
| Thân đỏ GĐ2 | `#B23A3A` |
| Mắt | `#9FE3FF` |

```text
Trong design/quai/vault_behemoth/, tạo 2_sketch/vault_behemoth_sketch_v1.kra (3840×2160) gồm các lớp: concept_battle (1a, 1a_p2), concept_front (1b), map_pixel (1c phóng ×8), variants (một hàng bản đổi màu nhanh cho từng biến thể theo bảng biến thể), palette, notes (vai trò, điểm yếu gợi ý bằng hình, chỗ AI vẽ sai), your_sketch (trống, trên cùng).
Xuất ảnh xem 2_sketch/vault_behemoth_sketch_v1.png. Thêm dòng vào design/REVIEW.md: vault_behemoth | B2 phác thảo | v1 | ... | chờ duyệt.
Không đụng code, assets/, data/. Dừng lại chờ tôi duyệt.
```

## Bước 3 – (bỏ)

Game 2D không cần mô hình 3D. Bước 2 đã duyệt thì làm thẳng Bước 4.

## Bước 4 – Sprite 2D: dựng quái (dán cho AI)

```text
Làm việc trong design/quai/vault_behemoth/. Làm 2D, không dựng 3D; mẫu là script của Mira trong design/nhan_vat/mira/4_rig2d/ (xem 00_CHUNG.md mục 5). Không sửa code, assets/ hay data/ của game.
1. Sprite trận: biến dạng ảnh 1_concept/1a_battle.png bằng xương 2D (chép rig_battle.py của Mira vào 4_rig2d/, đặt lại pivot và vùng ảnh hưởng theo ảnh lưới toạ độ). Phần đè lên mặt hoặc cần xoay nhiều (vũ khí, tay) tách thành lớp riêng; lớp nền tô lấp chỗ bị che.
2. Biến thể: thay các ô màu có ghi (màu biến thể) sang màu nhấn của biến thể ngay trên ảnh concept (thay màu theo vùng), mỗi biến thể 1 sheet riêng.
3. Xương: dựng cây xương theo hình dạng (chân, cánh, xúc tu, sách bay... mỗi phần chuyển động 1 xương).
4. Hoạt ảnh trận (12 fps), quay sang trái:
   - idle 6 khung, lặp: thở ra hơi lạnh, đầu lắc chậm, băng rơi lả tả
   - attack 8 khung (trúng khung 4), skill 10 khung (trúng khung 6): theo Bước 5
   - hit 4 khung: giật lùi, vết nứt Ma Biến lóe sáng
   - down 6 khung: quỵ xuống, thùng hàng đổ, băng vỡ
   - hoạt ảnh thêm: telegraph (6 khung, lặp): gồng trước Gầm Băng Giá / Lở Băng; phase2 (12 khung); mọi hành động GĐ2 thêm hậu tố -p2
5. Bản ngoài map (pixel): vẽ tay khung gốc dạng lưới ký tự theo 1d_pixel.png (mẫu map_base.txt + pixel_map.py của Mira), làm Action bằng cách dời nhóm pixel: idle 4, run 4, windup 3 (gồng trước khi vồ: co người, nháy màu nhấn). Nhìn ngang, chỉ hướng phải.
6. Render:
   - trận: 5_render/<id biến thể>/battle_<id biến thể>.png + .json (khung 768, quay trái, có hit_frame) cho mỗi biến thể
   - map: 5_render/<id biến thể>/map_<id biến thể>.png + .json (khung 48, pixel ≤ 12 màu, viền 1 px #141018)
   - ảnh xem: GIF mỗi Action trong 5_render/preview/, 1 ảnh ghép các biến thể cạnh nhau
7. Thêm dòng B4 vào design/REVIEW.md (chờ duyệt). Không chép gì vào assets/. Dừng lại chờ tôi duyệt.
```

## Bước 5 – Chiêu: hoạt ảnh và hiệu ứng

Render vào `design/quai/vault_behemoth/6_vfx/<chiêu>/`. Màu hiệu ứng theo màu nhấn của từng biến thể. Dán từng mục cho AI.

### Vuốt Băng (`beh_claw`, Action attack)

```text
Chiêu vault_behemoth.beh_claw – "Vuốt Băng". Cơ chế: 120% Tấn Công lên 1 người.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: nhấc chân trước
- ra đòn: vuốt xuống
- kết thúc: đặt chân
Hiệu ứng: hit: 3 vết vuốt băng
Xuất 6_vfx/beh_claw/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Hơi Thở Đóng Băng (`beh_freeze`, Action skill)

```text
Chiêu vault_behemoth.beh_freeze – "Hơi Thở Đóng Băng". Cơ chế: 60% Tấn Công lên người Tấn Công cao nhất, 80% Đông Cứng 1 lượt.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: hít vào, ngực phồng
- ra đòn: thở luồng băng vào người tấn công cao nhất
- kết thúc: lắc đầu
Hiệu ứng: đạn: luồng hơi băng; hit: khối băng bọc người (Đông Cứng)
Xuất 6_vfx/beh_freeze/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Gầm Băng Giá (`beh_roar`, Action telegraph → skill)

```text
Chiêu vault_behemoth.beh_roar – "Gầm Băng Giá". Cơ chế: Báo trước 1 lượt: 100% Tấn Công lên cả đội. Phá khiên để hủy.
Hoạt ảnh (lượt 1: hoạt ảnh báo trước lặp 6 khung; lượt 2: skill 10 khung, trúng khung 6):
- chuẩn bị: lượt 1: gồng, ngẩng đầu (cảnh báo)
- ra đòn: lượt 2: gầm lớn
- kết thúc: hạ đầu
Hiệu ứng: screen-nhỏ: sóng âm băng; hit (mọi đồng minh): sương giá; bị phá khiên khi gồng: nghẹn, băng vỡ trên mõm
Xuất 6_vfx/beh_roar/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Giẫm Nát (`beh_rampage`, Action attack)

```text
Chiêu vault_behemoth.beh_rampage – "Giẫm Nát". Cơ chế: 100% Tấn Công lên 1 người và 60% lên người bên cạnh.
Hoạt ảnh (8 khung, trúng khung 4):
- chuẩn bị: (GĐ2) cúi đầu cào đất
- ra đòn: lao tới giẫm nát
- kết thúc: trượt dừng
Hiệu ứng: hit: vết giẫm nứt đất trên 1 người + người bên cạnh
Xuất 6_vfx/beh_rampage/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Mưa Mảnh Băng (`beh_shards`, Action skill)

```text
Chiêu vault_behemoth.beh_shards – "Mưa Mảnh Băng". Cơ chế: 60% Tấn Công lên cả đội.
Hoạt ảnh (10 khung, trúng khung 6):
- chuẩn bị: (GĐ2) rùng mình
- ra đòn: mảnh băng trên lưng bắn tung lên cả đội
- kết thúc: lắc mình
Hiệu ứng: hit (mọi đồng minh): mưa mảnh băng
Xuất 6_vfx/beh_shards/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Lở Băng (`beh_avalanche`, Action telegraph → skill)

```text
Chiêu vault_behemoth.beh_avalanche – "Lở Băng". Cơ chế: Báo trước 1 lượt: 130% Tấn Công lên cả đội. Phá khiên để hủy.
Hoạt ảnh (lượt 1: hoạt ảnh báo trước lặp 6 khung; lượt 2: skill 10 khung, trúng khung 6):
- chuẩn bị: (GĐ2) lượt 1: đứng chồm lên hai chân sau (cảnh báo)
- ra đòn: lượt 2: dậm xuống, lở băng
- kết thúc: thở dốc
Hiệu ứng: screen: tuyết lở từ trên màn hình đổ xuống; bị phá khiên: ngã nghiêng
Xuất 6_vfx/beh_avalanche/<cast|hit|screen>/<khung>.png (khung 512, screen tới 1024) + GIF ghép quái + hiệu ứng. Không chép vào assets/.
```

### Chuyển giai đoạn (`phase2`, 12 khung)

```text
Hoạt ảnh chuyển giai đoạn của vault_behemoth: khung 0–3 khựng lại, vết nứt sáng chói; khung 4–8 lớp ngoài vỡ/biến đổi đúng mô tả giai đoạn; khung 9–11 tư thế mới, gầm hoặc tỏa sóng. Hiệu ứng screen: chớp màu nhấn 2 khung + mảnh vỡ bay. Mọi Action của giai đoạn sau thêm hậu tố -p2 / -p3.
```

## Bước 6 – Gửi duyệt

Thêm dòng cho từng chiêu vào `design/REVIEW.md` (chờ duyệt) kèm GIF. Duyệt xong mới dùng `99_DUA_VAO_GAME.md` với id `vault_behemoth`.

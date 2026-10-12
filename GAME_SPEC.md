# Đặc tả game: Aethelgard – Mảnh Hồn

Tài liệu này là đặc tả gốc. Đặt ở `docs/GAME_SPEC.md` trong dự án. Mỗi phase có file prompt riêng (PHASE_01.md → PHASE_14.md) chỉ ra cần đọc mục nào.

## 1. Vai trò và cách làm việc

Bạn là lập trình viên kiêm thiết kế game nhiều kinh nghiệm với Godot 4. Nhiệm vụ: xây dựng game 2D "Aethelgard: Mảnh Hồn" theo đặc tả này, chia theo 14 phase ở mục 14.

1. Mỗi lần chỉ làm một phase. Xong thì dừng, liệt kê file đã tạo/sửa, cách chạy thử, việc còn thiếu, rồi chờ tôi xác nhận.
2. Cuối mỗi phase game phải chạy được, kể cả khi chưa có hình: dùng hình tạm (khối màu theo nguyên tố, chữ cái đầu tên nhân vật).
3. Mọi chỉ số, kỹ năng, quái, banner, bảng rơi đồ, nhiệm vụ nằm trong file dữ liệu (Resource .tres hoặc JSON), không viết cứng trong code, để tôi cân bằng mà không cần sửa code.
4. GDScript có kiểu tĩnh (static typing), tên biến tiếng Anh, chú thích tiếng Việt ở chỗ khó.
5. Chỗ nào đặc tả chưa rõ: chọn phương án hợp lý nhất và ghi vào `docs/DESIGN_NOTES.md`. Chỉ dừng lại hỏi khi quyết định ảnh hưởng lớn.
6. Không dùng tên, hình, âm thanh hay văn bản của Honkai: Star Rail (HSR) hoặc Soul Knight. Chỉ lấy cảm hứng cơ chế.
7. Chữ trong game là tiếng Việt, đặt trong file dịch CSV của Godot để sau thêm tiếng Anh.
8. Cuối mỗi phase cập nhật `docs/PROGRESS.md`: đã làm gì, file chính, quyết định quan trọng, việc còn nợ. Đầu mỗi phiên làm việc mới, đọc lại `docs/GAME_SPEC.md` và `docs/PROGRESS.md`.

## 2. Tổng quan game

- Thể loại: nhập vai 2D. Khám phá bản đồ góc nhìn từ trên xuống kiểu Soul Knight; gặp quái thì vào trận đánh theo lượt kiểu HSR nhưng hoàn toàn 2D.
- Engine: Godot 4 bản ổn định mới nhất, GDScript, renderer Compatibility để chạy được máy yếu và mobile.
- Nền tảng: PC trước (bàn phím, chuột, tay cầm); có sẵn điều khiển cảm ứng (joystick ảo, nút kỹ năng) để xuất Android sau.
- Độ phân giải gốc 1920×1080, stretch mode canvas_items, aspect expand.
- Vòng lặp chính: khám phá phòng → chạm quái → trận theo lượt → nhận tài nguyên → nâng cấp nhân vật, quay gacha, làm nhiệm vụ ngày → mở khu mới theo cốt truyện.
- Đội hình tối đa 4 nhân vật. Trong trận chỉ có đúng 4 người đã chọn trước, không đổi người giữa trận. Ngoài map điều khiển 1 nhân vật dẫn đầu, đổi giữa 4 người bằng phím 1–4.
- Phạm vi hiện tại: 1 bản đồ (Pháo Đài Vọng Tinh, mục 4), 4 chương truyện, 24 nhân vật + nhân vật chính, 2 banner, giới hạn cấp hiện tại 30. Chơi offline, lưu trên máy.

## 3. Cốt truyện và thế giới

Lời dẫn mở đầu (chữ chạy trên tranh 2D, có nút bỏ qua):

> Từ thuở sơ khai, thế giới Aethelgard không tồn tại bóng tối. Vạn vật sinh sôi, từ ngọn cỏ chiếc lá cho đến những vì sao trên bầu trời, đều vận hành nhờ trái tim của vương quốc gọi là Tâm Thần Nhãn. Sáu nguyên tố Lửa, Nước, Sét, Phong, Độc và Mộc đan xen lẫn nhau, giữ cho thế giới một sự cân bằng tuyệt đối.
>
> Nhưng hòa bình chưa bao giờ là vĩnh cửu.
>
> Một đêm nọ, bầu trời lặng im một cách kỳ lạ. Đột nhiên một vết nứt xé toạc hư không, mang theo những hiện tượng kỳ quái mang tên Ma Biến. Trái tim của thế giới nổ tung: Tâm Thần Nhãn vỡ tan thành muôn vàn Mảnh Hồn, rơi vãi khắp nơi. Aethelgard trôi dạt vào hư vô, bị xé nhỏ thành hàng ngàn hầm ngục hỗn loạn, nơi thời gian ngưng đọng và không gian bị bóp méo.

Bổ sung để khớp hệ thống 7 nguyên tố:

- Khi Tâm Thần Nhãn vỡ, sức mạnh của chính nó thành nguyên tố thứ 7: Hồn. Chỉ người có Mảnh Hồn hòa vào cơ thể mới dùng được.
- Ma Biến là năng lượng méo mó từ vết nứt. Quái Ma Biến là sinh vật, đồ vật bị nhiễm, có thể mang bất kỳ nguyên tố nào.
- Nhân vật chính tỉnh dậy với một Mảnh Hồn trong tim và mất trí nhớ. Mỗi Mảnh Hồn thu hồi mở một đoạn ký ức và một Tinh Mệnh của nhân vật chính.
- Celestine (5★ giới hạn) là Người Gác Nhãn cuối cùng, xuất hiện trong ảo ảnh cuối Chương 1, là lý do banner giới hạn mở cùng lúc với banner thường.

Mạch truyện trên bản đồ hiện tại:

| Chương | Khu vực | Diễn biến chính | Nhận miễn phí | Boss |
| --- | --- | --- | --- | --- |
| Mở đầu | Sảnh Trung Tâm | Chọn nam/nữ, tỉnh dậy, hướng dẫn di chuyển và đánh theo lượt | Mira (4★) | Không (quái hướng dẫn) |
| 1 | Thư Viện Câm Lặng | Tìm sơ đồ pháo đài; cuối chương mở Gacha và nhiệm vụ hàng ngày | Kiri (4★) | Người Gác Thư Viện |
| 2 | Kho Chứa Băng Giá | Cứu đội cận vệ, đủ đội 4 người | Garren (4★) | Cự Thú Kho Chứa |
| 3 | Lò Năng Lượng | Khởi động lại lò, phát hiện kẻ đánh cắp Mảnh Hồn | Nyx (4★) | Lõi Lò Biến Dạng |
| 4 | Đỉnh Tháp Quan Sát | Đối đầu trùm cuối; vết nứt mở ra vùng đất mới (móc nối bản cập nhật sau) | Không | Kẻ Nuốt Mảnh Hồn |

Viết đầy đủ hội thoại cho từng chương: 3–5 cảnh chính mỗi chương, mỗi nhân vật miễn phí có cảnh gia nhập riêng thể hiện tính cách.

## 4. Bản đồ Pháo Đài Vọng Tinh và khám phá

Game hiện chỉ có 1 bản đồ: Pháo Đài Vọng Tinh, pháo đài quan sát sao trôi trong hư vô, từng canh giữ mảnh lớn nhất của Tâm Thần Nhãn. Cấu trúc giống một trạm lớn: một khu trung tâm an toàn và 4 khu bị Ma Biến chiếm, mở dần theo chương.

Khu vực:

- Sảnh Trung Tâm (an toàn, không quái): điểm hồi sinh, NPC, cửa hàng, bàn Gacha, bảng nhiệm vụ, đổi đội hình, nâng cấp nhân vật.
- Thư Viện Câm Lặng (Chương 1), Kho Chứa Băng Giá (Chương 2), Lò Năng Lượng (Chương 3), Đỉnh Tháp Quan Sát (Chương 4).
- Mỗi khu 8–12 phòng nối bằng hành lang kiểu Soul Knight: phòng chiến đấu, phòng rương, phòng giải đố, phòng nghỉ (hồi máu, lưu game, dịch chuyển nhanh), phòng tinh anh, phòng boss.
- Phòng dựng thủ công từ bộ phòng mẫu (TileMapLayer) để cốt truyện cố định. Quái thường hồi lại khi rời khu, để cày tài nguyên.

Di chuyển (cảm giác Soul Knight):

- Góc nhìn từ trên xuống, đi 8 hướng mượt (CharacterBody2D), tăng/giảm tốc nhanh, có lướt (dash) với thời gian hồi.
- Camera bám nhân vật, rung nhẹ khi đánh trúng; minimap góc màn hình hiện phòng đã khám phá.
- Vào phòng chiến đấu thì cửa khóa, chỉ mở khi hạ hết các nhóm quái trong phòng.
- Quái tuần tra theo đường định sẵn, thấy người chơi thì đuổi theo.
- Máu nhân vật giữ nguyên giữa các trận; hồi đầy ở phòng nghỉ.

Kỹ năng ngoài map (mỗi nhân vật đúng 2):

1. Đòn Mở Màn: đòn đánh trên map, miễn phí, hồi chiêu ngắn, mang nguyên tố của nhân vật. Trúng quái thì vào trận với Ưu Thế.
2. Bí Kỹ: tốn 1 Điểm Bí Kỹ (tối đa 5, dùng chung cả đội, hồi bằng vật phá được trên map hoặc ở phòng nghỉ). Hiệu ứng riêng từng nhân vật: tăng lợi thế cho trận kế tiếp, gây sát thương/hiệu ứng lên quái trên map, hoặc tiện ích khám phá (tàng hình, lướt xa, hút vật phẩm, hồi máu cả đội).

Đòn Mở Màn còn tương tác với môi trường theo nguyên tố (dùng cho giải đố, xem bảng ở mục 6), nên người chơi cần đổi người dẫn đầu để mở hết rương ẩn.

Vào trận:

- Ta đánh trúng quái trước → Ưu Thế: cả đội hành động trước ở vòng đầu, hiệu ứng Bí Kỹ đã bật được áp dụng; nếu nguyên tố là điểm yếu của quái, quái mất 25% khiên.
- Quái đánh trúng ta trước → Bị Phục Kích: quái hành động trước ở vòng đầu.
- Chạm nhau không ai đánh → trận bình thường.
- Quái thấp hơn đội từ 10 cấp trở lên: đánh trúng là thắng ngay, nhận thưởng luôn.
- Mỗi nhóm quái trên map gắn với một EncounterData (có thể nhiều đợt). Chuyển cảnh 0,5–1 giây; thua thì về phòng nghỉ gần nhất, không mất đồ.

## 5. Chiến đấu theo lượt (2D, kiểu HSR)

Màn hình trận nhìn ngang 2D: phe ta bên trái, quái bên phải. Thanh thứ tự lượt dọc bên trái; dưới cùng là 4 thẻ nhân vật (máu, năng lượng, chân dung); nút Đánh thường, Chiến kỹ, ô Điểm Chiến Kỹ ở góc phải.

Cơ chế:

1. Thứ tự lượt theo Tốc Độ: Giá trị Hành Động = 10000 / Tốc Độ, ai thấp nhất đi trước. Hiệu ứng kéo lượt, trì hoãn, tăng giảm tốc độ thay đổi giá trị này. Khi chọn kỹ năng, thanh lượt xem trước thay đổi.
2. Điểm Chiến Kỹ dùng chung cả đội: tối đa 5, đầu trận có 3. Đánh thường +1, Chiến kỹ −1.
3. Năng lượng: mỗi hành động và mỗi lần bị đánh đều cho năng lượng. Đầy thì dùng Tuyệt kỹ bất cứ lúc nào, kể cả chen ngang lượt người khác (bấm vào chân dung).
4. Khiên Điểm Yếu: mỗi quái có 1–3 nguyên tố điểm yếu. Chỉ đòn đúng điểm yếu mới làm giảm khiên. Khiên về 0 → Phá Vỡ: gây sát thương phá vỡ, trì hoãn lượt quái 25%, gắn hiệu ứng theo nguyên tố (mục 6). Khiên hồi đầy ở lượt kế tiếp của quái.
5. Kháng nguyên tố mặc định của quái 20%, nguyên tố điểm yếu 0%.
6. Buff/debuff có số lượt, có thể cộng dồn; tỉ lệ trúng phụ thuộc Chính Xác Hiệu Ứng của ta và Kháng Hiệu Ứng của quái.
7. Đòn đánh phụ và phản công là hành động riêng, không tốn lượt.
8. Có nút Tự Động và Tăng Tốc x2.
9. Phe ta tối đa 4 nhân vật: không đổi người giữa trận, người ngã không có ai thay; vật triệu hồi (nếu có) không chiếm chỗ nhân vật. Phe quái tối đa 5 mỗi đợt, có thể nhiều đợt.

Chỉ số nhân vật: Máu, Tấn Công, Phòng Thủ, Tốc Độ, Tỉ Lệ Bạo Kích (gốc 5%), Sát Thương Bạo Kích (gốc 50%), Hiệu Ứng Phá Vỡ, Hiệu Suất Hồi Năng Lượng, Chính Xác Hiệu Ứng, Kháng Hiệu Ứng, Tăng Trị Liệu.

Giới hạn cấp hiện tại là 30, đột phá ở cấp 10 và 20. Giới hạn cấp là một hằng số cấu hình; dữ liệu chừa chỗ để sau nâng lên 80.

Công thức sát thương (đặt trong một hàm duy nhất `systems/damage_calc.gd` để dễ chỉnh):

- Sát thương = Chỉ số gốc × Hệ số kỹ năng × (1 + Tăng sát thương%) × Hệ số bạo kích × Hệ số phòng thủ × (1 − Kháng%) × (1 + Dễ tổn thương%) × Hệ số phá vỡ
- Hệ số phòng thủ = (Cấp ta + 20) / ((Cấp quái + 20) × (1 − Giảm phòng thủ%) + Cấp ta + 20)
- Hệ số phá vỡ = 0,9 khi quái còn khiên, 1,0 khi khiên đã vỡ.

Hình ảnh trận hoàn toàn 2D: sprite sheet nhân vật (đứng, đánh thường, chiến kỹ, bị đánh, ngã, thắng), hiệu ứng kỹ năng bằng sprite sheet + GPUParticles2D + shader. Tuyệt kỹ có cắt cảnh 2D 1,5–3 giây (tranh nhân vật trượt vào, nền đổi màu theo nguyên tố, bỏ qua được). Thắng trận hiện EXP và vật phẩm nhận được; thua thì chọn đánh lại hoặc rút lui.

## 6. 7 nguyên tố và 7 vận mệnh

Mỗi nguyên tố có một màu chủ đạo (dùng cho hình tạm, viền chữ, hiệu ứng), một hiệu ứng khi Phá Vỡ và một tương tác ngoài map.

| Nguyên tố | Màu | Hiệu ứng khi Phá Vỡ | Tương tác ngoài map |
| --- | --- | --- | --- |
| Lửa | #E8552B | Thiêu Đốt: sát thương Lửa mỗi lượt, 2 lượt | Đốt dây leo chắn đường, thắp đuốc |
| Nước | #3A8DDE | Đóng Băng: quái mất 1 lượt; khi tan nhận thêm sát thương Nước | Dập lửa, đông mặt nước thành cầu |
| Sét | #A65BF2 | Điện Giật: sát thương Sét mỗi lượt, 2 lượt | Cấp điện cho cửa máy, thang nâng |
| Phong | #4FD1B5 | Phong Cắt: sát thương mỗi lượt, cộng dồn tối đa 5 tầng | Thổi tan sương mù, quay cối gió |
| Độc | #9BC53D | Nhiễm Độc: sát thương theo % máu tối đa của quái (có trần), 2 lượt, giảm 10% Phòng Thủ | Ăn mòn cổng sắt gỉ |
| Mộc | #2E8B57 | Trói Rễ: trì hoãn thêm 20%, đòn kế tiếp lên quái gây thêm sát thương | Mọc cây làm cầu, mở nụ hoa khóa |
| Hồn | #F2D58A | Giam Hồn: trì hoãn thêm 30%, giảm 10% Tốc Độ 1 lượt | Hiện lối đi và rương ẩn |

Vận mệnh quyết định vai trò trong đội, trọng số bị quái nhắm và cây vận mệnh (các nút chỉ số nhỏ + 3 nút bị động lớn).

| Vận mệnh | Vai trò | Trọng số bị nhắm | Đặc trưng kỹ năng |
| --- | --- | --- | --- |
| Hủy Diệt | Gây sát thương lan, chịu đòn | 125 | Máu cao, đánh mục tiêu chính + 2 bên, đổi máu lấy sức mạnh |
| Săn Bắn | Sát thương đơn mục tiêu mạnh nhất | 75 | Tốc độ, bạo kích cao |
| Tri Thức | Sát thương toàn bộ quái | 75 | Tấn công cao, máu thấp |
| Hòa Hợp | Tăng sức mạnh đồng đội | 100 | Buff tấn công, tốc độ, kéo lượt |
| Hư Vô | Làm suy yếu quái | 100 | Debuff, sát thương theo lượt |
| Bảo Hộ | Đỡ đòn | 150 | Tạo khiên, khiêu khích, phòng thủ cao |
| Trù Phú | Hồi máu | 100 | Hồi máu, giải hiệu ứng xấu, hồi sinh hạn chế |

## 7. Nhân vật chính (chọn nam hoặc nữ)

- Màn hình đầu game: chọn Nam hoặc Nữ và đặt tên (mặc định: Kael / Kaela).
- Hai bản giống hệt nhau về chỉ số, kỹ năng, đặc tính, cây vận mệnh, Tinh Mệnh. Chỉ khác sprite, chân dung, âm thanh. Trong code là 1 CharacterData (id `traveler`) với 2 bộ hình, không phải 2 nhân vật.
- Nguyên tố Hồn, vận mệnh Hủy Diệt, hạng 5★ nhưng không có trong banner. Tinh Mệnh mở bằng Mảnh Hồn thu được theo cốt truyện.

Mẫu kỹ năng của nhân vật chính, dùng làm khuôn cho mọi nhân vật (số liệu là mẫu, cân bằng sau):

- Ngoài map 1, Đòn Mở Màn "Vết Chém Hồn": chém hình quạt phía trước, hồi 0,6 giây. Trúng quái thì vào trận với Ưu Thế; chém vào tường nứt thì hiện lối đi ẩn.
- Ngoài map 2, Bí Kỹ "Bước Hư Ảnh" (1 Điểm Bí Kỹ): lướt 4 ô xuyên qua rào Ma Biến. Trận kế tiếp, lượt đầu của nhân vật chính được kéo lên 25%.
- Đánh thường "Chém Rạn": 100% Tấn Công sát thương Hồn lên 1 quái. +1 Điểm Chiến Kỹ, +20 năng lượng.
- Chiến kỹ "Hồn Vỡ": 125% lên mục tiêu chính, 50% lên 2 quái bên cạnh. −1 Điểm Chiến Kỹ, +30 năng lượng.
- Tuyệt kỹ "Tâm Nhãn Khai Mở" (120 năng lượng): chọn 450% lên 1 quái, hoặc 270% mục tiêu chính + 160% hai bên.
- Đặc tính "Cộng Hưởng Mảnh Hồn": mỗi lần phá vỡ khiên một quái, Tấn Công +20% trong 2 lượt, cộng dồn tối đa 2 tầng.
- Tinh Mệnh 1–6: mỗi chương mở 1, 2 nhiệm vụ phụ mở 2 cái còn lại.

## 8. Danh sách 24 nhân vật

Gồm 8 nhân vật 5★ (7 banner thường + 1 banner giới hạn) và 16 nhân vật 4★, trong đó 4 người nhận miễn phí qua cốt truyện. Mỗi nguyên tố có 3–4 người, mỗi vận mệnh 3–4 người; 7 nhân vật 5★ thường phủ đủ 7 nguyên tố và 7 vận mệnh. Đội miễn phí (nhân vật chính, Mira, Kiri, Garren, Nyx) đủ mọi vị trí: sát thương, hồi máu, buff, đỡ đòn, debuff. Tên là tên tạm.

| # | Tên | Hạng | Nguyên tố | Vận mệnh | Nguồn |
| --- | --- | --- | --- | --- | --- |
| 1 | Ignar | 5★ | Lửa | Hủy Diệt | Banner thường |
| 2 | Marisol | 5★ | Nước | Bảo Hộ | Banner thường |
| 3 | Raiko | 5★ | Sét | Săn Bắn | Banner thường |
| 4 | Zephyra | 5★ | Phong | Hòa Hợp | Banner thường |
| 5 | Vesper | 5★ | Độc | Hư Vô | Banner thường |
| 6 | Sylvaine | 5★ | Mộc | Trù Phú | Banner thường |
| 7 | Orrin | 5★ | Hồn | Tri Thức | Banner thường |
| 8 | Celestine | 5★ | Hồn | Săn Bắn | Banner giới hạn |
| 9 | Mira | 4★ | Nước | Trù Phú | Miễn phí (Mở đầu) + cả 2 banner |
| 10 | Kiri | 4★ | Lửa | Hòa Hợp | Miễn phí (Chương 1) + cả 2 banner |
| 11 | Garren | 4★ | Mộc | Bảo Hộ | Miễn phí (Chương 2) + cả 2 banner |
| 12 | Nyx | 4★ | Sét | Hư Vô | Miễn phí (Chương 3) + cả 2 banner |
| 13 | Quill | 4★ | Độc | Trù Phú | Cả 2 banner |
| 14 | Aldric | 4★ | Phong | Bảo Hộ | Cả 2 banner |
| 15 | Rook | 4★ | Mộc | Hủy Diệt | Cả 2 banner |
| 16 | Fenna | 4★ | Mộc | Săn Bắn | Cả 2 banner |
| 17 | Kestrel | 4★ | Phong | Hủy Diệt | Cả 2 banner |
| 18 | Vael | 4★ | Độc | Tri Thức | Cả 2 banner |
| 19 | Wisp | 4★ | Phong | Hư Vô | Cả 2 banner |
| 20 | Selka | 4★ | Độc | Hòa Hợp | Cả 2 banner |
| 21 | Ember | 4★ | Lửa | Tri Thức | Cả 2 banner |
| 22 | Neris | 4★ | Nước | Săn Bắn | Cả 2 banner |
| 23 | Pip | 4★ | Sét | Hòa Hợp | Cả 2 banner |
| 24 | Echo | 4★ | Hồn | Hư Vô | Cả 2 banner |

Quy tắc thiết kế mỗi nhân vật:

- Đủ bộ: tiểu sử 3–4 câu gắn với Aethelgard và Ma Biến, tính cách, ngoại hình (bảng 3–4 màu, dáng nhận ra được chỉ qua bóng đen), 2 kỹ năng ngoài map, 3 kỹ năng trong trận (Đánh thường, Chiến kỹ, Tuyệt kỹ), 1 Đặc tính, 6 Tinh Mệnh, cây vận mệnh, chỉ số cấp 1 và cấp 30 (công thức tăng trưởng dùng được tới cấp 80 khi nâng giới hạn).
- Đặc tính là cơ chế riêng, không trùng ai. Gợi ý hướng: tích tầng, đòn đánh phụ, phản công, triệu hồi, đổi thế đứng, tiêu máu bản thân, đánh dấu mục tiêu, ăn thêm Điểm Chiến Kỹ, chia máu với đồng đội, kéo lượt đồng đội, cộng hưởng khi đội cùng nguyên tố.
- 5★ mạnh hơn 4★ cùng cấp khoảng 15–25% và cơ chế sâu hơn. 4★ dễ dùng nhưng vẫn có chỗ đứng; đội miễn phí phải đủ sức qua hết Chương 4.
- Bí Kỹ chia đều 3 nhóm: lợi thế trận kế tiếp, tác động quái trên map, tiện ích khám phá.
- Xuất dữ liệu ra `data/characters/<id>.tres` và một bảng `docs/CHARACTERS.md` để tôi duyệt trước khi code.

## 9. Quái và boss

Quy tắc chung: mỗi quái có nguyên tố tấn công, 1–3 điểm yếu, thanh khiên, 2–3 kỹ năng; AI chọn kỹ năng theo trọng số và tình huống. Đòn mạnh phải báo trước 1 lượt bằng biểu tượng cảnh báo. Cấp quái: Chương 1 cấp 1–8, Chương 2 cấp 8–16, Chương 3 cấp 16–24, Chương 4 cấp 24–30 (trùm cuối cấp 30). Mỗi boss phải có ít nhất 1 điểm yếu thuộc đội miễn phí (Hồn, Nước, Lửa, Mộc, Sét).

Quái thường (mỗi loại có biến thể theo nguyên tố):

| Tên | Vai trò | Kỹ năng đặc trưng |
| --- | --- | --- |
| Mầm Ma Biến | Yếu, đông | Nổ khi chết, gây sát thương nhỏ lên cả đội |
| Hồn Ảnh Lang Thang | Hỗ trợ | Tạo khiên cho quái đồng minh |
| Giáp Sĩ Rỉ Sét | Khiên dày | Thủ thế: giảm sát thương nhận trong 1 lượt |
| Xạ Thủ Hư Không | Đánh xa | Đánh dấu 1 nhân vật, lượt sau bắn gấp đôi vào người đó |
| Pháp Sư Méo | Gây hiệu ứng | Gắn Thiêu Đốt, Nhiễm Độc... theo nguyên tố |
| Chuột Mực Sách | Nhanh | Đánh trúng thì trộm 1 Điểm Chiến Kỹ |
| Bầy Ong Độc | Nhiều mục tiêu | 3 con nhỏ, gọi thêm khi chỉ còn 1 |
| Bóng Gương | Gây rối | Sao chép 1 buff của nhân vật ta |

Quái tinh anh:

- Kỵ Sĩ Vỡ Vụn: tích tụ 1 lượt rồi lao tới gây sát thương lớn; phá khiên lúc đang tích tụ thì hủy đòn.
- Mẫu Thể Ma Biến: cứ 2 lượt triệu hồi Mầm Ma Biến; càng ít Mầm, khiên càng yếu.
- Thủ Thư Câm: Phong Ấn Chiến kỹ của 1 nhân vật trong 2 lượt.

Boss (mỗi boss 2–3 giai đoạn, nhạc riêng, có thể đổi điểm yếu giữa giai đoạn):

| Boss | Chương | Điểm yếu | Cơ chế |
| --- | --- | --- | --- |
| Người Gác Thư Viện | 1 | Lửa, Phong, Hồn | Triệu hồi sách bay. Dưới 50% máu đọc lời nguyền đếm ngược 3 lượt; phải phá khiên để ngắt, không thì cả đội bị Phong Ấn |
| Cự Thú Kho Chứa | 2 | Lửa, Sét, Hồn | Đóng băng 1 nhân vật. Giai đoạn 2 vỡ lớp băng: tăng tốc, đánh lan |
| Lõi Lò Biến Dạng | 3 | Nước, Mộc, Hồn | Mỗi lượt tích 1 tầng Nhiệt, đủ 5 tầng thì nổ cả đội; phá khiên giảm 3 tầng. Có 2 tay máy là mục tiêu phụ |
| Kẻ Nuốt Mảnh Hồn | 4 (trùm cuối) | Đổi theo giai đoạn | GĐ1 hút buff của ta. GĐ2 tách 3 phân thân khác điểm yếu. GĐ3 mỗi lượt xóa 1 Điểm Chiến Kỹ, tung "Nuốt Hồn" đếm ngược; phải gây đủ sát thương để ngắt |

Boss đánh lại được, có thêm mức khó cao hơn rơi nhiều nguyên liệu hơn.

## 10. Gacha: 2 banner

Tiền tệ: Lệ Tinh, 160 Lệ Tinh đổi 1 vé. Có Vé Thường (chỉ dùng cho banner thường) và Vé Giới Hạn (chỉ dùng cho banner giới hạn). Quay 1 hoặc 10 lượt. Gacha mở sau Chương 1.

Banner thường "Ước Nguyện Vĩnh Hằng" (luôn mở):

- 5★ luôn là 1 trong 7 nhân vật: Ignar, Marisol, Raiko, Zephyra, Vesper, Sylvaine, Orrin (tỉ lệ ngang nhau).
- 4★ là 1 trong 16 nhân vật 4★.
- Sau 300 lượt ở banner này, được chọn miễn phí 1 nhân vật 5★ thường (một lần duy nhất).

Banner giới hạn "Tiếng Gọi Của Nhãn":

- 5★ nổi bật: Celestine. Khi ra 5★, 50% là Celestine; nếu lệch thì ra 1 trong 7 nhân vật 5★ thường, và lần 5★ kế tiếp chắc chắn là Celestine.
- 3 nhân vật 4★ nổi bật (đặt trong file banner): khi ra 4★, 50% là 1 trong 3 người này; lệch thì lần 4★ sau chắc chắn.
- Banner định nghĩa bằng BannerData để sau thay nhân vật giới hạn khác mà không sửa code.

Tỉ lệ chung:

- 5★: 0,6% mỗi lượt; từ lượt 74 cộng thêm 6% mỗi lượt; lượt 90 chắc chắn.
- 4★: 5,1%; cứ 10 lượt chắc chắn có ít nhất 1 nhân vật 4★ trở lên.
- Còn lại là vật phẩm 3★ (Ký Ức Mảnh Hồn hoặc Xu Aether).
- Bộ đếm bảo hiểm mỗi banner tính riêng, lưu trong file save; bộ đếm giới hạn được giữ khi sau này đổi sang banner giới hạn mới.
- Trùng nhân vật: lần trùng 1–6 mở Tinh Mệnh 1–6, từ lần thứ 7 trở đi đổi thành Bụi Sao. Mỗi lần trùng còn tặng Bụi Sao (5★: 40, 4★: 8) để đổi vé ở cửa hàng (20 Bụi Sao/vé, mỗi tháng tối đa 5 Vé Thường và 5 Vé Giới Hạn).
- Có lịch sử 100 lượt gần nhất. Hiệu ứng quay 2D: sao băng màu theo độ hiếm (xanh 3★, tím 4★, vàng 5★), bỏ qua được.
- Game offline, Lệ Tinh chỉ kiếm trong game, không có nạp tiền.

## 11. Tài nguyên và phần thưởng

Mục tiêu cân bằng: chơi hết bản đồ hiện tại, người chơi nâng được 4–5 nhân vật lên cấp 30, kỹ năng tối đa cấp 5, và tích được khoảng 78 lượt quay từ phần thưởng một lần (mục 11b). Hãy tính tổng tài nguyên toàn bản đồ và báo lại tôi để kiểm tra.

| Tài nguyên | Dùng để | Nguồn chính |
| --- | --- | --- |
| Xu Aether | Mọi loại nâng cấp, mua ở cửa hàng | Mọi quái, rương |
| Ký Ức Mảnh Hồn (bậc 1/2/3 = 100/500/2000 EXP) | Tăng cấp nhân vật | Quái, rương, gacha 3★ |
| Tinh Thể Nguyên Tố (7 loại) | Đột phá cấp 10 và 20 (mốc sau mở khi nâng giới hạn) | Tinh anh và boss cùng nguyên tố |
| Dấu Ấn Vận Mệnh (7 loại × 3 bậc) | Nâng kỹ năng, cây vận mệnh | Quái thường bậc 1, tinh anh bậc 2, boss bậc 3 |
| Lõi Ma Biến | Nâng kỹ năng cấp cao | Chỉ boss |
| Lệ Tinh | Gacha | Rương lần đầu, nhiệm vụ, thành tựu, cốt truyện |
| Vé Ước Nguyện | Gacha | Mốc cốt truyện, nhiệm vụ tuần, cửa hàng Bụi Sao |
| Bụi Sao | Đổi vé, Tinh Thể | Nhân vật trùng |
| Hộp Bí Kỹ | Hồi Điểm Bí Kỹ | Vật phá được trên map, nhiệm vụ ngày |

Phần thưởng mỗi lần thắng (cộng theo số quái trong trận):

| Loại quái | Xu Aether | EXP | Dấu Ấn Vận Mệnh | Tinh Thể Nguyên Tố | Lần hạ đầu tiên |
| --- | --- | --- | --- | --- | --- |
| Thường | 20–40 | 1 Ký Ức bậc 1 (60%) | 1 bậc 1 (25%) | 1 (3%) | Không |
| Tinh anh | 200–300 | 2 Ký Ức bậc 2 | 1–2 bậc 2 | 1 (40%) | 20 Lệ Tinh |
| Boss | 1500 | 3 Ký Ức bậc 3 | 2 bậc 3 | 3–4 theo nguyên tố boss | 100 Lệ Tinh + 1 Lõi Ma Biến |

- Rương (Lệ Tinh chỉ có ở lần mở đầu tiên): thường 5, quý 10, giải đố 20, kèm xu và Ký Ức.
- Mỗi chương hoàn thành: 400 Lệ Tinh + 5 Vé Thường + 3 Vé Giới Hạn.
- Hồi quái: quái thường hồi khi rời khu; tinh anh hồi mỗi ngày (theo đồng hồ máy); boss nhận đủ thưởng 3 lần mỗi ngày, sau đó chỉ cho xu.
- Tạo bảng chi phí lên cấp 1–30, đột phá và nâng kỹ năng (tối đa cấp 5), khớp với mục tiêu cân bằng ở trên. Đi theo cốt truyện và dọn khu bình thường thì đội miễn phí đủ cấp khuyến nghị cho boss mà không cần cày lại quá 15 phút.

## 11b. Nhiệm vụ hàng ngày, hàng tuần và kinh tế lượt quay

Mục tiêu: người chơi không nạp tiền có khoảng 78 lượt quay từ nội dung một lần và khoảng 32 lượt mỗi tháng từ nhiệm vụ. Như vậy chắc chắn có Celestine (tối đa 180 lượt) trong khoảng 4–5 tháng (Vé Thường không dùng được cho banner giới hạn), trung bình 1 nhân vật 5★ mỗi 2 tháng.

Nhiệm vụ hàng ngày (mở sau Chương 1, làm mới 4:00 sáng giờ máy). Mỗi nhiệm vụ cho điểm Hoạt Động, tổng 500 điểm:

| Nhiệm vụ | Điểm Hoạt Động |
| --- | --- |
| Đăng nhập | 100 |
| Thắng 3 trận | 100 |
| Hạ 1 quái tinh anh hoặc boss | 100 |
| Phá vỡ khiên quái 5 lần | 100 |
| Dùng Bí Kỹ 2 lần | 50 |
| Nâng cấp nhân vật hoặc kỹ năng 1 lần | 50 |

Mốc thưởng Hoạt Động: 100 điểm 10 Lệ Tinh, 200 điểm 15, 300 điểm 20, 400 điểm 25, 500 điểm 30 (kèm xu, Ký Ức, 1 Hộp Bí Kỹ). Tổng 100 Lệ Tinh mỗi ngày.

Nhiệm vụ hàng tuần (làm mới sáng thứ Hai): đủ 500 Hoạt Động trong 5 ngày, hạ boss 3 lần, thắng 30 trận. Hoàn thành cả 3: 160 Lệ Tinh + 1 Vé Giới Hạn + 1 Vé Thường.

Phần thưởng một lần cho người mới: đăng nhập 7 ngày đầu tổng 10 Vé Thường; quà mở Gacha 10 Vé Giới Hạn; thành tựu tổng 800 Lệ Tinh; khám phá 100% mỗi khu 160 Lệ Tinh.

| Nguồn | Kiểu | Lượt quay quy đổi |
| --- | --- | --- |
| Cốt truyện 4 chương (400 Lệ Tinh + 8 vé mỗi chương) | Một lần | 42 |
| Quà người mới (7 ngày + mở Gacha) | Một lần | 20 |
| Thành tựu, khám phá 100% | Một lần | 9 |
| Boss, tinh anh lần đầu, rương | Một lần | 7 |
| Nhiệm vụ ngày (100 Lệ Tinh × 30 ngày) | Mỗi tháng | 19 |
| Nhiệm vụ tuần (× 4,3 tuần) | Mỗi tháng | 13 |
| Cửa hàng Bụi Sao | Mỗi tháng | Tối đa 10 |

Chống chỉnh giờ: nếu giờ máy lùi so với lần lưu gần nhất, không làm mới nhiệm vụ cho tới khi giờ vượt mốc cũ. Viết script kiểm tra tự cộng mọi nguồn trong dữ liệu và so với bảng này.

## 12. Đồ họa 2D với Blender và Krita

Mọi hình trong game là 2D. Blender dùng để dựng mẫu 3D rồi render ra sprite 2D; Krita để vẽ tay chân dung, tranh, hiệu ứng, tileset. Bạn không vẽ thay tôi được, nên hãy làm:

1. Bảng thông số hình cho từng nhân vật, quái (`art_specs/<id>.md`): mã màu, mô tả dáng, trang phục, vũ khí, danh sách animation và số khung hình.
2. Script Python cho Blender (`tools/blender/render_sprites.py`): camera trực giao, ánh sáng cố định, shader hoạt hình (Shader to RGB + Color Ramp), viền đen (Freestyle hoặc Solidify lật pháp tuyến), render từng hành động ra PNG nền trong suốt theo 8 hướng, rồi ghép thành sprite sheet. Chạy bằng dòng lệnh: `blender -b file.blend -P render_sprites.py -- --character ignar`
3. Hướng dẫn Krita (`docs/KRITA_PIPELINE.md`): kích thước canvas, lớp, cách làm hoạt ảnh hiệu ứng bằng Animation Docker, xuất chuỗi PNG, quy tắc đặt tên.
4. Công cụ nhập asset trong Godot (`tools/import_assets`): tự tạo SpriteFrames từ sprite sheet theo tên file, để tôi chỉ cần thả file vào thư mục.
5. Hình tạm cho mọi thứ còn thiếu để game luôn chạy.

| Loại | Kích thước | Công cụ | Nội dung |
| --- | --- | --- | --- |
| Nhân vật ngoài map | 128×128 px/khung, 8 hướng | Blender | Đứng, chạy, lướt, Đòn Mở Màn, Bí Kỹ; 4–8 khung mỗi hành động |
| Nhân vật trong trận | 512×512 px/khung, nghiêng 3/4 | Blender + Krita sửa nét | Đứng, đánh thường, chiến kỹ, tuyệt kỹ, bị đánh, ngã, thắng |
| Chân dung hội thoại | 1024×1024 | Krita | 3 biểu cảm: bình thường, vui, nghiêm |
| Tranh gacha, cắt cảnh tuyệt kỹ | 2048×1152 | Krita | Màn nhận nhân vật, cắt cảnh tuyệt kỹ |
| Hiệu ứng kỹ năng | 256–1024 px/khung, 8–16 khung | Krita + particle Godot | Màu theo nguyên tố |
| Quái thường / tinh anh / boss (trong trận) | 256 / 384 / 768 px | Blender hoặc Krita | Boss có hình riêng mỗi giai đoạn |
| Tileset bản đồ | ô 64×64 px | Krita | Mỗi khu 1 bộ ô + đồ trang trí |

Quy tắc đặt tên: `<loại>_<id>_<hành động>_<hướng>_<khung>.png`, ví dụ `map_ignar_run_se_03.png`. Thư mục: `assets/characters/<id>/` gồm các thư mục con map, battle, portrait, splash, vfx.

## 13. Kiến trúc code Godot

```text
res://
  autoload/      GameState, SaveManager, EventBus, SceneRouter, GachaManager, AudioManager, QuestManager
  data/          characters/ skills/ enemies/ encounters/ banners/ loot_tables/ quests/ dialogue/
  scenes/
    overworld/   map, rooms, player, overworld_enemy, interactables
    battle/      battle_scene, battle_unit, turn_queue, skill_executor, battle_ui
    ui/          title, character_select, team, character_detail, gacha, inventory, quests, dialogue_box
  systems/       stats, damage_calc, status_effects, enemy_ai, loot, progression, economy_report
  assets/        characters/ enemies/ tilesets/ vfx/ ui/ audio/
  tools/         blender/ import_assets/
  tests/
  docs/          GAME_SPEC.md, PROGRESS.md, DESIGN_NOTES.md, CHARACTERS.md, KRITA_PIPELINE.md
```

- Dữ liệu bằng Resource: CharacterData, SkillData, EnemyData, EncounterData, BannerData, LootTable, StatusEffectData, QuestData. Kỹ năng là danh sách hiệu ứng ghép được (sát thương, hồi máu, khiên, buff/debuff, kéo lượt, triệu hồi, hồi năng lượng). Chỉ Đặc tính đặc biệt mới viết script riêng, kế thừa lớp TalentScript.
- Trận đánh là state machine: Bắt đầu → Tính lượt → Lượt ta / Lượt quái → Xử lý hiệu ứng → Kiểm tra thắng thua → Thưởng.
- EventBus phát tín hiệu (turn_started, damage_dealt, weakness_broken, ultimate_used, unit_died, battle_won...) để Đặc tính, Tinh Mệnh và nhiệm vụ ngày gắn vào.
- Map và trận là 2 scene riêng; GameState giữ trạng thái map (vị trí, quái đã hạ, rương đã mở) khi chuyển qua lại.
- Lưu game JSON trong user://: 3 ô lưu + tự lưu ở phòng nghỉ, có số phiên bản để nâng cấp file save sau này.
- RNG của gacha và trận dùng RandomNumberGenerator có seed lưu lại để tái hiện lỗi.
- Hội thoại bằng JSON: người nói, chân dung, biểu cảm, câu thoại, lựa chọn, sự kiện kích hoạt.
- Test (GUT hoặc script riêng): công thức sát thương, thứ tự lượt, bảo hiểm gacha (giả lập 1.000.000 lượt), bảng rơi đồ, kinh tế lượt quay.
- 60 FPS trên máy tầm trung; object pool cho hiệu ứng và số sát thương bay.

## 14. Lộ trình 14 phase

Mỗi phase có file prompt riêng (PHASE_01.md đến PHASE_14.md). Khi được giao một file PHASE, chỉ làm đúng phase đó. Làm theo thứ tự; Phase 13 (đồ họa) có thể làm song song từ sau Phase 6.

| Phase | Nội dung | Xong khi |
| --- | --- | --- |
| 1 | Khung dự án, lời dẫn, chọn nam/nữ | Chạy được, chọn nam/nữ, đặt tên, vào phòng trống |
| 2 | Di chuyển và phòng kiểu Soul Knight | Đi qua 3–4 phòng mượt, cửa khóa/mở, minimap |
| 3 | Quái trên map và chuyển vào trận | Ưu Thế, Phục Kích, thắng ngay quái yếu; quay về map đúng trạng thái |
| 4 | Lõi trận đánh theo lượt (tối đa 4 nhân vật) | 4 nhân vật mẫu đánh 3 quái mẫu, test công thức đạt |
| 5 | Nguyên tố, khiên, phá vỡ, hiệu ứng | Test đủ 7 hiệu ứng phá vỡ và buff/debuff |
| 6 | Hệ thống kỹ năng + nhân vật chính + 4 nhân vật miễn phí | 5 nhân vật dùng đủ 2 kỹ năng map, 3 kỹ năng trận, Đặc tính |
| 7 | 20 nhân vật còn lại | Phòng thử chọn bất kỳ 4 người, mọi Đặc tính chạy đúng |
| 8 | Quái thường, tinh anh, boss | Đánh được từng boss qua đủ giai đoạn |
| 9 | Tiến trình: cấp 30, đột phá, kỹ năng, Tinh Mệnh, đội hình | Nâng 1 nhân vật từ cấp 1 lên 30 qua giao diện |
| 10 | Tài nguyên, rơi đồ, nhiệm vụ ngày/tuần | Báo cáo kinh tế khớp mục 11 và 11b |
| 11 | Gacha 2 banner, cửa hàng Bụi Sao | Giả lập 1.000.000 lượt khớp tỉ lệ |
| 12 | Bản đồ Pháo Đài Vọng Tinh + cốt truyện | Chơi hết Mở đầu → Chương 4, nhận đủ 4 nhân vật miễn phí |
| 13 | Đồ họa Blender/Krita, nhập asset | Render thử ra sprite sheet, Godot tự nhận |
| 14 | Lưu/tải, âm thanh, cảm ứng, cân bằng, xuất bản | Bản Windows chạy trọn vẹn, lưu/tải đúng |

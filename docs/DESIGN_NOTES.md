# Ghi chú thiết kế

Các chỗ đặc tả chưa rõ hoặc có thể hiểu nhiều cách, kèm phương án đã chọn. Ghi theo phase.

## Phase 1

### Điểm chưa rõ / mâu thuẫn và phương án chọn

1. **Lưu game ở Phase 1.** Nút "Tiếp tục" cần biết đã có save hay chưa, nhưng hệ lưu đầy đủ nằm ở Phase 14.
   → Làm SaveManager tối thiểu: JSON có số phiên bản, ô tự lưu (slot 0) + chỗ cho 3 ô tay (1–3). Tự lưu ngay khi xác nhận nhân vật chính để "Tiếp tục" dùng được ngay. Chọn ô, giao diện ô lưu, chuyển đổi save cũ để Phase 14.
2. **Lời dẫn chỉ nhắc 6 nguyên tố**, trong khi game có 7 (Hồn ở phần "Bổ sung").
   → Giữ nguyên văn lời dẫn, thêm trang 4 nói Hồn là nguyên tố thứ 7 và nhân vật chính tỉnh dậy, nối thẳng vào màn chọn nhân vật.
3. **"Chữ chạy từng dòng"**: không nói chia trang.
   → 4 trang theo đoạn văn gốc; mỗi trang các câu hiện lần lượt kiểu đánh máy rồi mờ đi. Bấm chuột/Enter/chạm để hiện hết câu đang chạy hoặc sang câu kế; Esc hoặc nút "Bỏ qua" để bỏ hết. Nhịp chữ nằm trong `data/dialogue/intro.json`.
4. **Đổi giới tính sau khi đã gõ tên.**
   → Chưa tự gõ tên (hoặc tên đang là Kael/Kaela) thì đổi giới tính sẽ đổi tên mặc định theo; đã gõ tên riêng thì giữ nguyên. Tên rỗng khi xác nhận → dùng tên mặc định. Tên cắt khoảng trắng hai đầu, tối đa 12 ký tự.
5. **Vào lại game bằng "Bắt đầu" khi đã có save.** Hiện tại ghi đè ô tự lưu không hỏi. TODO Phase 14: hỏi xác nhận.
6. **Ngôn ngữ.** Mặc định `vi` (lưu trong `user://settings.cfg`, không theo máy). File dịch có sẵn cột `en`.
7. **Cài đặt theo máy hay theo save?** Âm lượng, ngôn ngữ là cài đặt theo máy → lớp tĩnh `UserSettings` (không thêm autoload ngoài danh sách mục 13).
8. **Kích thước cửa sổ.** Độ phân giải gốc 1920×1080 như đặc tả; cửa sổ mở ở 1600×900 cho vừa màn hình laptop (stretch canvas_items nên hình không đổi). Đổi trong Cài đặt ở Phase 14.
9. **Phím tay cầm** (đặc tả chỉ nói "cần trái"): A = tương tác, B = lướt, X = Đòn Mở Màn, Y = Bí Kỹ, Start = menu, D-pad lên/phải/xuống/trái = đổi nhân vật 1–4. Phím bàn phím dùng mã vật lý để WASD đúng chỗ trên mọi kiểu bàn phím.
10. **Nguyên tố/vận mệnh trong CharacterData** tạm là `StringName` (`soul`, `destruction`); Phase 5/6 đổi sang enum.
11. **Phòng thử Phase 1**: Esc về thẳng màn tiêu đề (chưa có menu tạm dừng).

### Ghi chú cho các phase sau (đã kiểm tra số liệu đặc tả)

- Mục 8: đếm lại bảng 24 nhân vật — mỗi nguyên tố 3–4 người, mỗi vận mệnh 3–4 người, 7 nhân vật 5★ thường phủ đủ 7 nguyên tố và 7 vận mệnh. Khớp.
- Mục 11b: 42 + 20 + 9 + 7 = 78 lượt một lần. Khớp. Riêng dòng "Boss, tinh anh lần đầu, rương = 7 lượt" nghĩa là ≈1120 Lệ Tinh; 4 boss chỉ cho 400 → tinh anh lần đầu + rương phải đủ ≈720 Lệ Tinh. Phase 10/12 sẽ đặt số rương cho khớp.
- Mục 11b: trong 78 lượt một lần, chỉ khoảng 48 lượt dùng được cho banner giới hạn (Vé Thường không dùng được). Mỗi tháng ≈32 lượt dùng cho banner giới hạn (Lệ Tinh ngày + Lệ Tinh tuần + vé giới hạn tuần + 5 vé cửa hàng). 180 − 48 = 132 → ≈4,1 tháng có chắc Celestine. Khớp mục tiêu 4–5 tháng.
- Nhiệm vụ tuần "làm mới sáng thứ Hai": hiểu là 4:00 sáng thứ Hai, cùng giờ với nhiệm vụ ngày. Cửa hàng Bụi Sao làm mới 4:00 ngày 1.

## Phase 2

1. **Bố cục map.** Mỗi phòng nằm trên một ô lưới, khoảng cách tâm 40 ô gạch (64 px/ô). Hai phòng kề nhau trên lưới, cùng mở cửa ở phía đối diện (`door_sides`) thì tự nối bằng hành lang thẳng rộng 3 ô. Map thử: nghỉ (0,0) → chiến đấu (1,0) → rương (2,0); boss (1,−1) phía trên phòng chiến đấu.
2. **Phòng mẫu dùng lại được.** Phòng mẫu chừa lỗ cửa ở cả 4 cạnh; lúc chạy phòng tự bịt tường các phía không nối. Nhờ vậy 1 file phòng mẫu dùng được cho nhiều vị trí trên map. Phase 12 dựng phòng thủ công bằng cách nhân bản file mẫu rồi vẽ thêm ô.
3. **Khi nào tính là "đã vào phòng".** Vào phòng tính khi người chơi đi sâu quá 2 ô từ tường (để cửa đóng sau lưng, không kẹt người trong cửa). Rời phòng chỉ tính khi ra khỏi cả khung phòng, nên đứng sát cửa vẫn tính là trong phòng.
4. **Đi 8 hướng.** Di chuyển theo góc tự do của cần analog (mượt kiểu Soul Knight); hướng nhìn/hoạt ảnh làm tròn về 8 hướng.
5. **Lướt.** 0,16 giây, tốc 1450 px/s (≈3,6 ô), hồi 0,7 giây, bất tử 0,24 giây. Lướt không xuyên tường; "xuyên rào Ma Biến" là của Bí Kỹ nhân vật chính (Phase 6).
6. **Cảm ứng trên PC.** Bật `emulate_touch_from_mouse` để thử joystick bằng chuột. Nút cảm ứng phát InputEventAction thật, nên mọi code đọc phím vẫn dùng như cũ. Lưu ý cho Phase 3: Đòn Mở Màn bằng chuột trái phải bắt trong `_unhandled_input`, để bấm vào nút giao diện không tính là chém.
7. **Phím debug F8** (`debug_clear_enemies`) chỉ chạy ở bản debug.
8. **Tên lớp.** Godot 4.7 đã có lớp gốc `VirtualJoystick`, nên joystick của game tên là `TouchJoystick`.
9. **Lớp va chạm:** 1 world, 2 player, 3 enemy, 4 interactable (`systems/physics_layers.gd`).

## Phase 3

1. **Một nhóm quái = một con đại diện trên map.** Mỗi `OverworldEnemy` mang một `EncounterData` (có thể nhiều đợt). Chấm nhỏ dưới chân cho biết tổng số quái trong trận.
2. **So cấp để thắng ngay:** lấy **cấp cao nhất** trong trận so với **cấp đội**. Hơn ≥10 cấp và người chơi chém trúng trước thì thắng ngay. Bị quái chạm/vồ thì vẫn vào trận như thường. Cấp đội tạm là `GameState.team_level` (Phase 9 tính trung bình cấp 4 người).
3. **Ưu tiên kiểu mở trận:** sự kiện nào xảy ra trước thì tính trước. Một lần chém chỉ mở 1 trận (chọn quái gần nhất trong quạt). Đang lướt thì bất tử: không bị tính chạm, không bị vồ trúng.
4. **Không lưu riêng trạng thái cửa:** cửa suy ra từ quái còn lại. Quay về giữa phòng còn quái thì cửa tự khóa lại (không hiện lại thông báo).
5. **"Phòng nghỉ gần nhất"** = gần theo khoảng cách tới chỗ thua, ưu tiên phòng đã khám phá.
6. **Chống bị kéo vào trận liên tục:** vừa vào map quái đứng yên 1,5 giây; vừa từ trận về người chơi bất tử 1 giây.
7. **Phần thưởng thắng ngay/thắng trận tạm:** 30 Xu mỗi quái, Ký Ức bậc 1 = làm tròn lên 60% số quái (mức giữa bảng mục 11). Chưa cộng vào túi đồ (Phase 9–10).
8. **Đòn Mở Màn bằng chuột** bắt trong `_unhandled_input` và chém về phía con trỏ; bấm lên nút giao diện/nút cảm ứng không tính là chém.

## Phase 4

1. **Thứ tự lượt lưu "quãng đường" thay vì GTHĐ.** Mỗi đơn vị chạy 10000; GTHĐ = quãng còn lại / Tốc Độ. Nhờ vậy đổi Tốc Độ giữa trận tự đúng. Kéo lượt 50% = trừ 5000 quãng đường (không âm); trì hoãn 25% = cộng 2500.
2. **Hòa GTHĐ:** ai nhanh hơn đi trước → phe ta trước quái → ai vào trận trước.
3. **Ưu Thế / Phục Kích:** đặt quãng đường của cả phe về 0 ở đầu trận, nên cả phe đi liền một lượt theo thứ tự Tốc Độ, sau đó về nhịp bình thường.
4. **Đợt sau:** quái mới vào với quãng 10000, phe ta giữ nguyên tiến độ lượt.
5. **Năng lượng:** vào trận 50%; đánh thường +20, chiến kỹ +30, mỗi lần bị trúng đòn +10, Tuyệt kỹ trừ hết rồi +5 (đều nhân Hiệu Suất Hồi Năng Lượng). Năng lượng tối đa theo từng nhân vật.
6. **Chen lượt Tuyệt kỹ:** đang chờ người chơi chọn thì Tuyệt kỹ chạy ngay; đang trong hành động khác thì chạy ngay sau hành động đó. Không tốn lượt, không làm trôi thời gian. Mục tiêu đã chết lúc chạy thì tự chọn lại.
7. **Công thức:** làm tròn xuống, tối thiểu 1 nếu hệ số > 0. Kháng kẹp trong [−100%, 100%], giảm phòng thủ kẹp trong [0, 100%]. Hệ số phá vỡ chỉ áp lên mục tiêu có thanh khiên (quái); nhân vật phe ta luôn 1,0. Phase 4 coi quái luôn còn khiên (0,9).
8. **Hồi máu:** (Chỉ số × hệ số + số cố định) × (1 + Tăng Trị Liệu).
9. **Chỉ số theo cấp:** dữ liệu ghi bảng cấp 1 và cấp 80; Máu/Tấn Công/Phòng Thủ nội suy tuyến tính, các chỉ số khác giữ như cấp 1. Phase 9 cộng thêm thưởng đột phá.
10. **Cấp nhân vật trong trận:** tạm lấy `GameState.team_level` cho cả đội (Phase 9 dùng cấp riêng).
11. **Tăng Tốc x2:** dùng `Engine.time_scale = 2` trong màn trận (trả về 1 khi rời màn).
12. **Bấm vào quái = chọn và ra đòn luôn** (như thể loại). Muốn xem trước thì dùng ←/→ để đổi mục tiêu, Space để ra đòn; bấm lại nút kỹ năng đang chọn cũng là ra đòn.
13. **Điểm Chiến Kỹ khi Tự Động:** chiến kỹ gây sát thương chỉ dùng khi còn ≥2 điểm (chừa 1 cho người hồi máu). Tuyệt kỹ hồi máu chỉ dùng khi có người dưới 75% máu.
14. **Tên enum:** `BattleUnit.Faction` (không đặt `Side` vì trùng enum có sẵn của Godot).

## Phase 5

1. **Thời điểm hiệu ứng:** sát thương theo lượt, mất lượt (Đóng Băng) xử lý ĐẦU lượt của người mang; số lượt trừ ở CUỐI lượt. Gắn giữa lượt người khác thì lượt đó không bị tính. Vd. Thiêu Đốt 2 lượt = gây sát thương 2 lần.
2. **Hồi khiên:** đầu lượt kế tiếp của quái đã bị Phá Vỡ, khiên hồi đầy rồi quái vẫn hành động bình thường (trừ khi đang Đóng Băng).
3. **Đòn phá vỡ:** sát thương của chính đòn làm vỡ khiên vẫn tính hệ số 0,9 (khiên còn lúc ra đòn); sau đó mới trừ khiên → Phá Vỡ.
4. **Sát thương phá vỡ** = Mức phá vỡ theo cấp (50 + 8 × (cấp − 1)) × (1 + Hiệu Ứng Phá Vỡ) × hệ số nguyên tố (Lửa 2, Phong 1,5, Nước/Sét/Độc 1, Mộc/Hồn 0,5; Mộc/Hồn bù lại bằng trì hoãn) × hệ số khiên (0,5 + khiên tối đa / 120), rồi qua phòng thủ, kháng, dễ tổn thương. Số liệu ở `break_config.tres`.
5. **Hiệu ứng phá vỡ** có tỉ lệ gốc 150%, nên quái có Kháng Hiệu Ứng dưới 33% luôn dính. Sát thương của hiệu ứng không bạo kích, không cộng Tăng sát thương, nhưng vẫn qua phòng thủ, kháng, khiên.
6. **Số liệu từng hiệu ứng** (× mức phá vỡ): Thiêu Đốt 1,0/lượt; Điện Giật 2,0/lượt; Phong Cắt 1,0/tầng/lượt (tối đa 5 tầng, mỗi lần Phá Vỡ +1 tầng); Nhiễm Độc 10% máu tối đa/lượt, trần 3,0; Đóng Băng tan 1,0; Trói Rễ đòn kế tiếp 0,6 (dùng một lần, tối đa 1 lượt).
7. **Kháng nguyên tố** chỉ áp lên quái; phe ta mặc định 0 (Phase 6–8 có thể thêm buff kháng).
8. **Ưu Thế trừ 25% khiên** không bao giờ đủ làm Phá Vỡ ngay đầu trận.
9. **Phòng thử** ép nguyên tố cho cả đội (`BattleController.debug_element_override`), không ảnh hưởng trận thường.

## Phase 6

1. **Kỹ năng = danh sách hiệu ứng chạy theo thứ tự.** Sát thương được tính theo trạng thái khiên/buff ngay lúc hiệu ứng đó chạy, nên đặt buff trước sát thương nếu muốn buff có tác dụng ngay.
2. **Giảm Khiên Điểm Yếu nằm trong DamageEffect** (mỗi đòn sát thương mang lượng giảm khiên riêng), không nằm ở SkillData.
3. **Khiên:** mỗi đơn vị chỉ giữ khiên lớn nhất (không cộng dồn), hết khi hiệu ứng khiên hết lượt hoặc bị đánh vỡ. Sát thương theo lượt không bị khiên chặn.
4. **Tinh Mệnh 3 và 5** đặc tả kiểu thể loại thường là "+2 cấp kỹ năng"; cấp kỹ năng làm ở Phase 9, nên tạm dùng "+15% hệ số". Phase 9 có thể đổi sang +cấp mà không đổi ý nghĩa.
5. **Đòn phụ / phản công** chạy sau hành động hiện tại, không làm trôi thời gian, không cho/không trừ Điểm Chiến Kỹ; phản công không kích hoạt phản công khác.
6. **Bí Kỹ "trận kế tiếp"** chỉ có tác dụng nếu người dùng Bí Kỹ có trong đội lúc vào trận; dùng lại cùng Bí Kỹ không cộng dồn. Bí Kỹ "đánh dấu quái" (Kiri) áp khi vào trận với đúng nhóm quái đó.
7. **Bước Hư Ảnh** (theo mẫu mục 7) vừa là tiện ích khám phá, vừa kéo lượt đầu 25% ở trận kế tiếp → xếp vào kiểu khám phá.
8. **Rào Ma Biến** là vật cản thứ 8, không gắn nguyên tố: chỉ lướt qua bằng Bước Hư Ảnh. Hốc rào Ma Biến có Hộp Bí Kỹ bên trong để không bị kẹt khi hết điểm.
9. **Điểm Bí Kỹ** bắt đầu đầy (5), lưu trong save.
10. **Trọng số bị nhắm** = trọng số vận mệnh × (1 + AGGRO). Khiêu Khích chỉ ép đòn đơn/lan; đòn toàn bộ vẫn trúng cả đội.
11. **Dòng Chảy Ân Cần (Mira)** kích hoạt khi máu đồng minh vừa xuống dưới 30% vì bất kỳ lý do gì (cả sát thương theo lượt), mỗi đồng minh 1 lần (E2: 2 lần).
12. **Đặc tính tránh trùng cơ chế:** tích tầng khi Phá Vỡ (Lữ khách), hồi khẩn cấp (Mira), hoàn Điểm Chiến Kỹ (Kiri), phản công (Garren), kích nổ sát thương theo lượt (Nyx).

## Phase 7

1. **Một nguồn thiết kế:** `roster_design.py` chứa chữ (tiểu sử, mô tả kỹ năng, Tinh Mệnh); `build_roster.py` chứa số liệu kỹ năng và sinh `.tres` + file dịch; `write_character_doc.py` sinh `docs/CHARACTERS.md` và tự kiểm tra trùng cơ chế / chia Bí Kỹ / khớp mục 8. Chỉnh số thì sửa cả mô tả trong `roster_design.py` rồi chạy lại hai script.
2. **Cách đo cân bằng:** 10 lượt của nhân vật, cấp 30, Tinh Mệnh 0, 8 seed. Đội hỗ trợ (Lữ khách, Mira, Garren; trùng thì thay Nyx) chỉ đánh thường và không dùng Tuyệt kỹ, để không tranh Điểm Chiến Kỹ — trước khi làm vậy kết quả dao động quá mạnh. Điểm: sát thương bản thân (Hủy Diệt, Săn Bắn, Tri Thức), tổng sát thương cả đội quy về 1000 Giá trị Hành Động (Hòa Hợp, Hư Vô), lượng hồi kể cả phần tràn (Trù Phú), khiên + gánh thay + 50% sát thương (Bảo Hộ). Lữ khách không nằm trong phép so (không có trong banner).
3. **Thay đổi so với bản thiết kế đã duyệt (do cân bằng):** hệ số kỹ năng của Ignar, Marisol, Raiko, Zephyra, Vesper, Sylvaine, Orrin, Celestine được chỉnh qua 8 lượt; mô tả trong `docs/CHARACTERS.md` đã cập nhật theo. Vesper chỉ giảm khiên mục tiêu chính (Phá Vỡ hệ Độc gắn Nhiễm Độc theo % máu nên phá khiên cả 3 quái thì mạnh quá). Wisp E1 đổi thành +20% Chính Xác Hiệu Ứng; Lời Thì Thầm của Wisp áp ở cuối lượt quái (áp đầu lượt thì bị mất khi quái kết thúc lượt).
4. **Vật triệu hồi:** nằm trong hàng lượt nhưng không thuộc `allies` (không tính vào giới hạn 4, không làm thua, quái và kỹ năng "cả đội" không tính tới). Hết số lượt thì biến mất.
5. **"+20% hệ số" của Kestrel** nghĩa là cộng 20 điểm phần trăm vào hệ số (130% → 150% → 170% → 190%).
6. **Chia sát thương (Marisol)** áp cho đòn trực tiếp của quái, sau khi tính sát thương, trước khiên của người nhận; phần chuyển sang Marisol vẫn bị khiên của Marisol chặn. Đỡ thay (Aldric) đổi luôn người nhận.
7. **Tiếng Anh:** 20 nhân vật mới tạm dùng chữ tiếng Việt ở cột `en` (Phase 14 dịch).

## Phase 8

1. **AI quái = danh sách EnemyAction** (kỹ năng + trọng số + điều kiện + hệ số tình huống + cách chọn mục tiêu + báo trước), khai báo trong EnemyData. Tình huống nhân trọng số: máu bản thân < 50%, đã có quái phe mình bị hạ, vừa bị Phá Vỡ kể từ lượt trước, có đồng minh < 60% máu. Hành động `priority` đủ điều kiện thì dùng ngay (vd. Xạ Thủ bắn người Bị Ngắm, Bầy Ong gọi tổ, Quá Nhiệt). Dữ liệu cũ (`skills` + `skill_weights`) vẫn chạy, tự chuyển sang EnemyAction.
2. **Báo trước đòn mạnh:** mọi Tuyệt kỹ của quái (kind ULTIMATE) phải tích tụ (`charge_turns ≥ 1`), trừ đòn nhắm người đã bị đánh dấu (dấu chính là lời báo). Lượt tích tụ chỉ báo (biểu tượng "!" + tên đòn + số lượt trên đầu quái, vòng đỏ trên người sắp trúng, dòng nhắc cách ngắt). Đếm ngược kiểu lời nguyền (`act_while_charging`) thì vẫn hành động bình thường mỗi lượt. Quái bị Đóng Băng / mất lượt thì đếm ngược không giảm.
3. **Ngắt đòn:** `cancel_on_break` (Phá Vỡ trong lúc tích tụ) hoặc `cancel_damage_ratio` (tổng sát thương nhận trong lúc tích tụ, tính cả sát thương theo lượt). Kiểm tra sau mỗi hành động và sau sự kiện đầu lượt.
4. **Giai đoạn boss theo ngưỡng máu, một thanh máu:** máu dừng ở ngưỡng giai đoạn kế tiếp (không bỏ qua giai đoạn bằng một đòn lớn), chuyển giai đoạn ngay sau hành động đó: đổi điểm yếu, khiên tối đa, cộng chỉ số, bộ hành động mới, gỡ debuff, hồi đầy khiên, hủy đòn đang tích tụ, đổi nhạc, đoạn chuyển cảnh 1,6 giây (bấm để bỏ qua). Giai đoạn có ngưỡng âm do EnemyBehavior gọi (hạ hết phân thân); trước đó boss không thể ngã.
5. **Triệu hồi tính vào giới hạn 5 quái** (đếm quái còn sống, kể cả boss không bị nhắm được). Hết chỗ thì không gọi. Quái gọi ra không gọi tiếp (Ong Thợ là dữ liệu riêng) để tránh gọi vô hạn và vòng tham chiếu dữ liệu.
6. **Nổ khi chết** chạy như đòn phụ của quái đã ngã (không tốn lượt), sau hành động làm nó ngã. Trận đã thắng thì không nổ nữa.
7. **Sao chép / hút buff** chỉ lấy buff chỉ số hoặc hồi máu theo lượt; không lấy khiên, Khiêu Khích, bộ đếm dài hạn của Đặc tính (≥ 10 lượt). Buff lấy được giữ thêm 1 lượt (gắn trong lượt của chính quái).
8. **Phong Ấn** chỉ khóa Chiến kỹ; Tự Động tự chuyển sang Đánh thường. Nút Chiến kỹ ghi "bị Phong Ấn".
9. **Mức Khó** (`data/config/boss_hard_mode.tres`): máu +60%, Tấn Công +25%, Tốc Độ +8%, Chính Xác Hiệu Ứng +10%, khiên ×1,25; chỉ áp cho trận boss (payload `hard_mode`). Hệ số thưởng ×2 ghi sẵn cho Phase 10.
10. **Chỉ số quái** = đường cong "quái chuẩn" (Máu 90→900, Tấn Công 30→240 từ cấp 1→80) × hệ số từng loại. Cấp khuyến nghị: boss Chương 1/2/3 = cấp boss + 2 (10/18/26), trùm cuối 30. Nhân vật chưa có thưởng đột phá (Phase 9) nên số liệu sẽ cân lại ở Phase 14.
11. **Lõi Lò:** Quá Nhiệt dùng khi có ≥ 4 tầng Nhiệt và báo trước 1 lượt; lượt sau tích lên 5 thì nổ. Phá Vỡ lúc đó vừa hủy đòn vừa trừ 3 tầng. Tay máy là mục tiêu phụ (Nạp Nhiệt +1 tầng); sang giai đoạn 2 thì dựng lại tay máy đã hỏng.
12. **Kẻ Nuốt Mảnh Hồn:** GĐ2 (≤ 66%) tách 3 phân thân, mỗi phân thân ngã làm bản thể mất 8% máu tối đa; hạ hết thì GĐ3. GĐ3 xóa 1 Điểm Chiến Kỹ đầu mỗi lượt của boss; Nuốt Hồn đếm ngược 2 lượt, ngắt bằng 10% máu tối đa.
13. **Nhạc tạm** sinh bằng code (`systems/placeholder_music.gd`, vòng lặp sóng vuông/tam giác/răng cưa), mỗi boss và mỗi giai đoạn một bài. AudioManager phát qua bus Music; Phase 14 thay file thật theo id.
14. **Biến thể quái thường** có id `<họ>_<nguyên tố>`; quái cũ của Phase 3–7 (`warp_sprout`, `wandering_shade`, `rusted_knight`, bù nhìn, Quái Thử Sức) giữ nguyên làm dữ liệu test.

## Phase 9

1. **Giới hạn cấp một chỗ:** `GameConfig.MAX_LEVEL = 30`. Bảng EXP, đột phá, chi phí kỹ năng nằm ở `data/config/progression.tres` (sinh bằng `tools/data_builder/build_progression.py`); bảng EXP có sẵn tới cấp 80, mốc đột phá 30–70 có dữ liệu nhưng tự khóa khi giới hạn mới vượt MAX_LEVEL.
2. **Chỉ số theo cấp giữ công thức cũ** (nội suy tuyến tính cấp 1 → 80), đột phá chỉ nâng giới hạn cấp, không cộng chỉ số riêng – để giữ nguyên cân bằng Phase 7–8. "Bảng tăng trưởng" = bảng cấp 1 / cấp 80 trong CharacterData.
3. **EXP thừa ở giới hạn cấp bị bỏ;** nút "+1 cấp" / "Lên tới giới hạn" tự chọn Ký Ức (loại lớn trước, phần lẻ bù bằng loại nhỏ nhất đủ) để không phí nhiều. Nạp EXP tốn 0,1 Xu mỗi EXP.
4. **Cấp kỹ năng:** hệ số sát thương/hồi/khiên ×1,0 / 1,1 / 1,2 / 1,3 / 1,4; độ mạnh buff/debuff (điều chỉnh chỉ số, hồi máu theo lượt, sát thương theo lượt tính theo chỉ số) ×1,0 → 1,2. Đặc tính: áp cho sát thương/hồi/khiên do Đặc tính tạo trực tiếp, đòn phụ, và hiệu ứng Đặc tính/Tinh Mệnh gắn thẳng. Hiệu ứng Phá Vỡ không đổi theo cấp. Giới hạn cấp kỹ năng: chưa đột phá 2, đột phá 1 lần 4, 2 lần 5.
5. **Tinh Mệnh 3/5 giữ "+15% hệ số"** (không đổi sang +2 cấp kỹ năng) để không làm lệch cân bằng; hai thứ cộng dồn.
6. **Cây vận mệnh dùng chung theo vận mệnh** (mục 6: vận mệnh quyết định cây). Mỗi cây 6 nút chỉ số nhỏ (2 chỉ số × 3 bậc, bậc sau cần bậc trước) + 3 nút lớn (nút sau cần nút trước); bậc / nút lớn thứ n cần đột phá n − 1 lần. Bị động có điều kiện chạy trong `TracePassives` (năng lượng đầu trận, khiên đầu trận, sát thương khi máu thấp, sát thương lên quái có debuff, năng lượng khi Phá Vỡ, hồi mạnh hơn cho người dưới 50% máu).
7. **Tinh Mệnh nhân vật chính** = max(cấp lưu, số cờ `soul_shard_1..6`); Phase 12 đặt cờ theo cốt truyện. Nhân vật khác: `GameState.grant_character()` (Phase 11 gọi khi quay trùng), quá 6 thì báo `overflow`.
8. **Máu giữ giữa các trận** lưu dạng tỉ lệ (vì máu tối đa đổi theo cấp). Thắng: ghi máu cuối trận; thua: về phòng nghỉ với máu đầy; người đã ngã (0%) vào trận ở trạng thái ngã cho tới khi nghỉ / được hồi sinh / Bí Kỹ hồi máu. Phòng thử và test luôn đầy máu, không ghi lại.
9. **Cấp đội** (so với quái để thắng ngay) = trung bình cấp 4 người. `GameState.team_level` > 0 là cấp ép (phòng thử, phím debug F6/F7, test cũ).
10. **5 đội hình lưu sẵn;** đổi đội ở menu xong thì map nạp lại tại chỗ. Đội luôn 1–4 người, không trùng.
11. **Save v2:** thêm túi đồ, tiến trình, máu, đội hình; save v1 chuyển `team_level` cũ thành cấp từng nhân vật (tự coi như đã đột phá đủ).
12. **Lệnh debug:** nút "+ Tài nguyên (debug)" ở menu tạm dừng và túi đồ (bản debug), hàm `Progression.debug_grant_resources()`.

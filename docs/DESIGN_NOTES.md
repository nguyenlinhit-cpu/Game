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

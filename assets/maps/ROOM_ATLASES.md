# Tranh và cấu trúc từng phòng — v2

Bốn atlas trong `library/`, `vault/`, `furnace/`, `tower/` được tạo bằng công cụ image_gen tích hợp, tham chiếu phong cách `hub/hub_plaza.jpg`. Không ghi đè ảnh cũ. Mỗi atlas có 12 tranh khác nhau, xếp 4 cột × 3 hàng; game dùng 11/10/10/12 tranh cho 43 phòng. Thư Viện dùng ô cuối làm phòng boss để có sân rộng. Tọa độ hàng được đối chiếu với ảnh thực tế trong `room_architecture.gd` để không lấy nhầm phòng bên cạnh.

`tools/level_builder/room_architecture.gd` quy định khung sân, cánh phòng, hốc bên, vách ngăn, góc cắt và lõi máy giữa phòng. Builder dựng các ô va chạm, giữ đường đi liên thông và đặt nhân vật/vật phẩm trên sàn tới được. Kho có lối hẹp, sân hộ vệ cắt tám góc, phòng nghỉ có hốc, phòng boss Lò có lõi máy phải đi vòng. Mỗi phòng có `structure_id` và vùng `AtlasTexture` riêng.

Thứ tự lớp: ảnh phòng −20; cầu hành lang −10; tường/cửa trang trí −9; thực thể 5; cửa chiến đấu 6; người chơi 10. Việc thêm node sau người chơi không thể khiến nền che nhân vật nữa.

Prompt chung: Production 2D RPG ROOM ATLAS, exactly FOUR columns and THREE rows, 12 independent equally sized cells edge to edge, landscape. Reference supplied is STYLE ONLY: detailed overhead painted pixel fantasy environment, squared grid, short wall faces, cyan lamps, indigo shadows, ambient lighting matching the central hub. Each cell contains one complete different room with readable clear connected floor and four cardinal doors. Distinct room outlines and architecture, no repeated same rectangular arena, no people, enemies, UI, text, labels, numbers or watermark.

Danh sách phòng và prompt cụ thể: `room_atlas_prompts.json`. Hình Đỉnh Tháp dùng cùng prompt chung, với 12 cảnh theo thứ tự: entry pavilion; wind terrace with four buttresses; narrow astronomical treasury; asymmetric star courtyard; octagonal sentinel terrace; four-alcove celestial puzzle room; lookout bridge hall; diagonal two-wing terrace; stepped rift courtyard; eight-sided elite terrace; twin-nook rest pavilion; final boss arena. Ivory stone, gold celestial instruments, blue crystal lamps, lavender clouds and starry void.

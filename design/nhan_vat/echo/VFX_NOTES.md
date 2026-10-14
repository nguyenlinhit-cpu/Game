# Echo – bản nháp hoạt ảnh v1

Dùng 1a_clean.png đã bỏ bản sao vẽ sẵn. Bóng được ghép ở 40% độ mờ, trễ hai khung và nhập lại khi victory. Tuyệt kỹ giữ cả thân lẫn bóng ở hai khung cuối. Technique map biến mất từ khung 3.

Bản nháp 2D để duyệt. Chỉ hướng phải cho map. Mặt giữ từ concept, chưa tách hình dán để nhắm mắt/mở miệng trong trận. Down hiện khuỵu/gục; victory dùng cử chỉ gần ý brief, chưa đủ mọi thao tác cất vũ khí/tháo mặt nạ. Ánh sáng nhịp thở ở ngực/tóc chưa có lớp riêng cho idle. B2 cũ vẫn giữ trạng thái của bạn.

Nguồn yêu cầu đầy đủ: [ANIMATION_SPEC.md](ANIMATION_SPEC.md). Các PNG 1a_clean là bản dẫn xuất; không ghi đè 1a gốc.

Chạy từ gốc repo:

```bash
blender -b -noaudio -t 2 -P design/nhan_vat/echo/4_rig2d/rig_battle.py
blender -b -noaudio -t 2 -P design/nhan_vat/echo/4_rig2d/pixel_map.py
blender -b -noaudio -t 2 -P design/nhan_vat/echo/6_vfx/make_echo_vfx.py
```

Render lại sprite trước VFX để GIF ghép đúng bản. Không chép vào assets/.

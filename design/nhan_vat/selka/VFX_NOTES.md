# Selka – bản nháp hoạt ảnh v1

Dùng 1a_clean.png đã bỏ khói vẽ sẵn, giữ bản gốc. Gậy, xích và lư hương chuyển động riêng; tay áo có xương. Skill/ultimate đặt VFX lên đồng minh; vòng khói hồng-xanh và hoa hương.

Bản nháp 2D để duyệt. Chỉ hướng phải cho map. Mặt giữ từ concept, chưa tách hình dán để nhắm mắt/mở miệng trong trận. Down hiện khuỵu/gục; victory dùng cử chỉ gần ý brief, chưa đủ mọi thao tác cất vũ khí/tháo mặt nạ. Ánh sáng nhịp thở ở ngực/tóc chưa có lớp riêng cho idle. B2 cũ vẫn giữ trạng thái của bạn.

Nguồn yêu cầu đầy đủ: [ANIMATION_SPEC.md](ANIMATION_SPEC.md). Các PNG 1a_clean là bản dẫn xuất; không ghi đè 1a gốc.

Chạy từ gốc repo:

```bash
blender -b -noaudio -t 2 -P design/nhan_vat/selka/4_rig2d/rig_battle.py
blender -b -noaudio -t 2 -P design/nhan_vat/selka/4_rig2d/pixel_map.py
blender -b -noaudio -t 2 -P design/nhan_vat/selka/6_vfx/make_selka_vfx.py
```

Render lại sprite trước VFX để GIF ghép đúng bản. Không chép vào assets/.

"""Sprite pixel ngoài map của Ignar (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/ignar/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import default_frames, run, speed_lines  # noqa: E402


def frames(p, cfg):
    """Bộ chuẩn, riêng technique là cú lao: cúi người → lao tới (vệt gió) → trượt dừng."""
    seq = default_frames(p, cfg)
    dash = [p.compose(lean=2, head=(1, 0), body=(1, 0), back=(-1, 0), front=(2, 0), flaps=-1),
            p.compose(lean=2, head=(2, 0), body=(2, 0), back=(0, 0), front=(3, 0), flaps=-1)]
    for f in dash:
        speed_lines(f, cfg["spark"])
    seq["technique"] = [p.compose(lean=1, head=(0, 1), body=(0, 1), squint=True),  # cúi người
                        dash[0], dash[1], dash[0], dash[1],
                        p.compose(lean=-1, head=(-1, 0), front=(1, 0))]           # trượt dừng
    return seq

run({
    "id": "ignar",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12). Mắt #B8321C (đậm hơn #E8552B) để nhắm mắt không ăn vào đuôi tóc lửa.
    "keys": {"O": "#141018", "H": "#8E8A86", "F": "#E8552B", "S": "#E9B996", "E": "#B8321C", "R": "#C2402A",
             "A": "#2A2523", "B": "#C8A045", "I": "#5A5F66", "K": "#3A2A26", "M": "#FFB347", "W": "#5A3A28"},
    "eyes": ["#B8321C"], "skin": "#E9B996", "lid": "#141018",
    "head_ratio": 0.52,                                     # đầu gồm cả cán búa và nắm tay ngang cằm
    "flap_side": "left", "flap_rows": 9, "flap_width": 6,   # đầu búa sau lưng nhún theo nhịp (bên phải là nắm tay)
    "spark": "#FFB347",                                     # vệt tàn lửa khi lướt
    "frames": frames,
})

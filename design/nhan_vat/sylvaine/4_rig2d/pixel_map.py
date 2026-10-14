"""Sprite pixel ngoài map của Sylvaine (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/sylvaine/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "sylvaine",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12). Tóc nâu ô-liu theo concept (#6B8F4A trong bảng quá xanh,
    # lẫn vào áo choàng lá ở cỡ 32 px).
    "keys": {"O": "#141018", "H": "#8A7A4A", "h": "#5E5232", "F": "#F5A89A", "S": "#F6DCC8", "E": "#6CC36A",
             "W": "#F3EAD6", "G": "#2E8B57", "L": "#6CC36A", "K": "#7A5A3A", "Y": "#F7C96A"},
    "eyes": ["#6CC36A"], "skin": "#F6DCC8", "lid": "#5E5232",
    "head_ratio": 0.5,
    "flap_side": "left", "flap_rows": 10, "flap_width": 5,   # tóc dài bên trái (bên phải là gậy)
    "feet_split": 16,
    "spark": "#F5A89A",                                      # vệt cánh hoa khi lướt
})

"""Sprite pixel ngoài map của Vesper (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/vesper/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "vesper",
    # ký tự trong map_base.txt → màu (10 màu + viền = 11). Tóc đỏ tím theo concept (#3B2440 của bảng màu quá tối,
    # lẫn vào viền và mũ ở cỡ 32 px).
    "keys": {"O": "#141018", "T": "#2E2335", "t": "#5A3A66", "R": "#7A2E55", "r": "#4E1F3A", "S": "#EFD8D0",
             "E": "#B8F25A", "G": "#B89A4A", "W": "#EDE6D6", "P": "#9BC53D"},
    "eyes": ["#B8F25A"], "skin": "#EFD8D0", "lid": "#4E1F3A",
    "head_ratio": 0.58,
    "flap_side": "left", "flap_rows": 8, "flap_width": 4,   # vành mũ + tóc bên trái (bên phải là chén)
    "feet_split": 15,
    "spark": "#9BC53D",                                      # vệt độc khi lướt
})

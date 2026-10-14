"""Sprite pixel ngoài map của Aldric (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/aldric/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "aldric",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12); buồm khiên và mắt cùng màu xanh ngọc
    "keys": {"O": "#141018", "H": "#3E9C88", "h": "#24665A", "S": "#F2D2BE", "E": "#2E9C8C", "G": "#8C949E",
             "g": "#5A616B", "R": "#8E2A2A", "r": "#5E1A1A", "W": "#EEF1F2", "B": "#4FD1B5"},
    "eyes": ["#2E9C8C"], "skin": "#F2D2BE", "lid": "#24665A",
    "head_ratio": 0.5,
    "flap_side": "left", "flap_rows": 8, "flap_width": 6,   # áo choàng bay (bên phải là khiên)
    "feet_split": 14,
    "spark": "#C9F5EA",                                      # vệt gió khi lướt
})

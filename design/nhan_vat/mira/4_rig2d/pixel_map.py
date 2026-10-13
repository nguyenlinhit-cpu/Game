"""Sprite pixel ngoài map của Mira (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/mira/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "mira",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "W": "#F4F6FA", "w": "#C9D2E3", "H": "#E8EEF5", "h": "#BFC8D4", "S": "#F7DCCB",
             "B": "#A9D3F2", "L": "#3A8DDE", "D": "#1F5FB8", "K": "#6E4A34", "N": "#2B3550", "C": "#CDEBFF"},
    "eyes": ["#3A8DDE", "#1F5FB8"], "skin": "#F7DCCB", "lid": "#2B3550",
    "flap_side": "left",   # vạt tai mũ phía sau; bên phải là cây đũa
    "spark": "#CDEBFF",    # vệt gió khi lướt
})

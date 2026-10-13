"""Sprite pixel ngoài map của Kiri (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/kiri/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "kiri",
    # ký tự trong map_base.txt → màu (10 màu + viền = 11)
    "keys": {"O": "#141018", "H": "#F07A2C", "h": "#C24E1A", "S": "#F6D3BE", "E": "#F2A33A", "N": "#5A2A1A",
             "R": "#B3222E", "Y": "#F7C948", "W": "#F4EEE6", "K": "#6B3E26", "P": "#3A2A30"},
    "eyes": ["#F2A33A"], "skin": "#F6D3BE", "lid": "#5A2A1A",
    "flap_side": "left", "flap_rows": 10,   # bím tóc trái nảy (bên phải là gậy pháo)
    "spark": "#FFE08A",                     # vệt tia lửa khi lướt
})

"""Sprite pixel ngoài map của Garren (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/garren/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "garren",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "H": "#B8B8B0", "h": "#8A8A84", "S": "#E2B08E", "E": "#3F8F4F", "G": "#2E8B57",
             "g": "#1E5E3A", "L": "#6CC36A", "W": "#7A5232", "B": "#B8803A", "b": "#4A2E18", "C": "#E8D3A0"},
    "eyes": ["#3F8F4F"], "skin": "#E2B08E", "lid": "#8A8A84",
    "flap_side": "left", "flap_rows": 6, "flap_width": 7,   # cành lá vai trái rung (bên phải là khiên)
    "spark": "#6CC36A",                                      # vệt lá khi lướt
})

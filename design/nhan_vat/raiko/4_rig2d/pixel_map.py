"""Sprite pixel ngoài map của Raiko (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/raiko/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "raiko",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "H": "#E7E9F0", "h": "#B9BCCB", "P": "#C9A8F5", "S": "#F6D8C8", "E": "#D9F25A",
             "W": "#F3F3F7", "K": "#22202A", "V": "#A65BF2", "G": "#B08A4A", "B": "#3A3550"},
    "eyes": ["#D9F25A"], "skin": "#F6D8C8", "lid": "#22202A",
    "head_ratio": 0.56,
    "flap_side": "left", "flap_rows": 10, "flap_width": 5,   # đuôi ngựa bên trái nảy (bên phải là cung)
    "feet_split": 17,
    "spark": "#A65BF2",                                      # vệt điện khi lướt
})

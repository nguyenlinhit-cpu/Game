"""Sprite pixel ngoài map của Marisol (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/marisol/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "marisol",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12); bóng vải w dùng chung cho vỏ ốc
    "keys": {"O": "#141018", "W": "#F2EAD8", "w": "#C9BFA8", "B": "#2F6FB5", "b": "#1F4F8A", "S": "#F5D5C3",
             "E": "#2BA3A8", "G": "#C9A04A", "N": "#1F2A4A", "M": "#5E7F4F", "K": "#6E4A34", "L": "#3A8DDE"},
    "eyes": ["#2BA3A8"], "skin": "#F5D5C3", "lid": "#1F4F8A",
    "head_ratio": 0.62,
    "flap_side": "right", "flap_rows": 8, "flap_width": 4,   # tóc sau gáy bên phải bay (bên trái là khiên)
    "feet_split": 19,
    "spark": "#CDEBFF",                                      # vệt bọt nước khi lướt
})

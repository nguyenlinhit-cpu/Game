"""Sprite pixel ngoài map của Celestine (lõi ở design/_tools/pixel2d.py). Khung gốc vẽ tay trong map_base.txt.

Chạy từ gốc repo:
    blender -b -P design/nhan_vat/celestine/4_rig2d/pixel_map.py
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_tools"))
from pixel2d import run  # noqa: E402

run({
    "id": "celestine",
    # ký tự trong map_base.txt → màu (11 màu + viền = 12)
    "keys": {"O": "#141018", "H": "#EEF0F5", "h": "#B8BCCB", "S": "#F6DCCB", "E": "#F2C14E", "W": "#F2F3F7",
             "N": "#1E2A55", "Y": "#F2D58A", "y": "#C9A04A", "K": "#1A1A22", "B": "#D8DCE6"},
    "eyes": ["#F2C14E"], "skin": "#F6DCCB", "lid": "#1E2A55",
    "head_ratio": 0.5,
    "flap_side": "left", "flap_rows": 10, "flap_width": 5,   # vầng sáng + chuôi kiếm sau lưng (bên phải là kiếm)
    "feet_split": 17,
    "spark": "#F2D58A",                                      # vệt sáng vàng khi lướt
})

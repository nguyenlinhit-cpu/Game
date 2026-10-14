"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'pip',
 'keys': {'H': '#754B2F',
          'h': '#49352D',
          'S': '#F6D8C6',
          'E': '#6FA8FF',
          'B': '#8C9096',
          'b': '#555B69',
          'G': '#F2A23A',
          'W': '#EDEFF2',
          'K': '#9B672F',
          'A': '#3A6FD8',
          'L': '#A65BF2',
          'O': '#141018'},
 'eyes': ['#6FA8FF'],
 'skin': '#F6D8C6',
 'lid': '#49352D',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#A65BF2'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)

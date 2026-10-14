"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'neris',
 'keys': {'H': '#244476',
          'h': '#142746',
          'S': '#D9A27E',
          'E': '#3AB0D8',
          'B': '#1F4E8C',
          'b': '#132E54',
          'G': '#F2785C',
          'W': '#DBE6F2',
          'K': '#6D8199',
          'A': '#3A8DDE',
          'L': '#F8C599',
          'O': '#141018'},
 'eyes': ['#3AB0D8'],
 'skin': '#D9A27E',
 'lid': '#142746',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#F8C599'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)

"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'traveler_male',
 'keys': {'H': '#2A2F4A',
          'h': '#1C2035',
          'S': '#F4D7C4',
          'E': '#F2B84A',
          'B': '#1F2A55',
          'b': '#18203B',
          'G': '#F2D58A',
          'W': '#C9CFD8',
          'K': '#6B4B37',
          'A': '#3B4C8A',
          'L': '#FFF1B8',
          'O': '#141018'},
 'eyes': ['#F2B84A'],
 'skin': '#F4D7C4',
 'lid': '#1C2035',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#FFF1B8'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)

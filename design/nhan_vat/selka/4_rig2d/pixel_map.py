"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'selka',
 'keys': {'H': '#C6A4DE',
          'h': '#846A9C',
          'S': '#F6DACB',
          'E': '#D15F8D',
          'B': '#B9A3E3',
          'b': '#71608B',
          'G': '#9BC53D',
          'W': '#EEE3EE',
          'K': '#C59B54',
          'A': '#E9AED2',
          'L': '#D8D18C',
          'O': '#141018'},
 'eyes': ['#D15F8D'],
 'skin': '#F6DACB',
 'lid': '#846A9C',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#D8D18C'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)

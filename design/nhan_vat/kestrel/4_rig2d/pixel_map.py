"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))
from pixel2d import run
from character_pixel_motion import character_frames
CONFIG = {'id': 'kestrel',
 'keys': {'H': '#F1BD45',
          'h': '#B77F29',
          'S': '#DCA878',
          'E': '#269D99',
          'B': '#368F83',
          'b': '#236258',
          'G': '#4FD1B5',
          'W': '#EEE8D6',
          'K': '#705340',
          'A': '#BFA574',
          'L': '#A5DDD0',
          'O': '#141018'},
 'eyes': ['#269D99'],
 'skin': '#DCA878',
 'lid': '#B77F29',
 'head_ratio': 0.58,
 'feet_split': 15,
 'flap_side': 'left',
 'flap_width': 4,
 'flap_rows': 9,
 'spark': '#A5DDD0'}
CONFIG["frames"] = character_frames
if __name__ == "__main__":
    run(CONFIG)

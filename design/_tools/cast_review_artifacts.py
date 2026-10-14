"""Build layered review boards and labelled contact sheets without a GUI.

blender -b -P design/_tools/cast_review_artifacts.py -- --boards
blender -b -P design/_tools/cast_review_artifacts.py -- --overview
"""
from pathlib import Path
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile
import numpy as np
sys.path.insert(0,str(Path(__file__).resolve().parent))
from vfx2d import load_rgba,save_png,resize,over
from build_remaining_cast import CAST,PALETTES
from pixel2d import read_grid,outline
import importlib.util
ROOT=Path(__file__).resolve().parents[1]
# Small bitmap type for predictable, headless labels; enlarged with nearest pixels.
FONT={
'A':['01110','10001','10001','11111','10001','10001','10001'],
'B':['11110','10001','10001','11110','10001','10001','11110'],
'C':['01111','10000','10000','10000','10000','10000','01111'],
'D':['11110','10001','10001','10001','10001','10001','11110'],
'E':['11111','10000','10000','11110','10000','10000','11111'],
'F':['11111','10000','10000','11110','10000','10000','10000'],
'G':['01111','10000','10000','10111','10001','10001','01110'],
'H':['10001','10001','10001','11111','10001','10001','10001'],
'I':['11111','00100','00100','00100','00100','00100','11111'],
'J':['00111','00010','00010','00010','00010','10010','01100'],
'K':['10001','10010','10100','11000','10100','10010','10001'],
'L':['10000','10000','10000','10000','10000','10000','11111'],
'M':['10001','11011','10101','10101','10001','10001','10001'],
'N':['10001','11001','10101','10011','10001','10001','10001'],
'O':['01110','10001','10001','10001','10001','10001','01110'],
'P':['11110','10001','10001','11110','10000','10000','10000'],
'Q':['01110','10001','10001','10001','10101','10010','01101'],
'R':['11110','10001','10001','11110','10100','10010','10001'],
'S':['01111','10000','10000','01110','00001','00001','11110'],
'T':['11111','00100','00100','00100','00100','00100','00100'],
'U':['10001','10001','10001','10001','10001','10001','01110'],
'V':['10001','10001','10001','10001','10001','01010','00100'],
'W':['10001','10001','10001','10101','10101','10101','01010'],
'X':['10001','10001','01010','00100','01010','10001','10001'],
'Y':['10001','10001','01010','00100','00100','00100','00100'],
'Z':['11111','00001','00010','00100','01000','10000','11111'],
'0':['01110','10011','10101','10101','11001','10001','01110'],
'1':['00100','01100','00100','00100','00100','00100','01110'],
'2':['01110','10001','00001','00010','00100','01000','11111'],
'3':['11110','00001','00001','01110','00001','00001','11110'],
'4':['10010','10010','10010','11111','00010','00010','00010'],
'5':['11111','10000','10000','11110','00001','00001','11110'],
'6':['01110','10000','10000','11110','10001','10001','01110'],
'7':['11111','00001','00010','00100','01000','01000','01000'],
'8':['01110','10001','10001','01110','10001','10001','01110'],
'9':['01110','10001','10001','01111','00001','00001','01110'],
'#':['01010','11111','01010','01010','11111','01010','00000'],
'-':['00000','00000','00000','11111','00000','00000','00000'],
'.':['00000','00000','00000','00000','00000','00110','00110'],
':':['00000','00110','00110','00000','00110','00110','00000'],
'/':['00001','00010','00010','00100','01000','01000','10000'],
}
def color(h):return np.array([int(h[k:k+2],16)/255 for k in (1,3,5)]+[1],np.float32)
def canvas(w,h,col=None):
 a=np.zeros((h,w,4),np.float32)
 if col:a[:]=color(col)
 return a
def text(a,s,x,y,scale=3,col='#DCE4F5'):
 for ch in s.upper().replace('_',' '):
  pattern=FONT.get(ch,['00000']*7)
  for yy,row in enumerate(pattern):
   for xx,bit in enumerate(row):
    if bit=='1':a[y+yy*scale:y+(yy+1)*scale,x+xx*scale:x+(xx+1)*scale]=color(col)
  x+=6*scale

def fit(im,w,h):
 scale=min(w/im.shape[1],h/im.shape[0]);return resize(im,max(1,round(im.shape[1]*scale)),max(1,round(im.shape[0]*scale)))

def boards():
 for ident in ('traveler_male','traveler_female'):
  folder=ROOT/'nhan_vat'/ident;concept=folder/'1_concept';out=folder/'2_sketch';out.mkdir(exist_ok=True)
  spec=importlib.util.spec_from_file_location('pixel_'+ident,folder/'4_rig2d/pixel_map.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
  px=outline(read_grid(folder/'4_rig2d/map_base.txt',mod.CONFIG['keys'],32));save_png(concept/'1d_pixel.png',px)
  merged=canvas(3840,2160,'#F4F5F9');layers=[]
  with tempfile.TemporaryDirectory() as tmp:
   tmp=Path(tmp)
   def layer(name,a,x,y):
    p=tmp/(name+'.png');save_png(p,a);layers.append((name,p,x,y));over(merged,a,x,y)
   layer('background',merged.copy(),0,0)
   titles=canvas(3840,260)
   text(titles,ident+' - 5 STAR - SOUL - DESTRUCTION',80,45,7,'#27344E')
   for title,x in [('BATTLE CONCEPT',80),('FRONT A POSE',1330),('BACK A POSE',2580)]:text(titles,title,x,190,5,'#27344E')
   layer('notes_header',titles,0,0)
   for name,fn,x in [('concept_battle','1a_battle.png',80),('concept_front','1b_front.png',1330),('concept_back','1b_back.png',2580)]:
    im=fit(load_rgba(concept/fn),1160,1250);layer(name,im,x,300+(1250-im.shape[0])//2)
   im=fit(load_rgba(concept/'1c_weapon.png'),520,360);layer('weapon',im,80,1740)
   layer('map_pixel',resize(px,256,256,nearest=True),690,1780)
   pal=canvas(2700,300)
   labels=['HAIR','HAIR SHADE','SKIN','EYE','CLOAK','CLOAK SHADE','SOUL GOLD','SWORD','LEATHER','LINING','SOUL LIGHT']
   for i,(label,col) in enumerate(zip(labels,PALETTES[ident])):
    x=(i%4)*670;y=(i//4)*95;pal[y:y+64,x:x+64]=color(col);text(pal,label+' '+col,x+80,y+16,4,'#27344E')
   layer('palette',pal,1110,1620)
   note=canvas(2750,200)
   for i,s in enumerate(['QUIET - CURIOUS - STEADFAST. SPLIT CLOAK AND SOUL CRYSTAL.',
      'CHECK SWORD HANDS AND FACE. REVIEW DRAFT - NOT APPROVED.',
      'PIXEL IS THE EDITABLE 32 X 32 SOURCE. ONLY EAST VIEW.',
      'DRAW CORRECTIONS ON THE EMPTY YOUR SKETCH LAYER.']):text(note,s,0,i*45,4,'#27344E')
   layer('notes',note,1110,1950)
   save_png(out/(ident+'_sketch_v1.png'),resize(merged,1920,1080))
   save_png(tmp/'merged.png',merged)
   blank=canvas(1,1);save_png(tmp/'blank.png',blank)
   layers.append(('your_sketch',tmp/'blank.png',0,0))
   xml=ET.Element('image',version='0.0.3',w='3840',h='2160',name=ident);stack=ET.SubElement(xml,'stack')
   with zipfile.ZipFile(out/(ident+'_sketch_v1.ora'),'w') as z:
    z.writestr('mimetype','image/openraster',compress_type=zipfile.ZIP_STORED);z.write(tmp/'merged.png','mergedimage.png')
    for i,(name,p,x,y) in enumerate(reversed(layers)):
     member=f'data/layer{i:02d}.png';z.write(p,member);ET.SubElement(stack,'layer',name=name,src=member,x=str(x),y=str(y),opacity='1.0',visibility='visible',**{'composite-op':'svg:src-over'})
    z.writestr('stack.xml',ET.tostring(xml,encoding='utf-8',xml_declaration=True))
  (folder/'BRIEF.md').write_text((folder/'ANIMATION_SPEC.md').read_text())
  print('Board',ident,flush=True)


def overview():
 ids=list(CAST);a=canvas(1800,1560,'#202535');text(a,'REMAINING CAST - V1 - REVIEW DRAFTS',36,24,5)
 from make_gif import write_gif
 animations=[]
 for t in range(12):animations.append(canvas(1800,1560,'#202535'));text(animations[-1],'REMAINING CAST - V1 - REVIEW DRAFTS',36,24,5)
 for k,ident in enumerate(ids):
  x=(k%4)*450;y=90+(k//4)*490
  folder=ROOT/'nhan_vat'/ident
  import json
  meta=json.loads((folder/'5_render'/f'battle_{ident}.json').read_text());sheet=load_rgba(folder/'5_render'/f'battle_{ident}.png')
  cells=[e for e in meta['frames'] if e['action']=='idle'];f=sheet[cells[0]['y']:cells[0]['y']+512,cells[0]['x']:cells[0]['x']+512]
  over(a,resize(f,400,400),x+20,y+32);text(a,ident,x+25,y,3)
  px=load_rgba(folder/'4_rig2d/map_base.png');over(a,resize(px,96,96,nearest=True),x+320,y+345);text(a,'32PX',x+320,y+448,2)
  for t,bg in enumerate(animations):
   e=cells[t%len(cells)];im=sheet[e['y']:e['y']+512,e['x']:e['x']+512];over(bg,resize(im,400,400),x+20,y+32);text(bg,ident,x+25,y,3);over(bg,resize(px,96,96,nearest=True),x+320,y+345)
 out=ROOT/'_reports/remaining_cast';out.mkdir(exist_ok=True,parents=True);save_png(out/'cast_overview.png',a)
 write_gif(out/'cast_idle.gif',[(np.clip(bg[::2,::2]*255+.5,0,255)).astype(np.uint8) for bg in animations],12)
 print('Saved cast_overview.png and cast_idle.gif')
if '--boards' in sys.argv:boards()
if '--overview' in sys.argv:overview()

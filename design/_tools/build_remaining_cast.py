"""Create editable, character-specific rig declarations and hand-designed pixel grids.

Run once with Python from repo root. Existing declarations are never overwritten.
Then run each rig_battle.py, pixel_map.py, make_<id>_vfx.py with Blender.
"""
from pathlib import Path
from pprint import pformat
import shutil

ROOT = Path(__file__).resolve().parents[1]
# Source-image coordinates, all concept canvases 1536x1024.
# id: style, foot x, head(cx,cy,r), chest, hips, shoulders, leg segments, main weapon(pivot,zones)
CAST = {
 'fenna': dict(style='bow', fx=780, head=(815,285,205), chest=(790,565), hips=(760,730),
   arms=((575,490,690,510),(1010,535,1185,555)), legs=((660,790,585,900),(920,780,1010,940)),
   weapon=((1205,555),[(1125,175,1190,300,30),(1190,300,1240,460,35),(1240,460,1200,650,40),(1200,650,1085,755,35),(1075,760,970,680,18),(1175,550,1230,570,42)]),
   extras=[('ear_l','head',(640,235),[(680,85,715,160,60)]),('ear_r','head',(990,245),[(1030,140,1065,80,45)]),('scarf1','chest',(610,460),[(470,470,350,450,65)]),('scarf2','scarf1',(350,450),[(300,480,205,540,45)])], h=350),
 'kestrel': dict(style='dual', fx=860, head=(1005,245,215), chest=(865,520), hips=(825,670),
   arms=((745,455,540,490),(1030,535,1240,655)), legs=((675,750,475,925),(1080,735,1230,940)),
   weapon=((1270,670),[(1260,665,1410,670,38),(1410,450,1460,550,38),(1460,550,1470,690,45),(1470,690,1410,775,36)]),
   other=((425,505),[(300,470,430,505,36),(300,470,225,590,45),(225,590,240,685,38),(240,685,280,755,24)]),
   extras=[('scarf1','chest',(770,410),[(660,365,560,270,65)]),('scarf2','scarf1',(560,270),[(430,190,330,110,60)]),('scarf3','chest',(760,420),[(550,370,370,280,55)]),('scarf4','scarf3',(370,280),[(220,280,130,370,60)]),('wing_l','leg_l',(465,860),[(400,815,410,865,35)]),('wing_r','leg_r',(1190,865),[(1230,820,1250,775,24)])], h=290),
 'neris': dict(style='spear', fx=670, head=(640,215,220), chest=(620,490), hips=(615,670),
   arms=((485,450,370,555),(740,440,815,430)), legs=((535,725,300,925),(785,700,925,945)),
   weapon=((820,440),[(65,695,1080,330,24),(1120,235,1400,110,24),(1130,235,1090,320,30),(1090,320,1305,245,35),(1305,245,1480,145,25),(1120,360,1265,365,25),(1265,365,1440,265,22),(800,418,850,450,44),(330,590,380,610,43)]),
   extras=[('hair1','head',(470,185),[(455,240,420,325,40)]),('hair2','head',(810,265),[(835,310,855,345,26)])], h=280),
 'pip': dict(style='robot', fx=765, head=(765,230,220), chest=(745,530), hips=(735,675),
   arms=((620,520,560,570),(900,480,1035,435)), legs=((640,725,560,890),(850,730,950,940)),
   weapon=((1090,435),[(1050,425,1220,345,45),(1220,345,1260,235,40),(1260,235,1340,240,38),(1260,400,1345,375,40),(1150,355,1190,410,50),(1050,440,1100,470,45)]),
   extras=[], h=325),
 'ember': dict(style='book', fx=740, head=(790,205,205), chest=(750,485), hips=(740,660),
   arms=((605,475,495,535),(925,470,1080,475)), legs=((625,750,510,940),(900,750,980,940)),
   weapon=((490,535),[(355,385,430,460,55),(430,460,630,510,63),(390,395,575,405,45),(445,520,505,550,42)]),
   extras=[('hair1','head',(615,200),[(595,80,620,135,45)]),('hair2','head',(800,150),[(790,35,880,85,45)]),('hair3','head',(955,230),[(960,160,990,240,38)]),('book_cover','weapon',(430,440),[(510,455,590,510,35)])], h=345),
 'selka': dict(style='incense', fx=750, head=(730,220,190), chest=(790,470), hips=(770,665),
   arms=((705,440,790,445),(845,445,875,420)), legs=((660,810,630,900),(795,825,760,955)),
   weapon=((870,430),[(850,445,1030,250,21),(1045,230,1080,235,32)]),
   extras=[('censer_chain','weapon',(1060,260),[(1060,295,1060,425,21)]),('censer','censer_chain',(1060,420),[(1025,490,1110,525,65),(1065,550,1085,680,25)]),('sleeve_l','arm_l',(690,455),[(630,530,530,650,70)]),('sleeve_r','arm_r',(865,475),[(895,545,915,615,42)])], h=355, concept='1a_clean.png'),
 'vael': dict(style='cards', fx=790, head=(805,230,160), chest=(815,435), hips=(850,590),
   arms=((700,390,580,380),(940,355,965,290)), legs=((815,675,745,860),(860,710,830,940)),
   weapon=((570,350),[(460,295,590,310,55)]),
   extras=[('hat','head',(805,195),[(780,65,850,110,100),(680,115,910,230,45)]),('cape1','chest',(695,440),[(560,545,475,640,60)]),('cape2','cape1',(475,640),[(480,705,590,750,60)]),('cape3','chest',(960,550),[(1010,675,1050,740,60)])], h=355),
 'wisp': dict(style='ghost', fx=720, head=(845,220,205), chest=(845,500), hips=(785,670),
   arms=((780,485,925,425),(1000,485,985,435)), legs=((730,740,660,840),(810,740,790,900)),
   weapon=((965,420),[]),
   extras=[('tail1','hips',(805,720),[(800,770,750,800,60)]),('tail2','tail1',(750,800),[(720,825,670,870,48)]),('tail3','tail2',(670,870),[(665,880,705,920,40)]),('tail4','tail3',(705,920),[(730,930,790,945,35)]),('tail5','tail4',(790,945),[(800,945,845,930,22)]),('hair1','head',(610,310),[(510,345,360,365,55)]),('hair2','head',(710,430),[(625,495,540,520,45)])], h=350),
 'echo': dict(style='mirror', fx=950, head=(950,215,195), chest=(970,460), hips=(960,650),
   arms=((855,465,820,580),(1065,435,1090,400)), legs=((900,800,865,935),(1020,800,1040,950)),
   weapon=((1100,405),[(1110,275,1135,210,75),(1100,355,1105,405,24)]),
   extras=[('hair1','head',(760,350),[(705,470,630,550,85)]),('hair2','hair1',(630,550),[(565,650,475,680,70)])], h=330, concept='1a_clean.png'),
 'traveler_male': dict(style='sword',fx=965,head=(970,150,140),chest=(960,360),hips=(960,530),
   arms=((850,355,725,470),(1055,375,1100,535)),legs=((865,650,735,930),(1095,650,1175,900)),
   weapon=((655,530),[(35,735,570,555,20),(560,545,745,515,24),(605,510,660,555,33)]),
   extras=[('cape1','chest',(835,420),[(730,570,600,680,65)]),('cape2','cape1',(600,680),[(500,730,390,860,52)]),('cape3','chest',(1070,450),[(1210,610,1300,700,65)]),('cape4','cape3',(1300,700),[(1390,770,1450,840,45)]),('hair1','head',(985,80),[(1030,100,1070,170,27)]),('hair2','hair1',(1070,170),[(1070,195,1060,245,20)])],h=300),
 'traveler_female': dict(style='sword',fx=970,head=(1020,130,125),chest=(1015,325),hips=(1005,475),
   arms=((890,340,785,410),(1095,350,1110,485)),legs=((935,590,815,865),(1080,600,1185,920)),
   weapon=((725,480),[(30,712,620,525,19),(610,520,800,465,24),(665,490,715,535,25)]),
   extras=[('cape1','chest',(880,415),[(750,540,650,615,60)]),('cape2','cape1',(650,615),[(570,670,475,760,60)]),('cape3','chest',(1090,420),[(1190,550,1290,630,65)]),('cape4','cape3',(1290,630),[(1380,710,1445,800,45)]),('hair1','head',(925,150),[(840,205,800,260,50)]),('hair2','hair1',(800,260),[(740,300,715,350,35)])],h=300),
}


def bone(parent, pivot, zones, depth=2, prio=1.5):
 return dict(parent=parent,pivot=pivot,zone=zones,prio=prio,depth=depth)


def rig_config(ident,c):
 x,y=c['hips']; cx,cy=c['chest']; hx,hy,hr=c['head'];l,r=c['arms']
 b={'root':bone(None,(c['fx'],1000),[],0,.02)}
 for nm,leg in zip(('leg_l','leg_r'),c['legs']):
  ax,ay,bx,by=leg;b[nm]=bone('root',(ax,ay),[(ax,ay,bx,by,50)],1)
 b['hips']=bone('root',(x,y),[(x-70,y,x+70,y,75)],1.2)
 b['chest']=bone('hips',(cx,cy+100),[(cx,cy,cx,cy+60,90)],2)
 b['head']=bone('chest',(hx,hy+hr*.8),[(hx,hy-hr*.4,hx,hy+hr*.35,hr*.75)],3,2)
 for nm,a in zip(('arm_l','arm_r'),(l,r)):
  ax,ay,bx,by=a;b[nm]=bone('chest',(ax,ay),[(ax,ay,bx,by,45)],3.5,2)
 pivot,zones=c['weapon'];b['weapon']=bone('arm_l' if c['style'] in ('book','sword','cards') else 'arm_r',pivot,[],10,0)
 top=[('weapon',zones)] if zones else []
 if c.get('other'):
  pivot,zones=c['other'];b['weapon_l']=bone('arm_l',pivot,[],10,0);top.append(('weapon_l',zones))
 for name,parent,piv,zones in c['extras']:
  b[name]=bone(parent,piv,zones,2.5 if 'hair' not in name else 3.2,2.2)
  if name in ('hat','censer','censer_chain','book_cover'):
   top.append((name,zones));b[name]['prio']=0
 if ident=='pip':
  b['robot']=bone('root',(350,330),[],10,0)
  b['robot_eye']=bone('robot',(430,355),[],11,0)
  top.extend([('robot',[(330,345,340,360,165),(340,190,355,225,85),(180,305,210,345,65),(460,470,475,490,50)]),('robot_eye',[(430,335,430,370,38)])])
 cfg=dict(id=ident,bones=b,top=top,char_h=c['h'],foot_x=c['fx'],strict_pockets=350,shadow_below=975)
 if c.get('concept'):cfg['concept']=c['concept']
 if ident=='ember':cfg['erase']=[(1100,245,1175,355,70),(1110,350,1220,390,40),(370,250,440,320,58),(380,330,465,325,28)]
 if ident=='pip':cfg['erase']=[(175,425,280,520,45),(260,545,365,590,35),(400,520,455,555,25)]
 if ident=='wisp':cfg['erase']=[(1200,390,1370,430,95),(300,515,230,520,95)]
 if ident=='vael':cfg['drop_islands']=(800,500)  # isolated flying cards and trails; held fan remains
 return cfg

# Every grid is constructed explicitly from familiar pixel primitives, then stored as editable text.
# Eleven pigment colors plus the common outline. No quantisation of concept art.
PALETTES={
 'fenna':['#AA5A2C','#743D27','#F3D4B3','#F1A23A','#5D763B','#364D2C','#C67C32','#EEE6CB','#8D603A','#C0A56B','#B8CE84'],
 'kestrel':['#F1BD45','#B77F29','#DCA878','#269D99','#368F83','#236258','#4FD1B5','#EEE8D6','#705340','#BFA574','#A5DDD0'],
 'neris':['#244476','#142746','#D9A27E','#3AB0D8','#1F4E8C','#132E54','#F2785C','#DBE6F2','#6D8199','#3A8DDE','#F8C599'],
 'pip':['#754B2F','#49352D','#F6D8C6','#6FA8FF','#8C9096','#555B69','#F2A23A','#EDEFF2','#9B672F','#3A6FD8','#A65BF2'],
 'ember':['#E8552B','#9B3022','#F3CFAD','#E8AE3D','#4E3834','#2C262B','#E87532','#E9DABC','#79503A','#B9914D','#FFD16D'],
 'selka':['#C6A4DE','#846A9C','#F6DACB','#D15F8D','#B9A3E3','#71608B','#9BC53D','#EEE3EE','#C59B54','#E9AED2','#D8D18C'],
 'vael':['#A84377','#612946','#F3D2BE','#9BC53D','#622843','#241E2C','#C29C52','#F1E9DB','#806443','#C26491','#C5D975'],
 'wisp':['#E6FBF6','#9ABDBB','#F4E8EC','#B9A3E3','#F2F6F7','#AFCBD1','#4FD1B5','#F7FFFF','#C7CCD4','#CFEFEA','#7BA9AE'],
 'echo':['#F2E2A8','#BCAD8A','#F3DCD2','#8E6FD8','#27232F','#15151C','#F2D58A','#F4F4F4','#C7CCD4','#615376','#B6A0DD'],
 'traveler_male':['#2A2F4A','#1C2035','#F4D7C4','#F2B84A','#1F2A55','#18203B','#F2D58A','#C9CFD8','#6B4B37','#3B4C8A','#FFF1B8'],
 'traveler_female':['#2A2F4A','#1C2035','#F6DACB','#F2B84A','#6E2340','#411C30','#F2D58A','#C9CFD8','#6B4B37','#9C3A5E','#FFF1B8'],
}
CHARS='HhSEBbGWKAL'


def map_grid(ident):
 g=[['.']*32 for _ in range(32)]
 def dot(x,y,c):
  if 0<=x<32 and 0<=y<32:g[y][x]=c
 def rect(x0,y0,x1,y1,c):
  for y in range(y0,y1+1):
   for x in range(x0,x1+1):dot(x,y,c)
 def ellipse(cx,cy,rx,ry,c):
  for y in range(int(cy-ry),int(cy+ry)+1):
   for x in range(int(cx-rx),int(cx+rx)+1):
    if ((x-cx)/rx)**2+((y-cy)/ry)**2<=1:dot(x,y,c)
 def line(x0,y0,x1,y1,c):
  steps=max(abs(x1-x0),abs(y1-y0),1)
  for i in range(steps+1):dot(round(x0+(x1-x0)*i/steps),round(y0+(y1-y0)*i/steps),c)
 # Small body, head roughly sixty percent, right-facing visible eye and nose.
 rect(11,19,19,24,'B');rect(11,23,20,25,'b');rect(10,26,13,28,'K');rect(17,26,21,28,'K')
 rect(8,19,11,24,'b');rect(7,23,9,25,'G')
 ellipse(15,11,8,8,'h');ellipse(16,10,8,7,'H');ellipse(18,14,6,5,'S')
 rect(21,12,22,14,'E');dot(21,12,'W');dot(24,15,'S');line(19,18,21,18,'h')
 rect(9,10,13,15,'H');line(13,9,16,12,'H');line(16,8,19,11,'H');rect(14,20,16,21,'G')
 rect(20,20,22,22,'S')
 if ident.startswith('traveler'):
  rect(7,18,10,25,'B');line(7,22,4,27,'B');line(8,24,7,27,'G');line(11,21,9,27,'A')
  line(21,22,29,18,'W');line(22,22,28,20,'G');dot(21,22,'K');dot(15,20,'L')
  if ident.endswith('female'):ellipse(6,14,3,6,'H');line(4,16,3,21,'h');dot(7,12,'G')
 elif ident=='fenna':
  ellipse(14,8,9,6,'B');line(6,7,7,2,'B');line(7,2,11,6,'H');line(19,5,23,2,'H');line(23,2,23,8,'B');dot(8,4,'W');dot(22,4,'W')
  line(8,18,4,22,'G');line(8,19,3,21,'G');rect(13,19,19,20,'G')
  line(26,15,28,19,'K');line(28,19,28,24,'K');line(28,24,25,27,'K');line(26,15,25,27,'A');line(20,22,30,22,'W');dot(29,21,'W');dot(29,23,'W')
  line(8,22,7,16,'K');dot(7,15,'W');dot(9,15,'W')
 elif ident=='kestrel':
  for x,y in [(8,5),(12,2),(17,2),(22,4)]:line(x,y,x+2,y+4,'H')
  rect(10,18,19,19,'W');line(10,18,3,15,'W');line(10,19,3,21,'W')
  line(21,23,27,20,'K');line(27,20,28,17,'G');line(28,17,30,22,'G');line(30,22,27,24,'G')
  line(8,22,4,24,'K');line(4,24,3,20,'G');dot(3,19,'W');line(10,27,7,25,'W');line(20,27,23,25,'W')
 elif ident=='neris':
  line(25,6,25,29,'W');line(23,5,23,9,'W');line(27,5,27,9,'W');line(23,9,27,9,'W');dot(25,4,'W');rect(19,21,25,22,'S')
  rect(13,5,22,8,'G');rect(14,6,16,7,'E');rect(19,6,21,7,'E');line(10,5,12,7,'K')
  rect(11,20,12,21,'G');rect(18,24,20,25,'G')
 elif ident=='pip':
  ellipse(15,7,9,5,'G');rect(5,9,25,10,'G');rect(11,5,13,7,'W');rect(18,5,20,7,'E');rect(12,21,14,23,'A');rect(18,21,20,23,'A');rect(10,27,14,28,'G');rect(17,27,21,28,'G')
  ellipse(4,15,3,3,'W');ellipse(5,15,1,1,'E');dot(3,13,'L');dot(3,17,'L');line(23,21,28,17,'K');rect(27,15,29,17,'W');dot(28,15,'.')
 elif ident=='ember':
  for x,y in [(8,5),(12,2),(17,2),(22,4)]:line(x,y,x+1,y+5,'H')
  rect(5,20,10,24,'K');line(5,20,8,21,'W');line(8,21,11,20,'W');line(8,21,8,24,'G');dot(6,22,'G');rect(14,19,16,25,'W');dot(15,23,'G')
 elif ident=='selka':
  ellipse(11,4,3,3,'H');line(6,4,16,4,'K');dot(7,3,'G');rect(9,22,21,27,'B');line(12,22,10,27,'G');line(18,22,20,27,'A');rect(8,20,11,24,'A')
  line(22,22,27,10,'K');line(27,10,28,17,'K');ellipse(28,19,2,2,'G');dot(28,19,'K');line(28,21,28,24,'A')
 elif ident=='vael':
  rect(8,4,19,8,'b');rect(9,2,17,6,'b');line(9,7,20,7,'G');line(6,9,23,9,'b');dot(18,5,'G');rect(6,19,10,27,'A');rect(10,21,12,26,'B');line(7,27,5,26,'G')
  rect(24,18,26,21,'G');dot(25,19,'b');rect(27,16,29,19,'G');dot(28,17,'b')
 elif ident=='wisp':
  rect(8,20,21,26,'B');rect(10,26,22,28,'.');ellipse(15,26,5,3,'A');rect(11,28,18,29,'A');line(12,29,10,27,'h');dot(9,26,'A');line(18,22,21,19,'S');line(21,19,23,17,'S');line(7,13,4,18,'H')
 elif ident=='echo':
  rect(20,9,22,11,'b');rect(22,10,23,14,'b');dot(22,11,'W');line(21,14,23,12,'W');rect(9,20,20,26,'b');line(10,23,8,27,'A');line(20,23,23,27,'A');dot(15,24,'G')
  ellipse(27,15,3,4,'K');ellipse(27,15,2,3,'A');dot(27,14,'W');line(26,19,24,23,'K');line(8,15,5,23,'H')
 # Reassert the face after hats/hoods have been drawn so the right-facing eye reads at 1x.
 if ident != 'echo':
  rect(20,14,22,16,'S');dot(21,14,'W');dot(22,14,'E');dot(22,15,'E');dot(24,16,'S')
 # Leave room for lean, recoil, companion movement and the generated 1px outline.
 compact=[['.']*32 for _ in range(32)]
 for y,row in enumerate(g):
  for x,ch in enumerate(row):
   if ch!='.':compact[3+round(y*.75)][3+round(x*.75)]=ch
 return [''.join(r) for r in compact]


def main():
 for ident,c in CAST.items():
  folder=ROOT/'nhan_vat'/ident;rig=folder/'4_rig2d';rig.mkdir(exist_ok=True)
  config=rig_config(ident,c);extra=[b[0] for b in c['extras']]
  text='"""2D source-coordinate rig; edit pivots using grid.png and weights.png. Review v1."""\nfrom pathlib import Path\nimport sys\nsys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))\nfrom rig2d import run\nfrom character_motion import poses_for\n\nCONFIG = '+pformat(config,sort_dicts=False,width=115)+'\nCONFIG["poses"] = poses_for('+repr(c['style'])+', '+repr(extra)+')\n\nif __name__ == "__main__":\n    run(CONFIG)\n'
  if not (rig/'rig_battle.py').exists():(rig/'rig_battle.py').write_text(text)
  keys=dict(zip(CHARS,PALETTES[ident]));keys['O']='#141018'
  if not (rig/'map_base.txt').exists():(rig/'map_base.txt').write_text('# '+ident+' — 32×32, hand-designed grid, right-facing.\n# '+str(keys)+'\n'+'\n'.join(map_grid(ident))+'\n')
  cfg=dict(id=ident,keys=keys,eyes=[keys['E']],skin=keys['S'],lid=keys['h'],head_ratio=.58,feet_split=15,flap_side='left',flap_width=4,flap_rows=9,spark=keys['L'])
  text='"""Editable 32×32 map sprite, only east; shared pixel animation plus character-specific motion."""\nfrom pathlib import Path\nimport sys\nsys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))\nfrom pixel2d import run\nfrom character_pixel_motion import character_frames\nCONFIG = '+pformat(cfg,sort_dicts=False)+'\nCONFIG["frames"] = character_frames\nif __name__ == "__main__":\n    run(CONFIG)\n'
  if not (rig/'pixel_map.py').exists():(rig/'pixel_map.py').write_text(text)
  vfx=folder/'6_vfx';vfx.mkdir(exist_ok=True)
  p=vfx/f'make_{ident}_vfx.py'
  if not p.exists():p.write_text('"""Procedural 2D skill effects; see remaining_cast_vfx.py and VFX_NOTES.md."""\nfrom pathlib import Path\nimport sys\nsys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))\nfrom remaining_cast_vfx import run_character\nif __name__ == "__main__":\n    run_character('+repr(ident)+')\n')
  # Preserve the actual full skill brief beside the editable source files.
  brief=next((ROOT.parent/'Design/Prompt 3/nhan_vat').glob('*_'+ident+'.md'))
  target=folder/'ANIMATION_SPEC.md'
  if not target.exists():target.write_text(brief.read_text())
 print('Prepared',len(CAST),'characters; existing source files preserved.')

if __name__=='__main__':main()

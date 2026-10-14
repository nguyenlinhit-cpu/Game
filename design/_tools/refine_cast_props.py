"""Refine rigid prop masks after inspecting the first animation sheets.

Writes only the new cast declarations. Keep these polygons in source coordinates.
"""
from pathlib import Path
import importlib.util
from pprint import pformat
ROOT=Path(__file__).resolve().parents[1]

def rect(x0,y0,x1,y1):
 return [(x0,y,x1,y,5) for y in range(y0,y1+1,8)]
def polygon(pts):
 zones=[]
 for y in range(min(p[1] for p in pts),max(p[1] for p in pts)+1,6):
  xs=[]
  for (ax,ay),(bx,by) in zip(pts,pts[1:]+pts[:1]):
   if min(ay,by)<=y<max(ay,by):xs.append(ax+(bx-ax)*(y-ay)/(by-ay))
  xs.sort()
  for a,b in zip(xs[::2],xs[1::2]):zones.append((a,y,b,y,5))
 return zones

MASKS={
 'neris':{'weapon':rect(1070,65,1532,410)+[(65,700,1080,330,36),(1045,330,1070,470,33),(1070,455,1100,500,23),(115,700,150,800,30),(330,590,380,610,48),(800,425,850,435,50)]},
 'pip':{'weapon':polygon([(1050,400),(1150,350),(1165,255),(1225,195),(1380,185),(1425,320),(1395,430),(1310,470),(1190,445),(1110,505),(1050,470)])},
 'kestrel':{'weapon':rect(1310,390,1520,815)+[(1230,660,1400,680,43),(1255,650,1290,680,40)],'weapon_l':rect(160,390,390,790)+[(335,475,505,540,45)]},
 'fenna':{'weapon':polygon([(1110,155),(1200,240),(1285,430),(1275,590),(1275,750),(1140,790),(1060,790),(955,685),(990,665),(1080,730),(1205,635),(1230,485),(1180,330),(1100,220)])+[(1200,555,1340,520,22),(1180,550,1230,570,47)]},
 'ember':{'weapon':polygon([(315,345),(380,370),(445,392),(600,348),(645,380),(690,540),(615,590),(455,570),(380,490),(350,420)])},
 'selka':{'censer':polygon([(1005,390),(1100,385),(1140,460),(1160,535),(1240,640),(1245,680),(1185,690),(1150,590),(1100,740),(1060,760),(1025,610),(980,555),(970,480)])},
 'traveler_male':{'weapon':[(25,740,590,560,32),(650,530,760,515,31)]+rect(550,480,675,615)},
 'traveler_female':{'weapon':[(25,715,650,520,30),(700,485,810,465,28)]+rect(615,475,720,570)},
}

def main():
 for ident,masks in MASKS.items():
  path=ROOT/'nhan_vat'/ident/'4_rig2d/rig_battle.py'
  spec=importlib.util.spec_from_file_location('refine_'+ident,path);mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);cfg=mod.CONFIG
  cfg['top']=[(bone,masks.get(bone,zones)) for bone,zones in cfg['top']]
  if ident=='neris':cfg.update(char_h=245,foot_x=780)
  style={'neris':'spear','pip':'robot','kestrel':'dual','fenna':'bow','ember':'book','selka':'incense','traveler_male':'sword','traveler_female':'sword'}[ident]
  names=[nm for nm in cfg['bones'] if nm not in ['root','leg_l','leg_r','hips','chest','head','arm_l','arm_r','weapon','weapon_l','robot','robot_eye']]
  del cfg['poses']
  path.write_text('"""2D source-coordinate rig; prop masks refined from animation review. See grid.png."""\nfrom pathlib import Path\nimport sys\nsys.path.insert(0,str(Path(__file__).resolve().parents[3]/"_tools"))\nfrom rig2d import run\nfrom character_motion import poses_for\n\nCONFIG = '+pformat(cfg,sort_dicts=False,width=115)+'\nCONFIG["poses"] = poses_for('+repr(style)+', '+repr(names)+')\nif __name__ == "__main__":\n    run(CONFIG)\n')
 print('Refined props for',len(MASKS),'characters')
if __name__=='__main__':main()

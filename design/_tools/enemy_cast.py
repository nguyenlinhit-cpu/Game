"""Render the complete enemy cast from editable 2D anatomy declarations.

blender -b -t 2 -P design/_tools/enemy_cast.py -- --family rusted_knight
Preserves the three existing rigs. No game files or review decisions are changed.
"""
import argparse
import colorsys
import json
import math
from pathlib import Path
import re
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rig2d as R
import pixel2d as P
import vfx2d as V
from make_gif import write_gif

ROOT = Path(__file__).resolve().parents[2]
DESIGN = ROOT / "design/quai"
COUNTS = {"idle": 6, "attack": 8, "skill": 10, "hit": 4, "down": 6}
COLORS = ["#E8552B", "#3A8DDE", "#A65BF2", "#4FD1B5", "#9BC53D", "#2E8B57", "#F2D58A"]
# Normalised coordinates on each original concept, independently placed by anatomy.
# Core pivot, head capsule, left/right moving limbs, trailing appendages.
ANATOMY = {
 "rusted_knight": ((.55,.67),(.50,.23,.13),[(.36,.48,.18,.53,.10),(.69,.52,.85,.68,.13)],[(.44,.70,.36,.90,.07),(.62,.72,.69,.93,.08)]),
 "void_archer": ((.56,.66),(.58,.25,.15),[(.45,.48,.25,.48,.08),(.71,.45,.79,.52,.06)],[(.72,.64,.88,.82,.10),(.63,.76,.82,.89,.06)]),
 "warped_mage": ((.56,.65),(.53,.32,.19),[(.40,.62,.26,.73,.10),(.67,.63,.80,.71,.10)],[(.55,.17,.69,.08,.07),(.67,.78,.82,.88,.06)]),
 "mirror_shade": ((.57,.61),(.56,.27,.18),[(.37,.57,.16,.52,.08),(.73,.53,.87,.44,.07)],[(.70,.73,.87,.81,.10),(.45,.77,.35,.89,.08)]),
 "devourer_clone": ((.48,.62),(.45,.20,.14),[(.34,.55,.22,.77,.07),(.60,.55,.77,.63,.08)],[(.62,.72,.86,.83,.08),(.60,.82,.84,.93,.06)]),
 "shattered_knight": ((.53,.62),(.53,.27,.16),[(.40,.48,.29,.46,.08),(.66,.47,.71,.62,.08)],[(.73,.60,.85,.84,.08),(.44,.70,.35,.90,.06)]),
 "mute_librarian": ((.53,.62),(.50,.25,.16),[(.33,.47,.22,.50,.07),(.67,.51,.78,.60,.07)],[(.35,.70,.22,.89,.09),(.70,.71,.85,.91,.10)]),
 "library_warden": ((.52,.64),(.52,.22,.13),[(.36,.47,.24,.64,.11),(.66,.43,.82,.61,.11)],[(.29,.24,.16,.20,.08),(.72,.26,.87,.25,.08),(.70,.68,.86,.85,.10)]),
 "soul_devourer": ((.47,.60),(.46,.19,.14),[(.31,.48,.15,.66,.10),(.64,.47,.80,.61,.12)],[(.61,.73,.84,.83,.10),(.56,.82,.79,.94,.09),(.76,.26,.85,.19,.08)]),
 "flying_book": ((.52,.58),(.47,.48,.12),[(.36,.48,.20,.27,.12),(.66,.46,.82,.28,.12)],[(.55,.77,.62,.86,.05)]),
 "venom_bee": ((.56,.59),(.30,.52,.17),[(.56,.39,.47,.16,.12),(.69,.38,.84,.22,.13)],[(.42,.70,.30,.80,.06),(.63,.72,.62,.87,.06),(.72,.61,.81,.76,.08)]),
 "furnace_arm": ((.75,.35),(.88,.23,.09),[(.70,.35,.52,.49,.14),(.49,.51,.28,.67,.13)],[(.22,.71,.14,.84,.07),(.36,.76,.34,.88,.07)]),
 "warp_matrix": ((.52,.61),(.49,.48,.17),[(.35,.60,.18,.75,.10),(.68,.62,.86,.79,.10)],[(.25,.78,.13,.87,.08),(.56,.83,.42,.92,.07),(.80,.80,.90,.90,.07)]),
 "vault_behemoth": ((.58,.57),(.33,.52,.17),[(.30,.67,.26,.86,.09),(.68,.69,.76,.87,.10)],[(.75,.63,.88,.63,.07),(.47,.22,.60,.16,.12)]),
 "warped_core": ((.52,.52),(.50,.50,.15),[(.31,.35,.18,.54,.10),(.72,.38,.84,.60,.10)],[(.49,.21,.65,.23,.08),(.39,.80,.59,.83,.08)]),
}
EXTRAS = {
 "rusted_knight": {"guard":6}, "void_archer": {"aim":6}, "shattered_knight": {"charge":6},
 "warp_matrix": {"summon":10}, "library_warden": {"summon":10,"curse":6},
 "vault_behemoth": {"telegraph":6}, "warped_core": {"telegraph":6},
 "soul_devourer": {"telegraph":6,"swallow":6,"summon":10},
}
PHASES = {"library_warden":2,"vault_behemoth":2,"warped_core":2,"soul_devourer":3}
FLOATING = {"flying_book","venom_bee","mirror_shade","devourer_clone","void_archer","warped_mage","soul_devourer","warped_core"}


def enemies(family):
    result=[]
    for path in sorted((ROOT/'data/enemies').glob('*.tres')):
        text=path.read_text()
        if f'family = &"{family}"' not in text: continue
        ident=re.search(r'^id = &"(.*?)"',text,re.M)[1]
        element=int(re.search(r'^element = (\d+)',text,re.M)[1])
        kind=int(re.search(r'^kind = (\d+)',text,re.M)[1])
        skill_ids=sorted(set(re.findall(r'path="res://data/skills/(en_.*?)\.tres"',text)))
        result.append(dict(id=ident,element=element,kind=kind,skills=skill_ids))
    return result


def skills(family):
    path=next((ROOT/'Design/Prompt 3/quai').glob(f'*_{family}.md'))
    text=path.read_text()
    result={}
    for match in re.finditer(r'### (.*?)\(`(\w+)`, Action (.*?)\)',text):
        key,action=match[2],match[3].strip()
        result['en_'+key]=dict(action=action.split(' → ')[-1],prepare=action.split(' → ')[0],title=match[1].strip())
    return result


def rig_config(family,phase):
    folder=DESIGN/family
    concept='1a_battle.png' if phase==1 else f'1a_battle_p{phase}.png'
    image=R.load_rgba(folder/'1_concept'/concept)
    h,w=image.shape[:2]
    core,head,limbs,extras=ANATOMY[family]
    def b(parent,pivot,zone,depth=2,prio=1.5):
        return dict(parent=parent,pivot=(pivot[0]*w,pivot[1]*h),
                    zone=[(a*w,c*h,d*w,e*h,r*min(w,h)) for a,c,d,e,r in zone],depth=depth,prio=prio)
    cx,cy=core;hx,hy,hr=head
    bones={'root':b(None,(cx,.94),[],0,.025),
           'body':b('root',core,[(cx,cy-.14,cx,cy+.10,.18)],1,1),
           'head':b('body',(hx,hy+hr*.8),[(hx,hy-.04,hx,hy+.04,hr)],3,2)}
    for i,(ax,ay,bx,by,r) in enumerate(limbs):
        bones[f'limb{i}']=b('body',(ax,ay),[(ax,ay,bx,by,r)],3.5,2)
    for i,(ax,ay,bx,by,r) in enumerate(extras):
        bones[f'extra{i}']=b('body',(ax,ay),[(ax,ay,bx,by,r)],2.5,2)
    if family=='rusted_knight':
        bones['shield']=b('limb1',(.74,.56),[(.75,.40,.83,.80,.09)],5,2.5)
        bones['blade']=b('limb0',(.34,.57),[(.09,.43,.34,.60,.045)],5,2.5)
    if family=='shattered_knight':
        bones['blade']=b('limb0',(.42,.52),[(.06,.22,.53,.58,.045)],5,2.5)
    if family=='void_archer':
        bones['bow']=b('limb0',(.23,.50),[(.17,.16,.24,.46,.045),(.24,.46,.16,.72,.045)],5,2.5)
    if family=='warped_mage': bones['hat']=b('head',(.51,.32),[(.40,.24,.66,.15,.10)],4,2.3)
    if family=='mute_librarian': bones['lantern']=b('limb0',(.20,.40),[(.20,.42,.20,.61,.08)],5,2.4)
    f={0:256,1:384,2:768}[enemies(family)[0]['kind']]
    cut=R.cutout(image.copy())
    ys,xs=np.nonzero(cut[...,3]>.1)
    aspect=(xs.max()-xs.min()+1)/(ys.max()-ys.min()+1)
    char_h=min(f*.72,f*.69/aspect)
    actions={**COUNTS,**EXTRAS.get(family,{})}
    cfg=dict(id=family if phase==1 else f'{family}-p{phase}',folder=family,kind='quai',concept=concept,
             frame=f,char_h=char_h,foot_x=(xs.min()+xs.max())/2,feet=(f//2,round(f*.83)),
             bones=bones,soft=min(w,h)*.022,actions=actions,loops=['idle','guard','aim','charge','telegraph','curse','swallow'],
             hit_frames={'attack':4,'skill':6,'summon':6,'down':4},shadow_below=int(h*.96))
    cfg['poses']={a:(lambda i,n,a=a:pose(family,bones,a,i,n,w,h)) for a in actions}
    if phase>1:
        cfg['actions']={f'{a}-p{phase}':n for a,n in actions.items()}
        cfg['poses']={f'{a}-p{phase}':fn for a,fn in cfg['poses'].items()}
        cfg['loops']=[f'{a}-p{phase}' for a in cfg['loops']]
        cfg['hit_frames']={f'{a}-p{phase}':n for a,n in cfg['hit_frames'].items()}
    declaration=folder/'4_rig2d'/f'rig_phase{phase}.json'
    declaration.parent.mkdir(parents=True,exist_ok=True)
    if declaration.exists():
        cfg.update(json.loads(declaration.read_text()))
    else:
        declaration.write_text(json.dumps({k:v for k,v in cfg.items() if k!='poses'},indent=2))
    return cfg


def pose(family,bones,action,i,n,w,h):
    t=i/max(1,n-1);wave=math.sin(math.tau*i/n)
    p={'body':{'sy':1+.014*wave},'head':{'rot':1.5*wave}}
    for k in bones:
        if k.startswith('extra'):p[k]={'rot':3.5*math.sin(math.tau*i/n+int(k[-1])*.8)}
    if family in FLOATING:p['root']={'dy':h*.008*wave}
    if family in ('flying_book','venom_bee'):
        for j in range(2):p[f'limb{j}']={'rot':(1 if j else -1)*10*math.sin(math.tau*i/n)}
    if family=='furnace_arm':p['limb0']={'rot':2.5*wave};p['limb1']={'rot':-4*wave}
    if family=='warped_core':p['head']={'rot':7*wave};p['body']={'rot':-3*wave}
    if action=='idle':return p
    if action in ('guard','aim','charge','telegraph','curse','swallow'):
        p['body'].update(sy=.94+.012*wave,rot=-3 if action!='guard' else 4)
        for j in range(2):p[f'limb{j}']={'rot':(-9 if j==0 else 9)+2*wave}
        if 'shield' in bones:p['shield']={'rot':-8,'dx':-w*.02}
        if 'bow' in bones:p['bow']={'sx':.94,'rot':-4}
        if action=='swallow':p['head']={'sx':1.07+.02*wave,'sy':1.04}
        return p
    if action=='hit':
        recoil=math.sin(math.pi*(.25+.75*t))
        return R.add(p,{'root':{'dx':w*.045*recoil},'body':{'rot':7*recoil,'sx':1+.035*recoil}})
    if action=='down':
        p={'root':{'sy':1-.45*t,'rot':12*t,'dx':w*.035*t},'head':{'rot':20*t}}
        for k in bones:
            if k.startswith(('extra','limb')):p[k]={'rot':(18 if int(k[-1])%2 else -18)*t}
        return p
    hit=4 if action=='attack' else 6
    prep=max(0,math.sin(math.pi*min(i,hit)/hit))
    strike=math.exp(-((i-hit)/1.3)**2)
    p=R.add(p,{'root':{'dx':w*(.018*prep-.065*strike),'dy':-h*.018*strike},
               'body':{'rot':5*prep-9*strike,'sy':1-.035*prep+.025*strike},
               'head':{'rot':4*prep-8*strike}})
    for j in range(2):p[f'limb{j}']={'rot':(1 if j else -1)*(12*prep-19*strike)}
    for k in ('blade','bow','lantern','hat'):
        if k in bones:p[k]={'rot':22*prep-29*strike}
    if action=='summon':p['body']={'sy':1-.08*prep+.07*strike};p['limb0']={'rot':-20*strike};p['limb1']={'rot':20*strike}
    return p


def recolor(image,family,color):
    """Only recolour saturated elemental accents, preserving material colours."""
    a=image.copy();rgb=a[...,:3];mx=rgb.max(-1);mn=rgb.min(-1);delta=mx-mn
    hue=np.zeros_like(mx);good=delta>.04
    for ch in range(3):
        m=good & (rgb[...,ch]==mx)
        value=((rgb[...,(ch+1)%3]-rgb[...,(ch+2)%3])/np.maximum(delta,1e-6)+ch*2)/6
        hue[m]=value[m]%1
    centres={'warp_sprout':.22,'wandering_shade':.14,'ink_rat':.47,'rusted_knight':.76,
             'void_archer':.46,'warped_mage':.22,'venom_bee':.22,'mirror_shade':.59,'devourer_clone':.035}
    if family not in centres:return a
    dist=np.minimum(abs(hue-centres[family]),1-abs(hue-centres[family]))
    mask=(dist<.10)&(delta/np.maximum(mx,.01)>.30)&(a[...,3]>.01)
    target=V.hexc(color);target/=max(target.max(),.01)
    sat=delta/np.maximum(mx,.01)
    changed=mx[...,None]*(1-sat[...,None]+sat[...,None]*target)
    a[mask,:3]=changed[mask]
    return a


def palette(family,color):
    material={
      'rusted_knight':['#8C542F','#513524','#AE8355','#423F46','#BBB19C'],
      'shattered_knight':['#778DAD','#3C4C6A','#BACDE5','#1D2338','#A4BBDB'],
      'flying_book':['#785236','#3C2B23','#EDE0B5','#B7A783','#E8D6A3'],
      'furnace_arm':['#675650','#322C32','#AC7541','#BD4625','#F5A637'],
      'vault_behemoth':['#658BAD','#35445F','#B5D6EB','#64513B','#CEBC90'],
      'library_warden':['#D6CDB7','#8D8479','#F1E7CB','#624536','#A59677'],
      'warp_matrix':['#6B4C73','#32263D','#A482A8','#8AAB42','#D6DF83'],
      'warp_sprout':['#C9B98A','#7A6344','#E3D79E','#4E8A3A','#8EBF58'],
      'ink_rat':['#282938','#424353','#141828','#6D6B76','#87828E'],
      'venom_bee':['#739546','#36442B','#BAD17E','#65602D','#E2EED4'],
    }.get(family,['#34323F','#585261','#A49DA9','#1C1928','#DDD4C4'])
    values=['#141018',*material,color,'#EAF6EF','#746477','#B69B65','#403548','#C5B4C3']
    return dict(zip('OABCDEFGHIJK',values))


def pixel_grid(family,size):
    """Editable pixel silhouettes, drawn from primitives; no concept quantisation."""
    g=np.full((32,32),'.',dtype='<U1')
    def rect(x0,y0,x1,y1,c):g[max(0,y0):min(32,y1+1),max(0,x0):min(32,x1+1)]=c
    def oval(cx,cy,rx,ry,c):
        yy,xx=np.mgrid[:32,:32];g[((xx-cx)/rx)**2+((yy-cy)/ry)**2<=1]=c
    def stroke(x0,y0,x1,y1,c,r=0):
        for t in np.linspace(0,1,int(max(abs(x1-x0),abs(y1-y0)))+1):
            x=round(x0+(x1-x0)*t);y=round(y0+(y1-y0)*t);rect(x-r,y-r,x+r,y+r,c)
    if family in ('flying_book','venom_bee'):
        oval(9,9,5,7,'G');oval(23,8,5,6,'G');stroke(7,7,12,16,'C');stroke(25,5,22,16,'C')
        if family=='flying_book':
            rect(10,13,22,23,'B');rect(12,14,21,21,'A');rect(20,14,23,22,'C');rect(14,16,18,19,'F')
        else:
            oval(15,19,8,6,'A');oval(23,17,5,5,'B');rect(24,16,26,17,'F');rect(9,18,11,22,'B');rect(14,18,16,23,'B')
            stroke(23,20,28,24,'E');stroke(16,23,15,27,'B');stroke(21,22,23,26,'B')
    elif family=='furnace_arm':
        rect(5,6,11,15,'B');rect(6,7,9,13,'A');stroke(10,13,17,17,'A',2);stroke(17,17,23,20,'A',2)
        oval(18,17,3,3,'F');stroke(24,20,28,17,'B',1);stroke(24,20,28,25,'B',1);rect(7,8,7,12,'F')
    elif family=='warped_core':
        oval(16,16,11,11,'B');oval(16,16,9,9,'A');oval(16,16,6,6,'B');oval(16,16,4,5,'F')
        for x,y in [(8,8),(24,8),(8,24),(24,24)]:oval(x,y,3,3,'D');oval(x,y,1,1,'F')
        stroke(9,15,22,18,'C');oval(16,16,2,2,'G')
    elif family=='warp_matrix':
        oval(16,18,10,8,'B');oval(16,16,7,8,'A');oval(16,15,5,5,'E');oval(17,15,3,4,'F')
        for x in [5,10,21,26]:stroke(16,21,x,26,'A',1);stroke(x,26,x+2,27,'C')
        stroke(8,15,6,8,'A');stroke(22,14,24,7,'A');oval(10,13,2,2,'E');oval(22,20,2,2,'E')
    elif family=='vault_behemoth':
        oval(15,19,10,7,'B');oval(24,18,5,6,'A');oval(16,17,9,5,'A');rect(6,22,9,28,'B');rect(19,22,22,28,'B')
        rect(11,7,17,14,'D');rect(18,9,23,15,'D');rect(12,8,16,9,'E');rect(18,10,22,11,'E')
        stroke(24,19,29,27,'C',1);stroke(24,19,27,26,'G');rect(24,16,25,17,'F')
        for x,y in [(7,12),(10,16),(19,13)]:stroke(x,y,x+2,y-4,'C',1)
    else:
        # Distinct humanoid silhouettes: armour, robes, mirror shards or fissured ghosts.
        cloak=family in ('mute_librarian','library_warden','warped_mage','void_archer','devourer_clone','soul_devourer')
        oval(16,10,5,6,'A');oval(17,10,4,5,'C' if family=='mute_librarian' else 'B')
        rect(11,15,21,22,'A');rect(13,15,17,20,'C');rect(13,9,15,10,'F');rect(19,9,21,10,'F')
        if cloak:
            for y in range(20,28):rect(12-(y-20)//2,y,21+(y-20)//3,y,'B');rect(15,y,18,y,'A')
        else:
            rect(11,22,14,28,'B');rect(19,22,22,28,'B');rect(11,22,12,26,'C');rect(19,22,20,26,'C')
        stroke(12,16,8,21,'A',1);stroke(21,16,25,20,'A',1)
        if family in ('rusted_knight','shattered_knight'):
            rect(18,5,20,8,'A');rect(22,15,27,23,'B');rect(23,16,26,21,'A');stroke(9,20,5,10,'C',1)
            if family=='shattered_knight':stroke(5,10,3,6,'G');stroke(12,7,10,3,'F')
        if family=='void_archer':
            stroke(25,8,29,17,'F');stroke(29,17,25,25,'F');stroke(25,8,25,25,'C');stroke(20,16,30,16,'G')
        if family=='warped_mage':
            for y in range(4,10):rect(8+y//2,y,24-y//2,y,'B')
            rect(9,10,24,11,'A');rect(24,17,28,21,'E');rect(25,17,27,18,'G')
        if family=='mute_librarian':
            stroke(8,18,7,12,'D');rect(4,18,8,23,'B');rect(5,19,7,22,'F');rect(14,12,19,12,'B')
        if family=='library_warden':
            for x,y in [(5,7),(25,6),(4,17),(27,19)]:rect(x,y,x+3,y+4,'D');rect(x+1,y+1,x+2,y+3,'C')
            rect(11,17,13,24,'G');rect(17,20,19,26,'G')
        if family in ('soul_devourer','devourer_clone'):
            stroke(17,5,15,9,'F');stroke(15,9,18,12,'F');stroke(18,12,16,14,'F')
            for x,y in [(6,7),(25,5),(28,24)]:stroke(x,y,x+1,y+2,'G')
        if family=='mirror_shade':
            stroke(12,5,9,2,'F');stroke(21,6,25,2,'F');stroke(12,17,7,13,'G');stroke(20,20,28,24,'G')
    if size==48:
        return g[(np.arange(48)*32//48)[:,None],(np.arange(48)*32//48)[None,:]]
    return g


def render_map(family,variant,out):
    size=48 if variant['kind']==2 else 32
    keys=palette(family,COLORS[variant['element']]);grid=pixel_grid(family,size)
    rig_dir=DESIGN/family/'4_rig2d';rig_dir.mkdir(parents=True,exist_ok=True)
    path=rig_dir/f"map_{variant['id']}_base.txt"
    if not path.exists():
        path.write_text('# Editable pixel grid; O=#141018. Palette in enemy_cast.py.\n'+'\n'.join(''.join(row) for row in grid)+'\n')
    base=P.read_grid(path,keys,size)
    sheet=np.zeros((size*3,size*6,4),np.float32);entries=[];preview={}
    for row,(action,count) in enumerate([('idle',4),('run',6),('windup',3)]):
        frames=[]
        for i in range(count):
            dx=0;dy=round(math.sin(math.tau*i/count)) if family in FLOATING else 0
            f=P.shift(base,dy,dx)
            if action=='run':
                f=P.shift(f,-(i%3==1),0)
                if family not in FLOATING:
                    f[-7:]=P.shift(f[-7:],0,[-1,0,1,1,0,-1][i])
            if action=='windup':
                f=P.shear(f,i-1,size-4)
            f=P.outline(f);frames.append(f)
            sheet[row*size:(row+1)*size,i*size:(i+1)*size]=f
            entries.append(dict(action=action,dir='e',index=i,x=i*size,y=row*size))
        preview[action]=frames
    out.mkdir(parents=True,exist_ok=True)
    (out/'preview').mkdir(exist_ok=True)
    meta=dict(asset_id=variant['id'],mode='map',frame_size=[size,size],anchor=[.5,.875],fps=12,
              loop=['idle','run'],frames=entries,source='editable pixel grids in 4_rig2d/')
    R.save_png(out/f"map_{variant['id']}.png",fit_map_sheet(sheet,meta))
    (out/f"map_{variant['id']}.json").write_text(json.dumps(meta,indent=1))
    for action,frames in preview.items():
        rendered=[]
        for f in frames:
            bg=f.copy();bg[...,:3]=f[...,:3]*f[...,3:4]+np.array([.16,.17,.22])*(1-f[...,3:4]);bg[...,3]=1
            rendered.append((bg.repeat(4,0).repeat(4,1)*255+.5).astype(np.uint8))
        write_gif(out/'preview'/f'map_{action}.gif',rendered,12)


def build(family,resume=False):
    variants=enemies(family)
    for phase in range(1,PHASES.get(family,1)+1):
        ident=family if phase==1 else f'{family}-p{phase}'
        if (DESIGN/family/'5_render'/f'battle_{ident}.json').exists() and (resume or family not in ANATOMY):continue
        R.run(rig_config(family,phase))
    render_transitions(family)
    for variant in variants:
        out=DESIGN/family/'5_render'/variant['id']
        out.mkdir(parents=True,exist_ok=True)
        for phase in range(1,PHASES.get(family,1)+1):
            src_id=family if phase==1 else f'{family}-p{phase}'
            dest_id=variant['id'] if phase==1 else f"{variant['id']}-p{phase}"
            src=DESIGN/family/'5_render'/f'battle_{src_id}.json'
            meta=json.loads(src.read_text());meta['asset_id']=variant['id']
            image=R.load_rgba(src.with_suffix('.png'))
            image=recolor(image,family,COLORS[variant['element']])
            R.save_png(out/f'battle_{dest_id}.png',image)
            (out/f'battle_{dest_id}.json').write_text(json.dumps(meta,indent=1))
        # Keep the existing hand-drawn pixel art for the first three families.
        original=DESIGN/family/'5_render'/f'map_{family}.json'
        if family not in ANATOMY and original.exists():
            meta=json.loads(original.read_text());meta['asset_id']=variant['id']
            image=recolor(R.load_rgba(original.with_suffix('.png')),family,COLORS[variant['element']])
            image=add_map_windup(image,meta)
            R.save_png(out/f"map_{variant['id']}.png",fit_map_sheet(image,meta))
            (out/f"map_{variant['id']}.json").write_text(json.dumps(meta,indent=1))
        else:render_map(family,variant,out)
    from enemy_vfx import render_vfx
    render_vfx(family,variants,skills(family))
    print(f'COMPLETE {family}: {len(variants)} variants, {PHASES.get(family,1)} phases',flush=True)


def fit_map_sheet(sheet,meta):
    """Fit the whole motion envelope with two empty pixels on each edge."""
    size=meta['frame_size'][0];frames=[]
    x0=y0=size;x1=y1=0
    for fr in meta['frames']:
        f=sheet[fr['y']:fr['y']+size,fr['x']:fr['x']+size];frames.append(f)
        ys,xs=np.nonzero(f[...,3]>.5)
        x0=min(x0,xs.min());x1=max(x1,xs.max());y0=min(y0,ys.min());y1=max(y1,ys.max())
    if x0>=2 and y0>=2 and x1<size-2 and y1<size-2:return sheet
    w,h=x1-x0+1,y1-y0+1;scale=min(1,(size-4)/max(w,h))
    tw,th=max(1,round(w*scale)),max(1,round(h*scale));ox=(size-tw)//2;oy=size-3-th
    out=np.zeros_like(sheet)
    ys=np.minimum(h-1,np.arange(th)*h//th);xs=np.minimum(w-1,np.arange(tw)*w//tw)
    for fr,f in zip(meta['frames'],frames):
        resized=f[y0:y1+1,x0:x1+1][ys[:,None],xs[None,:]]
        out[fr['y']+oy:fr['y']+oy+th,fr['x']+ox:fr['x']+ox+tw]=resized
    return out


def add_map_windup(sheet,meta):
    if any(fr['action']=='windup' for fr in meta['frames']):return sheet
    size=meta['frame_size'][0];row=sheet.shape[0]
    out=np.zeros((row+size,sheet.shape[1],4),np.float32);out[:row]=sheet
    first=next(fr for fr in meta['frames'] if fr['action']=='idle')
    f=sheet[first['y']:first['y']+size,first['x']:first['x']+size]
    for i in range(3):
        out[row:row+size,i*size:(i+1)*size]=P.shear(f,i-1,size-4)
        meta['frames'].append(dict(action='windup',dir='e',index=i,x=i*size,y=row))
    return out


def render_transitions(family):
    phases=PHASES.get(family,1)
    if phases==1:return
    folder=DESIGN/family/'5_render';f=768;cols=4
    sheet=np.zeros((f*3*(phases-1),f*cols,4),np.float32);entries=[]
    for phase in range(2,phases+1):
        prev_id=family if phase==2 else f'{family}-p{phase-1}'
        before=R.load_rgba(folder/f'battle_{prev_id}.png')[:f,:f]
        after=R.load_rgba(folder/f'battle_{family}-p{phase}.png')[:f,:f]
        previews=[]
        for i in range(12):
            blend=max(0,min(1,(i-3)/5));a=before[...,3:4]*(1-blend)+after[...,3:4]*blend
            frame=np.zeros_like(before);frame[...,3:4]=a
            frame[...,:3]=(before[...,:3]*before[...,3:4]*(1-blend)+after[...,:3]*after[...,3:4]*blend)/np.maximum(a,1e-6)
            x=i%cols*f;y=((phase-2)*3+i//cols)*f;sheet[y:y+f,x:x+f]=frame
            entries.append(dict(action=f'phase{phase}',dir='',index=i,x=x,y=y))
            bg=frame[::4,::4].copy();bg[...,:3]=bg[...,:3]*bg[...,3:4]+np.array([.16,.17,.22])*(1-bg[...,3:4]);bg[...,3]=1
            previews.append((bg*255+.5).astype(np.uint8))
        write_gif(folder/'preview'/f'battle_phase{phase}.gif',previews,12)
    path=folder/f'battle_{family}-transitions.png';R.save_png(path,sheet)
    path.with_suffix('.json').write_text(json.dumps(dict(asset_id=family,mode='battle',frame_size=[f,f],
        anchor=[.5,.83],fps=12,loop=[],frames=entries),indent=1))


if __name__=='__main__':
    args=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
    parser=argparse.ArgumentParser();parser.add_argument('--family',required=True);parser.add_argument('--resume',action='store_true')
    a=parser.parse_args(args);build(a.family,a.resume)

"""Enemy-specific spell effects, exported as small atlases with timing metadata."""
import json
import math
from pathlib import Path

import numpy as np
import rig2d as R
import vfx2d as V
from make_gif import write_gif


def motif(skill):
    for keys,value in [
        (('bite','steal'),'bite'),(('claw','slash','sweep','cut','lash','strike'),'slash'),
        (('guard','veil','copy'),'shield'),(('seal','curse','hex','mark'),'seal'),
        (('books','spawn','call'),'summon'),(('pages','shred','book','hush'),'pages'),
        (('freeze','shards','avalanche','charge'),'ice'),(('flare','meltdown','stoke'),'fire'),
        (('swallow','devour','shadow','pulse','wail'),'void'),(('shot','snipe','bolt'),'bolt'),
    ]:
        if any(k in skill for k in keys):return value
    return 'burst'


def effect(skill,layer,i,n,color):
    screen=layer=='screen';w,h=(1024,576) if screen else (512,512)
    c=V.Canvas(w,h,ss=1);main=V.hexc(color);light=np.minimum(1,main*.5+.5);dark=main*.42
    bands=[(0,dark),(-2,main),(-5,light)]
    t=i/max(1,n-1);alpha=min(1,t*5+.25)*max(0,1-t)**.7
    x,y=(w/2,h*.53) if screen else ((256,270) if layer=='hit' else (180,300))
    kind=motif(skill)
    if screen:
        V.ring(c,x,y,40+270*t,14,bands,alpha*.30,sy=.56)
        for k in range(7):
            a=k*math.tau/7+t*2;xx=x+math.cos(a)*(60+220*t);yy=y+math.sin(a)*(40+100*t)
            V.star(c,xx,yy,10+4*(k%2),[(0,main),(-2,light)],alpha*.45,rot=a)
    elif kind=='bite':
        for k in range(6):
            xx=x+(k-2.5)*26;off=35 if k%2 else -35
            V.polygon(c,[(xx-11,y+off),(xx+11,y+off),(xx,y+off*.25)],bands,alpha)
        V.ring(c,x,y,40+55*t,8,bands,alpha*.6,sy=.6)
    elif kind=='slash':
        for k in range(3):
            V.capsule(c,x-85+24*k+35*t,y+65,x+48+24*k,y-80,8,2,bands,alpha)
        for k in range(5):V.star(c,x+math.cos(k*1.4)*100*t,y+math.sin(k*1.4)*90*t,9,[(0,main),(-2,light)],alpha)
    elif kind=='shield':
        V.polygon(c,[(x-75,y-90),(x+75,y-90),(x+60,y+30),(x,y+90),(x-60,y+30)],
                  [(0,main),(-5,light),(-10,dark)],alpha*.65)
        V.ring(c,x,y+90,60+15*t,5,bands,alpha*.7,sy=.25)
    elif kind=='seal':
        V.ring(c,x,y,60+7*math.sin(t*math.pi),7,bands,alpha)
        V.capsule(c,x-43,y-43,x+43,y+43,5,5,[(0,V.hexc('#C44B64'))],alpha)
        V.capsule(c,x+43,y-43,x-43,y+43,5,5,[(0,V.hexc('#C44B64'))],alpha)
        for k in range(4):
            a=k*math.pi/2;V.star(c,x+math.cos(a)*90,y+math.sin(a)*90,12,bands,alpha,rot=t*3)
    elif kind in ('pages','summon'):
        for k in range(6):
            a=k*math.tau/6+t*2;r=25+80*t;xx=x+math.cos(a)*r;yy=y+math.sin(a)*r
            V.polygon(c,[(xx-13,yy-20),(xx+18,yy-14),(xx+13,yy+20),(xx-18,yy+14)],
                      [(0,dark),(-2,main if kind=='summon' else V.hexc('#EDE4CF'))],alpha)
        V.ring(c,x,y+85,40+40*t,6,bands,alpha*.7,sy=.4)
    elif kind=='ice':
        for k in range(5):
            xx=x+(k-2)*32;yy=y+40-70*t+15*(k%2)
            V.polygon(c,[(xx,yy-60),(xx+12,yy),(xx,yy+35),(xx-12,yy)],[(0,main),(-3,light)],alpha)
        V.ring(c,x,y+70,35+75*t,7,bands,alpha*.55,sy=.35)
    elif kind=='fire':
        for k in range(7):
            xx=x+math.sin(k*3.1)*45;yy=y+50-t*95-(k%3)*13
            V.drop(c,xx,yy,14+7*(k%3),48+t*22,-math.pi/2,bands,alpha)
        V.ring(c,x,y+70,25+80*t,9,bands,alpha*.7,sy=.36)
    elif kind=='void':
        V.ellipse(c,x,y,30+30*math.sin(t*math.pi),80,[(0,main),(-5,V.hexc('#171122'))],alpha)
        for k in range(7):
            a=k*math.tau/7+t*3;r=110*(1-t)+22
            V.star(c,x+math.cos(a)*r,y+math.sin(a)*r,11,[(0,main),(-2,light)],alpha,rot=a)
    elif kind=='bolt':
        V.polyline(c,[(x-100+50*t,y+15),(x-25,y-20),(x+10,y+12),(x+105,y-35)],
                   [2,7,7,1],bands,alpha)
        V.star(c,x+80,y-25,23,bands,alpha,rot=t)
    else:
        V.ring(c,x,y,15+90*t,10,bands,alpha)
        for k in range(8):
            a=k*math.tau/8;V.drop(c,x+math.cos(a)*90*t,y+math.sin(a)*90*t,6,25,a,bands,alpha)
    return c.result()


def atlas(out,ident,skill,layer_groups,color):
    # Keep each atlas below hardware texture limits and bound renderer memory.
    (out/'preview').mkdir(exist_ok=True)
    fw,fh=(1024,576) if layer_groups==['screen'] else (512,512)
    cols=4;n=8;rows=len(layer_groups)*2
    sheet=np.zeros((fh*rows,fw*cols,4),np.float32);frames=[]
    for group,layer in enumerate(layer_groups):
        animation=skill if layer=='hit' else f'{skill}-{layer}'
        imgs=[]
        for i in range(n):
            f=effect(skill,layer,i,n,color);x=(i%cols)*fw;y=(group*2+i//cols)*fh
            sheet[y:y+fh,x:x+fw]=f
            frames.append(dict(action=animation,dir='',index=i,x=x,y=y))
            if layer=='hit':
                preview=f[::4,::4].copy();preview[...,:3]=f[::4,::4,:3]*f[::4,::4,3:4]+np.array([.16,.17,.22])*(1-f[::4,::4,3:4]);preview[...,3]=1
                imgs.append((preview*255+.5).astype(np.uint8))
        if imgs:write_gif(out/'preview'/f'{skill}.gif',imgs,12)
    suffix='screen' if layer_groups==['screen'] else 'effects'
    png=out/f'vfx_{ident}-{skill}-{suffix}.png'
    R.save_png(png,sheet)
    meta=dict(asset_id=ident,mode='vfx',frame_size=[fw,fh],anchor=[.5,.84],fps=12,frames=frames,loop=[])
    png.with_suffix('.json').write_text(json.dumps(meta,indent=1))


def render_vfx(family,variants,skill_specs):
    from enemy_cast import COLORS,DESIGN
    for variant in variants:
        out=DESIGN/family/'6_vfx'/variant['id'];out.mkdir(parents=True,exist_ok=True)
        metadata={}
        for skill in variant['skills']:
            spec=skill_specs.get(skill)
            if spec is None:
                base=skill.rsplit('_',1)[0]
                spec=skill_specs[base]
            action=spec['action'];hit=4 if action in ('attack','down') else (3 if action in ('guard','swallow','curse') else 6)
            metadata[skill]={**spec,'hit_frame':hit,'fps':12,'effect_frames':8,'element_color':COLORS[variant['element']],
                             'screen':variant['kind']==2 or any(k in skill for k in ('storm','hush','burst'))}
            color=COLORS[variant['element']]
            atlas(out,variant['id'],skill,['cast','hit'],color)
            if metadata[skill]['screen']:atlas(out,variant['id'],skill,['screen'],color)
        (out/'skills.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2))
    print(f'{family}: VFX for {len(skill_specs)} skills × {len(variants)} variants',flush=True)

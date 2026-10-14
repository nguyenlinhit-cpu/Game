"""Distinct procedural effects for the final eleven playable skins.

Geometry and timing follow each character's ANIMATION_SPEC.md. Shared drawing
primitives live in vfx2d.py; this module keeps projectile, buff and impact motifs
consistent across battle and map. No game assets are modified.
"""
import importlib.util
import math
from pathlib import Path
import random
import numpy as np
import vfx2d as V
from vfx2d import Canvas, hexc, circle, ellipse, ring, capsule, polyline, polygon, star, star5, leaf, cloud, bubble, shard, arrow_up, fade, blit

ROOT=Path(__file__).resolve().parents[1]
PALETTES={
 'soul':dict(main='#F2D58A',light='#FFF1C6',mid='#EADFAC',deep='#A87938',core='#FFFFF4'),
 'nature':dict(main='#2E8B57',light='#D6F4B7',mid='#7BCB80',deep='#185237',core='#F5FFE8'),
 'wind':dict(main='#4FD1B5',light='#D7FAF4',mid='#9CE5DB',deep='#278A83',core='#FAFFFE'),
 'poison':dict(main='#9BC53D',light='#E9F6C0',mid='#C8DC81',deep='#536C30',core='#FFFFE9'),
 'fire':dict(main='#E8552B',light='#FFE6A4',mid='#FFAA4D',deep='#9D3023',core='#FFFCE8'),
 'water':dict(main='#3A8DDE',light='#D7F4FF',mid='#8CD9F4',deep='#235D9F',core='#F8FFFF'),
 'lightning':dict(main='#A65BF2',light='#EED8FF',mid='#CE99FF',deep='#6736AA',core='#FFFAFF'),
}
ELEMENT={'fenna':'nature','kestrel':'wind','neris':'water','pip':'lightning','ember':'fire','selka':'poison','vael':'poison','wisp':'wind','echo':'soul','traveler_male':'soul','traveler_female':'soul'}
PINK=hexc('#EDA8CD'); PURPLE=hexc('#A68BD0'); GOLD=hexc('#F2D58A'); SILVER=hexc('#E5EAF5'); RED=hexc('#DF7664')


def bands(w):return V.bands(w)
def stroke(c,pts,w=5,al=1,col=None):
 polyline(c,pts,[w]*len(pts),bands(w) if col is None else [(0,col),(-w*.5,V.CORE)],al)
def arc(c,x,y,r,angle=0,span=4,w=5,al=1,sy=1):
 pts=[(x+math.cos(angle+span*k/24)*r,y+math.sin(angle+span*k/24)*r*sy) for k in range(25)]
 polyline(c,pts,[max(.5,w*math.sin(math.pi*k/24)) for k in range(25)],bands(w),al)
def swirl(c,x,y,r,i,al=1):
 for k in range(3):arc(c,x,y-k*8,r-k*10,i*.7+k*2,3.3,5,al,.32)
def lightning(c,a,b,i,w=5,al=1,col=None):
 rnd=random.Random(11+i);pts=[a]
 for k in range(1,8):
  t=k/8;pts.append((a[0]+(b[0]-a[0])*t+rnd.uniform(-10,10),a[1]+(b[1]-a[1])*t+rnd.uniform(-15,15)))
 pts.append(b);stroke(c,pts,w,al,col)
def arrow(c,x,y,ang=0,s=1,al=1):
 dx,dy=math.cos(ang),math.sin(ang);nx,ny=-dy,dx
 stroke(c,[(x-80*s*dx,y-80*s*dy),(x,y)],3*s,al)
 polygon(c,[(x+18*s*dx,y+18*s*dy),(x-12*s*dx+12*s*nx,y-12*s*dy+12*s*ny),(x-5*s*dx,y-5*s*dy),(x-12*s*dx-12*s*nx,y-12*s*dy-12*s*ny)],[(0,V.MAIN),(-3*s,V.LIGHT)],al)
 for sign in (-1,1):stroke(c,[(x-60*s*dx+sign*12*s*nx,y-60*s*dy+sign*12*s*ny),(x-40*s*dx,y-40*s*dy)],2*s,al)
def card(c,x,y,s=1,rot=0,al=1):
 pts=[]
 for xx,yy in [(-17,-27),(17,-27),(17,27),(-17,27)]:pts.append((x+s*(xx*math.cos(rot)-yy*math.sin(rot)),y+s*(xx*math.sin(rot)+yy*math.cos(rot))))
 polygon(c,pts,[(0,GOLD),(-3*s,V.DARK)],al);star(c,x,y,9*s,[(0,V.MAIN)],al,rot)
def eye(c,x,y,s=1,op=1,al=1):
 ellipse(c,x,y,100*s,max(2,42*s*op),[(0,V.MAIN),(-5*s,V.LIGHT),(-10*s,V.DARK)],al)
 ellipse(c,x,y,12*s,max(1,30*s*op),[(0,V.CORE)],al)
def battery(c,x,y,s=1,fill=1,al=1):
 polygon(c,[(x-45*s,y-20*s),(x+45*s,y-20*s),(x+45*s,y+20*s),(x-45*s,y+20*s)],[(0,GOLD),(-4*s,V.DARK)],al)
 polygon(c,[(x-37*s,y-12*s),(x-37*s+74*s*min(1,fill),y-12*s),(x-37*s+74*s*min(1,fill),y+12*s),(x-37*s,y+12*s)],[(0,V.MAIN)],al)
 capsule(c,x+47*s,y-7*s,x+47*s,y+7*s,3*s,3*s,[(0,GOLD)],al)
def cracks(c,x,y,i,s=1,al=1,col=None):
 rnd=random.Random(31)
 for k in range(7):
  a=k*math.tau/7;rr=(55+min(i,4)*18)*s
  p=(x+math.cos(a)*rr*.4,y+math.sin(a)*rr*.4)
  q=(x+math.cos(a+.15)*rr,y+math.sin(a+.15)*rr)
  stroke(c,[(x,y),p,(p[0]+rnd.uniform(-15,15),p[1]+rnd.uniform(-15,15)),q],3*s,al,col)
def motes(c,x,y,i,kind='star',count=10,al=1,r=100):
 rnd=random.Random(42)
 for k in range(count):
  a=rnd.random()*math.tau;rr=rnd.uniform(.3,1)*(r+12*i);xx=x+math.cos(a)*rr;yy=y+math.sin(a)*rr-i*7
  if kind=='leaf':leaf(c,xx,yy,10,i*.3+a,bands(10),al)
  elif kind=='shard':shard(c,xx,yy,12,a+i*.2,al)
  elif kind=='bubble':bubble(c,xx,yy,6+k%6,al)
  else:star(c,xx,yy,6+k%5,bands(8),al)
def fire(c,x,y,s,i,al=1):
 for k in range(5):
  dx=(k-2)*s*.32;yy=y-s*.1*(k%2)
  V.drop(c,x+dx,yy,s*.25,s*(.5+.15*((k+i)%3)),-math.pi/2,bands(s*.25),al)
 c.glow(x,y-s*.2,s*.7,V.MID,.35*al)
def debuff(c,x,y,kind,al=1):
 if kind=='slow':
  ring(c,x,y,20,3,[(0,PURPLE)],al);stroke(c,[(x,y-13),(x,y),(x+12,y+5)],3,al,PURPLE)
 elif kind=='attack_down':
  arrow_up(c,x,y,22,[RED,RED,SILVER],al)
  stroke(c,[(x-22,y-20),(x+22,y+20)],4,al,PURPLE)
 else:
  eye(c,x,y,.3,.6,al);cracks(c,x,y,0,.25,al,PURPLE)


class Effects:
 def __init__(self,ident,anchors):self.id=ident;self.anchors=anchors
 def cast(self,action,i):
  c=Canvas(512,512);ident=self.id;n={'attack':8,'skill':10,'ultimate':12}[action];hit={'attack':4,'skill':6,'ultimate':8}[action]
  x,y=self.anchors[action][i];charge=min(1,(i+1)/max(1,hit-1));power=1 if action=='attack' else 1.4 if action=='skill' else 2
  if i<hit:
   if ident=='fenna':
    if action=='ultimate':
     for k in range(6):leaf(c,x+math.cos(i*.5+k)*35,y+math.sin(i*.5+k)*25,8,k+i*.2,bands(8),.8)
    if i>=hit-2:arrow(c,min(465,x+25+(i-hit+2)*45),y,0,.65 if action!='ultimate' else 1.2)
   elif ident=='kestrel':
    if i>=hit-3:
     for k in range(2):arc(c,260,300,100+20*k,i*.7+k*math.pi,2.8,6,.8)
   elif ident=='neris':
    swirl(c,x-25,y,30+25*charge,i,.8)
    if action=='ultimate':
     ellipse(c,256,420,130,40,bands(10),.45);swirl(c,256,360,125,i,.8)
   elif ident=='pip':
    c.glow(x,y,40+20*charge,V.MAIN,.5)
    if action=='attack' and i>=hit-2:lightning(c,(x,y),(510,y-10),i)
    if action=='skill':battery(c,x,y-50,.65,charge,.9)
    if action=='ultimate':
     # Lever with a moving handle, drawn locally so it reads in the cast preview.
     capsule(c,190,405,220+35*charge,325,7,7,[(0,SILVER)]);circle(c,220+35*charge,325,15,[(0,GOLD)])
     ring(c,x,y,40+40*charge,5,bands(5),.7)
   elif ident=='ember':
    fire(c,x,y-20,35*charge*power,i,.9)
    if action=='ultimate':ring(c,256,130,90+10*charge,5,bands(5),.9,sy=.35)
    if action=='attack' and i>=hit-2:fire(c,min(480,x+100*(i-hit+2)),y,28,i)
   elif ident=='selka':
    for k in range(3):
     arc(c,x,y-k*23,30+12*k,i*.5+k,3,4,.6,.6)
    if action=='attack' and i>=2:capsule(c,min(480,x+70*(i-1)),y,min(500,x+80*(i-1)+40),y-6,2,1,[(0,GOLD)],.95)
   elif ident=='vael':
    if action=='attack':card(c,min(480,x+max(0,i-1)*65),y-20,charge*.8,i*.6)
    elif action=='skill':cloud(c,x,y-50,80,45,7,.6*charge)
    else:
     polygon(c,[(80,70),(430,70),(340,450),(170,450)],[(0,GOLD)],.1*charge)
     for k in range(5):card(c,140+k*50,170+math.sin(i+k)*30,.5,i*.3,.8)
   elif ident=='wisp':
    arc(c,x+25+20*i,y,30+10*i,-1.5,3,4,.5,.6)
    if action!='attack':
     for k in range(4):star(c,x+40*math.cos(k+i*.4),y-25+30*math.sin(k+i*.4),5,[(0,PURPLE)],.6)
   elif ident=='echo':
    if action=='attack':motes(c,x,y,i,'shard',5,.7,25)
    elif action=='skill' and i>=hit-2:stroke(c,[(x,y),(510,y+20)],5,.9)
    else:
     for k in range(9):
      a=k*math.tau/9+i*.25;shard(c,256+math.cos(a)*150,260+math.sin(a)*140,15,a,.8)
   else:  # Travelers: soul shard charge, extended sword and eye.
    if action=='skill':
     ring(c,265,250,25+charge*60,5,bands(5),.9)
    elif action=='ultimate':eye(c,256,190,1.7,charge,.75)
    if i>=hit-2:arc(c,260,320,125,i*.45,2.5,7,.9)
  if hit-1<=i<=hit+1 and ident in ('fenna','neris','kestrel'):
   if ident=='fenna':arrow(c,450,265,-.15 if action=='attack' else -.5,.9)
   elif ident=='neris':swirl(c,400,270,75,i,.85)
   else:arc(c,315,295,130,i*.6,4,8,.85)
  return c.result()

 def impact(self,action,i):
  c=Canvas(512,512);ident=self.id;al=fade(i,8,.4);x,y=256,275;power={'attack':1,'skill':1.4,'ultimate':2}[action]
  if ident=='fenna':
   if action=='skill':
    for k in range(6):arrow(c,185+k*28,150+min(270,i*42)+(k%2)*20,math.pi/2,.65,al)
   elif action=='ultimate':arrow(c,130+i*70,y,0,2,al);stroke(c,[(40,y),(470,y)],9,al)
   motes(c,x,y,i,'leaf',12,al,70)
  elif ident=='kestrel':
   for k in range(2 if action=='attack' else 6):arc(c,x,y,65+16*k,i*.6+k*1.4,3.3,8,al)
   if action=='skill':
    for xx in (35,477):swirl(c,xx,y,75,i,al*.6)
  elif ident=='neris':
   if action=='ultimate':
    for k in range(4):swirl(c,x,y+125-k*70,65+15*k,i,al)
    capsule(c,x,420,x,80,20,8,bands(18),al*.8);star(c,x,135,45,[(0,GOLD)],al)
   else:
    swirl(c,x,y,50+15*i,i,al);stroke(c,[(80,y+20),(430,y-10)],7*power,al)
   motes(c,x,y,i,'bubble',12,al,80)
  elif ident=='pip':
   if action=='attack':
    for k in range(6):
     a=k*math.tau/6;lightning(c,(x,y),(x+math.cos(a)*(60+12*i),y+math.sin(a)*(60+12*i)),k,5,al)
   elif action=='skill':
    battery(c,x,y-120,1.1,min(1,(i+2)/5),al);arrow_up(c,x+80,y-60,40,[RED,RED,SILVER],al)
    lightning(c,(x-90,y+75),(x+70,y-100),i,4,al,GOLD)
   else:
    ring(c,x,y,65+20*i,9,bands(9),al)
    for k in range(4):stroke(c,[(x-100,y+k*24),(x+80,y+k*24-40)],3,al,GOLD)
  elif ident=='ember':
   if action=='attack':fire(c,x,y,75+8*i,i,al)
   elif action=='skill':
    for k in range(6):fire(c,60+k*80,410,80+12*math.sin(k+i),i,al)
   else:
    if i<3:
     capsule(c,x-100+40*i,40+80*i,x-30+40*i,145+80*i,22,44,bands(24),al)
    fire(c,x,y+90,130+i*7,i,al);ring(c,x,410,45+22*i,8,bands(8),al,sy=.3)
  elif ident=='selka':
   for k,col in enumerate((V.MAIN,PINK,PURPLE)):
    arc(c,x,y+55-k*50,90+7*i,i*.5+k*2,4.5,15,al*.65,.5)
   if action!='attack':
    arrow_up(c,x,y-100,45,[RED,RED,SILVER],al)
    if action=='ultimate':
     for k in range(7):
      a=k*math.tau/7;ellipse(c,x+math.cos(a)*55,y+math.sin(a)*55,25,40,[(0,PINK)],al*.4)
     star(c,x,y,25,bands(20),al)
  elif ident=='vael':
   cloud(c,x,y+60,110*power,70*power,55,al*.65)
   if action!='attack':
    cloud(c,x+50,y-30,125,70,20,al*.4)
    for k in range(7):card(c,x+math.cos(k)*120,y+math.sin(k)*100,.7,k+i*.3,al)
  elif ident=='wisp':
   for k in range(3):arc(c,x,y-k*30,85+8*i,i*.5+k*2,4,9,al*.6,.4)
   if action!='attack':
    debuff(c,x-45,y-110,'slow',al);debuff(c,x+45,y-110,'attack_down',al)
  elif ident=='echo':
   if action=='skill':cracks(c,x,y,i,1.2,al,PURPLE);debuff(c,x,y-125,'soul',al)
   else:motes(c,x,y,i,'shard',18,al,80)
   if action=='ultimate':
    for k in range(3):
     a=i*.6+k*math.tau/3;debuff(c,x+math.cos(a)*95,y+math.sin(a)*95,'soul',al)
  else:
   if action=='attack':
    stroke(c,[(140,170),(370,390)],8,al);stroke(c,[(150,380),(360,180)],6,al)
   elif action=='skill':
    for xx,s in [(256,1.3),(20,.6),(492,.6)]:cracks(c,xx,400,i,s,al)
   else:
    capsule(c,x,40,x,460,16,22,bands(18),al);cracks(c,x,320,i,1.4,al)
   motes(c,x,y,i,'shard',9,al,85)
  return c.result()

 def screen(self,i):
  c=Canvas(1024,576,ss=1);ident=self.id;al=fade(i,12,.55);rise=min(1,(i+1)/3)
  if ident.startswith('traveler'):
   c.tint(hexc('#111426'),.7*al);eye(c,512,240,3.4,rise*(1 if i<7 else max(0,(11-i)/4)),.7*al)
  elif ident=='fenna':
   if 2<=i<=7:arrow(c,-150+i*180,295,0,3,al);stroke(c,[(0,295),(1024,295)],8,.5*al)
  elif ident=='kestrel':
   for k in range(6):arc(c,600,100+k*70,170-k*18,i*.7+k,5,9,al*.7,.3)
   motes(c,610,300,i,'leaf',18,al,300)
  elif ident=='neris':
   c.tint(hexc('#153C68'),.28*al)
   for k in range(8):bubble(c,100+k*120,550-(i*43+k*65)%550,12+k%4*5,.6*al)
   for k in range(5):polygon(c,[(170+k*170,0),(210+k*170,0),(380+k*150,576),(290+k*150,576)],[(0,V.LIGHT)],.08*al)
  elif ident=='pip':
   battery(c,512,65,2.4,rise,al)
   for k in range(4):lightning(c,(20,100+k*135),(1000,100+k*135),i+k,3,.45*al,GOLD)
  elif ident=='ember':
   c.tint(hexc('#611E28'),.24*al)
   for k in range(5):
    x=130+k*200+(i%6)*30;y=-120+(i%6)*120-k*25
    capsule(c,x-70,y-100,x,y,7,24,bands(18),.8*al)
  elif ident=='selka':
   for k in range(7):
    x=100+k*150;y=310+60*math.sin(k+i*.3)
    for petal in range(5):
     a=petal*math.tau/5;ellipse(c,x+math.cos(a)*35,y+math.sin(a)*35,25,25,[(0,PINK if k%2 else V.MID)],.2*al)
  elif ident=='vael':
   # Theatre curtains framing the stage, spotlight and spinning cards.
   for xx in (0,820):polygon(c,[(xx,0),(xx+204,0),(xx+170,576),(xx+30,576)],[(0,hexc('#6E1C3A'))],.8*al)
   polygon(c,[(500,0),(560,0),(860,576),(180,576)],[(0,GOLD)],.1*al)
   for k in range(8):card(c,200+k*90,100+(k*79+i*40)%420,.7,i*.3+k,.7*al)
  elif ident=='wisp':
   c.tint(V.LIGHT,.14*al)
   for k in range(4):cloud(c,100+k*280,60 if k%2==0 else 530,230,70,k,.3*al)
  elif ident=='echo':
   cracks(c,550,270,min(i,11-i),4,.65*al,SILVER)
   for k in range(10):shard(c,120+k*90,160+(k*55)%280,22,k+i*.1,.6*al)
  return c.result()

 def map(self,name,i):
  px=np.zeros((64,64,4),np.float32);ident=self.id
  def put(x,y,ch='L'):blit(px,[ch],round(x),round(y))
  def line(x0,y0,x1,y1,ch='L'):
   n=max(abs(round(x1-x0)),abs(round(y1-y0)),1)
   for k in range(n+1):put(x0+(x1-x0)*k/n,y0+(y1-y0)*k/n,ch)
  def ringpx(x,y,r,ch='M',sy=1):
   for a in range(0,360,7):put(x+math.cos(math.radians(a))*r,y+math.sin(math.radians(a))*r*sy,ch)
  if name=='opener':
   if i<2:blit(px,['.L.','LCL','.L.'],30,36)
   else:
    r=[9,17,24][i-2];ch='C' if i==2 else 'M' if i==3 else 'm'
    if ident in ('fenna','neris'):
     line(30,39,32+r,37,ch);line(32+r,37,28+r,34,ch);line(32+r,37,28+r,40,ch)
     if ident=='neris':ringpx(34+r,38,4,'L',.8)
    elif ident=='pip':
     for k in range(5):line(30+k*5,38+(k%2)*4,35+k*5,42-(k%2)*4,ch)
     blit(px,['.LL.','LCCL','LCCL','.LL.'],31+r,36)
    else:
     span={'kestrel':150,'wisp':100,'selka':100,'vael':110,'echo':100,'ember':90}.get(ident,120)
     for a in range(-span//2,span//2+1,8):
      xx=31+math.cos(math.radians(a))*r;yy=39+math.sin(math.radians(a))*r
      if ident in ('echo','vael'):blit(px,['.L','MC','M.'],round(xx),round(yy))
      elif ident=='ember':blit(px,['.C.','LML','.M.'],round(xx),round(yy))
      else:put(xx,yy,ch)
     if ident=='kestrel':ringpx(38,40,r*.55,'L',.7)
  elif ident=='fenna':
   if i>=2:
    ringpx(20,51,8,'D',.35);line(14,50,26,53,'M')
    if i>=4:line(14,49,23,34,'L');line(25,50,17,35,'L')
  elif ident=='pip':
   blit(px,['LLLLLLLLL','L.......L','L.......L','LLLLLLLLL'],12,10)
   for k in range(min(7,i+1)):
    put(13+k,11,'M');put(13+k,12,'M')
   if i>=2:blit(px,['.C.','CL.','.LC','..C'],26,17)
  elif ident=='neris':
   ringpx(16,51,5+i*4,'M',.35)
   if i>=2:blit(px,['LCL'],21,31)
  elif ident=='ember':
   if i>=2:
    for k in range(12):
     xx=4+(k*7)%50;yy=18+(k*13+i*6)%36
     blit(px,['C','M'],xx,yy)
  elif ident=='vael':
   if i<4:
    x=22+i*9;y=31-14*math.sin(i*math.pi/4);blit(px,['.D.','MCM','.M.'],round(x),round(y))
   else:
    for k in range(7):ringpx(45,37,4+k,'M' if k%2 else 'm',.7)
  elif ident=='selka':
   ringpx(16,40,10+i*2,'M',.55)
   if i>=3:blit(px,['..C..','.CMC.','CCMCC','..M..','..M..'],14,12)
  elif ident=='echo':
   for dy in range(-14,15):
    t=math.acos(max(-1,min(1,dy/14)));xx=round(8*math.sin(t));put(20-xx,35+dy,'L');put(20+xx,35+dy,'L')
   if i>=3:
    for k in range(9):put(20+math.cos(k)*i*3,35+math.sin(k)*i*3,'C')
  elif ident=='wisp':
   for k in range(4):
    a=i*.7+k*math.pi/2;r=18-i*2;put(16+math.cos(a)*r,40+math.sin(a)*r*.5,'C');ringpx(16,43,r,'m',.6)
  else:
   if 1<=i<=4:
    for k in range(3):line(5,35+k*5,24+i*4,30+k*5,'L' if k==1 else 'M')
    if ident=='kestrel':blit(px,['..C','LL.','M..'],30+i*3,50)
  return px


def anchors_for(ident):
 path=ROOT/'nhan_vat'/ident/'4_rig2d/rig_battle.py'
 spec=importlib.util.spec_from_file_location('cast_rig_'+ident,path);mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
 from rig2d import locate
 cfg=mod.CONFIG;bone='robot_eye' if ident=='pip' else 'weapon';pt=cfg['bones'][bone]['pivot']
 queries=[(a,i,bone,pt) for a,n in [('attack',8),('skill',10),('ultimate',12)] for i in range(n)]
 pts=locate(cfg,queries);return dict(attack=pts[:8],skill=pts[8:18],ultimate=pts[18:])


def trap_assets(folder):
 """Fenna's two independent 16px trap states (waiting / sprung)."""
 from make_gif import write_gif
 out=folder/'6_vfx/technique';out.mkdir(exist_ok=True,parents=True);frames=[]
 for sprung in (False,True):
  px=np.zeros((16,16,4),np.float32)
  for a in range(0,360,15):
   x=round(7+math.cos(math.radians(a))*5);y=round(11+math.sin(math.radians(a))*2)
   V.blit(px,['M'],x,y)
  if sprung:
   for y in range(3,12):V.blit(px,['L'],4+(y%3),y);V.blit(px,['M'],10-(y%3),y)
  V.save_png(out/('trap_sprung.png' if sprung else 'trap_waiting.png'),px);frames.append(V.to_u8(V.resize(px,128,128,nearest=True)))
 write_gif(out/'trap_states.gif',frames,2)


def run_character(ident):
 V.set_palette(**PALETTES[ELEMENT[ident]])
 anchors=anchors_for(ident);fx=Effects(ident,anchors)
 battle={}
 for action,n,hit in [('attack',8,4),('skill',10,6),('ultimate',12,8)]:
  target='ally' if ident in ('pip','selka') and action!='attack' else 'enemy'
  layers={'cast':(0,n,lambda i,a=action:fx.cast(a,i)), 'hit':(hit,8,lambda i,a=action:fx.impact(a,i))}
  if action=='ultimate':layers['screen']=(6,12,fx.screen)
  battle[action]=dict(frames=n,hit_frame=hit,target=target,cutin=action=='ultimate',layers=layers)
 # Traveler has both focused and blast modes; same cast, extra side strikes.
 if ident.startswith('traveler'):
  def blast(i):
   a=fx.impact('ultimate',i);c=Canvas(512,512);al=fade(i,8,.4)
   for x in (40,472):capsule(c,x,140,x,440,8,12,bands(12),al)
   over=c.result();V.over(a,over,0,0);return a
  battle['ultimate_blast']=dict(battle['ultimate'],layers={'cast':(0,12,lambda i:fx.cast('ultimate',i)),'hit':(8,8,blast),'screen':(6,12,fx.screen)})
 V.run(dict(id=ident,element_color=PALETTES[ELEMENT[ident]]['main'],battle_anchors={'feet':(256,430),'effect_origin_per_frame':anchors,'target_center':(256,275)},map_anchors={'opener_origin':(31,39),'opener_feet':(16,52),'technique_feet':(16,52)},battle=battle,map={name:dict(frames=n,hit_frame=2 if name=='opener' else None,fn=lambda i,a=name:fx.map(a,i),char=(16,52)) for name,n in [('opener',5),('technique',6)]}))
 if ident=='fenna':trap_assets(ROOT/'nhan_vat'/ident)

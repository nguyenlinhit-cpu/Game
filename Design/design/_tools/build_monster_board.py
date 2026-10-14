from pathlib import Path
import json,textwrap
from PyQt6.QtGui import QImage,QPainter,QColor,QFont
from PyQt6.QtCore import Qt,QByteArray
W,H=3840,2160
root=Path(monster_root); data=json.loads((root/'1_concept/PROMPTS.json').read_text());meta=data['metadata']
board=krita.createDocument(W,H,meta['id']+' concept sketch v1','RGBA','U8','',120)
krita.activeWindow().addView(board)
def layer(name,draw):
 im=QImage(W,H,QImage.Format.Format_ARGB32);im.fill(Qt.GlobalColor.transparent)
 p=QPainter(im);p.setRenderHint(QPainter.RenderHint.Antialiasing);draw(p);p.end()
 n=board.createNode(name,'paintlayer');board.rootNode().addChildNode(n,None)
 n.setPixelData(QByteArray(im.bits().asstring(im.sizeInBytes())),0,0,W,H)
 return n
def label(p,x,y,t,size=26):
 p.setPen(QColor('#26354C'));p.setFont(QFont('DejaVu Sans',size));p.drawText(x,y,t)
layer('background',lambda p:p.fillRect(0,0,W,H,QColor('#F7FAFD')))
def art(asset,x,y,w,h):
 im=QImage(str(root/'1_concept'/asset))
 if im.isNull():raise RuntimeError('Missing '+asset)
 xs=[];ys=[]
 for cy in range(0,im.height(),4):
  for cx in range(0,im.width(),4):
   c=im.pixelColor(cx,cy)
   if c.alpha()>32 and min(c.red(),c.green(),c.blue())<235:xs.append(cx);ys.append(cy)
 if xs:
  pad=24;l=max(0,min(xs)-pad);t=max(0,min(ys)-pad);r=min(im.width(),max(xs)+pad);b=min(im.height(),max(ys)+pad);im=im.copy(l,t,r-l,b-t)
 mode=Qt.TransformationMode.FastTransformation if 'pixel' in asset else Qt.TransformationMode.SmoothTransformation
 im=im.scaled(w,h,Qt.AspectRatioMode.KeepAspectRatio,mode)
 return im,x+(w-im.width())//2,y+(h-im.height())//2
for name,asset,x in [('concept_battle','1a_battle.png',100),('concept_front','1b_front.png',1350),('concept_side','1b_side.png',2580)]:
 im,x,y=art(asset,x,260,1145,1110)
 layer(name,lambda p,im=im,x=x,y=y:p.drawImage(x,y,im))
items=[]
if meta['phases']:
 items=[('Giai đoạn 1','1a_battle.png')]+[(f'Giai đoạn {i}',f'1a_battle_p{i}.png') for i in range(2,len(meta['phases'])+1)]
else:items=[(v['id'],'variants/'+v['id']+'.png') for v in meta['variants']]
if meta['has_pixel']:items.append(('Pixel tham khảo','1c_pixel.png'))
cell=2300//max(1,len(items))
for i,(title,asset) in enumerate(items):
 im,x,y=art(asset,100+i*cell,1480,cell-35,400)
 name='map_pixel' if 'pixel' in asset else ('phase_'+str(i+1) if meta['phases'] else 'variant_'+title)
 layer(name,lambda p,im=im,x=x,y=y:p.drawImage(x,y,im))
def palette(p):
 for i,(name,color) in enumerate(meta['palette']):
  x=2500+(i%2)*590;y=1460+(i//2)*95
  p.fillRect(x,y,52,52,QColor(color));label(p,x+68,y+36,name.strip()+': '+color,16)
layer('palette',palette)
def notes(p):
 label(p,100,120,meta['title'],43)
 for title,x in [('Concept trận · quay trái',100),('Mặt trước · trung tính',1350),('Nhìn ngang · quay trái',2580)]:label(p,x,220,title,28)
 label(p,100,1430,'Biến thể nguyên tố' if not meta['phases'] else 'Giai đoạn boss',26)
 for i,(title,asset) in enumerate(items):label(p,100+i*cell,1925,title,17)
 label(p,2500,1415,'Bảng màu gốc',25)
 for i,line in enumerate(textwrap.wrap(meta['scale'],145)[:2]):label(p,100,2000+i*42,line,20)
 label(p,100,2120,'Chỉ concept và sketch · Pixel tham khảo · Kiểm tra hình dáng, màu nguyên tố · Vẽ đè trên your_sketch · Chờ duyệt B2.',21)
layer('notes',notes)
n=board.createNode('your_sketch','paintlayer');board.rootNode().addChildNode(n,None);board.setActiveNode(n)
board.refreshProjection();out=root/'2_sketch';out.mkdir(exist_ok=True)
assert board.saveAs(str(out/(meta['id']+'_sketch_v1.kra')))
assert board.projection(0,0,W,H).scaled(1920,1080,Qt.AspectRatioMode.KeepAspectRatio,Qt.TransformationMode.SmoothTransformation).save(str(out/(meta['id']+'_sketch_v1.png')))
result={'saved':board.fileName(),'layers':[n.name() for n in board.rootNode().childNodes()]};board.close()

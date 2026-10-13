"""Run inside Krita Python to rebuild Nyx's layered concept review board."""
from pathlib import Path
from PyQt6.QtGui import QImage, QPainter, QColor, QFont
from PyQt6.QtCore import Qt, QByteArray

W, H = 3840, 2160
import json
root = Path(character_root)
meta = json.loads((root/'1_concept/PROMPTS.json').read_text())['metadata']
board = krita.createDocument(W, H, meta['id']+' sketch v1', 'RGBA', 'U8', '', 120)
krita.activeWindow().addView(board)

def add(name, draw):
    image = QImage(W, H, QImage.Format.Format_ARGB32)
    image.fill(Qt.GlobalColor.transparent)
    painter = QPainter(image)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing)
    draw(painter)
    painter.end()
    node = board.createNode(name, 'paintlayer')
    board.rootNode().addChildNode(node, None)
    node.setPixelData(QByteArray(image.bits().asstring(image.sizeInBytes())), 0, 0, W, H)
    return node

add('background', lambda p: p.fillRect(0, 0, W, H, QColor('#F7FAFD')))

def notes(p):
    import textwrap
    p.setPen(QColor('#26354C'))
    def text(x, y, t, size=34):
        p.setFont(QFont('DejaVu Sans', size))
        p.drawText(x, y, t)
    text(100,120,meta['title'],48)
    text(100,220,'Concept trong trận',30)
    text(1350,220,'Mặt trước · A-pose',30)
    text(2580,220,'Mặt sau · A-pose',30)
    text(100,1720,'Vũ khí',24)
    text(550,1720,'Pixel tham khảo',26)
    y=1950
    for line in textwrap.wrap(meta['personality']+' '+meta['identity'],115)[:3]:
        text(1120,y,line,21); y+=44
    text(1120,2115,'Kiểm tra tay, tỷ lệ, bất đối xứng · Pixel tham khảo · Vẽ đè trên your_sketch · Chờ duyệt B2.',20)
add('notes',notes)
colors=meta['palette']
def palette(p):
    p.setFont(QFont('DejaVu Sans',20))
    for i,(name,color) in enumerate(colors):
        x=1120+(i%4)*660
        y=1660+(i//4)*85
        p.fillRect(x,y,60,60,QColor(color))
        p.setPen(QColor('#26354C'))
        p.drawText(x+76,y+42,name+': '+color)
add('palette',palette)

art = [('concept_battle','1a_battle.png',100,260,1145,1374),('concept_front','1b_front.png',1350,260,1144,1375),('concept_back','1b_back.png',2580,260,1144,1375),('weapon','1c_weapon.png',100,1750,345,410),('map_pixel','1d_pixel.png',550,1750,340,340)]
for name,file,x,y,w,h in art:
    img = QImage(str(root/'1_concept'/file))
    if img.isNull():
        raise RuntimeError('Missing image: '+file)
    # Crop outer whitespace only inside the review layout; preserve source concept files.
    xs=[];ys=[]
    for cy in range(0,img.height(),4):
        for cx in range(0,img.width(),4):
            c=img.pixelColor(cx,cy)
            if c.alpha()>32 and min(c.red(),c.green(),c.blue())<235:
                xs.append(cx);ys.append(cy)
    if xs:
        pad=24
        left=max(0,min(xs)-pad); top=max(0,min(ys)-pad)
        right=min(img.width(),max(xs)+pad); bottom=min(img.height(),max(ys)+pad)
        img=img.copy(left,top,right-left,bottom-top)
    mode = Qt.TransformationMode.FastTransformation if name=='map_pixel' else Qt.TransformationMode.SmoothTransformation
    img = img.scaled(w,h,Qt.AspectRatioMode.KeepAspectRatio,mode)
    xx = x + (w-img.width())//2
    yy = y + (h-img.height())//2
    add(name,lambda p,img=img,xx=xx,yy=yy:p.drawImage(xx,yy,img))

top = board.createNode('your_sketch','paintlayer')
board.rootNode().addChildNode(top,None)
board.setActiveNode(top)
board.refreshProjection()
board.saveAs(str(root/'2_sketch'/(meta['id']+'_sketch_v1.kra')))
board.resizeImage(0,0,W,H)
preview=board.projection(0,0,W,H)
img=preview
img.scaled(1920,1080,Qt.AspectRatioMode.KeepAspectRatio,Qt.TransformationMode.SmoothTransformation).save(str(root/'2_sketch'/(meta['id']+'_sketch_v1.png')))
result = {'layers':[n.name() for n in board.rootNode().childNodes()],'size':[W,H],'saved':board.fileName()}
board.close()

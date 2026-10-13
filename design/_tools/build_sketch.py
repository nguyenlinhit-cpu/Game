"""Blender 5 script: make a layered OpenRaster review board and PNG preview.

Run: blender -b -P design/_tools/build_sketch.py -- --id mira
The .ora can be opened and saved as .kra in Krita. This script deliberately
keeps source art, palette, notes, and the empty drawing layer separate.
"""

import argparse
import os
from pathlib import Path
import shutil
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile

import bpy


W, H = 3840, 2160
ROOT = Path(__file__).resolve().parents[1]
PALETTES = {
    "mira": [
        ("Tóc", "#E8EEF5"), ("Da", "#F7DCCB"),
        ("Mũ / tạp dề", "#F4F6FA"), ("Váy", "#A9D3F2"),
        ("Điểm nước", "#3A8DDE"), ("Bạc / đũa", "#BFC8D4"),
        ("Mắt", "#3A8DDE"), ("Nước sáng", "#CDEBFF"),
    ]
}


def rgba(hexcode):
    h = hexcode.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)) + (1,)


def mat(name, color=None, texture=None):
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    nodes = material.node_tree.nodes
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial")
    emission = nodes.new("ShaderNodeEmission")
    material.node_tree.links.new(emission.outputs[0], out.inputs["Surface"])
    if texture:
        tex = nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.load(str(texture), check_existing=True)
        material.node_tree.links.new(tex.outputs["Color"], emission.inputs["Color"])
    else:
        emission.inputs["Color"].default_value = rgba(color)
    return material


def rect(name, x, y, w, h, color=None, texture=None):
    bpy.ops.mesh.primitive_plane_add(size=1, location=(x + w / 2, -y - h / 2, 0))
    obj = bpy.context.object
    obj.name = name
    obj.scale = (w, h, 1)
    obj.data.materials.append(mat(name + "_mat", color, texture))
    return obj


def label(name, text, x, y, size=38, color="#26354C"):
    data = bpy.data.curves.new(name, "FONT")
    data.body = text
    data.size = size
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.location = (x, -y, 0.1)
    data.materials.append(mat(name + "_mat", color))
    return obj


def render_layer(path, visible):
    for obj in bpy.context.scene.objects:
        if obj.type in {"MESH", "FONT"}:
            obj.hide_render = not any(obj.name.startswith(prefix) for prefix in visible)
    bpy.context.scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", required=True)
    opt = parser.parse_args(args)
    ident = opt.id
    folder = ROOT / "nhan_vat" / ident
    concept = folder / "1_concept"
    outdir = folder / "2_sketch"
    outdir.mkdir(parents=True, exist_ok=True)
    for name in ("1a_battle.png", "1b_front.png", "1c_weapon.png", "1d_pixel.png"):
        if not (concept / name).exists():
            raise SystemExit(f"Missing concept: {concept / name}")

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x, scene.render.resolution_y = W, H
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = True
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    cam_data = bpy.data.cameras.new("Board camera")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = W
    cam = bpy.data.objects.new("Board camera", cam_data)
    scene.collection.objects.link(cam)
    cam.location = (W / 2, -H / 2, 10)
    scene.camera = cam

    rect("background", 0, 0, W, H, "#F7FAFD")
    label("notes_title", f"{ident.upper()}  |  4-star  |  Water  |  Abundance", 100, 115, 68)
    for title, x in (("Battle concept", 100), ("Front A-pose", 1350), ("Back A-pose", 2580)):
        label("notes_heading_" + title, title, x, 220, 42)
    label("notes_weapon", "Dropper wand", 100, 1715, 38)
    label("notes_map", "Map pixel reference", 550, 1715, 38)
    label("notes_note1", "Gentle, worried, meticulous apprentice pharmacist", 1120, 1900, 38)
    label("notes_note2", "Recognize by long hood flaps and glowing water flask", 1120, 1950, 38)
    label("notes_note3", "Check hands, face and flask before image-to-3D", 1120, 2000, 38)
    label("notes_note4", "Pixel is reference only; final sprite: 32x32", 1120, 2050, 38)
    label("notes_note5", "Draw corrections on the empty your_sketch layer", 1120, 2100, 38)

    for i, (name, color) in enumerate(PALETTES.get(ident, [])):
        x = 1120 + (i % 4) * 660
        y = 1660 + (i // 4) * 105
        rect(f"palette_swatch_{i}", x, y, 64, 64, color)
        label(f"palette_label_{i}", f"{name}: {color}", x + 80, y + 43, 31)

    art = [
        ("concept_battle", "1a_battle.png", 100, 260, 1145, 1374),
        ("concept_front", "1b_front.png", 1350, 260, 1144, 1375),
        ("concept_back", "1b_back.png", 2580, 260, 1144, 1375),
        ("weapon", "1c_weapon.png", 100, 1750, 345, 410),
        ("map_pixel", "1d_pixel.png", 550, 1750, 340, 340),
    ]
    for layer, filename, x, y, w, h in art:
        source = concept / filename
        if source.exists():
            rect("art_" + layer, x, y, w, h, texture=source)

    with tempfile.TemporaryDirectory() as tmpstr:
        tmp = Path(tmpstr)
        render_layer(tmp / "background.png", ["background"])
        render_layer(tmp / "notes.png", ["notes_"])
        render_layer(tmp / "palette.png", ["palette_"])
        render_layer(tmp / "merged.png", ["background", "notes_", "palette_", "art_"])

        preview = bpy.data.images.load(str(tmp / "merged.png"))
        preview.scale(1920, 1080)
        preview.filepath_raw = str(outdir / f"{ident}_sketch_v1.png")
        preview.file_format = "PNG"
        preview.save()

        blank = bpy.data.images.new("blank", width=1, height=1, alpha=True)
        blank.pixels[0:4] = [0, 0, 0, 0]
        blank.filepath_raw = str(tmp / "blank.png")
        blank.file_format = "PNG"
        blank.save()

        layers = [("your_sketch", tmp / "blank.png", 0, 0)]
        for layer, filename, x, y, w, h in reversed(art):
            if (concept / filename).exists():
                source = concept / filename
                if layer in {"weapon", "map_pixel"}:
                    image_data = bpy.data.images.load(str(source), check_existing=False)
                    image_data.scale(w, h)
                    image_data.filepath_raw = str(tmp / f"{layer}.png")
                    image_data.file_format = "PNG"
                    image_data.save()
                    source = tmp / f"{layer}.png"
                layers.append((layer, source, x, y))
        layers += [("palette", tmp / "palette.png", 0, 0),
                   ("notes", tmp / "notes.png", 0, 0),
                   ("background", tmp / "background.png", 0, 0)]
        image = ET.Element("image", {"version": "0.0.3", "w": str(W), "h": str(H), "name": ident})
        stack = ET.SubElement(image, "stack")
        ora = outdir / f"{ident}_sketch_v1.ora"
        with zipfile.ZipFile(ora, "w") as z:
            z.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
            z.write(tmp / "merged.png", "mergedimage.png")
            for i, (name, source, x, y) in enumerate(layers):
                member = f"data/layer{i:02d}.png"
                z.write(source, member)
                ET.SubElement(stack, "layer", {"name": name, "src": member,
                    "x": str(x), "y": str(y), "opacity": "1.0",
                    "visibility": "visible", "composite-op": "svg:src-over"})
            z.writestr("stack.xml", ET.tostring(image, encoding="utf-8", xml_declaration=True))
    print(f"Wrote {ora} and preview PNG")


if __name__ == "__main__":
    main()

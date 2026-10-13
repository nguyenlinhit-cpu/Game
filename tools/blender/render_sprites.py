"""Render nhân vật / quái trong file .blend ra sprite sheet 2D cho game (mục 12).

    blender -b file.blend -P tools/blender/render_sprites.py -- --character ignar --mode map
    blender -b file.blend -P tools/blender/render_sprites.py -- --character ignar --mode battle
    blender -b boss.blend -P tools/blender/render_sprites.py -- --character library_warden --kind enemies --mode battle

Làm gì:
  - Camera trực giao, ánh sáng cố định (mặt trời + đèn viền), shader hoạt hình (Diffuse → Shader to RGB → Color Ramp
    bậc thang × màu gốc), viền đen bằng Solidify lật pháp tuyến (vật liệu viền chỉ hiện mặt sau).
  - map: 8 hướng (e, se, s, sw, w, nw, n, ne), nhìn chéo từ trên xuống; battle: 1 góc nghiêng 3/4
    (nhân vật quay sang phải, quái quay sang trái).
  - Mỗi Action trùng tên hành động của game (data/config/art_requirements.json) được render đủ số khung yêu cầu,
    lấy đều trong frame_range của Action. Action khác tên vẫn render nếu ghi trong --actions.
  - Ghép thành <mode>_<id>.png (hàng = hành động × hướng, cột = khung) + <mode>_<id>.json mô tả khung, điểm neo
    (chân nhân vật), fps → thả vào assets/<characters|enemies>/<id>/<mode>/ rồi chạy tools/import_assets.

Tùy chọn: --out <thư mục> · --size <px/khung> · --frames <số khung mỗi hành động, ghi đè yêu cầu> ·
          --actions idle,run · --kind characters|enemies · --enemy-kind normal|elite|boss · --no-toon · --no-outline
Thư mục mặc định: <dự án>/assets/<kind>/<id>/<mode>/ (dự án = thư mục cha của tools/).
"""
import json
import math
import os
import sys
import tempfile

import bpy
import numpy as np
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Vector

PROJECT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
REQUIREMENTS = os.path.join(PROJECT, "data", "config", "art_requirements.json")
# Góc quay nhân vật quanh trục Z (độ, ngược chiều kim đồng hồ nhìn từ trên) để nhìn về từng hướng trên màn hình.
# Mặt trước nhân vật trong .blend nhìn về -Y (về phía camera) = hướng "s".
DIRECTION_ANGLES = {"s": 0, "se": 45, "e": 90, "ne": 135, "n": 180, "nw": 225, "w": 270, "sw": 315}


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    opts = {"character": None, "mode": "map", "out": None, "size": None, "frames": None, "actions": None,
            "kind": "characters", "enemy-kind": "normal", "toon": True, "outline": True}
    i = 0
    while i < len(argv):
        key = argv[i].lstrip("-")
        if key == "no-toon":
            opts["toon"] = False
        elif key == "no-outline":
            opts["outline"] = False
        elif key in opts and i + 1 < len(argv):
            opts[key] = argv[i + 1]
            i += 1
        i += 1
    if not opts["character"]:
        raise SystemExit("Thiếu --character <id>")
    if opts["mode"] not in ("map", "battle"):
        raise SystemExit("--mode phải là map hoặc battle")
    return opts


def load_requirements(opts):
    with open(REQUIREMENTS, encoding="utf-8") as fh:
        req = json.load(fh)
    group = req["character"] if opts["kind"] == "characters" else req["enemy"]
    spec = group[opts["mode"]]
    size = spec["frame_size"]
    if isinstance(size, dict):
        size = size[opts["enemy-kind"]]
    return req, spec, int(opts["size"] or size)


# ---------------- Cảnh ----------------

def set_engine(scene):
    """Shader to RGB chỉ chạy trên EEVEE; tên engine đổi theo phiên bản Blender."""
    for engine in ("BLENDER_EEVEE", "BLENDER_EEVEE_NEXT"):
        try:
            scene.render.engine = engine
            return engine
        except TypeError:
            continue
    raise SystemExit("Không bật được EEVEE")


def setup_render(scene, size):
    set_engine(scene)
    scene.render.resolution_x = size
    scene.render.resolution_y = size
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    try:
        scene.view_settings.view_transform = "Standard"
    except TypeError:
        pass
    eevee = getattr(scene, "eevee", None)
    if eevee and hasattr(eevee, "taa_render_samples"):
        eevee.taa_render_samples = 16
    if scene.world is None:
        scene.world = bpy.data.worlds.new("World")
    scene.world.color = (0.05, 0.05, 0.08)


def find_rig():
    rigs = [o for o in bpy.data.objects if o.type == "ARMATURE"]
    if not rigs:
        raise SystemExit("Không tìm thấy Armature trong file .blend")
    return rigs[0]


def character_meshes(rig):
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and (o.parent == rig or any(
        m.type == "ARMATURE" and m.object == rig for m in o.modifiers))]
    return meshes or [o for o in bpy.data.objects if o.type == "MESH"]


def base_color_of(mat):
    if mat.use_nodes:
        for node in mat.node_tree.nodes:
            if node.type == "BSDF_PRINCIPLED":
                return tuple(node.inputs["Base Color"].default_value)
    return tuple(mat.diffuse_color)


def make_toon(mat):
    """Diffuse → Shader to RGB → Color Ramp (3 bậc) × màu gốc → Emission."""
    color = base_color_of(mat)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial")
    diffuse = nodes.new("ShaderNodeBsdfDiffuse")
    to_rgb = nodes.new("ShaderNodeShaderToRGB")
    ramp = nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.interpolation = "CONSTANT"
    elems = ramp.color_ramp.elements
    elems[0].position, elems[0].color = 0.0, (0.42, 0.42, 0.5, 1.0)
    elems[1].position, elems[1].color = 0.35, (0.75, 0.75, 0.8, 1.0)
    top = elems.new(0.7)
    top.color = (1.0, 1.0, 1.0, 1.0)
    mix = nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0
    mix.inputs[6].default_value = color
    emission = nodes.new("ShaderNodeEmission")
    links.new(diffuse.outputs[0], to_rgb.inputs[0])
    links.new(to_rgb.outputs["Color"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], mix.inputs[7])
    links.new(mix.outputs[2], emission.inputs["Color"])
    links.new(emission.outputs[0], out.inputs["Surface"])


def outline_material():
    mat = bpy.data.materials.get("SpriteOutline") or bpy.data.materials.new("SpriteOutline")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial")
    emission = nodes.new("ShaderNodeEmission")
    emission.inputs["Color"].default_value = (0.02, 0.02, 0.03, 1.0)
    mat.node_tree.links.new(emission.outputs[0], out.inputs["Surface"])
    mat.use_backface_culling = True
    return mat


def add_outline(obj, thickness):
    mat = outline_material()
    if mat.name not in [m.name for m in obj.data.materials if m]:
        obj.data.materials.append(mat)
    mod = obj.modifiers.get("SpriteOutline") or obj.modifiers.new("SpriteOutline", "SOLIDIFY")
    mod.thickness = thickness
    mod.offset = 1.0
    mod.use_flip_normals = True
    mod.use_rim = False
    mod.material_offset = len(obj.data.materials) - 1


def setup_lights():
    sun_data = bpy.data.lights.new("SpriteSun", "SUN")
    sun_data.energy = 3.5
    sun = bpy.data.objects.new("SpriteSun", sun_data)
    sun.rotation_euler = (math.radians(50), 0, math.radians(-35))
    bpy.context.scene.collection.objects.link(sun)
    rim_data = bpy.data.lights.new("SpriteRim", "SUN")
    rim_data.energy = 1.2
    rim = bpy.data.objects.new("SpriteRim", rim_data)
    rim.rotation_euler = (math.radians(-60), 0, math.radians(160))
    bpy.context.scene.collection.objects.link(rim)


def setup_camera(mode, height):
    cam_data = bpy.data.cameras.new("SpriteCamera")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = height * (1.45 if mode == "map" else 1.3)
    cam = bpy.data.objects.new("SpriteCamera", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    elevation = math.radians(35 if mode == "map" else 12)
    target = Vector((0, 0, height * 0.45))
    distance = 20.0
    cam.location = target + Vector((0, -math.cos(elevation) * distance, math.sin(elevation) * distance))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam
    return cam


def model_height(meshes):
    top = 0.0
    for obj in meshes:
        for corner in obj.bound_box:
            top = max(top, (obj.matrix_world @ Vector(corner)).z)
    return max(top, 0.5)


# ---------------- Render ----------------

def sample_frames(action, count, loop):
    start, end = action.frame_range
    span = max(end - start, 1)
    # Hoạt ảnh lặp không lấy khung cuối (trùng khung đầu).
    step = span / count if loop else span / max(count - 1, 1)
    return [start + step * i for i in range(count)]


def assign_action(rig, action):
    rig.animation_data_create()
    rig.animation_data.action = action
    slots = getattr(action, "slots", None)
    if slots and hasattr(rig.animation_data, "action_slot") and rig.animation_data.action_slot is None and len(slots):
        rig.animation_data.action_slot = slots[0]


def render_png(scene, frame, path):
    scene.frame_set(int(math.floor(frame)), subframe=frame - math.floor(frame))
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)


def read_pixels(path):
    img = bpy.data.images.load(path)
    w, h = img.size
    arr = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)
    bpy.data.images.remove(img)
    return np.flipud(arr)  # Blender lưu từ dưới lên → đổi về từ trên xuống.


def write_sheet(rows, size, path):
    cols = max(len(r[1]) for r in rows)
    sheet = np.zeros((len(rows) * size, cols * size, 4), dtype=np.float32)
    for r, (_, frames) in enumerate(rows):
        for c, pixels in enumerate(frames):
            sheet[r * size:(r + 1) * size, c * size:(c + 1) * size] = pixels
    img = bpy.data.images.new("sheet", width=cols * size, height=len(rows) * size, alpha=True)
    img.pixels[:] = np.flipud(sheet).ravel()
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)
    return cols


def main():
    opts = parse_args()
    req, spec, size = load_requirements(opts)
    mode = opts["mode"]
    char_id = opts["character"]
    out_dir = opts["out"] or os.path.join(PROJECT, "assets", opts["kind"], char_id, mode)
    os.makedirs(out_dir, exist_ok=True)
    scene = bpy.context.scene
    setup_render(scene, size)
    rig = find_rig()
    meshes = character_meshes(rig)
    height = model_height(meshes)
    if opts["toon"]:
        for mat in {m for o in meshes for m in o.data.materials if m and m.name != "SpriteOutline"}:
            make_toon(mat)
    if opts["outline"]:
        for obj in meshes:
            add_outline(obj, -height * 0.012)
    for obj in [o for o in bpy.data.objects if o.type in ("LIGHT", "CAMERA")]:
        obj.hide_render = True
    setup_lights()
    cam = setup_camera(mode, height)

    wanted = spec["actions"]
    available = {a.name: a for a in bpy.data.actions}
    names = opts["actions"].split(",") if opts["actions"] else [a for a in wanted if a in available]
    missing = [a for a in wanted if a not in available]
    if not names:
        raise SystemExit("File .blend không có Action nào trùng tên hành động: %s" % ", ".join(wanted))
    directions = req["directions"] if mode == "map" else [""]
    battle_angle = 60 if opts["kind"] == "characters" else -60
    base_rotation = rig.rotation_euler.z
    loops = spec.get("loop", [])
    tmp = tempfile.mkdtemp(prefix="sprites_")
    rows = []
    frames_json = []
    for action_name in names:
        action = available[action_name]
        assign_action(rig, action)
        count = int(opts["frames"] or wanted.get(action_name, 6))
        times = sample_frames(action, count, action_name in loops)
        for direction in directions:
            angle = DIRECTION_ANGLES[direction] if direction else battle_angle
            rig.rotation_euler.z = base_rotation + math.radians(angle)
            row = []
            for index, t in enumerate(times):
                path = os.path.join(tmp, "%s_%s_%02d.png" % (action_name, direction or "34", index))
                render_png(scene, t, path)
                row.append(read_pixels(path))
                frames_json.append({"action": action_name, "dir": direction, "index": index,
                                    "x": index * size, "y": len(rows) * size})
            rows.append(("%s_%s" % (action_name, direction), row))
            print("  %s %s: %d khung" % (action_name, direction or "3/4", len(row)))
    rig.rotation_euler.z = base_rotation
    # Điểm neo = chân nhân vật (gốc toạ độ) trên khung hình.
    foot = world_to_camera_view(scene, cam, Vector((0, 0, 0)))
    sheet_path = os.path.join(out_dir, "%s_%s.png" % (mode, char_id))
    write_sheet(rows, size, sheet_path)
    meta = {
        "asset_id": char_id, "mode": mode, "frame_size": [size, size], "anchor": [round(foot.x, 4), round(1.0 - foot.y, 4)],
        "fps": req.get("default_fps", 10), "frames": frames_json,
        "source": os.path.basename(bpy.data.filepath),
    }
    with open(os.path.join(out_dir, "%s_%s.json" % (mode, char_id)), "w", encoding="utf-8") as fh:
        json.dump(meta, fh, ensure_ascii=False, indent=1)
    print("Xong: %s (%d hàng × khung %dpx)" % (sheet_path, len(rows), size))
    if missing:
        print("Còn thiếu Action (game dùng hoạt ảnh idle thay thế):", ", ".join(missing))


if __name__ == "__main__":
    main()

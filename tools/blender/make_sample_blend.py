"""Tạo file .blend mẫu để thử tools/blender/render_sprites.py: một nhân vật hình khối đơn giản có rig (Armature
6 xương) và các Action đặt tên theo hành động của game (idle, run cho map; idle, attack cho trận).

Chạy:
    blender -b -P tools/blender/make_sample_blend.py -- --out tools/blender/sample_character.blend
Tùy chọn: --body "#3a8dde" --accent "#f0f0f0" (màu thân / viền, mặc định theo bảng màu Mira).

Quy ước để render_sprites.py nhận file của bạn:
  - Một Armature (tên bất kỳ) điều khiển mọi mesh nhân vật; mặt trước nhân vật nhìn về trục -Y.
  - Mỗi hành động là một Action tên đúng hành động của game: idle, run, dash, opener, technique (map) /
    idle, attack, skill, ultimate, hit, down, victory (trận). Khoảng khung lấy từ frame_range của Action.
  - Chân đứng ở gốc toạ độ, nhân vật cao khoảng 2 đơn vị.
"""
import math
import os
import sys

import bpy
from mathutils import Matrix


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    opts = {"out": "tools/blender/sample_character.blend", "body": "#3a8dde", "accent": "#f0f0f0"}
    i = 0
    while i < len(argv):
        key = argv[i].lstrip("-")
        if key in opts and i + 1 < len(argv):
            opts[key] = argv[i + 1]
            i += 2
        else:
            i += 1
    return opts


def hex_color(value):
    value = value.lstrip("#")
    srgb = [int(value[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
    # Blender dùng màu tuyến tính.
    return tuple(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb) + (1.0,)


def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = color
    return mat


def add_part(name, kind, location, scale, mat, bone, armature):
    if kind == "sphere":
        bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, location=location)
    elif kind == "cylinder":
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, location=location)
    else:
        bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bpy.ops.object.shade_smooth()
    obj.data.materials.append(mat)
    # Gắn cứng vào một xương (đủ cho mẫu; nhân vật thật dùng trọng số).
    obj.parent = armature
    obj.parent_type = "BONE"
    obj.parent_bone = bone
    # Cha là xương: gốc toạ độ của con nằm ở ĐUÔI xương → bù đúng ma trận đó để mesh đứng yên chỗ cũ.
    pose_bone = armature.pose.bones[bone]
    parent_matrix = armature.matrix_world @ pose_bone.matrix @ Matrix.Translation((0, pose_bone.bone.length, 0))
    obj.matrix_parent_inverse = parent_matrix.inverted()
    return obj


def build(opts):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = 24
    body = material("Body", hex_color(opts["body"]))
    accent = material("Accent", hex_color(opts["accent"]))
    skin = material("Skin", hex_color("#f1c8a8"))

    bpy.ops.object.armature_add(location=(0, 0, 0))
    arm = bpy.context.active_object
    arm.name = "Rig"
    bpy.ops.object.mode_set(mode="EDIT")
    bones = arm.data.edit_bones
    root = bones[0]
    root.name = "root"
    root.head, root.tail = (0, 0, 0.9), (0, 0, 1.3)

    def bone(name, head, tail, parent):
        b = bones.new(name)
        b.head, b.tail = head, tail
        b.parent = bones[parent]
        return b

    bone("spine", (0, 0, 1.3), (0, 0, 1.75), "root")
    bone("head", (0, 0, 1.75), (0, 0, 2.15), "spine")
    bone("arm_l", (0.32, 0, 1.65), (0.42, 0, 1.05), "spine")
    bone("arm_r", (-0.32, 0, 1.65), (-0.42, 0, 1.05), "spine")
    bone("leg_l", (0.14, 0, 0.9), (0.14, 0, 0.05), "root")
    bone("leg_r", (-0.14, 0, 0.9), (-0.14, 0, 0.05), "root")
    bpy.ops.object.mode_set(mode="POSE")
    bpy.ops.object.mode_set(mode="OBJECT")

    add_part("Torso", "cylinder", (0, 0, 1.35), (0.3, 0.22, 0.42), body, "spine", arm)
    add_part("Head", "sphere", (0, 0, 1.95), (0.24, 0.24, 0.24), skin, "head", arm)
    add_part("Hood", "sphere", (0, 0.03, 2.02), (0.27, 0.27, 0.2), body, "head", arm)
    add_part("Belt", "cylinder", (0, 0, 1.05), (0.32, 0.24, 0.05), accent, "spine", arm)
    add_part("ArmL", "cylinder", (0.37, 0, 1.35), (0.08, 0.08, 0.3), body, "arm_l", arm)
    add_part("ArmR", "cylinder", (-0.37, 0, 1.35), (0.08, 0.08, 0.3), body, "arm_r", arm)
    add_part("LegL", "cylinder", (0.14, 0, 0.47), (0.1, 0.1, 0.43), accent, "leg_l", arm)
    add_part("LegR", "cylinder", (-0.14, 0, 0.47), (0.1, 0.1, 0.43), accent, "leg_r", arm)
    # Bình nước đeo hông (nhận ra hướng nhìn: phía trước là -Y).
    add_part("Flask", "sphere", (0.22, -0.2, 1.1), (0.09, 0.09, 0.12), accent, "spine", arm)

    arm.animation_data_create()

    def make_action(name, length, keys):
        action = bpy.data.actions.new(name)
        action.use_fake_user = True
        arm.animation_data.action = action
        for frame, pose in keys:
            for bone_name, (rot_x, loc_z) in pose.items():
                pb = arm.pose.bones[bone_name]
                pb.rotation_mode = "XYZ"
                pb.rotation_euler = (math.radians(rot_x), 0, 0)
                pb.keyframe_insert("rotation_euler", frame=frame)
                if bone_name == "root":
                    pb.location = (0, loc_z, 0)
                    pb.keyframe_insert("location", frame=frame)
        action.use_frame_range = True
        action.frame_start, action.frame_end = 1, length
        return action

    rest = {"root": (0, 0), "spine": (0, 0), "head": (0, 0), "arm_l": (0, 0), "arm_r": (0, 0), "leg_l": (0, 0), "leg_r": (0, 0)}

    def pose(**changes):
        p = dict(rest)
        p.update(changes)
        return p

    make_action("idle", 24, [(1, pose()), (12, pose(root=(0, -0.03), spine=(4, 0), arm_l=(4, 0), arm_r=(4, 0))), (24, pose())])
    make_action("run", 16, [
        (1, pose(leg_l=(35, 0), leg_r=(-35, 0), arm_l=(-30, 0), arm_r=(30, 0), spine=(8, 0))),
        (5, pose(root=(0, 0.06), spine=(8, 0))),
        (9, pose(leg_l=(-35, 0), leg_r=(35, 0), arm_l=(30, 0), arm_r=(-30, 0), spine=(8, 0))),
        (13, pose(root=(0, 0.06), spine=(8, 0))),
        (16, pose(leg_l=(35, 0), leg_r=(-35, 0), arm_l=(-30, 0), arm_r=(30, 0), spine=(8, 0))),
    ])
    make_action("attack", 20, [
        (1, pose()), (6, pose(arm_r=(-120, 0), spine=(-10, 0))), (10, pose(arm_r=(60, 0), spine=(15, 0), root=(0, -0.05))),
        (20, pose()),
    ])
    arm.animation_data.action = bpy.data.actions["idle"]
    bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(opts["out"]))
    print("Đã lưu", opts["out"], "– Action:", ", ".join(a.name for a in bpy.data.actions))


if __name__ == "__main__":
    build(parse_args())

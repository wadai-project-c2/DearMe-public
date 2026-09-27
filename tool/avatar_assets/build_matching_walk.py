"""Retarget the walk onto the existing girl animation mesh, without re-exporting it.

Run with Blender --background --python tool/avatar_assets/build_matching_walk.py.
The target GLB's geometry, skin, UVs, images and materials remain byte-identical.
Only quaternion tracks are appended; the original assets are never overwritten.
"""
import json
import struct
from pathlib import Path

from mathutils import Matrix, Quaternion, Vector

ROOT = Path(__file__).resolve().parents[2]


def read_glb(path):
    data = path.read_bytes()
    length = struct.unpack_from('<I', data, 12)[0]
    doc = json.loads(data[20:20 + length])
    return doc, bytearray(data[28 + length:])


def values(doc, data, index):
    accessor = doc['accessors'][index]
    view = doc['bufferViews'][accessor['bufferView']]
    assert accessor['componentType'] == 5126
    width = {'SCALAR': 1, 'VEC4': 4}[accessor['type']]
    start = view.get('byteOffset', 0) + accessor.get('byteOffset', 0)
    stride = view.get('byteStride', width * 4)
    return [struct.unpack_from('<' + 'f' * width, data, start + i * stride)
            for i in range(accessor['count'])]


def quaternion(xyzw):
    x, y, z, w = xyzw
    return Quaternion((w, x, y, z))


def world_transforms(doc, rotations=None):
    result = {}
    rotations = rotations or {}

    def visit(index, parent):
        node = doc['nodes'][index]
        rotation = rotations.get(index, quaternion(node.get('rotation', [0, 0, 0, 1])))
        local = Matrix.LocRotScale(Vector(node.get('translation', [0, 0, 0])),
                                   rotation, Vector(node.get('scale', [1, 1, 1])))
        result[index] = parent @ local
        for child in node.get('children', []):
            visit(child, result[index])

    for root in doc['scenes'][doc.get('scene', 0)]['nodes']:
        visit(root, Matrix.Identity(4))
    return result


def build():
    source, source_data = read_glb(ROOT / 'assets/animation/3d/girl1_walk.glb')
    target, target_data = read_glb(ROOT / 'assets/animation/3d/girl1_left.glb')
    original_bytes = bytes(target_data)
    source_names = {n['name']: i for i, n in enumerate(source['nodes'])}
    target_names = {n['name'].removeprefix('mixamorig:'): i
                    for i, n in enumerate(target['nodes'])}
    mapping = {name: name for name in [
        'Hips', 'Head', 'LeftShoulder', 'LeftArm', 'LeftForeArm', 'LeftHand',
        'RightShoulder', 'RightArm', 'RightForeArm', 'RightHand',
        'LeftUpLeg', 'LeftLeg', 'LeftFoot', 'LeftToeBase',
        'RightUpLeg', 'RightLeg', 'RightFoot', 'RightToeBase']}
    mapping.update({'Spine': 'Spine02', 'Spine1': 'Spine01', 'Spine2': 'Spine', 'Neck': 'neck'})
    # Use the actual anatomical direction rather than exporter-specific bone
    # axes, which differ between the two rigs (including their rest arm pose).
    next_bone = {
        'Spine': 'Spine1', 'Spine1': 'Spine2', 'Spine2': 'Neck', 'Neck': 'Head',
        'LeftShoulder': 'LeftArm', 'LeftArm': 'LeftForeArm', 'LeftForeArm': 'LeftHand',
        'RightShoulder': 'RightArm', 'RightArm': 'RightForeArm', 'RightForeArm': 'RightHand',
        'LeftUpLeg': 'LeftLeg', 'LeftLeg': 'LeftFoot',
        'RightUpLeg': 'RightLeg', 'RightLeg': 'RightFoot',
    }
    # Feet must use the full rest-relative rotation below, just like toes.
    # A single ankle-to-toe vector loses sole roll/twist and forces the source
    # rig's neutral toe-out angle onto the differently proportioned girl shoes.
    # Keeping both foot and toe in the same rotation basis preserves their
    # relationship throughout heel strike and toe-off.
    source_rest = world_transforms(source)
    target_rest = world_transforms(target)
    parents = {child: index for index, node in enumerate(target['nodes'])
               for child in node.get('children', [])}
    animation = source['animations'][0]
    tracks = {}
    for channel in animation['channels']:
        if channel['target']['path'] != 'rotation':
            continue
        sampler = animation['samplers'][channel['sampler']]
        tracks[channel['target']['node']] = (
            [v[0] for v in values(source, source_data, sampler['input'])],
            [quaternion(v) for v in values(source, source_data, sampler['output'])])
    duration = max(times[-1] for times, _ in tracks.values())
    times = [i * duration / 60 for i in range(61)]
    output = {target_names[name]: [] for name in mapping}

    def sample(track, time):
        ts, qs = track
        for i in range(1, len(ts)):
            if time <= ts[i]:
                return qs[i-1].slerp(qs[i], (time-ts[i-1]) / (ts[i]-ts[i-1]))
        return qs[-1]

    for time in times:
        source_pose = world_transforms(source, {i: sample(t, time) for i, t in tracks.items()})
        desired = {}
        for name, source_name in mapping.items():
            ti, si = target_names[name], source_names[source_name]
            rest_rotation = target_rest[ti].to_quaternion()
            if name in next_bone:
                child = next_bone[name]
                target_direction = target_rest[target_names[child]].translation - target_rest[ti].translation
                source_direction = source_pose[source_names[mapping[child]]].translation - source_pose[si].translation
                desired[ti] = target_direction.rotation_difference(source_direction) @ rest_rotation
            else:
                delta = source_pose[si].to_quaternion() @ source_rest[si].to_quaternion().inverted()
                desired[ti] = delta @ rest_rotation
        for ti, frames in output.items():
            parent = parents.get(ti)
            parent_rotation = desired.get(parent, target_rest[parent].to_quaternion())
            local = parent_rotation.inverted() @ desired[ti]
            local.normalize()
            if frames and quaternion(frames[-1]).dot(local) < 0:
                local.negate()
            frames.append((local.x, local.y, local.z, local.w))

    def append_accessor(rows, kind):
        while len(target_data) % 4:
            target_data.append(0)
        offset = len(target_data)
        for row in rows:
            target_data.extend(struct.pack('<' + 'f' * len(row), *row))
        view = len(target['bufferViews'])
        target['bufferViews'].append({'buffer': 0, 'byteOffset': offset, 'byteLength': len(target_data)-offset})
        index = len(target['accessors'])
        accessor = {'bufferView': view, 'componentType': 5126, 'count': len(rows), 'type': kind}
        if kind == 'SCALAR':
            accessor.update(min=[rows[0][0]], max=[rows[-1][0]])
        target['accessors'].append(accessor)
        return index

    time_index = append_accessor([(t,) for t in times], 'SCALAR')
    result = {'name': 'girl1_walk_matching', 'channels': [], 'samplers': []}
    for node, frames in output.items():
        output_index = append_accessor(frames, 'VEC4')
        result['channels'].append({'sampler': len(result['samplers']), 'target': {'node': node, 'path': 'rotation'}})
        result['samplers'].append({'input': time_index, 'output': output_index, 'interpolation': 'LINEAR'})
    target['animations'] = [result]
    target['buffers'][0]['byteLength'] = len(target_data)
    assert target_data[:len(original_bytes)] == original_bytes
    encoded = json.dumps(target, separators=(',', ':')).encode()
    encoded += b' ' * (-len(encoded) % 4)
    total = 12 + 8 + len(encoded) + 8 + len(target_data)
    path = ROOT / 'assets/animation/3d/girl1_walk_matching.glb'
    path.write_bytes(struct.pack('<III', 0x46546C67, 2, total)
                     + struct.pack('<II', len(encoded), 0x4E4F534A) + encoded
                     + struct.pack('<II', len(target_data), 0x004E4942) + target_data)
    print(f'Created {path}: {len(output)} tracks, {duration:.3f}s; target appearance unchanged')


if __name__ == '__main__':
    build()

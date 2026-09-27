import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:three_js/three_js.dart' as three;

three.Quaternion rotation(List<dynamic> xyzw) => three.Quaternion(
      (xyzw[0] as num).toDouble(),
      (xyzw[1] as num).toDouble(),
      (xyzw[2] as num).toDouble(),
      (xyzw[3] as num).toDouble(),
    );

Map<int, three.Quaternion> worldRotations(
  Map<String, dynamic> doc,
  Uint8List binary, {
  double? time,
}) {
  final local = <int, three.Quaternion>{};
  if (time != null) {
    List<double> read(int index, int width, int row) {
      final accessor = doc['accessors'][index];
      final buffer = doc['bufferViews'][accessor['bufferView']];
      final offset = (buffer['byteOffset'] ?? 0) +
          (accessor['byteOffset'] ?? 0) +
          row * (buffer['byteStride'] ?? width * 4);
      final data = ByteData.sublistView(binary);
      return List.generate(
          width, (axis) => data.getFloat32(offset + axis * 4, Endian.little));
    }

    final animation = doc['animations'][0];
    for (final channel in animation['channels']) {
      if (channel['target']['path'] != 'rotation') continue;
      final sampler = animation['samplers'][channel['sampler']];
      expect(sampler['interpolation'] ?? 'LINEAR', 'LINEAR');
      final count = doc['accessors'][sampler['input']]['count'] as int;
      var hi = 1;
      while (hi < count - 1 && read(sampler['input'], 1, hi)[0] < time) {
        hi++;
      }
      final start = read(sampler['input'], 1, hi - 1)[0];
      final end = read(sampler['input'], 1, hi)[0];
      local[channel['target']['node']] =
          rotation(read(sampler['output'], 4, hi - 1))
            ..slerp(rotation(read(sampler['output'], 4, hi)),
                ((time - start) / (end - start)).clamp(0.0, 1.0));
    }
  }
  final result = <int, three.Quaternion>{};
  void visit(int index, three.Quaternion parent) {
    final node = doc['nodes'][index];
    final q = parent.clone()
      ..multiply(local[index] ?? rotation(node['rotation'] ?? [0, 0, 0, 1]));
    result[index] = q..normalize();
    for (final child in node['children'] ?? []) {
      visit(child, q);
    }
  }

  for (final root in doc['scenes'][doc['scene'] ?? 0]['nodes']) {
    visit(root, three.Quaternion());
  }
  return result;
}

({Map<String, dynamic> json, Uint8List binary}) readGlb(String name) {
  final bytes = File('assets/animation/3d/$name.glb').readAsBytesSync();
  final view = ByteData.sublistView(bytes);
  expect(view.getUint32(0, Endian.little), 0x46546c67);
  expect(view.getUint32(8, Endian.little), bytes.length);
  final length = view.getUint32(12, Endian.little);
  return (
    json: jsonDecode(utf8.decode(bytes.sublist(20, 20 + length)))
        as Map<String, dynamic>,
    binary: Uint8List.sublistView(bytes, 28 + length),
  );
}

void main() {
  test('walk feet and toes retain full rest-relative rotation, including twist',
      () {
    final source = readGlb('girl1_walk');
    final target = readGlb('girl1_walk_matching');
    final sourceRest = worldRotations(source.json, source.binary);
    final targetRest = worldRotations(target.json, target.binary);
    final sampler = target.json['animations'][0]['samplers'][0];
    final duration =
        (target.json['accessors'][sampler['input']]['max'][0] as num)
            .toDouble();
    for (var frame = 0; frame <= 60; frame++) {
      final time = duration * frame / 60;
      final sourcePose = worldRotations(source.json, source.binary, time: time);
      final targetPose = worldRotations(target.json, target.binary, time: time);
      for (final name in [
        'LeftFoot',
        'RightFoot',
        'LeftToeBase',
        'RightToeBase'
      ]) {
        final si = (source.json['nodes'] as List)
            .indexWhere((node) => node['name'] == name);
        final ti = (target.json['nodes'] as List)
            .indexWhere((node) => node['name'] == 'mixamorig:$name');
        final expected = sourcePose[si]!.clone()
          ..multiply(sourceRest[si]!.clone()..invert())
          ..multiply(targetRest[ti]!)
          ..normalize();
        final actual = targetPose[ti]!;
        final dot = actual.x * expected.x +
            actual.y * expected.y +
            actual.z * expected.z +
            actual.w * expected.w;
        expect(dot.abs(), closeTo(1, 0.00001), reason: '$name frame $frame');
      }
    }
  });
  test('matching walk preserves the girl appearance and rig byte-for-byte', () {
    final reference = readGlb('girl1_left');
    final walk = readGlb('girl1_walk_matching');
    for (final key in [
      'meshes',
      'skins',
      'nodes',
      'materials',
      'textures',
      'images',
      'samplers',
    ]) {
      expect(walk.json[key], reference.json[key], reason: key);
    }
    expect(walk.binary.sublist(0, reference.binary.length), reference.binary);
    final animation = (walk.json['animations'] as List).single;
    expect(animation['name'], 'girl1_walk_matching');
    expect(animation['channels'], hasLength(22));
    for (final channel in animation['channels']) {
      expect(channel['target']['path'], 'rotation');
      final sampler = animation['samplers'][channel['sampler']];
      final accessor = walk.json['accessors'][sampler['output']];
      final buffer = walk.json['bufferViews'][accessor['bufferView']];
      final offset = buffer['byteOffset'] as int;
      final data = ByteData.sublistView(walk.binary);
      for (var frame = 0; frame < accessor['count']; frame++) {
        var lengthSquared = 0.0;
        for (var axis = 0; axis < 4; axis++) {
          final value =
              data.getFloat32(offset + frame * 16 + axis * 4, Endian.little);
          expect(value.isFinite, isTrue);
          lengthSquared += value * value;
        }
        expect(lengthSquared, closeTo(1, 0.0001));
      }
    }
  });
}

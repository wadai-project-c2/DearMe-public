import 'dart:math' as math;

import 'package:dearme/room/avatar_pose_transition.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_js/three_js.dart' as three;

three.Quaternion yaw(double angle) => three.Quaternion().setFromAxisAngle(
      three.Vector3(0, 1, 0),
      angle,
    );

void expectRotation(three.Quaternion actual, three.Quaternion expected) {
  final dot = actual.x * expected.x +
      actual.y * expected.y +
      actual.z * expected.z +
      actual.w * expected.w;
  expect(dot.abs(), closeTo(1, 0.000001));
}

void main() {
  test('starts at displayed pose and reaches the moving destination', () {
    final source = three.Bone()..name = 'head';
    final target = three.Bone()..name = 'head';
    source.quaternion.setFrom(yaw(1));
    final blend = AvatarPoseTransition();
    blend.begin(
        source: source,
        destination: target,
        changeMirror: false,
        yawDelta: 0,
        destinationMirrored: false);
    blend.update(0);
    expectRotation(target.quaternion, yaw(1));
    for (var i = 0; i < 6; i++) {
      blend.restoreSampledPose();
      target.quaternion.setFrom(yaw(i * 0.1));
      blend.update(0.05);
    }
    expectRotation(target.quaternion, yaw(0.5));
  });

  test('untracked Armature does not retain the turn compensation', () {
    final source = three.Group()..name = 'Armature';
    final target = three.Group()..name = 'Armature';
    final blend = AvatarPoseTransition();
    blend.begin(
        source: source,
        destination: target,
        changeMirror: false,
        yawDelta: -math.pi / 2,
        destinationMirrored: false);
    blend.update(0);
    expectRotation(
        yaw(math.pi / 2)..multiply(target.quaternion), three.Quaternion());
    for (var i = 0; i < 6; i++) {
      blend.restoreSampledPose();
      blend.update(0.05);
    }
    expectRotation(target.quaternion, three.Quaternion());
  });

  test('right turn reflects rotation and swaps left and right limbs', () {
    final source = three.Bone()..name = 'mixamorigLeftArm';
    final target = three.Bone()..name = 'mixamorigRightArm';
    source.quaternion.setFrom(yaw(0.7));
    final blend = AvatarPoseTransition();
    blend.begin(
        source: source,
        destination: target,
        changeMirror: true,
        yawDelta: 0,
        destinationMirrored: true);
    blend.update(0);
    expectRotation(target.quaternion, yaw(-0.7));
    blend.clear();
    expectRotation(target.quaternion, three.Quaternion());
  });

  test('interrupted transition starts from the pose actually displayed', () {
    final a = three.Bone()..name = 'head';
    final b = three.Bone()..name = 'head';
    final c = three.Bone()..name = 'head';
    a.quaternion.setFrom(yaw(1));
    final blend = AvatarPoseTransition();
    blend.begin(
        source: a,
        destination: b,
        changeMirror: false,
        yawDelta: 0,
        destinationMirrored: false);
    blend.update(0.05);
    final displayed = b.quaternion.clone();
    blend.begin(
        source: b,
        destination: c,
        changeMirror: false,
        yawDelta: 0,
        destinationMirrored: false);
    blend.update(0);
    expectRotation(c.quaternion, displayed);
    expectRotation(b.quaternion, three.Quaternion());
  });
}

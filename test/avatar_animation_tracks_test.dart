import 'package:dearme/room/avatar_animation_tracks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isInPlaceAvatarAnimationTrack', () {
    test('keeps bone rotation tracks', () {
      expect(isInPlaceAvatarAnimationTrack('mixamorigHips.quaternion'), isTrue);
      expect(isInPlaceAvatarAnimationTrack('Armature.Bone.QUATERNION'), isTrue);
    });

    test('rejects tracks that overwrite room position and scale', () {
      expect(isInPlaceAvatarAnimationTrack('mixamorigHips.position'), isFalse);
      expect(isInPlaceAvatarAnimationTrack('Armature.scale'), isFalse);
      expect(isInPlaceAvatarAnimationTrack('Scene.position'), isFalse);
    });

    test('does not accept a partial quaternion suffix', () {
      expect(isInPlaceAvatarAnimationTrack('Bone.quaternion.extra'), isFalse);
      expect(isInPlaceAvatarAnimationTrack('Bone.rotation'), isFalse);
    });
  });
}

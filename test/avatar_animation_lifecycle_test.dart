import 'package:dearme/room/avatar_animation_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_js/three_js.dart' as three;

void main() {
  test('a finished turn holds its endpoint and is not activated a second time',
      () {
    final mixer = three.AnimationMixer(three.Group());
    final action = mixer.clipAction(three.AnimationClip('turn', 1.2, []))!;
    action
      ..setLoop(three.LoopOnce, 1)
      ..clampWhenFinished = true
      ..play();
    for (var frame = 0; frame < 60; frame++) {
      mixer.update(0.05);
    }
    expect(action.time, closeTo(1.2, 1e-8));
    expect(action.paused, isTrue);
    expect(action.isRunning(), isFalse);
    expect(
        shouldActivateAvatarAnimation(
          isRecordedAsActive: true,
          hasScene: true,
          isSceneVisible: true,
          isActionRunning: action.isRunning(),
          isHoldingFinalPose: action.paused,
        ),
        isFalse);
    expect(
        shouldBlendAvatarPose(
          isSceneVisible: true,
          isActionRunning: false,
          isHoldingFinalPose: true,
        ),
        isTrue);
    action.stop();
    mixer.uncacheAction(action.clip);
  });
  test('first async animation starts without blending from its bind pose', () {
    expect(shouldBlendAvatarPose(isSceneVisible: false, isActionRunning: false),
        isFalse);
    expect(shouldBlendAvatarPose(isSceneVisible: false, isActionRunning: true),
        isFalse);
    expect(shouldBlendAvatarPose(isSceneVisible: true, isActionRunning: false),
        isFalse);
    expect(shouldBlendAvatarPose(isSceneVisible: true, isActionRunning: true),
        isTrue);
  });
  group('avatar animation activation', () {
    test('restarts when state was selected before async assets were ready', () {
      expect(
        shouldActivateAvatarAnimation(
          isRecordedAsActive: true,
          hasScene: false,
          isSceneVisible: false,
          isActionRunning: false,
        ),
        isTrue,
      );
    });

    test('restarts a loaded action that is hidden or stopped', () {
      expect(
        shouldActivateAvatarAnimation(
          isRecordedAsActive: true,
          hasScene: true,
          isSceneVisible: false,
          isActionRunning: true,
        ),
        isTrue,
      );
      expect(
        shouldActivateAvatarAnimation(
          isRecordedAsActive: true,
          hasScene: true,
          isSceneVisible: true,
          isActionRunning: false,
        ),
        isTrue,
      );
    });

    test('keeps an already visible and running action', () {
      expect(
        shouldActivateAvatarAnimation(
          isRecordedAsActive: true,
          hasScene: true,
          isSceneVisible: true,
          isActionRunning: true,
        ),
        isFalse,
      );
    });
  });

  group('regular avatar visibility', () {
    test('restores after the standalone gift joy page finishes', () {
      expect(
        shouldRestoreRegularAvatar(
          celebrationRequested: false,
          hasCelebrationMixer: false,
        ),
        isTrue,
      );
    });

    test('restores when an in-scene celebration failed to start', () {
      expect(
        shouldRestoreRegularAvatar(
          celebrationRequested: true,
          hasCelebrationMixer: false,
        ),
        isTrue,
      );
    });

    test('keeps it hidden during a live in-scene celebration', () {
      expect(
        shouldRestoreRegularAvatar(
          celebrationRequested: true,
          hasCelebrationMixer: true,
        ),
        isFalse,
      );
    });
  });

  group('room scene activity', () {
    test('runs only while both app and widget are active', () {
      expect(
        shouldRunRoomScene(isAppResumed: true, isWidgetActive: true),
        isTrue,
      );
      expect(
        shouldRunRoomScene(isAppResumed: true, isWidgetActive: false),
        isFalse,
      );
      expect(
        shouldRunRoomScene(isAppResumed: false, isWidgetActive: true),
        isFalse,
      );
    });

    test('does not wake a hidden home after returning from an OS picker', () {
      const homeTabIsActive = false;
      expect(
        shouldRunRoomScene(
          isAppResumed: true,
          isWidgetActive: homeTabIsActive,
        ),
        isFalse,
      );
    });
  });
}

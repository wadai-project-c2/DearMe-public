/// Returns whether the requested avatar animation must be (re)activated.
///
/// The animation name can be selected before its asynchronously loaded scene
/// and action are ready. Treating the matching name alone as "already active"
/// leaves the fallback avatar visible forever and never starts the action.
bool shouldActivateAvatarAnimation({
  required bool isRecordedAsActive,
  required bool hasScene,
  required bool isSceneVisible,
  required bool isActionRunning,
  bool isHoldingFinalPose = false,
}) {
  return !isRecordedAsActive ||
      !hasScene ||
      !isSceneVisible ||
      !(isActionRunning || isHoldingFinalPose);
}

/// A newly loaded scene has a bind pose, not a previously displayed pose.
/// Never blend from it just because its state was selected before loading.
bool shouldBlendAvatarPose({
  required bool isSceneVisible,
  required bool isActionRunning,
  bool isHoldingFinalPose = false,
}) =>
    isSceneVisible && (isActionRunning || isHoldingFinalPose);

/// Returns whether the regular RoomScene avatar must be visible.
///
/// Gift joy is rendered on a standalone page, but this also protects the
/// legacy in-scene celebration path: only a requested celebration with a live
/// mixer may keep the regular avatar hidden.
bool shouldRestoreRegularAvatar({
  required bool celebrationRequested,
  required bool hasCelebrationMixer,
}) {
  return !celebrationRequested || !hasCelebrationMixer;
}

/// Returns whether this RoomScene may render and advance animations.
///
/// A home scene can remain mounted behind another tab. Returning from an OS
/// picker must not resume that hidden renderer merely because the app itself
/// entered the foreground again.
bool shouldRunRoomScene({
  required bool isAppResumed,
  required bool isWidgetActive,
}) {
  return isAppResumed && isWidgetActive;
}

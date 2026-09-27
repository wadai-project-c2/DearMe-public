/// Returns whether an animation track can be played without changing the
/// room-controlled position or scale of an avatar.
///
/// Mixamo GLBs can contain authored position and scale tracks whose units do
/// not match the room scene. Keeping only bone rotations preserves the gesture
/// while the room remains responsible for world position, normalized height,
/// and assignment scale.
bool isInPlaceAvatarAnimationTrack(String trackName) {
  return trackName.toLowerCase().endsWith('.quaternion');
}

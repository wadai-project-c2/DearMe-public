/// Shared vertical offsets for floor coverings and objects placed on them.
abstract final class RoomSurfaceElevations {
  /// Smallest practical separation from the floor that avoids z-fighting.
  ///
  /// The old 0.025 offset made the carpet visibly float and allowed its
  /// transparent plane to appear in front of nearby presented items.
  static const double carpetRenderOffset = 0.004;

  /// Keep the avatar at one height across bare floor and carpet boundaries.
  /// The carpet is decorative and must not introduce a vertical step.
  static const double avatarGroundClearance = 0.065;

  /// Animated leg bones can travel below the bind-pose mesh bounds.
  static const double animatedFootClearanceRatio = 0.04;

  /// Clearance used for an object's base when it is placed on the rug.
  static const double rugObjectSupport = 0.04;
}

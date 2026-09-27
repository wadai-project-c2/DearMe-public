import 'package:three_js/three_js.dart' as three;

/// Blends poses on one visible mesh, without translucent duplicate avatars.
/// Restore the sampled destination before advancing its mixer each frame: some
/// bones (and Armature) have no animation track and would otherwise accumulate
/// the previous frame's blend.
class AvatarPoseTransition {
  AvatarPoseTransition({this.duration = 0.25});

  final double duration;
  final Map<three.Object3D, three.Quaternion> _from = {};
  final Map<three.Object3D, three.Quaternion> _sampled = {};
  double _elapsed = 0;

  void begin({
    required three.Object3D source,
    required three.Object3D destination,
    required bool changeMirror,
    required double yawDelta,
    required bool destinationMirrored,
  }) {
    final pose = <String, three.Quaternion>{};
    source.traverse((node) {
      if (node is three.Bone || node.name == 'Armature') {
        var name = node.name;
        final q = node.quaternion;
        if (changeMirror) {
          name = name.contains('Left')
              ? name.replaceFirst('Left', 'Right')
              : name.replaceFirst('Right', 'Left');
        }
        pose[name] =
            changeMirror ? three.Quaternion(q.x, -q.y, -q.z, q.w) : q.clone();
      }
    });
    // Capture the displayed pose first, including an interrupted transition.
    clear();
    final yaw = three.Quaternion().setFromAxisAngle(
      three.Vector3(0, 1, 0),
      destinationMirrored ? -yawDelta : yawDelta,
    );
    destination.traverse((node) {
      final q = pose[node.name];
      if (q == null) return;
      // The controller commits a quarter turn when the turn clip finishes.
      // Compensate above the rig (whose authored up axis differs from world Y).
      if (node.name == 'Armature') q.premultiply(yaw);
      _from[node] = q;
    });
  }

  void restoreSampledPose() {
    for (final entry in _sampled.entries) {
      entry.key.quaternion.setFrom(entry.value);
    }
    _sampled.clear();
  }

  void update(double deltaTime) {
    if (_from.isEmpty) return;
    _elapsed += deltaTime.clamp(0, 0.05);
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    if (t >= 1) {
      _from.clear();
      return;
    }
    final weight = t * t * (3 - 2 * t);
    for (final entry in _from.entries) {
      final target = entry.key.quaternion.clone();
      _sampled[entry.key] = target;
      entry.key.quaternion.slerpQuaternions(entry.value, target, weight);
    }
  }

  void clear() {
    restoreSampledPose();
    _from.clear();
    _elapsed = 0;
  }
}

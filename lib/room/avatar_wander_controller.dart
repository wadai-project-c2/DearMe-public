import 'dart:math' as math;

import 'room_calibration.dart';

enum AvatarWanderAnimation {
  lookAround,
  turnLeft,
  turnRight,
  walk,
}

class AvatarWanderPose {
  final double x;
  final double y;
  final double z;
  final double rotationY;
  final bool isMoving;
  final AvatarWanderAnimation animation;

  const AvatarWanderPose({
    required this.x,
    required this.y,
    required this.z,
    required this.rotationY,
    required this.isMoving,
    required this.animation,
  });
}

class AvatarWanderController {
  final MovementBounds bounds;
  List<ObstacleArea> obstacles;
  final double floorY;
  final double speed;
  final double avatarHeight;
  final double boundaryPadding;
  final double collisionPadding;
  final math.Random _random;
  final double _fallbackX;
  final double _fallbackZ;

  double _x;
  double _z;
  double _rotationY;
  double _elapsed = 0;
  double _waitRemaining = 0;
  double? _targetX;
  double? _targetZ;
  double _turnElapsed = 0;
  double _turnDuration = 0;
  int _turnAttempts = 0;
  int _turnDirection = 1;
  AvatarWanderAnimation _animation = AvatarWanderAnimation.lookAround;
  bool _paused = false;

  static const double _turnAnimationDuration = 1.2;
  static const double _minWalkDistance = 0.4;
  // A turn sweep keeps one direction until every heading has been checked.
  static const int _maxTurnAttempts = 3;
  // Includes the avatar's feet and their lateral swing during the walk clip.
  // This remains below half of the narrowest room cell (about 0.283), so a
  // valid one-cell passage is not accidentally closed.
  static const double defaultCollisionPadding = 0.26;

  AvatarWanderController({
    required this.bounds,
    required this.obstacles,
    required this.floorY,
    required this.speed,
    required this.avatarHeight,
    // TODO: マジックナンバー
    this.boundaryPadding = 0.20,
    this.collisionPadding = defaultCollisionPadding,
    required double initialX,
    required double initialZ,
    required double initialRotationY,
    double fallbackX = 0,
    double fallbackZ = 0,
    math.Random? random,
  })  : assert(boundaryPadding >= 0),
        _x = initialX
            .clamp(bounds.minX + boundaryPadding, bounds.maxX - boundaryPadding)
            .toDouble(),
        _z = initialZ
            .clamp(bounds.minZ + boundaryPadding, bounds.maxZ - boundaryPadding)
            .toDouble(),
        // Every subsequent turn is a fixed 90-degree left turn, so the
        // heading must start parallel to the walls too. A stray diagonal
        // starting angle (e.g. a value saved before this behavior existed)
        // would otherwise never line up with a walkable axis-aligned path.
        _rotationY = _snapToRightAngle(initialRotationY),
        _fallbackX = fallbackX,
        _fallbackZ = fallbackZ,
        _random = random ?? math.Random() {
    if (_isObstacle(_x, _z, padding: collisionPadding)) {
      _x = fallbackX
          .clamp(bounds.minX + boundaryPadding, bounds.maxX - boundaryPadding)
          .toDouble();
      _z = fallbackZ
          .clamp(bounds.minZ + boundaryPadding, bounds.maxZ - boundaryPadding)
          .toDouble();
    }
    _startWaiting();
  }

  AvatarWanderPose get pose => AvatarWanderPose(
        x: _x,
        y: floorY,
        z: _z,
        rotationY: _rotationY,
        isMoving: _animation == AvatarWanderAnimation.walk,
        animation: _animation,
      );

  void pause() => _paused = true;

  void resume() => _paused = false;

  void updateObstacles(List<ObstacleArea> next) {
    obstacles = next;
    if (_isObstacle(_x, _z, padding: collisionPadding)) {
      final safe = _nearestClearFallback();
      if (safe != null) {
        _x = safe.x;
        _z = safe.z;
      }
      _targetX = null;
      _targetZ = null;
      _startWaiting(minSeconds: 1, maxSeconds: 2);
    }
  }

  ({double x, double z})? _nearestClearFallback() {
    const step = 0.10;
    final candidates = <({double x, double z})>[];
    for (var x = bounds.minX + boundaryPadding;
        x <= bounds.maxX - boundaryPadding + 1e-9;
        x += step) {
      for (var z = bounds.minZ + boundaryPadding;
          z <= bounds.maxZ - boundaryPadding + 1e-9;
          z += step) {
        if (!_isObstacle(x, z, padding: collisionPadding)) {
          candidates.add((x: x, z: z));
        }
      }
    }
    candidates.sort((a, b) {
      final ad = (a.x - _fallbackX) * (a.x - _fallbackX) +
          (a.z - _fallbackZ) * (a.z - _fallbackZ);
      final bd = (b.x - _fallbackX) * (b.x - _fallbackX) +
          (b.z - _fallbackZ) * (b.z - _fallbackZ);
      return ad.compareTo(bd);
    });
    return candidates.firstOrNull;
  }

  AvatarWanderPose update(double deltaTime) {
    final dt = deltaTime.clamp(0, 0.05).toDouble();
    if (_paused || dt == 0) {
      return pose;
    }
    _elapsed += dt;

    if (_isWaitingAnimation(_animation)) {
      _waitRemaining = math.max(0, _waitRemaining - dt);
      if (_waitRemaining > 0) {
        return pose;
      }
      _chooseDestination();
      if (_targetX == null || _targetZ == null) {
        if (_turnAttempts < _maxTurnAttempts) {
          // The heading we're currently facing is blocked. Rather than
          // waiting and re-checking the exact same blocked heading forever
          // (which leaves the avatar stuck in a corner), turn left and
          // retry from the new heading — up to a full circle.
          _turnAttempts++;
          _beginTurn();
          return pose;
        }
        _turnAttempts = 0;
        _startWaiting(minSeconds: 1, maxSeconds: 2);
        return pose;
      }
      _turnAttempts = 0;
      _beginTurn();
      return pose;
    }

    if (_animation == AvatarWanderAnimation.turnLeft ||
        _animation == AvatarWanderAnimation.turnRight) {
      // The turn clip itself carries the 90-degree rotation for the visible
      // mesh, so the wrapper's rotationY stays put during playback and snaps
      // to the new heading only after the clip has finished.
      _turnElapsed = math.min(_turnDuration, _turnElapsed + dt);
      if (_turnElapsed < _turnDuration) {
        return pose;
      }
      _rotationY = _wrapAngle(_rotationY + _turnDirection * math.pi / 2);
      // If this turn was just probing for an open heading (no target chosen
      // yet), briefly return to a non-repeating waiting gesture so the next
      // cycle re-evaluates from the new heading instead of walking.
      _animation = (_targetX != null && _targetZ != null)
          ? AvatarWanderAnimation.walk
          : _selectWaitingAnimation();
      return pose;
    }

    final dx = _targetX! - _x;
    final dz = _targetZ! - _z;
    final distance = math.sqrt(dx * dx + dz * dz);
    if (distance < 0.035) {
      _targetX = null;
      _targetZ = null;
      _startWaiting();
      return pose;
    }

    final step = math.min(distance, speed * dt);
    final nextX = _x + dx / distance * step;
    final nextZ = _z + dz / distance * step;
    if (_isObstacle(nextX, nextZ, padding: collisionPadding)) {
      _targetX = null;
      _targetZ = null;
      _startWaiting(minSeconds: 1, maxSeconds: 2);
      return pose;
    }
    _x = nextX;
    _z = nextZ;
    final bob = math.sin(_elapsed * 6) * avatarHeight * 0.008;
    return AvatarWanderPose(
      x: _x,
      y: floorY + bob,
      z: _z,
      rotationY: _rotationY,
      isMoving: true,
      animation: AvatarWanderAnimation.walk,
    );
  }

  void _beginTurn() {
    _turnElapsed = 0;
    _turnDuration = _turnAnimationDuration;
    _animation = _turnDirection > 0
        ? AvatarWanderAnimation.turnLeft
        : AvatarWanderAnimation.turnRight;
  }

  void _startWaiting({double minSeconds = 2, double maxSeconds = 5}) {
    _animation = _selectWaitingAnimation();
    _waitRemaining =
        minSeconds + _random.nextDouble() * (maxSeconds - minSeconds);
  }

  AvatarWanderAnimation _selectWaitingAnimation() {
    return AvatarWanderAnimation.lookAround;
  }

  // Each route starts by choosing clockwise or counterclockwise. The same
  // direction is retained while probing blocked headings so a full-circle
  // search still completes instead of bouncing between two directions.
  void _chooseDestination() {
    const halfPi = math.pi / 2;
    if (_turnAttempts == 0) {
      _turnDirection = _random.nextBool() ? 1 : -1;
    }
    final heading = _wrapAngle(_rotationY + _turnDirection * halfPi);
    final dirX = math.sin(heading);
    final dirZ = math.cos(heading);
    final maxDistance = _maxWalkDistance(dirX, dirZ);
    if (maxDistance < _minWalkDistance) {
      return;
    }
    final distance = maxDistance * (0.35 + _random.nextDouble() * 0.65);
    _targetX = _x + dirX * distance;
    _targetZ = _z + dirZ * distance;
  }

  static bool _isWaitingAnimation(AvatarWanderAnimation animation) {
    return animation == AvatarWanderAnimation.lookAround;
  }

  double _maxWalkDistance(double dirX, double dirZ) {
    final minX = bounds.minX + boundaryPadding;
    final maxX = bounds.maxX - boundaryPadding;
    final minZ = bounds.minZ + boundaryPadding;
    final maxZ = bounds.maxZ - boundaryPadding;

    var boundLimit = double.infinity;
    if (dirX > 0) {
      boundLimit = math.min(boundLimit, (maxX - _x) / dirX);
    } else if (dirX < 0) {
      boundLimit = math.min(boundLimit, (minX - _x) / dirX);
    }
    if (dirZ > 0) {
      boundLimit = math.min(boundLimit, (maxZ - _z) / dirZ);
    } else if (dirZ < 0) {
      boundLimit = math.min(boundLimit, (minZ - _z) / dirZ);
    }
    if (!boundLimit.isFinite || boundLimit < 0) {
      boundLimit = 0;
    }

    const step = 0.05;
    var distance = 0.0;
    while (distance < boundLimit) {
      final nextDistance = math.min(distance + step, boundLimit);
      final sampleX = _x + dirX * nextDistance;
      final sampleZ = _z + dirZ * nextDistance;
      if (_isObstacle(sampleX, sampleZ, padding: collisionPadding)) {
        break;
      }
      distance = nextDistance;
    }
    return distance;
  }

  bool _isObstacle(double x, double z, {double padding = 0}) {
    return obstacles.any((area) => area.contains(x, z, padding: padding));
  }

  double _wrapAngle(double value) {
    var angle = value;
    while (angle > math.pi) {
      angle -= math.pi * 2;
    }
    while (angle < -math.pi) {
      angle += math.pi * 2;
    }
    return angle;
  }

  static double _snapToRightAngle(double value) {
    const halfPi = math.pi / 2;
    var angle = (value / halfPi).round() * halfPi;
    while (angle > math.pi) {
      angle -= math.pi * 2;
    }
    while (angle < -math.pi) {
      angle += math.pi * 2;
    }
    return angle;
  }
}

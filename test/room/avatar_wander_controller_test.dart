import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:dearme/room/avatar_wander_controller.dart';
import 'package:dearme/room/room_calibration.dart';

void main() {
  group('AvatarWanderController', () {
    test('fully blocked avatar waits and retries, then resumes when cleared',
        () {
      final controller = AvatarWanderController(
        bounds: const MovementBounds(
          minX: -2,
          maxX: 2,
          minY: 0,
          maxY: 0,
          minZ: -2,
          maxZ: 2,
        ),
        obstacles: const [
          ObstacleArea(minX: -2, maxX: 2, minZ: -2, maxZ: 2),
        ],
        floorY: 0,
        speed: 1,
        avatarHeight: 1,
        collisionPadding: RoomCalibrations.simple.avatarCollisionPadding,
        initialX: 0,
        initialZ: 0,
        initialRotationY: 0,
        random: math.Random(1),
      );
      var turnStarts = 0;
      var waitsAfterTurn = 0;
      var previous = controller.pose.animation;
      for (var i = 0; i < 1200; i++) {
        final pose = controller.update(0.05);
        expect(pose.isMoving, isFalse);
        if (pose.animation != previous) {
          if (pose.animation == AvatarWanderAnimation.turnLeft ||
              pose.animation == AvatarWanderAnimation.turnRight) {
            turnStarts++;
          }
          if (pose.animation == AvatarWanderAnimation.lookAround) {
            waitsAfterTurn++;
          }
        }
        previous = pose.animation;
      }
      expect(turnStarts, greaterThan(3));
      expect(waitsAfterTurn, greaterThan(3));
      controller.updateObstacles([]);
      var moved = false;
      for (var i = 0; i < 1200; i++) {
        moved = controller.update(0.05).isMoving || moved;
      }
      expect(moved, isTrue);
    });

    test('uses both turn directions and only lookAround while waiting', () {
      final controller = AvatarWanderController(
        bounds: const MovementBounds(
          minX: -3,
          maxX: 3,
          minY: 0,
          maxY: 0,
          minZ: -3,
          maxZ: 3,
        ),
        obstacles: const [],
        floorY: 0,
        speed: 1,
        avatarHeight: 1,
        initialX: 0,
        initialZ: 0,
        initialRotationY: 0,
        random: math.Random(7),
      );

      final turns = <AvatarWanderAnimation>{};
      final waitingTransitions = <AvatarWanderAnimation>[];
      var previous = controller.pose.animation;
      for (var i = 0; i < 30000; i++) {
        final animation = controller.update(0.05).animation;
        if (animation == AvatarWanderAnimation.turnLeft ||
            animation == AvatarWanderAnimation.turnRight) {
          turns.add(animation);
        }
        final isWaiting = animation == AvatarWanderAnimation.lookAround;
        if (animation != previous && isWaiting) {
          waitingTransitions.add(animation);
        }
        previous = animation;
      }

      expect(
        turns,
        containsAll([
          AvatarWanderAnimation.turnLeft,
          AvatarWanderAnimation.turnRight,
        ]),
      );
      expect(waitingTransitions, isNotEmpty);
      expect(waitingTransitions.toSet(), {AvatarWanderAnimation.lookAround});
    });

    test(
        'escapes a corner instead of getting stuck when the initial '
        'turn heading is blocked', () {
      // A room where the avatar starts in a corner facing directly into a
      // wall/obstacle on its immediate left-turn heading. Only turning
      // further (up to a full circle) reveals a walkable direction.
      const bounds = MovementBounds(
        minX: -2,
        maxX: 2,
        minY: 0,
        maxY: 2,
        minZ: -2,
        maxZ: 2,
      );
      // Facing +Z (rotationY = 0), a left turn heads toward +X. Place an
      // obstacle immediately to the avatar's right (+X) so the very first
      // heading it tries is blocked at distance ~0 — the -Z and -X headings
      // it would try next are also blocked (avatar starts pressed into that
      // corner), so only the 4th and final heading in the full-circle sweep
      // (back to +Z) is open. This only succeeds if the avatar keeps
      // turning through blocked headings instead of giving up after one.
      final obstacles = [
        const ObstacleArea(minX: -1.2, maxX: 2, minZ: -2, maxZ: 2),
      ];

      final controller = AvatarWanderController(
        bounds: bounds,
        obstacles: obstacles,
        floorY: 0,
        speed: 1,
        avatarHeight: 1,
        initialX: -1.5,
        initialZ: -1.5,
        initialRotationY: 0,
        random: math.Random(1),
      );

      // Drive the simulation for a while. With the pre-fix logic, the
      // avatar would find the immediate left heading blocked, never turn,
      // and remain waiting in the corner forever.
      var moved = false;
      for (var i = 0; i < 2000; i++) {
        final pose = controller.update(0.05);
        if (pose.isMoving) {
          moved = true;
          break;
        }
      }

      expect(moved, isTrue,
          reason: 'avatar should eventually find an open heading and walk '
              'instead of staying stuck facing a blocked direction');
    });
  });
}

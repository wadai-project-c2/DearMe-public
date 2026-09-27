import 'dart:math' as math;

double placementRotationStep({required bool isFurniture}) => math.pi / 4;

double snapPlacementRotation(double angle, {required bool isFurniture}) {
  final step = placementRotationStep(isFurniture: isFurniture);
  return (angle / step).round() * step;
}

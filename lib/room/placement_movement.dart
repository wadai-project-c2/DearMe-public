import '../models/room_models.dart';

/// Converts a screen-facing move into the selected surface's grid axes.
/// The camera views the right wall from +X, so increasing Z goes screen-left.
({int x, int y, int z}) placementMoveDelta(
  PlacementSurface surface, {
  required int x,
  required int y,
  required int z,
}) =>
    switch (surface) {
      PlacementSurface.leftWall => (x: x, y: y - z, z: 0),
      PlacementSurface.rightWall => (x: 0, y: y - z, z: -x),
      _ => (x: x, y: y, z: z),
    };

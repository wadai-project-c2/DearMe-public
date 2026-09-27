import 'package:three_js/three_js.dart' as three;

/// Keep animation exports under the same lighting response. In particular,
/// the walk export contains specularColor=2 and IOR=1.45, while the other
/// animations use specularColor=0.8 and the default IOR=1.5.
/// Preserve each mesh's own texture/UV mapping and all animation data.
void normalizeAvatarAnimationMaterials(three.Object3D scene) {
  void normalize(three.Material material) {
    if (material is three.GroupMaterial) {
      for (final child in material.children) {
        normalize(child);
      }
      return;
    }
    material
      ..transparent = false
      ..opacity = 1
      ..alphaTest = 0.05
      ..depthWrite = true
      ..metalness = 0
      ..roughness = 0.72
      ..emissiveIntensity = 0;
    if (material is three.MeshPhysicalMaterial) {
      material
        ..specularIntensity = 1
        ..specularColor = three.Color(0.8, 0.8, 0.8)
        ..ior = 1.5;
    }
    material.needsUpdate = true;
  }

  scene.traverse((object) {
    final material = object.material;
    if (material != null) normalize(material);
  });
}

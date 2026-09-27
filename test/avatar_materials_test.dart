import 'package:dearme/room/avatar_materials.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_js/three_js.dart' as three;

void main() {
  test('walk and other animation exports use identical lighting response', () {
    final texture = three.Texture();
    final walk = three.MeshPhysicalMaterial()
      ..map = texture
      ..specularColor = three.Color(2, 2, 2)
      ..ior = 1.45
      ..emissiveIntensity = 1;
    final idle = three.MeshPhysicalMaterial()
      ..specularColor = three.Color(0.8, 0.8, 0.8);
    final scene = three.Group()
      ..add(three.Mesh(three.BoxGeometry(), three.GroupMaterial([walk, idle])));

    normalizeAvatarAnimationMaterials(scene);

    expect(walk.specularColor!.red, closeTo(idle.specularColor!.red, 1e-9));
    expect(walk.specularColor!.green, closeTo(idle.specularColor!.green, 1e-9));
    expect(walk.specularColor!.blue, closeTo(idle.specularColor!.blue, 1e-9));
    expect(walk.ior, idle.ior);
    expect(walk.roughness, idle.roughness);
    expect(walk.metalness, 0);
    expect(walk.emissiveIntensity, 0);
    expect(walk.map, same(texture));
    expect(walk.transparent, isFalse);
  });
}

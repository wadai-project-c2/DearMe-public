import 'package:dearme/models/avatar_model.dart';
import 'package:dearme/models/item_media_model.dart';
import 'package:dearme/models/item_model.dart';
import 'package:dearme/providers/item_provider.dart';
import 'package:dearme/repositories/item_repository.dart';
import 'package:dearme/screens/photo_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('successful registration clears the form for the next item',
      (tester) async {
    final provider = _SuccessfulItemProvider(_EmptyItemRepository());
    addTearDown(provider.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PhotoRegisterScreen(
            initialImagePath: 'assets/avatarphoto/mika.png',
          ),
        ),
        GoRoute(
          path: '/memo_input',
          builder: (context, state) => const Scaffold(
            body: Text('メモ入力'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<ItemProvider>.value(
        value: provider,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'first');
    await tester.pump();
    await tester.tap(find.text('送信して加工を開始'));
    await tester.pumpAndSettle();

    expect(provider.registeredTitles, ['first']);
    expect(find.text('メモ入力'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('写真を撮る・選ぶ'), findsOneWidget);
    expect(find.text('first'), findsNothing);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}

class _SuccessfulItemProvider extends ItemProvider {
  _SuccessfulItemProvider(super.repository);

  final List<String> registeredTitles = [];

  @override
  Future<String> startImageRegistration({
    required String title,
    required XFile image,
  }) async {
    registeredTitles.add(title);
    return 'item-1';
  }
}

class _EmptyItemRepository implements ItemRepository {
  @override
  Stream<List<ItemModel>> watchItems() => Stream.value(const []);

  @override
  Stream<List<ItemMediaModel>> watchItemMedia() => Stream.value(const []);

  @override
  Stream<List<AvatarModel>> watchAvatars() => Stream.value(const []);

  @override
  Stream<Map<String, List<String>>> watchRelatedAvatarIds() =>
      Stream.value(const {});

  @override
  Future<ItemModel?> getItem(String itemId) async => null;

  @override
  Future<void> saveItem(ItemModel item) async {}

  @override
  Future<void> saveMedia(ItemMediaModel media) async {}

  @override
  Future<void> deleteMedia(String mediaId) async {}

  @override
  Future<void> setRelatedAvatar(String itemId, String? avatarId) async {}

  @override
  Future<void> setRelatedAvatars(
    String itemId,
    List<String> avatarIds,
  ) async {}

  @override
  Future<void> deleteItem(String itemId) async {}
}

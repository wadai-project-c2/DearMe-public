import 'package:dearme/app_router.dart';
import 'package:dearme/screens/main_shell_screen.dart';
import 'package:dearme/screens/photo_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// アセット画像を読み込んでいる [Image] ウィジェットを探す。
Finder findAssetImage(String assetName) => find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == assetName,
    );

void main() {
  testWidgets('photo registration choices are shown', (tester) async {
    var returnedHome = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PhotoRegisterScreen(
          onBackToHome: () => returnedHome = true,
        ),
      ),
    );

    expect(find.text('写真を撮る・選ぶ'), findsOneWidget);
    expect(find.byTooltip('ホームへ戻る'), findsOneWidget);

    // 撮影／ギャラリーの選択肢はモーダルシートに移動したため、
    // プレースホルダをタップして開いてから検証する。
    await tester.tap(find.text('写真を撮る・選ぶ'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);

    // シートを閉じて元の画面へ戻す。
    Navigator.of(tester.element(find.byIcon(Icons.camera_alt_outlined))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('ホームへ戻る'));
    expect(returnedHome, isTrue);
  });
  test('legacy interior customize route is removed', () {
    final paths = appRouter.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path);

    expect(paths, isNot(contains('/interior_customize')));
  });
  testWidgets('shared navigation exposes exactly three destinations',
      (tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: DearMeBottomNavigation(
            selectedIndex: null,
            onSelected: (index) => selected = index,
          ),
        ),
      ),
    );

    // ナビはテキストラベルではなくアイコン画像＋中央の追加ボタンで構成される。
    expect(findAssetImage('assets/icon/library.png'), findsOneWidget);
    expect(findAssetImage('assets/icon/create.png'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('HOME'), findsNothing);

    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(selected, 1);
  });
}

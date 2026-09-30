import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:dearme/audio/audio_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dearme/screens/create_menu_screen.dart';
import 'package:dearme/screens/sound_settings_screen.dart';
import 'package:dearme/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

class Bundle extends CachingAssetBundle {
  Completer<ByteData>? pending;
  @override
  Future<ByteData> load(String key) async =>
      pending == null ? ByteData(1) : pending!.future;
}

class Settings implements AudioSettingsStore {
  @override
  Future<bool?> getBool(String key) async => null;
  @override
  Future<void> setBool(String key, bool value) async {}
}

class Player implements AudioPlayerHandle {
  bool playing = false;
  int resumes = 0;
  Completer<void>? pauseGate;
  Completer<void>? playGate;
  int disposes = 0;
  @override
  Future<void> setLooping() async {}
  @override
  Future<void> playAsset(String path, {double volume = 1}) async {
    if (playGate != null) await playGate!.future;
    playing = true;
  }

  @override
  Future<void> preload(String path) async {}

  @override
  Future<void> pause() async {
    if (pauseGate != null) await pauseGate!.future;
    playing = false;
  }

  @override
  Future<void> resume() async {
    resumes++;
    playing = true;
  }

  @override
  Future<void> stop() async {
    playing = false;
  }

  @override
  Future<void> dispose() async {
    disposes++;
    playing = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sound settings route replaces the deleted room information route', () {
    final paths =
        appRouter.configuration.routes.whereType<GoRoute>().map((r) => r.path);
    expect(paths, contains('/sound_settings'));
    expect(paths, isNot(contains('/room_settings')));
  });

  testWidgets('CREATE opens sound settings and both toggles update audio',
      (tester) async {
    final audio = AudioController(
        bgmPlayer: Player(), settingsStore: Settings(), assetBundle: Bundle());
    await audio.initialize();
    addTearDown(audio.dispose);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const CreateMenuScreen()),
      GoRoute(
          path: '/sound_settings',
          builder: (_, __) => const SoundSettingsScreen()),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ChangeNotifierProvider<AudioController>.value(
      value: audio,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.tap(find.byTooltip('サウンド設定'));
    await tester.pumpAndSettle();
    expect(find.byType(SoundSettingsScreen), findsOneWidget);
    await tester.tap(find.text('BGM'));
    await tester.pumpAndSettle();
    expect(audio.bgmEnabled, false);
    await tester.tap(find.text('演出・画面切替の効果音'));
    await tester.pumpAndSettle();
    expect(audio.soundEffectsEnabled, false);
    expect(find.text('部屋について'), findsNothing);
  });

  test('background during native play is followed by pause', () async {
    final player = Player()..playGate = Completer<void>();
    final controller = AudioController(
      bgmPlayer: player,
      settingsStore: Settings(),
      assetBundle: Bundle(),
    );
    addTearDown(controller.dispose);
    final initialization = controller.initialize();
    await Future<void>.delayed(Duration.zero);
    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    player.playGate!.complete();
    await initialization;
    await Future<void>.delayed(Duration.zero);
    expect(player.playing, false);
  });

  test('dispose waits for native play instead of racing it', () async {
    final player = Player()..playGate = Completer<void>();
    final controller = AudioController(
      bgmPlayer: player,
      settingsStore: Settings(),
      assetBundle: Bundle(),
    );
    final initialization = controller.initialize();
    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    expect(player.disposes, 0);
    player.playGate!.complete();
    await initialization;
    await Future<void>.delayed(Duration.zero);
    expect(player.disposes, 1);
    expect(player.playing, false);
  });

  test('iOS audio respects Silent mode and mixes with other audio', () {
    expect(AudioplayersHandle.audioContext.iOS.category,
        AVAudioSessionCategory.ambient);
  });

  test('BGM must not start if disabled while its asset is loading', () async {
    final bundle = Bundle()..pending = Completer<ByteData>();
    final player = Player();
    final controller = AudioController(
      bgmPlayer: player,
      settingsStore: Settings(),
      assetBundle: bundle,
    );
    addTearDown(controller.dispose);
    final initialization = controller.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(controller.initialized, true);
    final disable = controller.setBgmEnabled(false);
    bundle.pending!.complete(ByteData(1));
    await initialization;
    await disable;
    expect(player.playing, false, reason: 'BGM is disabled');
  });

  test('BGM must resume if foreground returns before pause completes',
      () async {
    final player = Player();
    final controller = AudioController(
      bgmPlayer: player,
      settingsStore: Settings(),
      assetBundle: Bundle(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(player.playing, true);
    player.pauseGate = Completer<void>();
    controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
    await Future<void>.delayed(Duration.zero);
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    player.pauseGate!.complete();
    await Future<void>.delayed(Duration.zero);
    expect(player.playing, true, reason: 'App is foreground and BGM enabled');
  });
}

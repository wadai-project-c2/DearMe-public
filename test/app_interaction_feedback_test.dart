import 'package:dearme/audio/audio_assets.dart';
import 'package:dearme/audio/audio_controller.dart';
import 'package:dearme/services/app_interaction_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _MemoryAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key != 'assets/${AudioAssets.buttonTap}') {
      throw FlutterError('Missing asset: $key');
    }
    return ByteData(1);
  }
}

class _FakePlayer implements AudioPlayerHandle {
  final assets = <String>[];

  @override
  Future<void> playAsset(String path, {double volume = 1}) async =>
      assets.add(path);

  @override
  Future<void> setLooping() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class _MemorySettings implements AudioSettingsStore {
  @override
  Future<bool?> getBool(String key) async => null;

  @override
  Future<void> setBool(String key, bool value) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('wrap plays buttonTap once and still runs the action',
      (tester) async {
    final effect = _FakePlayer();
    final controller = AudioController(
      bgmPlayer: _FakePlayer(),
      settingsStore: _MemorySettings(),
      effectPlayerFactory: (_) => effect,
      assetBundle: _MemoryAssetBundle(),
    );
    await controller.initialize();
    var pressed = 0;

    await tester.pumpWidget(
      ChangeNotifierProvider<AudioController>.value(
        value: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed:
                      AppInteractionFeedback.wrap(context, () => pressed++),
                  child: const Text('Tap'),
                ),
                const ElevatedButton(onPressed: null, child: Text('Off')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));
    await tester.pump();
    await tester.tap(find.text('Off'));
    await tester.pump();

    expect(pressed, 1);
    expect(effect.assets, [AudioAssets.buttonTap]);
    controller.dispose();
  });

  testWidgets('without a Provider the action runs silently', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: AppInteractionFeedback.wrap(context, () => pressed++),
            child: const Text('Tap'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));

    expect(pressed, 1);
    expect(tester.takeException(), isNull);
  });
}

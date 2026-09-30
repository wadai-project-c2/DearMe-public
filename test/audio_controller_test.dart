
import 'package:dearme/audio/audio_assets.dart';
import 'package:dearme/audio/audio_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.available);

  final Set<String> available;

  @override
  Future<ByteData> load(String key) async {
    if (!available.contains(key)) throw FlutterError('Missing asset: $key');
    return ByteData(1);
  }
}

class _FakePlayer implements AudioPlayerHandle {
  int loops = 0;
  int plays = 0;
  int preloads = 0;
  int pauses = 0;
  int resumes = 0;
  int stops = 0;
  int disposes = 0;
  String? lastAsset;
  double? lastVolume;

  @override
  Future<void> setLooping() async => loops++;

  @override
  Future<void> playAsset(String path, {double volume = 1}) async {
    plays++;
    lastAsset = path;
    lastVolume = volume;
  }

  @override
  Future<void> preload(String path) async => preloads++;

  @override
  Future<void> pause() async => pauses++;

  @override
  Future<void> resume() async => resumes++;

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async => disposes++;
}

class _MemorySettings implements AudioSettingsStore {
  final values = <String, bool>{};

  @override
  Future<bool?> getBool(String key) async => values[key];

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app BGM starts without a home screen and resumes without starting over',
      () async {
    final bgm = _FakePlayer();
    final controller = AudioController(
      bgmPlayer: bgm,
      settingsStore: _MemorySettings(),
      assetBundle: _MemoryAssetBundle({'assets/${AudioAssets.homeBgm}'}),
    );

    await controller.initialize();
    expect(bgm.loops, 1);
    expect(bgm.plays, 1);
    expect(bgm.lastAsset, AudioAssets.homeBgm);
    expect(bgm.lastVolume, 0.35);

    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    expect(bgm.pauses, 1);

    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(bgm.plays, 1);
    expect(bgm.resumes, 1);
    controller.dispose();
  });

  test('missing audio assets remain silent without failing operations',
      () async {
    final bgm = _FakePlayer();
    final effect = _FakePlayer();
    final controller = AudioController(
      bgmPlayer: bgm,
      settingsStore: _MemorySettings(),
      effectPlayerFactory: (_) => effect,
      assetBundle: _MemoryAssetBundle({}),
    );

    await controller.initialize();
    await controller.playEffect(SoundEffect.saveComplete);
    expect(bgm.plays, 0);
    expect(effect.plays, 0);
    controller.dispose();
  });

  test('BGM setting pauses and resumes the same app-wide loop', () async {
    final bgm = _FakePlayer();
    final controller = AudioController(
      bgmPlayer: bgm,
      settingsStore: _MemorySettings(),
      assetBundle: _MemoryAssetBundle({'assets/${AudioAssets.homeBgm}'}),
    );
    await controller.initialize();
    await controller.setBgmEnabled(false);
    expect(bgm.pauses, 1);
    await controller.setBgmEnabled(true);
    expect(bgm.resumes, 1);
    expect(bgm.plays, 1);
    expect(bgm.loops, 1);
    controller.dispose();
  });

  test('duplicate effects are suppressed and the setting can disable them',
      () async {
    final effect = _FakePlayer();
    final controller = AudioController(
      bgmPlayer: _FakePlayer(),
      settingsStore: _MemorySettings(),
      effectPlayerFactory: (_) => effect,
      assetBundle: _MemoryAssetBundle({
        'assets/${AudioAssets.navigation}',
      }),
    );

    await controller.initialize();
    await controller.playEffect(SoundEffect.navigation);
    await controller.playEffect(SoundEffect.navigation);
    expect(effect.plays, 1);

    await controller.setSoundEffectsEnabled(false);
    await controller.playEffect(SoundEffect.navigation);
    expect(effect.plays, 1);
    expect(effect.stops, 1);
    controller.dispose();
  });

  test('every effect is prepared at startup, once each', () async {
    final players = <SoundEffect, _FakePlayer>{};
    final controller = AudioController(
      bgmPlayer: _FakePlayer(),
      settingsStore: _MemorySettings(),
      effectPlayerFactory: (e) => players[e] = _FakePlayer(),
      assetBundle: _MemoryAssetBundle({
        for (final e in SoundEffect.values) 'assets/${e.assetPath}',
      }),
    );

    await controller.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(players.keys, unorderedEquals(SoundEffect.values));
    expect(players.values.map((p) => p.preloads), everyElement(1));
    expect(players.values.map((p) => p.plays), everyElement(0));
    controller.dispose();
  });

  test('a tap right after startup shares the preload instead of repeating it',
      () async {
    final players = <SoundEffect, _FakePlayer>{};
    final controller = AudioController(
      bgmPlayer: _FakePlayer(),
      settingsStore: _MemorySettings(),
      effectPlayerFactory: (e) => players[e] = _FakePlayer(),
      assetBundle: _MemoryAssetBundle({
        for (final e in SoundEffect.values) 'assets/${e.assetPath}',
      }),
    );

    await controller.initialize();
    await controller.playEffect(SoundEffect.buttonTap);
    final tap = players[SoundEffect.buttonTap]!;
    expect(tap.preloads, 1);
    expect(tap.plays, 1);
    controller.dispose();
  });

  test('saved BGM and sound effect settings are restored', () async {
    final settings = _MemorySettings()
      ..values['audio.bgm.enabled'] = false
      ..values['audio.sfx.enabled'] = false;
    final controller = AudioController(
      bgmPlayer: _FakePlayer(),
      settingsStore: settings,
      assetBundle: _MemoryAssetBundle({}),
    );

    await controller.initialize();
    expect(controller.bgmEnabled, isFalse);
    expect(controller.soundEffectsEnabled, isFalse);

    await controller.setBgmEnabled(true);
    await controller.setSoundEffectsEnabled(true);
    await Future<void>.delayed(Duration.zero);
    expect(settings.values['audio.bgm.enabled'], isTrue);
    expect(settings.values['audio.sfx.enabled'], isTrue);
    controller.dispose();
  });
}

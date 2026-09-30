import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_assets.dart';

abstract interface class AudioPlayerHandle {
  Future<void> setLooping();
  Future<void> playAsset(String path, {double volume = 1});
  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

class AudioplayersHandle implements AudioPlayerHandle {
  /// [keepLoaded] is for short effects played repeatedly: the prepared source
  /// is kept after playback so the next tap skips re-preparing it.
  AudioplayersHandle(String playerId, {this.keepLoaded = false})
      : _player = AudioPlayer(playerId: playerId);

  final AudioPlayer _player;
  final bool keepLoaded;
  bool _configured = false;

  // App audio is supplementary: respect Silent mode and mix with other apps.
  static AudioContext get audioContext => AudioContext(
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      );

  @override
  Future<void> setLooping() => _player.setReleaseMode(ReleaseMode.loop);

  @override
  Future<void> playAsset(String path, {double volume = 1}) async {
    if (!keepLoaded) {
      return _player.play(AssetSource(path), volume: volume, ctx: audioContext);
    }
    // ReleaseMode.release (the default) discards the prepared source after each
    // playback, and the audio context is global on iOS, so set both only once.
    if (!_configured) {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setAudioContext(audioContext);
      _configured = true;
    }
    await _player.play(AssetSource(path), volume: volume);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() async {
    // Video playback can have changed the shared iOS session category.
    await _player.setAudioContext(audioContext);
    await _player.resume();
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

typedef EffectPlayerFactory = AudioPlayerHandle Function(SoundEffect effect);

abstract interface class AudioSettingsStore {
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}

class SharedPreferencesAudioSettingsStore implements AudioSettingsStore {
  SharedPreferencesAudioSettingsStore({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}

enum SoundEffect {
  buttonTap(AudioAssets.buttonTap),
  navigation(AudioAssets.navigation),
  processingComplete(AudioAssets.processingComplete),
  swipePlacement(AudioAssets.swipePlacement),
  presentCelebration(AudioAssets.presentCelebration),
  saveComplete(AudioAssets.saveComplete);

  const SoundEffect(this.assetPath);

  final String assetPath;
}

/// BGM・効果音・ユーザー設定・アプリライフサイクルを一元管理する。
///
/// 音源がまだ配置されていなくても画面操作を妨げない。追加後はアプリを再起動
///すればAssetManifestから検出され、そのまま再生経路が有効になる。
class AudioController extends ChangeNotifier with WidgetsBindingObserver {
  AudioController({
    AudioPlayerHandle? bgmPlayer,
    EffectPlayerFactory? effectPlayerFactory,
    AudioSettingsStore? settingsStore,
    AssetBundle? assetBundle,
  })  : _bgmPlayer = bgmPlayer ?? AudioplayersHandle('dearme_bgm'),
        _effectPlayerFactory = effectPlayerFactory ??
            ((effect) => AudioplayersHandle(
                  'dearme_sfx_${effect.name}',
                  keepLoaded: true,
                )),
        _settingsStore = settingsStore ?? SharedPreferencesAudioSettingsStore(),
        _assetBundle = assetBundle ?? rootBundle;

  static const _bgmEnabledKey = 'audio.bgm.enabled';
  static const _soundEffectsEnabledKey = 'audio.sfx.enabled';
  static const _effectCooldown = Duration(milliseconds: 180);

  final AudioPlayerHandle _bgmPlayer;
  final EffectPlayerFactory _effectPlayerFactory;
  final AudioSettingsStore _settingsStore;
  final AssetBundle _assetBundle;
  final Map<SoundEffect, AudioPlayerHandle> _effectPlayers = {};
  final Map<SoundEffect, DateTime> _lastEffectAt = {};
  final Map<String, bool> _assetAvailability = {};

  bool _bgmEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _foreground = true;
  bool _initialized = false;
  bool _bgmPlaying = false;
  bool _bgmPrepared = false;
  bool _disposed = false;
  Future<void> _bgmQueue = Future<void>.value();

  bool get _shouldPlayBgm =>
      _initialized && !_disposed && _bgmEnabled && _foreground;

  bool get bgmEnabled => _bgmEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    try {
      _bgmEnabled = await _settingsStore.getBool(_bgmEnabledKey) ?? _bgmEnabled;
      _soundEffectsEnabled =
          await _settingsStore.getBool(_soundEffectsEnabledKey) ??
              _soundEffectsEnabled;
    } catch (error) {
      debugPrint('[Audio] 設定を読み込めませんでした: $error');
    }
    if (_disposed) return;
    _initialized = true;
    notifyListeners();
    await _syncBgm();
  }

  Future<void> setBgmEnabled(bool enabled) async {
    if (_disposed || _bgmEnabled == enabled) return;
    _bgmEnabled = enabled;
    notifyListeners();
    unawaited(_saveBool(_bgmEnabledKey, enabled));
    await _syncBgm();
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    if (_disposed || _soundEffectsEnabled == enabled) return;
    _soundEffectsEnabled = enabled;
    notifyListeners();
    unawaited(_saveBool(_soundEffectsEnabledKey, enabled));
    if (!enabled) {
      for (final player in _effectPlayers.values) {
        unawaited(player.stop());
      }
    }
  }

  Future<void> playEffect(SoundEffect effect) async {
    if (!_initialized || !_soundEffectsEnabled || !_foreground || _disposed) {
      return;
    }
    final now = DateTime.now();
    final previous = _lastEffectAt[effect];
    if (previous != null && now.difference(previous) < _effectCooldown) return;
    if (!await _hasAsset(effect.assetPath)) return;
    _lastEffectAt[effect] = now;
    try {
      final player = _effectPlayers.putIfAbsent(
        effect,
        () => _effectPlayerFactory(effect),
      );
      await player.playAsset(effect.assetPath);
    } catch (error) {
      debugPrint('[Audio] ${effect.name}を再生できませんでした: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    unawaited(_syncBgm());
    if (!_foreground) {
      for (final player in _effectPlayers.values) {
        unawaited(player.stop());
      }
    }
  }

  Future<void> _syncBgm() {
    // Serialize native commands. Each queued operation reads the latest state,
    // so a resume cannot overtake an in-flight pause (or vice versa).
    _bgmQueue = _bgmQueue.then((_) => _applyBgmState());
    return _bgmQueue;
  }

  Future<void> _applyBgmState() async {
    if (!_initialized || _disposed) return;
    // One shared player keeps BGM continuous across tabs and routes.
    final shouldPlay = _shouldPlayBgm;
    if (!shouldPlay) {
      if (_bgmPlaying) {
        try {
          await _bgmPlayer.pause();
          _bgmPlaying = false;
        } catch (error) {
          debugPrint('[Audio] BGMを一時停止できませんでした: $error');
        }
      }
      return;
    }
    if (_bgmPlaying || !await _hasAsset(AudioAssets.homeBgm)) return;
    if (!_shouldPlayBgm) return;
    try {
      if (_bgmPrepared) {
        await _bgmPlayer.resume();
      } else {
        await _bgmPlayer.setLooping();
        if (!_shouldPlayBgm) return;
        await _bgmPlayer.playAsset(AudioAssets.homeBgm, volume: 0.35);
        _bgmPrepared = true;
      }
      _bgmPlaying = true;
    } catch (error) {
      debugPrint('[Audio] BGMを再生できませんでした: $error');
    }
  }

  Future<bool> _hasAsset(String path) async {
    final cached = _assetAvailability[path];
    if (cached != null) return cached;
    try {
      final data = await _assetBundle.load('assets/$path');
      final available = data.lengthInBytes > 0;
      _assetAvailability[path] = available;
      return available;
    } catch (_) {
      _assetAvailability[path] = false;
      return false;
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    try {
      await _settingsStore.setBool(key, value);
    } catch (error) {
      debugPrint('[Audio] 設定を保存できませんでした: $error');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // Do not dispose the native player while a play/pause command is pending.
    unawaited(_bgmQueue.then((_) => _bgmPlayer.dispose()));
    for (final player in _effectPlayers.values) {
      unawaited(player.dispose());
    }
    _effectPlayers.clear();
    super.dispose();
  }
}

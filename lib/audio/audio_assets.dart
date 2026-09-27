/// Issue #147で使用する音源の配置先を一元管理する。
///
/// [AssetSource] は `assets/` を基準に解決するため、ここではその配下だけを
///指定する。音源を差し替える場合も、このファイルか同名ファイルだけを変更する。
abstract final class AudioAssets {
  static const homeBgm = 'audio/bgm/home_bgm.mp3';

  static const buttonTap = 'audio/sfx/button_tap.mp3';
  static const navigation = 'audio/sfx/navigation.mp3';
  static const processingComplete = 'audio/sfx/processing_complete.mp3';
  static const swipePlacement = 'audio/sfx/swipe_placement.mp3';
  static const presentCelebration = 'audio/sfx/present_celebration.mp3';
  static const saveComplete = 'audio/sfx/save_complete.mp3';
}

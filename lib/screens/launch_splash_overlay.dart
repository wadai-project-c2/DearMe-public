import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ネイティブスプラッシュ(起動直後にOSが表示する静止画)を`FlutterNativeSplash.remove()`
/// で消した直後から、ホーム画面の読み込み完了までを繋ぐFlutter側のオーバーレイ。
///
/// ネイティブスプラッシュと同じ背景色・同じロゴ配置で初回フレームを描画し、そこから
/// ロゴを揺らすアニメーションだけを開始する(登場演出は付けない)ことで、ネイティブから
/// Flutterへの継ぎ目を意識させずにアニメーションを見せる。[child]（ホーム画面を含む
/// メインシェル）は裏側で読み込みを開始しつつ、[readyListenable]がtrueになるまで
/// このオーバーレイを前面に表示し続ける。読み込み完了後はフェードアウトして消える。
class LaunchSplashOverlay extends StatefulWidget {
  final Widget child;
  final ValueListenable<bool> readyListenable;

  const LaunchSplashOverlay({
    super.key,
    required this.child,
    required this.readyListenable,
  });

  @override
  State<LaunchSplashOverlay> createState() => _LaunchSplashOverlayState();
}

class _LaunchSplashOverlayState extends State<LaunchSplashOverlay> {
  bool _overlayVisible = true;

  @override
  void initState() {
    super.initState();
    widget.readyListenable.addListener(_onReadyChanged);
    if (widget.readyListenable.value) {
      _overlayVisible = false;
    }
  }

  void _onReadyChanged() {
    if (widget.readyListenable.value) {
      _hideOverlay();
    }
  }

  void _hideOverlay() {
    if (!mounted || !_overlayVisible) {
      return;
    }
    setState(() => _overlayVisible = false);
  }

  @override
  void dispose() {
    widget.readyListenable.removeListener(_onReadyChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !_overlayVisible,
          child: AnimatedOpacity(
            opacity: _overlayVisible ? 1 : 0,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            child: const _SwayingLogo(),
          ),
        ),
      ],
    );
  }
}

class _SwayingLogo extends StatefulWidget {
  const _SwayingLogo();

  @override
  State<_SwayingLogo> createState() => _SwayingLogoState();
}

class _SwayingLogoState extends State<_SwayingLogo>
    with SingleTickerProviderStateMixin {
  // ロゴをゆったり上下させつつ、往復の傾きを添えて浮遊感を出す。
  static const _swayPeriod = Duration(milliseconds: 3600);
  static const _swayOffset = 10.0; // 上下の振れ幅(px)
  static const _swayAngle = 0.05; // 傾きの振れ幅(rad, 約2.9度)

  late final AnimationController _swayController = AnimationController(
    vsync: this,
    duration: _swayPeriod,
  )..repeat();

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // legacy Android/iOSのネイティブスプラッシュは元の横長ロゴ(onboarding_icon.png)
    // をそのまま使っており、ここも同じ画像・同じレイアウト(左右padding 48)で
    // 初回フレームを描画することで継ぎ目なく引き継げる。Android 12+だけは円形
    // マスクの制約でネイティブ側が正方形の小さいロゴになるため、この画面に
    // 切り替わる瞬間だけ小→大へ一瞬サイズがポップする(色・デザインは同じ)。
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xffd95f79)),
      child: SizedBox.expand(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: AnimatedBuilder(
              animation: _swayController,
              builder: (context, child) {
                final phase = _swayController.value * 2 * math.pi;
                return Transform.translate(
                  offset: Offset(0, math.sin(phase) * _swayOffset),
                  child: Transform.rotate(
                    // 上下運動と1/4周期ずらすことで、浮き上がりながら
                    // 左右に振り返るような往復の回転になる。
                    angle: -math.cos(phase) * _swayAngle,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/branding/onboarding_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../room/room_scene_snapshot.dart';
import 'home_screen.dart';
import 'photo_register_screen.dart';
import 'create_menu_screen.dart';
import 'sticker_book_screen.dart';

class MainShellScreen extends StatefulWidget {
  /// null means the HomeScreen itself is visible and no destination is selected.
  final int? initialIndex;

  /// ホームの3Dシーン読み込み完了を上位（オンボーディング）に伝える。
  final VoidCallback? onHomeReady;

  const MainShellScreen({super.key, this.initialIndex, this.onHomeReady});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int? _selectedIndex;
  int _navigationGeneration = 0;
  final HomeRoomSnapshotController _snapshotController =
      HomeRoomSnapshotController();

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialIndex;
    _selectedIndex = initialIndex?.clamp(0, 2).toInt();
  }

  @override
  void didUpdateWidget(covariant MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _navigationGeneration++;
      _selectedIndex = widget.initialIndex?.clamp(0, 2).toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The raised navigation button leaves a strip of the shell exposed.
      // Match the home canvas so that gap does not become a different color.
      backgroundColor: _selectedIndex == null ? const Color(0xfff7eeea) : null,
      // ソフトキーボードの分だけbodyを縮めない。
      //
      // このシェルはIndexedStackで全タブを常に生かしており、その中の
      // ホーム画面には3Dシーン（RoomSceneWidget）がいる。
      // RoomSceneWidgetは描画サイズをキャンバスのキーに含めているため、
      // 高さが1pxでも変わるとシーンを丸ごと作り直す（GLコンテキストの
      // 再生成と全GLBの再パース）。
      //
      // シェルのScaffoldがキーボードを避けて縮むと、別ルート（詳細入力
      // 画面など）でキーボードを開いただけでこの作り直しが走り、
      // 初期化途中のキャンバスをdisposeして例外が飛び、その巻き添えで
      // 開いたばかりのキーボードが閉じてしまっていた。
      //
      // このシェル自身に入力欄は無く、キーボードを避ける必要がある画面
      // （品物登録のタイトル欄など）は各画面のScaffoldが個別に
      // resizeToAvoidBottomInsetを持っているため、ここでは避けない。
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex == null ? 0 : _selectedIndex! + 1,
        children: [
          HomeScreen(
            onSceneReady: widget.onHomeReady,
            active: _selectedIndex == null,
            snapshotController: _snapshotController,
          ),
          StickerBookScreen(onBackToHome: _showHome),
          PhotoRegisterScreen(onBackToHome: _showHome),
          // アイコン画面はWebViewでアバターの3Dモデルを表示するため、他のタブ
          // （特にカメラ）表示中も裏で生かしたままにするとWebViewのレンダラー
          // プロセスがメモリ不足でOOM Killされ、アプリごと落ちることがある。
          // 選択中のみ生成し、他タブに移ったら破棄する。
          if (_selectedIndex == 2)
            CreateMenuScreen(onBackToHome: _showHome)
          else
            const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _selectedIndex == 2
          ? null
          : DearMeBottomNavigation(
              selectedIndex: _selectedIndex,
              onSelected: _select,
            ),
    );
  }

  void _select(int index) {
    if (_selectedIndex == index) return;
    final audio = context.read<AudioController>();
    unawaited(audio.playEffect(SoundEffect.navigation));
    final generation = ++_navigationGeneration;
    if (_selectedIndex == null && index == 1) {
      unawaited(_captureThenSelect(index, generation));
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _captureThenSelect(int index, int generation) async {
    try {
      await _snapshotController.capture();
    } catch (error) {
      // Snapshot failure must not block item registration. The placement page
      // has a plain-color fallback when no snapshot is available.
      debugPrint(
        '[MainShell][room-snapshot] capture failed '
        'type=${error.runtimeType}',
      );
    }
    if (mounted && generation == _navigationGeneration) {
      setState(() => _selectedIndex = index);
    }
  }

  void _showHome() {
    _navigationGeneration++;
    if (_selectedIndex == null) return;
    final audio = context.read<AudioController>();
    unawaited(audio.playEffect(SoundEffect.navigation));
    setState(() => _selectedIndex = null);
  }
}

class DearMeBottomNavigation extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  const DearMeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    const barHeight = 90.0;
    const buttonSize = 60.0;
    const buttonPopOut = 12.0; // 1/5 of 60dp pop out

    return SizedBox(
      height: barHeight + buttonPopOut + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 背景バー本体（画面下端に接地し、横幅いっぱい）
          Positioned(
            top: buttonPopOut,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: bottomPadding + 8), // アイコンが見切れないよう底上げ
                child: Row(
                  children: [
                    Expanded(
                      child: _Destination(
                        imagePath: 'assets/icon/library.png',
                        onTap: () => onSelected(0),
                      ),
                    ),
                    const SizedBox(width: buttonSize + 24), // 中央ボタン用のスペース
                    Expanded(
                      child: _Destination(
                        imagePath: 'assets/icon/create.png',
                        onTap: () => onSelected(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 中央の飛び出すプラスボタン（1/5飛び出し）
          _CenterPlusButton(
            onTap: () => onSelected(1),
          ),
        ],
      ),
    );
  }
}

class _CenterPlusButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterPlusButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '追加',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xffd95f79).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox.square(
              dimension: 60,
              child: Icon(
                Icons.add_rounded,
                size: 36,
                color: Color(0xffd95f79),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _Destination({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Center(
        child: Image.asset(
          imagePath,
          height: 54, // アイコンを一回り大きく調整
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

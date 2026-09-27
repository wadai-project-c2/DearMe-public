import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';

/// Audio settings remain accessible without restoring the removed room info.
class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    return Scaffold(
      appBar: AppBar(title: const Text('サウンド設定')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.music_note_outlined),
            title: const Text('BGM'),
            subtitle: const Text('アプリ全体の音楽'),
            value: audio.bgmEnabled,
            onChanged: audio.initialized
                ? (value) => unawaited(audio.setBgmEnabled(value))
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('演出・画面切替の効果音'),
            subtitle: const Text('加工完了・プレゼント・保存・画面切替の音'),
            value: audio.soundEffectsEnabled,
            onChanged: audio.initialized
                ? (value) => unawaited(audio.setSoundEffectsEnabled(value))
                : null,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('標準のボタン操作音はこの設定の対象外です。端末のサイレント・操作音設定に従います。'),
          ),
        ],
      ),
    );
  }
}

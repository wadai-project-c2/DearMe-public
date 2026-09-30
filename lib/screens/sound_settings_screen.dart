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
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '効果音を試聴',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          ..._effectPreviews.map(
            (preview) => ListTile(
              leading: Icon(preview.icon),
              title: Text(preview.label),
              subtitle: Text(preview.description),
              trailing: const Icon(Icons.play_circle_outline),
              enabled: audio.initialized && audio.soundEffectsEnabled,
              onTap: audio.initialized && audio.soundEffectsEnabled
                  ? () => unawaited(audio.playEffect(preview.effect))
                  : null,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('効果音をオフにすると、上の試聴とアプリ内の演出音は再生されません。'),
          ),
        ],
      ),
    );
  }
}

const _effectPreviews = <_EffectPreview>[
  _EffectPreview(
      label: 'ボタン操作',
      description: '丸く短い「コトッ」',
      icon: Icons.touch_app_outlined,
      effect: SoundEffect.buttonTap),
  _EffectPreview(
      label: '画面・タブ切替',
      description: '軽い2音の「ポロン」',
      icon: Icons.swap_horiz,
      effect: SoundEffect.navigation),
  _EffectPreview(
      label: '画像加工完了',
      description: '明るい3音の「きらりん」',
      icon: Icons.auto_awesome,
      effect: SoundEffect.processingComplete),
  _EffectPreview(
      label: '上スワイプ・配置',
      description: '柔らかい「ふわっ」',
      icon: Icons.swipe_up_alt,
      effect: SoundEffect.swipePlacement),
  _EffectPreview(
      label: 'プレゼント・喜び',
      description: '華やかなオルゴール風',
      icon: Icons.redeem_outlined,
      effect: SoundEffect.presentCelebration),
  _EffectPreview(
      label: '保存完了',
      description: '安心感のある2音の「ぽろん」',
      icon: Icons.check_circle_outline,
      effect: SoundEffect.saveComplete),
];

class _EffectPreview {
  const _EffectPreview(
      {required this.label,
      required this.description,
      required this.icon,
      required this.effect});

  final String label;
  final String description;
  final IconData icon;
  final SoundEffect effect;
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';

/// Plays the shared button-tap sound for controls that have no dedicated
/// sound effect. The sound is played by [AudioController] taken from [context].
abstract final class AppInteractionFeedback {
  static void tap(BuildContext context) {
    try {
      unawaited(
        context.read<AudioController>().playEffect(SoundEffect.buttonTap),
      );
    } on ProviderNotFoundException {
      // 単体のWidgetテストなど、アプリ全体のProvider外で使う場合は無音にする。
    }
  }

  static VoidCallback wrap(BuildContext context, VoidCallback callback) {
    return () {
      tap(context);
      callback();
    };
  }
}

import 'package:flutter/services.dart';

/// Keeps tap feedback consistent for custom controls that do not use a
/// Material button or InkWell.
abstract final class AppInteractionFeedback {
  static void tap() {
    SystemSound.play(SystemSoundType.click);
  }

  static VoidCallback wrap(VoidCallback callback) {
    return () {
      tap();
      callback();
    };
  }
}

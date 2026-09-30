import 'package:flutter/widgets.dart';

/// Keeps tap feedback consistent for custom controls that do not use a
/// Material button or InkWell.
abstract final class AppInteractionFeedback {
  // Custom effects are played by AudioController at meaningful interaction
  // points. Do not layer an iOS system click on top of those sounds.
  static void tap() {}

  static VoidCallback wrap(VoidCallback callback) {
    return () {
      tap();
      callback();
    };
  }
}

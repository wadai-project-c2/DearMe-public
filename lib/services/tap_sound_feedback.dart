import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// iOS Material controls do not emit Flutter's SystemSoundType.click.
/// Observe short taps on actionable controls without joining their gesture arena.
class TapSoundFeedback extends StatefulWidget {
  const TapSoundFeedback({super.key, required this.child});
  final Widget child;

  @override
  State<TapSoundFeedback> createState() => _TapSoundFeedbackState();
}

class _TapSoundFeedbackState extends State<TapSoundFeedback> {
  static const _channel = MethodChannel('dearme/interaction_sound');
  final _taps = <int, PointerDownEvent>{};
  final _pointers = <int>{};

  void _down(PointerDownEvent event) {
    _pointers.add(event.pointer);
    if (_pointers.length > 1) {
      _taps.clear();
      return;
    }
    final hit = HitTestResult();
    GestureBinding.instance.hitTestInView(hit, event.position, event.viewId);
    if (hit.path.any((entry) {
      final target = entry.target;
      return (target is RenderSemanticsGestureHandler &&
              target.onTap != null) ||
          (target is RenderSemanticsAnnotations &&
              target.properties.onTap != null);
    })) {
      _taps[event.pointer] = event;
    }
  }

  Future<void> _play() async {
    try {
      await _channel.invokeMethod<void>('tap');
    } on PlatformException {
      // Sound is optional; an audio failure must never block an action.
    } on MissingPluginException {
      // Tests and unsupported hosts do not install the iOS channel.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return widget.child;
    }
    return Listener(
      onPointerDown: _down,
      onPointerMove: (event) {
        final down = _taps[event.pointer];
        if (down != null &&
            (down.position - event.position).distance > kTouchSlop) {
          _taps.remove(event.pointer);
        }
      },
      onPointerCancel: (event) {
        _pointers.remove(event.pointer);
        _taps.remove(event.pointer);
      },
      onPointerUp: (event) {
        _pointers.remove(event.pointer);
        final down = _taps.remove(event.pointer);
        if (down != null &&
            event.timeStamp - down.timeStamp < kLongPressTimeout) {
          unawaited(_play());
        }
      },
      child: widget.child,
    );
  }
}

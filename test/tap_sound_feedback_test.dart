import 'package:dearme/services/tap_sound_feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('iOS button taps sound once; background and drags stay silent',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const channel = MethodChannel('dearme/interaction_sound');
    var sounds = 0;
    var presses = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      expect(call.method, 'tap');
      sounds++;
      return null;
    });
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => TapSoundFeedback(child: child!),
      home: Scaffold(
          body: Center(
              child: Column(children: [
        ElevatedButton(onPressed: () => presses++, child: const Text('Tap')),
        const ElevatedButton(onPressed: null, child: Text('Disabled')),
      ]))),
    ));
    await tester.tap(find.text('Tap'));
    await tester.pump();
    expect(sounds, 1);
    expect(presses, 1);
    await tester.tap(find.text('Disabled'));
    await tester.tapAt(const Offset(10, 400));
    await tester.drag(find.text('Tap'), const Offset(100, 0));
    await tester.pump();
    expect(sounds, 1);
    final first = await tester.startGesture(tester.getCenter(find.text('Tap')),
        pointer: 1);
    final second = await tester.startGesture(const Offset(10, 400), pointer: 2);
    await second.up();
    await first.up();
    await tester.pump();
    expect(sounds, 1,
        reason: 'Two-finger gestures must not emit button sounds');
    final cancelled =
        await tester.startGesture(tester.getCenter(find.text('Tap')));
    await cancelled.cancel();
    await tester.pump();
    expect(sounds, 1);
    await tester.tap(find.text('Tap'));
    await tester.pump();
    expect(sounds, 2, reason: 'Ordinary taps recover after cancellation');
    debugDefaultTargetPlatformOverride = null;
  });
}

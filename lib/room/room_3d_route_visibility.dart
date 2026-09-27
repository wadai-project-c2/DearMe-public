import 'package:flutter/foundation.dart';

/// True while the dedicated ROOM placement route owns the foreground 3D view.
///
/// GoRouter may rebuild the home route behind the placement route. Home must not
/// create a second ANGLE texture while this flag is true.
final roomPlacement3DVisible = ValueNotifier<bool>(false);

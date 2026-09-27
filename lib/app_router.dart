import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'screens/launch_splash_overlay.dart';
import 'screens/main_shell_screen.dart';
import 'screens/memo_input_screen.dart';
import 'pages/item_swipe_placement_page.dart';
import 'pages/item_detail_page.dart';
import 'screens/profile_create_screen.dart';
import 'screens/sound_settings_screen.dart';
import 'models/item_model.dart';
import 'pages/room_placement_page.dart';
import 'providers/room_provider.dart';
import 'route_observer.dart';

// アプリ起動後、ホームの3Dモデル読み込みが一度完了したらtrueになる。
// アプリのセッション中は保持し、'/'に再訪してもLaunchSplashOverlayを出し直さない。
final _homeReadyNotifier = ValueNotifier<bool>(false);

/// アプリ全体のURLと表示画面の対応を一か所で管理する。
final appRouter = GoRouter(
  initialLocation: '/',
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/sound_settings',
      builder: (context, state) => const SoundSettingsScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) {
        // 登録完了後も目的のタブを直接開けるよう、クエリから初期表示を決める。
        final tab = state.uri.queryParameters['tab'];
        final shell = MainShellScreen(
          initialIndex: tab == 'library'
              ? 0
              : tab == 'camera'
                  ? 1
                  : tab == 'avatar' || tab == 'create'
                      ? 2
                      : null,
          onHomeReady: () => _homeReadyNotifier.value = true,
        );
        if (_homeReadyNotifier.value) {
          return shell;
        }
        return LaunchSplashOverlay(
          readyListenable: _homeReadyNotifier,
          child: shell,
        );
      },
    ),
    GoRoute(
      path: '/room_placement',
      builder: (context, state) {
        final extra = state.extra;
        final itemId = extra is Map ? extra['itemId'] as String? : null;
        return RoomPlacementPage(
          itemId: itemId,
          roomId: RoomProvider.simpleRoomId,
        );
      },
    ),
    GoRoute(
      path: '/avatar_create',
      builder: (context, state) => const ProfileCreateScreen(),
    ),
    GoRoute(
      path: '/memo_input',
      builder: (context, state) {
        final itemId = state.extra is String ? state.extra! as String : '';
        // 新規登録フローから来た場合のみ、保存後にスワイプ配置演出へ進む（#62）。
        final isRegisterFlow = state.uri.queryParameters['flow'] == 'register';
        return MemoInputScreen(
          itemId: itemId,
          isRegisterFlow: isRegisterFlow,
        );
      },
    ),
    GoRoute(
      path: '/item_swipe_placement',
      builder: (context, state) {
        final itemId = state.extra is String ? state.extra! as String : '';
        return ItemSwipePlacementPage(itemId: itemId);
      },
    ),
    GoRoute(
      path: '/item_detail',
      builder: (context, state) {
        final item = state.extra is ItemModel ? state.extra as ItemModel : null;
        return ItemDetailPage(item: item);
      },
    ),
  ],
);

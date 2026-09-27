import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'repositories/item_repository.dart';
import 'providers/item_provider.dart';
import 'providers/room_provider.dart';
import 'repositories/room_repository.dart';
import 'services/local_file_service.dart';
import 'services/fastapi_image_service.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'audio/audio_controller.dart';
import 'services/tap_sound_feedback.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // OSが用意するネイティブスプラッシュを、Flutterの初回フレーム描画が終わるまで
  // 表示し続ける。初回フレームの時点でLaunchSplashOverlay(app_router.dart)が
  // 既にネイティブスプラッシュと同じ見た目で描画されているため、ここでremove()
  // しても継ぎ目が見えない。そこから先はLaunchSplashOverlayがホーム画面の3D
  // モデル読み込み完了まで演出(揺れアニメーション)を引き継ぐ。
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  widgetsBinding.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });

  // DBやサービスをここで一度だけ作り、全画面で同じ状態を共有する。
  final database = AppDatabase();
  final ItemRepository repository = LocalItemRepository(database);
  final RoomRepository roomRepository = LocalRoomRepository(database);
  const useMockImageProcessing = bool.fromEnvironment(
    'DEARME_MOCK_IMAGE_PROCESSING',
  );
  const mockFailureStageName = String.fromEnvironment(
    'DEARME_MOCK_FAILURE_STAGE',
  );
  const mockStageDelayMs = int.fromEnvironment(
    'DEARME_MOCK_STAGE_DELAY_MS',
    defaultValue: 2000,
  );
  final mockFailureStage =
      mockFailureStageName.isEmpty ? null : ImageProcessingStage.processing;
  final ImageProcessingService imageProcessingService = useMockImageProcessing
      ? MockImageProcessingService(
          stageDelay: const Duration(milliseconds: mockStageDelayMs),
          failFirstAt: mockFailureStage,
        )
      : FastApiImageService();
  final audioController = AudioController();
  unawaited(audioController.initialize());

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<ItemRepository>.value(value: repository),
        Provider<RoomRepository>.value(value: roomRepository),
        ChangeNotifierProvider<AudioController>.value(value: audioController),
        ChangeNotifierProvider(
          create: (context) => ItemProvider(
            repository,
            imageProcessingService: imageProcessingService,
            fileStore: LocalFileService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RoomProvider(roomRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DearMe',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) => TapSoundFeedback(child: child!),
    );
  }
}

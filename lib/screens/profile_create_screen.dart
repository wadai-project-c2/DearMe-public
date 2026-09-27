import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ProfileCreateScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const ProfileCreateScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffbf7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'ホームへ戻る',
          onPressed: onBackToHome ?? () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('アイコン'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff1f4),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const AspectRatio(
                    aspectRatio: 1,
                    child: ModelViewer(
                      backgroundColor: Colors.transparent,
                      src: 'assets/models/avatar/girl1.glb',
                      alt: 'DEAR ME avatar',
                      autoRotate: true,
                      cameraControls: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'You',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xff51494b),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'あなたのアバター',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xff756d70),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

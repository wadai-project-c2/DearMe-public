import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../services/app_interaction_feedback.dart';

class StickerBookScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StickerBookScreen({super.key, this.onBackToHome});

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // モックアップに合わせた背景色
    const backgroundColor = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'ホームへ戻る',
          onPressed: widget.onBackToHome ?? () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'LIBRARY',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: 1.2,
              ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 背景（台紙）の配置
          // SVGの真っ黒描画対策:
          // 1. 背景色をContainerで確実に敷く
          // 2. SvgPictureの colorFilter を使用せず、テーマ等による上書きを防止
          Positioned.fill(
            child: Image.asset(
              'assets/models/album/si-rutyou.png',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Container(
                color: backgroundColor,
              ),
            ),
          ),

          Consumer<ItemProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return const Center(child: Text('アイテムを読み込めませんでした'));
              }
              if (provider.items.isEmpty) {
                return const Center(child: Text('保存した思い出はまだありません'));
              }

              return GridView.builder(
                key: const PageStorageKey('sticker-book-grid'),
                padding: const EdgeInsets.fromLTRB(36, 24, 36, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 56, // 間隔を広げてゆとりを持たせる
                  crossAxisSpacing: 48, // 間隔を広げてゆとりを持たせる
                  childAspectRatio: 1.0,
                ),
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  return _StickerItem(
                    item: provider.items[index],
                    index: index,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StickerItem extends StatelessWidget {
  final ItemModel item;
  final int index;

  const _StickerItem({
    required this.item,
    required this.index,
  });

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('思い出の削除'),
        content: Text('「${item.title}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ItemProvider>().removeItem(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「${item.title}」を削除しました')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = item.id.hashCode;
    final random = math.Random(seed);

    final rotationDegrees = (random.nextDouble() * 16 - 8);
    final rotationRadians = rotationDegrees * math.pi / 180;

    final offsetX = (random.nextDouble() * 20 - 10);
    final offsetY = (random.nextDouble() * 20 - 10);

    // AI加工済み（ステッカー）かどうかの判定
    final bool isSticker = item.processedLocalImagePath != null;

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.rotate(
        angle: rotationRadians,
        child: Center(
          child: GestureDetector(
            onTap: AppInteractionFeedback.wrap(
              () => context.push('/item_detail', extra: item),
            ),
            onLongPress: () => _showDeleteDialog(context),
            child: Container(
              decoration: BoxDecoration(
                // 写真の場合は白背景、ステッカーの場合は透明（画像自体のフチを活かす）
                color: isSticker ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
                // 写真（未加工）の場合のみ、アプリ側で白枠を付ける
                border: isSticker
                    ? null
                    : Border.all(color: Colors.white, width: 6),
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: item.imagePath != null
                    ? Image.file(
                        File(item.imagePath!),
                        // ステッカーは全体を見せる(contain)、写真は枠いっぱい(cover)
                        fit: isSticker ? BoxFit.contain : BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.inventory_2_outlined,
                            color: Colors.grey),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

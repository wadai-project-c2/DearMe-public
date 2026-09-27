import 'package:flutter/material.dart';

import '../services/app_interaction_feedback.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/avatar_model.dart';

class InvolvedPeopleSection extends StatefulWidget {
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const InvolvedPeopleSection({
    super.key,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  State<InvolvedPeopleSection> createState() => _InvolvedPeopleSectionState();
}

class _InvolvedPeopleSectionState extends State<InvolvedPeopleSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final allAvatars = _sortAvatars(roomProvider.avatars);

    // 現在選択されているアバターを抽出（ソート済みリストから順序を維持）
    final selectedAvatars =
        allAvatars.where((a) => widget.selectedIds.contains(a.id)).toList();

    final sectionTitleStyle = Theme.of(context).textTheme.titleMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '登場メンバー',
            style: sectionTitleStyle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 選択済みアバターと「＋ メンバーを追加」ボタン
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ...selectedAvatars.map((avatar) => _AvatarIconItem(
                          avatar: avatar,
                          isSelected: true,
                          onTap: () {
                            final newSelection =
                                Set<String>.from(widget.selectedIds)
                                  ..remove(avatar.id);
                            widget.onSelectionChanged(newSelection);
                          },
                        )),
                    _AddAvatarButton(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      isExpanded: _isExpanded,
                    ),
                  ],
                ),
              ),
              // インライン展開されるメンバー選択エリア
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allAvatars.length,
                          itemBuilder: (context, index) {
                            final avatar = allAvatars[index];
                            final isSelected =
                                widget.selectedIds.contains(avatar.id);
                            return _AvatarIconItem(
                              avatar: avatar,
                              isSelected: isSelected,
                              onTap: () {
                                final newSelection =
                                    Set<String>.from(widget.selectedIds);
                                if (isSelected) {
                                  newSelection.remove(avatar.id);
                                } else {
                                  newSelection.add(avatar.id);
                                }
                                widget.onSelectionChanged(newSelection);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 「あなた(girl1)」を先頭に固定するソート処理
  List<AvatarModel> _sortAvatars(List<AvatarModel> avatars) {
    final list = List<AvatarModel>.from(avatars);
    list.sort((a, b) {
      if (a.id == 'girl1') return -1;
      if (b.id == 'girl1') return 1;
      return a.displayName.compareTo(b.displayName);
    });
    return list;
  }
}

class _AddAvatarButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isExpanded;

  const _AddAvatarButton({required this.onTap, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: AppInteractionFeedback.wrap(onTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'メンバーを追加',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarIconItem extends StatelessWidget {
  final AvatarModel avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarIconItem({
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // IDに基づいたアセットパスの取得
    final assetPath = _getAvatarAssetPath(avatar.id);

    return GestureDetector(
      onTap: AppInteractionFeedback.wrap(onTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFF5EFE6),
                    child: assetPath != null
                        ? Transform.scale(
                            scale: 1.4, // 1.4倍に拡大して顔を大きく表示
                            child: Image.asset(
                              assetPath,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                    'Failed to load avatar asset: $assetPath');
                                return const Icon(Icons.person, size: 32);
                              },
                            ),
                          )
                        : const Icon(Icons.person, size: 32),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 64,
              child: Text(
                avatar.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getAvatarAssetPath(String id) {
    switch (id) {
      case 'girl1':
        return 'assets/avatarphoto/you.png';
      case 'girl2':
        return 'assets/avatarphoto/mika.png';
      case 'youtienzi':
        return 'assets/avatarphoto/haruka.png';
      case 'boy':
        return 'assets/avatarphoto/shunsuke.png';
      default:
        return null;
    }
  }
}

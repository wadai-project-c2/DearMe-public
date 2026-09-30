import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/room_provider.dart';
import '../room/room_calibration.dart';
import '../room/room_scene_widget.dart';
import '../services/app_interaction_feedback.dart';

class InteriorCustomizePage extends StatefulWidget {
  const InteriorCustomizePage({super.key});

  @override
  State<InteriorCustomizePage> createState() => _InteriorCustomizePageState();
}

class _InteriorCustomizePageState extends State<InteriorCustomizePage> {
  PlacementSlot? _activeSlot;
  // 向きを選ぶ UI が無いため、画面の方を向く既定角度を使う（#97）。
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    final roomProvider = context.read<RoomProvider>();
    final roomId = roomProvider.selectedRoomId ?? RoomProvider.simpleRoomId;
    final calibration = RoomCalibrations.forRoom(roomId);
    _currentRotation = calibration.screenFacingYaw;
    if (calibration.placementSlots.isNotEmpty) {
      _activeSlot = calibration.placementSlots.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 3D Scene View
          _buildSceneView(),

          // 2. Top UI (Title & Back)
          _buildTopUI(),

          // 3. Slot Tabs (Categorized locations)
          _buildSlotTabs(),

          // 4. Bottom Item List
          _buildBottomGallery(),
        ],
      ),
    );
  }

  Widget _buildSceneView() {
    return Consumer<RoomProvider>(
      builder: (context, provider, child) {
        final room = provider.selectedRoom;
        if (room == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // For focus effect, we can adjust room camera if needed
        // For now, use the standard view
        return Positioned.fill(
          child: RoomSceneWidget(
            room: room,
            objects: provider.objectsForRoom(room.id),
            assignment: provider.assignmentForRoom(room.id),
            avatar: provider
                .avatarById(provider.assignmentForRoom(room.id)?.avatarId),
          ),
        );
      },
    );
  }

  Widget _buildTopUI() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.read<RoomProvider>().selectedRoom?.name ?? '部屋',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Text(
                  'インテリアカスタマイズ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon:
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
              label: const Text('ルール', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotTabs() {
    final roomProvider = context.read<RoomProvider>();
    final calibration =
        RoomCalibrations.forRoom(roomProvider.selectedRoomId ?? '');
    final slots = calibration.placementSlots;

    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: slots.map((slot) {
                final isSelected = _activeSlot?.id == slot.id;
                return GestureDetector(
                  onTap: AppInteractionFeedback.wrap(
                    context,
                    () => setState(() => _activeSlot = slot),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      border: isSelected
                          ? const Border(
                              bottom: BorderSide(color: Colors.white, width: 2))
                          : null,
                    ),
                    child: Text(
                      slot.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGallery() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Text('配置アイテム',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: _handleRemove,
                    child: const Text('収納する',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ItemProvider>(
                builder: (context, itemProvider, child) {
                  final items = itemProvider.items
                      .where((i) =>
                          i.processStatus == ImageProcessStatus.completed)
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildGalleryItem(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryItem(ItemModel item) {
    final isPlaced = context
        .watch<RoomProvider>()
        .objects
        .any((o) => o.itemId == item.id && o.isPlaced);

    return GestureDetector(
      onTap: AppInteractionFeedback.wrap(context, () => _handlePlace(item)),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: item.processedLocalImagePath != null
                        ? Image.file(File(item.processedLocalImagePath!),
                            fit: BoxFit.cover)
                        : const Icon(Icons.image, color: Colors.white30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            if (isPlaced)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('設置中',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlace(ItemModel item) async {
    if (_activeSlot == null) return;

    await context.read<RoomProvider>().placeItemAtSlot(
          itemId: item.id,
          roomId: context.read<RoomProvider>().selectedRoomId ?? '',
          posX: _activeSlot!.position.x,
          posY: _activeSlot!.position.y,
          posZ: _activeSlot!.position.z,
          rotationY: _currentRotation,
        );
  }

  Future<void> _handleRemove() async {
    if (_activeSlot == null) return;
    final roomProvider = context.read<RoomProvider>();
    final roomId = roomProvider.selectedRoomId ?? '';

    await roomProvider.removeItemAtSlot(
      roomId: roomId,
      posX: _activeSlot!.position.x,
      posZ: _activeSlot!.position.z,
    );
  }
}

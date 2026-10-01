import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/item_media_model.dart';
import '../models/item_model.dart';
import '../audio/audio_controller.dart';
import '../providers/item_provider.dart';
import '../providers/room_provider.dart';
import '../room/involved_people_section.dart';
import '../room/room_scene_widget.dart';
import '../services/app_interaction_feedback.dart';

class MemoInputScreen extends StatefulWidget {
  final String itemId;

  /// 新規登録フロー（写真登録→詳細入力）から開かれたかどうか。
  /// true の場合のみ、保存後にスワイプ配置演出へ進む（#62）。
  /// 詳細画面からの編集では元の画面へ pop で戻る。
  final bool isRegisterFlow;

  const MemoInputScreen({
    super.key,
    required this.itemId,
    this.isRegisterFlow = false,
  });

  @override
  State<MemoInputScreen> createState() => _MemoInputScreenState();
}

class _MemoInputScreenState extends State<MemoInputScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _memoController;
  late final FocusNode _memoFocusNode;
  final _picker = ImagePicker();

  bool _initialized = false;
  late ItemProvider _itemProvider;
  bool _isSaving = false;
  bool _isAddingMedia = false;
  DateTime? _usedFrom;
  DateTime? _usedUntil;
  ItemProvider? _observedItemProvider;
  ImageProcessStatus? _lastProcessStatus;

  /// スワイプ配置画面へ実際に遷移したかどうか。dispose時に、遷移せず
  /// 離脱した（＝先読みが消費されない）場合の後始末を判断するために使う。
  bool _navigatedToSwipePlacement = false;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
    _memoFocusNode = FocusNode();
    _memoFocusNode.addListener(() {
      if (!_memoFocusNode.hasFocus) {
        _saveMemoToProvider();
      }
    });
    WidgetsBinding.instance.addObserver(this);
    // ギャラリー/カメラ起動中にAndroidがMainActivityを破棄した場合、
    // pickMultiImage/pickVideoのFutureは解決も例外送出もされないまま失われる。
    // 画面復帰時にここで選択結果を回収する（#49と同じ対策）。
    unawaited(_recoverLostMedia());
    if (widget.isRegisterFlow) {
      // 新規登録フローのこの画面は、保存後にスワイプ配置画面（#107）へ
      // 進む直前の画面。AI画像加工待ちやメモ入力の合間にアイドル時間が
      // あるため、そのアイドル時間を使って部屋・家具のGLBパースを先に
      // 済ませておく。実際にスワイプ配置画面を開いた時はパース済みのものを
      // 譲り受けるだけで済み、体感の待ち時間が縮む
      // （メモ入力中に部屋の構成を変える手段は無いため、ここで仕込んだ
      // 先読みキーが後でずれる心配は無い）。
      // なおアバター本体GLBは現時点では先読み対象外。理由は
      // RoomSceneWidget.prewarmRoomSceneAssets のコメントを参照。
      // context.read はbuild完了後でないと安全に呼べないため、post frame
      // callbackへ回す（item_swipe_placement_page.dart の _bootstrap と
      // 同じ理由）。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _prewarmSwipePlacementAssets();
      });
    }
  }

  /// 部屋・アバターがまだRoomProviderに読み込まれていない場合は、先読みを
  /// 待たずに黙ってスキップする（この画面をブロックしてまで待つ理由は無い。
  /// 通常のフローではスワイプ配置画面自体がこのProviderの読み込み完了を
  /// 前提にしているため、先読みできなくても最終的には通常パースに
  /// フォールバックするだけで動作上の問題は無い）。
  void _prewarmSwipePlacementAssets() {
    final roomProvider = context.read<RoomProvider>();
    final room = roomProvider.roomById(RoomProvider.simpleRoomId);
    if (room == null) {
      return;
    }
    final assignment =
        roomProvider.assignmentForRoom(RoomProvider.simpleRoomId);
    final avatar = roomProvider.avatarById(assignment?.avatarId);
    RoomSceneWidget.prewarmRoomSceneAssets(room: room, avatar: avatar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<ItemProvider>(context, listen: false);
    _itemProvider = provider;
    if (!identical(_observedItemProvider, provider)) {
      _observedItemProvider?.removeListener(_handleItemProviderChanged);
      _observedItemProvider = provider;
      provider.addListener(_handleItemProviderChanged);
      _lastProcessStatus = provider.itemById(widget.itemId)?.processStatus;
    }
    final item = provider.itemById(widget.itemId);
    if (!_initialized && item != null) {
      _memoController.text = item.memo;
      _usedFrom = item.usedFrom;
      _usedUntil = item.usedUntil;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _observedItemProvider?.removeListener(_handleItemProviderChanged);
    // 保存ボタン経由で離脱する場合は既にflushされているため、冗長な保存を避ける
    if (!_isSaving) {
      _saveMemoToProvider();
    }
    // スワイプ配置画面へ実際に遷移した場合は、そちら側（画面自体のdisposeや
    // _loadGlbDataでのtake()消費）が後始末を担う。遷移せずに離脱した
    // （＝先読みが誰にも消費されない）場合だけ、ここで宙に浮いた先読み
    // 結果を破棄してメモリを解放する。
    if (!_navigatedToSwipePlacement) {
      GlbParsePrewarm.clear();
    }
    WidgetsBinding.instance.removeObserver(this);
    _memoController.dispose();
    _memoFocusNode.dispose();
    super.dispose();
  }

  void _handleItemProviderChanged() {
    final status =
        _observedItemProvider?.itemById(widget.itemId)?.processStatus;
    if (_lastProcessStatus != ImageProcessStatus.completed &&
        status == ImageProcessStatus.completed &&
        mounted) {
      try {
        unawaited(
          context
              .read<AudioController>()
              .playEffect(SoundEffect.processingComplete),
        );
      } on ProviderNotFoundException {
        // 単体のWidgetテストなど、アプリ全体のProvider外で使う場合は無音にする。
      }
    }
    _lastProcessStatus = status;
  }

  void _saveMemoToProvider() {
    _itemProvider.updateDetailMemo(widget.itemId, _memoController.text);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_recoverLostMedia());
    }
  }

  Future<void> _selectUsedFrom() async {
    final selected = await _showMonthPicker(_usedFrom);
    if (selected == null || !mounted) return;
    if (_usedUntil != null && selected.isAfter(_usedUntil!)) {
      _showMessage('使用開始年月は使用終了年月以前にしてください。');
      return;
    }
    setState(() => _usedFrom = selected);
    await context.read<ItemProvider>().setUsedFrom(widget.itemId, selected);
  }

  Future<void> _selectUsedUntil() async {
    final selected = await _showMonthPicker(
      _usedUntil ?? _usedFrom,
      minDate: _usedFrom,
    );
    if (selected == null || !mounted) {
      return;
    }
    // ダイアログのminDateにより通常は選択できないが、念のためのフォールバック。
    if (_usedFrom != null && selected.isBefore(_usedFrom!)) {
      _showMessage('使用終了年月は使用開始年月以降にしてください。');
      return;
    }
    setState(() => _usedUntil = selected);
    await context.read<ItemProvider>().setUsedUntil(widget.itemId, selected);
  }

  Future<DateTime?> _showMonthPicker(DateTime? initial, {DateTime? minDate}) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) =>
          _MonthPickerDialog(initial: initial, minDate: minDate),
    );
  }

  /// Androidでギャラリー/カメラ起動中にActivityが破棄された場合、選択結果は
  /// pickMultiImage/pickVideoのFutureではなくretrieveLostDataから取り出す。
  /// 未回収のままだと添付が反映されずエラーも出ないため、固まったように見える。
  Future<void> _recoverLostMedia() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty || !mounted) {
        return;
      }
      if (response.exception != null) {
        debugPrint(
          '[MemoInputScreen][recover_lost_media] retrieveLostData exception '
          'type=${response.exception.runtimeType}',
        );
        _showMessage('添付データを保存できませんでした。');
        return;
      }
      // 写真は複数選択があるためfilesを優先し、無ければ単一のfileを使う。
      final files = response.files ??
          (response.file == null ? const <XFile>[] : [response.file!]);
      if (files.isEmpty) {
        return;
      }
      final type = response.type == RetrieveType.video
          ? ItemMediaType.video
          : ItemMediaType.image;
      await _addMedia(files, type);
    } catch (error) {
      debugPrint(
        '[MemoInputScreen][recover_lost_media] failed '
        'type=${error.runtimeType}',
      );
      if (mounted) {
        _showMessage('添付データを保存できませんでした。');
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('写真を選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('動画を選択'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> result = await _picker.pickMultiImage(
        imageQuality: 95,
      );
      if (result.isEmpty || !mounted) return;
      await _addMedia(result);
    } catch (e) {
      debugPrint('Error picking images: $e');
      _showMessage('写真を選択できませんでした。');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? result = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (result == null || !mounted) return;
      await _addMedia([result]);
    } catch (e) {
      debugPrint('Error picking video: $e');
      _showMessage('動画を選択できませんでした。');
    }
  }

  Future<void> _addMedia(List<XFile> files, [ItemMediaType? type]) async {
    setState(() => _isAddingMedia = true);
    try {
      await context
          .read<ItemProvider>()
          .addMedia(widget.itemId, files, mediaType: type);
    } catch (_) {
      _showMessage('添付データを保存できませんでした。');
    } finally {
      if (mounted) setState(() => _isAddingMedia = false);
    }
  }

  Future<void> _removeMedia(ItemMediaModel media) async {
    try {
      await context.read<ItemProvider>().removeMedia(media);
    } catch (_) {
      _showMessage('データを削除できませんでした。');
    }
  }

  Future<void> _saveAndClose() async {
    _saveMemoToProvider();
    setState(() => _isSaving = true);
    try {
      final provider = context.read<ItemProvider>();
      await provider.flushPendingEdits(widget.itemId);
      final item = provider.itemById(widget.itemId);
      if (mounted) {
        // 新規登録フローでは、配置に使える画像（加工済み、無ければ元写真）があれば
        // スワイプ配置演出を経由する（#62/#95）。詳細画面からの編集では演出を挟まない。
        if (widget.isRegisterFlow && item?.placementImagePath != null) {
          _navigatedToSwipePlacement = true;
          context.go('/item_swipe_placement', extra: widget.itemId);
        } else if (context.canPop()) {
          // 詳細画面から遷移してきた場合は pop で戻る（go('/') だとホームに戻ってしまう）。
          context.pop();
        } else {
          // 履歴がない場合は安全にホームへ戻す。
          context.go('/');
        }
      }
    } catch (_) {
      _showMessage('入力内容を保存できませんでした。');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('思い出の詳細'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5EFE6), // 全体背景色
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Selector<ItemProvider, ItemModel?>(
          selector: (_, provider) => provider.itemById(widget.itemId),
          shouldRebuild: (prev, next) =>
              prev?.id != next?.id ||
              prev?.processStatus != next?.processStatus ||
              prev?.relatedAvatarIds != next?.relatedAvatarIds,
          builder: (context, item, _) {
            if (item == null) {
              return const Center(child: Text('登録中の品物が見つかりません。'));
            }
            final isProcessingImage =
                item.processStatus == ImageProcessStatus.uploading ||
                    item.processStatus == ImageProcessStatus.processing;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // メイン画像プレビュー（画像加工中などのステータス表示含む）
                        _ProcessingImage(item: item),
                        if (item.processStatus ==
                            ImageProcessStatus.failed) ...[
                          _ProcessingFailure(
                            item: item,
                            onRetry: () => context
                                .read<ItemProvider>()
                                .retryImageProcessing(widget.itemId),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // メモセクション
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('メモ', style: sectionTitleStyle),
                        ),
                        const SizedBox(height: 8),
                        _WhiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextField(
                                key: const ValueKey('memo_input_field'),
                                controller: _memoController,
                                focusNode: _memoFocusNode,
                                maxLines: 4,
                                maxLength: 1000,
                                decoration: const InputDecoration(
                                  hintText: 'エピソードを入力しましょう',
                                  border: InputBorder.none,
                                  counterText: '', // 標準のカウンタを隠す
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_memoController.text.length}/1000',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 使用期間セクション
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('使用期間', style: sectionTitleStyle),
                        ),
                        const SizedBox(height: 8),
                        _WhiteCard(
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month,
                                  color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectUsedFrom,
                                  child: Center(
                                    child: Text(
                                      _usedFrom == null
                                          ? '開始日'
                                          : '${_usedFrom!.year}.${_usedFrom!.month}',
                                      style: TextStyle(
                                        color: _usedFrom == null
                                            ? Colors.grey
                                            : Colors.black87,
                                        fontSize: 16, // 文字サイズを拡大
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(' 〜 ',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16)),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectUsedUntil,
                                  child: Center(
                                    child: Text(
                                      _usedUntil == null
                                          ? '終了日'
                                          : '${_usedUntil!.year}.${_usedUntil!.month}',
                                      style: TextStyle(
                                        color: _usedUntil == null
                                            ? Colors.grey
                                            : Colors.black87,
                                        fontSize: 16, // 文字サイズを拡大
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 追加メディアセクション
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('追加メディア', style: sectionTitleStyle),
                        ),
                        const SizedBox(height: 8),
                        _WhiteCard(
                          padding: const EdgeInsets.all(12),
                          clipBehavior: Clip.antiAlias, // 枠外へのはみ出しを防止
                          child: Selector<ItemProvider, List<ItemMediaModel>>(
                            selector: (_, provider) =>
                                provider.mediaFor(widget.itemId),
                            builder: (context, media, _) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8), // ×ボタンの表示スペースを確保
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ...media.map((m) => _MediaThumbnail(
                                            media: m,
                                            onRemove: () => _removeMedia(m),
                                          )),
                                      _AddMediaPlaceholder(
                                        onTap: _pickMedia,
                                        isLoading: _isAddingMedia,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 登場メンバーセクション
                        InvolvedPeopleSection(
                          selectedIds: item.relatedAvatarIds.toSet(),
                          onSelectionChanged: (ids) {
                            context
                                .read<ItemProvider>()
                                .setRelatedAvatars(widget.itemId, ids.toList());
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      // AI加工中は保存を待たせ、加工済み画像でスワイプ配置演出へ進める（#62）。
                      onPressed:
                          _isSaving || isProcessingImage ? null : _saveAndClose,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _isSaving
                            ? '保存中...'
                            : isProcessingImage
                                ? 'AI画像を加工中...'
                                : '思い出を記録する',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Clip clipBehavior;

  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: clipBehavior,
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
      child: child,
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final ItemMediaModel media;
  final VoidCallback onRemove;
  const _MediaThumbnail({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isVideo = media.mediaType == ItemMediaType.video;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.videocam, color: Colors.grey, size: 32),
                    ),
                  )
                : Image.file(
                    File(media.localPath),
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
          ),
          Positioned(
            right: -6,
            top: -6,
            child: GestureDetector(
              onTap: AppInteractionFeedback.wrap(context, onRemove),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMediaPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _AddMediaPlaceholder({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: AppInteractionFeedback.wrap(context, onTap),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.grey[600], size: 28),
                  const SizedBox(height: 4),
                  const Text('+画像/動画を追加',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}

class _ProcessingImage extends StatelessWidget {
  final ItemModel item;
  const _ProcessingImage({required this.item});

  @override
  Widget build(BuildContext context) {
    final processedPath = item.processedLocalImagePath;
    Widget mainContent;

    if (item.processStatus == ImageProcessStatus.completed &&
        processedPath != null) {
      mainContent = Image.file(
        File(processedPath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
          ),
        ),
      );
    } else {
      final originalPath = item.localImagePath;
      final original = originalPath == null
          ? const Icon(Icons.image_outlined, size: 72)
          : Image.file(
              File(originalPath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[100],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                ),
              ),
            );

      if (item.processStatus == ImageProcessStatus.processing ||
          item.processStatus == ImageProcessStatus.uploading) {
        mainContent = Stack(
          fit: StackFit.expand,
          children: [
            Opacity(opacity: 0.3, child: original),
            const Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('画像加工中')
              ],
            )),
          ],
        );
      } else {
        mainContent = original;
      }
    }

    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: mainContent,
      ),
    );
  }
}

class _ProcessingFailure extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onRetry;
  const _ProcessingFailure({required this.item, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
              child: Text(item.processErrorMessage ?? '画像加工に失敗しました',
                  style: const TextStyle(fontSize: 12))),
          TextButton(onPressed: onRetry, child: const Text('再試行')),
        ],
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime? initial;
  final DateTime? minDate;

  const _MonthPickerDialog({this.initial, this.minDate});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final minDate = widget.minDate;
    var initial = widget.initial ?? DateTime.now();
    if (minDate != null && initial.isBefore(minDate)) {
      initial = minDate;
    }
    _year = initial.year;
    _month = initial.month;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final minDate = widget.minDate;
    final firstYear = minDate != null
        ? minDate.year
        : (_year < currentYear - 100 ? _year : currentYear - 100);
    final lastYear = _year > currentYear + 10 ? _year : currentYear + 10;
    final firstMonth =
        minDate != null && _year == minDate.year ? minDate.month : 1;
    return AlertDialog(
      title: const Text('年月を選択'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _year,
              decoration: const InputDecoration(labelText: '年'),
              items: [
                for (var year = firstYear; year <= lastYear; year++)
                  DropdownMenuItem(value: year, child: Text('$year年')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _year = value;
                  if (minDate != null &&
                      _year == minDate.year &&
                      _month < minDate.month) {
                    _month = minDate.month;
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int>(
              key: ValueKey(_month),
              initialValue: _month,
              decoration: const InputDecoration(labelText: '月'),
              items: [
                for (var month = firstMonth; month <= 12; month++)
                  DropdownMenuItem(value: month, child: Text('$month月')),
              ],
              onChanged: (value) => setState(() => _month = value ?? _month),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル')),
        TextButton(
            onPressed: () =>
                Navigator.pop(context, DateTime.utc(_year, _month)),
            child: const Text('選択')),
      ],
    );
  }
}

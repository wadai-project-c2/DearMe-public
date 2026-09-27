import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/item_provider.dart';

class PhotoRegisterScreen extends StatefulWidget {
  final String? initialImagePath;
  final VoidCallback? onBackToHome;

  const PhotoRegisterScreen({
    super.key,
    this.initialImagePath,
    this.onBackToHome,
  });

  @override
  State<PhotoRegisterScreen> createState() => _PhotoRegisterScreenState();
}

class _PhotoRegisterScreenState extends State<PhotoRegisterScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();

  XFile? _selectedImage;
  bool _isSubmitting = false;
  String? _selectionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final initialImagePath = widget.initialImagePath;
    if (initialImagePath != null && initialImagePath.isNotEmpty) {
      _selectedImage = XFile(initialImagePath);
    }

    unawaited(_recoverLostImage());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _showTitleKeyboard() {
    _titleFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_titleFocusNode.hasFocus) return;
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_recoverLostImage());
    }
  }

  Future<void> _recoverLostImage() async {
    if (!Platform.isAndroid) return;
    try {
      final response = await _picker.retrieveLostData();
      debugPrint(
        '[PhotoRegister][lostData] isEmpty=${response.isEmpty} '
        'file=${response.file?.path} exception=${response.exception} '
        'type=${response.type} mounted=$mounted',
      );
      if (response.isEmpty || !mounted) return;
      final file = response.file;
      if (file != null) {
        setState(() {
          _selectedImage = file;
          _selectionError = null;
        });
      }
    } catch (e, st) {
      debugPrint('[PhotoRegister][lostData] threw $e\n$st');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 95);
      if (image == null || !mounted) return;
      setState(() {
        _selectedImage = image;
        _selectionError = null;
      });
    } catch (_) {
      if (mounted) setState(() => _selectionError = '写真を選択できませんでした。');
    }
  }

  void _showPickOptions() {
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
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('写真を撮る'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('ギャラリーから選ぶ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _startProcessing() async {
    final image = _selectedImage;
    if (image == null || !_formKey.currentState!.validate()) {
      setState(() => _selectionError = image == null ? '写真を選択してください。' : null);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final itemId = await context.read<ItemProvider>().startImageRegistration(
            title: _titleController.text,
            image: image,
          );
      if (mounted) {
        setState(_resetForm);
        widget.onBackToHome?.call();
        // flow=register を付けることで、保存後にスワイプ配置演出へ進む（#62）。
        context.push('/memo_input?flow=register', extra: itemId);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _selectionError = '登録を開始できませんでした。もう一度お試しください。');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _titleFocusNode.unfocus();
    _formKey.currentState?.reset();
    _selectedImage = null;
    _selectionError = null;
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'タイトルを入力してください。';
    if (title.runes.length > ItemModel.maxTitleLength) {
      return 'タイトルは50文字以内で入力してください。';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'ホームへ戻る',
          onPressed: widget.onBackToHome ?? () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('品物を登録'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // プレビュー画像カード
                      _ImageCard(
                        image: _selectedImage,
                        onClear: () => setState(() => _selectedImage = null),
                        onPick: _showPickOptions,
                      ),
                      const SizedBox(height: 24),

                      Text('タイトル', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _WhiteCard(
                        child: TextFormField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          maxLength: ItemModel.maxTitleLength,
                          decoration: const InputDecoration(
                            hintText: '例：お気に入りの椅子',
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          validator: _validateTitle,
                          onTap: _showTitleKeyboard,
                          onFieldSubmitted: (_) {
                            if (_selectedImage != null && !_isSubmitting) {
                              _startProcessing();
                            }
                          },
                        ),
                      ),
                      if (_selectionError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _selectionError!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  'AI画像加工はDEARME全体で1日50回まで（全利用者の合計）。\n'
                  '日本時間0時にリセットされます。\n'
                  '加工開始後の失敗・再試行も回数に含まれます。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _titleController,
                  builder: (context, value, child) {
                    final canSubmit = _selectedImage != null &&
                        value.text.trim().isNotEmpty &&
                        !_isSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: canSubmit ? _startProcessing : null,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_fix_high),
                        label: Text(_isSubmitting ? '準備中...' : '送信して加工を開始'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

class _ImageCard extends StatelessWidget {
  final XFile? image;
  final VoidCallback onClear;
  final VoidCallback onPick;

  const _ImageCard({
    required this.image,
    required this.onClear,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (image == null)
              InkWell(
                onTap: onPick,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('写真を撮る・選ぶ', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else ...[
              Positioned.fill(
                child: Image.file(
                  File(image!.path),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: onClear,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

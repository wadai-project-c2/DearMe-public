import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_interaction_feedback.dart';

class CreateMenuScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const CreateMenuScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7eeea),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 88,
        leadingWidth: 88,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            tooltip: 'ホームへ戻る',
            onPressed: onBackToHome ?? () => context.go('/'),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 34,
              color: Color(0xff555555),
            ),
          ),
        ),
        title: const Text(
          'CREATE',
          style: TextStyle(
            color: Color(0xffd86f76),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'サウンド設定',
            onPressed: () => _withButtonSound(
              context,
              () => context.push('/sound_settings'),
            ),
            icon: const Icon(Icons.music_note_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(36, 32, 36, 48),
          child: Column(
            children: [
              Expanded(
                child: _CreateCard(
                  label: 'AVATAR',
                  onTap: () => _withButtonSound(
                    context,
                    () => context.push('/avatar_create'),
                  ),
                ),
              ),
              const SizedBox(height: 38),
              Expanded(
                child: _CreateCard(
                  label: 'ROOM',
                  onTap: () => _withButtonSound(
                    context,
                    () => context.push('/room_placement'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _withButtonSound(BuildContext context, VoidCallback action) {
    AppInteractionFeedback.tap(context);
    action();
  }
}

class _CreateCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CreateCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xfffff8fa),
      elevation: 10,
      shadowColor: const Color(0x4d766b69),
      borderRadius: BorderRadius.circular(38),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(38),
        child: SizedBox.expand(
          child: Align(
            alignment: const Alignment(0, 0.76),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xffd86f76),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

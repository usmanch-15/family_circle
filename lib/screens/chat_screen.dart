import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/family_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/camera_service.dart';
import '../widgets/loading_widget.dart';
import 'members_screen.dart';
import 'ai_mediator_screen.dart';
import 'admin_screen.dart';
import 'calendar_screen.dart';
import 'expense_screen.dart';
import 'task_screen.dart';
import 'media_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final FamilyModel family;

  const ChatScreen({super.key, required this.family});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _chatService = ChatService();
  final _cameraService = CameraService();
  bool _sending = false;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  List<ChatModel> _searchResults = [];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _msgCtrl.clear();
    setState(() => _sending = true);

    try {
      await _chatService.sendTextMessage(
        familyId: widget.family.id,
        senderUid: user.uid,
        senderName: user.name,
        senderPhotoUrl: user.photoUrl,
        text: text,
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _sendImage() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final file = await _cameraService.pickPhotoFromGallery();
    if (file == null) return;

    setState(() => _sending = true);
    try {
      await _chatService.sendImageMessage(
        familyId: widget.family.id,
        senderUid: user.uid,
        senderName: user.name,
        senderPhotoUrl: user.photoUrl,
        imageFile: file,
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await _chatService.searchMessages(
      familyId: widget.family.id,
      query: query.trim(),
    );
    setState(() => _searchResults = results);
  }

  Future<void> _toggleLike(ChatModel message) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await _chatService.toggleLike(
      familyId: widget.family.id,
      messageId: message.id,
      userUid: user.uid,
      isCurrentlyLiked: message.isLikedBy(user.uid),
    );
  }

  void _openMenu(String value) {
    switch (value) {
      case 'members':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MembersScreen()));
        break;
      case 'media':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MediaScreen()));
        break;
      case 'calendar':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CalendarScreen(familyId: widget.family.id)));
        break;
      case 'expense':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ExpenseScreen(family: widget.family)));
        break;
      case 'tasks':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TaskScreen(family: widget.family)));
        break;
      case 'admin':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 0,
        title: _searching
            ? TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Message search karein...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: _runSearch,
        )
            : InkWell(
          onTap: () => _openMenu('members'),
          child: Row(
            children: [
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  Helpers.getInitials(widget.family.name),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.family.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text('${widget.family.memberCount} members',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchCtrl.clear();
                  _searchResults = [];
                }
              });
            },
          ),
          if (widget.family.aiEnabled)
            IconButton(
              icon: const Icon(Icons.psychology_rounded, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiMediatorScreen()),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _openMenu,
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'members',
                  child: Row(children: [
                    Icon(Icons.people_outline, size: 18),
                    SizedBox(width: 10),
                    Text('Members'),
                  ])),
              const PopupMenuItem(
                  value: 'media',
                  child: Row(children: [
                    Icon(Icons.photo_library_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Media'),
                  ])),
              const PopupMenuItem(
                  value: 'calendar',
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Calendar'),
                  ])),
              const PopupMenuItem(
                  value: 'expense',
                  child: Row(children: [
                    Icon(Icons.receipt_long_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Expenses'),
                  ])),
              const PopupMenuItem(
                  value: 'tasks',
                  child: Row(children: [
                    Icon(Icons.checklist_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Tasks'),
                  ])),
              if (widget.family.isAdmin(user?.uid ?? ''))
                const PopupMenuItem(
                    value: 'admin',
                    child: Row(children: [
                      Icon(Icons.admin_panel_settings_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Admin panel'),
                    ])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _searching && _searchCtrl.text.isNotEmpty
                ? _buildSearchResults(user?.uid ?? '')
                : _buildChatStream(user?.uid ?? ''),
          ),
          if (!_searching)
            _MessageInputBar(
              controller: _msgCtrl,
              onSend: _sendText,
              onImage: _sendImage,
              sending: _sending,
            ),
        ],
      ),
    );
  }

  Widget _buildChatStream(String currentUid) {
    return StreamBuilder<List<ChatModel>>(
      stream: _chatService.messagesStream(widget.family.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoadingWidget();
        final messages = snapshot.data!;

        if (messages.isEmpty) {
          return const Center(
            child: Text('Yahan se chat shuru karein',
                style: TextStyle(color: AppColors.textMuted)),
          );
        }

        return ListView.builder(
          controller: _scrollCtrl,
          reverse: true,
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final msg = messages[i];
            return _ChatMessageBubble(
              message: msg,
              isMe: msg.senderUid == currentUid,
              onLike: () => _toggleLike(msg),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(String currentUid) {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Koi message nahi mila',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (context, i) {
        final msg = _searchResults[i];
        return _ChatMessageBubble(
          message: msg,
          isMe: msg.senderUid == currentUid,
          onLike: () => _toggleLike(msg),
        );
      },
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatModel message;
  final bool isMe;
  final VoidCallback onLike;

  const _ChatMessageBubble({
    required this.message,
    required this.isMe,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLike,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 3),
              bottomRight: Radius.circular(isMe ? 3 : 14),
            ),
            border: isMe ? null : Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(message.senderName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              if (message.type == ChatMessageType.image &&
                  message.mediaUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(message.mediaUrl!,
                      width: 200, fit: BoxFit.cover),
                ),
              if (message.type == ChatMessageType.voice)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_fill,
                        color: isMe ? Colors.white : AppColors.primary,
                        size: 28),
                    const SizedBox(width: 8),
                    Text('${message.voiceDurationSeconds ?? 0}s',
                        style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textPrimary)),
                  ],
                ),
              if (message.type == ChatMessageType.text)
                Text(message.text ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(Helpers.formatTime(message.sentAt),
                      style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textMuted)),
                  if (message.likeCount > 0) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.favorite, size: 11, color: Colors.red),
                    const SizedBox(width: 2),
                    Text('${message.likeCount}',
                        style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white.withOpacity(0.7)
                                : AppColors.textMuted)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImage;
  final bool sending;

  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.onImage,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined, color: AppColors.textMuted),
              onPressed: onImage,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Message likhein...',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: sending
                  ? const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
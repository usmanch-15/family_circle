import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/family_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../services/chat_service.dart';
import '../widgets/loading_widget.dart';
import 'members_screen.dart';
import 'ai_mediator_screen.dart';
import 'admin_screen.dart';
import 'calendar_screen.dart';
import 'expense_screen.dart';
import 'task_screen.dart';
import 'media_screen.dart';
import 'mood_checkin_screen.dart';
import 'on_this_day_screen.dart';
import 'family_story_screen.dart';
import 'birthday_reminder_screen.dart';
import 'family_news_feed_screen.dart';
import 'document_screen.dart';
import 'search_screen.dart';
import 'event_planning_screen.dart';
import '../widgets/voice_record_button.dart';
import '../widgets/voice_message_player.dart';
import '../services/voice_recorder_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final FamilyModel family;
  const ChatScreen({super.key, required this.family});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl     = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final _chatService = ChatService();
  final _searchCtrl  = TextEditingController();
  bool _sending      = false;
  bool _searching    = false;
  bool _showAttach   = false;
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
    setState(() { _sending = true; _showAttach = false; });
    try {
      await _chatService.sendTextMessage(
        familyId:       widget.family.id,
        senderUid:      user.uid,
        senderName:     user.name,
        senderPhotoUrl: user.photoUrl,
        text:           text,
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _sendVoiceMessage(VoiceRecordResult result) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _sending = true);
    try {
      await _chatService.sendVoiceMessage(
        familyId:       widget.family.id,
        senderUid:      user.uid,
        senderName:     user.name,
        senderPhotoUrl: user.photoUrl,
        audioFile:      result.file,
        durationSeconds: result.durationSeconds,
      );
    } catch (e) {
      _showSnack('Voice message bhejne mein masla hua');
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
        familyId: widget.family.id, query: query.trim());
    setState(() => _searchResults = results);
  }

  Future<void> _toggleLike(ChatModel message) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await _chatService.toggleLike(
      familyId:         widget.family.id,
      messageId:        message.id,
      userUid:          user.uid,
      isCurrentlyLiked: message.isLikedBy(user.uid),
    );
  }

  void _openMenu(String value) {
    setState(() => _showAttach = false);
    switch (value) {
      case 'members':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen()));
        break;
      case 'media':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaScreen()));
        break;
      case 'calendar':
        Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen(familyId: widget.family.id)));
        break;
      case 'expense':
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseScreen(family: widget.family)));
        break;
      case 'tasks':
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskScreen(family: widget.family)));
        break;
      case 'admin':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
        break;
      case 'mood':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => MoodCheckinScreen(familyId: widget.family.id)));
        break;
      case 'on_this_day':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => OnThisDayScreen(familyId: widget.family.id)));
        break;
      case 'family_story':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => FamilyStoryScreen(
                familyId: widget.family.id,
                familyName: widget.family.name)));
        break;
      case 'birthdays':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => BirthdayReminderScreen(familyId: widget.family.id)));
        break;
      case 'feed':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => FamilyNewsFeedScreen(familyId: widget.family.id)));
        break;
      case 'search':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => SearchScreen(familyId: widget.family.id)));
        break;
      case 'event_planning':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => EventPlanningScreen(familyId: widget.family.id)));
        break;
      // case 'documents':
      //   Navigator.push(context, MaterialPageRoute(
      //       builder: (_) => DocumentScreen(familyId: widget.family.id)));
      //   break;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _searching
            ? TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: _runSearch,
        )
            : InkWell(
          onTap: () => _openMenu('members'),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  Helpers.getInitials(widget.family.name),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.family.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text('${widget.family.memberCount} members',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
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
          IconButton(
            icon: Icon(
              Icons.psychology_rounded,
              color: widget.family.aiEnabled
                  ? Colors.yellow.shade300
                  : Colors.white.withOpacity(0.45),
            ),
            onPressed: () {
              if (widget.family.aiEnabled) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AiMediatorScreen(familyId: widget.family.id)));
              } else {
                _showSnack('AI Mediator is group mein off hai');
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _openMenu,
            itemBuilder: (context) => [
              // Core features
              _mi('members',  Icons.people_outline,                'Members'),
              _mi('media',    Icons.photo_library_outlined,        'Media'),
              _mi('calendar', Icons.calendar_today_outlined,       'Calendar'),
              _mi('expense',  Icons.receipt_long_outlined,         'Expenses'),
              _mi('tasks',    Icons.checklist_outlined,            'Tasks'),
              _mi('search', Icons.search_outlined, 'Search 🔍'),
              _mi('event_planning', Icons.celebration_outlined, 'Event Planning 🎉'),
              // New features
              const PopupMenuDivider(),
              _mi('birthdays',    Icons.cake_outlined,             'Birthdays 🎂'),
              _mi('feed',         Icons.newspaper_outlined,        'Family Feed 📰'),
              _mi('mood',         Icons.emoji_emotions_outlined,   'Aaj ka Mood 😊'),
              _mi('on_this_day',  Icons.history_outlined,          'On This Day 🕰️'),
              _mi('family_story', Icons.auto_stories_outlined,     'Family Story 📖'),
              _mi('documents',    Icons.folder_outlined,           'Documents 📄'),
              // Admin
              if (widget.family.isAdmin(user?.uid ?? ''))
                ...[
                  const PopupMenuDivider(),
                  _mi('admin', Icons.admin_panel_settings_outlined, 'Admin Panel'),
                ],
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () { if (_showAttach) setState(() => _showAttach = false); },
        child: Column(
          children: [
            Expanded(
              child: _searching && _searchCtrl.text.isNotEmpty
                  ? _buildSearchResults(user?.uid ?? '')
                  : _buildChatStream(user?.uid ?? ''),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: _showAttach ? 160 : 0,
              color: Colors.white,
              child: _showAttach
                  ? _AttachPanel(
                onGallery:  () => _showSnack('Gallery: Android app mein available'),
                onCamera:   () => _showSnack('Camera: Android app mein available'),
                onDocument: () => _openMenu('documents'),
                onLocation: () => _showSnack('Location: Android app mein available'),
                onAudio:    () => _showSnack('Audio: Android app mein available'),
                onContact:  () => _showSnack('Contact: Android app mein available'),
              )
                  : null,
            ),
            _InputBar(
              controller: _msgCtrl,
              onSend:     _sendText,
              onAttach:   () => setState(() => _showAttach = !_showAttach),
              sending:    _sending,
              showAttach: _showAttach,
              onVoiceRecorded: _sendVoiceMessage,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _mi(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ]),
    );
  }

  Widget _buildChatStream(String currentUid) {
    return StreamBuilder<List<ChatModel>>(
      stream: _chatService.messagesStream(widget.family.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoadingWidget();
        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle),
                  child: Icon(Icons.chat_bubble_outline,
                      size: 42,
                      color: AppColors.primary.withOpacity(0.4)),
                ),
                const SizedBox(height: 14),
                const Text('Pehla message bhejein!',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 14)),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: _scrollCtrl,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, i) => _ChatBubble(
            message: messages[i],
            isMe:    messages[i].senderUid == currentUid,
            onLike:  () => _toggleLike(messages[i]),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(String currentUid) {
    if (_searchResults.isEmpty) {
      return const Center(
          child: Text('Koi message nahi mila',
              style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _searchResults.length,
      itemBuilder: (context, i) => _ChatBubble(
        message: _searchResults[i],
        isMe:    _searchResults[i].senderUid == currentUid,
        onLike:  () => _toggleLike(_searchResults[i]),
      ),
    );
  }
}

// ─── Attachment Panel ─────────────────────────────────────
class _AttachPanel extends StatelessWidget {
  final VoidCallback onGallery, onCamera, onDocument,
      onLocation, onAudio, onContact;
  const _AttachPanel({
    required this.onGallery, required this.onCamera,
    required this.onDocument, required this.onLocation,
    required this.onAudio, required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AttachItem(icon: Icons.photo_library_rounded, label: 'Gallery',  color: const Color(0xFF8B5CF6), onTap: onGallery),
          _AttachItem(icon: Icons.camera_alt_rounded,    label: 'Camera',   color: const Color(0xFF06B6D4), onTap: onCamera),
          _AttachItem(icon: Icons.insert_drive_file,     label: 'Document', color: const Color(0xFF3B82F6), onTap: onDocument),
          _AttachItem(icon: Icons.location_on_rounded,   label: 'Location', color: const Color(0xFF10B981), onTap: onLocation),
          _AttachItem(icon: Icons.headphones_rounded,    label: 'Audio',    color: const Color(0xFFF59E0B), onTap: onAudio),
          _AttachItem(icon: Icons.person_rounded,        label: 'Contact',  color: const Color(0xFFEF4444), onTap: onContact),
        ],
      ),
    );
  }
}

class _AttachItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachItem({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Input Bar ────────────────────────────────────────────
class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend, onAttach;
  final bool sending, showAttach;
  final void Function(VoiceRecordResult result) onVoiceRecorded;
  const _InputBar({required this.controller, required this.onSend,
    required this.onAttach, required this.sending,
    required this.showAttach, required this.onVoiceRecorded});

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _recordingActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!_recordingActive) ...[
              GestureDetector(
                onTap: widget.onAttach,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: widget.showAttach ? AppColors.primary : AppColors.cardBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.showAttach ? Icons.close : Icons.add,
                    color: widget.showAttach ? Colors.white : AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Message likhein...',
                            hintStyle: TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => widget.onSend(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:  Text('Camera: Android mein available'),
                            behavior: SnackBarBehavior.floating,
                          )),
                          child: const Icon(Icons.camera_alt_outlined,
                              color: AppColors.textMuted, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (hasText)
              GestureDetector(
                onTap: widget.sending ? null : widget.onSend,
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: widget.sending ? AppColors.textMuted : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: widget.sending
                      ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              )
            else if (_recordingActive)
              Expanded(
                child: VoiceRecordButton(
                  onRecorded: widget.onVoiceRecorded,
                  onRecordingStart: () => setState(() => _recordingActive = true),
                  onRecordingEnd: () => setState(() => _recordingActive = false),
                ),
              )
            else
              VoiceRecordButton(
                onRecorded: widget.onVoiceRecorded,
                onRecordingStart: () => setState(() => _recordingActive = true),
                onRecordingEnd: () => setState(() => _recordingActive = false),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat Bubble ──────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatModel message;
  final bool isMe;
  final VoidCallback onLike;
  const _ChatBubble(
      {required this.message, required this.isMe, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: onLike,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.cardBg,
                  child: Text(
                    message.senderName.isNotEmpty
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70),
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(16),
                    topRight:    const Radius.circular(16),
                    bottomLeft:  Radius.circular(isMe ? 16 : 3),
                    bottomRight: Radius.circular(isMe ? 3 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
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
                    if (message.type == ChatMessageType.voice &&
                        message.mediaUrl != null)
                      VoiceMessagePlayer(
                        audioUrl: message.mediaUrl!,
                        durationSeconds: message.voiceDurationSeconds ?? 0,
                        isMe: isMe,
                      ),
                    if (message.type == ChatMessageType.text)
                      Text(message.text ?? '',
                          style: TextStyle(
                              fontSize: 14,
                              color: isMe
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              height: 1.3)),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(Helpers.formatTime(message.sentAt),
                            style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white.withOpacity(0.65)
                                    : AppColors.textMuted)),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.done_all,
                              size: 12,
                              color: Colors.white.withOpacity(0.65)),
                        ],
                        if (message.likeCount > 0) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite,
                              size: 11, color: Colors.red),
                          const SizedBox(width: 2),
                          Text('${message.likeCount}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white.withOpacity(0.65)
                                      : AppColors.textMuted)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
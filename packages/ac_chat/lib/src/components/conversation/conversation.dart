import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/ac_chat.dart';
import '../../common/chat_colors.dart';
import 'message_bubble.dart';
import 'input_bar.dart';
import 'reply_bar.dart';
import 'attachments.dart';
import 'conversation_media_tabs.dart';
import '../../chat_profile_screen.dart';
import 'audio_recording_bottom_sheet.dart';

class StickyDateState {
  final DateTime? date;
  final double pushProgress;
  const StickyDateState(this.date, this.pushProgress);
}

class Conversation extends StatefulWidget {
  final AcChatConversation chat;
  final AcChatApi api;
  final VoidCallback? onBack;
  final bool isEmbedded;

  const Conversation({
    super.key,
    required this.chat,
    required this.api,
    this.onBack,
    this.isEmbedded = false,
  });

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmojiPicker = false;
  bool _isComposing = false;
  bool _showScrollFab = false;
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  AcChatMessage? _replyTo;
  late AnimationController _micAnim;

  List<AcChatMessage> _cachedMessages = [];
  List<dynamic> _flatItems = [];
  final Map<int, BuildContext> _itemContexts = {};
  final GlobalKey _listStackKey = GlobalKey();
  late final ValueNotifier<StickyDateState> _stickyDateNotifier =
      ValueNotifier<StickyDateState>(const StickyDateState(null, 0.0));

  StreamSubscription<List<AcChatMessage>>? _messagesSub;
  Timer? _typingTimer;

  bool get _isGroup => widget.chat.type == "group";

  void _loadMessages() {
    final all = widget.api.getMessages(conversationId: widget.chat.conversationId);
    if (_searchQuery.isEmpty) {
      _cachedMessages = all;
    } else {
      _cachedMessages = all
          .where((m) => m.text.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    _computeFlatItems();
  }

  void _computeFlatItems() {
    final List<dynamic> flat = [];
    DateTime? lastDate;
    for (final msg in _cachedMessages) {
      final msgDate = DateTime(msg.time.year, msg.time.month, msg.time.day);
      if (lastDate == null || !_sameDay(lastDate, msgDate)) {
        flat.add(msgDate);
        lastDate = msgDate;
      }
      flat.add(msg);
    }
    _flatItems = flat.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Live reactive stream subscription
    if (widget.api.watchMessages != null) {
      _messagesSub = widget.api.watchMessages!(conversationId: widget.chat.conversationId).listen((msgs) {
        if (mounted) {
          setState(() {
            if (_searchQuery.isEmpty) {
              _cachedMessages = msgs;
            } else {
              _cachedMessages = msgs
                  .where((m) => m.text.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();
            }
            _computeFlatItems();
          });
        }
      });
    }

    _micAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _scrollController.addListener(() {
      _updateStickyDate();
      final atBottom = _scrollController.position.pixels <= 100;
      if (atBottom != !_showScrollFab) {
        setState(() => _showScrollFab = !atBottom);
      }
    });

    _controller.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _isComposing) {
      setState(() => _isComposing = hasText);
    }
    if (widget.api.sendTypingIndicator != null) {
      widget.api.sendTypingIndicator!(
        conversationId: widget.chat.conversationId,
        isTyping: hasText,
      );
      _typingTimer?.cancel();
      if (hasText) {
        _typingTimer = Timer(const Duration(milliseconds: 2000), () {
          widget.api.sendTypingIndicator?.call(
            conversationId: widget.chat.conversationId,
            isTyping: false,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _typingTimer?.cancel();
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    _micAnim.dispose();
    _stickyDateNotifier.dispose();
    super.dispose();
  }

  void _updateStickyDate() {
    if (_flatItems.isEmpty) {
      _stickyDateNotifier.value = const StickyDateState(null, 0.0);
      return;
    }

    final RenderBox? stackBox =
        _listStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final stackTop = stackBox.localToGlobal(Offset.zero).dy;

    int? topDateIndex;
    int? nextDateIndex;
    double? nextDateTop;

    for (int i = 0; i < _flatItems.length; i++) {
      if (_flatItems[i] is! DateTime) continue;

      final ctx = _itemContexts[i];
      if (ctx == null) continue;
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final itemTop = renderBox.localToGlobal(Offset.zero).dy - stackTop;

      if (itemTop <= 16.0) {
        topDateIndex = i;
      } else {
        if (nextDateIndex == null) {
          nextDateIndex = i;
          nextDateTop = itemTop;
        }
        break;
      }
    }

    DateTime? currentDate;
    if (topDateIndex != null) {
      currentDate = _flatItems[topDateIndex] as DateTime;
    } else {
      for (int i = 0; i < _flatItems.length; i++) {
        if (_flatItems[i] is DateTime) {
          currentDate = _flatItems[i] as DateTime;
          break;
        }
      }
    }

    double progress = 0.0;
    if (nextDateTop != null) {
      const headerHeight = 36.0;
      const targetY = 16.0;
      if (nextDateTop < targetY + headerHeight) {
        progress = (targetY + headerHeight - nextDateTop) / headerHeight;
        progress = progress.clamp(0.0, 1.0);
      }
    }

    final cur = _stickyDateNotifier.value;
    if (cur.date != currentDate || (cur.pushProgress - progress).abs() > 0.01) {
      _stickyDateNotifier.value = StickyDateState(currentDate, progress);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = widget.api.getCurrentUser().userId
      ..type = 'text'
      ..text = text
      ..replyTo = _replyTo;

    widget.api.sendMessage(message: newMsg);
    _controller.clear();
    _replyTo = null;
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendAudio({required String filePath, required int durationSeconds}) {
    if (durationSeconds < 1) return;
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = widget.api.getCurrentUser().userId
      ..type = 'voice_note'
      ..text = '🎤 Voice message'
      ..duration = durationStr
      ..localPath = filePath
      ..isDownloaded = true
      ..replyTo = _replyTo;

    widget.api.sendMessage(message: newMsg);
    _replyTo = null;
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.api.theme;
    final isDark = ct.isDark;
    final msgs = _cachedMessages;

    AcChatUser? user;
    if (!_isGroup) {
      final members = widget.api.getConversationUsers(conversationId: widget.chat.conversationId);
      final otherMember = members.firstWhere(
        (m) => m.userId != widget.api.getCurrentUser().userId,
        orElse: () => AcChatConversationUser(),
      );
      if (otherMember.userId.isNotEmpty) {
        user = widget.api.getUserById(userId: otherMember.userId);
      }
    }

    final name = _isGroup
        ? (widget.chat.groupName ?? 'Group')
        : (user?.name ?? 'Unknown');
    final userId = _isGroup ? null : user?.userId;
    final color = avatarColor(_isGroup ? '${widget.chat.conversationId}-group' : (userId ?? ''));

    return AcChatApiProvider(
      api: widget.api,
      child: PopScope(
        canPop: !_showEmojiPicker,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_showEmojiPicker) {
            setState(() {
              _showEmojiPicker = false;
            });
          }
        },
        child: Scaffold(
          backgroundColor: ct.wallpaper,
          appBar: AppBar(
            backgroundColor: ct.appBar,
            elevation: 0,
            titleSpacing: widget.isEmbedded ? 16 : 0,
            leading: widget.isEmbedded
                ? null
                : IconButton(
                    icon: Icon(Icons.arrow_back, color: ct.white),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
            title: _showSearch
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: ct.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search messages…',
                      hintStyle: TextStyle(color: ct.white.withOpacity(0.6)),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _loadMessages();
                      });
                    },
                  )
                : InkWell(
                    onTap: () {
                      if (!widget.isEmbedded) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatProfileScreen(
                              chat: widget.chat,
                              api: widget.api,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(children: [
                      Hero(
                        tag: 'avatar-${widget.chat.conversationId}',
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: color,
                          child: _isGroup
                              ? Icon(Icons.group, color: ct.white, size: 20)
                              : Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                      color: ct.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: ct.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              _buildSubtitle(ct: ct, user: user),
                            ]),
                      ),
                    ]),
                  ),
            actions: _showSearch
                ? [
                    IconButton(
                      icon: Icon(Icons.close, color: ct.white),
                      onPressed: () {
                        _searchQuery = '';
                        _searchController.clear();
                        setState(() {
                          _showSearch = false;
                          _loadMessages();
                        });
                      },
                    )
                  ]
                : [
                    IconButton(
                      icon: Icon(Icons.search, color: ct.white),
                      onPressed: () => setState(() => _showSearch = true),
                    ),
                    if (widget.api.enableVideoCall)
                      IconButton(
                        icon: Icon(Icons.videocam_outlined, color: ct.white),
                        onPressed: () => _toast(context, 'Video call — coming soon'),
                      ),
                    if (widget.api.enableVoiceCall)
                      IconButton(
                        icon: Icon(Icons.call_outlined, color: ct.white),
                        onPressed: () => _toast(context, 'Voice call — coming soon'),
                      ),
                    if (widget.api.showConversationMenu)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: ct.white),
                        color: ct.surface,
                        onSelected: (v) {
                          if (v == 'Media, Links, and Docs') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConversationMediaTabs(
                                  chat: widget.chat,
                                  ct: ct,
                                ),
                              ),
                            );
                          } else {
                            _toast(context, '$v — coming soon');
                          }
                        },
                        itemBuilder: (_) => [
                          _menuItem('Media, Links, and Docs', ct),
                          _menuItem('Mute Notifications', ct),
                          _menuItem('Wallpaper', ct),
                          _menuItem('Clear Chat', ct),
                        ],
                      ),
                  ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  key: _listStackKey,
                  children: [
                    msgs.isEmpty
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: ct.dateChipBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🔒 Messages are end-to-end encrypted.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ct.dateChipText, fontSize: 12),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            itemCount: _flatItems.length,
                            itemBuilder: (context, index) {
                              final item = _flatItems[index];

                              return _TrackedItem(
                                index: index,
                                onMounted: (ctx) => _itemContexts[index] = ctx,
                                onUnmounted: (idx) => _itemContexts.remove(idx),
                                child: item is DateTime
                                    ? _DateChip(date: item, ct: ct)
                                    : MessageBubble(
                                        key: ValueKey((item as AcChatMessage).messageId),
                                        message: item,
                                        isGroup: _isGroup,
                                        ct: ct,
                                        isDark: isDark,
                                        onReply: (m) => setState(() => _replyTo = m),
                                        onCopy: (t) => _toast(context, 'Copied to clipboard'),
                                      ),
                              );
                            },
                          ),

                    // Sticky Date Chip
                    ValueListenableBuilder<StickyDateState>(
                      valueListenable: _stickyDateNotifier,
                      builder: (context, state, child) {
                        if (state.date == null) return const SizedBox.shrink();
                        return Positioned(
                          top: 8.0 - (state.pushProgress * 36.0),
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Opacity(
                              opacity: (1.0 - state.pushProgress).clamp(0.0, 1.0),
                              child: _DateChip(date: state.date!, ct: ct),
                            ),
                          ),
                        );
                      },
                    ),

                    // Scroll-to-bottom FAB
                    if (_showScrollFab)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          backgroundColor: ct.appBar,
                          onPressed: _scrollToBottom,
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: ct.white),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Input Bar
              if (widget.api.customInputBuilder != null)
                widget.api.customInputBuilder!(
                  context: context,
                  conversation: widget.chat,
                ) ??
                    _buildInputBar(ct, isDark)
              else
                _buildInputBar(ct, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle({required AcChatTheme ct, AcChatUser? user}) {
    if (widget.api.watchTyping != null) {
      return StreamBuilder<Map<String, bool>>(
        stream: widget.api.watchTyping!(conversationId: widget.chat.conversationId),
        builder: (context, snapshot) {
          final typingMap = snapshot.data ?? {};
          final someoneTyping = typingMap.entries
              .any((e) => e.key != widget.api.getCurrentUser().userId && e.value);

          if (someoneTyping) {
            return Text(
              'typing…',
              style: TextStyle(
                color: ct.activeTabColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            );
          }

          if (_isGroup) {
            return Text(
              _groupSubtitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
            );
          }

          if (widget.api.watchUserOnlineStatus != null && user != null) {
            return StreamBuilder<bool>(
              stream: widget.api.watchUserOnlineStatus!(userId: user.userId),
              builder: (ctx, onlSnap) {
                final isOnline = onlSnap.data ?? false;
                return Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
                );
              },
            );
          }

          return Text(
            widget.api.showOnlineStatus ? 'Online' : '',
            style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
          );
        },
      );
    }

    return Text(
      _isGroup ? _groupSubtitle() : (widget.api.showOnlineStatus ? 'Online' : ''),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
    );
  }

  Widget _buildInputBar(AcChatTheme ct, bool isDark) {
    if (widget.api.readOnly) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyTo != null)
          ReplyBar(
            message: _replyTo!,
            ct: ct,
            onCancel: () => setState(() => _replyTo = null),
          ),
        InputBar(
          controller: _controller,
          ct: ct,
          isDark: isDark,
          isRecording: false,
          micAnim: _micAnim,
          onSend: _send,
          onAttach: () => _showAttachmentModal(context, ct, isDark),
          onMicStart: () {},
          onMicStop: () {},
          onMicTap: () => _showAudioRecordingBottomSheet(context, ct),
          focusNode: _focusNode,
          showEmojiPicker: _showEmojiPicker,
          onEmojiToggle: () {
            setState(() {
              _showEmojiPicker = !_showEmojiPicker;
              if (_showEmojiPicker) {
                _focusNode.unfocus();
              } else {
                _focusNode.requestFocus();
              }
            });
          },
        ),
      ],
    );
  }

  String _groupSubtitle() {
    final members = widget.api.getConversationUsers(conversationId: widget.chat.conversationId);
    final names = members
        .map((m) => widget.api.getUserById(userId: m.userId)?.name ?? 'Unknown')
        .where((n) => n.isNotEmpty)
        .join(', ');
    return names.isNotEmpty ? names : 'tap here for group info';
  }

  void _showAttachmentModal(BuildContext context, AcChatTheme ct, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Attachments(
        ct: ct,
        isDark: isDark,
        onSelect: (label) {
          Navigator.pop(context);
          if (label == 'Document') {
            _sendMockDocument();
          } else if (label == 'Camera') {
            _sendMockImage('Camera');
          } else if (label == 'Gallery' || label.startsWith('Recent Media')) {
            _sendMockImage('Gallery');
          } else if (label == 'Audio') {
            _sendMockAudio();
          } else if (label == 'Location') {
            _showMockLocationSelector(context, ct);
          } else if (label == 'Contact') {
            _showMockContactSelector(context, ct);
          } else {
            _toast(context, '$label — coming soon');
          }
        },
      ),
    );
  }

  void _sendMockDocument() {
    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = widget.api.getCurrentUser().userId
      ..type = 'document'
      ..text = '📎 Project_Proposal.pdf'
      ..fileName = 'Project_Proposal.pdf'
      ..fileSize = '1.2 MB'
      ..isDownloaded = true;
    widget.api.sendMessage(message: newMsg);
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMockImage(String source) {
    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = widget.api.getCurrentUser().userId
      ..type = 'image'
      ..text = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600'
      ..fileName = 'image.png'
      ..mediaCaption = 'Captured via $source'
      ..isDownloaded = true;
    widget.api.sendMessage(message: newMsg);
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMockAudio() {
    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = widget.api.getCurrentUser().userId
      ..type = 'audio'
      ..text = '🎵 Background_Music.mp3'
      ..fileName = 'Background_Music.mp3'
      ..fileSize = '4.5 MB'
      ..duration = '3:20'
      ..isDownloaded = true;
    widget.api.sendMessage(message: newMsg);
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showMockLocationSelector(BuildContext context, AcChatTheme ct) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Share Location',
              style: TextStyle(
                color: ct.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.my_location, color: ct.activeTabColor),
            title: Text('Share Current Location', style: TextStyle(color: ct.text)),
            subtitle: Text('Accurate to 10 meters', style: TextStyle(color: ct.subText, fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              final newMsg = AcChatMessage()
                ..conversationId = widget.chat.conversationId
                ..senderId = widget.api.getCurrentUser().userId
                ..type = 'location'
                ..text = '📍 Current Location\nLat: 37.7749, Lng: -122.4194'
                ..isDownloaded = true;
              widget.api.sendMessage(message: newMsg);
              setState(() => _loadMessages());
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showMockContactSelector(BuildContext context, AcChatTheme ct) {
    final contacts = widget.api.getUsers();
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: contacts.length,
        itemBuilder: (ctx, i) {
          final c = contacts[i];
          final phone = c.phone;
          final contactInfo = (phone != null && phone.isNotEmpty) ? phone : (c.email ?? '');
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: avatarColor(c.userId),
              child: Text(
                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                style: TextStyle(color: ct.white),
              ),
            ),
            title: Text(c.name, style: TextStyle(color: ct.text)),
            subtitle: Text(contactInfo, style: TextStyle(color: ct.subText, fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              final newMsg = AcChatMessage()
                ..conversationId = widget.chat.conversationId
                ..senderId = widget.api.getCurrentUser().userId
                ..type = 'contact'
                ..text = '👤 ${c.name}\n$contactInfo'
                ..isDownloaded = true;
              widget.api.sendMessage(message: newMsg);
              setState(() => _loadMessages());
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            },
          );
        },
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String label, AcChatTheme ct) {
    return PopupMenuItem(
      value: label,
      child: Text(label, style: TextStyle(color: ct.text, fontSize: 14)),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  void _showAudioRecordingBottomSheet(BuildContext context, AcChatTheme ct) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AudioRecordingBottomSheet(
        ct: ct,
        onCompleted: ({required String filePath, required int durationSeconds}) {
          _sendAudio(filePath: filePath, durationSeconds: durationSeconds);
        },
      ),
    );
  }
}

class _TrackedItem extends StatefulWidget {
  final int index;
  final Widget child;
  final ValueChanged<BuildContext> onMounted;
  final ValueChanged<int> onUnmounted;

  const _TrackedItem({
    required this.index,
    required this.child,
    required this.onMounted,
    required this.onUnmounted,
  });

  @override
  State<_TrackedItem> createState() => _TrackedItemState();
}

class _TrackedItemState extends State<_TrackedItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onMounted(context);
    });
  }

  @override
  void dispose() {
    widget.onUnmounted(widget.index);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final AcChatTheme ct;

  const _DateChip({required this.date, required this.ct});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: ct.dateChipBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _formatChipDate(date),
          style: TextStyle(
            color: ct.dateChipText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatChipDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Yesterday';
    }
    if (now.difference(d).inDays < 7) {
      return DateFormat('EEEE').format(d);
    }
    return DateFormat('dd MMMM yyyy').format(d);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../core/ac_chat.dart';
import 'attachments.dart';
import 'conversation_background.dart';
import 'date_seperator.dart';
import 'input_bar.dart';
import 'message_bubble.dart';
import 'reply_bar.dart';
import 'audio_recording_bottom_sheet.dart';

class StickyDateState {
  final DateTime? date;
  final double pushOffset;
  const StickyDateState(this.date, this.pushOffset);
}

class Conversation extends StatefulWidget {
  final AcChatConversation chat;
  final bool isEmbedded;
  final VoidCallback? onShowProfile;
  final AcChatApi api;

  const Conversation({
    super.key,
    required this.chat,
    this.isEmbedded = false,
    this.onShowProfile,
    required this.api,
  });

  @override
  State<Conversation> createState() =>
      _ConversationState();
}

class _ConversationState extends State<Conversation>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  AcChatMessage? _replyTo;
  bool _showScrollFab = false;
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  bool _showEmojiPicker = false;
  bool _showSearch = false;
  String _searchQuery = '';
  late AnimationController _micAnim;
  List<AcChatMessage> _cachedMessages = [];
  List<dynamic> _flatItems = [];
  final Map<int, BuildContext> _itemContexts = {};
  final GlobalKey _listStackKey = GlobalKey();
  late final ValueNotifier<StickyDateState> _stickyDateNotifier =
      ValueNotifier<StickyDateState>(const StickyDateState(null, 0.0));

  bool get _isGroup => widget.chat.type == "group";

  void _loadMessages() {
    final all = widget.api.getMessages(widget.chat.conversationId);
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
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _micAnim.dispose();
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _stickyDateNotifier.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _updateStickyDate() {
    if (!mounted) return;
    if (_itemContexts.isEmpty) {
      if (_stickyDateNotifier.value.date != null) {
        _stickyDateNotifier.value = const StickyDateState(null, 0.0);
      }
      return;
    }

    final stackBox = _listStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final viewportTop = stackBox.localToGlobal(Offset.zero).dy;

    int? topmostIndex;
    double minY = double.infinity;

    for (final entry in _itemContexts.entries) {
      final box = entry.value.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;

      final y = box.localToGlobal(Offset.zero).dy;
      if (y < minY) {
        minY = y;
        topmostIndex = entry.key;
      }
    }

    if (topmostIndex == null) return;

    final topmostItem = _flatItems[topmostIndex];
    DateTime? bestDate;
    if (topmostItem is DateTime) {
      bestDate = topmostItem;
    } else if (topmostItem is AcChatMessage) {
      bestDate = DateTime(topmostItem.time.year, topmostItem.time.month, topmostItem.time.day);
    }

    double pushOffset = 0.0;
    const headerHeight = 36.0;

    for (final entry in _itemContexts.entries) {
      final item = _flatItems[entry.key];
      if (item is! DateTime) continue;

      final box = entry.value.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;

      final y = box.localToGlobal(Offset.zero).dy;
      final relativeY = y - viewportTop;

      if (relativeY > 0 && relativeY < headerHeight) {
        pushOffset = relativeY - headerHeight;
        break;
      }
    }

    bool showHeader = true;
    if (topmostItem is DateTime) {
      if (minY > viewportTop) {
        showHeader = false;
      }
    }

    final finalDate = showHeader ? bestDate : null;
    final newState = StickyDateState(finalDate, pushOffset);

    if (_stickyDateNotifier.value.date != newState.date ||
        _stickyDateNotifier.value.pushOffset != newState.pushOffset) {
      _stickyDateNotifier.value = newState;
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
    widget.api.sendMessage(newMsg);
    _controller.clear();
    _replyTo = null;
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendAudio(int durationSeconds) {
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
      ..replyTo = _replyTo;

    widget.api.sendMessage(newMsg);
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
      final members = widget.api.getConversationUsers(widget.chat.conversationId);
      final otherMember = members.firstWhere(
        (m) => m.userId != widget.api.getCurrentUser().userId,
        orElse: () => AcChatConversationUser(),
      );
      if (otherMember.userId.isNotEmpty) {
        user = widget.api.getUserById(otherMember.userId);
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: _showSearch
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: ct.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: TextStyle(color: ct.white60),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      setState(() {
                        _loadMessages();
                      });
                    },
                  )
                : InkWell(
                    onTap: () => _showProfileSheet(context, ct, name, color),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: color,
                        child: _isGroup
                            ? Icon(Icons.group, color: ct.white, size: 18)
                            : Text(
                                name[0].toUpperCase(),
                                style: TextStyle(
                                    color: ct.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
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
                              Text(
                                _isGroup ? _groupSubtitle() : 'Online',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                      color: ct.white.withOpacity(0.8),
                                      fontSize: 12),
                              ),
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
                    ),
                  ]
                : [
                    IconButton(
                      icon: Icon(Icons.search, color: ct.white),
                      onPressed: () {
                        setState(() {
                          _showSearch = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam_outlined, color: ct.white),
                      onPressed: () => _toast(context, 'Video call — coming soon'),
                    ),
                    IconButton(
                      icon: Icon(Icons.call_outlined, color: ct.white),
                      onPressed: () => _toast(context, 'Voice call — coming soon'),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: ct.white),
                      color: ct.surface,
                      onSelected: (v) {
                        if (v == 'View Contact') {
                          _showProfileSheet(context, ct, name, color);
                        } else if (v == 'Search') {
                          setState(() {
                            _showSearch = true;
                          });
                        } else {
                          _toast(context, '$v — coming soon');
                        }
                      },
                      itemBuilder: (_) => [
                        _menuItem('View Contact', ct),
                        _menuItem('Media, Links and Docs', ct),
                        _menuItem('Search', ct),
                        _menuItem('Mute Notifications', ct),
                        _menuItem('Clear Chat', ct),
                      ],
                    ),
                  ],
          ),
          body: Stack(children: [
            // Wallpaper pattern
            Positioned.fill(child: ConversationBackground(ct: ct)),
            Column(
                children: [
              // Messages list
              Expanded(
                child: msgs.isEmpty
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ct.dateChip.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🔒 Messages are end-to-end encrypted',
                      style:
                      TextStyle(color: ct.subText, fontSize: 12),
                    ),
                  ),
                )
                    : Stack(
                        key: _listStackKey,
                        children: [
                          Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(40, 12, 40, 8),
                              reverse: true,
                              itemCount: _flatItems.length,
                              itemBuilder: (context, index) {
                                final item = _flatItems[index];
                                Widget child;
                                if (item is DateTime) {
                                  child = DateSeparator(
                                    key: ValueKey(item),
                                    date: item,
                                    ct: ct,
                                  );
                                } else if (item is AcChatMessage) {
                                  bool isSenderChanged = false;
                                  if (index + 1 < _flatItems.length) {
                                    final prevItem = _flatItems[index + 1];
                                    if (prevItem is AcChatMessage && prevItem.senderId != item.senderId) {
                                      isSenderChanged = true;
                                    }
                                  }

                                  bool showTail = true;
                                  if (index - 1 >= 0) {
                                    final nextItem = _flatItems[index - 1];
                                    if (nextItem is AcChatMessage && nextItem.senderId == item.senderId) {
                                      showTail = false;
                                    }
                                  }

                                  child = MessageBubble(
                                    message: item,
                                    ct: ct,
                                    isDark: isDark,
                                    isGroup: _isGroup,
                                    onReply: (m) => setState(() => _replyTo = m),
                                    onCopy: (text) {
                                      Clipboard.setData(ClipboardData(text: text));
                                      _toast(context, 'Copied');
                                    },
                                    isSenderChanged: isSenderChanged,
                                    showTail: showTail,
                                  );
                                } else {
                                  child = const SizedBox.shrink();
                                }

                                return _TrackedItem(
                                  index: index,
                                  onMounted: (ctx) {
                                    _itemContexts[index] = ctx;
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _updateStickyDate());
                                  },
                                  onUnmounted: (idx) {
                                    _itemContexts.remove(idx);
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _updateStickyDate());
                                  },
                                  child: child,
                                );
                              },
                            ),
                          ),
                          ValueListenableBuilder<StickyDateState>(
                            valueListenable: _stickyDateNotifier,
                            builder: (context, state, child) {
                              if (state.date == null) return const SizedBox.shrink();
                              return Positioned(
                                top: state.pushOffset,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: DateSeparator(
                                    date: state.date!,
                                    ct: ct,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
  
              // Reply preview bar
              if (_replyTo != null)
                ReplyBar(
                  message: _replyTo!,
                  ct: ct,
                  onCancel: () => setState(() => _replyTo = null),
                ),
  
              // Input bar
              InputBar(
                controller: _controller,
                ct: ct,
                isDark: isDark,
                isRecording: _isRecording,
                micAnim: _micAnim,
                onSend: _send,
                onAttach: () => _showAttachSheet(context, ct, isDark),
                onMicStart: () {
                  setState(() {
                    _isRecording = true;
                    _recordingStartTime = DateTime.now();
                  });
                },
                onMicStop: () {
                  if (!_isRecording) return;
                  final duration = _recordingStartTime != null
                      ? DateTime.now().difference(_recordingStartTime!).inSeconds
                      : 0;
                  setState(() {
                    _isRecording = false;
                  });
                  _sendAudio(duration);
                },
                onMicCancel: () {
                  setState(() {
                    _isRecording = false;
                    _recordingStartTime = null;
                  });
                },
                onMicTap: () => _showAudioRecordingBottomSheet(context, ct),
                focusNode: _focusNode,
                showEmojiPicker: _showEmojiPicker,
                onEmojiToggle: () {
                  final width = MediaQuery.sizeOf(context).width;
                  final isDesktop = width >= 768;
                  if (isDesktop) {
                    _focusNode.unfocus();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: ct.surface,
                      builder: (context) => SizedBox(
                        height: 300,
                        child: EmojiPicker(
                          textEditingController: _controller,
                          config: Config(
                            height: 300,
                            checkPlatformCompatibility: true,
                            viewOrderConfig: const ViewOrderConfig(),
                            emojiViewConfig: EmojiViewConfig(
                              backgroundColor: ct.surface,
                            ),
                            categoryViewConfig: CategoryViewConfig(
                              backgroundColor: ct.inputBar,
                              indicatorColor: ct.activeTabColor,
                              iconColorSelected: ct.activeTabColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (_showEmojiPicker) {
                      _focusNode.requestFocus();
                    } else {
                      _focusNode.unfocus();
                    }
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  }
                },
              ),
              if (_showEmojiPicker && MediaQuery.sizeOf(context).width < 768)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    textEditingController: _controller,
                    config: Config(
                      height: 250,
                      checkPlatformCompatibility: true,
                      viewOrderConfig: const ViewOrderConfig(),
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: ct.surface,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: ct.inputBar,
                        indicatorColor: ct.activeTabColor,
                        iconColorSelected: ct.activeTabColor,
                      ),
                    ),
                  ),
                ),
            ]),
  
            // Scroll-to-bottom FAB
            if (_showScrollFab)
              Positioned(
                bottom: 72,
                right: 16,
                child: GestureDetector(
                  onTap: _scrollToBottom,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: ct.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: ct.black.withOpacity(0.25),
                            blurRadius: 6),
                      ],
                    ),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: ct.subText),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  String _groupSubtitle() {
    final ids = widget.chat.memberIds;
    final names = ids
        .map((id) =>
    id == widget.api.getCurrentUser().userId
        ? 'You'
        : widget.api.getUserById(id)?.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    return names.join(', ');
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showProfileSheet(
      BuildContext context, AcChatTheme ct, String name, Color color) {
    if (widget.onShowProfile != null) {
      widget.onShowProfile!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatProfileScreen(chat: widget.chat, api: widget.api),
        ),
      );
    }
  }

  void _showAttachSheet(BuildContext context, AcChatTheme ct, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.transparent,
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
    widget.api.sendMessage(newMsg);
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
    widget.api.sendMessage(newMsg);
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
    widget.api.sendMessage(newMsg);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Location to Share',
              style: TextStyle(color: ct.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _locationTile(context, ct, 'Times Square, New York', '40.7580° N, 73.9855° W'),
            _locationTile(context, ct, 'Eiffel Tower, Paris', '48.8584° N, 2.2945° E'),
            _locationTile(context, ct, 'Colosseum, Rome', '41.8902° N, 12.4922° E'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _locationTile(BuildContext context, AcChatTheme ct, String name, String coords) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ct.attachLocationBg.withOpacity(0.15),
        child: Icon(Icons.location_on_rounded, color: ct.attachLocationBg),
      ),
      title: Text(name, style: TextStyle(color: ct.text)),
      subtitle: Text(coords, style: TextStyle(color: ct.subText, fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        final newMsg = AcChatMessage()
          ..conversationId = widget.chat.conversationId
          ..senderId = widget.api.getCurrentUser().userId
          ..type = 'location'
          ..text = '$name ($coords)';
        widget.api.sendMessage(newMsg);
        setState(() {
          _loadMessages();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
    );
  }

  void _showMockContactSelector(BuildContext context, AcChatTheme ct) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Contact to Share',
              style: TextStyle(color: ct.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _contactTile(context, ct, 'Alice Johnson', '+1 (555) 019-9821'),
            _contactTile(context, ct, 'Bob Smith', '+1 (555) 014-2398'),
            _contactTile(context, ct, 'Charlie Brown', '+1 (555) 017-7401'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(BuildContext context, AcChatTheme ct, String name, String phone) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ct.attachContactBg.withOpacity(0.15),
        child: Text(name[0], style: TextStyle(color: ct.attachContactBg, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: TextStyle(color: ct.text)),
      subtitle: Text(phone, style: TextStyle(color: ct.subText, fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        final newMsg = AcChatMessage()
          ..conversationId = widget.chat.conversationId
          ..senderId = widget.api.getCurrentUser().userId
          ..type = 'contact'
          ..text = '$name\n$phone';
        widget.api.sendMessage(newMsg);
        setState(() {
          _loadMessages();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
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
        onCompleted: (duration) {
          _sendAudio(duration);
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
      if (mounted) {
        widget.onMounted(context);
      }
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



import 'dart:async';
import 'dart:io' as io;
import 'package:autocode/autocode.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/ac_chat.dart';
import '../../common/chat_colors.dart';
import 'message_bubble.dart';
import 'input_bar.dart';
import 'reply_bar.dart';
import 'attachments.dart';
import 'conversation_media_tabs.dart';
import '../chat_profile_screen.dart';
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
  final VoidCallback? onViewProfile;
  final bool? enableTyping;

  const Conversation({
    super.key,
    required this.chat,
    required this.api,
    this.onBack,
    this.isEmbedded = false,
    this.onViewProfile,
    this.enableTyping,
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
  AcChatMessage? _editingMessage;
  late AnimationController _micAnim;

  // Multi-select state
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};

  // Search filters
  String? _filterSenderId;
  DateTimeRange? _filterDateRange;
  bool? _filterHasAttachment;

  List<AcChatMessage> _cachedMessages = [];
  List<dynamic> _flatItems = [];
  final Map<int, BuildContext> _itemContexts = {};
  final GlobalKey _listStackKey = GlobalKey();
  late final ValueNotifier<StickyDateState> _stickyDateNotifier =
      ValueNotifier<StickyDateState>(const StickyDateState(null, 0.0));

  StreamSubscription<List<AcChatMessage>>? _messagesSub;
  Timer? _typingTimer;

  bool get _isGroup => widget.chat.type == "group";

  void _loadMessages() async {
    final all = await widget.api.getMessages(conversationId: widget.chat.conversationId);
    _cachedMessages = all.where((m) {
      if (_searchQuery.isNotEmpty &&
          !m.text.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterSenderId != null && m.senderId != _filterSenderId) {
        return false;
      }
      if (_filterHasAttachment != null) {
        final isMedia = m.type != 'text' && m.type != 'system';
        if (_filterHasAttachment! && !isMedia) return false;
        if (!_filterHasAttachment! && isMedia) return false;
      }
      if (_filterDateRange != null) {
        final start = _filterDateRange!.start.toUtc();
        final end = _filterDateRange!.end.toUtc().add(const Duration(days: 1));
        if (m.timeUtc.isBefore(start) || m.timeUtc.isAfter(end)) {
          return false;
        }
      }
      return true;
    }).toList();

    _computeFlatItems();
  }

  void _computeFlatItems() async {
    final List<dynamic> flat = [];
    DateTime? lastDate;
    final prefs = await widget.api.getConversationPrefs(conversationId: widget.chat.conversationId);
    final lastReadTime = prefs?.lastReadTimeUtc;

    var insertedUnreadSeparator = false;

    for (final msg in _cachedMessages) {
      final msgDate = DateTime.utc(msg.timeUtc.year, msg.timeUtc.month, msg.timeUtc.day);
      if (lastDate == null || !_sameDay(lastDate, msgDate)) {
        flat.add(msgDate);
        lastDate = msgDate;
      }

      // Unread separator insertion
      if (widget.api.enableUnreadMessagesSeparator &&
          !insertedUnreadSeparator &&
          lastReadTime != null &&
          msg.timeUtc.isAfter(lastReadTime) &&
          msg.senderId != (await widget.api.getCurrentUser()).userId) {
        flat.add(_UnreadSeparatorMarker());
        insertedUnreadSeparator = true;
      }

      flat.add(msg);
    }
    _flatItems = flat.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();

    if (widget.api.watchMessages != null) {
       widget.api.watchMessages(conversationId: widget.chat.conversationId).then((result){
        _messagesSub = result?.listen((msgs) {
          if (mounted) {
            setState(() {
              _loadMessages();
            });
          }
        });
      });

    }

    _micAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      if (widget.api.enableStickyDateHeaders) {
        _updateStickyDate();
      }
      if (widget.api.enableScrollToLatestFab) {
        final atBottom = _scrollController.position.pixels <= 100;
        if (atBottom != !_showScrollFab) {
          setState(() => _showScrollFab = !atBottom);
        }
      }
    });

    _controller.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _isComposing) {
      setState(() => _isComposing = hasText);
    }
    if (widget.api.enableTypingIndicator) {
      widget.api.sendTypingIndicator(
        conversationId: widget.chat.conversationId,
        isTyping: hasText,
      );
      _typingTimer?.cancel();
      if (hasText) {
        _typingTimer = Timer(const Duration(milliseconds: 2000), () {
          widget.api.sendTypingIndicator(
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
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingMessage != null) {
      // Editing message flow
      widget.api.editMessage(
        messageId: _editingMessage!.messageId,
        newText: text,
      );
      _editingMessage = null;
      _controller.clear();
      setState(() => _loadMessages());
      return;
    }

    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = (await widget.api.getCurrentUser()).userId
      ..type = 'text'
      ..text = text
      ..timeUtc = DateTime.now().toUtc()
      ..expiresAtUtc = _calculateExpiration()
      ..replyTo = _replyTo;

    widget.api.sendMessage(message: newMsg);
    _controller.clear();
    _replyTo = null;
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendAudio({required String filePath, required int durationSeconds}) async {
    if (durationSeconds < 1) return;
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final newMsg = AcChatMessage()
      ..conversationId = widget.chat.conversationId
      ..senderId = (await widget.api.getCurrentUser()).userId
      ..type = 'voice_note'
      ..text = '🎤 Voice message'
      ..duration = durationStr
      ..filePath = filePath
      ..localPath = filePath
      ..isDownloaded = true
      ..timeUtc = DateTime.now().toUtc()
      ..expiresAtUtc = _calculateExpiration()
      ..replyTo = _replyTo;

    widget.api.sendMessage(message: newMsg);
    _replyTo = null;
    setState(() {
      _loadMessages();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  DateTime? _calculateExpiration() {
    final dur = widget.chat.disappearingDurationSeconds;
    if (dur != null && dur > 0) {
      return DateTime.now().toUtc().add(Duration(seconds: dur));
    }
    return null;
  }

  void _openProfile() {
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
    } else {
      widget.onViewProfile?.call();
    }
  }

  // ── Multi-select actions ──────────────────────────────────────────────────

  void _toggleSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  void _batchCopy() {
    final selectedMsgs = _cachedMessages
        .where((m) => _selectedMessageIds.contains(m.messageId))
        .map((m) => m.text)
        .where((t) => t.isNotEmpty)
        .join('\n');
    if (selectedMsgs.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: selectedMsgs));
      _toast(context, 'Copied ${_selectedMessageIds.length} messages');
    }
    _cancelSelection();
  }

  void _batchForward() {
    _showForwardDialog(_selectedMessageIds.toList());
  }

  void _batchDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.api.theme.surface,
        title: Text('Delete ${_selectedMessageIds.length} messages?',
            style: TextStyle(color: widget.api.theme.text)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.api.deleteMessagesBatch(
                messageIds: _selectedMessageIds.toList(),
                forEveryone: false,
              );
              _cancelSelection();
              setState(() => _loadMessages());
            },
            child: Text('Delete for me', style: TextStyle(color: widget.api.theme.text)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.api.deleteMessagesBatch(
                messageIds: _selectedMessageIds.toList(),
                forEveryone: true,
              );
              _cancelSelection();
              setState(() => _loadMessages());
            },
            child: Text('Delete for everyone',
                style: TextStyle(color: widget.api.theme.messageDestructive)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: widget.api.theme.subText)),
          ),
        ],
      ),
    );
  }

  void _showForwardDialog(List<String> messageIds) async {
    final convs = await widget.api.getConversations();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.api.theme.surface,
        title: Text('Forward to…', style: TextStyle(color: widget.api.theme.text)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: convs.length,
            itemBuilder: (context, index) {
              final c = convs[index];
              final cName = c.conversationName ??
                  (c.type == 'group' ? 'Group' : 'Conversation');
              return ListTile(
                title: Text(cName, style: TextStyle(color: widget.api.theme.text)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.api.forwardMessages(
                    messageIds: messageIds,
                    targetConversationId: c.conversationId,
                  );
                  _cancelSelection();
                  _toast(context, 'Forwarded');
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Pinned Message Banner ─────────────────────────────────────────────────

  AcChatMessage? get _pinnedMessage {
    if (!widget.api.enablePinnedMessages) return null;
    final now = DateTime.now().toUtc();
    try {
      return _cachedMessages.firstWhere(
        (m) => m.pinnedUntilUtc != null && m.pinnedUntilUtc!.isAfter(now),
      );
    } catch (_) {
      return null;
    }
  }

  Widget? _buildPinnedBanner(AcChatTheme ct) {
    final pinned = _pinnedMessage;
    if (pinned == null) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: ct.appBar.withOpacity(0.95),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded, color: ct.activeTabColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pinned Message',
                    style: TextStyle(
                        color: ct.activeTabColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                Text(
                  pinned.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ct.white, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: ct.white, size: 16),
            onPressed: () {
              widget.api.unpinMessage(messageId: pinned.messageId);
              setState(() => _loadMessages());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox();
    buildAsync(context).then((widget){
      result = widget;
    });
    return result;
  }


  Future<Widget> buildAsync(BuildContext context) async {
    final ct = widget.api.theme;
    final isDark = ct.isDark;
    final msgs = _cachedMessages;
    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= 768;
    AcChatUser currentUser = await widget.api.getCurrentUser();
    AcChatUser? user;
    if (!_isGroup) {
      final members = await widget.api.getConversationUsers(conversationId: widget.chat.conversationId);
      final otherMember = members.firstWhere(
        (m) => m.userId != currentUser.userId,
        orElse: () => AcChatConversationUser(),
      );
      if (otherMember.userId.isNotEmpty) {
        user = await widget.api.getUserById(userId: otherMember.userId);
      }
    }

    final name = _isGroup
        ? (widget.chat.conversationName ?? 'Group')
        : (user?.name ?? 'Unknown');
    final userId = _isGroup ? null : user?.userId;
    final color = avatarColor(_isGroup ? '${widget.chat.conversationId}-group' : (userId ?? ''));

    final members = (await widget.api.getConversationUsers(conversationId: widget.chat.conversationId))
        .map((m) => widget.api.getUserById(userId: m.userId))
        .whereType<AcChatUser>()
        .toList();

    return AcChatApiProvider(
      api: widget.api,
      child: PopScope(
        canPop: !_showEmojiPicker && !_isSelectionMode,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_isSelectionMode) {
            _cancelSelection();
          } else if (_showEmojiPicker) {
            setState(() {
              _showEmojiPicker = false;
            });
          }
        },
        child: Scaffold(
          backgroundColor: ct.wallpaper,
          appBar: _isSelectionMode
              ? AppBar(
                  backgroundColor: ct.appBar,
                  leading: IconButton(
                    icon: Icon(Icons.close, color: ct.white),
                    onPressed: _cancelSelection,
                  ),
                  title: Text('${_selectedMessageIds.length} selected',
                      style: TextStyle(color: ct.white, fontSize: 18)),
                  actions: [
                    if (widget.api.enableBatchCopy)
                      IconButton(
                        icon: Icon(Icons.copy_rounded, color: ct.white),
                        onPressed: _batchCopy,
                      ),
                    if (widget.api.enableBatchForwarding)
                      IconButton(
                        icon: Icon(Icons.forward_rounded, color: ct.white),
                        onPressed: _batchForward,
                      ),
                    if (widget.api.enableBatchDeletion)
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: ct.white),
                        onPressed: _batchDelete,
                      ),
                  ],
                )
              : AppBar(
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
                          onTap: _openProfile,
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
                                    await _buildSubtitle(ct: ct, user: user),
                                  ]),
                            ),
                          ]),
                        ),
                  actions: _showSearch
                      ? [
                          if (widget.api.enableSearchFilters)
                            IconButton(
                              icon: Icon(Icons.filter_list_rounded, color: ct.white),
                              onPressed: () => _showSearchFilterSheet(context, ct, members),
                            ),
                          IconButton(
                            icon: Icon(Icons.close, color: ct.white),
                            onPressed: () {
                              _searchQuery = '';
                              _searchController.clear();
                              _filterSenderId = null;
                              _filterDateRange = null;
                              _filterHasAttachment = null;
                              setState(() {
                                _showSearch = false;
                                _loadMessages();
                              });
                            },
                          )
                        ]
                      : [
                          if (widget.api.enableInChatSearch)
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
                                if (v == (_isGroup ? 'Group Info' : 'Contact Info')) {
                                  _openProfile();
                                } else if (v == 'Media, Links, and Docs') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ConversationMediaTabs(
                                        chat: widget.chat,
                                        ct: ct,
                                        api: widget.api,
                                      ),
                                    ),
                                  );
                                } else if (v == 'Mute Notifications') {
                                  _showMuteDialog(context, ct);
                                } else if (v == 'Export Chat') {
                                  _showExportDialog(context, ct);
                                } else if (v == 'Block User' && user != null) {
                                  widget.api.blockUser(userId: user.userId);
                                  _toast(context, 'User blocked');
                                } else if (v == 'Report User' && user != null) {
                                  widget.api.reportUser(userId: user.userId, reason: 'Reported by user');
                                  _toast(context, 'User reported');
                                } else {
                                  _toast(context, '$v — coming soon');
                                }
                              },
                              itemBuilder: (_) => [
                                _menuItem(_isGroup ? 'Group Info' : 'Contact Info', ct),
                                if (widget.api.enableSharedMediaGallery)
                                  _menuItem('Media, Links, and Docs', ct),
                                if (widget.api.enableConversationMuting)
                                  _menuItem('Mute Notifications', ct),
                                if (widget.api.enableChatExport)
                                  _menuItem('Export Chat', ct),
                                if (!_isGroup && user != null && widget.api.enableUserBlocking)
                                  _menuItem('Block User', ct),
                                if (!_isGroup && user != null && widget.api.enableUserReporting)
                                  _menuItem('Report User', ct),
                              ],
                            ),
                        ],
                ),
          body: Column(
            children: [
              // Pinned Message Banner
              if (_buildPinnedBanner(ct) != null)
                _buildPinnedBanner(ct)!,

              Expanded(
                child: Stack(
                  key: _listStackKey,
                  children: [
                    msgs.isEmpty
                        ? Center(
                            child: widget.api.isEndToEndEncrypted ?Container(
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
                            ):SizedBox(),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding:  EdgeInsets.symmetric(
                                horizontal: isLarge?50:8, vertical: 8),
                            itemCount: _flatItems.length,
                            itemBuilder: (context, index) {
                              final item = _flatItems[index];

                              if (item is _UnreadSeparatorMarker) {
                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ct.unreadBadgeBg.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Unread Messages',
                                      style: TextStyle(
                                        color: ct.unreadBadgeBg,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return _TrackedItem(
                                index: index,
                                onMounted: (ctx) => _itemContexts[index] = ctx,
                                onUnmounted: (idx) => _itemContexts.remove(idx),
                                child: item is DateTime
                                  ? _DateChip(date: item.toLocal(), ct: ct)
                                  : MessageBubble(
                                      key: ValueKey((item as AcChatMessage).messageId),
                                      message: item,
                                      isGroup: _isGroup,
                                      ct: ct,
                                      isDark: isDark,
                                      isSelected: _selectedMessageIds.contains(item.messageId),
                                      isSelectionMode: _isSelectionMode,
                                      onSelect: widget.api.enableMultiSelect
                                          ? () => _toggleSelection(item.messageId)
                                          : null,
                                      onReply: (m) => setState(() => _replyTo = m),
                                      onCopy: (t) => _toast(context, 'Copied to clipboard'),
                                      onEdit: (m) {
                                        setState(() {
                                          _editingMessage = m;
                                          _controller.text = m.text;
                                        });
                                      },
                                      onForward: (m) => _showForwardDialog([m.messageId]),
                                      onDelete: (m, forEveryone) {
                                        if (forEveryone) {
                                          widget.api.deleteMessageForEveryone(messageId: m.messageId);
                                        } else {
                                          widget.api.deleteMessageForMe(messageId: m.messageId);
                                        }
                                        setState(() => _loadMessages());
                                      },
                                      onStar: (m) {
                                        widget.api.setStarred(
                                          messageId: m.messageId,
                                          isStarred: !m.isStarred,
                                        );
                                        setState(() => _loadMessages());
                                      },
                                      onPin: (m) {
                                        widget.api.pinMessage(
                                          messageId: m.messageId,
                                          duration: const Duration(days: 7),
                                        );
                                        setState(() => _loadMessages());
                                      },
                                      onReaction: (m, emoji) async {
                                        final myId = currentUser.userId;
                                        final already = m.reactions[emoji]?.contains(myId) ?? false;
                                        if (already) {
                                          widget.api.removeReaction(messageId: m.messageId, emoji: emoji);
                                        } else {
                                          widget.api.addReaction(messageId: m.messageId, emoji: emoji);
                                        }
                                        setState(() => _loadMessages());
                                      },
                                    ),
                              );
                            },
                          ),

                    // Sticky Date Chip
                    if (widget.api.enableStickyDateHeaders)
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
                                child: _DateChip(date: state.date!.toLocal(), ct: ct),
                              ),
                            ),
                          );
                        },
                      ),

                    // Scroll-to-bottom FAB
                    if (widget.api.enableScrollToLatestFab && _showScrollFab)
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
                    _buildInputBar(ct, isDark, members)
              else
                _buildInputBar(ct, isDark, members),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> _buildSubtitle({required AcChatTheme ct, AcChatUser? user}) async {
    if (widget.api.enableTypingIndicator) {
      var currentUser = await widget.api.getCurrentUser();
      var typingStream = (await widget.api.watchTyping(conversationId: widget.chat.conversationId));
      var onlineStream;
      if(widget.api.enableOnlinePresence && user != null){
        onlineStream =await widget.api.watchUserOnlineStatus(userId: user.userId);
      }
      String groupSubtitle = await _groupSubtitle();
      return StreamBuilder<Map<String, bool>>(
        stream: typingStream,
        builder: (context, snapshot) {
          final typingMap = snapshot.data ?? {};
          final someoneTyping = typingMap.entries.any((e) => e.key != currentUser.userId && e.value);

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
              groupSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
            );
          }

          if (widget.api.enableOnlinePresence &&
              widget.api.watchUserOnlineStatus != null &&
              user != null) {
            return StreamBuilder<bool>(
              stream: onlineStream,
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
            widget.api.enableOnlinePresence ? 'Online' : '',
            style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
          );
        },
      );
    }

    return Text(
      _isGroup ? await _groupSubtitle() : (widget.api.enableOnlinePresence ? 'Online' : ''),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: ct.white.withOpacity(0.8), fontSize: 12),
    );
  }

  Widget _buildInputBar(AcChatTheme ct, bool isDark, List<AcChatUser> members) {
    if (widget.api.readOnly) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_editingMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: ct.surface,
            child: Row(
              children: [
                Icon(Icons.edit_rounded, color: ct.activeTabColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Editing message: "${_editingMessage!.text}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ct.text, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16, color: ct.subText),
                  onPressed: () {
                    setState(() {
                      _editingMessage = null;
                      _controller.clear();
                    });
                  },
                ),
              ],
            ),
          ),
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
          enableTyping: widget.enableTyping ?? widget.api.enableTyping,
          micAnim: _micAnim,
          api: widget.api,
          mentionCandidates: members,
          onSend: _send,
          onAttach: () => _showAttachmentModal(context, ct, isDark),
          onAttachOption: (label) => _handleAttachmentSelected(label, ct),
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

  Future<String> _groupSubtitle() async {
    final members = await widget.api.getConversationUsers(conversationId: widget.chat.conversationId);
    final names = members.map((m) async => (await widget.api.getUserById(userId: m.userId))?.name ?? 'Unknown');
        // .where((n) => n.isNotEmpty)
        // .join(', ');
    // return names.isNotEmpty ? names : 'tap here for group info';
    return "";
  }

  void _showAttachmentModal(BuildContext context, AcChatTheme ct, bool isDark) {
    if (!widget.api.enableMediaAttachments) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Attachments(
        ct: ct,
        isDark: isDark,
        api: widget.api,
        onSelect: (label) {
          Navigator.pop(context);
          _handleAttachmentSelected(label, ct);
        },
      ),
    );
  }

  void _handleAttachmentSelected(String label, AcChatTheme ct) {
    if (!widget.api.enableMediaAttachments) return;
    if (label == 'Document' && widget.api.enableDocumentAttachments) {
      _pickAndSendDocument();
    } else if (label == 'Camera' && widget.api.enableImageAttachments) {
      _pickAndSendImage(isCamera: true);
    } else if ((label == 'Gallery' || label.startsWith('Recent Media')) &&
        (widget.api.enableImageAttachments || widget.api.enableVideoAttachments)) {
      _pickAndSendImage(isCamera: false);
    } else if (label == 'Audio' && widget.api.enableVoiceNotes) {
      _pickAndSendAudio();
    } else if (label == 'Location') {
      _showMockLocationSelector(context, ct);
    } else if (label == 'Contact') {
      _showMockContactSelector(context, ct);
    } else {
      _toast(context, '$label — coming soon');
    }
  }

  Future<void> _pickAndSendDocument() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv', 'zip', 'rar', 'ppt', 'pptx'],
      );
      if (file == null) return;
      await _dispatchPickedFile(
        type: 'document',
        file: file,
        defaultFileName: 'document.pdf',
      );
    } catch (e) {
      debugPrint('[Conversation] Error picking document: $e');
    }
  }

  Future<void> _pickAndSendImage({bool isCamera = false}) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file == null) return;
      await _dispatchPickedFile(
        type: 'image',
        file: file,
        defaultFileName: 'image.png',
      );
    } catch (e) {
      debugPrint('[Conversation] Error picking image: $e');
    }
  }

  Future<void> _pickAndSendAudio() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.audio,
      );
      if (file == null) return;
      await _dispatchPickedFile(
        type: 'audio',
        file: file,
        defaultFileName: 'audio.mp3',
      );
    } catch (e) {
      debugPrint('[Conversation] Error picking audio: $e');
    }
  }

  Future<void> _dispatchPickedFile({
    required String type,
    required PlatformFile file,
    required String defaultFileName,
  }) async {
    final fileName = file.name.isNotEmpty ? file.name : defaultFileName;
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      debugPrint('[Conversation] Error reading bytes from file: $e');
    }
    if ((bytes == null || bytes.isEmpty) && file.path != null && !kIsWeb) {
      try {
        bytes = await io.File(file.path!).readAsBytes();
      } catch (_) {}
    }
    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        _toast(context, 'Could not read file data');
      }
      return;
    }

    if (bytes.length > widget.api.maxAttachmentSizeBytes) {
      if (mounted) {
        _toast(context, 'File exceeds maximum size limit (${widget.api.maxAttachmentSizeBytes ~/ (1024 * 1024)} MB)');
      }
      return;
    }

    final fileSize = _formatFileSize(bytes.length);
    final messageId = Autocode.uuid();

    final newMsg = AcChatMessage()
      ..messageId = messageId
      ..conversationId = widget.chat.conversationId
      ..senderId = (await widget.api.getCurrentUser()).userId
      ..type = type
      ..text = ''
      ..filePath = file.path
      ..localPath = file.path
      ..fileName = fileName
      ..fileSize = fileSize
      ..byteData = bytes
      ..isDownloaded = true
      ..timeUtc = DateTime.now().toUtc()
      ..expiresAtUtc = _calculateExpiration()
      ..replyTo = _replyTo
      ..status = 'sending';

    _replyTo = null;
    widget.api.sendMessage(message: newMsg);
    if (mounted) {
      setState(() {
        _loadMessages();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    final uploader = widget.api.mediaUploader;
    if (uploader != null) {
      try {
        final mimeType = _inferMimeType(fileName);
        final publicUrl = await uploader.uploadMedia(
          conversationId: widget.chat.conversationId,
          messageId: messageId,
          fileName: fileName,
          bytes: bytes,
          mimeType: mimeType,
        );

        newMsg.fileUrl = publicUrl;
        newMsg.status = 'sent';
        if (mounted) {
          setState(() {
            _loadMessages();
          });
        }
      } catch (e) {
        debugPrint('[Conversation] uploadMedia failed: $e');
        newMsg.status = 'failed';
        if (mounted) {
          setState(() {
            _loadMessages();
          });
        }
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _inferMimeType(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1) return 'application/octet-stream';
    final ext = fileName.substring(dot + 1).toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
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
            onTap: () async {
              Navigator.pop(context);
              final newMsg = AcChatMessage()
                ..conversationId = widget.chat.conversationId
                ..senderId = (await widget.api.getCurrentUser()).userId
                ..type = 'location'
                ..text = '📍 Current Location\nLat: 37.7749, Lng: -122.4194'
                ..isDownloaded = true
                ..timeUtc = DateTime.now().toUtc()
                ..expiresAtUtc = _calculateExpiration();
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

  void _showMockContactSelector(BuildContext context, AcChatTheme ct) async {
    final contacts = await widget.api.getUsers();
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
          final contactInfo = (phone != null && phone.isNotEmpty) ? phone : (c.email);
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
            onTap: () async {
              Navigator.pop(context);
              final newMsg = AcChatMessage()
                ..conversationId = widget.chat.conversationId
                ..senderId = (await widget.api.getCurrentUser()).userId
                ..type = 'contact'
                ..text = '👤 ${c.name}\n$contactInfo'
                ..isDownloaded = true
                ..timeUtc = DateTime.now().toUtc()
                ..expiresAtUtc = _calculateExpiration();
              widget.api.sendMessage(message: newMsg);
              setState(() => _loadMessages());
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            },
          );
        },
      ),
    );
  }

  void _showMuteDialog(BuildContext context, AcChatTheme ct) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: ct.surface,
        title: Text('Mute notifications for…', style: TextStyle(color: ct.text)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              widget.api.muteConversation(
                conversationId: widget.chat.conversationId,
                muteDuration: const Duration(hours: 8),
              );
              _toast(context, 'Muted for 8 hours');
            },
            child: Text('8 Hours', style: TextStyle(color: ct.text)),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              widget.api.muteConversation(
                conversationId: widget.chat.conversationId,
                muteDuration: const Duration(days: 7),
              );
              _toast(context, 'Muted for 1 week');
            },
            child: Text('1 Week', style: TextStyle(color: ct.text)),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              widget.api.muteConversation(
                conversationId: widget.chat.conversationId,
                muteDuration: const Duration(days: 3650),
              );
              _toast(context, 'Muted indefinitely');
            },
            child: Text('Always', style: TextStyle(color: ct.text)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, AcChatTheme ct) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: ct.surface,
        title: Text('Export Chat', style: TextStyle(color: ct.text)),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              final text = await widget.api.exportChat(
                conversationId: widget.chat.conversationId,
                asJson: false,
              );
              Clipboard.setData(ClipboardData(text: text));
              if (mounted) _toast(context, 'Chat exported to clipboard');
            },
            child: Text('Plain Text', style: TextStyle(color: ct.text)),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              final jsonStr = await widget.api.exportChat(
                conversationId: widget.chat.conversationId,
                asJson: true,
              );
              Clipboard.setData(ClipboardData(text: jsonStr));
              if (mounted) _toast(context, 'Chat JSON exported to clipboard');
            },
            child: Text('JSON', style: TextStyle(color: ct.text)),
          ),
        ],
      ),
    );
  }

  void _showSearchFilterSheet(BuildContext context, AcChatTheme ct, List<AcChatUser> members) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search Filters',
                    style: TextStyle(
                        color: ct.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _filterSenderId,
                  dropdownColor: ct.surface,
                  decoration: InputDecoration(
                    labelText: 'Sender',
                    labelStyle: TextStyle(color: ct.subText),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('All Senders', style: TextStyle(color: ct.text)),
                    ),
                    ...members.map((u) => DropdownMenuItem(
                          value: u.userId,
                          child: Text(u.name, style: TextStyle(color: ct.text)),
                        )),
                  ],
                  onChanged: (val) {
                    setModalState(() => _filterSenderId = val);
                    setState(() {
                      _filterSenderId = val;
                      _loadMessages();
                    });
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Attachments Only', style: TextStyle(color: ct.text)),
                  value: _filterHasAttachment ?? false,
                  activeColor: ct.activeTabColor,
                  onChanged: (val) {
                    setModalState(() => _filterHasAttachment = val ? true : null);
                    setState(() {
                      _filterHasAttachment = val ? true : null;
                      _loadMessages();
                    });
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (range != null) {
                      setModalState(() => _filterDateRange = range);
                      setState(() {
                        _filterDateRange = range;
                        _loadMessages();
                      });
                    }
                  },
                  child: Text(
                    _filterDateRange != null
                        ? 'Date: ${DateFormat('yyyy-MM-dd').format(_filterDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_filterDateRange!.end)}'
                        : 'Select Date Range',
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setModalState(() {
                        _filterSenderId = null;
                        _filterDateRange = null;
                        _filterHasAttachment = null;
                      });
                      setState(() {
                        _filterSenderId = null;
                        _filterDateRange = null;
                        _filterHasAttachment = null;
                        _loadMessages();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text('Clear Filters', style: TextStyle(color: ct.messageDestructive)),
                  ),
                ),
              ],
            ),
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
    if (!widget.api.enableVoiceNotes) return;
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

class _UnreadSeparatorMarker {}

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../../core/ac_chat.dart';
import 'attachments.dart';
import 'conversation_background.dart';
import 'date_seperator.dart';
import 'input_bar.dart';
import 'message_bubble.dart';
import 'reply_bar.dart';

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
  bool _showEmojiPicker = false;
  bool _showSearch = false;
  String _searchQuery = '';
  late AnimationController _micAnim;

  bool get _isGroup => widget.chat.type == "group";

  List<AcChatMessage> get _messages {
    final all = widget.api.getMessages(widget.chat.conversationId);
    if (_searchQuery.isEmpty) return all;
    return all
        .where((m) => m.text.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _micAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _scrollController.addListener(() {
      final atBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;
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
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.api.theme;
    final isDark = ct.isDark;
    final msgs = _messages;
    final List<MapEntry<DateTime, List<AcChatMessage>>> dayGroups = [];
    for (final msg in msgs) {
      if (dayGroups.isEmpty || !_sameDay(dayGroups.last.key, msg.time)) {
        dayGroups.add(MapEntry(msg.time, [msg]));
      } else {
        dayGroups.last.value.add(msg);
      }
    }

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
                      setState(() {
                        _searchQuery = val;
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
                        setState(() {
                          _showSearch = false;
                          _searchQuery = '';
                          _searchController.clear();
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
            Column(children: [
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
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  itemCount: dayGroups.length,
                  itemBuilder: (_, i) {
                    final group = dayGroups[i];
                    return StickyHeader(
                      header: Container(
                        alignment: Alignment.center,
                        child: DateSeparator(date: group.key, ct: ct),
                      ),
                      content: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: group.value.length,
                        itemBuilder: (context, j) {
                          final msg = group.value[j];
                          return MessageBubble(
                            message: msg,
                            ct: ct,
                            isDark: isDark,
                            isGroup: _isGroup,
                            onReply: (m) => setState(() => _replyTo = m),
                            onCopy: (text) {
                              Clipboard.setData(ClipboardData(text: text));
                              _toast(context, 'Copied');
                            },
                          );
                        },
                      ),
                    );
                  },
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
                onMicStart: () => setState(() => _isRecording = true),
                onMicStop: () => setState(() => _isRecording = false),
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
          _toast(context, '$label — coming soon');
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
}



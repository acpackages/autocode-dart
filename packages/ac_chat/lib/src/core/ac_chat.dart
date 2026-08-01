import 'package:ac_chat/src/components/conversation/conversation.dart';
import 'package:flutter/material.dart';
import '../common/chat_colors.dart';
import '../components/conversation_list_item.dart';
import '../new_chat_screen.dart';
import '../models/ac_chat_user.dart';
import '../models/ac_chat_conversation.dart';
import '../models/ac_chat_conversation_user.dart';
import '../chat_profile_screen.dart';
import 'ac_chat_api.dart';
export '../models/ac_chat_user.dart';
export '../models/ac_chat_conversation.dart';
export '../models/ac_chat_message.dart';
export '../models/ac_chat_conversation_user.dart';
export '../chat_profile_screen.dart';
export 'ac_chat_api.dart';
export '../common/chat_colors.dart';

class AcChatApiProvider extends InheritedWidget {
  final AcChatApi api;

  const AcChatApiProvider({
    super.key,
    required this.api,
    required super.child,
  });

  static AcChatApi of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AcChatApiProvider>();
    assert(provider != null, 'No AcChatApiProvider found in context');
    return provider!.api;
  }

  @override
  bool updateShouldNotify(AcChatApiProvider oldWidget) => api != oldWidget.api;
}

class AcChat extends StatefulWidget {
  final AcChatApi api;
  const AcChat({super.key, required this.api});

  @override
  State<AcChat> createState() => _AcChatState();
}

class _AcChatState extends State<AcChat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AcChatConversation? _selectedChat;
  double _listWidth = 380.0;
  double _profileWidth = 350.0;
  bool _showProfile = false;
  bool _hoveringListDivider = false;
  bool _hoveringProfileDivider = false;

  @override
  void initState() {
    super.initState();
    final showGroupStatus = widget.api.enableGroupsAndStatuses;
    _tabController = TabController(length: showGroupStatus ? 3 : 1, vsync: this);
    final conversations = widget.api.getConversations().where((c) => showGroupStatus || c.type != 'group').toList();
    if (conversations.isNotEmpty) {
      _selectedChat = conversations.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.api.theme;
    final isDark = ct.isDark;
    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= 768;
    final showGroupStatus = widget.api.enableGroupsAndStatuses;

    final leftPane = Scaffold(
      backgroundColor: ct.scaffold,
      appBar: showGroupStatus
          ? AppBar(
              backgroundColor: ct.appBar,
              elevation: 0,
              toolbarHeight: 0,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50), 
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: isDark ? ct.activeTabColor : ct.white,
                    indicatorWeight: 3,
                    dividerColor: ct.divider,
                    labelColor: ct.chatTabLabelColor,
                    unselectedLabelColor: ct.chatTabUnselectedLabelColor,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'CHATS'),
                      Tab(text: 'GROUPS'),
                      Tab(text: 'STATUS'),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: showGroupStatus
          ? TabBarView(
              controller: _tabController,
              children: [
                _ChatTab(
                  chats: widget.api.getConversations(),
                  ct: ct,
                  isDark: isDark,
                  selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                  onChatSelected: (chat) {
                    if (isLarge) {
                      setState(() {
                        _selectedChat = chat;
                      });
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Conversation(
                            chat: chat,
                            isEmbedded: false,
                            api: widget.api,
                          ),
                        ),
                      );
                    }
                  },
                  onRefresh: () => setState(() {}),
                ),
                _ChatTab(
                  chats: widget.api.getConversations()
                      .where((c) => c.type == 'group')
                      .toList(),
                  ct: ct,
                  isDark: isDark,
                  selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                  onChatSelected: (chat) {
                    if (isLarge) {
                      setState(() {
                        _selectedChat = chat;
                      });
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Conversation(
                            chat: chat,
                            isEmbedded: false,
                            api: widget.api,
                          ),
                        ),
                      );
                    }
                  },
                  onRefresh: () => setState(() {}),
                ),
                _StatusTab(ct: ct),
              ],
            )
          : _ChatTab(
              chats: widget.api.getConversations().where((c) => c.type != 'group').toList(),
              ct: ct,
              isDark: isDark,
              selectedChatId: isLarge ? _selectedChat?.conversationId : null,
              onChatSelected: (chat) {
                if (isLarge) {
                  setState(() {
                    _selectedChat = chat;
                  });
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Conversation(
                        chat: chat,
                        isEmbedded: false,
                        api: widget.api,
                      ),
                    ),
                  );
                }
              },
              onRefresh: () => setState(() {}),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ct.activeTabColor,
        child: Icon(Icons.chat_rounded, color: ct.chatFloatingActionButtonColor),
        onPressed: () async {
          final result = await Navigator.of(context)
              .push<AcChatConversation>(MaterialPageRoute(builder: (_) => NewChatScreen(api: widget.api)));
          if (result != null) {
            if (isLarge) {
              setState(() {
                _selectedChat = result;
              });
            } else {
              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Conversation(
                      chat: result,
                      isEmbedded: false,
                      api: widget.api,
                    ),
                  ),
                );
              }
            }
          }
        },
      ),
    );

    if (!isLarge) {
      return AcChatApiProvider(
        api: widget.api,
        child: leftPane,
      );
    }

    final rightPane = Expanded(
      child: _selectedChat == null
          ? Container(
              color: ct.scaffold,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 80,
                      color: ct.subText.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select a chat to view conversation',
                      style: TextStyle(
                        color: ct.subText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Conversation(
              key: ValueKey(_selectedChat!.conversationId),
              chat: _selectedChat!,
              isEmbedded: true,
              api: widget.api,
              onShowProfile: () {
                setState(() {
                  _showProfile = !_showProfile;
                });
              },
            ),
    );

    return AcChatApiProvider(
      api: widget.api,
      child: Stack(
        children: [
        Row(
          children: [
            SizedBox(
              width: _listWidth,
              child: leftPane,
            ),
            rightPane,
            if (_showProfile && _selectedChat != null)
              SizedBox(
                width: _profileWidth,
                child: ChatProfileScreen(
                  chat: _selectedChat!,
                  isEmbedded: true,
                  api: widget.api,
                  onClose: () {
                    setState(() {
                      _showProfile = false;
                    });
                  },
                ),
              ),
          ],
        ),
        Positioned(
          left: _listWidth - 4,
          top: 0,
          bottom: 0,
          width: 8,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                _listWidth = (_listWidth + details.delta.dx).clamp(250.0, 600.0);
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              onEnter: (_) => setState(() => _hoveringListDivider = true),
              onExit: (_) => setState(() => _hoveringListDivider = false),
              child: Container(
                width: 8,
                color: _hoveringListDivider
                    ? (isDark ? ct.white.withValues(alpha: 0.08) : ct.black.withValues(alpha: 0.08))
                    : ct.transparent,
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _hoveringListDivider ? 1.0 : 0.0,
                  child: Container(
                    width: 2,
                    height: 40,
                    color: isDark ? ct.white.withValues(alpha: 0.3) : ct.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showProfile && _selectedChat != null)
          Positioned(
            right: _profileWidth - 4,
            top: 0,
            bottom: 0,
            width: 8,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _profileWidth = (_profileWidth - details.delta.dx).clamp(280.0, 500.0);
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                onEnter: (_) => setState(() => _hoveringProfileDivider = true),
                onExit: (_) => setState(() => _hoveringProfileDivider = false),
                child: Container(
                  width: 8,
                  color: _hoveringProfileDivider
                      ? (isDark ? ct.white.withValues(alpha: 0.08) : ct.black.withValues(alpha: 0.08))
                      : ct.transparent,
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _hoveringProfileDivider ? 1.0 : 0.0,
                    child: Container(
                      width: 2,
                      height: 40,
                      color: isDark ? ct.white.withValues(alpha: 0.3) : ct.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),);
  }
}

// ─────────────────────────────────────────────────────────────
// Chat Tab (Includes Search & Options Bar inside the Tab)
// ─────────────────────────────────────────────────────────────

class _ChatTab extends StatefulWidget {
  final List<AcChatConversation> chats;
  final AcChatTheme ct;
  final bool isDark;
  final VoidCallback onRefresh;
  final Function(AcChatConversation) onChatSelected;
  final dynamic selectedChatId;

  const _ChatTab({
    required this.chats,
    required this.ct,
    required this.isDark,
    required this.onRefresh,
    required this.onChatSelected,
    this.selectedChatId,
  });

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  List<AcChatConversation> get _filteredChats {
    final api = AcChatApiProvider.of(context);
    return widget.chats.where((c) {
      final isGroup = c.type == 'group';
      AcChatUser? otherUser;
      if (!isGroup) {
        final members = api.getConversationUsers(c.conversationId);
        final otherMember = members.firstWhere(
          (m) => m.userId != api.getCurrentUser().userId,
          orElse: () => AcChatConversationUser(),
        );
        if (otherMember.userId.isNotEmpty) {
          otherUser = api.getUserById(otherMember.userId);
        }
      }
      final name = isGroup
          ? (c.groupName ?? '')
          : (otherUser?.name ?? '');
      if (_query.isEmpty) return true;
      return name.toLowerCase().contains(_query.toLowerCase());
    }).toList()
      ..sort((a, b) {
        // Pinned first
        final pinA = a.isPinned ? 0 : 1;
        final pinB = b.isPinned ? 0 : 1;
        if (pinA != pinB) return pinA - pinB;
        return b.lastTime.compareTo(a.lastTime);
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredChats;
    return Column(
      children: [
        // Search & Actions Row inside Tab
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.ct.chatHeaderBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: widget.ct.text, fontSize: 14),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: widget.ct.subText, size: 20),
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(color: widget.ct.subText, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: widget.ct.subText, size: 16),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: widget.isDark ? widget.ct.white70 : widget.ct.black54),
                color: widget.ct.chatBubbleMenuBg,
                onSelected: (v) {
                  if (v == 'new_group') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New Group — coming soon')));
                  } else if (v == 'starred') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starred Messages')));
                  }
                },
                itemBuilder: (_) {
                  final api = AcChatApiProvider.of(context);
                  return [
                    if (api.enableGroupsAndStatuses)
                      PopupMenuItem(
                        value: 'new_group',
                        child: Row(children: [
                          Icon(Icons.group_add, size: 18, color: widget.ct.subText),
                          const SizedBox(width: 10),
                          Text('New Group', style: TextStyle(color: widget.ct.text, fontSize: 14)),
                        ]),
                      ),
                    PopupMenuItem(
                      value: 'starred',
                      child: Row(children: [
                        Icon(Icons.star_outline, size: 18, color: widget.ct.subText),
                        const SizedBox(width: 10),
                        Text('Starred Messages', style: TextStyle(color: widget.ct.text, fontSize: 14)),
                      ]),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
        // Conversation List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 64, color: widget.ct.subText.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      Text(_query.isEmpty ? 'No chats yet' : 'No results found',
                          style: TextStyle(color: widget.ct.subText, fontSize: 15)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final chat = filtered[i];
                    final isSelected = widget.selectedChatId == chat.conversationId;
                    return ConversationListItem(
                      chat: chat,
                      ct: widget.ct,
                      isDark: widget.isDark,
                      isSelected: isSelected,
                      onTap: () async {
                        // Mark as read
                        final api = AcChatApiProvider.of(context);
                        api.markAsRead(chat.conversationId);
                        widget.onChatSelected(chat);
                        widget.onRefresh();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Status Tab (stub)
// ─────────────────────────────────────────────────────────────

class _StatusTab extends StatelessWidget {
  final AcChatTheme ct;
  const _StatusTab({required this.ct});

  @override
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final curUser = api.getCurrentUser();
    final users = api.getUsers();
    return ListView.builder(
      itemCount: 4 + users.length + 1,
      cacheExtent: 200.0,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text('MY STATUS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ct.subText,
                    letterSpacing: 0.8)),
          );
        }
        if (index == 1) {
          return _StatusTile(
              user: curUser,
              subtitle: 'Tap to add status update',
              ct: ct,
              isMe: true);
        }
        if (index == 2) {
          return Divider(height: 1, color: ct.divider);
        }
        if (index == 3) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text('RECENT UPDATES',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ct.subText,
                    letterSpacing: 0.8)),
          );
        }
        final uIdx = index - 4;
        if (uIdx < users.length) {
          return _StatusTile(user: users[uIdx], ct: ct);
        }
        return const SizedBox(height: 80);
      },
    );
  }
}

class _StatusTile extends StatelessWidget {
  final AcChatUser user;
  final String? subtitle;
  final AcChatTheme ct;
  final bool isMe;

  const _StatusTile(
      {required this.user,
      this.subtitle,
      required this.ct,
      this.isMe = false});

  @override
  Widget build(BuildContext context) {
    final color = avatarColor(user.userId);
    return ListTile(
      leading: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? ct.subText : ct.unreadBadgeBg,
              width: isMe ? 1.5 : 2.5,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            backgroundColor: color,
            child: isMe
                ? Icon(Icons.add, color: ct.white, size: 20)
                : Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                        color: ct.white,
                        fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ]),
      title: Text(isMe ? 'My Status' : user.name,
          style: TextStyle(
              color: ct.text, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(
          subtitle ?? '2 hours ago',
          style: TextStyle(color: ct.subText, fontSize: 12)),
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Status — coming soon'))),
    );
  }
}

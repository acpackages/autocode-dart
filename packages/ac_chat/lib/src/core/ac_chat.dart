import 'package:flutter/material.dart';
import 'ac_chat_api.dart';
import '../models/ac_chat_user.dart';
import '../models/ac_chat_conversation.dart';
import '../models/ac_chat_conversation_user.dart';
import '../models/ac_chat_message.dart';
import 'ac_chat_audio_player.dart';
import '../common/chat_colors.dart';
import '../common/theme_provider.dart';
import '../components/conversation/conversation.dart';
import '../components/conversation_list_item.dart';
import '../chat_profile_screen.dart';
import '../new_chat_screen.dart';

export 'ac_chat_api.dart';
export '../common/chat_colors.dart';
export '../models/ac_chat_user.dart';
export '../models/ac_chat_conversation.dart';
export '../models/ac_chat_conversation_user.dart';
export '../models/ac_chat_message.dart';
export '../common/theme_provider.dart';
export '../sync/ac_chat_sync_channel.dart';
export '../media/ac_chat_media_uploader.dart';
export '../crypto/ac_chat_crypto_provider.dart';
export '../connectivity/ac_chat_connectivity_provider.dart';
export 'ac_chat_audio_player.dart';

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

    return StreamBuilder<List<AcChatConversation>>(
      stream: widget.api.watchConversations?.call(),
      initialData: widget.api.getConversations(),
      builder: (context, snapshot) {
        final allConvs = snapshot.data ?? widget.api.getConversations();

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
                        unselectedLabelColor: isDark ? ct.tabUnselected : ct.white.withOpacity(0.7),
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                      chats: allConvs,
                      ct: ct,
                      isDark: isDark,
                      selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                      showSearch: widget.api.searchConversations,
                      pinningEnabled: widget.api.pinConversations,
                      showOnlineStatus: widget.api.showOnlineStatus,
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
                      chats: allConvs.where((c) => c.type == 'group').toList(),
                      ct: ct,
                      isDark: isDark,
                      selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                      showSearch: widget.api.searchConversations,
                      pinningEnabled: widget.api.pinConversations,
                      showOnlineStatus: widget.api.showOnlineStatus,
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
                  chats: allConvs.where((c) => c.type != 'group').toList(),
                  ct: ct,
                  isDark: isDark,
                  selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                  showSearch: widget.api.searchConversations,
                  pinningEnabled: widget.api.pinConversations,
                  showOnlineStatus: widget.api.showOnlineStatus,
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
          floatingActionButton: widget.api.showNewConversationButton
              ? FloatingActionButton(
                  backgroundColor: ct.activeTabColor,
                  child: Icon(Icons.chat_rounded, color: ct.chatFloatingActionButtonColor),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<AcChatConversation>(
                      MaterialPageRoute(builder: (_) => NewChatScreen(api: widget.api)),
                    );
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
                )
              : null,
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
                  api: widget.api,
                  isEmbedded: true,
                ),
        );

        return AcChatApiProvider(
          api: widget.api,
          child: Scaffold(
            backgroundColor: ct.scaffold,
            body: Row(
              children: [
                SizedBox(
                  width: _listWidth,
                  child: leftPane,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  onEnter: (_) => setState(() => _hoveringListDivider = true),
                  onExit: (_) => setState(() => _hoveringListDivider = false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _listWidth = (_listWidth + details.delta.dx).clamp(280.0, 500.0);
                      });
                    },
                    child: Container(
                      width: 6,
                      color: _hoveringListDivider ? ct.activeTabColor : ct.divider,
                    ),
                  ),
                ),
                rightPane,
                if (_showProfile && _selectedChat != null) ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    onEnter: (_) => setState(() => _hoveringProfileDivider = true),
                    onExit: (_) => setState(() => _hoveringProfileDivider = false),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _profileWidth = (_profileWidth - details.delta.dx).clamp(280.0, 500.0);
                        });
                      },
                      child: Container(
                        width: 6,
                        color: _hoveringProfileDivider ? ct.activeTabColor : ct.divider,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: _profileWidth,
                    child: ChatProfileScreen(
                      chat: _selectedChat!,
                      isEmbedded: true,
                      onClose: () => setState(() => _showProfile = false),
                      api: widget.api,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatTab extends StatefulWidget {
  final List<AcChatConversation> chats;
  final AcChatTheme ct;
  final bool isDark;
  final String? selectedChatId;
  final bool showSearch;
  final bool pinningEnabled;
  final bool showOnlineStatus;
  final ValueChanged<AcChatConversation> onChatSelected;
  final VoidCallback onRefresh;

  const _ChatTab({
    required this.chats,
    required this.ct,
    required this.isDark,
    required this.selectedChatId,
    required this.showSearch,
    required this.pinningEnabled,
    required this.showOnlineStatus,
    required this.onChatSelected,
    required this.onRefresh,
  });

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  String _query = '';
  final _searchCtrl = TextEditingController();
  final Map<String, AcChatUser> _userCache = {};
  final Map<String, List<AcChatConversationUser>> _memberCache = {};

  List<AcChatConversation> get _filteredChats {
    final api = AcChatApiProvider.of(context);
    return widget.chats.where((c) {
      final isGroup = c.type == 'group';
      AcChatUser? otherUser;
      if (!isGroup) {
        final members = _memberCache.putIfAbsent(
          c.conversationId,
          () => api.getConversationUsers(conversationId: c.conversationId),
        );
        final otherMember = members.firstWhere(
          (m) => m.userId != api.getCurrentUser().userId,
          orElse: () => AcChatConversationUser(),
        );
        if (otherMember.userId.isNotEmpty) {
          otherUser = _userCache.putIfAbsent(
            otherMember.userId,
            () => api.getUserById(userId: otherMember.userId) ?? AcChatUser(),
          );
        }
      }
      final name = isGroup
          ? (c.groupName ?? '')
          : (otherUser?.name ?? '');
      if (_query.isEmpty) return true;
      return name.toLowerCase().contains(_query.toLowerCase());
    }).toList()
      ..sort((a, b) {
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
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.ct.searchBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _query = val),
                      style: TextStyle(color: widget.ct.text, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search…',
                        hintStyle: TextStyle(color: widget.ct.subText, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: widget.ct.subText, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: widget.ct.subText, size: 16),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: widget.isDark ? widget.ct.white70 : widget.ct.black54),
                  color: widget.ct.chatBubbleMenuBg,
                  onSelected: (v) {
                    final api = AcChatApiProvider.of(context);
                    if (v == 'new_group') {
                      if (api.onNewGroup != null) {
                        api.onNewGroup!(context: context);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => NewChatScreen(api: api)),
                        );
                      }
                    } else if (v == 'starred') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starred Messages')),
                      );
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
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 64, color: widget.ct.subText.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      Text(
                        _query.isEmpty ? 'No conversations yet' : 'No results found',
                        style: TextStyle(color: widget.ct.subText, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 76,
                    color: widget.ct.divider,
                  ),
                  itemBuilder: (context, index) {
                    final chat = filtered[index];
                    final isSelected = widget.selectedChatId == chat.conversationId;
                    AcChatUser? otherUser;
                    if (chat.type != 'group') {
                      final members = _memberCache[chat.conversationId];
                      if (members != null && members.isNotEmpty) {
                        final api = AcChatApiProvider.of(context);
                        final otherMember = members.firstWhere(
                          (m) => m.userId != api.getCurrentUser().userId,
                          orElse: () => AcChatConversationUser(),
                        );
                        if (otherMember.userId.isNotEmpty) {
                          otherUser = _userCache[otherMember.userId];
                        }
                      }
                    }
                    return ConversationListItem(
                      chat: chat,
                      ct: widget.ct,
                      isDark: widget.isDark,
                      isSelected: isSelected,
                      otherUser: otherUser,
                      showOnlineStatus: widget.showOnlineStatus,
                      pinningEnabled: widget.pinningEnabled,
                      onTap: () async {
                        final api = AcChatApiProvider.of(context);
                        api.markAsRead(conversationId: chat.conversationId);
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

class _StatusTab extends StatelessWidget {
  final AcChatTheme ct;
  const _StatusTab({required this.ct});

  @override
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final curUser = api.getCurrentUser();
    return ListView(
      children: [
        ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ct.activeTabColor,
                child: Text(
                  curUser.name.isNotEmpty ? curUser.name[0].toUpperCase() : '?',
                  style: TextStyle(color: ct.white, fontSize: 18),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: ct.activeTabColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: ct.scaffold, width: 2),
                  ),
                  child: Icon(Icons.add, size: 14, color: ct.white),
                ),
              )
            ],
          ),
          title: Text(
            'My status',
            style: TextStyle(color: ct.text, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Tap to add status update',
            style: TextStyle(color: ct.subText, fontSize: 13),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Status update — coming soon')),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'RECENT UPDATES',
            style: TextStyle(
              color: ct.subText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'No recent status updates',
              style: TextStyle(color: ct.subText, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

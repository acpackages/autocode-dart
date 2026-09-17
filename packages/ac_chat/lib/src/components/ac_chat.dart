import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ac_chat_core/ac_chat_core.dart';
import '../common/chat_colors.dart';
import '../common/theme_provider.dart';
import 'conversation/conversation.dart';
import 'conversation_list_item.dart';
import 'new_conversation_screen.dart';
import 'conversation_profile_screen.dart';
export '../common/chat_colors.dart';
export '../common/theme_provider.dart';
export '../core/ac_chat_audio_player.dart';

class AcChat extends StatefulWidget {
  final AcChatApi api;

  /// The visual theme for the chat UI.
  final AcChatTheme theme;

  /// Optional custom widget builder for individual messages.
  final Widget? Function({
    required BuildContext context,
    required AcChatMessage message,
  })? customMessageBuilder;

  /// Optional custom widget builder for the message input bar.
  final Widget? Function({
    required BuildContext context,
    required AcChatConversation conversation,
  })? customInputBuilder;

  /// Called when the user taps the 'New Contact' button.
  final FutureOr<AcChatUser?> Function({required BuildContext context})? onNewContact;

  /// Called when the user taps the 'New Group' button.
  final FutureOr<void> Function({required BuildContext context})? onNewGroup;

  const AcChat({
    super.key,
    required this.api,
    this.theme = const AcChatTheme(),
    this.customMessageBuilder,
    this.customInputBuilder,
    this.onNewContact,
    this.onNewGroup,
  });

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
    // Propagate theme to api so sub-components that read api.theme work correctly.
    widget.api.theme = widget.theme;
    final showGroupStatus = widget.api.enableGroups && widget.api.enableStatuses;
    _tabController = TabController(length: showGroupStatus ? 2 : 1, vsync: this);
    widget.api.getConversations().then((r){
      final conversations = r.where((c) => widget.api.enableGroups || c.type != 'group').toList();
        if (conversations.isNotEmpty) {
      _selectedChat = conversations.first;
    }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.theme;
    final isDark = ct.isDark;
    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= 768;
    final showGroupStatus = widget.api.enableGroups && widget.api.enableStatuses;

    return AcChatApiProvider(
      api: widget.api,
      chat: widget,
      child: FutureBuilder<Stream<List<AcChatConversation>>?>(
        future: widget.api.watchConversations(),
        builder: (context, streamSnap) {
          return FutureBuilder<List<AcChatConversation>>(
            future: widget.api.getConversations(),
            builder: (context, initialSnap) {
              return StreamBuilder<List<AcChatConversation>>(
                stream: streamSnap.data,
                initialData: initialSnap.data,
                builder: (context, snapshot) {
                  final allConvs = snapshot.data ?? initialSnap.data ?? [];
                  final conversations = allConvs.where((c) => widget.api.enableGroups || c.type != 'group').toList();

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
                                  unselectedLabelColor: isDark ? ct.tabUnselected : ct.white.withValues(alpha: 0.7),
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(text: 'CHATS'),
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
                      chat: widget,
                      chats: conversations,
                      ct: ct,
                      isDark: isDark,
                      selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                      showSearch: widget.api.enableConversationSearch,
                      pinningEnabled: widget.api.enableConversationPinning,
                      showOnlineStatus: widget.api.enableOnlinePresence,
                      onChatSelected: (chat) {
                        if (isLarge) {
                          setState(() {
                            _selectedChat = chat;
                          });
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Conversation(
                                chat: widget,
                                isEmbedded: false,
                                conversation: chat,
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
                  chat: widget,
                  chats: conversations,
                  ct: ct,
                  isDark: isDark,
                  selectedChatId: isLarge ? _selectedChat?.conversationId : null,
                  showSearch: widget.api.enableConversationSearch,
                  pinningEnabled: widget.api.enableConversationPinning,
                  showOnlineStatus: widget.api.enableOnlinePresence,
                  onChatSelected: (chat) {
                    if (isLarge) {
                      setState(() {
                        _selectedChat = chat;
                      });
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Conversation(
                            chat: widget,
                            isEmbedded: false,
                            conversation: chat,
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
                      MaterialPageRoute(builder: (_) => NewConversationScreen(chat: widget)),
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
                                conversation: _selectedChat!,
                                chat: widget,
                                isEmbedded: false,
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
          return leftPane;
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
                          color: ct.subText.withValues(alpha: 0.2),
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
                  conversation: _selectedChat!,
                  chat: widget,
                  isEmbedded: true,
                  onViewProfile: () => setState(() => _showProfile = !_showProfile),
                ),
        );

                  return Scaffold(
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
                            child: ConversationProfileScreen(
                              conversation: _selectedChat!,
                              isEmbedded: true,
                              chat: widget,
                              onClose: () => setState(() => _showProfile = false),
                              api: widget.api,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatTab extends StatefulWidget {
  final List<AcChatConversation> chats;
  final AcChatTheme ct;
  final AcChat chat;
  final bool isDark;
  final String? selectedChatId;
  final bool showSearch;
  final bool pinningEnabled;
  final bool showOnlineStatus;
  final ValueChanged<AcChatConversation> onChatSelected;
  final VoidCallback onRefresh;

  const _ChatTab({
    required this.chat,
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
  final Map<String, AcChatUser> userCache = {};
  final Map<String, List<AcChatConversationUser>> conversationUserCache = {};

  Future<List<AcChatConversation>> _filteredChats() async {
    AcChatApi api = AcChatApiProvider.getApi(context);
    List<AcChatConversation> filteredChats = List.empty(growable: true);
    for(var c in widget.chats){
      if (!api.enableGroups && c.type == 'group'){}
      else{
        final isGroup = c.type == 'group';
        AcChatUser? otherUser;
        final name = isGroup ? (c.conversationName != null && c.conversationName!.trim().isNotEmpty? c.conversationName!
            : 'Group')
            : (c.otherUser != null && c.otherUser!.user != null && c.otherUser!.user!.name.trim().isNotEmpty
                ? c.otherUser!.user!.name.trim() :'Unknown'
                );
        if (_query.isEmpty || name.toLowerCase().contains(_query.toLowerCase())){
          filteredChats.add(c);
        };
      }
    }
    filteredChats.sort((a, b) {
        final pinA = a.isPinned ? 0 : 1;
        final pinB = b.isPinned ? 0 : 1;
        if (pinA != pinB) return pinA - pinB;
        return b.lastTime.compareTo(a.lastTime);
      });
    return filteredChats;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AcChatApi api = AcChatApiProvider.getApi(context);
    return FutureBuilder<List<AcChatConversation>>(
      future: _filteredChats(),
      builder: (context, snapshot) {
        final filtered = snapshot.data ?? widget.chats;
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
                if(api.enableMessageStarring || api.enableGroups)
                  const SizedBox(width: 8),
                if(api.enableMessageStarring || api.enableGroups)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: widget.isDark ? widget.ct.white70 : widget.ct
                            .black54),
                    color: widget.ct.chatBubbleMenuBg,
                    onSelected: (v) {
                      AcChatApi api = AcChatApiProvider.getApi(context);
                      if (v == 'new_group') {
                        if (widget.chat.onNewGroup != null) {
                          widget.chat.onNewGroup!(context: context);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) =>
                                NewConversationScreen(chat: widget.chat)),
                          );
                        }
                      } else if (v == 'starred') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Starred Messages')),
                        );
                      }
                    },
                    itemBuilder: (_) {

                      return [
                        if (api.enableGroups)
                          PopupMenuItem(
                            value: 'new_group',
                            child: Row(children: [
                              Icon(Icons.group_add, size: 18,
                                  color: widget.ct.subText),
                              const SizedBox(width: 10),
                              Text('New Group', style: TextStyle(
                                  color: widget.ct.text, fontSize: 14)),
                            ]),
                          ),
                        if (api.enableMessageStarring)
                          PopupMenuItem(
                            value: 'starred',
                            child: Row(children: [
                              Icon(Icons.star_outline, size: 18,
                                  color: widget.ct.subText),
                              const SizedBox(width: 10),
                              Text('Starred Messages', style: TextStyle(
                                  color: widget.ct.text, fontSize: 14)),
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
                          size: 64, color: widget.ct.subText.withValues(alpha: 0.4)),
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
                    return ConversationListItem(
                      conversation: chat,
                      ct: widget.ct,
                      isDark: widget.isDark,
                      isSelected: isSelected,
                      showOnlineStatus: widget.showOnlineStatus,
                      pinningEnabled: widget.pinningEnabled,
                      onTap: () async {
                        api.notifyConversationRead(conversationId: chat.conversationId);
                        widget.onChatSelected(chat);
                        widget.onRefresh();
                      },
                    );
                  },
                ),
        ),
      ],
    );
      },
    );
  }
}

class _StatusTab extends StatelessWidget {
  final AcChatTheme ct;
  const _StatusTab({required this.ct});

  @override
  Widget build(BuildContext context) {
    final AcChatApi api = AcChatApiProvider.getApi(context);
    return FutureBuilder<AcChatUser?>(
      future: api.getCurrentUser(),
      builder: (context, snapshot) {
        final curUser = snapshot.data ?? AcChatUser();
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
      },
    );
  }
}

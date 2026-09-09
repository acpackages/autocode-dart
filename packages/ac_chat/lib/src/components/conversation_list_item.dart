import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/ac_chat.dart';

class ConversationListItem extends StatefulWidget {
  final AcChatConversation chat;
  final AcChatTheme ct;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;
  final AcChatUser? otherUser;
  final bool showOnlineStatus;
  final bool pinningEnabled;

  const ConversationListItem({
    super.key,
    required this.chat,
    required this.ct,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
    this.otherUser,
    this.showOnlineStatus = true,
    this.pinningEnabled = true,
  });

  @override
  State<ConversationListItem> createState() => _ConversationListItemState();
}

class _ConversationListItemState extends State<ConversationListItem> {
  AcChatUser? _user;
  AcChatUser? _currentUser;
  AcChatMessage? _lastMessageObj;

  AcChatConversation get chat => widget.chat;
  AcChatTheme get ct => widget.ct;
  bool get isDark => widget.isDark;
  bool get isSelected => widget.isSelected;
  VoidCallback get onTap => widget.onTap;
  AcChatUser? get otherUser => widget.otherUser;
  bool get showOnlineStatus => widget.showOnlineStatus;
  bool get pinningEnabled => widget.pinningEnabled;

  @override
  void initState() {
    super.initState();
    _user = widget.otherUser;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadItemData();
    });
  }

  @override
  void didUpdateWidget(covariant ConversationListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.otherUser != null && widget.otherUser != oldWidget.otherUser) {
      _user = widget.otherUser;
    }
    if (widget.chat.conversationId != oldWidget.chat.conversationId ||
        widget.chat.otherUserId != oldWidget.chat.otherUserId) {
      _loadItemData();
    }
  }

  Future<void> _loadItemData() async {
    final api = AcChatApiProvider.of(context);
    final currentUser = await api.getCurrentUser();
    AcChatUser? user = _user ?? widget.otherUser;
    final isGroup = chat.type == 'group';
    if ((user == null || user.name.trim().isEmpty) && !isGroup) {
      try {
        final members = await api.getConversationUsers(conversationId: chat.conversationId);
        final otherMember = members.firstWhere(
          (m) => m.userId.isNotEmpty && m.userId != currentUser.userId,
          orElse: () => AcChatConversationUser(),
        );
        if (otherMember.userId.isNotEmpty) {
          final u = await api.getUserById(userId: otherMember.userId);
          if (u != null && u.name.trim().isNotEmpty) user = u;
        }
      } catch (_) {}

      if (user == null || user.name.trim().isEmpty) {
        final otherId = chat.memberIds.firstWhere(
          (id) => id.isNotEmpty && id != currentUser.userId,
          orElse: () => '',
        );
        if (otherId.isNotEmpty) {
          try {
            final u = await api.getUserById(userId: otherId);
            if (u != null && u.name.trim().isNotEmpty) user = u;
          } catch (_) {}
        }
      }

      if (user == null || user.name.trim().isEmpty) {
        final directUserId = chat.otherUserId;
        if (directUserId != null && directUserId.isNotEmpty && directUserId != currentUser.userId) {
          try {
            final u = await api.getUserById(userId: directUserId);
            if (u != null && u.name.trim().isNotEmpty) user = u;
          } catch (_) {}
        }
      }
    }

    AcChatMessage? lastMessageObj;
    try {
      final msgs = await api.getMessages(conversationId: chat.conversationId);
      if (msgs.isNotEmpty) {
        lastMessageObj = msgs.last;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _currentUser = currentUser;
        if (user != null && user.name.trim().isNotEmpty) {
          _user = user;
        }
        _lastMessageObj = lastMessageObj;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final user = _user ?? otherUser;
    final currentUser = _currentUser;
    final lastMessageObj = _lastMessageObj;
    final isGroup = chat.type == 'group';
    final name = isGroup
        ? (chat.groupName != null && chat.groupName!.trim().isNotEmpty
            ? chat.groupName!
            : (chat.conversationName != null && chat.conversationName!.trim().isNotEmpty
                ? chat.conversationName!
                : 'Group'))
        : (user != null && user.name.trim().isNotEmpty
            ? user.name
            : (chat.conversationName != null && chat.conversationName!.trim().isNotEmpty
                ? chat.conversationName!
                : 'Unknown'));
    final initials = _initials(name: name);
    final dynamic userId = isGroup ? '${chat.conversationId}-group' : (user?.userId ?? chat.otherUserId ?? '');
    final color = avatarColor(userId);
    final lastTime = chat.lastTime;
    final unread = chat.unread;
    final isPinned = pinningEnabled && chat.isPinned;
    final isMuted = chat.isMuted;
    final lastMsg = chat.lastMessage;
    final isToday = _isToday(dt: lastTime);

    final isSentByMe = lastMessageObj != null && currentUser != null && lastMessageObj.senderId == currentUser.userId;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context: context, api: api),
      child: Container(
        color: isSelected
            ? ct.activeConversationBackgroundColor
            : (isPinned
                ? ct.pinnedConversationBackgroundColor
                : ct.scaffold),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar
              Stack(clipBehavior: Clip.none, children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: color,
                  child: isGroup
                      ? Icon(Icons.group, color: ct.white, size: 24)
                      : Text(
                          initials,
                          style: TextStyle(
                            color: ct.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                // Online status indicator
                if (!isGroup && showOnlineStatus && user != null)
                  FutureBuilder<Stream<bool>?>(
                    future: api.watchUserOnlineStatus(userId: user.userId),
                    builder: (context, streamSnap) {
                      final stream = streamSnap.data;
                      if (stream == null) return const SizedBox.shrink();
                      return StreamBuilder<bool>(
                        stream: stream,
                        builder: (context, snapshot) {
                          final isOnline = snapshot.data ?? false;
                          if (!isOnline) return const SizedBox.shrink();
                          return Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: ct.activeTabColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: ct.scaffold, width: 2),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ]),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ct.text,
                              fontSize: 16,
                              fontWeight: isPinned ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          isToday
                              ? DateFormat('hh:mm a').format(lastTime.toLocal())
                              : DateFormat('dd/MM/yy').format(lastTime.toLocal()),
                          style: TextStyle(
                            color: unread > 0 ? ct.activeTabColor : ct.subText,
                            fontSize: 12,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isSentByMe) ...[
                                _buildTickIcon(status: lastMessageObj.status),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  lastMsg,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: unread > 0 ? ct.text : ct.subText,
                                    fontSize: 14,
                                    fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isMuted) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.volume_off_rounded, size: 16, color: ct.subText),
                        ],
                        if (isPinned) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.push_pin_rounded, size: 16, color: ct.subText),
                        ],
                        if (unread > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: ct.activeTabColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : unread.toString(),
                              style: TextStyle(
                                color: ct.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
  }

  Widget _buildTickIcon({required String status}) {
    switch (status) {
      case 'sending':
        return Icon(Icons.access_time_rounded, size: 14, color: ct.subText);
      case 'delivered':
        return Icon(Icons.done_all_rounded, size: 15, color: ct.subText);
      case 'read':
        return Icon(Icons.done_all_rounded, size: 15, color: ct.readTick);
      case 'failed':
        return Icon(Icons.error_outline_rounded, size: 14, color: ct.messageDestructive);
      case 'sent':
      default:
        return Icon(Icons.check_rounded, size: 14, color: ct.subText);
    }
  }

  void _showContextMenu({required BuildContext context, required AcChatApi api}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomCtx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: ct.subText.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        _ContextOption(
          icon: chat.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
          label: chat.isArchived ? 'Unarchive Chat' : 'Archive Chat',
          ct: ct,
          onTap: () async {
            Navigator.pop(bottomCtx);
            await api.archiveConversation(conversationId: chat.conversationId, isArchived: !chat.isArchived);
          },
        ),
        _ContextOption(
          icon: chat.isMuted ? Icons.volume_up_outlined : Icons.volume_off_outlined,
          label: chat.isMuted ? 'Unmute' : 'Mute',
          ct: ct,
          onTap: () async {
            Navigator.pop(bottomCtx);
            await api.muteConversation(conversationId: chat.conversationId, muted: !chat.isMuted);
          },
        ),
        if (pinningEnabled)
          _ContextOption(
            icon: chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: chat.isPinned ? 'Unpin Chat' : 'Pin Chat',
            ct: ct,
            onTap: () async {
              Navigator.pop(bottomCtx);
              await api.pinConversation(conversationId: chat.conversationId, isPinned: !chat.isPinned);
            },
          ),
        _ContextOption(
          icon: Icons.delete_outline,
          label: 'Delete Chat',
          ct: ct,
          isDestructive: true,
          onTap: () async {
            Navigator.pop(bottomCtx);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dCtx) => AlertDialog(
                title: const Text('Delete Chat'),
                content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dCtx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dCtx, true),
                    child: Text('Delete', style: TextStyle(color: ct.messageDestructive)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await api.deleteConversation(conversationId: chat.conversationId);
            }
          },
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  String _initials({required String name}) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool _isToday({required DateTime dt}) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }
}

class _ContextOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final AcChatTheme ct;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _ContextOption({
    required this.icon,
    required this.label,
    required this.ct,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? ct.messageDestructive : ct.text;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      onTap: onTap ?? () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label — coming soon')));
      },
    );
  }
}
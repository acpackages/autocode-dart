import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/ac_chat.dart';
import '../common/chat_colors.dart';

class ConversationListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final isGroup = chat.type == 'group';
    AcChatUser? user = otherUser;
    if (user == null && !isGroup) {
      final members = api.getConversationUsers(conversationId: chat.conversationId);
      final otherMember = members.firstWhere(
        (m) => m.userId != api.getCurrentUser().userId,
        orElse: () => AcChatConversationUser(),
      );
      if (otherMember.userId.isNotEmpty) {
        user = api.getUserById(userId: otherMember.userId);
      }
    }
    final name = isGroup
        ? (chat.groupName ?? 'Group')
        : (user?.name ?? 'Unknown');
    final initials = _initials(name: name);
    final dynamic userId = isGroup ? '${chat.conversationId}-group' : (user?.userId ?? '');
    final color = avatarColor(userId);
    final lastTime = chat.lastTime;
    final unread = chat.unread;
    final isPinned = pinningEnabled && chat.isPinned;
    final isMuted = chat.isMuted;
    final lastMsg = chat.lastMessage;
    final isToday = _isToday(dt: lastTime);

    // Retrieve last message for delivery tick status
    AcChatMessage? lastMessageObj;
    try {
      final msgs = api.getMessages(conversationId: chat.conversationId);
      if (msgs.isNotEmpty) {
        lastMessageObj = msgs.last;
      }
    } catch (_) {}

    final isSentByMe = lastMessageObj != null && lastMessageObj.senderId == api.getCurrentUser().userId;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context: context),
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
            if (!isGroup && showOnlineStatus && user != null && api.watchUserOnlineStatus != null)
              StreamBuilder<bool>(
                stream: api.watchUserOnlineStatus!(userId: user.userId),
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
              ),
          ]),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (isPinned) ...[
                    Icon(Icons.push_pin_rounded, size: 12, color: ct.subText),
                    const SizedBox(width: 3),
                  ],
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ct.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    isToday
                        ? DateFormat('hh:mm a').format(lastTime)
                        : _formatDate(dt: lastTime),
                    style: TextStyle(
                      fontSize: 11,
                      color: unread > 0 ? ct.activeTabColor : ct.subText,
                    ),
                  ),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  // Tick for last message from me
                  if (isSentByMe && lastMessageObj != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildTickIcon(status: lastMessageObj.status),
                    ),
                  Expanded(
                    child: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: unread > 0 && !isSelected
                            ? ct.text
                            : ct.subText,
                        fontWeight: unread > 0 && !isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isMuted) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.volume_off_rounded, size: 16, color: ct.subText),
                  ],
                  if (unread > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ct.unreadBadgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: TextStyle(
                          color: ct.unreadBadgeText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ]),
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

  void _showContextMenu({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: ct.subText.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        _ContextOption(icon: Icons.archive_outlined, label: 'Archive', ct: ct),
        _ContextOption(icon: Icons.volume_off_outlined, label: 'Mute', ct: ct),
        _ContextOption(icon: Icons.push_pin_outlined, label: 'Pin Chat', ct: ct),
        _ContextOption(
          icon: Icons.delete_outline,
          label: 'Delete Chat',
          ct: ct,
          isDestructive: true,
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

  String _formatDate({required DateTime dt}) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff < 7) return DateFormat('EEE').format(dt);
    return DateFormat('dd/MM/yy').format(dt);
  }
}

class _ContextOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final AcChatTheme ct;
  final bool isDestructive;

  const _ContextOption({
    required this.icon,
    required this.label,
    required this.ct,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? ct.messageDestructive : ct.text;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label — coming soon')));
      },
    );
  }
}
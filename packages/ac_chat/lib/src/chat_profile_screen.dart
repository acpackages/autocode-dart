import 'package:flutter/material.dart';
import 'core/ac_chat.dart';
import 'common/chat_colors.dart';
import 'common/theme_provider.dart';
import 'components/conversation/conversation_media_tabs.dart';

class ChatProfileScreen extends StatefulWidget {
  final AcChatConversation chat;
  final VoidCallback? onClose;
  final bool isEmbedded;
  final AcChatApi api;

  const ChatProfileScreen({
    super.key,
    required this.chat,
    this.onClose,
    this.isEmbedded = false,
    required this.api,
  });

  @override
  State<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final chat = widget.chat;
    final ct = api.theme;
    final isDark = ct.isDark;

    // Determine type and user info
    final isGroup = chat.type == 'group';
    AcChatUser? user;
    if (!isGroup) {
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

    final membersList = api.getConversationUsers(conversationId: chat.conversationId);
    final subtitleText = isGroup
        ? 'Group • ${membersList.length} members'
        : 'Direct Message • ${user?.email ?? "No email"}';

    final dynamic avatarId = isGroup ? '${chat.conversationId}-group' : (user?.userId ?? '');
    final themeColor = avatarColor(avatarId);

    // Fetch participant's conversations (excluding this one)
    final participantChats = <AcChatConversation>[];
    if (user != null) {
      final targetUserId = user.userId;
      final otherChats = api.getConversations()
          .where((c) => c.conversationId != chat.conversationId)
          .toList();

      for (var c in otherChats) {
        final members = api.getConversationUsers(conversationId: c.conversationId);
        if (members.any((m) => m.userId == targetUserId)) {
          participantChats.add(c);
        }
      }
    }

    final mediaMsgs = api.getMessages(conversationId: chat.conversationId)
        .where((m) => m.type == 'image' || m.type == 'video' || m.type == 'audio')
        .toList();

    return AcChatApiProvider(
      api: api,
      child: Scaffold(
        backgroundColor: ct.scaffold,
        body: CustomScrollView(
          slivers: [
            // 1. Header Hero Area with Gradient Backplate
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: ct.appBar,
              leading: IconButton(
                icon: Icon(widget.isEmbedded ? Icons.close : Icons.arrow_back, color: ct.white),
                onPressed: () {
                  if (widget.isEmbedded && widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeColor, themeColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: 'avatar-${chat.conversationId}',
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: ct.white.withOpacity(0.2),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: ct.surface,
                            child: isGroup
                                ? Icon(Icons.group, size: 50, color: themeColor)
                                : Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: themeColor),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          color: ct.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText,
                        style: TextStyle(
                          color: ct.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Body Details & Media Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Card(
                  elevation: 0,
                  color: isDark ? ct.chatDarkAppBar : ct.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: ct.divider, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Media, Links, Docs Section Header
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConversationMediaTabs(
                                chat: chat,
                                ct: ct,
                              ),
                            ),
                          );
                        },
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Media, Links and Docs',
                                style: TextStyle(
                                  color: ct.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${mediaMsgs.length}',
                                    style: TextStyle(color: ct.subText, fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 14, color: ct.subText),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      // Media Horizontal Preview
                      if (mediaMsgs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Text(
                            'No shared media',
                            style: TextStyle(color: ct.subText, fontSize: 14),
                          ),
                        )
                      else
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: mediaMsgs.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final msg = mediaMsgs[index];
                              if (msg.type == 'image') {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.image, color: themeColor, size: 28),
                                );
                              } else {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: ct.profileStatusOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.mic, color: ct.profileStatusOrange, size: 26),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Voice msg',
                                        style: TextStyle(fontSize: 10, color: ct.profileStatusOrange),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Group Members or Shared Chats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Card(
                  elevation: 0,
                  color: isDark ? ct.chatDarkAppBar : ct.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: ct.divider, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isGroup ? 'Group Members' : 'Shared Conversations',
                              style: TextStyle(
                                color: ct.text,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isGroup && api.addGroupMembers != null)
                              IconButton(
                                icon: Icon(Icons.person_add_alt_1_rounded, color: ct.activeTabColor, size: 22),
                                onPressed: () async {
                                  final allUsers = api.getUsers();
                                  final currentMemberIds = membersList.map((m) => m.userId).toSet();
                                  final candidates = allUsers.where((u) => !currentMemberIds.contains(u.userId)).toList();

                                  if (candidates.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('All available users are already in this group')),
                                    );
                                    return;
                                  }

                                  final selectedUser = await showDialog<AcChatUser>(
                                    context: context,
                                    builder: (dialogCtx) => SimpleDialog(
                                      title: const Text('Add Member'),
                                      children: candidates.map((u) => SimpleDialogOption(
                                        onPressed: () => Navigator.pop(dialogCtx, u),
                                        child: Text(u.name),
                                      )).toList(),
                                    ),
                                  );

                                  if (selectedUser != null) {
                                    await api.addGroupMembers!(
                                      conversationId: chat.conversationId,
                                      userIds: [selectedUser.userId],
                                    );
                                    if (mounted) setState(() {});
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                      Divider(color: ct.divider, height: 1),
                      if (isGroup) ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: membersList.length,
                          itemBuilder: (context, index) {
                            final memberRel = membersList[index];
                            final u = api.getUserById(userId: memberRel.userId);
                            if (u == null) return const SizedBox.shrink();
                            final isMe = u.userId == api.getCurrentUser().userId;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: avatarColor(u.userId),
                                child: Text(
                                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                  style: TextStyle(color: ct.white),
                                ),
                              ),
                              title: Text(
                                isMe ? '${u.name} (You)' : u.name,
                                style: TextStyle(color: ct.text),
                              ),
                              subtitle: Text(u.email, style: TextStyle(color: ct.subText, fontSize: 12)),
                              trailing: (!isMe && api.removeGroupMember != null)
                                  ? IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: ct.messageDestructive, size: 20),
                                      onPressed: () async {
                                        await api.removeGroupMember!(
                                          conversationId: chat.conversationId,
                                          userId: u.userId,
                                        );
                                        if (mounted) setState(() {});
                                      },
                                    )
                                  : null,
                            );
                          },
                        )
                      ] else ...[
                        if (participantChats.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            child: Center(
                              child: Text(
                                'No other shared conversations',
                                style: TextStyle(color: ct.subText, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: participantChats.length,
                            itemBuilder: (context, index) {
                              final pChat = participantChats[index];
                              final isGroupChat = pChat.type == 'group';
                              final pName = isGroupChat
                                  ? (pChat.groupName ?? 'Group')
                                  : (api.getUserById(userId: user?.userId ?? '')?.name ?? 'Unknown');
                              final pColor = avatarColor(isGroupChat ? '${pChat.conversationId}-group' : user?.userId);

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: pColor,
                                  child: isGroupChat
                                      ? Icon(Icons.group, color: ct.white, size: 18)
                                      : Text(
                                          pName.isNotEmpty ? pName[0].toUpperCase() : '?',
                                          style: TextStyle(color: ct.white),
                                        ),
                                ),
                                title: Text(pName, style: TextStyle(color: ct.text)),
                                subtitle: Text(
                                  pChat.lastMessage.isNotEmpty ? pChat.lastMessage : 'No messages',
                                  style: TextStyle(color: ct.subText, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

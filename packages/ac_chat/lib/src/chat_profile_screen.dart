import 'package:flutter/material.dart';
import 'core/ac_chat.dart';
import 'common/chat_colors.dart';
import 'common/theme_provider.dart';
import 'components/conversation/conversation_media_tabs.dart';

class ChatProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ct = api.theme;
    final isDark = ct.isDark;

    // Determine type and user info
    final isGroup = chat.type == 'group';
    AcChatUser? user;
    if (!isGroup) {
      final members = api.getConversationUsers(chat.conversationId);
      final otherMember = members.firstWhere(
        (m) => m.userId != api.getCurrentUser().userId,
        orElse: () => AcChatConversationUser(),
      );
      if (otherMember.userId.isNotEmpty) {
        user = api.getUserById(otherMember.userId);
      }
    }

    final name = isGroup
        ? (chat.groupName ?? 'Group')
        : (user?.name ?? 'Unknown');
    
    final subtitleText = isGroup 
        ? 'Group • ${api.getConversationUsers(chat.conversationId).length} members'
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
        final members = api.getConversationUsers(c.conversationId);
        if (members.any((m) => m.userId == targetUserId)) {
          participantChats.add(c);
        }
      }
    }

    final mediaMsgs = api.getMessages(chat.conversationId)
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
                icon: Icon(isEmbedded ? Icons.close : Icons.arrow_back, color: ct.white),
                onPressed: () {
                  if (isEmbedded && onClose != null) {
                    onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: ct.white),
                  onPressed: () {},
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeColor.withOpacity(0.85),
                        ct.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Large Avatar
                        Hero(
                          tag: 'avatar_${chat.conversationId}',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ct.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: themeColor,
                              child: isGroup
                                  ? Icon(Icons.group, color: ct.white, size: 50)
                                  : Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: ct.white,
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Conversation Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ct.text,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtitle Info
                        Text(
                          subtitleText,
                          style: TextStyle(
                            color: ct.subText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
  
            // 2. Tabbed Reusable Shared Media, Links & Docs Section
            SliverToBoxAdapter(
              child: Container(
                color: ct.surface,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Media, Attachments & Links',
                            style: TextStyle(
                              color: ct.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: ct.surface,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Container(
                                      width: 500,
                                      height: 600,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Media, Attachments & Links',
                                                style: TextStyle(
                                                  color: ct.text,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close, color: ct.text),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Expanded(
                                            child: ConversationMediaTabs(chat: chat, ct: ct),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text('See all', style: TextStyle(color: ct.activeTabColor)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (mediaMsgs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                  color: themeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/logo/launcher_icon.png'),
                                    fit: BoxFit.cover,
                                    opacity: 0.1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.image, color: themeColor, size: 28),
                              );
                            } else if (msg.type == 'audio') {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: ct.profileStatusOrange.withValues(alpha: 0.1),
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
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: ct.profileStatusBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.video_collection, color: ct.profileStatusBlue),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
  
            // 3. Participant's Shared Conversations / Group Members Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 32),
                color: ct.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        isGroup ? 'Group Members' : 'Shared Conversations',
                        style: TextStyle(
                          color: ct.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(color: ct.divider, height: 1),
                    if (isGroup) ...[
                      // List group members
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: api.getConversationUsers(chat.conversationId).length,
                        itemBuilder: (context, index) {
                          final memberRel = api.getConversationUsers(chat.conversationId)[index];
                          final u = api.getUserById(memberRel.userId);
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
                          );
                        },
                      )
                    ] else ...[
                      // List shared conversations for a DM participant
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
                                : (api.getUserById(user?.userId ?? '')?.name ?? 'Unknown');
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
                                isGroupChat ? 'Group Chat' : 'Direct Message',
                                style: TextStyle(color: ct.subText, fontSize: 12),
                              ),
                            );
                          },
                        )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

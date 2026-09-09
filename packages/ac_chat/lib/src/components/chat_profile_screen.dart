import 'package:flutter/material.dart';
import '../core/ac_chat.dart';
import 'conversation/conversation_media_tabs.dart';

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
  bool _isLoading = true;
  AcChatUser? _currentUser;
  AcChatUser? _user;
  List<AcChatConversationUser> _membersList = [];
  bool _isBlocked = false;
  List<AcChatMessage> _mediaMsgs = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final api = widget.api;
    final chat = widget.chat;
    final isGroup = chat.type == 'group';
    AcChatUser? user;
    final currentUser = await api.getCurrentUser();
    if (!isGroup) {
      final members = await api.getConversationUsers(conversationId: chat.conversationId);
      final otherMember = members.firstWhere(
        (m) => m.userId.isNotEmpty && m.userId != currentUser.userId,
        orElse: () => AcChatConversationUser(),
      );
      if (otherMember.userId.isNotEmpty) {
        final u = await api.getUserById(userId: otherMember.userId);
        if (u != null && u.name.trim().isNotEmpty) user = u;
      }
      if (user == null || user.name.trim().isEmpty) {
        final otherId = chat.memberIds.firstWhere(
          (id) => id.isNotEmpty && id != currentUser.userId,
          orElse: () => '',
        );
        if (otherId.isNotEmpty) {
          final u = await api.getUserById(userId: otherId);
          if (u != null && u.name.trim().isNotEmpty) user = u;
        }
      }
      if (user == null || user.name.trim().isEmpty) {
        final directUserId = chat.otherUserId;
        if (directUserId != null && directUserId.isNotEmpty && directUserId != currentUser.userId) {
          final u = await api.getUserById(userId: directUserId);
          if (u != null && u.name.trim().isNotEmpty) user = u;
        }
      }
    }

    var membersList = await api.getConversationUsers(conversationId: chat.conversationId);
    if (isGroup && membersList.isEmpty && chat.memberIds.isNotEmpty) {
      membersList = chat.memberIds
          .map((id) => AcChatConversationUser()
            ..conversationId = chat.conversationId
            ..userId = id)
          .toList();
    }

    final participantChats = <AcChatConversation>[];
    bool isBlocked = false;
    if (user != null) {
      final targetUserId = user.userId;
      final otherChats = (await api.getConversations())
          .where((c) => c.conversationId != chat.conversationId)
          .toList();

      for (var c in otherChats) {
        final members = await api.getConversationUsers(conversationId: c.conversationId);
        if (members.any((m) => m.userId == targetUserId)) {
          participantChats.add(c);
        }
      }

      isBlocked = await api.isUserBlocked(userId: user.userId);
    }

    final mediaMsgs = (await api.getMessages(conversationId: chat.conversationId))
        .where((m) => m.type == 'image' || m.type == 'video' || m.type == 'audio')
        .toList();

    if (mounted) {
      setState(() {
        _currentUser = currentUser;
        _user = user;
        _membersList = membersList;
        _isBlocked = isBlocked;
        _mediaMsgs = mediaMsgs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final chat = widget.chat;
    final ct = api.theme;
    final isDark = ct.isDark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: ct.scaffold,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = _currentUser;
    final isGroup = chat.type == 'group';
    final user = _user;
    final membersList = _membersList;
    final isBlocked = _isBlocked;
    final mediaMsgs = _mediaMsgs;

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

    final userEmail = user?.email.trim();
    final userPhone = user?.phone?.trim();
    final userContact = (userEmail != null && userEmail.isNotEmpty)
        ? userEmail
        : ((userPhone != null && userPhone.isNotEmpty) ? userPhone : 'No email');
    final subtitleText = isGroup
        ? 'Group • ${membersList.length} members'
        : 'Direct Message • $userContact';

    final dynamic avatarId = isGroup ? '${chat.conversationId}-group' : (user?.userId ?? chat.otherUserId ?? '');
    final themeColor = avatarColor(avatarId);

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
                      colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: widget.isEmbedded ? 'avatar-profile-${chat.conversationId}' : 'avatar-${chat.conversationId}',
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: ct.white.withValues(alpha: 0.2),
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
                          color: ct.white.withValues(alpha: 0.85),
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
                padding: const EdgeInsets.only(bottom: 6.0,top:12.0),
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
                          ConversationMediaTabs.showModal(
                            context: context,
                            chat: chat,
                            ct: ct,
                            api: api,
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
                                    color: themeColor.withValues(alpha: 0.15),
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
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3.0),
            //     child: Card(
            //       elevation: 0,
            //       color: isDark ? ct.chatDarkAppBar : ct.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(16),
            //         side: BorderSide(color: ct.divider, width: 0.5),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text(
            //                   isGroup ? 'Group Members' : 'Shared Conversations',
            //                   style: TextStyle(
            //                     color: ct.text,
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 if (isGroup && api.addGroupMembers != null)
            //                   IconButton(
            //                     icon: Icon(Icons.person_add_alt_1_rounded, color: ct.activeTabColor, size: 22),
            //                     onPressed: () async {
            //                       if (membersList.length >= api.maxGroupParticipants) {
            //                         ScaffoldMessenger.of(context).showSnackBar(
            //                           SnackBar(
            //                             content: Text('Group participant limit (${api.maxGroupParticipants}) reached'),
            //                           ),
            //                         );
            //                         return;
            //                       }
            //                       final allUsers = api.getUsers();
            //                       final currentMemberIds = membersList.map((m) => m.userId).toSet();
            //                       final myId = api.getCurrentUser().userId;
            //                       final candidates = allUsers
            //                           .where((u) => !currentMemberIds.contains(u.userId) && u.userId != myId)
            //                           .toList();
            //
            //                       if (candidates.isEmpty) {
            //                         ScaffoldMessenger.of(context).showSnackBar(
            //                           const SnackBar(content: Text('All available users are already in this group')),
            //                         );
            //                         return;
            //                       }
            //
            //                       final selectedUser = await showDialog<AcChatUser>(
            //                         context: context,
            //                         builder: (dialogCtx) => SimpleDialog(
            //                           title: const Text('Add Member'),
            //                           children: candidates.map((u) => SimpleDialogOption(
            //                             onPressed: () => Navigator.pop(dialogCtx, u),
            //                             child: Text(u.name),
            //                           )).toList(),
            //                         ),
            //                       );
            //
            //                       if (selectedUser != null) {
            //                         await api.addGroupMembers!(
            //                           conversationId: chat.conversationId,
            //                           userIds: [selectedUser.userId],
            //                         );
            //                         if (mounted) setState(() {});
            //                       }
            //                     },
            //                   ),
            //               ],
            //             ),
            //           ),
            //           Divider(color: ct.divider, height: 1),
            //           if (isGroup) ...[
            //             ListView.builder(
            //               shrinkWrap: true,
            //               physics: const NeverScrollableScrollPhysics(),
            //               itemCount: membersList.length,
            //               itemBuilder: (context, index) {
            //                 final memberRel = membersList[index];
            //                 final u = api.getUserById(userId: memberRel.userId);
            //                 if (u == null) return const SizedBox.shrink();
            //                 final isMe = u.userId == api.getCurrentUser().userId;
            //
            //                 return ListTile(
            //                   leading: CircleAvatar(
            //                     backgroundColor: avatarColor(u.userId),
            //                     child: Text(
            //                       u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
            //                       style: TextStyle(color: ct.white),
            //                     ),
            //                   ),
            //                   title: Text(
            //                     isMe ? '${u.name} (You)' : u.name,
            //                     style: TextStyle(color: ct.text),
            //                   ),
            //                   subtitle: Text(u.email, style: TextStyle(color: ct.subText, fontSize: 12)),
            //                   trailing: (!isMe && api.removeGroupMember != null)
            //                       ? IconButton(
            //                           icon: Icon(Icons.remove_circle_outline, color: ct.messageDestructive, size: 20),
            //                           onPressed: () async {
            //                             await api.removeGroupMember!(
            //                               conversationId: chat.conversationId,
            //                               userId: u.userId,
            //                             );
            //                             if (mounted) setState(() {});
            //                           },
            //                         )
            //                       : null,
            //                 );
            //               },
            //             )
            //           ] else ...[
            //             if (participantChats.isEmpty)
            //               Padding(
            //                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            //                 child: Center(
            //                   child: Text(
            //                     'No other shared conversations',
            //                     style: TextStyle(color: ct.subText, fontSize: 13),
            //                   ),
            //                 ),
            //               )
            //             else
            //               ListView.builder(
            //                 shrinkWrap: true,
            //                 physics: const NeverScrollableScrollPhysics(),
            //                 itemCount: participantChats.length,
            //                 itemBuilder: (context, index) {
            //                   final pChat = participantChats[index];
            //                   final isGroupChat = pChat.type == 'group';
            //                   final pName = isGroupChat
            //                       ? (pChat.groupName ?? 'Group')
            //                       : (api.getUserById(userId: user?.userId ?? '')?.name ?? 'Unknown');
            //                   final pColor = avatarColor(isGroupChat ? '${pChat.conversationId}-group' : user?.userId);
            //
            //                   return ListTile(
            //                     leading: CircleAvatar(
            //                       backgroundColor: pColor,
            //                       child: isGroupChat
            //                           ? Icon(Icons.group, color: ct.white, size: 18)
            //                           : Text(
            //                               pName.isNotEmpty ? pName[0].toUpperCase() : '?',
            //                               style: TextStyle(color: ct.white),
            //                             ),
            //                     ),
            //                     title: Text(pName, style: TextStyle(color: ct.text)),
            //                     subtitle: Text(
            //                       pChat.lastMessage.isNotEmpty ? pChat.lastMessage : 'No messages',
            //                       style: TextStyle(color: ct.subText, fontSize: 12),
            //                       maxLines: 1,
            //                       overflow: TextOverflow.ellipsis,
            //                     ),
            //                   );
            //                 },
            //               ),
            //           ],
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // 4. Settings & Actions Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
                child: Card(
                  elevation: 0,
                  color: isDark ? ct.chatDarkAppBar : ct.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: ct.divider, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      // Mute Notifications
                      SwitchListTile(
                        secondary: Icon(chat.isMuted ? Icons.volume_off : Icons.volume_up_outlined, color: ct.subText),
                        title: Text('Mute Notifications', style: TextStyle(color: ct.text)),
                        value: chat.isMuted,
                        activeThumbColor: ct.activeTabColor,
                        onChanged: (val) async {
                          await api.muteConversation(conversationId: chat.conversationId, muted: val);
                          setState(() {
                            chat.isMuted = val;
                          });
                        },
                      ),
                      // Disappearing Messages
                      Divider(color: ct.divider, height: 1),
                      ListTile(
                        leading: Icon(Icons.timer_outlined, color: ct.subText),
                        title: Text('Disappearing Messages', style: TextStyle(color: ct.text)),
                        subtitle: Text(
                          _formatDisappearingDuration(chat.disappearingDurationSeconds),
                          style: TextStyle(color: ct.subText, fontSize: 12),
                        ),
                        onTap: () async {
                          final selected = await showDialog<int?>(
                            context: context,
                            builder: (dCtx) => SimpleDialog(
                              title: const Text('Disappearing Messages'),
                              children: [
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(dCtx, 0),
                                  child: const Text('Off'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(dCtx, 24 * 3600),
                                  child: const Text('24 Hours'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(dCtx, 7 * 24 * 3600),
                                  child: const Text('7 Days'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.pop(dCtx, 90 * 24 * 3600),
                                  child: const Text('90 Days'),
                                ),
                              ],
                            ),
                          );
                          if (selected != null && mounted) {
                            setState(() {
                              chat.disappearingDurationSeconds = selected > 0 ? selected : null;
                            });
                          }
                        },
                      ),
                      // Edit Group (if isGroup)
                      if (isGroup && (!api.enableGroupAdminRoles || chat.createdBy == currentUser?.userId)) ...[
                        Divider(color: ct.divider, height: 1),
                        ListTile(
                          leading: Icon(Icons.edit_outlined, color: ct.subText),
                          title: Text('Edit Group Details', style: TextStyle(color: ct.text)),
                          onTap: () async {
                            final nameCtrl = TextEditingController(text: chat.groupName);
                            final descCtrl = TextEditingController(text: chat.groupDescription);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Edit Group Details'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: nameCtrl,
                                      decoration: const InputDecoration(labelText: 'Group Name'),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: descCtrl,
                                      decoration: const InputDecoration(labelText: 'Description'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Save')),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              chat.groupName = nameCtrl.text.trim();
                              chat.groupDescription = descCtrl.text.trim();
                              await api.updateGroupDetails(
                                conversationId: chat.conversationId,
                                groupName: chat.groupName,
                                groupDescription: chat.groupDescription,
                              );
                              setState(() {});
                            }
                          },
                        ),
                      ],
                      // Export Chat
                      Divider(color: ct.divider, height: 1),
                      ListTile(
                        leading: Icon(Icons.file_download_outlined, color: ct.subText),
                        title: Text('Export Chat', style: TextStyle(color: ct.text)),
                        onTap: () async {
                          final data = await api.exportChat(conversationId: chat.conversationId, asJson: true);
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Exported Chat Data'),
                                content: SingleChildScrollView(child: SelectableText(data)),
                                actions: [TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Close'))],
                              ),
                            );
                          }
                        },
                      ),
                      // Block User (Direct Chat)
                      if (!isGroup && user != null) ...[
                        Divider(color: ct.divider, height: 1),
                        Builder(
                          builder: (context) {
                            final targetUid = user.userId;

                            return ListTile(
                              leading: Icon(isBlocked ? Icons.lock_open : Icons.block, color: ct.messageDestructive),
                              title: Text(isBlocked ? 'Unblock User' : 'Block User', style: TextStyle(color: ct.messageDestructive)),
                              onTap: () async {
                                if (isBlocked) {
                                  await api.unblockUser(userId: targetUid);
                                } else {
                                  await api.blockUser(userId: targetUid);
                                }
                                setState(() {});
                              },
                            );
                          },
                        ),
                        Divider(color: ct.divider, height: 1),
                        ListTile(
                          leading: Icon(Icons.report_outlined, color: ct.messageDestructive),
                          title: Text('Report User', style: TextStyle(color: ct.messageDestructive)),
                          onTap: () async {
                            final targetUid = user.userId;
                            final reasonCtrl = TextEditingController();
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Report User'),
                                content: TextField(
                                  controller: reasonCtrl,
                                  decoration: const InputDecoration(hintText: 'Enter reason for report...'),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Report')),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              await api.reportUser(userId: targetUid, reason: reasonCtrl.text.trim());
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Report submitted. Thank you.')),
                                );
                              }
                            }
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

  String _formatDisappearingDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return 'Off';
    if (seconds == 24 * 3600) return '24 Hours';
    if (seconds == 7 * 24 * 3600) return '7 Days';
    if (seconds == 90 * 24 * 3600) return '90 Days';
    final days = seconds ~/ 86400;
    if (days > 0) return '$days Days';
    final hours = seconds ~/ 3600;
    return '$hours Hours';
  }
}

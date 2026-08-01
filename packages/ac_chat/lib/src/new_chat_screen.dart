import 'package:flutter/material.dart';
import 'core/ac_chat.dart';
import 'common/chat_colors.dart';
import 'common/theme_provider.dart';

class NewChatScreen extends StatefulWidget {
  final AcChatApi api;
  const NewChatScreen({super.key, required this.api});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  String _query = '';

  List<AcChatUser> get _filtered {
    final list = widget.api.getUsers();
    if (_query.isEmpty) return list;
    return list
        .where((u) =>
            u.name
                .toLowerCase()
                .contains(_query.toLowerCase()) ||
            u.username
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();
  }

  void _startChat(AcChatUser user) {
    final existing =
        widget.api.getConversations().where((c) => c.type == 'direct' && c.memberIds.contains(user.userId)).toList();
    AcChatConversation? conversation;
    if (existing.isNotEmpty) {
      conversation = existing.first;
    } else {
      final newConv = AcChatConversation()
        ..type = 'direct'
        ..groupName = null
        ..memberIds = []
        ..lastMessage = ''
        ..lastMessageType = 'text'
        ..isPinned = false
        ..isMuted = false;
      conversation = widget.api.insertConversation(newConv, user.userId);
    }
    Navigator.of(context).pop(conversation);
  }

  void _startGroup() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('New Group — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.api.theme;
    final users = _filtered;

    return Scaffold(
      backgroundColor: ct.scaffold,
      appBar: AppBar(
        backgroundColor: ct.appBar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ct.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Chat',
                style: TextStyle(
                    color: ct.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            Text('${users.length} contacts',
                style: TextStyle(color: ct.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: ct.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(children: [
        // Search bar
        Container(
          color: ct.scaffold,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Container(
            decoration: BoxDecoration(
              color: ct.searchFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              autofocus: false,
              style: TextStyle(color: ct.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search name or username…',
                hintStyle: TextStyle(color: ct.subText, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: ct.subText, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        Expanded(
          child: Builder(builder: (context) {
            final showGroup = widget.api.enableGroupsAndStatuses;
            final specialTilesCount = showGroup ? 2 : 1;
            return ListView.builder(
              itemCount: specialTilesCount + 2 + (users.isEmpty ? 1 : users.length) + 1,
              cacheExtent: 200.0,
              addRepaintBoundaries: true,
              addAutomaticKeepAlives: false,
              itemBuilder: (context, index) {
                int cur = 0;
                if (showGroup) {
                  if (index == cur) {
                    return _SpecialTile(
                      icon: Icons.group_rounded,
                      color: ct.unreadBadgeBg,
                      label: 'New Group',
                      subtitle: 'Create a group with contacts',
                      ct: ct,
                      onTap: _startGroup,
                    );
                  }
                  cur++;
                }
                if (index == cur) {
                  return _SpecialTile(
                    icon: Icons.person_add_rounded,
                    color: ct.newChatGroupIconBg,
                    label: 'Invite to Accountea',
                    subtitle: 'Share the app with friends',
                    ct: ct,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite — coming soon'))),
                  );
                }
                cur++;

                if (index == cur) {
                  return Divider(height: 1, color: ct.divider);
                }
                cur++;

                if (index == cur) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Text(
                      'CONTACTS ON ACCOUNTEA',
                      style: TextStyle(
                          color: ct.unreadBadgeBg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8),
                    ),
                  );
                }
                cur++;

                final contactIndex = index - cur;
                if (users.isEmpty) {
                  if (contactIndex == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text('No contacts found',
                            style: TextStyle(color: ct.subText, fontSize: 14)),
                      ),
                    );
                  }
                  return const SizedBox(height: 80);
                }

                if (contactIndex < users.length) {
                  final u = users[contactIndex];
                  return _ContactTile(
                    user: u,
                    ct: ct,
                    onTap: () => _startChat(u),
                  );
                }
                return const SizedBox(height: 80);
              },
            );
          }),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Special Tile (New Group / Invite)
// ─────────────────────────────────────────────────────────────

class _SpecialTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final AcChatTheme ct;
  final VoidCallback onTap;

  const _SpecialTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.ct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: ct.scaffold,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: color.withOpacity(0.18),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label,
          style: TextStyle(
              color: ct.text, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: ct.subText, fontSize: 12)),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Contact Tile
// ─────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final AcChatUser user;
  final AcChatTheme ct;
  final VoidCallback onTap;

  const _ContactTile(
      {required this.user, required this.ct, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user.name;
    final username = user.username;
    final color = avatarColor(user.userId);

    return ListTile(
      tileColor: ct.scaffold,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: color,
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
              color: ct.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(name,
          style: TextStyle(
              color: ct.text, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text('@$username',
          style: TextStyle(color: ct.subText, fontSize: 12)),
      trailing: Icon(Icons.message_outlined, color: ct.subText, size: 18),
      onTap: onTap,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/ac_chat.dart';

class NewChatScreen extends StatefulWidget {
  final AcChatApi api;

  const NewChatScreen({super.key, required this.api});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  List<AcChatUser> _remoteUsers = [];
  bool _isSearchingRemote = false;
  Timer? _debounceTimer;

  // Multi-select state for creating groups
  bool _isGroupCreationMode = false;
  final Set<String> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    if (q == _query) return;
    setState(() => _query = q);

    _debounceTimer?.cancel();
    if (widget.api.onSearchRemoteUsers != null && q.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 400), () => _searchRemote(q));
    } else {
      setState(() {
        _remoteUsers = [];
        _isSearchingRemote = false;
      });
    }
  }

  Future<void> _searchRemote(String q) async {
    if (widget.api.onSearchRemoteUsers == null) return;
    setState(() => _isSearchingRemote = true);
    try {
      final results = await widget.api.onSearchRemoteUsers!(query: q);
      if (mounted && _query == q) {
        final myId = (await widget.api.getCurrentUser()).userId;
        final localIds = (await _localUsers()).map((u) => u.userId).toSet();
        setState(() {
          _remoteUsers = results
              .where((u) => !localIds.contains(u.userId) && u.userId != myId)
              .toList();
          _isSearchingRemote = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearchingRemote = false);
    }
  }

  Future<List<AcChatUser>> _localUsers() async {
    final myId = (await widget.api.getCurrentUser()).userId;
    final users = await widget.api.getContacts?.call() ?? await widget.api.getUsers();
    return users.where((u) => u.userId.isNotEmpty && u.userId != myId).toList();
  }

  Future<List<AcChatUser>> _filteredLocal() async {
    if (_query.isEmpty) return await _localUsers();
    final q = _query.toLowerCase();
    return (await _localUsers()).where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();
  }

  void _startChat(AcChatUser user) async {
    final existing = (await widget.api.getConversations()).where(
      (c) => c.type == 'direct' && c.memberIds.contains(user.userId),
    ).toList();

    AcChatConversation? conversation;
    if (existing.isNotEmpty) {
      conversation = existing.first;
    } else {
      final newConv = AcChatConversation()
        ..type = 'direct'
        ..groupName = null
        ..memberIds = [(await widget.api.getCurrentUser()).userId, user.userId]
        ..lastMessage = ''
        ..lastMessageType = 'text'
        ..isPinned = false
        ..isMuted = false;
      conversation = await widget.api.insertConversation(
        newConversation: newConv,
        otherUserId: user.userId,
      );
    }
    Navigator.of(context).pop(conversation);
  }

  void _startGroup() {
    if (widget.api.onNewGroup != null) {
      widget.api.onNewGroup!(context: context);
    } else {
      setState(() {
        _isGroupCreationMode = true;
        _selectedMemberIds.clear();
      });
    }
  }

  Future<void> _proceedGroupCreation() async {
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 1 contact to create a group')),
      );
      return;
    }

    final groupNameCtrl = TextEditingController();
    final groupName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Group Name'),
        content: TextField(
          controller: groupNameCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter group subject...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = groupNameCtrl.text.trim();
              if (val.isNotEmpty) Navigator.pop(ctx, val);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (groupName != null && groupName.isNotEmpty && mounted) {
      final allMembers = [(await widget.api.getCurrentUser()).userId, ..._selectedMemberIds];
      final groupConv = await widget.api.createGroupConversation(
        groupName: groupName,
        memberUserIds: allMembers,
      );
      if (mounted) Navigator.of(context).pop(groupConv);
    }
  }

  Future<void> _startNewContact() async {
    if (widget.api.onNewContact != null) {
      final user = await widget.api.onNewContact!(context: context);
      if (user != null && mounted) {
        _startChat(user);
      } else if (mounted) {
        setState(() {});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Contact — coming soon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.api.theme;

    return FutureBuilder<List<AcChatUser>>(
      future: _filteredLocal(),
      builder: (context, snapshot) {
        final localUsers = snapshot.data ?? [];
        final totalContacts = localUsers.length;

        return Scaffold(
          backgroundColor: ct.scaffold,
          appBar: AppBar(
        backgroundColor: ct.appBar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ct.white),
          onPressed: () {
            if (_isGroupCreationMode) {
              setState(() => _isGroupCreationMode = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isGroupCreationMode ? 'New Group' : 'New Chat',
              style: TextStyle(
                color: ct.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _isGroupCreationMode
                  ? '${_selectedMemberIds.length} / ${widget.api.maxGroupParticipants}'
                  : '$totalContacts contacts',
              style: TextStyle(color: ct.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (_isGroupCreationMode)
            TextButton(
              onPressed: _selectedMemberIds.isNotEmpty ? _proceedGroupCreation : null,
              child: Text(
                'Next',
                style: TextStyle(
                  color: _selectedMemberIds.isNotEmpty ? ct.activeTabColor : ct.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            color: ct.appBar,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ct.searchBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: ct.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _isGroupCreationMode ? 'Search contacts to add…' : 'Search name, username or email…',
                  hintStyle: TextStyle(color: ct.subText, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: ct.subText, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: ct.subText, size: 18),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Action Items & Contacts List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (!_isGroupCreationMode && _query.isEmpty && (widget.api.enableGroups || widget.api.enableCreateNewContact)) ...[
                  if (widget.api.enableGroups)
                    _SpecialTile(
                      icon: Icons.group_add_rounded,
                      label: widget.api.newGroupLabel ?? 'New Group',
                      subtitle: widget.api.newGroupSubtitle ?? 'Create a group chat',
                      ct: ct,
                      onTap: _startGroup,
                    ),
                  if (widget.api.enableCreateNewContact)
                  _SpecialTile(
                    icon: Icons.person_add_rounded,
                    label: widget.api.newContactLabel ?? 'New Contact',
                    subtitle: widget.api.newContactSubtitle ?? 'Add a new contact to chat',
                    ct: ct,
                    onTap: _startNewContact,
                  ),
                  Divider(height: 1, color: ct.divider),
                ],

                // Local Contacts Section
                if (localUsers.isNotEmpty || _query.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Text(
                      widget.api.contactsSectionTitle ?? 'CONTACTS',
                      style: TextStyle(
                        color: ct.unreadBadgeBg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (localUsers.isEmpty && _query.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No contacts found',
                          style: TextStyle(color: ct.subText, fontSize: 14),
                        ),
                      ),
                    ),
                  for (final u in localUsers)
                    _ContactTile(
                      user: u,
                      ct: ct,
                      isSelectable: _isGroupCreationMode,
                      isSelected: _selectedMemberIds.contains(u.userId),
                      onTap: () {
                        if (_isGroupCreationMode) {
                          if (_selectedMemberIds.contains(u.userId)) {
                            setState(() => _selectedMemberIds.remove(u.userId));
                          } else {
                            if (_selectedMemberIds.length >= widget.api.maxGroupParticipants) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Maximum of ${widget.api.maxGroupParticipants} participants allowed'),
                                ),
                              );
                            } else {
                              setState(() => _selectedMemberIds.add(u.userId));
                            }
                          }
                        } else {
                          _startChat(u);
                        }
                      },
                    ),
                ],

                // Remote Users Section
                if (!_isGroupCreationMode && _isSearchingRemote)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ct.unreadBadgeBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Searching remote contacts…',
                          style: TextStyle(color: ct.subText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                if (!_isGroupCreationMode && _remoteUsers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_outlined, size: 14, color: ct.unreadBadgeBg),
                        const SizedBox(width: 6),
                        Text(
                          'REMOTE CONTACTS FOUND',
                          style: TextStyle(
                            color: ct.unreadBadgeBg,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final u in _remoteUsers)
                    _ContactTile(
                      user: u,
                      ct: ct,
                      isRemote: true,
                      onTap: () => _startChat(u),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _SpecialTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final AcChatTheme ct;
  final VoidCallback onTap;

  const _SpecialTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.ct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: ct.activeTabColor,
        child: Icon(icon, color: ct.white, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(color: ct.text, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: ct.subText, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

class _ContactTile extends StatelessWidget {
  final AcChatUser user;
  final AcChatTheme ct;
  final bool isRemote;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContactTile({
    required this.user,
    required this.ct,
    this.isRemote = false,
    this.isSelectable = false,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = user.name.isNotEmpty ? user.name : user.username;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = avatarColor(user.userId);

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              initial,
              style: TextStyle(
                color: ct.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          if (isSelectable && isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: ct.activeTabColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: ct.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isRemote)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ct.unreadBadgeBg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Remote',
                style: TextStyle(
                  color: ct.unreadBadgeBg,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        user.userId.isNotEmpty ? user.userId : user.email,
        style: TextStyle(color: ct.subText, fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelectable
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: ct.activeTabColor,
            )
          : Icon(Icons.message_outlined, color: ct.subText, size: 18),
      onTap: onTap,
    );
  }
}

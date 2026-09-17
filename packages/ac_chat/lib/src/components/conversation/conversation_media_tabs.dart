import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ac_chat.dart';
import 'media_viewer_screen.dart';

class ConversationMediaTabs extends StatefulWidget {
  final AcChatConversation conversation;
  final AcChatTheme ct;
  final AcChatApi? api;

  const ConversationMediaTabs({
    super.key,
    required this.conversation,
    required this.ct,
    this.api,
  });

  static Future<T?> showModal<T>({
    required BuildContext context,
    required AcChatConversation conversation,
    required AcChatTheme ct,
    AcChatApi? api,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ct.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ct.subText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Media, Links and Docs',
                    style: TextStyle(
                      color: ct.text,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ct.subText),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: ct.divider),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: ConversationMediaTabs(
                  conversation: conversation,
                  ct: ct,
                  api: api,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<ConversationMediaTabs> createState() => _ConversationMediaTabsState();
}

class _ConversationMediaTabsState extends State<ConversationMediaTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openViewer(BuildContext context, AcChatMessage msg) async {
    AcChatApi effectiveApi = widget.api ?? AcChatApiProvider.getApi(context);
    final sender = await effectiveApi.getUserById(userId: msg.senderId);
    final senderName = msg.senderId == widget.api?.userId
        ? 'You'
        : (sender?.name ?? 'Unknown');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          message: msg,
          ct:widget.ct,
          senderName: senderName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AcChatApi effectiveApi = widget.api ?? AcChatApiProvider.getApi(context);
    final ct = widget.ct;

    return FutureBuilder<List<AcChatMessage>>(
      future: effectiveApi.getMessages(conversationId: widget.conversation.conversationId),
      builder: (context, snapshot) {
        final allMessages = snapshot.data ?? [];

        final mediaMsgs = allMessages
            .where((m) => m.type == 'image' || m.type == 'video' || m.type == 'audio')
            .toList();
        final docMsgs = allMessages.where((m) => m.type == 'document').toList();

        final urlRegex = RegExp(
            r'(https?:\/\/[^\s]+|(www\.[^\s]+))',
            caseSensitive: false);
        final linkMsgs = allMessages
            .where((m) => m.type == 'text' && urlRegex.hasMatch(m.text))
            .toList();

        final dynamic avatarId = widget.conversation.type == 'group'
            ? '${widget.conversation.conversationId}-group'
            : widget.conversation.conversationId;
        final themeColor = avatarColor(avatarId);

        return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: ct.unreadBadgeBg,
          unselectedLabelColor: ct.subText,
          indicatorColor: ct.unreadBadgeBg,
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Docs'),
            Tab(text: 'Links'),
          ],
        ),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            Widget content;
            if (_tabController.index == 0) {
              // Media Grid View
              if (mediaMsgs.isEmpty) {
                content = _buildEmptyState(ct, 'No shared media');
              } else {
                content = GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: mediaMsgs.length,
                  itemBuilder: (context, index) {
                    final msg = mediaMsgs[index];
                    if (msg.type == 'image') {
                      return InkWell(
                        onTap: () => _openViewer(context, msg),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: themeColor.withValues(alpha: 0.15),
                            child: Image.network(
                              msg.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, color: themeColor, size: 28),
                            ),
                          ),
                        ),
                      );
                    } else if (msg.type == 'audio') {
                      return Container(
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
                      // video
                      String thumbUrl = 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400';
                      if (msg.text.contains('BigBuckBunny')) {
                        thumbUrl = 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400';
                      } else if (msg.text.contains('ForBiggerBlazes')) {
                        thumbUrl = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400';
                      }

                      return InkWell(
                        onTap: () => _openViewer(context, msg),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: ct.profileStatusBlue.withValues(alpha: 0.15),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  thumbUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.video_collection, color: ct.profileStatusBlue),
                                ),
                                Center(
                                  child: Icon(Icons.play_circle_fill, color: ct.white, size: 28),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            } else if (_tabController.index == 1) {
              // Docs List
              if (docMsgs.isEmpty) {
                content = _buildEmptyState(ct, 'No shared documents');
              } else {
                content = ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docMsgs.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: ct.divider, height: 1),
                  itemBuilder: (context, index) {
                    final msg = docMsgs[index];
                    final fileName = msg.fileName ?? 'Document.pdf';
                    final lowerName = fileName.toLowerCase();
                    
                    Color docColor = ct.docIconPdf;
                    IconData docIcon = Icons.picture_as_pdf;
                    if (lowerName.endsWith('.xlsx') || lowerName.endsWith('.xls')) {
                      docColor = ct.docIconExcel;
                      docIcon = Icons.grid_on_rounded;
                    } else if (lowerName.endsWith('.docx') || lowerName.endsWith('.doc')) {
                      docColor = ct.docIconWord;
                      docIcon = Icons.description_rounded;
                    } else if (lowerName.endsWith('.zip') || lowerName.endsWith('.rar')) {
                      docColor = ct.docIconPpt;
                      docIcon = Icons.folder_zip_rounded;
                    }

                    return ListTile(
                      onTap: () => _openViewer(context, msg),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: docColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(docIcon, color: docColor),
                      ),
                      title: Text(fileName,
                          style: TextStyle(color: ct.text)),
                      subtitle: Text(msg.fileSize ?? 'Unknown size',
                          style: TextStyle(color: ct.subText, fontSize: 12)),
                      trailing: Text(
                        DateFormat('dd MMM').format(msg.time),
                        style: TextStyle(color: ct.subText, fontSize: 11),
                      ),
                    );
                  },
                );
              }
            } else {
              // Links List
              if (linkMsgs.isEmpty) {
                content = _buildEmptyState(ct, 'No shared links');
              } else {
                content = ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: linkMsgs.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: ct.divider, height: 1),
                  itemBuilder: (context, index) {
                    final msg = linkMsgs[index];
                    final urlMatch = urlRegex.firstMatch(msg.text);
                    final url = urlMatch?.group(0) ?? '';
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ct.profileStatusBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.link, color: ct.profileStatusBlue),
                      ),
                      title: Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ct.profileStatusBlue,
                            decoration: TextDecoration.underline),
                      ),
                      subtitle: Text(
                        msg.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: ct.subText, fontSize: 12),
                      ),
                      trailing: Text(
                        DateFormat('dd MMM').format(msg.time),
                        style: TextStyle(color: ct.subText, fontSize: 11),
                      ),
                    );
                  },
                );
              }
            }

            return Container(
              color: ct.surface,
              child: content,
            );
          },
        ),
      ],
    );
      },
    );
  }

  Widget _buildEmptyState(AcChatTheme ct, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline,
                color: ct.subText.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: ct.subText, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

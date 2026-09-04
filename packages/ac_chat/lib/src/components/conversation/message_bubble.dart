import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ac_extensions/ac_extensions.dart';

import '../../core/ac_chat.dart';
import '../../common/chat_colors.dart';
import 'media_download_wrapper.dart';
import 'media_viewer_screen.dart';
import 'message_action_row.dart';
import 'message_bubbles/image_message_bubble.dart';
import 'message_bubbles/audio_message_bubble.dart';
import 'message_bubbles/document_message_bubble.dart';
import 'message_bubbles/video_message_bubble.dart';
import 'message_bubbles/location_message_bubble.dart';
import 'message_bubbles/contact_message_bubble.dart';

class MessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  final bool isDark;
  final bool isGroup;
  final void Function(AcChatMessage)? onReply;
  final void Function(String)? onCopy;
  final void Function(AcChatMessage)? onEdit;
  final void Function(AcChatMessage)? onForward;
  final void Function(AcChatMessage, bool forEveryone)? onDelete;
  final void Function(AcChatMessage, String emoji)? onReaction;
  final void Function(AcChatMessage)? onStar;
  final void Function(AcChatMessage)? onPin;
  final VoidCallback? onSelect;
  final bool isSelected;
  final bool isSelectionMode;

  final bool isSenderChanged;
  final bool showTail;

  const MessageBubble({
    super.key,
    required this.message,
    required this.ct,
    required this.isDark,
    required this.isGroup,
    this.onReply,
    this.onCopy,
    this.onEdit,
    this.onForward,
    this.onDelete,
    this.onReaction,
    this.onStar,
    this.onPin,
    this.onSelect,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.isSenderChanged = false,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final config = api.config;
    final myId = api.getCurrentUser().userId;
    final isMe = message.senderId == myId;
    final type = message.type;
    final status = message.status;
    final localTime = message.timeUtc.toLocal();
    final timeStr = DateFormat('hh:mm a').format(localTime);

    Widget bubbleWidget = Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 4,
          right: isMe ? 4 : 60,
          top: isSenderChanged ? 8 : 1,
          bottom: 2,
        ),
        child: CustomPaint(
          painter: BubbleBackgroundPainter(
            isMe: isMe,
            showTail: showTail,
            color: isMe ? ct.sentBubble : ct.recvBubble,
            shadowColor: ct.black.withOpacity(0.12),
          ),
          child: Container(
            padding: _bubblePadding(type),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sender name in group conversations
                  if (isGroup && !isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        api.getUserById(userId: message.senderId)?.name ?? 'Unknown',
                        style: TextStyle(
                          color: avatarColor(message.senderId),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  // Reply preview
                  if (message.replyTo != null && config.enableMessageReplying)
                    _ReplyPreview(replyTo: message.replyTo!, ct: ct),

                  // Message content (or deleted placeholder)
                  if (message.isDeleted)
                    _buildDeletedContent(ct)
                  else
                    _buildContent(context, type, ct),

                  // Reactions Badge Row
                  if (config.enableMessageReactions && message.reactions.isNotEmpty && !message.isDeleted)
                    _buildReactionsRow(context, api, myId, ct),

                  // Time + edited tag + starred icon + ticks
                  const SizedBox(height: 3),
                  Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isStarred && config.enableStarredMessages) ...[
                          Icon(Icons.star_rounded, size: 12, color: ct.profileStatusOrange),
                          const SizedBox(width: 2),
                        ],
                        if (message.isEdited && config.enableMessageEditing) ...[
                          Text(
                            'edited ',
                            style: TextStyle(
                              color: ct.subText.withOpacity(0.8),
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: ct.subText.withOpacity(0.9),
                            fontSize: 10,
                          ),
                        ),
                        if (isMe && !message.isDeleted) ...[
                          const SizedBox(width: 3),
                          if (config.enableDeliveryReceipts || config.enableReadReceipts)
                            _TickIcon(status: status, ct: ct, config: config),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Multi-select wrapper
    if (isSelectionMode) {
      return InkWell(
        onTap: onSelect,
        child: Container(
          color: isSelected ? ct.activeTabColor.withOpacity(0.15) : Colors.transparent,
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelect?.call(),
                activeColor: ct.activeTabColor,
              ),
              Expanded(child: bubbleWidget),
            ],
          ),
        ),
      );
    }

    // Swipe-to-reply wrapper (only if replying is enabled)
    if (config.enableMessageReplying && !message.isDeleted && onReply != null) {
      bubbleWidget = Dismissible(
        key: ValueKey('reply_${message.messageId}'),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (_) async {
          onReply!(message);
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Icon(Icons.reply_rounded, color: ct.subText, size: 22),
        ),
        child: bubbleWidget,
      );
    }

    return GestureDetector(
      onLongPress: () {
        if (config.enableMultiSelect && onSelect != null && isSelectionMode) {
          onSelect!();
        } else {
          _showBubbleMenu(context, api);
        }
      },
      onTap: () {
        if (isSelectionMode && onSelect != null) {
          onSelect!();
          return;
        }
        if (api.onMessageTap != null) {
          api.onMessageTap!(message);
          return;
        }
        if (config.enableMediaViewer &&
            (type == 'image' || type == 'video' || type == 'document') &&
            !message.isDeleted) {
          final sender = api.getUserById(userId: message.senderId);
          final senderName = isMe ? 'You' : (sender?.name ?? 'Unknown');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaViewerScreen(
                message: message,
                ct: ct,
                senderName: senderName,
              ),
            ),
          );
        }
      },
      child: bubbleWidget,
    );
  }

  Widget _buildDeletedContent(AcChatTheme ct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded, size: 14, color: ct.subText.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            'This message was deleted',
            style: TextStyle(
              color: ct.subText.withOpacity(0.8),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionsRow(BuildContext context, AcChatApi api, String myId, AcChatTheme ct) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: message.reactions.entries.map((entry) {
          final emoji = entry.key;
          final userIds = entry.value;
          final hasReacted = userIds.contains(myId);

          return GestureDetector(
            onTap: () {
              if (onReaction != null) {
                onReaction!(message, emoji);
              } else {
                if (hasReacted) {
                  api.removeReaction(messageId: message.messageId, emoji: emoji);
                } else {
                  api.addReaction(messageId: message.messageId, emoji: emoji);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasReacted
                    ? ct.activeTabColor.withOpacity(0.2)
                    : ct.subText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasReacted ? ct.activeTabColor : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 3),
                  Text(
                    '${userIds.length}',
                    style: TextStyle(
                      color: hasReacted ? ct.activeTabColor : ct.subText,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  EdgeInsets _bubblePadding(String type) {
    if (type == 'image' || type == 'video') {
      return const EdgeInsets.all(4);
    }
    return const EdgeInsets.fromLTRB(10, 7, 10, 5);
  }

  Widget _buildContent(BuildContext context, String type, AcChatTheme ct) {
    Widget content;
    switch (type) {
      case 'image':
        content = ImageMessageBubble(message: message, ct: ct);
        break;
      case 'video':
        content = VideoMessageBubble(message: message, ct: ct);
        break;
      case 'document':
        content = DocumentMessageBubble(message: message, ct: ct);
        break;
      case 'audio':
      case 'voice_note':
        content = AudioMessageBubble(message: message, ct: ct);
        break;
      case 'location':
        content = LocationMessageBubble(message: message, ct: ct);
        break;
      case 'contact':
        content = ContactMessageBubble(message: message, ct: ct);
        break;
      default:
        final custom = AcChatApiProvider.of(context)
            .customMessageBuilder
            ?.call(context: context, message: message);
        content = custom ??
            Text(
              message.text,
              style: TextStyle(color: ct.text, fontSize: 14.5),
            );
        break;
    }

    if (type == 'image' || type == 'video' || type == 'document') {
      return MediaDownloadWrapper(message: message, ct: ct, child: content);
    }
    return content;
  }

  void _showBubbleMenu(BuildContext context, AcChatApi api) {
    final config = api.config;
    final myId = api.getCurrentUser().userId;
    final isMe = message.senderId == myId;
    final now = DateTime.now().toUtc();

    // Check policies
    final canEdit = config.enableMessageEditing &&
        isMe &&
        !message.isDeleted &&
        now.difference(message.timeUtc) <= config.editTimeWindow;

    final canDeleteForEveryone = config.enableMessageDeletingForEveryone &&
        isMe &&
        !message.isDeleted &&
        now.difference(message.timeUtc) <= config.deleteForEveryoneWindow;

    final canDeleteForMe = config.enableMessageDeletingForMe;

    showModalBottomSheet(
      context: context,
      backgroundColor: ct.chatBubbleMenuBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ct.subText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Quick emoji reactions bar
            if (config.enableMessageReactions && !message.isDeleted) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['👍', '❤️', '😂', '😮', '😢', '🙏'].map((emoji) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pop(context);
                        if (onReaction != null) {
                          onReaction!(message, emoji);
                        } else {
                          api.addReaction(messageId: message.messageId, emoji: emoji);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: ct.divider, height: 16),
            ],

            // Action row
            MessageActionRow(
              ct: ct,
              isDark: isDark,
              items: [
                if (config.enableMessageReplying && !message.isDeleted)
                  MessageAction(
                    icon: Icons.reply_rounded,
                    label: 'Reply',
                    onTap: () {
                      Navigator.pop(context);
                      onReply?.call(message);
                    },
                  ),
                if (canEdit)
                  MessageAction(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    onTap: () {
                      Navigator.pop(context);
                      onEdit?.call(message);
                    },
                  ),
                if (config.enableMessageCopying && message.text.isNotEmpty && !message.isDeleted)
                  MessageAction(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: message.text));
                      onCopy?.call(message.text);
                    },
                  ),
                if (config.enableMessageForwarding && !message.isDeleted)
                  MessageAction(
                    icon: Icons.forward_rounded,
                    label: 'Forward',
                    onTap: () {
                      Navigator.pop(context);
                      onForward?.call(message);
                    },
                  ),
                if (config.enableStarredMessages && !message.isDeleted)
                  MessageAction(
                    icon: message.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                    label: message.isStarred ? 'Unstar' : 'Star',
                    color: message.isStarred ? ct.profileStatusOrange : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (onStar != null) {
                        onStar!(message);
                      } else {
                        api.setStarred(
                          messageId: message.messageId,
                          isStarred: !message.isStarred,
                        );
                      }
                    },
                  ),
                if (config.enablePinnedMessages && !message.isDeleted)
                  MessageAction(
                    icon: Icons.push_pin_outlined,
                    label: 'Pin',
                    onTap: () {
                      Navigator.pop(context);
                      onPin?.call(message);
                    },
                  ),
                if (canDeleteForMe || canDeleteForEveryone)
                  MessageAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: ct.messageDestructive,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteDialog(context, api, canDeleteForEveryone, canDeleteForMe);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AcChatApi api,
    bool canDeleteForEveryone,
    bool canDeleteForMe,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ct.surface,
        title: Text('Delete message?', style: TextStyle(color: ct.text)),
        actions: [
          if (canDeleteForMe)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (onDelete != null) {
                  onDelete!(message, false);
                } else {
                  api.deleteMessageForMe(messageId: message.messageId);
                }
              },
              child: Text('Delete for me', style: TextStyle(color: ct.text)),
            ),
          if (canDeleteForEveryone)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (onDelete != null) {
                  onDelete!(message, true);
                } else {
                  api.deleteMessageForEveryone(messageId: message.messageId);
                }
              },
              child: Text('Delete for everyone', style: TextStyle(color: ct.messageDestructive)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ct.subText)),
          ),
        ],
      ),
    );
  }
}

class _TickIcon extends StatelessWidget {
  final String status;
  final AcChatTheme ct;
  final AcChatConfig config;

  const _TickIcon({required this.status, required this.ct, required this.config});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'sending':
        return Icon(Icons.access_time_rounded, size: 13, color: ct.messageCheckIcon);
      case 'delivered':
        if (!config.enableDeliveryReceipts) {
          return Icon(Icons.check_rounded, size: 14, color: ct.messageCheckIcon);
        }
        return Icon(Icons.done_all_rounded, size: 14, color: ct.messageCheckIcon);
      case 'read':
        if (!config.enableReadReceipts) {
          if (config.enableDeliveryReceipts) {
            return Icon(Icons.done_all_rounded, size: 14, color: ct.messageCheckIcon);
          }
          return Icon(Icons.check_rounded, size: 14, color: ct.messageCheckIcon);
        }
        return Icon(Icons.done_all_rounded, size: 14, color: ct.readTick);
      case 'failed':
        return Icon(Icons.error_outline_rounded, size: 14, color: ct.messageDestructive);
      case 'sent':
      default:
        return Icon(Icons.check_rounded, size: 14, color: ct.messageCheckIcon);
    }
  }
}

class _ReplyPreview extends StatelessWidget {
  final AcChatMessage replyTo;
  final AcChatTheme ct;

  const _ReplyPreview({required this.replyTo, required this.ct});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: ct.subText.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: ct.unreadBadgeBg, width: 3)),
      ),
      child: Text(
        replyTo.text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: ct.subText, fontSize: 12),
      ),
    );
  }
}

class BubbleBackgroundPainter extends CustomPainter {
  final bool isMe;
  final bool showTail;
  final Color color;
  final Color shadowColor;

  const BubbleBackgroundPainter({
    required this.isMe,
    required this.showTail,
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    Path unifiedPath = Path()..addRRect(rrect);

    if (showTail) {
      const Size tailSize = Size(14, 14);
      final Path tailPath = isMe
          ? RightTailPainter.getClipPath(tailSize)
          : LeftTailPainter.getClipPath(tailSize);

      final double tailY = size.height - 20;
      final double tailX = isMe ? size.width - 1 : -13;

      final Path shiftedTailPath = tailPath.shift(Offset(tailX, tailY));
      unifiedPath = Path.combine(PathOperation.union, unifiedPath, shiftedTailPath);
    }

    final double blurSigma = 3.0 * 0.57735 + 0.5;
    canvas.drawPath(
      unifiedPath.shift(const Offset(0, 1)),
      Paint()
        ..color = shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma),
    );

    canvas.drawPath(
      unifiedPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant BubbleBackgroundPainter oldDelegate) =>
      oldDelegate.isMe != isMe ||
      oldDelegate.showTail != showTail ||
      oldDelegate.color != color ||
      oldDelegate.shadowColor != shadowColor;
}

class RightTailPainter extends CustomPainter {
  final Color color;
  final Color? shadowColor;

  const RightTailPainter({
    required this.color,
    this.shadowColor,
  });

  static Path getClipPath(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width - 6, size.height)
      ..cubicTo(
        size.width - 3, size.height,
        size.width, size.height - 2,
        size.width, size.height - 8,
      )
      ..cubicTo(
        size.width, size.height - 2,
        size.width - 6, size.height - 3,
        size.width - 12, size.height - 10,
      )
      ..lineTo(size.width - 14, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = getClipPath(size);

    if (shadowColor != null) {
      canvas.drawPath(
        path.shift(const Offset(0, 1)),
        Paint()
          ..color = shadowColor!
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(covariant RightTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.shadowColor != shadowColor;
}

class LeftTailPainter extends CustomPainter {
  final Color color;
  final Color? shadowColor;

  const LeftTailPainter({
    required this.color,
    this.shadowColor,
  });

  static Path getClipPath(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(6, size.height)
      ..cubicTo(
        3, size.height,
        0, size.height - 2,
        0, size.height - 8,
      )
      ..cubicTo(
        0, size.height - 2,
        6, size.height - 3,
        12, size.height - 10,
      )
      ..lineTo(14, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = getClipPath(size);
    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant LeftTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.shadowColor != shadowColor;
}
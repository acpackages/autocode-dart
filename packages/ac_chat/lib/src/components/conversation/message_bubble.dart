import 'package:ac_chat/src/components/conversation/media_download_wrapper.dart';
import 'package:ac_chat/src/components/conversation/media_viewer_screen.dart';
import 'package:ac_chat/src/components/conversation/message_bubbles/image_message_bubble.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:flutter/material.dart';
import '../../core/ac_chat.dart';
import '../../common/chat_colors.dart';
import 'message_action_row.dart';
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
  final void Function(AcChatMessage) onReply;
  final void Function(String) onCopy;

  final bool isSenderChanged;
  final bool showTail;

  const MessageBubble({
    required this.message,
    required this.ct,
    required this.isDark,
    required this.isGroup,
    required this.onReply,
    required this.onCopy,
    this.isSenderChanged = false,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    final api = AcChatApiProvider.of(context);
    final isMe = message.senderId == api.getCurrentUser().userId;
    final type = message.type;
    final time = message.time;
    final status = message.status;

    return Dismissible(
      key: ValueKey(message.messageId),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        onReply(message);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(Icons.reply_rounded, color: ct.subText, size: 22),
      ),
      child: GestureDetector(
        onLongPress: () => _showBubbleMenu(context),
        onTap: () {
          // Let the caller intercept any tap first.
          if (api.onMessageTap != null) {
            api.onMessageTap!(message);
            return;
          }
          // Default: open media viewer for downloadable types.
          if (type == 'image' || type == 'video' || type == 'document') {
            if (!message.isDownloaded) return;
            final sender = api.getUserById(message.senderId);
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
        child: Align(
          alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                        // Sender name (group only, received)
                        if (isGroup && !isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              api.getUserById(message.senderId)?.name ??
                                  'Unknown',
                              style: TextStyle(
                                  color: avatarColor(message.senderId),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
  
                        // Reply preview
                        if (message.replyTo != null)
                          _ReplyPreview(
                              replyTo: message.replyTo!,
                              ct: ct),
  
                        // Message content
                        _buildContent(context, type, ct),
  
                        // Time + ticks
                        const SizedBox(height: 3),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  time.format('hh:mm a'),
                                  style: TextStyle(
                                      color: ct.subText.withOpacity(0.9),
                                      fontSize: 10),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 3),
                                  _TickIcon(status: status, ct: ct),
                                ],
                              ]),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
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
        // Try caller-provided custom builder first.
        final custom = AcChatApiProvider.of(context)
            .customMessageBuilder
            ?.call(context, message);
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

  void _showBubbleMenu(BuildContext context) {
    final text = message.text;
    showModalBottomSheet(
      context: context,
      backgroundColor: ct.chatBubbleMenuBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              color: ct.subText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 8),
        MessageActionRow(ct: ct, isDark: isDark, items: [
          MessageAction(icon: Icons.reply_rounded, label: 'Reply',
              onTap: () { Navigator.pop(context); onReply(message); }),
          MessageAction(icon: Icons.copy_rounded, label: 'Copy',
              onTap: () { Navigator.pop(context); onCopy(text); }),
          MessageAction(icon: Icons.forward_rounded, label: 'Forward',
              onTap: () { Navigator.pop(context); }),
          MessageAction(icon: Icons.star_border_rounded, label: 'Star',
              onTap: () { Navigator.pop(context); }),
          MessageAction(icon: Icons.delete_outline_rounded, label: 'Delete',
              color: ct.messageDestructive,
              onTap: () { Navigator.pop(context); }),
        ]),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _TickIcon extends StatelessWidget {
  final String status;
  final AcChatTheme ct;
  const _TickIcon({required this.status, required this.ct});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'read':
        return Icon(Icons.done_all_rounded,
            size: 14, color: ct.readTick);
      case 'delivered':
        return Icon(Icons.done_all_rounded,
            size: 14, color: ct.messageCheckIcon);
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
        border: Border(
            left: BorderSide(color: ct.unreadBadgeBg, width: 3)),
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
      final Size tailSize = const Size(14, 14);
      final Path tailPath = isMe
          ? RightTailPainter.getClipPath(tailSize)
          : LeftTailPainter.getClipPath(tailSize);

      final double tailY = size.height - 20;
      final double tailX = isMe ? size.width - 1 : -13;

      final Path shiftedTailPath = tailPath.shift(Offset(tailX, tailY));
      unifiedPath = Path.combine(PathOperation.union, unifiedPath, shiftedTailPath);
    }

    // Draw continuous shadow
    final double blurSigma = 3.0 * 0.57735 + 0.5;
    canvas.drawPath(
      unifiedPath.shift(const Offset(0, 1)),
      Paint()
        ..color = shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma),
    );

    // Draw bubble fill
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
      oldDelegate.color != color ||
          oldDelegate.shadowColor != shadowColor;
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

    if (shadowColor != null && false) {
      canvas.drawPath(
        path.shift(const Offset(0, 1)),
        Paint()
          ..color = shadowColor!
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
    );
  }

  @override
  bool shouldRepaint(covariant LeftTailPainter oldDelegate) =>
      oldDelegate.color != color ||
          oldDelegate.shadowColor != shadowColor;
}
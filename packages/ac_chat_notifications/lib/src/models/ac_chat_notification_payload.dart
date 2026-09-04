import 'package:ac_chat/ac_chat.dart';

/// Universal data payload representing a chat notification.
///
/// Designed to be serialized across push notifications (FCM, OneSignal, APNs)
/// as well as local foreground/background system notifications.
class AcChatNotificationPayload {
  final String notificationId;
  final String conversationId;
  final String messageId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String body;
  final bool isGroup;
  final String? conversationName;
  String? get groupName => conversationName;

  final int? badgeCount;
  final Map<String, dynamic> customData;
  final DateTime timestamp;

  AcChatNotificationPayload({
    required this.notificationId,
    required this.conversationId,
    required this.messageId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.body,
    this.isGroup = false,
    String? conversationName,
    String? groupName,
    this.badgeCount,
    this.customData = const {},
    required DateTime timestamp,
  })  : conversationName = conversationName ?? groupName,
        timestamp = timestamp.isUtc ? timestamp : timestamp.toUtc();

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'conversation_id': conversationId,
      'message_id': messageId,
      'sender_id': senderId,
      'sender_name': senderName,
      if (senderAvatar != null) 'sender_avatar': senderAvatar,
      'body': body,
      'is_group': isGroup,
      if (conversationName != null) ...{
        'conversation_name': conversationName,
        'group_name': conversationName,
      },
      if (badgeCount != null) 'badge_count': badgeCount,
      'custom_data': customData,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'timestamp_iso': formatUtcIso(timestamp),
    };
  }

  factory AcChatNotificationPayload.fromJson({required Map<String, dynamic> json}) {
    final rawTime = json['timestamp_iso'] ?? json['timestamp'];
    final parsedTime = parseUtc(rawTime);

    return AcChatNotificationPayload(
      notificationId: (json['notification_id'] as String?) ?? '',
      conversationId: (json['conversation_id'] as String?) ?? '',
      messageId: (json['message_id'] as String?) ?? '',
      senderId: (json['sender_id'] as String?) ?? '',
      senderName: (json['sender_name'] as String?) ?? 'New Message',
      senderAvatar: json['sender_avatar'] as String?,
      body: (json['body'] as String?) ?? '',
      isGroup: (json['is_group'] as bool?) ?? false,
      conversationName: (json['conversation_name'] ?? json['group_name']) as String?,
      badgeCount: json['badge_count'] as int?,
      customData: (json['custom_data'] as Map<String, dynamic>?) ?? {},
      timestamp: parsedTime,
    );
  }
}

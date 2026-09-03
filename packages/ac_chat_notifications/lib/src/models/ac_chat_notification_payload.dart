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
  final String? groupName;
  final int? badgeCount;
  final Map<String, dynamic> customData;
  final DateTime timestamp;

  const AcChatNotificationPayload({
    required this.notificationId,
    required this.conversationId,
    required this.messageId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.body,
    this.isGroup = false,
    this.groupName,
    this.badgeCount,
    this.customData = const {},
    required this.timestamp,
  });

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
      if (groupName != null) 'group_name': groupName,
      if (badgeCount != null) 'badge_count': badgeCount,
      'custom_data': customData,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory AcChatNotificationPayload.fromJson({required Map<String, dynamic> json}) {
    final rawTimestamp = json['timestamp'];
    DateTime parsedTime;
    if (rawTimestamp is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      parsedTime = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return AcChatNotificationPayload(
      notificationId: (json['notification_id'] as String?) ?? '',
      conversationId: (json['conversation_id'] as String?) ?? '',
      messageId: (json['message_id'] as String?) ?? '',
      senderId: (json['sender_id'] as String?) ?? '',
      senderName: (json['sender_name'] as String?) ?? 'New Message',
      senderAvatar: json['sender_avatar'] as String?,
      body: (json['body'] as String?) ?? '',
      isGroup: (json['is_group'] as bool?) ?? false,
      groupName: json['group_name'] as String?,
      badgeCount: json['badge_count'] as int?,
      customData: (json['custom_data'] as Map<String, dynamic>?) ?? {},
      timestamp: parsedTime,
    );
  }
}

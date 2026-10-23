import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

import '../../ac_chat_core.dart';

/// Represents shared conversation metadata across participants.
///
/// Contains shared metadata only (e.g. ID, type, name, last message).
/// User-specific state (unread count, pin status, mute status, role) is stored
/// in [AcChatConversationUser].
@AcReflectable()
class AcChatConversation {
  @AcBindJsonProperty(key: 'conversation_id')
  String conversationId = '';

  /// Conversation type: 'direct', 'group', 'channel', etc.
  String type = 'direct';

  @AcBindJsonProperty(key: 'conversation_name')
  String? conversationName;

  @AcBindJsonProperty(key: 'conversation_avatar')
  String? conversationAvatar;

  @AcBindJsonProperty(key: 'conversation_description')
  String? conversationDescription;

  /// User ID of the creator.
  @AcBindJsonProperty(key: 'created_by')
  String? createdBy;

  @AcBindJsonProperty(key: 'created_at')
  DateTime createdAt = DateTime.now();

  @AcBindJsonProperty(key: 'last_message')
  String lastMessage = '';

  /// Type of the latest message ('text', 'image', 'system', etc.).
  String lastMessageType = 'text';

  @AcBindJsonProperty(key: 'last_time')
  DateTime lastTime = DateTime.now().toUtc();

  @AcBindJsonProperty(key: 'user_ids')
  List<String> userIds = [];

  @AcBindJsonProperty(key: 'disappearing_duration_seconds')
  int? disappearingDurationSeconds;

  // ── View-Layer Convenience Properties (Populated from User Prefs) ─────────
  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  int unread = 0;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  bool isPinned = false;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  bool isMuted = false;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  bool isArchived = false;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  bool isHidden = false;

  @AcBindJsonProperty(skipInFromJson:true,skipInToJson:true)
  AcChatConversationUser? otherUser;

  AcChatConversation();

  factory AcChatConversation.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatConversation();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatConversation fromJson({required Map<String, dynamic> jsonData}) {
    conversationId = AcJsonUtils.deserializeValue<String>(
      jsonData['conversation_id'] ?? jsonData['conversationId'],
      defaultValue: conversationId,
    )!;
    type = AcJsonUtils.deserializeValue<String>(
      jsonData['type'],
      defaultValue: type,
    )!;
    conversationName = AcJsonUtils.deserializeValue<String>(
      jsonData['conversation_name'] ?? jsonData['conversationName'],
      defaultValue: conversationName,
    );
    conversationAvatar = AcJsonUtils.deserializeValue<String>(
      jsonData['conversation_avatar'] ?? jsonData['conversationAvatar'],
      defaultValue: conversationAvatar,
    );
    conversationDescription = AcJsonUtils.deserializeValue<String>(
      jsonData['conversation_description'] ?? jsonData['conversationDescription'],
      defaultValue: conversationDescription,
    );
    createdBy = AcJsonUtils.deserializeValue<String>(
      jsonData['created_by'] ?? jsonData['createdBy'],
      defaultValue: createdBy,
    );
    createdAt = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['created_at'] ?? jsonData['createdAt'],
      defaultValue: createdAt,
    )!;
    lastMessage = AcJsonUtils.deserializeValue<String>(
      jsonData['last_message'] ?? jsonData['lastMessage'],
      defaultValue: lastMessage,
    )!;
    lastMessageType = AcJsonUtils.deserializeValue<String>(
      jsonData['last_message_type'] ?? jsonData['lastMessageType'],
      defaultValue: lastMessageType,
    )!;
    lastTime = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['last_time'] ?? jsonData['lastTime'],
      defaultValue: lastTime,
    )!;
    userIds = AcJsonUtils.deserializeList<String>(
      jsonData['user_ids'] ?? jsonData['userIds'],
    );
    disappearingDurationSeconds = AcJsonUtils.deserializeValue<int>(
      jsonData['disappearing_duration_seconds'] ?? jsonData['disappearingDurationSeconds'],
      defaultValue: disappearingDurationSeconds,
    );
    unread = AcJsonUtils.deserializeValue<int>(
      jsonData['unread'],
      defaultValue: unread,
    )!;
    isPinned = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_pinned'] ?? jsonData['isPinned'],
      defaultValue: isPinned,
    )!;
    isMuted = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_muted'] ?? jsonData['isMuted'],
      defaultValue: isMuted,
    )!;
    isArchived = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_archived'] ?? jsonData['isArchived'],
      defaultValue: isArchived,
    )!;
    isHidden = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_hidden'] ?? jsonData['isHidden'],
      defaultValue: isHidden,
    )!;

    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId.isNotEmpty ? conversationId : null,
      'type': type,
      'conversation_name': conversationName,
      'conversation_avatar': conversationAvatar,
      'conversation_description': conversationDescription,
      'created_by': createdBy,
      'created_at': AcJsonUtils.serializeValue(createdAt),
      'last_message': lastMessage,
      'last_message_type': lastMessageType,
      'lastMessageType': lastMessageType,
      'last_time': AcJsonUtils.serializeValue(lastTime),
      'user_ids': AcJsonUtils.serializeValue(userIds),
      'disappearing_duration_seconds': disappearingDurationSeconds,
    };
  }
}

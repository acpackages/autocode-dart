import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

import '../../ac_chat_core.dart';

/// Represents user-specific conversation state and preferences.
///
/// Stores unread count, pin/mute/archive status, member roles, and read positions
/// for a specific user within a specific conversation.
@AcReflectable()
class AcChatConversationUser {
  @AcBindJsonProperty(key: 'conversation_id')
  String conversationId = '';
  @AcBindJsonProperty(key: 'user_id')
  String userId = '';
  @AcBindJsonProperty(key: 'unread_count')
  int unreadCount = 0;
  @AcBindJsonProperty(key: 'is_pinned')
  bool isPinned = false;
  @AcBindJsonProperty(key: 'is_muted')
  bool isMuted = false;
  @AcBindJsonProperty(key: 'mute_until')
  DateTime? muteUntil;
  @AcBindJsonProperty(key: 'is_archived')
  bool isArchived = false;
  @AcBindJsonProperty(key: 'is_hidden')
  bool isHidden = false;

  /// User role in this conversation: 'owner', 'admin', 'member'.
  String role = 'member';

  @AcBindJsonProperty(key: 'last_read_message_id')
  String? lastReadMessageId;
  @AcBindJsonProperty(key: 'last_read_time')
  DateTime? lastReadTime;

  @AcBindJsonProperty(skipInFromJson:true,skipInToJson:true)
  AcChatUser? user;

  AcChatConversationUser();

  factory AcChatConversationUser.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatConversationUser();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatConversationUser fromJson({required Map<String, dynamic> jsonData}) {
    conversationId = AcJsonUtils.deserializeValue<String>(
      jsonData['conversation_id'] ?? jsonData['conversationId'],
      defaultValue: conversationId,
    )!;
    userId = AcJsonUtils.deserializeValue<String>(
      jsonData['user_id'] ?? jsonData['userId'],
      defaultValue: userId,
    )!;
    unreadCount = AcJsonUtils.deserializeValue<int>(
      jsonData['unread_count'] ?? jsonData['unreadCount'],
      defaultValue: unreadCount,
    )!;
    isPinned = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_pinned'] ?? jsonData['isPinned'],
      defaultValue: isPinned,
    )!;
    isMuted = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_muted'] ?? jsonData['isMuted'],
      defaultValue: isMuted,
    )!;
    muteUntil = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['mute_until'] ?? jsonData['muteUntil'],
      defaultValue: muteUntil,
    );
    isArchived = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_archived'] ?? jsonData['isArchived'],
      defaultValue: isArchived,
    )!;
    isHidden = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_hidden'] ?? jsonData['isHidden'],
      defaultValue: isHidden,
    )!;
    role = AcJsonUtils.deserializeValue<String>(
      jsonData['role'],
      defaultValue: role,
    )!;
    lastReadMessageId = AcJsonUtils.deserializeValue<String>(
      jsonData['last_read_message_id'] ?? jsonData['lastReadMessageId'],
      defaultValue: lastReadMessageId,
    );
    lastReadTime = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['last_read_time'] ?? jsonData['lastReadTime'],
      defaultValue: lastReadTime,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'user_id': userId,
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'is_muted': isMuted,
      'mute_until': AcJsonUtils.serializeValue(muteUntil),
      'is_archived': isArchived,
      'is_hidden': isHidden,
      'role': role,
      'last_read_message_id': lastReadMessageId,
      'last_read_time': AcJsonUtils.serializeValue(lastReadTime),
    };
  }
}

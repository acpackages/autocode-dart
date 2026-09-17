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
    final json = Map<String, dynamic>.from(jsonData);

    if (json.containsKey('is_pinned')) {
      isPinned = json['is_pinned'] == true || json['is_pinned'] == 1;
      json.remove('is_pinned');
    }
    if (json.containsKey('is_muted')) {
      isMuted = json['is_muted'] == true || json['is_muted'] == 1;
      json.remove('is_muted');
    }
    if (json.containsKey('is_archived')) {
      isArchived = json['is_archived'] == true || json['is_archived'] == 1;
      json.remove('is_archived');
    }
    if (json.containsKey('is_hidden')) {
      isHidden = json['is_hidden'] == true || json['is_hidden'] == 1;
      json.remove('is_hidden');
    }
    if (json.containsKey('role')) {
      role = (json['role'] ?? 'member').toString();
      json.remove('role');
    }

    try {
      AcJsonUtils.setInstancePropertiesFromJsonData(
        instance: this,
        jsonData: json,
      );
    } catch (_) {}
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }
}

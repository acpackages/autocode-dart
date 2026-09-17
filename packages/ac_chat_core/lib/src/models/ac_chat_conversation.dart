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

    try {
      AcJsonUtils.setInstancePropertiesFromJsonData(
        instance: this,
        jsonData: json,
      );
    } catch (_) {}
    return this;
  }

  Map<String, dynamic> toJson() {
    final result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if(conversationId.isEmpty){
      result['conversation_id'] = null;
    }
    return result;
  }
}

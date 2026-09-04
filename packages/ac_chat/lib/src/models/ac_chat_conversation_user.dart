import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';
import '../common/utc_utils.dart';

/// Represents user-specific conversation state and preferences.
///
/// Stores unread count, pin/mute/archive status, member roles, and read positions
/// for a specific user within a specific conversation.
@AcReflectable()
class AcChatConversationUser {
  String conversationId = '';
  String userId = '';
  int unreadCount = 0;
  bool isPinned = false;
  bool isMuted = false;
  DateTime? muteUntilUtc;
  bool isArchived = false;
  bool isHidden = false;

  /// User role in this conversation: 'owner', 'admin', 'member'.
  String role = 'member';

  String? lastReadMessageId;
  DateTime? lastReadTimeUtc;

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

    if (json.containsKey('conversationId')) {
      conversationId = json['conversationId']?.toString() ?? '';
      json.remove('conversationId');
    }
    if (json.containsKey('userId')) {
      userId = json['userId']?.toString() ?? '';
      json.remove('userId');
    }
    if (json.containsKey('unreadCount')) {
      unreadCount = int.tryParse(json['unreadCount'].toString()) ?? 0;
      json.remove('unreadCount');
    } else if (json.containsKey('unread')) {
      unreadCount = int.tryParse(json['unread'].toString()) ?? 0;
      json.remove('unread');
    }
    if (json.containsKey('isPinned')) {
      isPinned = json['isPinned'] == true || json['isPinned'] == 1;
      json.remove('isPinned');
    }
    if (json.containsKey('isMuted')) {
      isMuted = json['isMuted'] == true || json['isMuted'] == 1;
      json.remove('isMuted');
    }
    if (json.containsKey('muteUntilUtc') || json.containsKey('muteUntil')) {
      final raw = json['muteUntilUtc'] ?? json['muteUntil'];
      if (raw != null) muteUntilUtc = parseUtc(raw);
      json.remove('muteUntilUtc');
      json.remove('muteUntil');
    }
    if (json.containsKey('isArchived')) {
      isArchived = json['isArchived'] == true || json['isArchived'] == 1;
      json.remove('isArchived');
    }
    if (json.containsKey('isHidden')) {
      isHidden = json['isHidden'] == true || json['isHidden'] == 1;
      json.remove('isHidden');
    }
    if (json.containsKey('role')) {
      role = (json['role'] ?? 'member').toString();
      json.remove('role');
    }
    if (json.containsKey('lastReadMessageId')) {
      lastReadMessageId = json['lastReadMessageId']?.toString();
      json.remove('lastReadMessageId');
    }
    if (json.containsKey('lastReadTimeUtc') || json.containsKey('lastReadTime')) {
      final raw = json['lastReadTimeUtc'] ?? json['lastReadTime'];
      if (raw != null) lastReadTimeUtc = parseUtc(raw);
      json.remove('lastReadTimeUtc');
      json.remove('lastReadTime');
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
    final result = <String, dynamic>{
      'conversationId': conversationId,
      'userId': userId,
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'isHidden': isHidden,
      'role': role,
    };
    if (muteUntilUtc != null) {
      result['muteUntilUtc'] = formatUtcIso(muteUntilUtc!);
    }
    if (lastReadMessageId != null) {
      result['lastReadMessageId'] = lastReadMessageId;
    }
    if (lastReadTimeUtc != null) {
      result['lastReadTimeUtc'] = formatUtcIso(lastReadTimeUtc!);
    }
    return result;
  }
}

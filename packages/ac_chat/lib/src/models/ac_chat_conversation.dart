import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';
import '../common/utc_utils.dart';

/// Represents shared conversation metadata across participants.
///
/// Contains shared metadata only (e.g. ID, type, name, last message).
/// User-specific state (unread count, pin status, mute status, role) is stored
/// in [AcChatConversationUser].
@AcReflectable()
class AcChatConversation {
  String conversationId = '';

  /// Conversation type: 'direct', 'group', 'channel', etc.
  String type = 'direct';

  /// Agnostic name for the conversation (replaces groupName).
  String? conversationName;

  /// Agnostic avatar URL/path for the conversation.
  String? conversationAvatar;

  /// Agnostic description for the conversation.
  String? conversationDescription;

  /// User ID of the creator.
  String? createdBy;

  /// UTC creation timestamp.
  DateTime createdAtUtc = DateTime.now().toUtc();

  /// Snippet of the latest message.
  String lastMessage = '';

  /// Type of the latest message ('text', 'image', 'system', etc.).
  String lastMessageType = 'text';

  /// UTC timestamp of the latest message or update.
  DateTime lastTimeUtc = DateTime.now().toUtc();

  /// Participant user IDs.
  List<String> memberIds = [];

  // ── Backward-compatible Aliases ───────────────────────────────────────────

  String? get groupName => conversationName;
  set groupName(String? v) => conversationName = v;

  String? get groupAvatar => conversationAvatar;
  set groupAvatar(String? v) => conversationAvatar = v;

  String? get groupDescription => conversationDescription;
  set groupDescription(String? v) => conversationDescription = v;

  DateTime get lastTime => lastTimeUtc;
  set lastTime(DateTime v) => lastTimeUtc = v.isUtc ? v : v.toUtc();

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

    if (json.containsKey('conversationId') || json.containsKey('id')) {
      conversationId = (json['conversationId'] ?? json['id'] ?? '').toString();
      json.remove('conversationId');
      json.remove('id');
    }

    if (json.containsKey('type')) {
      type = (json['type'] ?? 'direct').toString();
      json.remove('type');
    } else if (json.containsKey('isGroup')) {
      type = (json['isGroup'] == true) ? 'group' : 'direct';
      json.remove('isGroup');
    }

    if (json.containsKey('conversationName') || json.containsKey('groupName')) {
      conversationName = (json['conversationName'] ?? json['groupName']) as String?;
      json.remove('conversationName');
      json.remove('groupName');
    }

    if (json.containsKey('conversationAvatar') || json.containsKey('groupAvatar')) {
      conversationAvatar = (json['conversationAvatar'] ?? json['groupAvatar']) as String?;
      json.remove('conversationAvatar');
      json.remove('groupAvatar');
    }

    if (json.containsKey('conversationDescription') || json.containsKey('groupDescription')) {
      conversationDescription = (json['conversationDescription'] ?? json['groupDescription']) as String?;
      json.remove('conversationDescription');
      json.remove('groupDescription');
    }

    if (json.containsKey('createdBy')) {
      createdBy = json['createdBy'] as String?;
      json.remove('createdBy');
    }

    if (json.containsKey('createdAtUtc') || json.containsKey('createdAt')) {
      final raw = json['createdAtUtc'] ?? json['createdAt'];
      if (raw != null) createdAtUtc = parseUtc(raw);
      json.remove('createdAtUtc');
      json.remove('createdAt');
    }

    if (json.containsKey('lastMessage')) {
      lastMessage = (json['lastMessage'] ?? '').toString();
      json.remove('lastMessage');
    }

    if (json.containsKey('lastMessageType')) {
      lastMessageType = (json['lastMessageType'] ?? 'text').toString();
      json.remove('lastMessageType');
    }

    if (json.containsKey('lastTimeUtc') || json.containsKey('lastTime')) {
      final raw = json['lastTimeUtc'] ?? json['lastTime'];
      if (raw != null) lastTimeUtc = parseUtc(raw);
      json.remove('lastTimeUtc');
      json.remove('lastTime');
    }

    if (json.containsKey('memberIds') && json['memberIds'] != null) {
      memberIds = List<String>.from((json['memberIds'] as List).map((x) => x.toString()));
      json.remove('memberIds');
    }

    // View-layer convenience mappings if provided in snapshot
    if (json.containsKey('unread')) {
      unread = int.tryParse(json['unread'].toString()) ?? 0;
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
    if (json.containsKey('isArchived')) {
      isArchived = json['isArchived'] == true || json['isArchived'] == 1;
      json.remove('isArchived');
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
      'type': type,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastTimeUtc': formatUtcIso(lastTimeUtc),
      'createdAtUtc': formatUtcIso(createdAtUtc),
      'memberIds': memberIds,
    };
    if (conversationName != null) {
      result['conversationName'] = conversationName;
      // Backward-compatible mirror for transports expecting groupName
      result['groupName'] = conversationName;
    }
    if (conversationAvatar != null) {
      result['conversationAvatar'] = conversationAvatar;
      result['groupAvatar'] = conversationAvatar;
    }
    if (conversationDescription != null) {
      result['conversationDescription'] = conversationDescription;
    }
    if (createdBy != null) {
      result['createdBy'] = createdBy;
    }
    return result;
  }
}

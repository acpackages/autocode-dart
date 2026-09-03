import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatConversation {
  @AcBindJsonProperty(key: 'id')
  String conversationId = '';

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  String type = 'direct';

  String? groupName;
  String? groupAvatar;
  List<String> memberIds = [];
  String lastMessage = '';
  String lastMessageType = 'text';
  DateTime lastTime = DateTime.now();
  int unread = 0;
  bool isPinned = false;
  bool isMuted = false;

  AcChatConversation();

  factory AcChatConversation.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatConversation();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatConversation fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey("memberIds") && json["memberIds"] != null) {
      memberIds = List<String>.from(json['memberIds'].map((x) => x.toString()));
      json.remove("memberIds");
    }
    if (json['lastTime'] is String) {
      lastTime = DateTime.parse(json['lastTime']);
      json.remove('lastTime');
    } else if (json['lastTime'] is DateTime) {
      lastTime = json['lastTime'];
      json.remove('lastTime');
    } else if (json['lastTime'] is int) {
      lastTime = DateTime.fromMillisecondsSinceEpoch(json['lastTime']);
      json.remove('lastTime');
    }
    if (json.containsKey('isGroup')) {
      type = (json['isGroup'] == true) ? 'group' : 'direct';
      json.remove('isGroup');
    }
    if (json.containsKey('userId')) {
      json.remove('userId');
    }
    if (json.containsKey('conversationId') || json.containsKey('id')) {
      conversationId = (json['conversationId'] ?? json['id'] ?? '').toString();
    }
    if (json.containsKey('type')) type = (json['type'] ?? 'direct').toString();
    if (json.containsKey('groupName')) groupName = json['groupName'] as String?;
    if (json.containsKey('groupAvatar')) groupAvatar = json['groupAvatar'] as String?;
    if (json.containsKey('lastMessage')) lastMessage = (json['lastMessage'] ?? '').toString();
    if (json.containsKey('lastMessageType')) lastMessageType = (json['lastMessageType'] ?? 'text').toString();
    if (json.containsKey('unread')) unread = int.tryParse(json['unread'].toString()) ?? 0;
    if (json.containsKey('isPinned')) isPinned = json['isPinned'] == true || json['isPinned'] == 1;
    if (json.containsKey('isMuted')) isMuted = json['isMuted'] == true || json['isMuted'] == 1;

    try {
      AcJsonUtils.setInstancePropertiesFromJsonData(
        instance: this,
        jsonData: json,
      );
    } catch (_) {}
    return this;
  }

  Map<String, dynamic> toJson() {
    var result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    result['id'] = conversationId;
    result['conversationId'] = conversationId;
    result['type'] = type;
    if (groupName != null) {
      result['groupName'] = groupName;
    }
    result['memberIds'] = memberIds;
    result['lastTime'] = lastTime.toIso8601String();
    result['isGroup'] = (type == 'group');
    if (groupAvatar != null) {
      result['groupAvatar'] = groupAvatar;
    }
    return result;
  }
}

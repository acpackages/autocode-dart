import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatConversation {
  @AcBindJsonProperty(key: 'id')
  String conversationId = '';

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  String type = 'direct';

  String? groupName;
  List<String> memberIds = [];
  String lastMessage = '';
  String lastMessageType = '';
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
    }
    if (json.containsKey('isGroup')) {
      type = (json['isGroup'] == true) ? 'group' : 'direct';
      json.remove('isGroup');
    }
    if (json.containsKey('userId')) {
      json.remove('userId');
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    result['memberIds'] = memberIds;
    result['lastTime'] = lastTime;
    result['isGroup'] = (type == 'group');
    return result;
  }
}

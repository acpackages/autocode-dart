import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatConversationUser {
  String conversationId = '';
  String userId = '';

  AcChatConversationUser();

  factory AcChatConversationUser.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatConversationUser();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatConversationUser fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }
}

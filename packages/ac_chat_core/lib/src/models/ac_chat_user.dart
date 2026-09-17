import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatUser {
  @AcBindJsonProperty(key: 'user_id')
  String userId = '';
  String name = '';
  String username = '';
  String email = '';
  String? phone;
  String? avatar;
  String? bio;
  @AcBindJsonProperty(key: 'last_seen')
  DateTime? lastSeen;
  @AcBindJsonProperty(key: 'is_online')
  bool isOnline = false;

  AcChatUser();

  factory AcChatUser.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatUser();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatUser fromJson({required Map<String, dynamic> jsonData}) {
    final json = Map<String, dynamic>.from(jsonData);
    if (json.containsKey('is_online')) {
      isOnline = json['is_online'] == true || json['is_online'] == 1;
      json.remove('is_online');
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
    Map<String, dynamic> result = {};
    try {
      result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    } catch (_) {}
    if(userId.isEmpty){
      result['user_id'] = null;
    }
    return result;
  }
}

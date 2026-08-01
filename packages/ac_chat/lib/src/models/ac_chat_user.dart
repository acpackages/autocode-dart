import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatUser {
  @AcBindJsonProperty(key: 'id')
  String userId = '';

  String name = '';
  String username = '';
  String email = '';
  String? phone;
  String? avatar;

  AcChatUser();

  factory AcChatUser.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatUser();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatUser fromJson({required Map<String, dynamic> jsonData}) {
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

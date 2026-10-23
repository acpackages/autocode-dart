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
    userId = AcJsonUtils.deserializeValue<String>(
      jsonData['user_id'] ?? jsonData['userId'],
      defaultValue: userId,
    )!;
    name = AcJsonUtils.deserializeValue<String>(
      jsonData['name'],
      defaultValue: name,
    )!;
    username = AcJsonUtils.deserializeValue<String>(
      jsonData['username'],
      defaultValue: username,
    )!;
    email = AcJsonUtils.deserializeValue<String>(
      jsonData['email'],
      defaultValue: email,
    )!;
    phone = AcJsonUtils.deserializeValue<String>(
      jsonData['phone'],
      defaultValue: phone,
    );
    avatar = AcJsonUtils.deserializeValue<String>(
      jsonData['avatar'],
      defaultValue: avatar,
    );
    bio = AcJsonUtils.deserializeValue<String>(
      jsonData['bio'],
      defaultValue: bio,
    );
    lastSeen = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['last_seen'] ?? jsonData['lastSeen'],
      defaultValue: lastSeen,
    );
    isOnline = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_online'] ?? jsonData['isOnline'],
      defaultValue: isOnline,
    )!;

    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId.isNotEmpty ? userId : null,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'last_seen': AcJsonUtils.serializeValue(lastSeen),
      'is_online': isOnline,
    };
  }
}

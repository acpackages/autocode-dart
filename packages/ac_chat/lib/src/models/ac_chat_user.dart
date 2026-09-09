import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';
import '../common/utc_utils.dart';

@AcReflectable()
class AcChatUser {
  String userId = '';
  String name = '';
  String username = '';
  String email = '';
  String? phone;
  String? get phoneNumber => phone;
  set phoneNumber(String? v) => phone = v;
  String? avatar;
  String? bio;
  DateTime? lastSeenUtc;
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

    if (json.containsKey('userId') || json.containsKey('id')) {
      userId = (json['userId'] ?? json['id'] ?? '').toString();
      json.remove('id');
      json.remove('userId');
    }

    if (json.containsKey('name')) {
      name = (json['name'] ?? '').toString();
      json.remove('name');
    }

    if (json.containsKey('username')) {
      username = (json['username'] ?? '').toString();
      json.remove('username');
    }

    if (json.containsKey('email')) {
      email = (json['email'] ?? '').toString();
      json.remove('email');
    }

    if (json.containsKey('phone') || json.containsKey('phoneNumber')) {
      phone = (json['phone'] ?? json['phoneNumber'])?.toString();
      json.remove('phone');
      json.remove('phoneNumber');
    }

    if (json.containsKey('avatar')) {
      avatar = json['avatar']?.toString();
      json.remove('avatar');
    }

    if (json.containsKey('bio')) {
      bio = json['bio']?.toString();
      json.remove('bio');
    }

    if (json.containsKey('isOnline')) {
      isOnline = json['isOnline'] == true || json['isOnline'] == 1;
      json.remove('isOnline');
    }

    if (json.containsKey('lastSeenUtc') || json.containsKey('lastSeen')) {
      final raw = json['lastSeenUtc'] ?? json['lastSeen'];
      if (raw != null) {
        lastSeenUtc = parseUtc(raw);
      }
      json.remove('lastSeenUtc');
      json.remove('lastSeen');
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
      'userId': userId,
      'name': name,
      'username': username,
      'email': email,
      'isOnline': isOnline,
    };
    if (phone != null) result['phone'] = phone;
    if (avatar != null) result['avatar'] = avatar;
    if (bio != null) result['bio'] = bio;
    if (lastSeenUtc != null) {
      result['lastSeenUtc'] = formatUtcIso(lastSeenUtc!);
    }
    return result;
  }
}

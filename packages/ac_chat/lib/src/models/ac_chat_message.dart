import 'dart:typed_data';
import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatMessage {
  @AcBindJsonProperty(key: 'id')
  String messageId = '';

  @AcBindJsonProperty(key: 'chatId')
  String conversationId = '';

  String senderId = '';
  String type = 'text';
  String text = '';
  DateTime time = DateTime.now();
  String status = 'sent';
  String? mediaCaption;
  double? amount;
  String? paymentNote;
  String? duration;
  String? fileName;
  String? fileSize;

  bool isDownloaded = false;
  String? localPath;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  Uint8List? byteData;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  AcChatMessage? replyTo;

  AcChatMessage();

  factory AcChatMessage.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcChatMessage();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcChatMessage fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json['time'] is String) {
      time = DateTime.parse(json['time']);
      json.remove('time');
    } else if (json['time'] is DateTime) {
      time = json['time'];
      json.remove('time');
    }
    if (json.containsKey('amount') && json['amount'] != null) {
      amount = (json['amount'] as num).toDouble();
      json.remove('amount');
    }
    if (json.containsKey('replyTo') && json['replyTo'] != null) {
      if (json['replyTo'] is Map<String, dynamic>) {
        replyTo = AcChatMessage.instanceFromJson(jsonData: json['replyTo']);
      } else if (json['replyTo'] is AcChatMessage) {
        replyTo = json['replyTo'];
      }
      json.remove('replyTo');
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    result['time'] = time;
    if (amount != null) {
      result['amount'] = amount;
    }
    if (replyTo != null) {
      result['replyTo'] = replyTo!.toJson();
    }
    return result;
  }
}

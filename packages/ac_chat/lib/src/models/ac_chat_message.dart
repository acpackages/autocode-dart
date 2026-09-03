import 'dart:convert';
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

  /// Message status: 'sending', 'sent', 'delivered', 'read', 'failed'
  String status = 'sending';

  DateTime? deliveredTime;
  DateTime? readTime;

  bool isEdited = false;
  DateTime? editedTime;

  bool isDeleted = false;

  Map<String, List<String>> reactions = {};

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
    } else if (json['time'] is int) {
      time = DateTime.fromMillisecondsSinceEpoch(json['time']);
      json.remove('time');
    }

    if (json['deliveredTime'] is int) {
      deliveredTime = DateTime.fromMillisecondsSinceEpoch(json['deliveredTime']);
      json.remove('deliveredTime');
    }
    if (json['readTime'] is int) {
      readTime = DateTime.fromMillisecondsSinceEpoch(json['readTime']);
      json.remove('readTime');
    }
    if (json['editedTime'] is int) {
      editedTime = DateTime.fromMillisecondsSinceEpoch(json['editedTime']);
      json.remove('editedTime');
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

    if (json.containsKey('reactions') && json['reactions'] != null) {
      if (json['reactions'] is Map) {
        final rawMap = json['reactions'] as Map;
        reactions = rawMap.map(
          (k, v) => MapEntry(
            k.toString(),
            (v as List).map((e) => e.toString()).toList(),
          ),
        );
      } else if (json['reactions'] is String && (json['reactions'] as String).isNotEmpty) {
        try {
          final decoded = jsonDecode(json['reactions'] as String) as Map;
          reactions = decoded.map(
            (k, v) => MapEntry(
              k.toString(),
              (v as List).map((e) => e.toString()).toList(),
            ),
          );
        } catch (_) {}
      }
      json.remove('reactions');
    }

    if (json.containsKey('messageId') || json.containsKey('id')) {
      messageId = (json['messageId'] ?? json['id'] ?? '').toString();
    }
    if (json.containsKey('conversationId') || json.containsKey('chatId')) {
      conversationId = (json['conversationId'] ?? json['chatId'] ?? '').toString();
    }
    if (json.containsKey('senderId')) senderId = (json['senderId'] ?? '').toString();
    if (json.containsKey('type')) type = (json['type'] ?? 'text').toString();
    if (json.containsKey('text')) text = (json['text'] ?? '').toString();
    if (json.containsKey('status')) status = (json['status'] ?? 'sending').toString();
    if (json.containsKey('mediaCaption')) mediaCaption = json['mediaCaption'] as String?;
    if (json.containsKey('paymentNote')) paymentNote = json['paymentNote'] as String?;
    if (json.containsKey('duration')) duration = json['duration'] as String?;
    if (json.containsKey('fileName')) fileName = json['fileName'] as String?;
    if (json.containsKey('fileSize')) fileSize = json['fileSize'] as String?;
    if (json.containsKey('localPath')) localPath = json['localPath'] as String?;
    if (json.containsKey('isDownloaded')) isDownloaded = json['isDownloaded'] == true || json['isDownloaded'] == 1;
    if (json.containsKey('isEdited')) isEdited = json['isEdited'] == true || json['isEdited'] == 1;
    if (json.containsKey('isDeleted')) isDeleted = json['isDeleted'] == true || json['isDeleted'] == 1;

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
    result['id'] = messageId;
    result['messageId'] = messageId;
    result['chatId'] = conversationId;
    result['conversationId'] = conversationId;
    result['senderId'] = senderId;
    result['type'] = type;
    result['text'] = text;
    result['status'] = status;
    result['time'] = time.toIso8601String();
    if (deliveredTime != null) {
      result['deliveredTime'] = deliveredTime!.millisecondsSinceEpoch;
    }
    if (readTime != null) {
      result['readTime'] = readTime!.millisecondsSinceEpoch;
    }
    if (editedTime != null) {
      result['editedTime'] = editedTime!.millisecondsSinceEpoch;
    }
    result['isEdited'] = isEdited;
    result['isDeleted'] = isDeleted;
    if (reactions.isNotEmpty) {
      result['reactions'] = reactions;
    }
    if (amount != null) {
      result['amount'] = amount;
    }
    if (replyTo != null) {
      result['replyTo'] = replyTo!.toJson();
    }
    return result;
  }
}

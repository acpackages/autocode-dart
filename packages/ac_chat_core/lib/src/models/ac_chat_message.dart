import 'dart:convert';
import 'dart:typed_data';
import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcChatMessage {
  @AcBindJsonProperty(key:'message_id')
  String messageId = '';
  @AcBindJsonProperty(key:'conversation_id')
  String conversationId = '';
  @AcBindJsonProperty(key:'sender_id')
  String senderId = '';

  /// Message type: 'text', 'image', 'video', 'audio', 'voice_note',
  /// 'document', 'location', 'contact', 'system'.
  String type = 'text';

  String text = '';

  /// Canonical UTC creation timestamp.
  DateTime time = DateTime.now().toUtc();

  /// Message status: 'sending', 'sent', 'delivered', 'read', 'failed'.
  String status = 'sending';

  @AcBindJsonProperty(key:'delivered_time')
  DateTime? deliveredTime;
  @AcBindJsonProperty(key:'read_time')
  DateTime? readTime;

  @AcBindJsonProperty(key:'is_edited')
  bool isEdited = false;
  @AcBindJsonProperty(key:'edited_time')
  DateTime? editedTime;

  @AcBindJsonProperty(key:'is_deleted')
  bool isDeleted = false;
  @AcBindJsonProperty(key:'is_starred')
  bool isStarred = false;

  /// Reactions mapped by emoji -> list of userIds who reacted.
  Map<String, List<String>> reactions = {};

  /// User IDs mentioned in this message.
  List<String> mentions = [];

  // Media / Metadata
  @AcBindJsonProperty(key:'media_caption')
  String? mediaCaption;
  @AcBindJsonProperty(key:'media_duration')
  String? duration;
  @AcBindJsonProperty(key:'file_name')
  String? fileName;
  @AcBindJsonProperty(key:'file_size')
  String? fileSize;

  @AcBindJsonProperty(key:'is_downloaded')
  bool isDownloaded = false;

  @AcBindJsonProperty(key:'local_path')
  String? localPath;
  @AcBindJsonProperty(key:'file_url')
  String? fileUrl;

  /// Optional expiration timestamp for disappearing messages (UTC).
  @AcBindJsonProperty(key:'expires_at')
  DateTime? expiresAt;

  /// Optional scheduled delivery timestamp (UTC).
  @AcBindJsonProperty(key:'scheduled_time')
  DateTime? scheduledTime;

  /// Optional pin expiration timestamp (UTC).
  @AcBindJsonProperty(key:'pinned_until')
  DateTime? pinnedUntil;

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
    final json = Map<String, dynamic>.from(jsonData);
    if (json.containsKey('is_edited')) {
      isEdited = json['is_edited'] == true || json['is_edited'] == 1;
      json.remove('is_edited');
    }

    if (json.containsKey('is_deleted')) {
      isDeleted = json['is_deleted'] == true || json['is_deleted'] == 1;
      json.remove('is_deleted');
    }

    if (json.containsKey('is_starred')) {
      isStarred = json['is_starred'] == true || json['is_starred'] == 1;
      json.remove('is_starred');
    }

    if (json.containsKey('is_downloaded')) {
      isDownloaded = json['is_downloaded'] == true || json['is_downloaded'] == 1;
      json.remove('is_downloaded');
    } else if (json.containsKey('isDownloaded')) {
      isDownloaded = json['isDownloaded'] == true || json['isDownloaded'] == 1;
      json.remove('isDownloaded');
    }

    if (json.containsKey('local_path')) {
      localPath = json['local_path'] as String?;
      json.remove('local_path');
    } else if (json.containsKey('localPath')) {
      localPath = json['localPath'] as String?;
      json.remove('localPath');
    }

    if (json.containsKey('file_url')) {
      fileUrl = json['file_url'] as String?;
      json.remove('file_url');
    } else if (json.containsKey('fileUrl')) {
      fileUrl = json['fileUrl'] as String?;
      json.remove('fileUrl');
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

    if (json.containsKey('mentions') && json['mentions'] != null) {
      if (json['mentions'] is List) {
        mentions = (json['mentions'] as List).map((e) => e.toString()).toList();
      }
      json.remove('mentions');
    }


    if (json.containsKey('reply_to') && json['reply_to'] != null) {
      if (json['reply_to'] is Map<String, dynamic>) {
        replyTo = AcChatMessage.instanceFromJson(jsonData: json['reply_to']);
      } else if (json['reply_to'] is AcChatMessage) {
        replyTo = json['reply_to'];
      }
      json.remove('reply_to');
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
    final result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if(messageId.isEmpty){
      result['message_id'] = null;
    }
    if (localPath != null) {
      result['local_path'] = localPath;
      result['localPath'] = localPath;
    }
    if (fileUrl != null) {
      result['file_url'] = fileUrl;
      result['fileUrl'] = fileUrl;
    }
    return result;
  }

  AcChatMessage clone() {
    final copy = AcChatMessage()
      ..messageId = messageId
      ..conversationId = conversationId
      ..senderId = senderId
      ..type = type
      ..text = text
      ..time = time
      ..status = status
      ..deliveredTime = deliveredTime
      ..readTime = readTime
      ..isEdited = isEdited
      ..editedTime = editedTime
      ..isDeleted = isDeleted
      ..isStarred = isStarred
      ..reactions = Map<String, List<String>>.from(
        reactions.map((k, v) => MapEntry(k, List<String>.from(v))),
      )
      ..mentions = List<String>.from(mentions)
      ..mediaCaption = mediaCaption
      ..duration = duration
      ..fileName = fileName
      ..fileSize = fileSize
      ..isDownloaded = isDownloaded
      ..localPath = localPath
      ..fileUrl = fileUrl
      ..expiresAt = expiresAt
      ..scheduledTime = scheduledTime
      ..pinnedUntil = pinnedUntil
      ..byteData = byteData != null ? Uint8List.fromList(byteData!) : null
      ..replyTo = replyTo?.clone();
    return copy;
  }
}

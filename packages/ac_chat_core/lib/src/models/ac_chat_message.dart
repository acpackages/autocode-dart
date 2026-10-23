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
    messageId = AcJsonUtils.deserializeValue<String>(
      jsonData['message_id'] ?? jsonData['messageId'],
      defaultValue: messageId,
    )!;
    conversationId = AcJsonUtils.deserializeValue<String>(
      jsonData['conversation_id'] ?? jsonData['conversationId'],
      defaultValue: conversationId,
    )!;
    senderId = AcJsonUtils.deserializeValue<String>(
      jsonData['sender_id'] ?? jsonData['senderId'],
      defaultValue: senderId,
    )!;
    type = AcJsonUtils.deserializeValue<String>(
      jsonData['type'],
      defaultValue: type,
    )!;
    text = AcJsonUtils.deserializeValue<String>(
      jsonData['text'],
      defaultValue: text,
    )!;
    status = AcJsonUtils.deserializeValue<String>(
      jsonData['status'],
      defaultValue: status,
    )!;
    time = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['time'],
      defaultValue: time,
    )!;
    deliveredTime = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['delivered_time'] ?? jsonData['deliveredTime'],
      defaultValue: deliveredTime,
    );
    readTime = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['read_time'] ?? jsonData['readTime'],
      defaultValue: readTime,
    );
    editedTime = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['edited_time'] ?? jsonData['editedTime'],
      defaultValue: editedTime,
    );
    isEdited = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_edited'] ?? jsonData['isEdited'],
      defaultValue: isEdited,
    )!;
    isDeleted = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_deleted'] ?? jsonData['isDeleted'],
      defaultValue: isDeleted,
    )!;
    isStarred = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_starred'] ?? jsonData['isStarred'],
      defaultValue: isStarred,
    )!;
    isDownloaded = AcJsonUtils.deserializeValue<bool>(
      jsonData['is_downloaded'] ?? jsonData['isDownloaded'],
      defaultValue: isDownloaded,
    )!;
    localPath = AcJsonUtils.deserializeValue<String>(
      jsonData['local_path'] ?? jsonData['localPath'],
      defaultValue: localPath,
    );
    fileUrl = AcJsonUtils.deserializeValue<String>(
      jsonData['file_url'] ?? jsonData['fileUrl'],
      defaultValue: fileUrl,
    );
    mediaCaption = AcJsonUtils.deserializeValue<String>(
      jsonData['media_caption'] ?? jsonData['mediaCaption'],
      defaultValue: mediaCaption,
    );
    duration = AcJsonUtils.deserializeValue<String>(
      jsonData['media_duration'] ?? jsonData['duration'],
      defaultValue: duration,
    );
    fileName = AcJsonUtils.deserializeValue<String>(
      jsonData['file_name'] ?? jsonData['fileName'],
      defaultValue: fileName,
    );
    fileSize = AcJsonUtils.deserializeValue<String>(
      jsonData['file_size'] ?? jsonData['fileSize'],
      defaultValue: fileSize,
    );

    expiresAt = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['expires_at'] ?? jsonData['expiresAt'],
      defaultValue: expiresAt,
    );
    scheduledTime = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['scheduled_time'] ?? jsonData['scheduledTime'],
      defaultValue: scheduledTime,
    );
    pinnedUntil = AcJsonUtils.deserializeValue<DateTime>(
      jsonData['pinned_until'] ?? jsonData['pinnedUntil'],
      defaultValue: pinnedUntil,
    );

    if (jsonData.containsKey('reactions') && jsonData['reactions'] != null) {
      if (jsonData['reactions'] is Map) {
        reactions = AcJsonUtils.deserializeMap<List<String>>(
          jsonData['reactions'],
          valueParser: (val) => AcJsonUtils.deserializeList<String>(val),
        );
      } else if (jsonData['reactions'] is String && (jsonData['reactions'] as String).isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonData['reactions'] as String);
          reactions = AcJsonUtils.deserializeMap<List<String>>(
            decoded,
            valueParser: (val) => AcJsonUtils.deserializeList<String>(val),
          );
        } catch (_) {}
      }
    }

    if (jsonData.containsKey('mentions') && jsonData['mentions'] != null) {
      mentions = AcJsonUtils.deserializeList<String>(jsonData['mentions']);
    }

    replyTo = AcJsonUtils.deserializeValue<AcChatMessage>(
      jsonData['reply_to'] ?? jsonData['replyTo'],
      fromJson: (data) => AcChatMessage.instanceFromJson(jsonData: data),
      defaultValue: replyTo,
    );

    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId.isNotEmpty ? messageId : null,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'type': type,
      'text': text,
      'time': AcJsonUtils.serializeValue(time),
      'status': status,
      'delivered_time': AcJsonUtils.serializeValue(deliveredTime),
      'read_time': AcJsonUtils.serializeValue(readTime),
      'is_edited': isEdited,
      'edited_time': AcJsonUtils.serializeValue(editedTime),
      'is_deleted': isDeleted,
      'is_starred': isStarred,
      'reactions': AcJsonUtils.serializeValue(reactions),
      'mentions': AcJsonUtils.serializeValue(mentions),
      'media_caption': mediaCaption,
      'media_duration': duration,
      'file_name': fileName,
      'file_size': fileSize,
      'is_downloaded': isDownloaded,
      'local_path': localPath,
      'localPath': localPath,
      'file_url': fileUrl,
      'fileUrl': fileUrl,
      'expires_at': AcJsonUtils.serializeValue(expiresAt),
      'scheduled_time': AcJsonUtils.serializeValue(scheduledTime),
      'pinned_until': AcJsonUtils.serializeValue(pinnedUntil),
    };
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

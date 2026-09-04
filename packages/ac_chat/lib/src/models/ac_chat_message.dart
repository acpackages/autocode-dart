import 'dart:convert';
import 'dart:typed_data';
import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';
import '../common/utc_utils.dart';

@AcReflectable()
class AcChatMessage {
  String messageId = '';
  String conversationId = '';
  String senderId = '';

  /// Message type: 'text', 'image', 'video', 'audio', 'voice_note',
  /// 'document', 'location', 'contact', 'system'.
  String type = 'text';

  String text = '';

  /// Canonical UTC creation timestamp.
  DateTime timeUtc = DateTime.now().toUtc();

  /// Message status: 'sending', 'sent', 'delivered', 'read', 'failed'.
  String status = 'sending';

  DateTime? deliveredTimeUtc;
  DateTime? readTimeUtc;

  bool isEdited = false;
  DateTime? editedTimeUtc;

  bool isDeleted = false;
  bool isStarred = false;

  /// Reactions mapped by emoji -> list of userIds who reacted.
  Map<String, List<String>> reactions = {};

  /// User IDs mentioned in this message.
  List<String> mentions = [];

  // Media / Metadata
  String? mediaCaption;
  double? amount;
  String? paymentNote;
  String? duration;
  String? fileName;
  String? fileSize;

  bool isDownloaded = false;
  String? localPath;

  /// Optional expiration timestamp for disappearing messages (UTC).
  DateTime? expiresAtUtc;

  /// Optional scheduled delivery timestamp (UTC).
  DateTime? scheduledTimeUtc;

  /// Optional pin expiration timestamp (UTC).
  DateTime? pinnedUntilUtc;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  Uint8List? byteData;

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  AcChatMessage? replyTo;

  // ── Backward-compatible Aliases ───────────────────────────────────────────

  DateTime get time => timeUtc;
  set time(DateTime v) => timeUtc = v.isUtc ? v : v.toUtc();

  DateTime? get deliveredTime => deliveredTimeUtc;
  set deliveredTime(DateTime? v) => deliveredTimeUtc = v == null ? null : (v.isUtc ? v : v.toUtc());

  DateTime? get readTime => readTimeUtc;
  set readTime(DateTime? v) => readTimeUtc = v == null ? null : (v.isUtc ? v : v.toUtc());

  DateTime? get editedTime => editedTimeUtc;
  set editedTime(DateTime? v) => editedTimeUtc = v == null ? null : (v.isUtc ? v : v.toUtc());

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

    if (json.containsKey('messageId') || json.containsKey('id')) {
      messageId = (json['messageId'] ?? json['id'] ?? '').toString();
      json.remove('messageId');
      json.remove('id');
    }

    if (json.containsKey('conversationId') || json.containsKey('chatId')) {
      conversationId = (json['conversationId'] ?? json['chatId'] ?? '').toString();
      json.remove('conversationId');
      json.remove('chatId');
    }

    if (json.containsKey('senderId')) {
      senderId = (json['senderId'] ?? '').toString();
      json.remove('senderId');
    }

    if (json.containsKey('type')) {
      type = (json['type'] ?? 'text').toString();
      json.remove('type');
    }

    if (json.containsKey('text')) {
      text = (json['text'] ?? '').toString();
      json.remove('text');
    }

    if (json.containsKey('status')) {
      status = (json['status'] ?? 'sending').toString();
      json.remove('status');
    }

    if (json.containsKey('timeUtc') || json.containsKey('time')) {
      final raw = json['timeUtc'] ?? json['time'];
      if (raw != null) timeUtc = parseUtc(raw);
      json.remove('timeUtc');
      json.remove('time');
    }

    if (json.containsKey('deliveredTimeUtc') || json.containsKey('deliveredTime')) {
      final raw = json['deliveredTimeUtc'] ?? json['deliveredTime'];
      if (raw != null) deliveredTimeUtc = parseUtc(raw);
      json.remove('deliveredTimeUtc');
      json.remove('deliveredTime');
    }

    if (json.containsKey('readTimeUtc') || json.containsKey('readTime')) {
      final raw = json['readTimeUtc'] ?? json['readTime'];
      if (raw != null) readTimeUtc = parseUtc(raw);
      json.remove('readTimeUtc');
      json.remove('readTime');
    }

    if (json.containsKey('editedTimeUtc') || json.containsKey('editedTime')) {
      final raw = json['editedTimeUtc'] ?? json['editedTime'];
      if (raw != null) editedTimeUtc = parseUtc(raw);
      json.remove('editedTimeUtc');
      json.remove('editedTime');
    }

    if (json.containsKey('isEdited')) {
      isEdited = json['isEdited'] == true || json['isEdited'] == 1;
      json.remove('isEdited');
    }

    if (json.containsKey('isDeleted')) {
      isDeleted = json['isDeleted'] == true || json['isDeleted'] == 1;
      json.remove('isDeleted');
    }

    if (json.containsKey('isStarred')) {
      isStarred = json['isStarred'] == true || json['isStarred'] == 1;
      json.remove('isStarred');
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

    if (json.containsKey('pinnedUntilUtc') || json.containsKey('pinnedUntil')) {
      final raw = json['pinnedUntilUtc'] ?? json['pinnedUntil'];
      pinnedUntilUtc = parseUtcOrNull(raw);
      json.remove('pinnedUntilUtc');
      json.remove('pinnedUntil');
    }

    if (json.containsKey('scheduledTimeUtc') || json.containsKey('scheduledTime')) {
      final raw = json['scheduledTimeUtc'] ?? json['scheduledTime'];
      scheduledTimeUtc = parseUtcOrNull(raw);
      json.remove('scheduledTimeUtc');
      json.remove('scheduledTime');
    }

    if (json.containsKey('expiresAtUtc') || json.containsKey('expiresAt')) {
      final raw = json['expiresAtUtc'] ?? json['expiresAt'];
      expiresAtUtc = parseUtcOrNull(raw);
      json.remove('expiresAtUtc');
      json.remove('expiresAt');
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

    if (json.containsKey('mediaCaption')) mediaCaption = json['mediaCaption'] as String?;
    if (json.containsKey('paymentNote')) paymentNote = json['paymentNote'] as String?;
    if (json.containsKey('duration')) duration = json['duration'] as String?;
    if (json.containsKey('fileName')) fileName = json['fileName'] as String?;
    if (json.containsKey('fileSize')) fileSize = json['fileSize'] as String?;
    if (json.containsKey('localPath')) localPath = json['localPath'] as String?;
    if (json.containsKey('isDownloaded')) isDownloaded = json['isDownloaded'] == true || json['isDownloaded'] == 1;

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
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type,
      'text': text,
      'status': status,
      'timeUtc': formatUtcIso(timeUtc),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isStarred': isStarred,
    };

    if (deliveredTimeUtc != null) {
      result['deliveredTimeUtc'] = formatUtcIso(deliveredTimeUtc!);
      result['deliveredTime'] = deliveredTimeUtc!.millisecondsSinceEpoch;
    }
    if (readTimeUtc != null) {
      result['readTimeUtc'] = formatUtcIso(readTimeUtc!);
      result['readTime'] = readTimeUtc!.millisecondsSinceEpoch;
    }
    if (editedTimeUtc != null) {
      result['editedTimeUtc'] = formatUtcIso(editedTimeUtc!);
      result['editedTime'] = editedTimeUtc!.millisecondsSinceEpoch;
    }
    if (pinnedUntilUtc != null) {
      result['pinnedUntilUtc'] = formatUtcIso(pinnedUntilUtc!);
      result['pinnedUntil'] = pinnedUntilUtc!.millisecondsSinceEpoch;
    }
    if (scheduledTimeUtc != null) {
      result['scheduledTimeUtc'] = formatUtcIso(scheduledTimeUtc!);
      result['scheduledTime'] = scheduledTimeUtc!.millisecondsSinceEpoch;
    }
    if (expiresAtUtc != null) {
      result['expiresAtUtc'] = formatUtcIso(expiresAtUtc!);
      result['expiresAt'] = expiresAtUtc!.millisecondsSinceEpoch;
    }
    if (reactions.isNotEmpty) {
      result['reactions'] = reactions;
    }
    if (mentions.isNotEmpty) {
      result['mentions'] = mentions;
    }
    if (amount != null) result['amount'] = amount;
    if (paymentNote != null) result['paymentNote'] = paymentNote;
    if (mediaCaption != null) result['mediaCaption'] = mediaCaption;
    if (duration != null) result['duration'] = duration;
    if (fileName != null) result['fileName'] = fileName;
    if (fileSize != null) result['fileSize'] = fileSize;
    if (replyTo != null) {
      result['replyTo'] = replyTo!.toJson();
    }
    return result;
  }
}

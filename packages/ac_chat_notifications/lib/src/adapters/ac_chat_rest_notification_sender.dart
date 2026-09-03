import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/ac_chat_notification_payload.dart';
import '../services/ac_chat_notification_sender.dart';

/// Concrete HTTP REST implementation of [AcChatNotificationSender] that posts
/// notification envelopes to any custom backend server with strictly named parameters.
class AcChatRestNotificationSender implements AcChatNotificationSender {
  final Uri endpoint;
  final Map<String, String> headers;
  final HttpClient Function()? httpClientProvider;

  const AcChatRestNotificationSender({
    required this.endpoint,
    this.headers = const {},
    this.httpClientProvider,
  });

  @override
  Future<void> sendPushNotification({
    required List<String> recipientUserIds,
    required AcChatNotificationPayload payload,
  }) async {
    if (recipientUserIds.isEmpty) return;

    final client = httpClientProvider?.call() ?? HttpClient();
    try {
      final request = await client.postUrl(endpoint);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      final bodyMap = {
        'recipient_user_ids': recipientUserIds,
        'notification': payload.toJson(),
      };

      request.write(jsonEncode(bodyMap));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw HttpException(
          'Failed to send push notification. Status code: ${response.statusCode}',
          uri: endpoint,
        );
      }
    } finally {
      if (httpClientProvider == null) {
        client.close();
      }
    }
  }
}

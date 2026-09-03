import '../models/ac_chat_notification_payload.dart';

/// Pluggable interface for dispatching push notifications from the client
/// or a backend/proxy layer to recipient devices.
abstract class AcChatNotificationSender {
  /// Dispatches push notifications to the provided [recipientUserIds].
  Future<void> sendPushNotification({
    required List<String> recipientUserIds,
    required AcChatNotificationPayload payload,
  });
}

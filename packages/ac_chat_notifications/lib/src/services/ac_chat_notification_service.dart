import '../models/ac_chat_notification_payload.dart';

/// Pluggable client-side interface for receiving, displaying, and handling notifications.
///
/// Implementations can wrap FCM, OneSignal, APNs, or a local notification library.
abstract class AcChatNotificationService {
  /// Initializes the notification service (e.g. requesting permissions,
  /// creating notification channels).
  Future<void> initialize();

  /// Retrieves the current push device token (FCM token, APNs token, OneSignal player ID, etc.).
  Future<String?> getDeviceToken();

  /// Registers the device token for [userId] with the backend or notification provider.
  Future<void> registerUserDevice({
    required String userId,
    required String deviceToken,
    required String platform,
  });

  /// Unregisters the device token for [userId].
  Future<void> unregisterUserDevice({
    required String userId,
    required String deviceToken,
  });

  /// Displays a local foreground or background notification on the device.
  Future<void> displayNotification({
    required AcChatNotificationPayload payload,
  });

  /// Cancels an active notification by its [notificationId].
  Future<void> cancelNotification({
    required String notificationId,
  });

  /// Cancels all active notifications associated with [conversationId].
  Future<void> cancelConversationNotifications({
    required String conversationId,
  });

  /// Updates the application badge count on iOS / supported Android launchers.
  Future<void> setBadgeCount({
    required int count,
  });

  /// Registers a callback to be triggered when a notification is tapped by the user.
  void onNotificationTapped({
    required void Function({
      required String conversationId,
      String? messageId,
    }) callback,
  });
}

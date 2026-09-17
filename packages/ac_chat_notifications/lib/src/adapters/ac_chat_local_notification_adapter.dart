import 'dart:async';
import 'package:ac_chat_core/ac_chat_core.dart';

import '../models/ac_chat_notification_payload.dart';
import '../services/ac_chat_notification_service.dart';

/// A delegate-based notification service that handles in-app notification routing,
/// listener registration, and device tokens with strictly named parameters.
class AcChatLocalNotificationAdapter implements AcChatNotificationService {
  final AcChatApi? api;
  String? activeConversationId;

  final Future<void> Function({required AcChatNotificationPayload payload})? onDisplayNotification;
  final Future<void> Function({required String notificationId})? onCancelNotification;
  final Future<void> Function({required int count})? onSetBadgeCount;
  final Future<String?> Function()? onGetDeviceToken;
  final Future<void> Function({
    required String userId,
    required String deviceToken,
    required String platform,
  })? onRegisterDevice;
  final Future<void> Function({
    required String userId,
    required String deviceToken,
  })? onUnregisterDevice;

  void Function({required String conversationId, String? messageId})? _tapCallback;
  final Map<String, AcChatNotificationPayload> _activeNotifications = {};

  AcChatLocalNotificationAdapter({
    this.api,
    this.activeConversationId,
    this.onDisplayNotification,
    this.onCancelNotification,
    this.onSetBadgeCount,
    this.onGetDeviceToken,
    this.onRegisterDevice,
    this.onUnregisterDevice,
  });

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getDeviceToken() async {
    if (onGetDeviceToken != null) {
      return await onGetDeviceToken!();
    }
    return null;
  }

  @override
  Future<void> registerUserDevice({
    required String userId,
    required String deviceToken,
    required String platform,
  }) async {
    if (onRegisterDevice != null) {
      await onRegisterDevice!(
        userId: userId,
        deviceToken: deviceToken,
        platform: platform,
      );
    }
  }

  @override
  Future<void> unregisterUserDevice({
    required String userId,
    required String deviceToken,
  }) async {
    if (onUnregisterDevice != null) {
      await onUnregisterDevice!(
        userId: userId,
        deviceToken: deviceToken,
      );
    }
  }

  @override
  Future<void> displayNotification({
    required AcChatNotificationPayload payload,
  }) async {
    // Suppress notification if foreground conversation matches and suppression is enabled
    final suppressForeground = api?.enableForegroundNotificationSuppression ?? true;
    if (suppressForeground &&
        activeConversationId != null &&
        activeConversationId == payload.conversationId) {
      return;
    }

    _activeNotifications[payload.notificationId] = payload;
    if (onDisplayNotification != null) {
      await onDisplayNotification!(payload: payload);
    }
  }

  @override
  Future<void> cancelNotification({
    required String notificationId,
  }) async {
    _activeNotifications.remove(notificationId);
    if (onCancelNotification != null) {
      await onCancelNotification!(notificationId: notificationId);
    }
  }

  @override
  Future<void> cancelConversationNotifications({
    required String conversationId,
  }) async {
    final toRemove = _activeNotifications.entries
        .where((e) => e.value.conversationId == conversationId)
        .map((e) => e.key)
        .toList();

    for (final id in toRemove) {
      await cancelNotification(notificationId: id);
    }
  }

  @override
  Future<void> setBadgeCount({
    required int count,
  }) async {
    if (api != null && !api!.enableBadgeCountSync) {
      return;
    }
    if (onSetBadgeCount != null) {
      await onSetBadgeCount!(count: count);
    }
  }

  @override
  void onNotificationTapped({
    required void Function({
      required String conversationId,
      String? messageId,
    }) callback,
  }) {
    _tapCallback = callback;
  }

  /// Triggers the tap callback programmatically (e.g. from a system notification tap listener).
  void simulateNotificationTap({
    required String conversationId,
    String? messageId,
  }) {
    _tapCallback?.call(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  /// Returns unmodifiable list of currently tracked active notifications.
  List<AcChatNotificationPayload> get activeNotifications =>
      List.unmodifiable(_activeNotifications.values);
}

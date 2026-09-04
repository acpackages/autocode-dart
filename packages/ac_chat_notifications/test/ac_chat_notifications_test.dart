import 'package:flutter_test/flutter_test.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_notifications/ac_chat_notifications.dart';

void main() {
  group('AcChatNotificationPayload Tests', () {
    test('Serialization and Deserialization roundtrip with strict UTC and agnostic names', () {
      final now = DateTime.utc(2026, 9, 3, 12, 0);
      final payload = AcChatNotificationPayload(
        notificationId: 'notif_001',
        conversationId: 'conv_123',
        messageId: 'msg_456',
        senderId: 'alice',
        senderName: 'Alice Johnson',
        senderAvatar: 'https://example.com/alice.png',
        body: 'Hey there! How is the project going?',
        isGroup: true,
        conversationName: 'Engineering Core',
        badgeCount: 3,
        customData: {'priority': 'high', 'type': 'direct_message'},
        timestamp: now,
      );

      expect(payload.timestamp.isUtc, isTrue);
      expect(payload.groupName, equals('Engineering Core'));

      final json = payload.toJson();
      expect(json['notification_id'], equals('notif_001'));
      expect(json['conversation_id'], equals('conv_123'));
      expect(json['message_id'], equals('msg_456'));
      expect(json['sender_id'], equals('alice'));
      expect(json['sender_name'], equals('Alice Johnson'));
      expect(json['sender_avatar'], equals('https://example.com/alice.png'));
      expect(json['body'], equals('Hey there! How is the project going?'));
      expect(json['is_group'], isTrue);
      expect(json['conversation_name'], equals('Engineering Core'));
      expect(json['group_name'], equals('Engineering Core'));
      expect(json['badge_count'], equals(3));
      expect(json['custom_data']['priority'], equals('high'));
      expect(json['timestamp'], equals(now.millisecondsSinceEpoch));
      expect(json['timestamp_iso'].toString().endsWith('Z'), isTrue);

      final fromJson = AcChatNotificationPayload.fromJson(json: json);
      expect(fromJson.notificationId, equals(payload.notificationId));
      expect(fromJson.conversationId, equals(payload.conversationId));
      expect(fromJson.messageId, equals(payload.messageId));
      expect(fromJson.senderId, equals(payload.senderId));
      expect(fromJson.senderName, equals(payload.senderName));
      expect(fromJson.senderAvatar, equals(payload.senderAvatar));
      expect(fromJson.body, equals(payload.body));
      expect(fromJson.isGroup, equals(payload.isGroup));
      expect(fromJson.conversationName, equals('Engineering Core'));
      expect(fromJson.groupName, equals('Engineering Core'));
      expect(fromJson.badgeCount, equals(payload.badgeCount));
      expect(fromJson.customData['type'], equals('direct_message'));
      expect(fromJson.timestamp.isUtc, isTrue);
      expect(fromJson.timestamp.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
    });
  });

  group('AcChatLocalNotificationAdapter Tests', () {
    test('Display, cancellation, and tap routing with strictly named parameters', () async {
      String? tappedConvId;
      String? tappedMsgId;
      int setBadge = 0;

      final adapter = AcChatLocalNotificationAdapter(
        onSetBadgeCount: ({required int count}) async {
          setBadge = count;
        },
      );

      adapter.onNotificationTapped(
        callback: ({required String conversationId, String? messageId}) {
          tappedConvId = conversationId;
          tappedMsgId = messageId;
        },
      );

      final payload1 = AcChatNotificationPayload(
        notificationId: 'notif_1',
        conversationId: 'conv_1',
        messageId: 'msg_1',
        senderId: 'bob',
        senderName: 'Bob',
        body: 'Hello',
        timestamp: DateTime.now(),
      );

      final payload2 = AcChatNotificationPayload(
        notificationId: 'notif_2',
        conversationId: 'conv_1',
        messageId: 'msg_2',
        senderId: 'bob',
        senderName: 'Bob',
        body: 'Second message',
        timestamp: DateTime.now(),
      );

      await adapter.displayNotification(payload: payload1);
      await adapter.displayNotification(payload: payload2);

      expect(adapter.activeNotifications.length, equals(2));

      await adapter.setBadgeCount(count: 5);
      expect(setBadge, equals(5));

      // Simulate tapping notification
      adapter.simulateNotificationTap(
        conversationId: 'conv_1',
        messageId: 'msg_1',
      );
      expect(tappedConvId, equals('conv_1'));
      expect(tappedMsgId, equals('msg_1'));

      // Cancel single notification
      await adapter.cancelNotification(notificationId: 'notif_1');
      expect(adapter.activeNotifications.length, equals(1));
      expect(adapter.activeNotifications.first.notificationId, equals('notif_2'));

      // Cancel all for conversation
      await adapter.cancelConversationNotifications(conversationId: 'conv_1');
      expect(adapter.activeNotifications, isEmpty);
    });

    test('Foreground notification suppression when activeConversationId matches', () async {
      int displayed = 0;
      final adapter = AcChatLocalNotificationAdapter(
        activeConversationId: 'conv_active',
        config: const AcChatConfig(
          enableForegroundNotificationSuppression: true,
        ),
        onDisplayNotification: ({required payload}) async {
          displayed++;
        },
      );

      // Notification for active conversation should be suppressed
      await adapter.displayNotification(
        payload: AcChatNotificationPayload(
          notificationId: 'notif_suppressed',
          conversationId: 'conv_active',
          messageId: 'm1',
          senderId: 'bob',
          senderName: 'Bob',
          body: 'Ignored',
          timestamp: DateTime.now(),
        ),
      );
      expect(displayed, equals(0));
      expect(adapter.activeNotifications, isEmpty);

      // Notification for other conversation should be displayed
      await adapter.displayNotification(
        payload: AcChatNotificationPayload(
          notificationId: 'notif_shown',
          conversationId: 'conv_other',
          messageId: 'm2',
          senderId: 'charlie',
          senderName: 'Charlie',
          body: 'Shown',
          timestamp: DateTime.now(),
        ),
      );
      expect(displayed, equals(1));
      expect(adapter.activeNotifications.length, equals(1));
    });

    test('Badge count sync guard respects enableBadgeCountSync config flag', () async {
      int setBadge = 0;
      final disabledAdapter = AcChatLocalNotificationAdapter(
        config: const AcChatConfig(enableBadgeCountSync: false),
        onSetBadgeCount: ({required int count}) async {
          setBadge = count;
        },
      );

      await disabledAdapter.setBadgeCount(count: 10);
      expect(setBadge, equals(0));

      final enabledAdapter = AcChatLocalNotificationAdapter(
        config: const AcChatConfig(enableBadgeCountSync: true),
        onSetBadgeCount: ({required int count}) async {
          setBadge = count;
        },
      );

      await enabledAdapter.setBadgeCount(count: 10);
      expect(setBadge, equals(10));
    });
  });
}

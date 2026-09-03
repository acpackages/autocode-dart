/// Universal pluggable notification toolkit for `ac_chat`.
///
/// Provides abstract interfaces and adapters for client-side display,
/// device token registration, notification tap routing, and backend
/// push notification dispatch (FCM, OneSignal, APNs, custom REST).
library ac_chat_notifications;

export 'src/models/ac_chat_notification_payload.dart';
export 'src/services/ac_chat_notification_service.dart';
export 'src/services/ac_chat_notification_sender.dart';
export 'src/adapters/ac_chat_local_notification_adapter.dart';
export 'src/adapters/ac_chat_rest_notification_sender.dart';

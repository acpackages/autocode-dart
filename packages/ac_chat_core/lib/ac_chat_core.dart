/// Pure-Dart core models, API contracts, and interfaces for the ac_chat ecosystem.
///
/// No Flutter dependency. Safe to use in server-side Dart, CLI tools, and Flutter apps alike.
library ac_chat_core;

export 'src/common/utc_utils.dart';
export 'src/models/ac_chat_message.dart';
export 'src/models/ac_chat_user.dart';
export 'src/models/ac_chat_conversation.dart';
export 'src/models/ac_chat_conversation_user.dart';
export 'src/sync/ac_chat_sync_channel.dart';
export 'src/media/ac_chat_media_handler.dart';
export 'src/crypto/ac_chat_crypto_provider.dart';
export 'src/connectivity/ac_chat_connectivity_provider.dart';
export 'src/core/ac_chat_api.dart';

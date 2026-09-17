/// Flutter chat UI toolkit — re-exports ac_chat_core for full backward compatibility.
///
/// Any existing `import 'package:ac_chat/ac_chat.dart'` continues to resolve
/// all model types (AcChatMessage, AcChatUser, AcChatConversation, etc.)
/// through the ac_chat_core re-export below.
library ac_chat;

// Flutter UI: AcChat widget, AcChatTheme, ThemeProvider, AcChatApiProvider, AcChatAudioPlayer
export 'src/components/ac_chat.dart';
export 'src/common/chat_colors.dart';
export 'src/common/theme_provider.dart';

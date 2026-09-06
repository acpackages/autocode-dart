import 'package:flutter/material.dart';
import 'package:ac_chat/ac_chat.dart';
import 'mock_data.dart' as mock;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Construct default dark and light themes (can use AcChatTheme(isDark: false))
    final chatTheme = const AcChatTheme(isDark: false);

    // final api = AcChatApi(
    //   theme: chatTheme,
    //   enableGroupsAndStatuses: true,
    //   getCurrentUser: () => mock.currentUserInstance,
    //   getUsers: () => mock.users.map((u) => AcChatUser.instanceFromJson(jsonData: u)).toList(),
    //   getUserById: ({required userId}) => mock.getUserById(userId),
    //   getConversations: () => mock.chats.map((c) => AcChatConversation.instanceFromJson(jsonData: c)).toList(),
    //   getConversationUsers: ({required conversationId}) => mock.getConversationUsers(conversationId),
    //   markAsRead: ({required conversationId}) {
    //     final idx = mock.chats.indexWhere((c) => c['id'].toString() == conversationId);
    //     if (idx != -1) {
    //       mock.chats[idx] = {...mock.chats[idx], 'unread': 0};
    //     }
    //   },
    //   insertConversation: ({required newConv, required otherUserId}) => mock.insertConversation(newConv, otherUserId),
    //   getMessages: ({required conversationId}) {
    //     final list = mock.messages
    //         .where((m) => m['chatId'].toString() == conversationId)
    //         .map((m) => AcChatMessage.instanceFromJson(jsonData: m))
    //         .toList();
    //     list.sort((a, b) => a.time.compareTo(b.time));
    //     return list;
    //   },
    //   sendMessage: ({required message}) => mock.insertMessage(message),
    //   updateMessage: ({required messageId, required data}) => mock.updateMessage(messageId, data),
    // );

    return MaterialApp(
      title: 'AcChat Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        // body: AcChat(api: api),
      ),
    );
  }
}

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_sqlite/ac_chat_sqlite.dart';
// import 'package:ac_chat_on_firebase/ac_chat_on_firebase.dart';

/// Entry point. Firebase is initialized before the app starts.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ac_chat SQLite + Firebase Example',
      theme: ThemeData.dark(),
      home: const ChatScreen(currentUserId: 'user_abc123'),
    );
  }
}

/// Full chat screen backed by SQLite + Firebase.
///
/// [AcChatFirebase] directly implements [AcChatSyncChannel], so it can be
/// passed directly as the `channel` — no adapter class required.
class ChatScreen extends StatefulWidget {
  final String currentUserId;

  const ChatScreen({super.key, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late AcChatSqlite _sqlite;
  AcChatApi? _api;

  @override
  void initState() {
    super.initState();

    // AcChatFirebase implements AcChatSyncChannel — pass it directly as the
    // channel. No hand-written adapter is needed.
    // final firebase = AcChatFirebase(currentUserId: widget.currentUserId);

    _sqlite = AcChatSqlite(
      currentUserId: widget.currentUserId,
      // channel: firebase,
    );

    // Hook up UI rebuilds.
    _sqlite.onDataChanged = () {
      if (mounted) setState(() {});
    };

    // Initialize (open DB, load cached data, start channel listeners).
    _sqlite.initialize().then((_) {
      if (mounted) {
        setState(() {
          // _api = _sqlite.buildApi(AcChatTheme.dark());
        });
      }
    });
  }

  @override
  void dispose() {
    // dispose() is async; use unawaited() since State.dispose() is synchronous.
    unawaited(_sqlite.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_api == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return AcChat(api: _api!);
  }
}

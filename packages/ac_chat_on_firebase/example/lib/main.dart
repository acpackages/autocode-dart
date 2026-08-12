import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_on_firebase/ac_chat_on_firebase.dart';

/// Entry point for the ac_chat_on_firebase example.
///
/// Firebase is initialized here using the default app. Replace the
/// `Firebase.initializeApp()` call with your own options if required.
/// The [currentUserId] used throughout this example is hard-coded for
/// demonstration purposes — in a real application this value comes from
/// whatever authentication mechanism the host app uses.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your Firebase app as usual.
  // If you have multiple Firebase projects, name them:
  //   await Firebase.initializeApp(name: 'chat', options: chatFirebaseOptions);
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ac_chat Firebase Example',
      theme: ThemeData(useMaterial3: true),
      // Replace with however your app resolves the current user ID.
      home: const ChatScreen(currentUserId: 'user_abc123'),
    );
  }
}

/// A screen that wires [AcChatFirebase] to [AcChat] and refreshes the UI
/// whenever Firestore data changes.
class ChatScreen extends StatefulWidget {
  final String currentUserId;

  const ChatScreen({super.key, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late AcChatFirebase _firebase;
  AcChatApi? _api;

  @override
  void initState() {
    super.initState();

    _firebase = AcChatFirebase(
      currentUserId: widget.currentUserId,
      // To target a specific Firebase project pass a named FirebaseApp:
      //   app: Firebase.app('chat'),
      //
      // To customize collection names:
      //   config: AcChatFirebaseConfig(
      //     usersCollection: 'chat_users',
      //     conversationsCollection: 'chat_conversations',
      //   ),
    );

    // Tell AcChatFirebase to rebuild the widget tree whenever Firestore data
    // arrives. In standalone mode this is the only trigger for UI refreshes.
    _firebase.onDataChanged = () {
      if (mounted) setState(() {});
    };

    _firebase.initialize().then((_) {
      if (mounted) {
        setState(() {
          // _api = _firebase.buildApi(AcChatTheme.dark());
        });
      }
    });
  }

  @override
  void dispose() {
    _firebase.dispose();
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

// ─── Multiple Firebase instances example ─────────────────────────────────────
//
// When your app connects to more than one Firebase project, pass the named
// FirebaseApp to AcChatFirebase so Firestore and Storage are derived from the
// correct project.
//
// // Default app
// final firebaseA = AcChatFirebase(currentUserId: 'uid');
//
// // Named app — initialized elsewhere with:
// //   await Firebase.initializeApp(name: 'chat', options: chatFirebaseOptions);
// final firebaseB = AcChatFirebase(
//   currentUserId: 'uid',
//   app: Firebase.app('chat'),
// );

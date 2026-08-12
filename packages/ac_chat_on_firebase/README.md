# ac_chat_on_firebase

Firebase backend adapter for [`ac_chat`](https://pub.dev/packages/ac_chat).

Implements `AcChatApi` using **Cloud Firestore** and **Firebase Storage** as the data sources.  
Also implements `AcChatSyncChannel` so it can be used as a drop-in transport layer for `ac_chat_sqlite` or any future caching adapter.

> **No Firebase Auth dependency.** Authentication is the host application's responsibility.  
> Pass `currentUserId` directly — however your app resolves it (JWT, custom auth, etc.).

---

## Prerequisites

1. A Firebase project with **Cloud Firestore** and **Firebase Storage** enabled.
2. The `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) file added to your app.
3. Firebase Core initialized in `main()` before calling `initialize()`.

No Firebase Auth setup is required.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ac_chat_on_firebase:
    path: '../ac_chat_on_firebase'   # or use the pub.dev version
```

---

## Initialization

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_on_firebase/ac_chat_on_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

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
    _firebase = AcChatFirebase(currentUserId: widget.currentUserId);

    // Rebuild the widget tree whenever Firestore data changes.
    _firebase.onDataChanged = () {
      if (mounted) setState(() {});
    };

    _firebase.initialize().then((_) {
      if (mounted) setState(() => _api = _firebase.buildApi(AcChatTheme.dark()));
    });
  }

  @override
  void dispose() {
    _firebase.dispose(); // cancels all Firestore listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_api == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return AcChat(api: _api!);
  }
}
```

---

## Multiple Firebase Instances

When your app connects to more than one Firebase project, pass the named `FirebaseApp`:

```dart
// Initialize both apps in main()
await Firebase.initializeApp(); // default
await Firebase.initializeApp(name: 'chat', options: chatFirebaseOptions);

// Default project
final firebaseA = AcChatFirebase(currentUserId: 'uid');

// Named project
final firebaseB = AcChatFirebase(
  currentUserId: 'uid',
  app: Firebase.app('chat'),
);
```

`AcChatFirebase` derives `FirebaseFirestore` and `FirebaseStorage` from the supplied `FirebaseApp` — it never touches `FirebaseFirestore.instance` directly when an app is provided.

---

## How `onDataChanged` Works

Because `AcChatApi` callback signatures are **synchronous**, `AcChatFirebase` maintains an in-memory cache that is kept up-to-date by Firestore real-time listeners.

Whenever a listener fires (new message, conversation update, user change), `AcChatFirebase` calls `onDataChanged`. Set this to `() => setState(() {})` in your `StatefulWidget` and the UI will rebuild automatically.

```dart
_firebase.onDataChanged = () {
  if (mounted) setState(() {});
};
```

---

## Configuration

Override collection names, storage path, or page size via `AcChatFirebaseConfig`:

```dart
AcChatFirebase(
  currentUserId: 'uid',
  config: AcChatFirebaseConfig(
    usersCollection: 'chat_users',
    conversationsCollection: 'chats',
    messagesSubcollection: 'chat_messages',
    conversationUsersSubcollection: 'participants',
    storagePath: 'chat_media',
    messagesPageSize: 100,
  ),
);
```

---

## Firestore Schema

### `/users/{user_id}`
```json
{
  "user_id": "uid1",
  "name": "Alice",
  "username": "alice",
  "email": "alice@example.com",
  "phone": "+15550001234",
  "avatar": "https://..."
}
```

### `/conversations/{conversation_id}`
```json
{
  "member_ids": ["uid1", "uid2"],
  "is_group": false,
  "group_name": null,
  "last_message": "Hello!",
  "last_message_type": "text",
  "last_time": "<Timestamp>",
  "is_pinned": false,
  "is_muted": false
}
```

### `/conversations/{conversation_id}/members/{user_id}`
```json
{
  "user_id": "uid1",
  "conversation_id": "conv123",
  "unread": 3
}
```

### `/conversations/{conversation_id}/messages/{message_id}`
```json
{
  "message_id": "msgId",
  "conversation_id": "conv123",
  "sender_id": "uid1",
  "type": "text",
  "text": "Hello!",
  "time": "<Timestamp>",
  "status": "sent",
  "media_caption": null,
  "amount": null,
  "payment_note": null,
  "duration": null,
  "file_name": null,
  "file_size": null,
  "reply_to_id": null
}
```

> **Note:** `is_downloaded` and `local_path` are **never** stored in Firestore.  
> These are device-local fields managed by the caching layer (e.g. `ac_chat_sqlite`).

---

## Firestore Security Rules

> ⚠️ The rules below allow open read/write access and are for **development only**.  
> Tighten them for production using your own authentication mechanism.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if true;
    }
    match /conversations/{conversationId} {
      allow read, write: if true;
      match /messages/{messageId} {
        allow read, write: if true;
      }
      match /members/{memberId} {
        allow read, write: if true;
      }
    }
  }
}
```

---

## Required Firestore Indexes

Create these composite indexes in the Firebase Console (or via `firestore.indexes.json`):

| Collection | Fields | Order |
|---|---|---|
| `conversations` | `member_ids` (array-contains), `last_time` | descending |
| `messages` (subcollection) | `time` | ascending |

---

## Using as a Sync Channel

`AcChatFirebase` implements `AcChatSyncChannel`, the transport interface defined in `ac_chat`.  
This allows it to be used directly with `ac_chat_sqlite` (or any caching layer) as the remote backend:

```dart
final channel = AcChatFirebase(currentUserId: 'uid');
await channel.startListening(
  currentUserId: 'uid',
  onMessageReceived: (msg) { /* forward to SQLite */ },
  onConversationChanged: (conv, members) { /* forward to SQLite */ },
  onUsersLoaded: (users) { /* forward to SQLite */ },
);
```

In channel mode, `AcChatFirebase` does **not** update its in-memory state or call `onDataChanged`.  
The caching layer owns all local state.

---

## License

See [LICENSE](LICENSE).

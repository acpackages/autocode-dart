# ac_chat_sqlite

Offline-first SQLite cache layer for [`ac_chat`](../ac_chat).

SQLite is the **source of truth** for persistence. All UI reads come from a fast in-memory cache that mirrors SQLite. An optional [`AcChatSyncChannel`](../ac_chat/lib/src/sync/ac_chat_sync_channel.dart) delegates message transport to any remote backend — Firebase, REST, WebSocket, Supabase, or anything else.

---

## Architecture

```
ac_chat (UI)
    │  synchronous callbacks
    ▼
AcChatSqlite                 ← this package
    │  reads in-memory cache │  writes to / loads from
    ▼                        ▼
In-memory state          SQLite (sqflite)
    │
    │  delegates send / listens for incoming
    ▼
AcChatSyncChannel (abstract)   ← defined in ac_chat
    │
    ▲  implemented by host app (e.g. AcChatFirebase)
```

**Key rules:**

- All UI reads come from in-memory state (fast, synchronous).
- SQLite is always written first before in-memory state is updated.
- The channel is optional — the package works offline without one.
- `ac_chat_sqlite` and `ac_chat_on_firebase` have zero dependency on each other.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ac_chat_sqlite:
    path: ../ac_chat_sqlite   # adjust path to your monorepo layout
```

---

## Usage

### Standalone (offline-only, no channel)

```dart
import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:ac_chat/ac_chat.dart';
import 'package:ac_chat_sqlite/ac_chat_sqlite.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late AcChatSqlite _sqlite;
  AcChatApi? _api;

  @override
  void initState() {
    super.initState();

    _sqlite = AcChatSqlite(
      currentUserId: 'user_123',
      // no channel — works fully offline
    );

    _sqlite.onDataChanged = () {
      if (mounted) setState(() {});
    };

    _sqlite.initialize().then((_) {
      if (mounted) {
        setState(() {
          _api = _sqlite.buildApi(AcChatTheme.dark());
        });
      }
    });
  }

  @override
  void dispose() {
    unawaited(_sqlite.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_api == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return AcChat(api: _api!);
  }
}
```

---

### With Firebase as the sync channel

[`AcChatFirebase`](../ac_chat_on_firebase) directly implements `AcChatSyncChannel` — no adapter class is needed.

```dart
import 'package:ac_chat_sqlite/ac_chat_sqlite.dart';
import 'package:ac_chat_on_firebase/ac_chat_on_firebase.dart';

final sqlite = AcChatSqlite(
  currentUserId: 'user_123',
  channel: AcChatFirebase(currentUserId: 'user_123'),
);
```

---

### Custom channel (REST, WebSocket, Supabase, etc.)

Implement `AcChatSyncChannel` from `ac_chat` in your own package:

```dart
import 'package:ac_chat/ac_chat.dart';

class MyRestChannel implements AcChatSyncChannel {
  @override
  Future<void> sendMessage(AcChatMessage message) async {
    await http.post('/messages', body: jsonEncode(message.toJson()));
  }

  @override
  Future<void> createConversation(
    AcChatConversation conversation,
    String otherUserId,
  ) async {
    await http.post('/conversations', body: jsonEncode(conversation.toJson()));
  }

  @override
  Future<void> markAsRead(
    String conversationId,
    String currentUserId,
  ) async {
    await http.post('/conversations/$conversationId/read');
  }

  @override
  Future<void> updateMessage(
    String messageId,
    String conversationId,
    Map<String, dynamic> data,
  ) async {
    await http.patch('/messages/$messageId', body: jsonEncode(data));
  }

  @override
  Future<void> startListening({
    required String currentUserId,
    required void Function(AcChatMessage message) onMessageReceived,
    required void Function(
      AcChatConversation conversation,
      List<AcChatConversationUser> members,
    ) onConversationChanged,
    required void Function(List<AcChatUser> users) onUsersLoaded,
  }) async {
    // Connect to WebSocket / SSE and forward events to the callbacks.
  }

  @override
  Future<void> stopListening() async {
    // Cancel subscriptions.
  }
}
```

Then wire it up:

```dart
final sqlite = AcChatSqlite(
  currentUserId: 'user_123',
  channel: MyRestChannel(),
);
```

---

## SQLite Schema

### `users`
| Column    | Type | Notes             |
|-----------|------|-------------------|
| user_id   | TEXT | Primary key       |
| name      | TEXT |                   |
| username  | TEXT | Default `''`      |
| email     | TEXT | Default `''`      |
| phone     | TEXT | Nullable          |
| avatar    | TEXT | Nullable (URL)    |

### `conversations`
| Column            | Type    | Notes                             |
|-------------------|---------|-----------------------------------|
| conversation_id   | TEXT    | Primary key                       |
| type              | TEXT    | `'direct'` or `'group'`           |
| group_name        | TEXT    | Nullable                          |
| last_message      | TEXT    |                                   |
| last_message_type | TEXT    |                                   |
| last_time         | INTEGER | Unix milliseconds                 |
| unread            | INTEGER |                                   |
| is_pinned         | INTEGER | `0` / `1`                         |
| is_muted          | INTEGER | `0` / `1`                         |

### `conversation_members`
| Column          | Type | Notes                          |
|-----------------|------|--------------------------------|
| conversation_id | TEXT | Composite PK with `user_id`    |
| user_id         | TEXT |                                |

### `messages`
| Column          | Type    | Notes                                  |
|-----------------|---------|----------------------------------------|
| message_id      | TEXT    | Primary key                            |
| conversation_id | TEXT    | Indexed with `time`                    |
| sender_id       | TEXT    |                                        |
| type            | TEXT    | `text`, `image`, `audio`, etc.         |
| text            | TEXT    |                                        |
| time            | INTEGER | Unix milliseconds                      |
| status          | TEXT    | `sending` → `sent` / `failed`          |
| media_caption   | TEXT    | Nullable                               |
| amount          | REAL    | Nullable (payment messages)            |
| payment_note    | TEXT    | Nullable                               |
| duration        | TEXT    | Nullable (audio/video)                 |
| file_name       | TEXT    | Nullable                               |
| file_size       | TEXT    | Nullable                               |
| is_downloaded   | INTEGER | `0` / `1`                              |
| local_path      | TEXT    | Nullable                               |
| reply_to_id     | TEXT    | Nullable — resolved from in-memory index |

> **Note:** `AcChatMessage.replyTo` (an `AcChatMessage` object) is stored as `reply_to_id` (a message ID) and resolved from the in-memory `_messageIndex` on load.

---

## How `onDataChanged` triggers UI rebuilds

`AcChatSqlite` calls `onDataChanged` after every mutation (send message, receive message, mark as read, etc.). Hook it up to `setState` in your `StatefulWidget`:

```dart
_sqlite.onDataChanged = () {
  if (mounted) setState(() {});
};
```

The UI reads in-memory state synchronously via the `AcChatApi` callbacks returned by `buildApi()`, so every `setState` immediately reflects the latest data.

---

## Message status lifecycle

```
User taps "Send"
    │
    ▼
status = 'sending'  ──▶  stored in SQLite  ──▶  in-memory  ──▶  UI notified
    │
    ▼  (channel present)
channel.sendMessage()  ──▶  remote write
    │
    ▼  (remote listener fires)
_handleIncomingMessage()
    │  message_id already in _messageIndex
    ▼
status = 'sent'  ──▶  updated in SQLite  ──▶  UI notified

    ── OR, on channel error ──

status = 'failed'  ──▶  updated in SQLite  ──▶  UI notified
```

When no channel is connected, `status` jumps directly from `'sending'` to `'sent'` after the SQLite write.

---

## Configuration

```dart
AcChatSqlite(
  currentUserId: 'user_123',
  config: AcChatSqliteConfig(
    databaseName: 'my_chat.db',   // default: 'ac_chat.db'
    databaseVersion: 1,           // increment to run migrations
  ),
);
```

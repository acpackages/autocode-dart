# ac_exceptor

A lightweight Dart and Flutter exception-capturing package that catches uncaught application exceptions and Flutter framework errors, grouping identical exceptions and storing detailed occurrence timestamps in a local SQLite database.

## Features

* **Zero-config Uncaught Error Interception**: Automatically hooks into `PlatformDispatcher.instance.onError` and `FlutterError.onError`.
* **Preserves Flutter Error Handling**: Does not overwrite or silence existing framework error presentations or developer handlers.
* **Smart Grouping**: Groups identical exceptions by `exception_type` and `exception_message` while tracking `occurrence_count`, `first_occurred_at`, and `last_occurred_at`.
* **Separate Occurrence Logs**: Records individual timestamps and stack traces in a relational `exception_occurrences` table.
* **Powered by `ac_sql` & `ac_data_dictionary`**: Schema definition and SQLite migrations are managed through repository-native data dictionary abstractions.
* **Loop Prevention**: Reentrancy protected to ensure database recording failures never trigger recursive reporting or application crashes.
* **Minimalist Architecture**: No unnecessary layers, services, controllers, or dependencies.

## Installation

Add `ac_exceptor` to your `pubspec.yaml`:

```yaml
dependencies:
  ac_exceptor:
    path: ../ac_exceptor
```

## Initialization

Initialize `AcExceptor` before running your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:ac_exceptor/ac_exceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database and hook error handlers
  await AcExceptor.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('ac_exceptor Active')),
      ),
    );
  }
}
```

By default, the SQLite database is created and maintained at:

```text
ac-exceptor/exceptor.db
```

## Handled Exceptions

You can record handled exceptions explicitly using `captureHandled` or automatically protect blocks of code using `guard` / `guardAsync`:

### 1. Manual Handled Capture
```dart
try {
  // risky business logic
} catch (e, stack) {
  // Explicitly tag as handled in SQLite
  AcExceptor.captureHandled(e, stack);

  showUserFeedback();
}
```

### 2. Automatic Guarding (Sync & Async)
```dart
// Synchronous guard with fallback
final count = AcExceptor.guard<int>(() {
  return parseServerCount();
}, fallbackValue: 0);

// Asynchronous guard with error recovery handler
final user = await AcExceptor.guardAsync<User>(() async {
  return await api.fetchProfile();
}, onError: (e, stack) => User.guest());
```

### 3. Fluent Extensions for Zero-Boilerplate Auto-Capture
You can directly chain `.captureHandled()`, `.guarded()`, or `.guardedAsync()` onto any Future or Function:

```dart
// Auto-capture errors on any Future:
final profile = await api.getProfile().captureHandled(fallbackValue: null);

// Auto-capture errors on synchronous button callbacks / functions:
final safeOnClick = (() => doHeavyTask()).guarded(fallbackValue: null);

// Auto-capture errors on async functions:
final safeFetch = (() async => await loadData()).guardedAsync(fallbackValue: []);
```

## Database Schema

The database schema is defined in `kAcExceptorDataDictionaryJson` and initialized automatically using `ac_data_dictionary` and `AcSqlDbSchemaManager`:

### `exceptions` (Grouped Exceptions)

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Unique identifier for the grouped exception |
| `exception_type` | `TEXT` | Runtime type of the exception (e.g. `FormatException`, `TypeError`) |
| `exception_message` | `TEXT` | String representation of the error message |
| `stack_trace` | `TEXT` | Latest stack trace |
| `first_occurred_at` | `TEXT` | ISO-8601 UTC timestamp of the first occurrence |
| `last_occurred_at` | `TEXT` | ISO-8601 UTC timestamp of the latest occurrence |
| `occurrence_count` | `INTEGER` | Total number of times this grouped exception has occurred |
| `is_handled` | `INTEGER` | `1` if recorded as a handled exception, `0` for unhandled crashes |

### `exception_occurrences` (Individual Occurrences)

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Unique occurrence record identifier |
| `exception_id` | `INTEGER` | Foreign key referencing `exceptions(id)` (`ON DELETE CASCADE`) |
| `occurred_at` | `TEXT` | ISO-8601 UTC timestamp when this occurrence happened |
| `stack_trace` | `TEXT` | Stack trace captured for this specific occurrence |
| `is_handled` | `INTEGER` | `1` if this occurrence was handled, `0` for unhandled crash |

## Querying Exceptions

You can inspect the recorded exceptions using the built-in query helpers:

```dart
// Retrieve all grouped exceptions
final List<Map<String, dynamic>> exceptions = await AcExceptor.getExceptions();

// Retrieve all occurrences (or for a specific grouped exception)
final List<Map<String, dynamic>> occurrences = await AcExceptor.getOccurrences(exceptionId: 1);
```

## Multi-threading / Background Isolates

`AcExceptor` handles both **managed** (try/catch) and **unmanaged** (uncaught crashes) in background isolates:

### 1. `Isolate.run(...)` & Flutter `compute(...)`
Any exception (managed or unmanaged) thrown inside `Isolate.run` or `compute` is **automatically captured** by `AcExceptor.runAppGuarded` on the main isolate without any extra configuration.

### 2. Spawning Raw Isolates (`AcExceptor.spawnIsolate`)
When spawning raw isolates with `AcExceptor.spawnIsolate`, any unmanaged crash inside the background isolate is **automatically routed to AcExceptor and saved to SQLite**:

```dart
// Auto-captures unmanaged crashes in the spawned worker isolate:
await AcExceptor.spawnIsolate(myBackgroundWorker, message);
```

Or with raw `Isolate.spawn`:
```dart
Isolate.spawn(
  myBackgroundWorker,
  message,
  onError: AcExceptor.isolateErrorPort.sendPort,
);
```

### 3. Long-Running Worker Isolates
In worker isolates that maintain their own loop, call `await AcExceptor.initialize();` to enable direct SQLite persistence:

```dart
void workerIsolate(SendPort port) async {
  await AcExceptor.initialize(); // Auto-configured for background isolate

  try {
    doHeavyBackgroundWork();
  } catch (e, stack) {
    await AcExceptor.capture(e, stack);
  }
}
```

Check `AcExceptor.isMainIsolate` if you need programmatic isolate inspection.

## Suppressing / Ignoring Exceptions (`acExceptorIgnore`)

If you have specific code where you want any potential exceptions completely ignored—meaning they will **neither crash the application nor be recorded into SQLite**—use the global `acExceptorIgnore` method (or `AcExceptor.ignore`):

```dart
import 'package:ac_exceptor/ac_exceptor.dart';

// Synchronous usage:
final value = acExceptorIgnore<int>(() {
  return riskyCalculations();
}, fallbackValue: 0);

// Asynchronous usage:
final data = await acExceptorIgnore<String>(() async {
  return await thirdPartyService.getOptionalAnalytics();
}, fallbackValue: 'none');
```


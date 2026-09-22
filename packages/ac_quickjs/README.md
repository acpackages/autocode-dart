# ac_quickjs

A high-performance QuickJS JavaScript runtime for **pure Dart** and **Flutter** applications, ported from [`fjs`](https://github.com/fluttercandies/fjs).

`ac_quickjs` preserves 100% of FJS's feature set and execution model while removing the hard `package:flutter/*` dependency from the core package. It works out of the box in pure Dart command-line tools, background services, and backend servers via `dart:ffi`, while continuing to support all Flutter devices (Android, iOS, macOS, Windows, Linux) as an FFI plugin.

---

## Features

- **Dart-First & Flutter-Ready**: Runs in pure Dart CLI/VM applications with zero Flutter dependencies, and consumes identically in Flutter mobile/desktop apps.
- **Powered by QuickJS & LLRT**: High-performance JavaScript ES2023 engine with embedded AWS LLRT modules (`fs`, `fetch`, `timers`, `crypto`, `path`, `process`, `assert`, `buffer`, `url`, `util`, `zlib`, etc.).
- **Zero-Config Native Loading**: Bundled precompiled binaries with an automatic library resolver—no manual DLL/so copying required.
- **Bidirectional Communication**: Call JavaScript from Dart, and call Dart asynchronous callbacks from JavaScript via `fjs.bridge_call()`.
- **Async & Promises**: Seamless mapping between JavaScript Promises and Dart `Future`s.
- **ES6 Modules & Bytecode**: Full support for dynamic module declaration (`declareNewModule`), ES module imports, and precompiled bytecode (`JsBytecode`).
- **Rich Value Types**: Deep bidirectional conversions for `null`, `bool`, `int`, `double`, `String`, `BigInt`, `Uint8List`, `DateTime`, `List`, and `Map`.
- **Fine-Grained Memory Control**: Track runtime memory usage with `engine.memoryUsage()` and invoke garbage collection with `engine.runGc()`.

---

## Supported Platforms

| Platform | Pure Dart CLI / VM | Flutter Application | Native Binary |
| :--- | :---: | :---: | :--- |
| **Windows (x64)** | Supported | Supported | `ac_quickjs.dll` |
| **Linux (x64)** | Supported | Supported | `libac_quickjs.so` |
| **macOS (arm64, x64)** | Supported | Supported | `libac_quickjs.dylib` |
| **Android (arm64, armv7, x64)** | N/A (mobile) | Supported | `libac_quickjs.so` |
| **iOS (arm64, simulator)** | N/A (mobile) | Supported | `ac_quickjs.xcframework` |
| **Web** | Limited / Experimental | Limited / Experimental | QuickJS WASM (LLRT modules rely on OS sockets/threads) |

---

## Installation

Add `ac_quickjs` to your `pubspec.yaml`:

```yaml
dependencies:
  ac_quickjs:
    path: packages/ac_quickjs # within autocode-dart monorepo
```

---

## Quickstart

### Pure Dart CLI

```dart
import 'package:ac_quickjs/ac_quickjs.dart';

void main() async {
  // 1. Create engine (auto-initializes native bindings)
  final engine = await JsEngine.create();
  await engine.initWithoutBridge();

  // 2. Evaluate JavaScript
  final result = await engine.eval(source: JsCode.code('1 + 2 * 3'));
  print('Result: ${result.value}'); // 7

  // 3. Dispose resources
  await engine.close();
}
```

---

## Core Capabilities

### 1. Variables, Closures, and Higher-Order Functions

```dart
final result = await engine.eval(source: JsCode.code('''
  function makeCounter() {
    let count = 0;
    return () => ++count;
  }
  const counter = makeCounter();
  [counter(), counter(), counter()];
'''));

print(result.value); // [1, 2, 3]
```

### 2. Objects, Arrays, and Collections

```dart
final result = await engine.eval(source: JsCode.code('''
  ({
    title: "QuickJS in Dart",
    version: 1.0,
    tags: ["dart", "quickjs", "flutter"]
  })
'''));

final map = result.value as Map;
print(map['title']); // "QuickJS in Dart"
print(map['tags']);  // ["dart", "quickjs", "flutter"]
```

### 3. Promises and Async / Await

```dart
final result = await engine.eval(source: JsCode.code('''
  async function computeAsync() {
    const value = await Promise.resolve(42);
    return value * 2;
  }
  computeAsync();
'''));

print(result.value); // 84
```

### 4. Dart ↔ JavaScript Bridge Callbacks

Register a Dart handler when initializing the engine:

```dart
final engine = await JsEngine.create();
await engine.init(
  bridge: (jsValue) async {
    print('Dart received: ${jsValue.value}');
    return JsResult.ok(JsValue.string('Hello from Dart!'));
  },
);

final result = await engine.eval(source: JsCode.code('''
  const greeting = await fjs.bridge_call("ping from JS");
  greeting;
'''));

print(result.value); // "Hello from Dart!"
```

### 5. ES6 Modules

```dart
// Declare dynamic module
await engine.declareNewModule(
  module: JsModule.code(
    module: 'math-utils',
    code: '''
      export function multiply(a, b) {
        return a * b;
      }
    ''',
  ),
);

// Import and use inside JavaScript
final result = await engine.eval(source: JsCode.code('''
  const { multiply } = await import('math-utils');
  multiply(6, 7);
'''));

print(result.value); // 42
```

### 6. Bytecode Compilation and Execution

```dart
// Compile JavaScript to QuickJS bytecode ahead-of-time
final script = await JsBytecode.compileScript(
  name: 'calc.js',
  source: JsCode.code('100 * 2 + 50'),
);

// Execute precompiled bytecode
final result = await engine.evaluateScriptBytecode(script: script);
print(result.value); // 250
```

### 7. Memory Management & Garbage Collection

```dart
// Inspect memory usage
final mem = await engine.memoryUsage();
print('Memory used: ${mem.memoryUsedSize} bytes');

// Trigger garbage collection
await engine.runGc();
```

---

## Migration from `fjs` to `ac_quickjs`

Migrating from `fjs` to `ac_quickjs` requires only updating the package import:

| Feature | FJS (`package:fjs`) | `ac_quickjs` (`package:ac_quickjs`) |
| :--- | :--- | :--- |
| **Import** | `import 'package:fjs/fjs.dart';` | `import 'package:ac_quickjs/ac_quickjs.dart';` |
| **Engine Creation** | `await JsEngine.create(...)` | `await JsEngine.create(...)` *(auto-initializes)* |
| **Evaluation** | `await engine.eval(source: ...)` | `await engine.eval(source: ...)` |
| **Bridge Calling** | `fjs.bridge_call(...)` | `fjs.bridge_call(...)` |
| **Bytecode** | `JsBytecode.compileScript(...)` | `JsBytecode.compileScript(...)` |
| **Modules** | `engine.declareNewModule(...)` | `engine.declareNewModule(...)` |
| **Disposal** | `await engine.close()` | `await engine.close()` |
| **Flutter SDK Requirement** | Required (`flutter: sdk: flutter`) | **Removed** (Pure Dart package) |
| **Pure Dart CLI Support** | Broken / Manual setup required | **Native & Automatic** (`dart:ffi`) |

---

## License & Attribution

`ac_quickjs` is derived from [`fluttercandies/fjs`](https://github.com/fluttercandies/fjs) by iota9star under the MIT License.
Portions copyright (c) 2026 AutoCode.
Distributed under the MIT License. See [LICENSE](LICENSE) for details.

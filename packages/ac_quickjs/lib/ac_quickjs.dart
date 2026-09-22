/// ac_quickjs - A high-performance QuickJS JavaScript runtime for pure Dart and Flutter.
///
/// Ported from FJS to provide seamless execution in Dart CLI, backend servers,
/// and Flutter applications across Windows, Linux, macOS, Android, and iOS.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:ac_quickjs/ac_quickjs.dart';
///
/// void main() async {
///   final engine = await JsEngine.create();
///   await engine.initWithoutBridge();
///
///   final result = await engine.eval(source: JsCode.code('1 + 2 * 3'));
///   print('Result: ${result.value}'); // 7
///
///   await engine.close();
/// }
/// ```
library;

// Main library initializer & resolver
export 'src/ac_quickjs_init.dart';

// JavaScript API with high-level abstractions
export 'src/frb/api/bytecode.dart';
export 'src/frb/api/engine.dart';

// Error handling
export 'src/frb/api/error.dart';

// Runtime and context
export 'src/frb/api/runtime.dart';

// Source code and modules
export 'src/frb/api/source.dart';

// Value conversion and type handling
export 'src/frb/api/value.dart';

// Low-level generated bindings
export 'src/frb/frb_generated.dart' show LibFjs;

import 'dart:convert';
import 'package:ac_quickjs/ac_quickjs.dart';
import 'package:flutter/foundation.dart';

/// High-performance JavaScript execution runner powered by [ac_quickjs].
///
/// Executes inline scripts, calculated properties, and declarative `run` actions
/// defined within JSON screen descriptors.
class AcQuickJsRunner {
  AcQuickJsRunner._();

  static JsEngine? _engine;
  static bool _initialized = false;
  static bool _initInProgress = false;

  /// Initialize the QuickJS engine. Safe to call multiple times.
  static Future<void> init() async {
    if (_initialized || _initInProgress) return;
    _initInProgress = true;
    try {
      await AcQuickJs.init();
      _engine = await JsEngine.create();
      await _engine!.initWithoutBridge();
      _initialized = true;
      debugPrint('[AcQuickJsRunner] Native QuickJS runtime initialized successfully.');
    } catch (e) {
      debugPrint('[AcQuickJsRunner] Engine initialization failed: $e');
    } finally {
      _initInProgress = false;
    }
  }

  /// Whether the native engine is active and ready.
  static bool get isReady => _initialized && _engine != null;

  /// Execute an inline JavaScript snippet.
  ///
  /// The provided [code] has access to `args` passed in as a JavaScript object.
  /// Example:
  /// ```dart
  /// final total = await AcQuickJsRunner.runInline('return args.qty * args.rate;', args: {'qty': 5, 'rate': 100});
  /// ```
  static Future<dynamic> runInline({
    required String code,
    Map<String, dynamic> args = const {},
  }) async {
    if (!_initialized) {
      await init();
    }
    if (_engine == null) {
      debugPrint('[AcQuickJsRunner] Cannot run JS — engine unavailable.');
      return null;
    }

    try {
      final jsonArgs = jsonEncode(args);
      final wrappedCode = '''
(function(args) {
  $code
})($jsonArgs)
''';
      final result = await _engine!.eval(source: JsCode.code(wrappedCode));
      return result.value;
    } catch (e) {
      debugPrint('[AcQuickJsRunner] Script execution error: $e');
      return null;
    }
  }

  /// Evaluate a raw JavaScript expression and return the parsed result.
  static Future<dynamic> eval(String expression) async {
    if (!_initialized) {
      await init();
    }
    if (_engine == null) return null;

    try {
      final result = await _engine!.eval(source: JsCode.code(expression));
      return result.value;
    } catch (e) {
      debugPrint('[AcQuickJsRunner] Eval error: $e');
      return null;
    }
  }

  /// Execute a named script function from a screen's `scripts` map.
  static Future<dynamic> runNamed({
    required Map<String, String> scripts,
    required String fnName,
    Map<String, dynamic> args = const {},
  }) async {
    final scriptSource = scripts[fnName];
    if (scriptSource == null) {
      debugPrint('[AcQuickJsRunner] Named script "$fnName" not found.');
      return null;
    }

    if (!_initialized) {
      await init();
    }
    if (_engine == null) return null;

    try {
      final jsonArgs = jsonEncode(args);
      final code = '($scriptSource)($jsonArgs)';
      final result = await _engine!.eval(source: JsCode.code(code));
      return result.value;
    } catch (e) {
      debugPrint('[AcQuickJsRunner] Execution of "$fnName" failed: $e');
      return null;
    }
  }
}

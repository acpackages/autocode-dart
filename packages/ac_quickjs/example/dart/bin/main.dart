import 'package:ac_quickjs/ac_quickjs.dart';

void main() async {
  print('=== ac_quickjs Pure Dart CLI Example ===\n');

  // 1. Create engine (auto-initializes native library)
  final engine = await JsEngine.create();
  await engine.init(
    bridge: (value) async {
      print('  [Dart Bridge] JavaScript sent: ${value.value}');
      return JsResult.ok(const JsValue.string('Hello from Dart CLI!'));
    },
  );

  // 2. Evaluate basic expression
  final mathResult = await engine.eval(source: JsCode.code('10 + 20 * 3'));
  print('1. Math evaluation: 10 + 20 * 3 = ${mathResult.value}');

  // 3. Closures & Functions
  final closureResult = await engine.eval(source: JsCode.code('''
    function makeMultiplier(factor) {
      return (n) => n * factor;
    }
    const triple = makeMultiplier(3);
    triple(7);
  '''));
  print('2. Closure result: triple(7) = ${closureResult.value}');

  // 4. Objects and JSON
  final objResult = await engine.eval(source: JsCode.code('''
    ({
      appName: "AutoCode CLI",
      engine: "QuickJS",
      features: ["ES6", "Async/Await", "Pure Dart", "Flutter"]
    })
  '''));
  print('3. Object evaluation: ${objResult.value}');

  // 5. Promises & Async/Await
  final asyncResult = await engine.eval(source: JsCode.code('''
    async function fetchGreeting() {
      return Promise.resolve("Hello from QuickJS Async Promise!");
    }
    fetchGreeting();
  '''));
  print('4. Async Promise: ${asyncResult.value}');

  // 6. Calling Dart Bridge from JavaScript
  final bridgeResult = await engine.eval(source: JsCode.code('''
    fjs.bridge_call("ping from JavaScript environment")
  '''));
  print('5. Bridge call result: ${bridgeResult.value}');

  // 7. Memory statistics
  final mem = await engine.memoryUsage();
  print('6. Memory used: ${(mem.memoryUsedSize / 1024).toStringAsFixed(2)} KB');

  // 8. Close engine
  await engine.close();
  print('\nEngine closed cleanly. Done!');
}

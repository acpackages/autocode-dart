import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ac_quickjs/ac_quickjs.dart';

void main() {
  setUpAll(() async {
    await AcQuickJs.init();
  });

  group('Basic Evaluation', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('evaluates arithmetic expression 1 + 2 * 3 = 7', () async {
      final result = await engine.eval(source: JsCode.code('1 + 2 * 3'));
      expect(result.value, 7);
    });

    test('evaluates boolean logic', () async {
      final rTrue = await engine.eval(source: JsCode.code('true && !false'));
      expect(rTrue.value, true);

      final rFalse = await engine.eval(source: JsCode.code('false || (1 > 2)'));
      expect(rFalse.value, false);
    });

    test('evaluates floating point operations', () async {
      final result = await engine.eval(source: JsCode.code('3.14 * 2'));
      expect(result.value, closeTo(6.28, 0.001));
    });

    test('evaluates string concatenation and templates', () async {
      final result = await engine.eval(
        source: JsCode.code(r'const name = "QuickJS"; `Hello, ${name}!`'),
      );
      expect(result.value, 'Hello, QuickJS!');
    });
  });

  group('Variables & Lexical Scope', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('declares and uses variables', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          const x = 10;
          const y = 20;
          x * y;
        '''),
      );
      expect(result.value, 200);
    });

    test('block scoping with let and const', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          let a = 1;
          {
            let a = 2;
            const b = 3;
          }
          a;
        '''),
      );
      expect(result.value, 1);
    });
  });

  group('Functions & Closures', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('declares and invokes function with parameters', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          function add(a, b) {
            return a + b;
          }
          add(10, 20);
        '''),
      );
      expect(result.value, 30);
    });

    test('creates and calls stateful closures', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          function counter() {
            let value = 0;
            return () => ++value;
          }
          const c = counter();
          c() + c() * 10;
        '''),
      );
      // c() is 1, then second c() is 2 -> 1 + 2 * 10 = 21
      expect(result.value, 21);
    });

    test('higher-order functions', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          const numbers = [1, 2, 3, 4];
          numbers
            .filter(n => n % 2 === 0)
            .map(n => n * 10)
            .reduce((sum, n) => sum + n, 0);
        '''),
      );
      // filter: [2, 4], map: [20, 40], reduce: 60
      expect(result.value, 60);
    });
  });

  group('Objects & Arrays', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('evaluates object literal and maps to Dart Map', () async {
      final result = await engine.eval(
        source: JsCode.code('({ name: "test", value: 42, enabled: true })'),
      );
      final map = result.value as Map;
      expect(map['name'], 'test');
      expect(map['value'], 42);
      expect(map['enabled'], true);
    });

    test('evaluates array literal and maps to Dart List', () async {
      final result = await engine.eval(
        source: JsCode.code('[1, 2, 3, 4]'),
      );
      final list = result.value as List;
      expect(list, [1, 2, 3, 4]);
    });

    test('handles nested objects and arrays', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          ({
            user: {
              id: 101,
              profile: { name: "Alice", active: true }
            },
            tags: ["dart", "quickjs", "flutter"]
          })
        '''),
      );
      final map = result.value as Map;
      final user = map['user'] as Map;
      final profile = user['profile'] as Map;
      expect(profile['name'], 'Alice');
      expect(profile['active'], true);
      expect(map['tags'], ['dart', 'quickjs', 'flutter']);
    });
  });

  group('JsValue Conversion System', () {
    test('converts primitive types to JsValue and back', () {
      // null
      final noneVal = JsValue.from(null);
      expect(noneVal.isNone(), true);
      expect(noneVal.value, null);

      // bool
      final boolVal = JsValue.from(true);
      expect(boolVal.isBoolean(), true);
      expect(boolVal.asBoolean, true);
      expect(boolVal.value, true);

      // int
      final intVal = JsValue.from(42);
      expect(intVal.isNumber(), true);
      expect(intVal.asInteger, 42);
      expect(intVal.value, 42);

      // double
      final floatVal = JsValue.from(3.14);
      expect(floatVal.isNumber(), true);
      expect(floatVal.asFloat, 3.14);
      expect(floatVal.value, 3.14);

      // String
      final strVal = JsValue.from('AutoCode');
      expect(strVal.isString(), true);
      expect(strVal.asString, 'AutoCode');
      expect(strVal.value, 'AutoCode');

      // Uint8List
      final bytes = Uint8List.fromList([1, 2, 3]);
      final bytesVal = JsValue.from(bytes);
      expect(bytesVal.isBytes(), true);
      expect(bytesVal.asBytes, bytes);
      expect(bytesVal.value, bytes);
    });

    test('converts collections to JsValue and back', () {
      final list = [1, 'hello', true];
      final jsArray = JsValue.from(list);
      expect(jsArray.isArray(), true);
      expect(jsArray.value, list);

      final map = {'a': 1, 'b': 'two'};
      final jsObj = JsValue.from(map);
      expect(jsObj.isObject(), true);
      expect(jsObj.value, map);
    });
  });

  group('Promises & Async / Await', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('resolves Promise.resolve(42)', () async {
      final result = await engine.eval(
        source: JsCode.code('Promise.resolve(42)'),
      );
      expect(result.value, 42);
    });

    test('evaluates async function', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          async function test() {
            return 42;
          }
          test();
        '''),
      );
      expect(result.value, 42);
    });

    test('evaluates chained Promise', () async {
      final result = await engine.eval(
        source: JsCode.code('''
          Promise.resolve(10)
            .then(x => x * 2)
            .then(x => x + 5);
        '''),
      );
      expect(result.value, 25);
    });
  });

  group('Exceptions & Error Handling', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('catches thrown error as JsError', () async {
      expect(
        () => engine.eval(source: JsCode.code('throw new Error("test error");')),
        throwsA(isA<JsError>()),
      );
    });

    test('catches reference error for undefined variable', () async {
      expect(
        () => engine.eval(source: JsCode.code('nonExistentVar + 1;')),
        throwsA(isA<JsError>()),
      );
    });

    test('catches syntax error', () async {
      expect(
        () => engine.eval(source: JsCode.code('const = ;')),
        throwsA(isA<JsError>()),
      );
    });
  });

  group('Dart-JS Bridge Communication', () {
    late JsEngine engine;
    late List<String> receivedMessages;

    setUp(() async {
      receivedMessages = [];
      engine = await JsEngine.create();
      await engine.init(
        bridge: (jsVal) async {
          final msg = jsVal.value.toString();
          receivedMessages.add(msg);
          return JsResult.ok(JsValue.string('Dart received: $msg'));
        },
      );
    });

    tearDown(() async {
      await engine.close();
    });

    test('calls Dart bridge callback from JavaScript and receives response', () async {
      final result = await engine.eval(
        source: JsCode.code('fjs.bridge_call("ping")'),
      );
      expect(receivedMessages, ['ping']);
      expect(result.value, 'Dart received: ping');
    });

    test('handles multiple sequential bridge calls', () async {
      final result = await engine.eval(
        source: JsCode.code(r'''
          const a = await fjs.bridge_call("first");
          const b = await fjs.bridge_call("second");
          `${a} | ${b}`;
        '''),
      );
      expect(receivedMessages, ['first', 'second']);
      expect(result.value, 'Dart received: first | Dart received: second');
    });
  });

  group('Modules', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('declares and imports dynamic module', () async {
      await engine.declareNewModule(
        module: JsModule.code(
          module: 'math',
          code: '''
            export function multiply(a, b) {
              return a * b;
            }
          ''',
        ),
      );

      final isDeclared = await engine.isModuleDeclared(moduleName: 'math');
      expect(isDeclared, true);

      final result = await engine.eval(
        source: JsCode.code('''
          const { multiply } = await import('math');
          multiply(6, 7);
        '''),
      );
      expect(result.value, 42);
    });
  });

  group('Bytecode Compilation & Execution', () {
    late JsEngine engine;

    setUp(() async {
      engine = await JsEngine.create();
      await engine.initWithoutBridge();
    });

    tearDown(() async {
      await engine.close();
    });

    test('compiles and executes script bytecode', () async {
      final script = await JsBytecode.compileScript(
        name: 'test.js',
        source: JsCode.code('20 + 22'),
      );
      expect(script, isNotNull);

      final result = await engine.evaluateScriptBytecode(script: script);
      expect(result.value, 42);
    });
  });

  group('Lifecycle & Disposal', () {
    test('creates, uses, and closes engine repeatedly', () async {
      for (var i = 0; i < 5; i++) {
        final eng = await JsEngine.create();
        await eng.initWithoutBridge();
        final r = await eng.eval(source: JsCode.code('$i * 10'));
        expect(r.value, i * 10);
        expect(eng.closed, false);
        await eng.close();
        expect(eng.closed, true);
      }
    });

    test('reports memory usage metrics', () async {
      final engine = await JsEngine.create();
      await engine.initWithoutBridge();
      final mem = await engine.memoryUsage();
      expect(mem.memoryUsedSize, greaterThan(0));
      expect(mem.mallocCount, greaterThan(0));
      await engine.close();
    });
  });
}

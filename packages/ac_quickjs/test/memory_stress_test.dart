import 'package:test/test.dart';
import 'package:ac_quickjs/ac_quickjs.dart';

void main() {
  setUpAll(() async {
    await AcQuickJs.init();
  });

  group('Memory & Stress Tests', () {
    test('allocates and converts thousands of values', () async {
      final engine = await JsEngine.create();
      await engine.initWithoutBridge();

      // Create an array with 10,000 integers in JavaScript
      final result = await engine.eval(
        source: JsCode.code('''
          const arr = [];
          for (let i = 0; i < 10000; i++) {
            arr.push(i * 2);
          }
          arr.length;
        '''),
      );
      expect(result.value, 10000);

      // Verify memory usage is reported
      final mem = await engine.memoryUsage();
      expect(mem.memoryUsedSize, greaterThan(0));

      await engine.close();
    });

    test('rapid sequential script evaluation', () async {
      final engine = await JsEngine.create();
      await engine.initWithoutBridge();

      for (var i = 0; i < 100; i++) {
        final r = await engine.eval(source: JsCode.code('$i + 1'));
        expect(r.value, i + 1);
      }

      await engine.close();
    });

    test('deep object hierarchy', () async {
      final engine = await JsEngine.create();
      await engine.initWithoutBridge();

      final result = await engine.eval(
        source: JsCode.code('''
          let obj = { depth: 0 };
          let curr = obj;
          for (let i = 1; i <= 20; i++) {
            curr.next = { depth: i };
            curr = curr.next;
          }
          curr.depth;
        '''),
      );
      expect(result.value, 20);

      await engine.close();
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ac_calculator/ac_calculator.dart';

void main() {
  group('Standard & Scientific Calculations', () {
    late CalculatorLogic logic;

    setUp(() {
      logic = CalculatorLogic();
    });

    test('Basic Arithmetic: 12 + 25 = 37', () {
      logic.inputDigit('1');
      logic.inputDigit('2');
      logic.setOperator('+');
      logic.inputDigit('2');
      logic.inputDigit('5');
      logic.calculateEquals();
      expect(logic.display, '37');
    });

    test('Chained operations: 10 + 5 * 2', () {
      logic.inputDigit('1');
      logic.inputDigit('0');
      logic.setOperator('+');
      logic.inputDigit('5');
      logic.setOperator('×'); // 10 + 5 evaluates to 15
      expect(logic.display, '15');
      logic.inputDigit('2');
      logic.calculateEquals(); // 15 * 2 = 30
      expect(logic.display, '30');
    });

    test('Repeated equals: 1 + 2 = 3, = 5, = 7', () {
      logic.inputDigit('1');
      logic.setOperator('+');
      logic.inputDigit('2');
      logic.calculateEquals();
      expect(logic.display, '3');
      logic.calculateEquals();
      expect(logic.display, '5');
      logic.calculateEquals();
      expect(logic.display, '7');
    });

    test('Context-sensitive percentage addition: 200 + 10% = 220', () {
      logic.inputDigit('2');
      logic.inputDigit('0');
      logic.inputDigit('0');
      logic.setOperator('+');
      logic.inputDigit('1');
      logic.inputDigit('0');
      logic.inputPercentage(); // 10% of 200 is 20
      expect(logic.display, '20');
      logic.calculateEquals();
      expect(logic.display, '220');
    });

    test('Context-sensitive percentage multiplication: 200 * 10% = 20', () {
      logic.inputDigit('2');
      logic.inputDigit('0');
      logic.inputDigit('0');
      logic.setOperator('×');
      logic.inputDigit('1');
      logic.inputDigit('0');
      logic.inputPercentage(); // 10% = 0.1
      expect(logic.display, '0.1');
      logic.calculateEquals();
      expect(logic.display, '20');
    });

    test('Division by zero handles error gracefully', () {
      logic.inputDigit('5');
      logic.setOperator('÷');
      logic.inputDigit('0');
      logic.calculateEquals();
      expect(logic.hasError, isTrue);
      expect(logic.display, 'Cannot divide by zero');
    });

    test('Sign toggle and Backspace', () {
      logic.inputDigit('5');
      logic.inputDigit('0');
      logic.toggleSign();
      expect(logic.display, '-50');
      logic.backspace();
      expect(logic.display, '-5');
      logic.toggleSign();
      expect(logic.display, '5');
    });

    test('Scientific unary functions: sqrt, sqr, reciprocal, sin', () {
      logic.inputDigit('9');
      logic.applyUnary('√x');
      expect(logic.display, '3');

      logic.applyUnary('x²');
      expect(logic.display, '9');

      logic.applyUnary('1/x');
      expect(logic.display.startsWith('0.1111'), isTrue);

      logic.clearAll();
      logic.angleMode = AngleMode.degree;
      logic.inputDigit('9');
      logic.inputDigit('0');
      logic.applyUnary('sin');
      expect(logic.display, '1');
    });
  });

  group('Programmer Calculator', () {
    late CalculatorLogic logic;

    setUp(() {
      logic = CalculatorLogic(mode: CalculatorMode.programmer);
    });

    test('Base conversion & bit masking (DWORD 32-bit)', () {
      logic.wordSize = ProgrammerWordSize.dword;
      logic.programmerBase = ProgrammerBase.dec;
      logic.inputDigit('2');
      logic.inputDigit('5');
      logic.inputDigit('5');

      expect(
        logic.formatProgrammerValue(logic.programmerValue, ProgrammerBase.hex),
        'FF',
      );
      expect(
        logic.formatProgrammerValue(logic.programmerValue, ProgrammerBase.bin),
        '1111 1111',
      );
      expect(
        logic.formatProgrammerValue(logic.programmerValue, ProgrammerBase.oct),
        '377',
      );
    });

    test('Bitwise operations: 0x0F AND 0x06 = 0x06', () {
      logic.programmerBase = ProgrammerBase.hex;
      logic.inputDigit('F');
      logic.setOperator('AND');
      logic.inputDigit('6');
      logic.calculateEquals();
      expect(
        logic.formatProgrammerValue(logic.programmerValue, ProgrammerBase.hex),
        '6',
      );
    });

    test('Word size truncation: 0x10000 on WORD (16-bit) masks to 0', () {
      logic.wordSize = ProgrammerWordSize.word;
      logic.programmerBase = ProgrammerBase.hex;
      logic.inputDigit('1');
      logic.inputDigit('0');
      logic.inputDigit('0');
      logic.inputDigit('0');
      logic.inputDigit('0');
      expect(
        logic.formatProgrammerValue(logic.programmerValue, ProgrammerBase.hex),
        '0',
      );
    });

    test('Bitwise NOT on BYTE (8-bit): NOT 0x00 = 0xFF', () {
      logic.wordSize = ProgrammerWordSize.byte;
      logic.programmerBase = ProgrammerBase.hex;
      logic.programmerNot();
      expect(
        logic.formatProgrammerValue(logic.programmerValue, ProgrammerBase.hex),
        'FF',
      );
    });
  });

  group('MathExpressionEvaluator', () {
    test('Operator precedence and parentheses', () {
      final eval = MathExpressionEvaluator();
      expect(eval.evaluate('2 + 3 * 4'), 14.0);
      expect(eval.evaluate('(2 + 3) * 4'), 20.0);
      expect(eval.evaluate('2^3 + 1'), 9.0);
      expect(eval.evaluate('10 / 2 - 3'), 2.0);
    });

    test('Variables and functions', () {
      final eval = MathExpressionEvaluator(variables: {'x': 5.0, 'y': 2.0});
      expect(eval.evaluate('x * y + 10'), 20.0);
      expect(eval.evaluate('sqrt(16) + abs(-5)'), 9.0);
    });
  });

  group('UnitConverter and DateCalculator', () {
    test('Length conversions', () {
      final m = UnitConverter.units[UnitCategory.length]!.firstWhere(
        (u) => u.id == 'm',
      );
      final ft = UnitConverter.units[UnitCategory.length]!.firstWhere(
        (u) => u.id == 'ft',
      );
      final feet = UnitConverter.convert(
        category: UnitCategory.length,
        from: m,
        to: ft,
        value: 1.0,
      );
      expect((feet - 3.28084).abs() < 0.001, isTrue);
    });

    test('Temperature conversions with offsets', () {
      final c = UnitConverter.units[UnitCategory.temperature]!.firstWhere(
        (u) => u.id == 'c',
      );
      final f = UnitConverter.units[UnitCategory.temperature]!.firstWhere(
        (u) => u.id == 'f',
      );
      expect(
        UnitConverter.convert(
          category: UnitCategory.temperature,
          from: c,
          to: f,
          value: 0.0,
        ),
        32.0,
      );
      expect(
        UnitConverter.convert(
          category: UnitCategory.temperature,
          from: c,
          to: f,
          value: 100.0,
        ),
        212.0,
      );
    });

    test('Date Difference Calculation', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 3, 15);
      final diff = DateCalculator.difference(start, end);
      expect(diff.months, 2);
      expect(diff.days, 14);
      expect(diff.totalDays, 73);
    });

    test('Date Duration Addition with Month Overflow', () {
      final start = DateTime(2026, 1, 31);
      final res = DateCalculator.addDuration(
        start,
        months: 1,
      ); // 2026 is non-leap, Feb has 28 days
      expect(res.month, 2);
      expect(res.day, 28);
    });
  });

  group('Math Notes Engine', () {
    test('Evaluates assignments and dependent expressions', () {
      final engine = MathNotesEngine();
      final lines = ['x = 10', 'y = 20', 'x + y', 'total = (x + y) * 2'];
      final res = engine.evaluateLines(lines);
      expect(res[0].result, '10');
      expect(res[1].result, '20');
      expect(res[2].result, '30');
      expect(res[3].result, '60');
    });

    test('Evaluates unit conversions in notes', () {
      final engine = MathNotesEngine();
      final res = engine.evaluateLines(['1000 m to km']);
      expect(res[0].result, '1 km');
    });
  });

  group('Memory and History', () {
    test('Stores and recalls memory without clearing on clearAll', () {
      final logic = CalculatorLogic();
      logic.inputDigit('5');
      logic.memoryStore();
      expect(logic.currentMemory, 5.0);

      logic.clearAll();
      expect(logic.display, '0');
      expect(logic.currentMemory, 5.0);

      logic.memoryAdd(); // display 0, adds 0
      expect(logic.currentMemory, 5.0);

      logic.inputDigit('3');
      logic.memoryAdd();
      expect(logic.currentMemory, 8.0);
    });
  });
}

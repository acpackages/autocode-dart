import 'dart:math' as math;

/// Calculation mode
enum CalculatorMode {
  standard,
  scientific,
  programmer,
  graphing,
  date,
  converter,
  mathNotes,
}

/// Programmer bit widths
enum ProgrammerWordSize {
  qword(64, 'QWORD'),
  dword(32, 'DWORD'),
  word(16, 'WORD'),
  byte(8, 'BYTE');

  final int bits;
  final String label;
  const ProgrammerWordSize(this.bits, this.label);
}

/// Programmer bases
enum ProgrammerBase {
  hex(16, 'HEX'),
  dec(10, 'DEC'),
  oct(8, 'OCT'),
  bin(2, 'BIN');

  final int radix;
  final String label;
  const ProgrammerBase(this.radix, this.label);
}

/// Angle mode for scientific calculations
enum AngleMode { degree, radian }

/// History item
class HistoryItem {
  final String expression;
  final String result;
  final DateTime timestamp;

  HistoryItem({
    required this.expression,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Calculation engine and state manager for standard, scientific, and programmer modes.
class CalculatorLogic {
  CalculatorMode mode;
  AngleMode angleMode;
  ProgrammerWordSize wordSize;
  ProgrammerBase programmerBase;

  // Display & input state
  String _display = '0';
  String _expressionPreview = '';
  String? _errorMessage;

  // Standard/Scientific calculation registers
  double? _firstOperand;
  String? _pendingOperator; // '+', '-', '×', '÷', '^', 'yroot', 'mod'
  bool _startNewInput = true;

  // Repeated equals state
  String? _lastOperator;
  double? _lastOperand;

  // Memory registers
  final List<double> _memoryList = [];

  // History register
  final List<HistoryItem> _history = [];

  // Programmer state
  BigInt _programmerValue = BigInt.zero;
  String? _progPendingOp; // AND, OR, XOR, LSH, RSH, ADD, SUB, MUL, DIV, MOD
  BigInt? _progFirstOperand;

  CalculatorLogic({
    this.mode = CalculatorMode.standard,
    this.angleMode = AngleMode.degree,
    this.wordSize = ProgrammerWordSize.qword,
    this.programmerBase = ProgrammerBase.dec,
  });

  // Getters
  String get display => _errorMessage ?? _formatDisplay();
  String get rawDisplay => _display;
  String get expressionPreview => _expressionPreview;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  List<double> get memoryList => List.unmodifiable(_memoryList);
  double? get currentMemory =>
      _memoryList.isNotEmpty ? _memoryList.first : null;
  List<HistoryItem> get history => List.unmodifiable(_history);
  BigInt get programmerValue => _maskToWordSize(_programmerValue);

  String _formatDisplay() {
    if (mode == CalculatorMode.programmer) {
      return formatProgrammerValue(programmerValue, programmerBase);
    }
    // Number grouping for standard/scientific
    if (_display.contains('e') || _display.contains('E')) {
      return _display;
    }
    final parts = _display.split('.');
    final whole = parts[0];
    final isNegative = whole.startsWith('-');
    final absWhole = isNegative ? whole.substring(1) : whole;

    // Group whole part
    final buffer = StringBuffer();
    for (int i = 0; i < absWhole.length; i++) {
      if (i > 0 && (absWhole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(absWhole[i]);
    }
    final formattedWhole = (isNegative ? '-' : '') + buffer.toString();
    if (parts.length > 1) {
      return '$formattedWhole.${parts[1]}';
    }
    return formattedWhole;
  }

  // --- Reset & Clear Operations ---
  void clearAll() {
    _display = '0';
    _expressionPreview = '';
    _errorMessage = null;
    _firstOperand = null;
    _pendingOperator = null;
    _lastOperator = null;
    _lastOperand = null;
    _startNewInput = true;
    _programmerValue = BigInt.zero;
    _progFirstOperand = null;
    _progPendingOp = null;
  }

  void clearEntry() {
    _errorMessage = null;
    if (mode == CalculatorMode.programmer) {
      _programmerValue = BigInt.zero;
    } else {
      _display = '0';
    }
    _startNewInput = true;
  }

  void backspace() {
    if (_errorMessage != null) {
      clearAll();
      return;
    }
    if (mode == CalculatorMode.programmer) {
      final str = formatProgrammerValue(programmerValue, programmerBase);
      if (str.length <= 1) {
        _programmerValue = BigInt.zero;
      } else {
        final newStr = str.substring(0, str.length - 1);
        _programmerValue =
            BigInt.tryParse(newStr, radix: programmerBase.radix) ?? BigInt.zero;
      }
      return;
    }

    if (_startNewInput) return;
    if (_display.length <= 1 ||
        (_display.length == 2 && _display.startsWith('-'))) {
      _display = '0';
      _startNewInput = true;
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  // --- Digit & Decimal Input ---
  void inputDigit(String digit) {
    if (_errorMessage != null) clearAll();

    if (mode == CalculatorMode.programmer) {
      // Validate digit against active base
      final validChars = switch (programmerBase) {
        ProgrammerBase.bin => '01',
        ProgrammerBase.oct => '01234567',
        ProgrammerBase.dec => '0123456789',
        ProgrammerBase.hex => '0123456789ABCDEFabcdef',
      };
      if (!validChars.contains(digit)) return;

      if (_startNewInput) {
        _programmerValue = BigInt.parse(digit, radix: programmerBase.radix);
        _startNewInput = false;
      } else {
        final currentStr = formatProgrammerValue(
          programmerValue,
          programmerBase,
        );
        final newStr =
            (currentStr == '0' ? '' : currentStr) + digit.toUpperCase();
        try {
          final parsed = BigInt.parse(newStr, radix: programmerBase.radix);
          _programmerValue = _maskToWordSize(parsed);
        } catch (_) {}
      }
      return;
    }

    if (_startNewInput) {
      _display = digit;
      _startNewInput = false;
    } else {
      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    }
  }

  void inputDecimal() {
    if (mode == CalculatorMode.programmer)
      return; // Programmer mode is integer only
    if (_errorMessage != null) clearAll();

    if (_startNewInput) {
      _display = '0.';
      _startNewInput = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void toggleSign() {
    if (_errorMessage != null) return;
    if (mode == CalculatorMode.programmer) {
      // Two's complement negation
      _programmerValue = _maskToWordSize(-_programmerValue);
      return;
    }

    if (_display == '0') return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
  }

  // --- Percentage (Context-Sensitive Reference Logic) ---
  void inputPercentage() {
    if (mode == CalculatorMode.programmer || _errorMessage != null) return;
    final current = double.tryParse(_display) ?? 0.0;

    if (_firstOperand != null && _pendingOperator != null) {
      // Context sensitive:
      // 200 + 10% -> 10% of 200 = 20
      // 200 - 10% -> 20
      // 200 × 10% -> 0.1
      // 200 ÷ 10% -> 0.1
      if (_pendingOperator == '+' || _pendingOperator == '-') {
        final pctVal = _firstOperand! * (current / 100.0);
        _display = _formatNumber(pctVal);
      } else {
        final pctVal = current / 100.0;
        _display = _formatNumber(pctVal);
      }
    } else {
      // Standalone: divide by 100
      _display = _formatNumber(current / 100.0);
    }
  }

  // --- Basic Binary Operators (+, -, ×, ÷, etc.) ---
  void setOperator(String op) {
    if (_errorMessage != null) return;

    if (mode == CalculatorMode.programmer) {
      _handleProgrammerOperator(op);
      return;
    }

    final currentVal = double.tryParse(_display) ?? 0.0;

    if (_pendingOperator != null && !_startNewInput) {
      // Evaluate chained operator: e.g. 5 + 3 + -> calculate 8 first
      _calculateResult(isEquals: false);
    } else {
      _firstOperand = currentVal;
    }

    _pendingOperator = op;
    _expressionPreview = '${_formatNumber(_firstOperand!)} $op';
    _startNewInput = true;
    _lastOperator = null;
    _lastOperand = null;
  }

  // --- Equals & Repeated Equals ---
  void calculateEquals() {
    if (_errorMessage != null) return;

    if (mode == CalculatorMode.programmer) {
      _handleProgrammerEquals();
      return;
    }

    _calculateResult(isEquals: true);
  }

  void _calculateResult({required bool isEquals}) {
    final currentVal = double.tryParse(_display) ?? 0.0;

    if (_pendingOperator != null) {
      final op = _pendingOperator!;
      final a = _firstOperand ?? 0.0;
      final b = currentVal;

      final res = _applyBinaryOp(a, b, op);
      if (res == null) {
        _errorMessage = 'Cannot divide by zero';
        return;
      }

      final expr = '$a $op $b =';
      _history.insert(
        0,
        HistoryItem(expression: expr, result: _formatNumber(res)),
      );

      _display = _formatNumber(res);
      _firstOperand = res;
      _lastOperator = op;
      _lastOperand = b;

      if (isEquals) {
        _expressionPreview = '$expr';
        _pendingOperator = null;
      } else {
        _expressionPreview = '${_formatNumber(res)} $op';
      }
      _startNewInput = true;
    } else if (isEquals && _lastOperator != null && _lastOperand != null) {
      // Repeated equals: e.g., 1 + 2 = (3), = (5), = (7)...
      final a = currentVal;
      final b = _lastOperand!;
      final op = _lastOperator!;
      final res = _applyBinaryOp(a, b, op);
      if (res == null) {
        _errorMessage = 'Cannot divide by zero';
        return;
      }
      _display = _formatNumber(res);
      _expressionPreview = '$a $op $b =';
      _history.insert(
        0,
        HistoryItem(expression: _expressionPreview, result: _formatNumber(res)),
      );
      _startNewInput = true;
    }
  }

  double? _applyBinaryOp(double a, double b, String op) {
    return switch (op) {
      '+' => a + b,
      '-' => a - b,
      '×' || '*' => a * b,
      '÷' || '/' => b == 0 ? null : a / b,
      '^' || 'x^y' => math.pow(a, b).toDouble(),
      'yroot' => b == 0 ? null : math.pow(a, 1.0 / b).toDouble(),
      'mod' => b == 0 ? null : (a % b),
      _ => b,
    };
  }

  // --- Unary Scientific & Standard Functions ---
  void applyUnary(String func) {
    if (_errorMessage != null) return;
    final current = double.tryParse(_display) ?? 0.0;
    double? result;
    String exprStr = '$func($current)';

    switch (func) {
      case '1/x':
        if (current == 0) {
          _errorMessage = 'Cannot divide by zero';
          return;
        }
        result = 1.0 / current;
        exprStr = '1/($current)';
        break;
      case 'x²':
        result = current * current;
        exprStr = 'sqr($current)';
        break;
      case 'x³':
        result = current * current * current;
        exprStr = 'cube($current)';
        break;
      case '√x' || 'sqrt':
        if (current < 0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = math.sqrt(current);
        exprStr = '√($current)';
        break;
      case '∛x' || 'cbrt':
        result =
            current >= 0
                ? math.pow(current, 1.0 / 3.0).toDouble()
                : -math.pow(-current, 1.0 / 3.0).toDouble();
        exprStr = 'cbrt($current)';
        break;
      case '10^x':
        result = math.pow(10, current).toDouble();
        exprStr = '10^($current)';
        break;
      case '2^x':
        result = math.pow(2, current).toDouble();
        exprStr = '2^($current)';
        break;
      case 'e^x':
        result = math.exp(current);
        exprStr = 'e^($current)';
        break;
      case 'ln':
        if (current <= 0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = math.log(current);
        exprStr = 'ln($current)';
        break;
      case 'log10' || 'log':
        if (current <= 0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = math.log(current) / math.ln10;
        exprStr = 'log($current)';
        break;
      case 'log2':
        if (current <= 0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = math.log(current) / math.ln2;
        exprStr = 'log2($current)';
        break;
      case 'n!' || 'fact':
        if (current < 0 ||
            current != current.roundToDouble() ||
            current > 170) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = _factorial(current.toInt());
        exprStr = 'fact($current)';
        break;
      case '|x|' || 'abs':
        result = current.abs();
        exprStr = 'abs($current)';
        break;
      // Trigonometric functions
      case 'sin':
        result = math.sin(_toRadians(current));
        break;
      case 'cos':
        result = math.cos(_toRadians(current));
        break;
      case 'tan':
        final rad = _toRadians(current);
        if ((rad / (math.pi / 2)).round() % 2 != 0 &&
            (math.cos(rad).abs() < 1e-15)) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = math.tan(rad);
        break;
      case 'asin':
        if (current < -1.0 || current > 1.0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = _fromRadians(math.asin(current));
        break;
      case 'acos':
        if (current < -1.0 || current > 1.0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = _fromRadians(math.acos(current));
        break;
      case 'atan':
        result = _fromRadians(math.atan(current));
        break;
      case 'sinh':
        result = (math.exp(current) - math.exp(-current)) / 2;
        break;
      case 'cosh':
        result = (math.exp(current) + math.exp(-current)) / 2;
        break;
      case 'tanh':
        result =
            (math.exp(current) - math.exp(-current)) /
            (math.exp(current) + math.exp(-current));
        break;
      case 'asinh':
        result = math.log(current + math.sqrt(current * current + 1));
        break;
      case 'acosh':
        if (current < 1.0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = math.log(current + math.sqrt(current * current - 1));
        break;
      case 'atanh':
        if (current <= -1.0 || current >= 1.0) {
          _errorMessage = 'Invalid input';
          return;
        }
        result = 0.5 * math.log((1 + current) / (1 - current));
        break;
      case 'pi' || 'π':
        result = math.pi;
        exprStr = 'π';
        break;
      case 'e':
        result = math.e;
        exprStr = 'e';
        break;
      case 'rand':
        result = math.Random().nextDouble();
        exprStr = 'rand()';
        break;
    }

    if (result != null) {
      if (result.isNaN || result.isInfinite) {
        _errorMessage = 'Invalid input';
        return;
      }
      _display = _formatNumber(result);
      _expressionPreview = exprStr;
      _startNewInput = true;
    }
  }

  double _toRadians(double angle) {
    return angleMode == AngleMode.degree ? angle * (math.pi / 180.0) : angle;
  }

  double _fromRadians(double rad) {
    return angleMode == AngleMode.degree ? rad * (180.0 / math.pi) : rad;
  }

  double _factorial(int n) {
    if (n <= 1) return 1.0;
    double res = 1.0;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }

  // --- Memory Operations ---
  void memoryClear() {
    _memoryList.clear();
  }

  void memoryRecall() {
    if (_memoryList.isNotEmpty) {
      _display = _formatNumber(_memoryList.first);
      _startNewInput = true;
    }
  }

  void memoryStore() {
    final current = double.tryParse(_display) ?? 0.0;
    _memoryList.insert(0, current);
    _startNewInput = true;
  }

  void memoryAdd() {
    final current = double.tryParse(_display) ?? 0.0;
    if (_memoryList.isEmpty) {
      _memoryList.add(current);
    } else {
      _memoryList[0] = _memoryList[0] + current;
    }
    _startNewInput = true;
  }

  void memorySubtract() {
    final current = double.tryParse(_display) ?? 0.0;
    if (_memoryList.isEmpty) {
      _memoryList.add(-current);
    } else {
      _memoryList[0] = _memoryList[0] - current;
    }
    _startNewInput = true;
  }

  // --- History Operations ---
  void clearHistory() {
    _history.clear();
  }

  void removeHistoryAt(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
    }
  }

  void restoreHistory(HistoryItem item) {
    _display = item.result;
    _expressionPreview = item.expression;
    _startNewInput = true;
  }

  // --- Programmer Mode Logic ---
  BigInt _maskToWordSize(BigInt val) {
    final bits = wordSize.bits;
    final mask = (BigInt.one << bits) - BigInt.one;
    return val & mask;
  }

  void _handleProgrammerOperator(String op) {
    if (_progPendingOp != null && !_startNewInput) {
      _handleProgrammerEquals();
    } else {
      _progFirstOperand = programmerValue;
    }
    _progPendingOp = op;
    _startNewInput = true;
  }

  void _handleProgrammerEquals() {
    if (_progPendingOp != null && _progFirstOperand != null) {
      final a = _progFirstOperand!;
      final b = programmerValue;
      BigInt res = BigInt.zero;

      switch (_progPendingOp) {
        case 'AND':
          res = a & b;
          break;
        case 'OR':
          res = a | b;
          break;
        case 'XOR':
          res = a ^ b;
          break;
        case 'LSH':
          res = a << b.toInt();
          break;
        case 'RSH':
          res = a >> b.toInt();
          break;
        case '+':
          res = a + b;
          break;
        case '-':
          res = a - b;
          break;
        case '×' || '*':
          res = a * b;
          break;
        case '÷' || '/':
          if (b == BigInt.zero) {
            _errorMessage = 'Cannot divide by zero';
            return;
          }
          res = a ~/ b;
          break;
        case 'MOD':
          if (b == BigInt.zero) {
            _errorMessage = 'Cannot divide by zero';
            return;
          }
          res = a % b;
          break;
      }

      _programmerValue = _maskToWordSize(res);
      _history.insert(
        0,
        HistoryItem(
          expression:
              '${formatProgrammerValue(a, programmerBase)} $_progPendingOp ${formatProgrammerValue(b, programmerBase)} =',
          result: formatProgrammerValue(_programmerValue, programmerBase),
        ),
      );
      _progPendingOp = null;
      _progFirstOperand = null;
      _startNewInput = true;
    }
  }

  void programmerNot() {
    final bits = wordSize.bits;
    final mask = (BigInt.one << bits) - BigInt.one;
    _programmerValue = (~programmerValue) & mask;
  }

  void toggleBit(int bitIndex) {
    if (bitIndex < 0 || bitIndex >= wordSize.bits) return;
    final bitMask = BigInt.one << bitIndex;
    _programmerValue = programmerValue ^ bitMask;
  }

  String formatProgrammerValue(BigInt val, ProgrammerBase base) {
    final masked = _maskToWordSize(val);
    switch (base) {
      case ProgrammerBase.hex:
        return masked.toRadixString(16).toUpperCase();
      case ProgrammerBase.dec:
        // Signed interpretation if highest bit set
        final bits = wordSize.bits;
        final signBit = BigInt.one << (bits - 1);
        if ((masked & signBit) != BigInt.zero) {
          // Negative
          final fullRange = BigInt.one << bits;
          final signedVal = masked - fullRange;
          return signedVal.toString();
        }
        return masked.toString();
      case ProgrammerBase.oct:
        return masked.toRadixString(8);
      case ProgrammerBase.bin:
        final rawBin = masked.toRadixString(2);
        // Pad to 4-bit boundaries for clean grouping
        final targetLen = ((rawBin.length + 3) ~/ 4) * 4;
        final padded = rawBin.padLeft(targetLen == 0 ? 4 : targetLen, '0');
        // Group in 4s
        final buffer = StringBuffer();
        for (int i = 0; i < padded.length; i++) {
          if (i > 0 && i % 4 == 0) buffer.write(' ');
          buffer.write(padded[i]);
        }
        return buffer.toString();
    }
  }

  // Formatter helper
  static String _formatNumber(double val) {
    if (val.isNaN) return 'Error';
    if (val.isInfinite) return val.isNegative ? '-Infinity' : 'Infinity';

    // Avoid -0
    if (val.abs() < 1e-15) val = 0.0;

    // Check if integer
    if (val == val.roundToDouble() && val.abs() < 1e15) {
      return val.toInt().toString();
    }

    // High precision with trailing zero removal
    String str = val.toStringAsPrecision(12);
    if (str.contains('.')) {
      while (str.endsWith('0')) {
        str = str.substring(0, str.length - 1);
      }
      if (str.endsWith('.')) {
        str = str.substring(0, str.length - 1);
      }
    }
    return str;
  }
}

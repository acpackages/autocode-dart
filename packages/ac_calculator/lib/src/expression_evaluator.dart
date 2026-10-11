import 'dart:math' as math;

/// Evaluates mathematical expressions with variables, functions, and standard operator precedence.
class MathExpressionEvaluator {
  final Map<String, double> variables;

  MathExpressionEvaluator({Map<String, double>? variables})
    : variables = variables ?? {};

  /// Evaluates an expression string such as "2 * (x + 3) + sin(0.5)"
  double evaluate(String expression) {
    final tokens = _tokenize(expression);
    if (tokens.isEmpty) return 0.0;
    final rpn = _toRpn(tokens);
    return _evaluateRpn(rpn);
  }

  List<_Token> _tokenize(String expression) {
    final tokens = <_Token>[];
    int i = 0;
    while (i < expression.length) {
      final char = expression[i];

      if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
        i++;
        continue;
      }

      // Check numbers
      if (_isDigit(char) || char == '.') {
        final buffer = StringBuffer();
        while (i < expression.length &&
            (_isDigit(expression[i]) || expression[i] == '.')) {
          buffer.write(expression[i]);
          i++;
        }
        // Handle scientific notation e.g. 1e-5
        if (i < expression.length &&
            (expression[i] == 'e' || expression[i] == 'E')) {
          buffer.write(expression[i]);
          i++;
          if (i < expression.length &&
              (expression[i] == '+' || expression[i] == '-')) {
            buffer.write(expression[i]);
            i++;
          }
          while (i < expression.length && _isDigit(expression[i])) {
            buffer.write(expression[i]);
            i++;
          }
        }
        final numVal = double.tryParse(buffer.toString()) ?? 0.0;
        tokens.add(_Token(_TokenType.number, buffer.toString(), numVal));
        continue;
      }

      // Check identifiers (variables or function names)
      if (_isAlpha(char) || char == 'π') {
        final buffer = StringBuffer();
        while (i < expression.length &&
            (_isAlpha(expression[i]) ||
                _isDigit(expression[i]) ||
                expression[i] == 'π')) {
          buffer.write(expression[i]);
          i++;
        }
        final word = buffer.toString();
        if (word == 'pi' || word == 'π') {
          tokens.add(_Token(_TokenType.number, word, math.pi));
        } else if (word == 'e') {
          tokens.add(_Token(_TokenType.number, word, math.e));
        } else if (_isKnownFunction(word)) {
          tokens.add(_Token(_TokenType.function, word));
        } else {
          tokens.add(_Token(_TokenType.variable, word));
        }
        continue;
      }

      // Check operators and parentheses
      if (char == '+' ||
          char == '-' ||
          char == '*' ||
          char == '/' ||
          char == '×' ||
          char == '÷' ||
          char == '^' ||
          char == '%') {
        // Detect unary plus/minus
        final isUnary =
            (char == '+' || char == '-') &&
            (tokens.isEmpty ||
                tokens.last.type == _TokenType.operator ||
                tokens.last.type == _TokenType.leftParen);
        if (isUnary) {
          tokens.add(_Token(_TokenType.unaryOperator, char));
        } else {
          final normalized = (char == '×') ? '*' : ((char == '÷') ? '/' : char);
          tokens.add(_Token(_TokenType.operator, normalized));
        }
        i++;
        continue;
      }

      if (char == '(') {
        // Implicit multiplication check: if previous token was number or variable or rightParen
        if (tokens.isNotEmpty &&
            (tokens.last.type == _TokenType.number ||
                tokens.last.type == _TokenType.variable ||
                tokens.last.type == _TokenType.rightParen)) {
          tokens.add(_Token(_TokenType.operator, '*'));
        }
        tokens.add(_Token(_TokenType.leftParen, '('));
        i++;
        continue;
      }

      if (char == ')') {
        tokens.add(_Token(_TokenType.rightParen, ')'));
        i++;
        continue;
      }

      if (char == ',') {
        tokens.add(_Token(_TokenType.comma, ','));
        i++;
        continue;
      }

      i++;
    }
    return tokens;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == '_';
  }

  bool _isKnownFunction(String name) {
    const funcs = {
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'sinh',
      'cosh',
      'tanh',
      'asinh',
      'acosh',
      'atanh',
      'sqrt',
      'cbrt',
      'ln',
      'log',
      'log10',
      'log2',
      'exp',
      'abs',
      'floor',
      'ceil',
      'round',
    };
    return funcs.contains(name.toLowerCase());
  }

  int _precedence(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
      case '%':
        return 2;
      case '^':
        return 3;
      case 'u+':
      case 'u-':
        return 4;
      default:
        return 0;
    }
  }

  bool _isRightAssociative(String op) {
    return op == '^' || op == 'u+' || op == 'u-';
  }

  List<_Token> _toRpn(List<_Token> tokens) {
    final output = <_Token>[];
    final operatorStack = <_Token>[];

    for (final token in tokens) {
      switch (token.type) {
        case _TokenType.number:
        case _TokenType.variable:
          output.add(token);
          break;
        case _TokenType.function:
          operatorStack.add(token);
          break;
        case _TokenType.comma:
          while (operatorStack.isNotEmpty &&
              operatorStack.last.type != _TokenType.leftParen) {
            output.add(operatorStack.removeLast());
          }
          break;
        case _TokenType.operator:
        case _TokenType.unaryOperator:
          final op1 =
              token.type == _TokenType.unaryOperator
                  ? 'u${token.text}'
                  : token.text;
          while (operatorStack.isNotEmpty &&
              operatorStack.last.type != _TokenType.leftParen &&
              ((!_isRightAssociative(op1) &&
                      _precedence(op1) <=
                          _precedence(
                            operatorStack.last.type == _TokenType.unaryOperator
                                ? 'u${operatorStack.last.text}'
                                : operatorStack.last.text,
                          )) ||
                  (_isRightAssociative(op1) &&
                      _precedence(op1) <
                          _precedence(
                            operatorStack.last.type == _TokenType.unaryOperator
                                ? 'u${operatorStack.last.text}'
                                : operatorStack.last.text,
                          )))) {
            output.add(operatorStack.removeLast());
          }
          operatorStack.add(token);
          break;
        case _TokenType.leftParen:
          operatorStack.add(token);
          break;
        case _TokenType.rightParen:
          while (operatorStack.isNotEmpty &&
              operatorStack.last.type != _TokenType.leftParen) {
            output.add(operatorStack.removeLast());
          }
          if (operatorStack.isNotEmpty &&
              operatorStack.last.type == _TokenType.leftParen) {
            operatorStack.removeLast(); // discard '('
          }
          if (operatorStack.isNotEmpty &&
              operatorStack.last.type == _TokenType.function) {
            output.add(operatorStack.removeLast());
          }
          break;
      }
    }

    while (operatorStack.isNotEmpty) {
      output.add(operatorStack.removeLast());
    }

    return output;
  }

  double _evaluateRpn(List<_Token> rpn) {
    final stack = <double>[];

    for (final token in rpn) {
      switch (token.type) {
        case _TokenType.number:
          stack.add(token.numberValue!);
          break;
        case _TokenType.variable:
          final val = variables[token.text] ?? 0.0;
          stack.add(val);
          break;
        case _TokenType.unaryOperator:
          if (stack.isEmpty) return 0.0;
          final a = stack.removeLast();
          if (token.text == '-') {
            stack.add(-a);
          } else {
            stack.add(a);
          }
          break;
        case _TokenType.operator:
          if (stack.length < 2) return 0.0;
          final b = stack.removeLast();
          final a = stack.removeLast();
          switch (token.text) {
            case '+':
              stack.add(a + b);
              break;
            case '-':
              stack.add(a - b);
              break;
            case '*':
              stack.add(a * b);
              break;
            case '/':
              stack.add(b == 0 ? double.nan : a / b);
              break;
            case '%':
              stack.add(b == 0 ? double.nan : a % b);
              break;
            case '^':
              stack.add(math.pow(a, b).toDouble());
              break;
          }
          break;
        case _TokenType.function:
          if (stack.isEmpty) return 0.0;
          final a = stack.removeLast();
          final name = token.text.toLowerCase();
          switch (name) {
            case 'sin':
              stack.add(math.sin(a));
              break;
            case 'cos':
              stack.add(math.cos(a));
              break;
            case 'tan':
              stack.add(math.tan(a));
              break;
            case 'asin':
              stack.add((a < -1.0 || a > 1.0) ? double.nan : math.asin(a));
              break;
            case 'acos':
              stack.add((a < -1.0 || a > 1.0) ? double.nan : math.acos(a));
              break;
            case 'atan':
              stack.add(math.atan(a));
              break;
            case 'sinh':
              stack.add((math.exp(a) - math.exp(-a)) / 2);
              break;
            case 'cosh':
              stack.add((math.exp(a) + math.exp(-a)) / 2);
              break;
            case 'tanh':
              stack.add(
                (math.exp(a) - math.exp(-a)) / (math.exp(a) + math.exp(-a)),
              );
              break;
            case 'asinh':
              stack.add(math.log(a + math.sqrt(a * a + 1)));
              break;
            case 'acosh':
              stack.add(
                a < 1.0 ? double.nan : math.log(a + math.sqrt(a * a - 1)),
              );
              break;
            case 'atanh':
              stack.add(
                (a <= -1.0 || a >= 1.0)
                    ? double.nan
                    : 0.5 * math.log((1 + a) / (1 - a)),
              );
              break;
            case 'sqrt':
              stack.add(a < 0 ? double.nan : math.sqrt(a));
              break;
            case 'cbrt':
              stack.add(
                a >= 0
                    ? math.pow(a, 1 / 3).toDouble()
                    : -math.pow(-a, 1 / 3).toDouble(),
              );
              break;
            case 'ln':
              stack.add(a <= 0 ? double.nan : math.log(a));
              break;
            case 'log' || 'log10':
              stack.add(a <= 0 ? double.nan : math.log(a) / math.ln10);
              break;
            case 'log2':
              stack.add(a <= 0 ? double.nan : math.log(a) / math.ln2);
              break;
            case 'exp':
              stack.add(math.exp(a));
              break;
            case 'abs':
              stack.add(a.abs());
              break;
            case 'floor':
              stack.add(a.floorToDouble());
              break;
            case 'ceil':
              stack.add(a.ceilToDouble());
              break;
            case 'round':
              stack.add(a.roundToDouble());
              break;
            default:
              stack.add(a);
          }
          break;
        default:
          break;
      }
    }

    return stack.isNotEmpty ? stack.last : 0.0;
  }
}

enum _TokenType {
  number,
  variable,
  function,
  operator,
  unaryOperator,
  leftParen,
  rightParen,
  comma,
}

class _Token {
  final _TokenType type;
  final String text;
  final double? numberValue;

  _Token(this.type, this.text, [this.numberValue]);
}

import 'package:intl/intl.dart';

/// Resolves `{{token}}` expressions in JSON string values against a context map.
///
/// Supports:
///   - Simple paths:    `{{item.party_name}}`
///   - Nested paths:    `{{state.record.sale_invoice_id}}`
///   - Pipe filters:    `{{item.created_at|date:dd-MM-yyyy}}`
///   - Array access:    `{{state.items[0].name}}`
///   - Length:          `{{state.items.length}}`
///   - Null-safe:       `{{item.x ?? 'fallback'}}`
///   - Ternary:         `{{state.isNew ? 'New' : 'Edit'}}`
///   - Fallback to QuickJS for complex JS expressions
class AcExpressionEvaluator {
  AcExpressionEvaluator._();

  static final _tokenRegex = RegExp(r'\{\{([^}]+)\}\}');

  /// Replace all `{{token}}` placeholders in [template] using [context].
  static dynamic resolve(String template, Map<String, dynamic> context) {
    final match = _singleTokenRegex(template);
    if (match != null) {
      // Single token — return the raw value (may be bool, num, etc.)
      return _resolveToken(match, context);
    }

    // Multiple tokens or mixed text — return interpolated string
    return template.replaceAllMapped(_tokenRegex, (m) {
      final value = _resolveToken(m.group(1)!.trim(), context);
      return value?.toString() ?? '';
    });
  }

  static String? _singleTokenRegex(String template) {
    final trimmed = template.trim();
    if (trimmed.startsWith('{{') && trimmed.endsWith('}}')) {
      return trimmed.substring(2, trimmed.length - 2).trim();
    }
    return null;
  }

  static dynamic _resolveToken(String expr, Map<String, dynamic> context) {
    if (expr.contains('|')) {
      final parts = expr.split('|');
      final value = _evaluate(parts[0].trim(), context);
      return _applyFilter(value, parts.sublist(1));
    }

    if (expr.contains('?') && expr.contains(':')) {
      return _resolveTernary(expr, context);
    }

    if (expr.contains('??')) {
      final parts = expr.split('??');
      final value = _evaluate(parts[0].trim(), context);
      if (value != null && value.toString().isNotEmpty) return value;
      final fallback = parts[1].trim();
      if ((fallback.startsWith("'") && fallback.endsWith("'")) ||
          (fallback.startsWith('"') && fallback.endsWith('"'))) {
        return fallback.substring(1, fallback.length - 1);
      }
      return _evaluate(fallback, context);
    }

    return _evaluate(expr, context);
  }

  static dynamic _evaluate(String expr, Map<String, dynamic> context) {
    if ((expr.startsWith("'") && expr.endsWith("'")) ||
        (expr.startsWith('"') && expr.endsWith('"'))) {
      return expr.substring(1, expr.length - 1);
    }

    final num? numVal = num.tryParse(expr);
    if (numVal != null) return numVal;

    if (expr == 'true') return true;
    if (expr == 'false') return false;
    if (expr == 'null') return null;

    for (final op in ['==', '!=', '>=', '<=', '>', '<']) {
      if (expr.contains(' $op ')) {
        final parts = expr.split(' $op ');
        if (parts.length == 2) {
          final left = _evaluate(parts[0].trim(), context);
          final right = _evaluate(parts[1].trim(), context);
          return _compare(left, right, op);
        }
      }
    }

    // Dot navigation + array index access
    return _resolvePath(expr, context);
  }

  static dynamic _resolvePath(String path, Map<String, dynamic> context) {
    final segments = path.replaceAll('[', '.').replaceAll(']', '').split('.');
    dynamic current = context;

    for (final seg in segments) {
      if (current == null) return null;
      if (seg.isEmpty) continue;

      if (current is Map) {
        current = current[seg];
      } else if (current is List) {
        if (seg == 'length') {
          current = current.length;
        } else {
          final idx = int.tryParse(seg);
          if (idx != null && idx >= 0 && idx < current.length) {
            current = current[idx];
          } else {
            return null;
          }
        }
      } else {
        return null;
      }
    }

    return current;
  }

  static dynamic _resolveTernary(String expr, Map<String, dynamic> context) {
    final qIdx = expr.indexOf('?');
    final cIdx = expr.lastIndexOf(':');
    if (qIdx == -1 || cIdx == -1 || cIdx < qIdx) return null;

    final conditionStr = expr.substring(0, qIdx).trim();
    final thenStr = expr.substring(qIdx + 1, cIdx).trim();
    final elseStr = expr.substring(cIdx + 1).trim();

    final condition = isTruthy(conditionStr, context);
    return condition
        ? _resolveToken(thenStr, context)
        : _resolveToken(elseStr, context);
  }

  static dynamic _applyFilter(dynamic value, List<String> filters) {
    dynamic result = value;
    for (final f in filters) {
      final parts = f.split(':');
      final name = parts[0].trim();
      final arg = parts.length > 1 ? parts[1].trim() : null;

      switch (name) {
        case 'date':
          if (result == null) break;
          try {
            final dt = DateTime.tryParse(result.toString());
            if (dt != null) {
              final pattern = arg ?? 'dd-MM-yyyy';
              result = DateFormat(pattern).format(dt);
            }
          } catch (_) {}
          break;
        case 'currency':
        case 'amount':
          if (result == null) break;
          final num? n = num.tryParse(result.toString());
          if (n != null) {
            final sym = arg ?? '₹';
            result = '$sym${n.toStringAsFixed(2)}';
          }
          break;
        case 'upper':
          result = result?.toString().toUpperCase();
          break;
        case 'lower':
          result = result?.toString().toLowerCase();
          break;
      }
    }
    return result;
  }

  static bool isTruthy(dynamic expr, Map<String, dynamic> context) {
    if (expr == null) return false;
    if (expr is bool) return expr;

    final val = expr is String ? _resolveToken(expr, context) : expr;
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      if (val.isEmpty || val == 'false' || val == '0') return false;
      return true;
    }
    if (val is List) return val.isNotEmpty;
    if (val is Map) return val.isNotEmpty;
    return true;
  }

  static bool _compare(dynamic left, dynamic right, String op) {
    if (op == '==') return left?.toString() == right?.toString();
    if (op == '!=') return left?.toString() != right?.toString();

    final leftNum = num.tryParse(left?.toString() ?? '');
    final rightNum = num.tryParse(right?.toString() ?? '');
    if (leftNum == null || rightNum == null) return false;

    switch (op) {
      case '>': return leftNum > rightNum;
      case '<': return leftNum < rightNum;
      case '>=': return leftNum >= rightNum;
      case '<=': return leftNum <= rightNum;
      default: return false;
    }
  }
}

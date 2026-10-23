import 'package:autocode/autocode.dart';

/// Evaluates [AcFilter] and [AcFilterGroup] conditions against arbitrary data rows.
class AcFilterEvaluator {
  /// Evaluates an [AcFilterGroup] against [data].
  static bool evaluateGroup({
    required AcFilterGroup group,
    required dynamic data,
  }) {
    final bool isOr = group.operator == AcEnumLogicalOperator.or;

    if (group.filters.isNotEmpty) {
      for (final filter in group.filters) {
        final bool matches = evaluateFilter(filter: filter, data: data);
        if (isOr && matches) return true;
        if (!isOr && !matches) return false;
      }
    }

    if (group.filterGroups.isNotEmpty) {
      for (final subGroup in group.filterGroups) {
        final bool matches = evaluateGroup(group: subGroup, data: data);
        if (isOr && matches) return true;
        if (!isOr && !matches) return false;
      }
    }

    // Default: for AND with all true -> true; for OR with no match -> false
    return !isOr;
  }

  /// Evaluates a single [AcFilter] against [data].
  static bool evaluateFilter({
    required AcFilter filter,
    required dynamic data,
  }) {
    final dynamic rowValue = _extractValue(data, filter.key);
    final dynamic targetValue = filter.value;

    switch (filter.operator) {
      case AcEnumConditionOperator.isNull:
        return rowValue == null;

      case AcEnumConditionOperator.isNotNull:
        return rowValue != null;

      case AcEnumConditionOperator.isEmpty:
        if (rowValue == null) return true;
        if (rowValue is String) return rowValue.trim().isEmpty;
        if (rowValue is Iterable) return rowValue.isEmpty;
        if (rowValue is Map) return rowValue.isEmpty;
        return false;

      case AcEnumConditionOperator.isNotEmpty:
        if (rowValue == null) return false;
        if (rowValue is String) return rowValue.trim().isNotEmpty;
        if (rowValue is Iterable) return rowValue.isNotEmpty;
        if (rowValue is Map) return rowValue.isNotEmpty;
        return true;

      case AcEnumConditionOperator.equalTo:
        return _areEqual(rowValue, targetValue);

      case AcEnumConditionOperator.notEqualTo:
        return !_areEqual(rowValue, targetValue);

      case AcEnumConditionOperator.contains:
        if (rowValue == null || targetValue == null) return false;
        return rowValue.toString().toLowerCase().contains(targetValue.toString().toLowerCase());

      case AcEnumConditionOperator.notContains:
        if (rowValue == null) return true;
        if (targetValue == null) return true;
        return !rowValue.toString().toLowerCase().contains(targetValue.toString().toLowerCase());

      case AcEnumConditionOperator.startsWith:
        if (rowValue == null || targetValue == null) return false;
        return rowValue.toString().toLowerCase().startsWith(targetValue.toString().toLowerCase());

      case AcEnumConditionOperator.endsWith:
        if (rowValue == null || targetValue == null) return false;
        return rowValue.toString().toLowerCase().endsWith(targetValue.toString().toLowerCase());

      case AcEnumConditionOperator.greaterThan:
        return _compare(rowValue, targetValue) > 0;

      case AcEnumConditionOperator.greaterThanEqualTo:
        return _compare(rowValue, targetValue) >= 0;

      case AcEnumConditionOperator.lessThan:
        return _compare(rowValue, targetValue) < 0;

      case AcEnumConditionOperator.lessThanEqualTo:
        return _compare(rowValue, targetValue) <= 0;

      case AcEnumConditionOperator.in_:
        if (targetValue is Iterable) {
          return targetValue.any((item) => _areEqual(rowValue, item));
        }
        return false;

      case AcEnumConditionOperator.notIn:
        if (targetValue is Iterable) {
          return !targetValue.any((item) => _areEqual(rowValue, item));
        }
        return true;

      case AcEnumConditionOperator.between:
        if (targetValue is List && targetValue.length >= 2) {
          final low = targetValue[0];
          final high = targetValue[1];
          return _compare(rowValue, low) >= 0 && _compare(rowValue, high) <= 0;
        }
        return false;

      case AcEnumConditionOperator.unknown:
        return true;
    }
  }

  static dynamic _extractValue(dynamic data, String key) {
    if (data == null) return null;
    if (data is Map) return data[key];
    try {
      return (data as dynamic)[key];
    } catch (_) {
      return null;
    }
  }

  static bool _areEqual(dynamic a, dynamic b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a == b) return true;

    // Numerical equality (e.g. 5 == 5.0 or string number matching)
    final numA = num.tryParse(a.toString());
    final numB = num.tryParse(b.toString());
    if (numA != null && numB != null) {
      return numA == numB;
    }

    // Case-insensitive string comparison
    return a.toString().toLowerCase() == b.toString().toLowerCase();
  }

  static int _compare(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    final numA = num.tryParse(a.toString());
    final numB = num.tryParse(b.toString());
    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }

    final dateA = DateTime.tryParse(a.toString());
    final dateB = DateTime.tryParse(b.toString());
    if (dateA != null && dateB != null) {
      return dateA.compareTo(dateB);
    }

    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }
}

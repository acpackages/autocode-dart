import 'package:flutter/material.dart';
import 'ac_expression_evaluator.dart';

/// Holds all runtime state and expression scope for a rendered JSON screen.
class AcScreenContext {
  /// Screen ID (from JSON `id` field)
  final String screenId;

  /// Route parameters passed when opening this screen
  final Map<String, dynamic> params;

  /// Current accounteeId (optional tenant ID)
  final String accounteeId;

  /// Current currency code (e.g. `INR`)
  final String currencyCode;

  /// User rights map (e.g. `{ 'sale_invoices': { 'add': true, 'edit': true } }`)
  final Map<String, dynamic> rights;

  /// The mutable state map — mirrors JSON `state` initial values
  final Map<String, dynamic> state;

  /// Called whenever state changes — triggers rebuild of the screen
  final VoidCallback onStateChange;

  AcScreenContext({
    required this.screenId,
    required this.params,
    this.accounteeId = '',
    this.currencyCode = 'INR',
    this.rights = const {},
    required Map<String, dynamic> initialState,
    required this.onStateChange,
  }) : state = Map<String, dynamic>.from(initialState);

  /// Mutate a state value by dot-path key (e.g. `mutate('record.party_id', '123')`).
  void mutate(String key, dynamic value) {
    _setNested(state, key, value);
    onStateChange();
  }

  /// Shallow-merge a map into a state key.
  void mergeState(String key, Map<String, dynamic> value) {
    final existing = _getNested(state, key);
    if (existing is Map<String, dynamic>) {
      _setNested(state, key, {...existing, ...value});
    } else {
      _setNested(state, key, value);
    }
    onStateChange();
  }

  /// Toggle a boolean state value.
  void toggle(String key) {
    final current = _getNested(state, key);
    _setNested(state, key, !(current as bool? ?? false));
    onStateChange();
  }

  /// Read a value at a dot-path key.
  dynamic get(String key) => _getNested(state, key);

  /// The full evaluation context map.
  Map<String, dynamic> get evalContext => {
    'state': state,
    'params': params,
    'accounteeId': accounteeId,
    'currencyCode': currencyCode,
    'rights': rights,
    ...params,
  };

  /// Resolve a `{{token}}` expression against this context.
  dynamic resolve(dynamic value) {
    if (value is String) {
      return AcExpressionEvaluator.resolve(value, evalContext);
    }
    return value;
  }

  /// Resolve a string, always returning a String.
  String resolveString(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      return AcExpressionEvaluator.resolve(value, evalContext)?.toString() ?? '';
    }
    return value.toString();
  }

  /// Resolve all string values in a map.
  Map<String, dynamic> resolveMap(Map<String, dynamic> map) {
    return map.map((k, v) {
      if (v is String) {
        return MapEntry(k, AcExpressionEvaluator.resolve(v, evalContext));
      }
      if (v is Map<String, dynamic>) {
        return MapEntry(k, resolveMap(v));
      }
      return MapEntry(k, v);
    });
  }

  /// Check visibility / condition.
  bool isVisible(dynamic expr) {
    if (expr == null) return true;
    if (expr is bool) return expr;
    if (expr is String) {
      return AcExpressionEvaluator.isTruthy(expr, evalContext);
    }
    return true;
  }

  /// Child context with `item` scope (for list items & repeaters).
  AcScreenContext withItem(Map<String, dynamic> item, {int? index}) {
    return _ChildScreenContext(
      parent: this,
      extraVars: {
        'item': item,
        if (index != null) 'index': index,
      },
    );
  }

  /// Child context with arbitrary extra variables.
  AcScreenContext withVars(Map<String, dynamic> vars) {
    return _ChildScreenContext(parent: this, extraVars: vars);
  }

  static void _setNested(Map<String, dynamic> map, String key, dynamic value) {
    final parts = key.split('.');
    Map<String, dynamic> current = map;
    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (current[part] is! Map<String, dynamic>) {
        current[part] = <String, dynamic>{};
      }
      current = current[part] as Map<String, dynamic>;
    }
    current[parts.last] = value;
  }

  static dynamic _getNested(Map<String, dynamic> map, String key) {
    final parts = key.split('.');
    dynamic current = map;
    for (final part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}

class _ChildScreenContext extends AcScreenContext {
  final AcScreenContext parent;
  final Map<String, dynamic> extraVars;

  _ChildScreenContext({
    required this.parent,
    required this.extraVars,
  }) : super(
          screenId: parent.screenId,
          params: parent.params,
          accounteeId: parent.accounteeId,
          currencyCode: parent.currencyCode,
          rights: parent.rights,
          initialState: parent.state,
          onStateChange: parent.onStateChange,
        );

  @override
  Map<String, dynamic> get evalContext => {
        ...parent.evalContext,
        ...extraVars,
      };

  @override
  void mutate(String key, dynamic value) => parent.mutate(key, value);

  @override
  void mergeState(String key, Map<String, dynamic> value) =>
      parent.mergeState(key, value);

  @override
  void toggle(String key) => parent.toggle(key);
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'ac_expression_evaluator.dart';
import 'ac_quickjs_runner.dart';
import 'ac_screen_context.dart';

typedef AcActionHandler = Future<void> Function(
  Map<String, dynamic> action,
  AcScreenContext ctx, {
  Map<String, dynamic>? event,
});

/// Central executor for all declarative action descriptors dispatched from JSON screens.
class AcActionRegistry {
  AcActionRegistry._();

  static final Map<String, AcActionHandler> _handlers = {};
  static bool _defaultsRegistered = false;

  /// Register or override an action handler.
  static void addHandler(String key, AcActionHandler handler) {
    _handlers[key] = handler;
  }

  /// Execute an action descriptor (can be a Map for single action or a List for sequence).
  static Future<void> execute(
    dynamic descriptor,
    AcScreenContext ctx, {
    Map<String, dynamic>? event,
  }) async {
    if (descriptor == null) return;

    if (!_defaultsRegistered) {
      _registerDefaults();
    }

    if (descriptor is List) {
      for (final item in descriptor) {
        await execute(item, ctx, event: event);
      }
      return;
    }

    if (descriptor is! Map) return;
    final action = Map<String, dynamic>.from(descriptor);
    final key = action['action']?.toString() ?? '';
    if (key.isEmpty) return;

    final handler = _handlers[key];
    if (handler != null) {
      try {
        await handler(action, ctx, event: event);
      } catch (e) {
        debugPrint('[AcActionRegistry] Error executing action "$key": $e');
      }
    } else {
      debugPrint('[AcActionRegistry] Unhandled action key: "$key"');
    }
  }

  static void _registerDefaults() {
    _defaultsRegistered = true;

    // ── State Actions ────────────────────────────────────────────────────────
    _handlers['state.set'] = (action, ctx, {event}) async {
      final key = action['key']?.toString() ?? '';
      if (key.isEmpty) return;

      final evalCtx = event != null
          ? {...ctx.evalContext, 'event': event}
          : ctx.evalContext;

      final rawValue = action['value'];
      final value = rawValue is String
          ? AcExpressionEvaluator.resolve(rawValue, evalCtx)
          : rawValue;

      ctx.mutate(key, value);
    };

    _handlers['state.toggle'] = (action, ctx, {event}) async {
      final key = action['key']?.toString() ?? '';
      if (key.isNotEmpty) ctx.toggle(key);
    };

    _handlers['state.merge'] = (action, ctx, {event}) async {
      final key = action['key']?.toString() ?? '';
      final values = action['values'];
      if (key.isNotEmpty && values is Map) {
        ctx.mergeState(key, Map<String, dynamic>.from(values));
      }
    };

    _handlers['state.clear'] = (action, ctx, {event}) async {
      final key = action['key']?.toString() ?? '';
      if (key.isNotEmpty) ctx.mutate(key, null);
    };

    // ── Flow Control Actions ─────────────────────────────────────────────────
    _handlers['branch'] = (action, ctx, {event}) async {
      final condition = action['condition'];
      final evalCtx = event != null
          ? {...ctx.evalContext, 'event': event}
          : ctx.evalContext;

      final isConditionTrue = AcExpressionEvaluator.isTruthy(condition, evalCtx);

      if (isConditionTrue) {
        final thenAction = action['then'];
        if (thenAction != null) {
          await execute(thenAction, ctx, event: event);
        }
      } else {
        final elseAction = action['else'];
        if (elseAction != null) {
          await execute(elseAction, ctx, event: event);
        }
      }
    };

    _handlers['run'] = (action, ctx, {event}) async {
      final code = action['code']?.toString() ?? action['script']?.toString();
      final evalCtx = event != null
          ? {...ctx.evalContext, 'event': event}
          : ctx.evalContext;

      if (code != null && code.isNotEmpty) {
        final result = await AcQuickJsRunner.runInline(code: code, args: evalCtx);
        final stateKey = action['stateKey']?.toString();
        if (stateKey != null && stateKey.isNotEmpty) {
          ctx.mutate(stateKey, result);
        }
      }

      final actions = action['actions'];
      if (actions != null) {
        await execute(actions, ctx, event: event);
      }
    };

    // ── List Actions ─────────────────────────────────────────────────────────
    _handlers['list.add'] = (action, ctx, {event}) async {
      final stateKey = action['stateKey']?.toString() ?? action['key']?.toString() ?? 'items';
      final item = action['item'] ?? event;
      final current = ctx.get(stateKey);
      if (current is List) {
        ctx.mutate(stateKey, [...current, item]);
      } else {
        ctx.mutate(stateKey, [item]);
      }
    };

    _handlers['list.remove'] = (action, ctx, {event}) async {
      final stateKey = action['stateKey']?.toString() ?? action['key']?.toString() ?? 'items';
      final index = action['index'] as int?;
      final current = ctx.get(stateKey);
      if (current is List && index != null && index >= 0 && index < current.length) {
        final newList = List.from(current)..removeAt(index);
        ctx.mutate(stateKey, newList);
      }
    };
  }
}

import 'package:flutter/material.dart';
import 'ac_element_dictionary.dart';
import 'ac_screen_context.dart';

typedef AcWidgetBuilder = Widget Function(
  Map<String, dynamic> props,
  AcScreenContext ctx,
);

/// Registry mapping JSON element types (`act-*`, `act-select-*-input`, `act-*-input`)
/// to Flutter widget builders.
class AcWidgetRegistry {
  AcWidgetRegistry._();

  static final Map<String, AcWidgetBuilder> _builders = {};

  /// Register builders.
  static void registerBuilders(Map<String, AcWidgetBuilder> builders) {
    _builders.addAll(builders);
  }

  /// Register a single builder for a canonical element and optional aliases.
  static void registerBuilder(String elementKey, AcWidgetBuilder builder, {List<String> aliases = const []}) {
    _builders[elementKey] = builder;
    for (final a in aliases) {
      _builders[a] = builder;
    }
  }

  /// Build a widget from a JSON descriptor map.
  static Widget buildWidget(Map<String, dynamic> descriptor, AcScreenContext ctx) {
    if (descriptor.isEmpty) return const SizedBox.shrink();

    // 1. Resolve element key (support both "element" and legacy "widget")
    final key = descriptor['element']?.toString() ?? descriptor['widget']?.toString() ?? '';
    if (key.isEmpty) return const SizedBox.shrink();

    // 2. Evaluate visibility
    final conditionExpr = descriptor['condition'] ?? descriptor['visible'];
    if (conditionExpr != null) {
      final expr = conditionExpr is String ? conditionExpr : null;
      if (!ctx.isVisible(expr ?? conditionExpr)) return const SizedBox.shrink();
    }

    // 3. Normalize props: merge properties, inputs, outputs, and flat root keys
    final normalizedProps = _normalizeDescriptorProps(descriptor, ctx);

    // 4. Look up builder
    final builder = _builders[key];
    if (builder != null) {
      return builder(normalizedProps, ctx);
    }

    // 5. Look up in element dictionary aliases if not found directly
    final def = AcElementDictionary.get(key);
    if (def != null) {
      final aliasBuilder = _builders[def.element];
      if (aliasBuilder != null) {
        return aliasBuilder(normalizedProps, ctx);
      }
    }

    assert(() {
      debugPrint('[AcWidgetRegistry] Unregistered element key: "$key"');
      return true;
    }());

    return _UnknownElementWidget(elementKey: key);
  }

  /// Build a list of child widgets from a list of descriptors.
  static List<Widget> buildChildren(List<dynamic>? descriptors, AcScreenContext ctx) {
    if (descriptors == null || descriptors.isEmpty) return const [];
    return descriptors
        .whereType<Map>()
        .map((d) => buildWidget(Map<String, dynamic>.from(d), ctx))
        .toList();
  }

  /// Normalizes a descriptor into a unified props map combining:
  /// - `properties` block
  /// - `inputs` block (with bindings resolved against context)
  /// - `outputs` block
  /// - `children` / `child`
  /// - flat root properties for backward compatibility
  static Map<String, dynamic> _normalizeDescriptorProps(
    Map<String, dynamic> descriptor,
    AcScreenContext ctx,
  ) {
    final Map<String, dynamic> props = {};

    // Start with flat root properties (excluding meta keys)
    descriptor.forEach((k, v) {
      if (k != 'element' && k != 'widget' && k != 'properties' && k != 'inputs' && k != 'outputs') {
        props[k] = v;
      }
    });

    // Merge explicit properties
    final explicitProps = descriptor['properties'];
    if (explicitProps is Map) {
      explicitProps.forEach((k, v) {
        props[k.toString()] = v;
      });
    }

    // Resolve inputs bindings
    final inputs = descriptor['inputs'];
    if (inputs is Map) {
      inputs.forEach((k, v) {
        final keyStr = k.toString();
        if (v is Map && v.containsKey('binding')) {
          final binding = v['binding']?.toString() ?? '';
          props[keyStr] = ctx.resolve(binding.startsWith('{{') ? binding : '{{$binding}}');
        } else if (v is String && v.contains('{{')) {
          props[keyStr] = ctx.resolve(v);
        } else {
          props[keyStr] = v;
        }
      });
    }

    // Merge outputs declarations
    final outputs = descriptor['outputs'];
    if (outputs is Map) {
      outputs.forEach((k, v) {
        props[k.toString()] = v;
      });
    }

    // Preserve children/child slots
    if (descriptor.containsKey('children')) {
      props['children'] = descriptor['children'];
    }
    if (descriptor.containsKey('child')) {
      props['child'] = descriptor['child'];
    }

    return props;
  }
}

class _UnknownElementWidget extends StatelessWidget {
  final String elementKey;
  const _UnknownElementWidget({required this.elementKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Text(
        '<$elementKey>',
        style: const TextStyle(fontSize: 11, color: Colors.red, fontFamily: 'monospace'),
      ),
    );
  }
}

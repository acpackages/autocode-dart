import 'package:flutter/material.dart';
import '../../inputs/ac_button.dart';
import '../ac_action_registry.dart';
import '../ac_screen_context.dart';
import '../ac_widget_registry.dart';

Widget buildButtonElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final label = ctx.resolveString(p['label'] ?? '');
  final action = p['action'] ?? p['onClick'];
  final variantStr = p['variant']?.toString();
  final disabled = ctx.resolve(p['disabled']) == true;

  AcButtonVariant variant = AcButtonVariant.primary;
  switch (variantStr) {
    case 'secondary': variant = AcButtonVariant.secondary; break;
    case 'outline': variant = AcButtonVariant.outline; break;
    case 'ghost': case 'text': variant = AcButtonVariant.text; break;
    case 'danger': variant = AcButtonVariant.danger; break;
    default: variant = AcButtonVariant.primary;
  }

  return AcButton(
    variant: variant,
    onPressed: (!disabled && action != null)
        ? () => AcActionRegistry.execute(action, ctx)
        : null,
    child: Text(label),
  );
}

Widget buildIconActionElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final tooltip = ctx.resolveString(p['tooltip'] ?? '');
  final action = p['action'] ?? p['onClick'];
  final iconName = p['icon']?.toString() ?? '';

  IconData iconData = Icons.touch_app;
  switch (iconName) {
    case 'add': iconData = Icons.add; break;
    case 'edit': iconData = Icons.edit_outlined; break;
    case 'delete': iconData = Icons.delete_outline; break;
    case 'refresh': iconData = Icons.refresh; break;
    case 'close': iconData = Icons.close; break;
    case 'check': iconData = Icons.check; break;
    case 'filter': iconData = Icons.filter_list; break;
    case 'search': iconData = Icons.search; break;
    case 'more': iconData = Icons.more_vert; break;
    default: iconData = Icons.circle_outlined;
  }

  return IconButton(
    icon: Icon(iconData, size: 20),
    tooltip: tooltip.isNotEmpty ? tooltip : null,
    onPressed: action != null
        ? () => AcActionRegistry.execute(action, ctx)
        : null,
  );
}

Widget buildActionsElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final children = p['children'] as List? ?? [];
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: AcWidgetRegistry.buildChildren(children, ctx),
  );
}

Widget buildSwipeActionsElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final child = p['child'];
  final childWidget = child is Map
      ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(child), ctx)
      : const SizedBox.shrink();

  return childWidget;
}

Widget buildMenuElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final items = p['items'] as List? ?? [];
  return PopupMenuButton<dynamic>(
    icon: const Icon(Icons.more_vert),
    itemBuilder: (context) => [
      for (final item in items)
        if (item is Map)
          PopupMenuItem(
            value: item,
            child: Text(ctx.resolveString(item['label'] ?? '')),
          )
    ],
    onSelected: (item) {
      if (item is Map && item.containsKey('action')) {
        AcActionRegistry.execute(item['action'], ctx);
      }
    },
  );
}

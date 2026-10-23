import 'package:flutter/material.dart';
import '../../feedback/ac_alert.dart';
import '../../feedback/ac_badge.dart';
import '../../feedback/ac_spinner.dart';
import '../ac_screen_context.dart';
import '../ac_widget_registry.dart';

Widget buildTextElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final valExpr = p['value'] ?? p['text'] ?? '';
  final value = ctx.resolveString(valExpr);
  final styleToken = p['style']?.toString();
  final colorToken = p['color']?.toString();

  TextStyle style = const TextStyle(fontSize: 14);
  switch (styleToken) {
    case 'h1': style = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold); break;
    case 'h2': style = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold); break;
    case 'h3': style = const TextStyle(fontSize: 18, fontWeight: FontWeight.w600); break;
    case 'h4': style = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600); break;
    case 'h5': style = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600); break;
    case 'caption': style = const TextStyle(fontSize: 12, color: Colors.grey); break;
    case 'bold': style = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold); break;
  }

  Color? textColor;
  switch (colorToken) {
    case 'primary': textColor = const Color(0xFF1565C0); break;
    case 'success': textColor = const Color(0xFF2E7D32); break;
    case 'danger': case 'error': textColor = const Color(0xFFC62828); break;
    case 'warning': textColor = const Color(0xFFEF6C00); break;
    case 'secondary': textColor = Colors.grey[700]; break;
  }

  return Text(
    value,
    style: textColor != null ? style.copyWith(color: textColor) : style,
  );
}

Widget buildAmountElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final val = ctx.resolve(p['value']);
  final num amount = (val is num) ? val : num.tryParse(val?.toString() ?? '') ?? 0;
  final currency = ctx.resolveString(p['currency'] ?? '₹');
  final bold = p['bold'] != false;

  final formatted = '$currency${amount.abs().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  return Text(
    formatted,
    style: TextStyle(
      fontSize: 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: const Color(0xFF1565C0),
    ),
  );
}

Widget buildBadgeElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final val = ctx.resolveString(p['value']);
  final label = ctx.resolveString(p['label'] ?? val);
  final colorToken = p['color']?.toString();

  AcAlertVariant variant = AcAlertVariant.secondary;
  switch (colorToken) {
    case 'success': variant = AcAlertVariant.success; break;
    case 'danger': case 'error': variant = AcAlertVariant.danger; break;
    case 'warning': variant = AcAlertVariant.warning; break;
    case 'info': case 'primary': variant = AcAlertVariant.info; break;
  }

  return AcBadge(
    variant: variant,
    child: Text(label),
  );
}

Widget buildAvatarElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final name = ctx.resolveString(p['name'] ?? '');
  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
  final double size = (p['size'] as num?)?.toDouble() ?? 32.0;

  return CircleAvatar(
    radius: size / 2,
    backgroundColor: const Color(0xFF1565C0),
    child: Text(initial, style: TextStyle(fontSize: size * 0.4, color: Colors.white)),
  );
}

Widget buildIconElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final iconName = p['icon']?.toString() ?? '';
  final double size = (p['size'] as num?)?.toDouble() ?? 20.0;
  IconData icon = Icons.circle_outlined;
  switch (iconName) {
    case 'add': icon = Icons.add; break;
    case 'edit': icon = Icons.edit_outlined; break;
    case 'delete': icon = Icons.delete_outline; break;
    case 'refresh': icon = Icons.refresh; break;
    case 'close': icon = Icons.close; break;
    case 'check': icon = Icons.check; break;
    case 'search': icon = Icons.search; break;
    case 'more': icon = Icons.more_vert; break;
    case 'filter': icon = Icons.filter_list; break;
    default: icon = Icons.circle_outlined;
  }
  return Icon(icon, size: size);
}

Widget buildSummaryElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final items = p['items'] as List? ?? [];
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        for (final item in items)
          if (item is Map)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ctx.resolveString(item['label'] ?? ''), style: const TextStyle(fontSize: 13)),
                  Text(ctx.resolveString(item['value'] ?? ''), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            )
      ],
    ),
  );
}

Widget buildInfoTableElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final rows = p['rows'] as List? ?? [];
  return Column(
    children: [
      for (final r in rows)
        if (r is Map)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(ctx.resolveString(r['label'] ?? ''), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ),
                Expanded(
                  child: Text(ctx.resolveString(r['value'] ?? ''), style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          )
    ],
  );
}

Widget buildEmptyElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final message = ctx.resolveString(p['message'] ?? 'No records found');
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    ),
  );
}

Widget buildLoaderElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final double size = (p['size'] as num?)?.toDouble() ?? 24.0;
  return Center(child: AcSpinner(size: size));
}

Widget buildChipBarElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final chips = p['chips'] as List? ?? [];
  final activeKey = ctx.resolveString(p['active']);

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final chip in chips)
          if (chip is Map)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(ctx.resolveString(chip['label'] ?? '')),
                selected: chip['key'] == activeKey,
                onSelected: (selected) {
                  // output onSelect
                },
              ),
            )
      ],
    ),
  );
}

Widget buildOperationStatusElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final message = ctx.resolveString(p['message'] ?? '');
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}

Widget buildLockOverlayElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final locked = ctx.resolve(p['locked']) == true;
  final child = p['child'];
  final childWidget = child is Map
      ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(child), ctx)
      : const SizedBox.shrink();

  if (!locked) return childWidget;

  return Stack(
    children: [
      Opacity(opacity: 0.6, child: AbsorbPointer(child: childWidget)),
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.amber),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 14, color: Colors.brown),
              SizedBox(width: 4),
              Text('Locked', style: TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ],
  );
}

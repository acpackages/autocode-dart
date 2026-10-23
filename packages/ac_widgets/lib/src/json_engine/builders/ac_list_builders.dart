import 'package:flutter/material.dart';
import '../ac_action_registry.dart';
import '../ac_screen_context.dart';
import '../ac_widget_registry.dart';

Widget buildListElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? 'items';
  final rawItems = ctx.get(bindKey) ?? p['items'];
  final List<dynamic> items = rawItems is List ? rawItems : [];

  final emptyNode = p['empty'] as Map?;
  if (items.isEmpty && emptyNode != null) {
    return AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(emptyNode), ctx);
  }

  final explicitColumns = (p['columns'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  final onItemTap = p['onItemTap'] ?? p['onTap'] ?? p['onRowPress'] ?? p['itemDescriptor']?['onPress'];

  // If columns are specified or we have structured items, render the Datagrid
  final cols = explicitColumns.isNotEmpty
      ? explicitColumns
      : (items.isNotEmpty && items.first is Map
          ? _deriveColumns(Map<String, dynamic>.from(items.first))
          : <Map<String, dynamic>>[]);

  if (cols.isNotEmpty) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBounded = constraints.hasBoundedHeight;
        final rowsWidget = ListView.builder(
          shrinkWrap: !isBounded,
          physics: !isBounded ? const NeverScrollableScrollPhysics() : null,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i] is Map ? Map<String, dynamic>.from(items[i]) : {'value': items[i]};
            final itemCtx = ctx.withItem(item, index: i);
            final rowBg = i.isEven ? Colors.white : const Color(0xFFF1F1F1);

            return InkWell(
              onTap: onItemTap != null ? () => AcActionRegistry.execute(onItemTap, itemCtx, event: {'item': item, 'index': i}) : null,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: rowBg,
                  border: const Border(bottom: BorderSide(color: Color(0xFFE4E7EA))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
                    ),
                    for (final col in cols) ...[
                      Expanded(
                        flex: (col['flex'] as num?)?.toInt() ?? 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _renderCell(col, item),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD8DBE0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: isBounded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              // Header row (#181818)
              Container(
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF181818),
                  border: Border(bottom: BorderSide(color: Color(0xFF282828))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: const Text('#', style: TextStyle(color: Color(0xFF8A93A2), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    for (final col in cols) ...[
                      Expanded(
                        flex: (col['flex'] as num?)?.toInt() ?? 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            col['label']?.toString() ?? col['title']?.toString() ?? col['field']?.toString() ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isBounded) Expanded(child: rowsWidget) else rowsWidget,
            ],
          ),
        );
      },
    );
  }

  // Fallback to row template
  final rowTemplate = p['row'] as Map?;
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final rawItem = items[index];
      final itemMap = rawItem is Map
          ? Map<String, dynamic>.from(rawItem)
          : {'value': rawItem};

      final itemCtx = ctx.withItem(itemMap, index: index);

      Widget rowWidget = rowTemplate != null
          ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(rowTemplate), itemCtx)
          : ListTile(title: Text(itemMap.toString()));

      if (onItemTap != null) {
        rowWidget = InkWell(
          onTap: () => AcActionRegistry.execute(onItemTap, itemCtx, event: {'item': itemMap, 'index': index}),
          child: rowWidget,
        );
      }

      return rowWidget;
    },
  );
}

List<Map<String, dynamic>> _deriveColumns(Map<String, dynamic> sample) {
  final keys = sample.keys.toList();
  final cols = <Map<String, dynamic>>[];
  for (final k in ['invoiceNumber', 'number', 'partyName', 'customerName', 'name', 'title', 'date', 'amount', 'total', 'status']) {
    if (keys.contains(k)) {
      cols.add({
        'field': k,
        'label': k[0].toUpperCase() + k.substring(1),
        'flex': k.toLowerCase().contains('name') ? 2 : 1,
      });
    }
  }
  return cols;
}

Widget _renderCell(Map<String, dynamic> col, Map<String, dynamic> item) {
  final field = col['field']?.toString() ?? '';
  final val = item[field];
  if (val == null) return const SizedBox.shrink();

  if (field.toLowerCase().contains('status')) {
    final s = val.toString().toLowerCase();
    final isPaid = s == 'paid' || s == 'completed' || s == 'active';
    final isUnpaid = s == 'unpaid' || s == 'pending' || s == 'overdue';
    final badgeColor = isPaid ? const Color(0xFF2EB85C) : (isUnpaid ? const Color(0xFFE55353) : const Color(0xFFF9B115));
    final badgeBg = isPaid ? const Color(0xFFD4EDDA) : (isUnpaid ? const Color(0xFFF8D7DA) : const Color(0xFFFFF3CD));

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(3)),
        child: Text(val.toString().toUpperCase(), style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.bold)),
      ),
    );
  }

  return Text(
    '$val',
    style: const TextStyle(fontSize: 13, color: Color(0xFF23282D)),
    overflow: TextOverflow.ellipsis,
  );
}

Widget buildRepeaterElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? 'items';
  final rawItems = ctx.get(bindKey) ?? p['items'];
  final List<dynamic> items = rawItems is List ? rawItems : [];

  final itemDesc = p['itemDescriptor'] ?? p['row'] ?? p['template'];
  final emptyNode = p['empty'] as Map?;

  if (items.isEmpty && emptyNode != null) {
    return AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(emptyNode), ctx);
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < items.length; i++) ...[
        if (itemDesc is Map)
          AcWidgetRegistry.buildWidget(
            Map<String, dynamic>.from(itemDesc),
            ctx.withItem(
              items[i] is Map ? Map<String, dynamic>.from(items[i]) : {'value': items[i]},
              index: i,
            ),
          )
      ]
    ],
  );
}

Widget buildInlineListElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildListElement(p, ctx);
}

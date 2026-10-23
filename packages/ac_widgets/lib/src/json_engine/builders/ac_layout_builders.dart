import 'package:flutter/material.dart';
import '../../layout/ac_card.dart';
import '../../layout/ac_tabs.dart';
import '../ac_screen_context.dart';
import '../ac_widget_registry.dart';

double _parseSize(dynamic val, {double defaultVal = 12.0}) {
  if (val == null) return defaultVal;
  if (val is num) return val.toDouble();
  if (val is String) {
    final d = double.tryParse(val);
    if (d != null) return d;
    switch (val) {
      case 'xs': return 4.0;
      case 'sm': return 8.0;
      case 'md': return 16.0;
      case 'lg': return 24.0;
      case 'xl': return 32.0;
      default: return defaultVal;
    }
  }
  return defaultVal;
}

int _parseFlex(dynamic val, {int defaultVal = 1}) {
  if (val == null) return defaultVal;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? defaultVal;
  return defaultVal;
}

Widget buildColumnElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final children = p['children'] as List? ?? [];
  final double gap = _parseSize(p['gap'], defaultVal: 8.0);

  CrossAxisAlignment crossAxis = CrossAxisAlignment.start;
  switch (p['crossAxisAlignment'] ?? p['align']) {
    case 'center': crossAxis = CrossAxisAlignment.center; break;
    case 'end': case 'right': crossAxis = CrossAxisAlignment.end; break;
    case 'stretch': crossAxis = CrossAxisAlignment.stretch; break;
    default: crossAxis = CrossAxisAlignment.start;
  }

  MainAxisAlignment mainAxis = MainAxisAlignment.start;
  switch (p['mainAxisAlignment'] ?? p['justify']) {
    case 'center': mainAxis = MainAxisAlignment.center; break;
    case 'end': mainAxis = MainAxisAlignment.end; break;
    case 'spaceBetween': mainAxis = MainAxisAlignment.spaceBetween; break;
    default: mainAxis = MainAxisAlignment.start;
  }

  bool hasExpanded = false;
  final built = <Widget>[];
  for (final rawChild in children) {
    if (rawChild is! Map) continue;
    final childMap = Map<String, dynamic>.from(rawChild);
    final flex = childMap['flex'] != null ? _parseFlex(childMap['flex']) : null;
    final isExpand = childMap['element'] == 'act-expand' || childMap['widget'] == 'expand';

    Widget w = AcWidgetRegistry.buildWidget(childMap, ctx);
    if (flex != null && flex > 0 && !isExpand) {
      w = Expanded(flex: flex, child: w);
      hasExpanded = true;
    } else if (isExpand) {
      hasExpanded = true;
    }
    built.add(w);
  }

  final mainAxisSize = (hasExpanded || p['mainAxisSize'] == 'max')
      ? MainAxisSize.max
      : MainAxisSize.min;

  Widget col = Column(
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxis,
    mainAxisAlignment: mainAxis,
    children: gap > 0 && built.length > 1
        ? [
            for (int i = 0; i < built.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              built[i],
            ]
          ]
        : built,
  );

  final padding = _parsePadding(p['padding']);
  if (padding != null) {
    col = Padding(padding: padding, child: col);
  }

  return col;
}

Widget buildRowElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final children = p['children'] as List? ?? [];
  final double gap = _parseSize(p['gap'], defaultVal: 8.0);

  CrossAxisAlignment crossAxis = CrossAxisAlignment.center;
  switch (p['crossAxisAlignment'] ?? p['align']) {
    case 'start': case 'top': crossAxis = CrossAxisAlignment.start; break;
    case 'end': case 'bottom': crossAxis = CrossAxisAlignment.end; break;
    case 'stretch': crossAxis = CrossAxisAlignment.stretch; break;
    default: crossAxis = CrossAxisAlignment.center;
  }

  MainAxisAlignment mainAxis = MainAxisAlignment.start;
  switch (p['mainAxisAlignment'] ?? p['justify']) {
    case 'center': mainAxis = MainAxisAlignment.center; break;
    case 'end': mainAxis = MainAxisAlignment.end; break;
    case 'spaceBetween': mainAxis = MainAxisAlignment.spaceBetween; break;
    case 'spaceAround': mainAxis = MainAxisAlignment.spaceAround; break;
    default: mainAxis = MainAxisAlignment.start;
  }

  bool hasExpanded = false;
  final built = <Widget>[];
  for (final rawChild in children) {
    if (rawChild is! Map) continue;
    final childMap = Map<String, dynamic>.from(rawChild);
    final flex = childMap['flex'] != null ? _parseFlex(childMap['flex']) : null;
    final isExpand = childMap['element'] == 'act-expand' || childMap['widget'] == 'expand';

    Widget w = AcWidgetRegistry.buildWidget(childMap, ctx);
    if (flex != null && flex > 0 && !isExpand) {
      w = Expanded(flex: flex, child: w);
      hasExpanded = true;
    } else if (isExpand) {
      hasExpanded = true;
    }
    built.add(w);
  }

  final wrap = p['wrap'] == true;
  if (wrap) {
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: built,
    );
  }

  final mainAxisSize = (hasExpanded || p['mainAxisSize'] == 'max' || p['flex'] != null)
      ? MainAxisSize.max
      : MainAxisSize.min;

  Widget row = Row(
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxis,
    mainAxisAlignment: mainAxis,
    children: gap > 0 && built.length > 1
        ? [
            for (int i = 0; i < built.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              built[i],
            ]
          ]
        : built,
  );

  final padding = _parsePadding(p['padding']);
  if (padding != null) {
    row = Padding(padding: padding, child: row);
  }

  return row;
}

Widget buildCardElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final child = p['child'];
  final children = p['children'] as List?;
  final title = ctx.resolveString(p['title']);

  Widget content;
  if (children != null) {
    content = buildColumnElement(p, ctx);
  } else if (child is Map) {
    content = AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(child), ctx);
  } else {
    content = const SizedBox.shrink();
  }

  return AcCard(
    title: title.isNotEmpty ? Text(title) : null,
    body: content,
  );
}

Widget buildSectionElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final title = ctx.resolveString(p['title']);
  final subtitle = ctx.resolveString(p['subtitle']);
  final children = p['children'] as List? ?? [];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) ...[
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
      ],
      ...AcWidgetRegistry.buildChildren(children, ctx),
    ],
  );
}

Widget buildGapElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final double size = _parseSize(p['size'], defaultVal: 12.0);
  final bool crossAxis = p['crossAxis'] == true;
  return crossAxis ? SizedBox(width: size) : SizedBox(height: size);
}

Widget buildDividerElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return const Divider(height: 1);
}

Widget buildExpandElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final child = p['child'];
  final flex = _parseFlex(p['flex']);
  final childWidget = child is Map
      ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(child), ctx)
      : const SizedBox.shrink();
  return Expanded(flex: flex, child: childWidget);
}

Widget buildScrollElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final child = p['child'];
  final children = p['children'] as List?;
  final direction = p['direction']?.toString() == 'horizontal'
      ? Axis.horizontal
      : Axis.vertical;

  final Widget content = children != null
      ? (direction == Axis.horizontal ? buildRowElement(p, ctx) : buildColumnElement(p, ctx))
      : (child is Map ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(child), ctx) : const SizedBox.shrink());

  return SingleChildScrollView(scrollDirection: direction, child: content);
}

Widget buildIfElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final condition = p['condition'];
  final isTrue = ctx.isVisible(condition);

  if (isTrue) {
    final thenNode = p['then'];
    if (thenNode is Map) {
      return AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(thenNode), ctx);
    }
  } else {
    final elseNode = p['else'];
    if (elseNode is Map) {
      return AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(elseNode), ctx);
    }
  }

  return const SizedBox.shrink();
}

Widget buildTabsElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final tabsList = p['tabs'] as List? ?? [];
  final tabs = <AcTabItem>[];

  for (final t in tabsList) {
    if (t is Map) {
      final label = ctx.resolveString(t['label'] ?? t['title'] ?? '');
      final contentDesc = t['content'] ?? t['body'];
      final content = contentDesc is Map
          ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(contentDesc), ctx)
          : const SizedBox.shrink();
      tabs.add(AcTabItem(label: Text(label), content: content));
    }
  }

  return AcTabs(tabs: tabs);
}

EdgeInsets? _parsePadding(dynamic val) {
  if (val == null) return null;
  if (val is num) return EdgeInsets.all(val.toDouble());
  if (val is Map) {
    final h = (val['horizontal'] as num?)?.toDouble() ?? 0.0;
    final v = (val['vertical'] as num?)?.toDouble() ?? 0.0;
    final l = (val['left'] as num?)?.toDouble() ?? h;
    final r = (val['right'] as num?)?.toDouble() ?? h;
    final t = (val['top'] as num?)?.toDouble() ?? v;
    final b = (val['bottom'] as num?)?.toDouble() ?? v;
    return EdgeInsets.fromLTRB(l, t, r, b);
  }
  if (val is String) {
    final d = double.tryParse(val);
    if (d != null) return EdgeInsets.all(d);
    switch (val) {
      case 'xs': return const EdgeInsets.all(4);
      case 'sm': return const EdgeInsets.all(8);
      case 'md': return const EdgeInsets.all(16);
      case 'lg': return const EdgeInsets.all(24);
      default: return const EdgeInsets.all(12);
    }
  }
  return null;
}

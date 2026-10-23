import 'package:flutter/material.dart';

/// Single link/item within [AcBreadcrumb].
class AcBreadcrumbItem {
  final Widget label;
  final Widget? icon;
  final VoidCallback? onTap;

  const AcBreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}

/// A path navigation trail showing hierarchical context with customizable separators.
class AcBreadcrumb extends StatelessWidget {
  final List<AcBreadcrumbItem> items;
  final Widget separator;
  final TextStyle? activeStyle;
  final TextStyle? inactiveStyle;

  const AcBreadcrumb({
    super.key,
    required this.items,
    this.separator = const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
    this.activeStyle,
    this.inactiveStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      Widget content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            item.icon!,
            const SizedBox(width: 4),
          ],
          item.label,
        ],
      );

      if (!isLast && item.onTap != null) {
        content = InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: DefaultTextStyle(
              style: inactiveStyle ?? theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary),
              child: content,
            ),
          ),
        );
      } else {
        content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: DefaultTextStyle(
            style: activeStyle ?? theme.textTheme.bodyMedium!.copyWith(
              fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
              color: isLast ? theme.textTheme.bodyMedium?.color : theme.hintColor,
            ),
            child: content,
          ),
        );
      }

      children.add(content);

      if (!isLast) {
        children.add(separator);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

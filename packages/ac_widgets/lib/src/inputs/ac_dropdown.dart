import 'package:flutter/material.dart';

/// Single item within [AcDropdown].
class AcDropdownItem<T> {
  final T value;
  final Widget child;
  final Widget? leading;
  final bool enabled;

  const AcDropdownItem({
    required this.value,
    required this.child,
    this.leading,
    this.enabled = true,
  });
}

/// A popup dropdown menu triggered by an interactive child button.
class AcDropdown<T> extends StatelessWidget {
  final Widget trigger;
  final List<AcDropdownItem<T>> items;
  final ValueChanged<T>? onSelected;
  final Offset offset;

  const AcDropdown({
    super.key,
    required this.trigger,
    required this.items,
    this.onSelected,
    this.offset = const Offset(0, 40),
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      offset: offset,
      onSelected: onSelected,
      itemBuilder: (context) {
        return items.map((it) {
          return PopupMenuItem<T>(
            value: it.value,
            enabled: it.enabled,
            child: Row(
              children: [
                if (it.leading != null) ...[
                  it.leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(child: it.child),
              ],
            ),
          );
        }).toList();
      },
      child: trigger,
    );
  }
}

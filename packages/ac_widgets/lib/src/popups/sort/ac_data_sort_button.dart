import 'package:flutter/material.dart';
import '../../data_manager/ac_data_manager.dart';
import 'ac_data_sort_popup.dart';
import 'ac_sort_field.dart';

/// Button that displays active sort count badge and triggers [AcDataSortPopup].
class AcDataSortButton extends StatelessWidget {
  final AcDataManager dataManager;
  final List<AcSortField> fields;
  final AcSortField? targetField;
  final VoidCallback? onApply;
  final VoidCallback? onClear;
  final Widget? icon;
  final String tooltip;

  const AcDataSortButton({
    super.key,
    required this.dataManager,
    required this.fields,
    this.targetField,
    this.onApply,
    this.onClear,
    this.icon,
    this.tooltip = 'Sort Data',
  });

  int get _activeCount {
    if (targetField != null) {
      return dataManager.sortOrders.sortOrders
          .where((s) => s.key == targetField!.key)
          .length;
    }
    return dataManager.sortOrders.sortOrders.length;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dataManager,
      builder: (context, _) {
        final count = _activeCount;
        final hasActive = count > 0;

        Widget button = IconButton(
          icon: icon ?? Icon(
            Icons.sort,
            color: hasActive ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: tooltip,
          onPressed: () {
            AcDataSortPopup.show(
              context: context,
              dataManager: dataManager,
              fields: fields,
              targetField: targetField,
              onApply: onApply,
              onClear: onClear,
            );
          },
        );

        if (hasActive) {
          return Badge(
            label: Text(count.toString(), style: const TextStyle(fontSize: 10)),
            child: button,
          );
        }

        return button;
      },
    );
  }
}

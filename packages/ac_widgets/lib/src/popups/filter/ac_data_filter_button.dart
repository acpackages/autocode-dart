import 'package:flutter/material.dart';
import '../../data_manager/ac_data_manager.dart';
import 'ac_data_filter_popup.dart';
import 'ac_filter_field.dart';

/// Button that displays active filter count badge and triggers [AcDataFilterPopup].
class AcDataFilterButton extends StatelessWidget {
  final AcDataManager dataManager;
  final List<AcFilterField> fields;
  final AcFilterField? targetField;
  final VoidCallback? onApply;
  final VoidCallback? onClear;
  final Widget? icon;
  final String tooltip;

  const AcDataFilterButton({
    super.key,
    required this.dataManager,
    required this.fields,
    this.targetField,
    this.onApply,
    this.onClear,
    this.icon,
    this.tooltip = 'Filter Data',
  });

  int get _activeCount {
    if (targetField != null) {
      return dataManager.filterGroup.filters
          .where((f) => f.key == targetField!.key)
          .length;
    }
    return dataManager.filterGroup.filters.length;
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
            Icons.filter_list,
            color: hasActive ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: tooltip,
          onPressed: () {
            AcDataFilterPopup.show(
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

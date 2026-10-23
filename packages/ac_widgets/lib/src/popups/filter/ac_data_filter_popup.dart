import 'package:flutter/material.dart';
import 'package:autocode/autocode.dart';
import '../../data_manager/ac_data_manager.dart';
import 'ac_filter_field.dart';

/// Interactive popup/dialog allowing users to configure data filters.
///
/// Supports both:
/// 1. **Single-Field Mode** (when [targetField] is provided): Anchored to a specific column header.
/// 2. **Multi-Field Mode** (when [targetField] is null): Configures multi-condition compound filters.
class AcDataFilterPopup extends StatefulWidget {
  final AcDataManager dataManager;
  final List<AcFilterField> fields;
  final AcFilterField? targetField;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  const AcDataFilterPopup({
    super.key,
    required this.dataManager,
    required this.fields,
    this.targetField,
    this.onApply,
    this.onClear,
  });

  /// Displays the filter popup modally or anchored.
  static Future<void> show({
    required BuildContext context,
    required AcDataManager dataManager,
    required List<AcFilterField> fields,
    AcFilterField? targetField,
    VoidCallback? onApply,
    VoidCallback? onClear,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
          child: AcDataFilterPopup(
            dataManager: dataManager,
            fields: fields,
            targetField: targetField,
            onApply: onApply,
            onClear: onClear,
          ),
        ),
      ),
    );
  }

  @override
  State<AcDataFilterPopup> createState() => _AcDataFilterPopupState();
}

class _FilterConditionItem {
  String key;
  AcEnumConditionOperator operator;
  dynamic value;

  _FilterConditionItem({
    required this.key,
    required this.operator,
    this.value = '',
  });
}

class _AcDataFilterPopupState extends State<AcDataFilterPopup> {
  late List<_FilterConditionItem> _conditions;

  bool get isSingleFieldMode => widget.targetField != null;

  @override
  void initState() {
    super.initState();
    _loadExistingFilters();
  }

  void _loadExistingFilters() {
    final existingFilters = widget.dataManager.filterGroup.filters;
    _conditions = [];

    if (isSingleFieldMode) {
      final match = existingFilters.where((f) => f.key == widget.targetField!.key).toList();
      if (match.isNotEmpty) {
        for (final m in match) {
          _conditions.add(_FilterConditionItem(
            key: m.key,
            operator: m.operator,
            value: m.value?.toString() ?? '',
          ));
        }
      } else {
        _conditions.add(_FilterConditionItem(
          key: widget.targetField!.key,
          operator: _defaultOperatorForType(widget.targetField!.type),
          value: '',
        ));
      }
    } else {
      if (existingFilters.isNotEmpty) {
        for (final f in existingFilters) {
          _conditions.add(_FilterConditionItem(
            key: f.key,
            operator: f.operator,
            value: f.value?.toString() ?? '',
          ));
        }
      } else if (widget.fields.isNotEmpty) {
        _conditions.add(_FilterConditionItem(
          key: widget.fields.first.key,
          operator: _defaultOperatorForType(widget.fields.first.type),
          value: '',
        ));
      }
    }
  }

  AcEnumConditionOperator _defaultOperatorForType(String type) {
    switch (type.toLowerCase()) {
      case 'number':
        return AcEnumConditionOperator.equalTo;
      case 'date':
      case 'datetime':
        return AcEnumConditionOperator.equalTo;
      case 'boolean':
        return AcEnumConditionOperator.equalTo;
      default:
        return AcEnumConditionOperator.contains;
    }
  }

  List<AcEnumConditionOperator> _operatorsForField(String key) {
    final field = widget.fields.firstWhere(
      (f) => f.key == key,
      orElse: () => AcFilterField(key: key, label: key),
    );

    switch (field.type.toLowerCase()) {
      case 'number':
        return [
          AcEnumConditionOperator.equalTo,
          AcEnumConditionOperator.notEqualTo,
          AcEnumConditionOperator.greaterThan,
          AcEnumConditionOperator.greaterThanEqualTo,
          AcEnumConditionOperator.lessThan,
          AcEnumConditionOperator.lessThanEqualTo,
          AcEnumConditionOperator.isNull,
          AcEnumConditionOperator.isNotNull,
        ];
      case 'date':
      case 'datetime':
        return [
          AcEnumConditionOperator.equalTo,
          AcEnumConditionOperator.notEqualTo,
          AcEnumConditionOperator.greaterThan,
          AcEnumConditionOperator.lessThan,
          AcEnumConditionOperator.isNull,
          AcEnumConditionOperator.isNotNull,
        ];
      case 'boolean':
        return [
          AcEnumConditionOperator.equalTo,
          AcEnumConditionOperator.isNull,
          AcEnumConditionOperator.isNotNull,
        ];
      default:
        return [
          AcEnumConditionOperator.contains,
          AcEnumConditionOperator.notContains,
          AcEnumConditionOperator.equalTo,
          AcEnumConditionOperator.notEqualTo,
          AcEnumConditionOperator.startsWith,
          AcEnumConditionOperator.endsWith,
          AcEnumConditionOperator.isEmpty,
          AcEnumConditionOperator.isNotEmpty,
          AcEnumConditionOperator.isNull,
          AcEnumConditionOperator.isNotNull,
        ];
    }
  }

  bool _operatorNeedsValue(AcEnumConditionOperator op) {
    return op != AcEnumConditionOperator.isNull &&
        op != AcEnumConditionOperator.isNotNull &&
        op != AcEnumConditionOperator.isEmpty &&
        op != AcEnumConditionOperator.isNotEmpty;
  }

  void _addCondition() {
    if (widget.fields.isEmpty) return;
    setState(() {
      final first = widget.fields.first;
      _conditions.add(_FilterConditionItem(
        key: first.key,
        operator: _defaultOperatorForType(first.type),
        value: '',
      ));
    });
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
  }

  void _clear() {
    if (isSingleFieldMode) {
      widget.dataManager.filterGroup.filters.removeWhere((f) => f.key == widget.targetField!.key);
      widget.dataManager.refresh();
    } else {
      widget.dataManager.setFilterGroup(AcFilterGroup());
    }
    widget.onClear?.call();
    Navigator.of(context).pop();
  }

  void _apply() {
    if (isSingleFieldMode) {
      // Remove previous filters for this specific field
      widget.dataManager.filterGroup.filters.removeWhere((f) => f.key == widget.targetField!.key);
      for (final cond in _conditions) {
        if (!_operatorNeedsValue(cond.operator) || cond.value.toString().trim().isNotEmpty) {
          widget.dataManager.filterGroup.addFilter(
            key: cond.key,
            operator: cond.operator,
            value: cond.value,
          );
        }
      }
      widget.dataManager.refresh();
    } else {
      final newGroup = AcFilterGroup();
      for (final cond in _conditions) {
        if (!_operatorNeedsValue(cond.operator) || cond.value.toString().trim().isNotEmpty) {
          newGroup.addFilter(
            key: cond.key,
            operator: cond.operator,
            value: cond.value,
          );
        }
      }
      widget.dataManager.setFilterGroup(newGroup);
    }
    widget.onApply?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = isSingleFieldMode
        ? 'Filter: ${widget.targetField!.label}'
        : 'Filter Data';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 18,
              ),
            ],
          ),
          const Divider(),

          // Rows
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _conditions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final cond = _conditions[i];
                final availableOps = _operatorsForField(cond.key);
                final needsVal = _operatorNeedsValue(cond.operator);

                return Row(
                  children: [
                    // Field dropdown (only in multi-field mode)
                    if (!isSingleFieldMode) ...[
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: cond.key,
                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                          items: widget.fields.map((f) => DropdownMenuItem(value: f.key, child: Text(f.label, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                cond.key = val;
                                final f = widget.fields.firstWhere((x) => x.key == val);
                                cond.operator = _defaultOperatorForType(f.type);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Operator dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<AcEnumConditionOperator>(
                        isExpanded: true,
                        initialValue: availableOps.contains(cond.operator) ? cond.operator : availableOps.first,
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                        items: availableOps.map((op) => DropdownMenuItem(value: op, child: Text(op.value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              cond.operator = val;
                            });
                          }
                        },
                      ),
                    ),

                    // Value input
                    if (needsVal) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          initialValue: cond.value?.toString(),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Value...',
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (v) => cond.value = v,
                        ),
                      ),
                    ],

                    // Delete row button
                    if (!isSingleFieldMode && _conditions.length > 1) ...[
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeCondition(i),
                        splashRadius: 16,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              if (!isSingleFieldMode)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Rule'),
                  onPressed: _addCondition,
                ),
              const Spacer(),
              OutlinedButton(
                onPressed: _clear,
                child: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _apply,
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

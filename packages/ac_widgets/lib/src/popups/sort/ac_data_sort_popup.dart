import 'package:flutter/material.dart';
import 'package:autocode/autocode.dart';
import '../../data_manager/ac_data_manager.dart';
import 'ac_sort_field.dart';

/// Interactive popup/dialog allowing users to configure multi-column sort rules.
///
/// Supports both:
/// 1. **Single-Field Mode** (when [targetField] is provided): Quick sort for a column.
/// 2. **Multi-Field Mode** (when [targetField] is null): Multi-tier priority sort builder.
class AcDataSortPopup extends StatefulWidget {
  final AcDataManager dataManager;
  final List<AcSortField> fields;
  final AcSortField? targetField;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  const AcDataSortPopup({
    super.key,
    required this.dataManager,
    required this.fields,
    this.targetField,
    this.onApply,
    this.onClear,
  });

  /// Displays the sort popup modally or anchored.
  static Future<void> show({
    required BuildContext context,
    required AcDataManager dataManager,
    required List<AcSortField> fields,
    AcSortField? targetField,
    VoidCallback? onApply,
    VoidCallback? onClear,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
          child: AcDataSortPopup(
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
  State<AcDataSortPopup> createState() => _AcDataSortPopupState();
}

class _SortTierItem {
  String key;
  AcEnumSortOrder order;

  _SortTierItem({
    required this.key,
    required this.order,
  });
}

class _AcDataSortPopupState extends State<AcDataSortPopup> {
  late List<_SortTierItem> _sortTiers;

  bool get isSingleFieldMode => widget.targetField != null;

  @override
  void initState() {
    super.initState();
    _loadExistingSorts();
  }

  void _loadExistingSorts() {
    final existing = widget.dataManager.sortOrders.sortOrders;
    _sortTiers = [];

    if (isSingleFieldMode) {
      final match = existing.where((s) => s.key == widget.targetField!.key).toList();
      if (match.isNotEmpty) {
        _sortTiers.add(_SortTierItem(key: match.first.key, order: match.first.order));
      } else {
        _sortTiers.add(_SortTierItem(key: widget.targetField!.key, order: AcEnumSortOrder.ascending));
      }
    } else {
      if (existing.isNotEmpty) {
        for (final s in existing) {
          _sortTiers.add(_SortTierItem(key: s.key, order: s.order));
        }
      } else if (widget.fields.isNotEmpty) {
        _sortTiers.add(_SortTierItem(key: widget.fields.first.key, order: AcEnumSortOrder.ascending));
      }
    }
  }

  void _addTier() {
    if (widget.fields.isEmpty) return;
    setState(() {
      _sortTiers.add(_SortTierItem(
        key: widget.fields.first.key,
        order: AcEnumSortOrder.ascending,
      ));
    });
  }

  void _removeTier(int index) {
    setState(() {
      _sortTiers.removeAt(index);
    });
  }

  void _clear() {
    if (isSingleFieldMode) {
      widget.dataManager.clearSort(widget.targetField!.key);
    } else {
      widget.dataManager.clearAllSorts();
    }
    widget.onClear?.call();
    Navigator.of(context).pop();
  }

  void _apply() {
    if (isSingleFieldMode) {
      if (_sortTiers.isNotEmpty && _sortTiers.first.order != AcEnumSortOrder.none) {
        widget.dataManager.setSort(
          key: _sortTiers.first.key,
          order: _sortTiers.first.order,
        );
      } else {
        widget.dataManager.clearSort(widget.targetField!.key);
      }
    } else {
      final newSorts = AcSortOrder();
      for (final tier in _sortTiers) {
        if (tier.order != AcEnumSortOrder.none) {
          newSorts.addSort(key: tier.key, order: tier.order, removeIfExist: true);
        }
      }
      widget.dataManager.setSortOrders(newSorts);
    }
    widget.onApply?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = isSingleFieldMode
        ? 'Sort: ${widget.targetField!.label}'
        : 'Sort Order';

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
              itemCount: _sortTiers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final tier = _sortTiers[i];

                return Row(
                  children: [
                    if (!isSingleFieldMode) ...[
                      Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: tier.key,
                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                          items: widget.fields.map((f) => DropdownMenuItem(value: f.key, child: Text(f.label, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                tier.key = val;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Order dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<AcEnumSortOrder>(
                        isExpanded: true,
                        initialValue: tier.order,
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                        items: const [
                          DropdownMenuItem(value: AcEnumSortOrder.ascending, child: Text('Ascending (A-Z, 0-9)')),
                          DropdownMenuItem(value: AcEnumSortOrder.descending, child: Text('Descending (Z-A, 9-0)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              tier.order = val;
                            });
                          }
                        },
                      ),
                    ),

                    // Delete tier button
                    if (!isSingleFieldMode && _sortTiers.length > 1) ...[
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeTier(i),
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
                  label: const Text('Add Sort Level'),
                  onPressed: _addTier,
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

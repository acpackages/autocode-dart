import 'package:flutter/material.dart';

/// Single item within [AcTomSelectOption].
class AcTomSelectOption<T> {
  final T value;
  final String label;
  final Widget? leading;

  const AcTomSelectOption({
    required this.value,
    required this.label,
    this.leading,
  });
}

/// A searchable multi-select tag picker with filter chips and search dialog.
class AcTomSelectInput<T> extends StatefulWidget {
  final List<AcTomSelectOption<T>> options;
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onChanged;
  final String hintText;
  final String label;

  const AcTomSelectInput({
    super.key,
    required this.options,
    this.selectedValues = const [],
    this.onChanged,
    this.hintText = 'Select options...',
    this.label = '',
  });

  @override
  State<AcTomSelectInput<T>> createState() => _AcTomSelectInputState<T>();
}

class _AcTomSelectInputState<T> extends State<AcTomSelectInput<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedValues);
  }

  void _openSelectionDialog() async {
    final searchCtrl = TextEditingController();
    List<AcTomSelectOption<T>> filteredOptions = List.from(widget.options);

    final result = await showDialog<List<T>>(
      context: context,
      builder: (ctx) {
        final List<T> tempSelected = List.from(_selected);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(widget.label.isNotEmpty ? widget.label : 'Select Options'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (query) {
                        setDialogState(() {
                          filteredOptions = widget.options
                              .where((o) => o.label.toLowerCase().contains(query.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredOptions.length,
                        itemBuilder: (context, i) {
                          final opt = filteredOptions[i];
                          final isChecked = tempSelected.contains(opt.value);

                          return CheckboxListTile(
                            dense: true,
                            title: Text(opt.label),
                            secondary: opt.leading,
                            value: isChecked,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  tempSelected.add(opt.value);
                                } else {
                                  tempSelected.remove(opt.value);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(tempSelected),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selected = result;
      });
      widget.onChanged?.call(_selected);
    }
  }

  void _remove(T val) {
    setState(() {
      _selected.remove(val);
    });
    widget.onChanged?.call(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _openSelectionDialog,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label.isNotEmpty ? widget.label : null,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: _selected.isEmpty
            ? Text(widget.hintText, style: TextStyle(color: theme.hintColor))
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selected.map((val) {
                  final opt = widget.options.firstWhere(
                    (o) => o.value == val,
                    orElse: () => AcTomSelectOption(value: val, label: val.toString()),
                  );
                  return InputChip(
                    label: Text(opt.label),
                    onDeleted: () => _remove(val),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../inputs/ac_tom_select_input.dart';
import '../ac_action_registry.dart';
import '../ac_screen_context.dart';

IconData _resolveIcon(String? name) {
  if (name == null || name.isEmpty) return Icons.help_outline;
  switch (name) {
    case 'search': return Icons.search;
    case 'calendar_today': case 'calendar': return Icons.calendar_today_outlined;
    case 'tune': case 'filter': return Icons.tune;
    case 'clear': case 'close': return Icons.close;
    case 'add': return Icons.add;
    case 'edit': return Icons.edit_outlined;
    case 'delete': return Icons.delete_outline;
    default: return Icons.help_outline;
  }
}

InputDecoration _inputDeco(Map<String, dynamic> p, AcScreenContext ctx) {
  final label = ctx.resolveString(p['label'] ?? '');
  final placeholder = ctx.resolveString(p['placeholder'] ?? '');
  final prefix = p['prefix']?.toString();
  final suffix = p['suffix']?.toString();
  final prefixIconName = p['prefixIcon']?.toString();
  final suffixIconName = p['suffixIcon']?.toString();

  return InputDecoration(
    labelText: label.isNotEmpty ? label : null,
    hintText: placeholder.isNotEmpty ? placeholder : null,
    prefixText: prefix,
    suffixText: suffix,
    prefixIcon: prefixIconName != null ? Icon(_resolveIcon(prefixIconName), size: 18) : null,
    suffixIcon: suffixIconName != null ? Icon(_resolveIcon(suffixIconName), size: 18) : null,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFE36314), width: 1.5),
    ),
  );
}

void _onValueChange(Map<String, dynamic> p, AcScreenContext ctx, dynamic val) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  if (bindKey.isNotEmpty) {
    ctx.mutate(bindKey, val);
  }
  final onChange = p['onChange'] ?? p['onChanged'];
  if (onChange != null) {
    AcActionRegistry.execute(onChange, ctx, event: {'value': val});
  }
}

// ── Text Input ───────────────────────────────────────────────────────────────
Widget buildTextInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey)?.toString() ?? '' : ctx.resolveString(p['value']);
  final readonly = ctx.resolve(p['readonly']) == true || ctx.resolve(p['disabled']) == true;

  return TextFormField(
    initialValue: current,
    readOnly: readonly,
    decoration: _inputDeco(p, ctx),
    onChanged: (v) => _onValueChange(p, ctx, v),
  );
}

// ── Number Input ─────────────────────────────────────────────────────────────
Widget buildNumberInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey)?.toString() ?? '' : ctx.resolveString(p['value']);
  final readonly = ctx.resolve(p['readonly']) == true || ctx.resolve(p['disabled']) == true;

  return TextFormField(
    initialValue: current,
    readOnly: readonly,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: _inputDeco(p, ctx),
    onChanged: (v) {
      final n = num.tryParse(v);
      _onValueChange(p, ctx, n ?? v);
    },
  );
}

// ── Amount Input ─────────────────────────────────────────────────────────────
Widget buildAmountInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildNumberInputElement({
    'prefix': p['currency'] ?? '₹',
    ...p,
  }, ctx);
}

// ── Date Input ───────────────────────────────────────────────────────────────
Widget buildDateInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey)?.toString() ?? '' : ctx.resolveString(p['value']);
  final readonly = ctx.resolve(p['readonly']) == true || ctx.resolve(p['disabled']) == true;

  return Builder(
    builder: (context) {
      return InkWell(
        onTap: readonly
            ? null
            : () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(current) ?? now,
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  _onValueChange(p, ctx, formatted);
                }
              },
        child: IgnorePointer(
          child: TextFormField(
            key: ValueKey(current),
            initialValue: current,
            readOnly: true,
            decoration: _inputDeco(p, ctx).copyWith(
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
          ),
        ),
      );
    },
  );
}

// ── Date Range Input ─────────────────────────────────────────────────────────
Widget buildDateRangeInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final fromKey = p['fromKey']?.toString() ?? p['startBind']?.toString() ?? p['startDateKey']?.toString() ?? 'startDate';
  final toKey = p['toKey']?.toString() ?? p['endBind']?.toString() ?? p['endDateKey']?.toString() ?? 'endDate';

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 135,
        child: buildDateInputElement({
          ...p,
          'bind': fromKey,
          'placeholder': p['startPlaceholder'] ?? p['placeholder'] ?? 'From',
        }, ctx),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text('To', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
      ),
      SizedBox(
        width: 135,
        child: buildDateInputElement({
          ...p,
          'bind': toKey,
          'placeholder': p['endPlaceholder'] ?? 'To',
        }, ctx),
      ),
    ],
  );
}

// ── Multiline Input ──────────────────────────────────────────────────────────
Widget buildMultilineInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey)?.toString() ?? '' : ctx.resolveString(p['value']);
  final readonly = ctx.resolve(p['readonly']) == true || ctx.resolve(p['disabled']) == true;
  final int minLines = (p['minLines'] as num?)?.toInt() ?? 2;
  final int maxLines = (p['maxLines'] as num?)?.toInt() ?? 5;

  return TextFormField(
    initialValue: current,
    readOnly: readonly,
    minLines: minLines,
    maxLines: maxLines,
    decoration: _inputDeco(p, ctx),
    onChanged: (v) => _onValueChange(p, ctx, v),
  );
}

// ── Checkbox Input ───────────────────────────────────────────────────────────
Widget buildCheckboxInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey) == true : ctx.resolve(p['value']) == true;
  final label = ctx.resolveString(p['label'] ?? '');
  final readonly = ctx.resolve(p['readonly']) == true || ctx.resolve(p['disabled']) == true;

  return CheckboxListTile(
    title: Text(label, style: const TextStyle(fontSize: 13)),
    value: current,
    dense: true,
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    onChanged: readonly ? null : (v) => _onValueChange(p, ctx, v),
  );
}

// ── Toggle Input ─────────────────────────────────────────────────────────────
Widget buildToggleInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey) == true : ctx.resolve(p['value']) == true;
  final label = ctx.resolveString(p['label'] ?? '');
  final readonly = ctx.resolve(p['readonly']) == true || ctx.resolve(p['disabled']) == true;

  return SwitchListTile(
    title: Text(label, style: const TextStyle(fontSize: 13)),
    value: current,
    dense: true,
    contentPadding: EdgeInsets.zero,
    onChanged: readonly ? null : (v) => _onValueChange(p, ctx, v),
  );
}

// ── Barcode Input ────────────────────────────────────────────────────────────
Widget buildBarcodeInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildTextInputElement({
    'suffixIcon': 'barcode',
    'placeholder': 'Scan or enter barcode...',
    ...p,
  }, ctx);
}

// ── Select Input (act-select-input) ──────────────────────────────────────────
Widget buildSelectInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey) : ctx.resolve(p['value']);

  final rawOptions = p['options'] ?? p['items'];
  final List<dynamic> options = (rawOptions is String)
      ? (ctx.resolve(rawOptions) is List ? ctx.resolve(rawOptions) as List : [])
      : (rawOptions is List ? rawOptions : []);

  final valueKey = p['valueKey']?.toString() ?? 'value';
  final labelKey = p['labelKey']?.toString() ?? 'label';
  final readonly = ctx.resolve(p['readonly']) == true;

  final dropdownItems = <DropdownMenuItem<dynamic>>[];
  for (final opt in options) {
    if (opt is Map) {
      final v = opt[valueKey] ?? opt['id'];
      final l = opt[labelKey]?.toString() ?? opt['name']?.toString() ?? v?.toString() ?? '';
      dropdownItems.add(DropdownMenuItem(value: v, child: Text(l, style: const TextStyle(fontSize: 13))));
    } else {
      dropdownItems.add(DropdownMenuItem(value: opt, child: Text(opt.toString(), style: const TextStyle(fontSize: 13))));
    }
  }

  return DropdownButtonFormField<dynamic>(
    initialValue: current,
    decoration: _inputDeco(p, ctx),
    items: dropdownItems,
    onChanged: readonly
        ? null
        : (v) {
            _onValueChange(p, ctx, v);
            final onSelect = p['onSelect'];
            if (onSelect != null) {
              final selectedRecord = options.firstWhere(
                (o) => (o is Map && (o[valueKey] == v || o['id'] == v)) || o == v,
                orElse: () => null,
              );
              AcActionRegistry.execute(onSelect, ctx, event: {'record': selectedRecord, 'value': v});
            }
          },
  );
}

// ── Search Select (act-select-search-input & specialized pickers) ─────────────
Widget buildSearchSelectInputElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? p['stateKey']?.toString() ?? '';
  final current = bindKey.isNotEmpty ? ctx.get(bindKey) : ctx.resolve(p['value']);
  final label = ctx.resolveString(p['label'] ?? '');
  final placeholder = ctx.resolveString(p['placeholder'] ?? 'Search...');

  final rawOptions = p['options'] ?? p['items'];
  final List<dynamic> options = (rawOptions is String)
      ? (ctx.resolve(rawOptions) is List ? ctx.resolve(rawOptions) as List : [])
      : (rawOptions is List ? rawOptions : []);

  final valueKey = p['valueKey']?.toString() ?? 'id';
  final labelKey = p['labelKey']?.toString() ?? 'name';

  final tomOptions = <AcTomSelectOption<dynamic>>[];
  for (final opt in options) {
    if (opt is Map) {
      final v = opt[valueKey] ?? opt['value'];
      final l = opt[labelKey]?.toString() ?? opt['label']?.toString() ?? v?.toString() ?? '';
      tomOptions.add(AcTomSelectOption(value: v, label: l));
    } else {
      tomOptions.add(AcTomSelectOption(value: opt, label: opt.toString()));
    }
  }

  return AcTomSelectInput<dynamic>(
    label: label,
    hintText: placeholder,
    options: tomOptions,
    selectedValues: current != null ? [current] : [],
    onChanged: (values) {
      final val = values.isNotEmpty ? values.first : null;
      _onValueChange(p, ctx, val);

      final onSelect = p['onSelect'];
      if (onSelect != null) {
        final selectedRecord = options.firstWhere(
          (o) => (o is Map && (o[valueKey] == val || o['value'] == val)) || o == val,
          orElse: () => null,
        );
        AcActionRegistry.execute(onSelect, ctx, event: {'record': selectedRecord, 'value': val});
      }
    },
  );
}

// ── Specialized Picker Helpers ───────────────────────────────────────────────
Widget buildPickerPartyElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSearchSelectInputElement({
    'label': p['label'] ?? 'Party',
    'placeholder': p['placeholder'] ?? 'Search party...',
    'labelKey': 'name',
    'valueKey': 'id',
    ...p,
  }, ctx);
}

Widget buildPickerProductElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSearchSelectInputElement({
    'label': p['label'] ?? 'Product',
    'placeholder': p['placeholder'] ?? 'Search product...',
    'labelKey': 'name',
    'valueKey': 'id',
    ...p,
  }, ctx);
}

Widget buildPickerLedgerAccountElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSearchSelectInputElement({
    'label': p['label'] ?? 'Ledger Account',
    'placeholder': p['placeholder'] ?? 'Search account...',
    'labelKey': 'name',
    'valueKey': 'id',
    ...p,
  }, ctx);
}

Widget buildPickerPaymentMethodElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSelectInputElement({
    'label': p['label'] ?? 'Payment Method',
    'placeholder': p['placeholder'] ?? 'Select payment method...',
    ...p,
  }, ctx);
}

Widget buildPickerProductCategoryElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSelectInputElement({
    'label': p['label'] ?? 'Category',
    'placeholder': p['placeholder'] ?? 'Select category...',
    ...p,
  }, ctx);
}

Widget buildPickerTaxRateElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSelectInputElement({
    'label': p['label'] ?? 'Tax Rate',
    'placeholder': p['placeholder'] ?? 'Select tax rate...',
    ...p,
  }, ctx);
}

Widget buildPickerUomElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSelectInputElement({
    'label': p['label'] ?? 'Unit',
    'placeholder': p['placeholder'] ?? 'Select unit...',
    ...p,
  }, ctx);
}

Widget buildPickerCurrencyElement(Map<String, dynamic> p, AcScreenContext ctx) {
  return buildSelectInputElement({
    'label': p['label'] ?? 'Currency',
    'placeholder': p['placeholder'] ?? 'Select currency...',
    ...p,
  }, ctx);
}

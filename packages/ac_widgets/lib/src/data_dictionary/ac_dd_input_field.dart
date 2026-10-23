import 'package:flutter/material.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/// Form input field automatically generated from an [AcDDTableColumn] definition.
class AcDDInputField extends StatefulWidget {
  final AcDDTableColumn column;
  final dynamic initialValue;
  final ValueChanged<dynamic>? onChanged;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;

  const AcDDInputField({
    super.key,
    required this.column,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.decoration,
  });

  @override
  State<AcDDInputField> createState() => _AcDDInputFieldState();
}

class _AcDDInputFieldState extends State<AcDDInputField> {
  late dynamic _value;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _textController = TextEditingController(text: _value?.toString() ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String? _defaultValidator(String? text) {
    if (widget.validator != null) {
      final customError = widget.validator!(text);
      if (customError != null) return customError;
    }

    final isRequired = widget.column.isNotNull();
    if (isRequired && (text == null || text.trim().isEmpty)) {
      return '${widget.column.getColumnTitle()} is required';
    }

    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_value?.toString() ?? '') ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = picked.toIso8601String().split('T').first;
      setState(() {
        _value = formatted;
        _textController.text = formatted;
      });
      widget.onChanged?.call(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.column.getColumnTitle();
    final colType = widget.column.columnType;

    // Boolean Switch
    if (colType == AcEnumDDColumnType.yesNo) {
      final bool currentBool = _value == true || _value == 1 || _value == 'true';
      return SwitchListTile(
        title: Text(title),
        value: currentBool,
        onChanged: (val) {
          setState(() {
            _value = val;
          });
          widget.onChanged?.call(val);
        },
      );
    }

    // Date Picker Input
    if (colType == AcEnumDDColumnType.date || colType == AcEnumDDColumnType.datetime) {
      return TextFormField(
        controller: _textController,
        readOnly: true,
        decoration: (widget.decoration ?? InputDecoration(labelText: title)).copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: _pickDate,
          ),
        ),
        validator: _defaultValidator,
        onTap: _pickDate,
      );
    }

    // Number Input
    if (colType == AcEnumDDColumnType.integer ||
        colType == AcEnumDDColumnType.double_ ||
        colType == AcEnumDDColumnType.autoIncrement) {
      return TextFormField(
        controller: _textController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: widget.decoration ?? InputDecoration(labelText: title),
        validator: _defaultValidator,
        onChanged: (val) {
          final numVal = num.tryParse(val);
          _value = numVal ?? val;
          widget.onChanged?.call(_value);
        },
      );
    }

    // Password Input
    if (colType == AcEnumDDColumnType.password) {
      return TextFormField(
        controller: _textController,
        obscureText: true,
        decoration: widget.decoration ?? InputDecoration(labelText: title),
        validator: _defaultValidator,
        onChanged: (val) {
          _value = val;
          widget.onChanged?.call(val);
        },
      );
    }

    // Standard Text Input
    return TextFormField(
      controller: _textController,
      decoration: widget.decoration ?? InputDecoration(labelText: title),
      validator: _defaultValidator,
      onChanged: (val) {
        _value = val;
        widget.onChanged?.call(val);
      },
    );
  }
}

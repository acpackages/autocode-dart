import 'package:flutter/material.dart';
import '../data_manager/ac_data_row.dart';

/// Supported data types for datagrid columns.
enum AcDatagridColumnDataType {
  string,
  number,
  boolean,
  date,
  datetime,
  actions,
}

/// Supported pinning positions for datagrid columns.
enum AcColumnPin {
  none,
  left,
  right,
}

/// Renderer function for datagrid cells.
typedef AcCellRenderer = Widget Function(
  BuildContext context,
  AcDataRow row,
  dynamic value,
);

/// Editor builder function for editable datagrid cells.
typedef AcCellEditor = Widget Function(
  BuildContext context,
  AcDataRow row,
  dynamic value,
  ValueChanged<dynamic> onCommit,
);

/// Defines the configuration, layout, and behaviors of a column in [AcDatagrid].
class AcDatagridColumn {
  /// The field/property key in the row data map.
  final String field;

  /// The header title displayed. Defaults to [field].
  final String title;

  /// Width of the column in pixels.
  double width;

  /// Minimum allowed column width during resizing.
  final double minWidth;

  /// Maximum allowed column width during resizing.
  final double maxWidth;

  /// Whether the column is visible.
  bool visible;

  /// Data type of the column's values.
  final AcDatagridColumnDataType dataType;

  /// Whether sorting is permitted on this column.
  final bool allowSort;

  /// Whether filtering is permitted on this column.
  final bool allowFilter;

  /// Whether interactive column resizing is permitted.
  final bool allowResize;

  /// Whether this column is pinned to the left or right edge.
  final AcColumnPin pinned;

  /// Horizontal text alignment for cells in this column.
  final TextAlign? textAlign;

  /// Custom cell widget renderer.
  final AcCellRenderer? cellRenderer;

  /// Custom cell editor widget builder.
  final AcCellEditor? cellEditor;

  /// Custom value getter if not a standard map lookup.
  final dynamic Function(AcDataRow row)? valueGetter;

  /// Custom value setter for inline editing.
  final void Function(AcDataRow row, dynamic value)? valueSetter;

  AcDatagridColumn({
    required this.field,
    String? title,
    this.width = 150.0,
    this.minWidth = 60.0,
    this.maxWidth = 600.0,
    this.visible = true,
    this.dataType = AcDatagridColumnDataType.string,
    this.allowSort = true,
    this.allowFilter = true,
    this.allowResize = true,
    this.pinned = AcColumnPin.none,
    this.textAlign,
    this.cellRenderer,
    this.cellEditor,
    this.valueGetter,
    this.valueSetter,
  }) : title = title ?? field;

  /// Gets the value for this column from [row].
  dynamic getValue(AcDataRow row) {
    if (valueGetter != null) return valueGetter!(row);
    return row.getValue(field);
  }

  /// Sets the value for this column on [row].
  void setValue(AcDataRow row, dynamic value) {
    if (valueSetter != null) {
      valueSetter!(row, value);
    } else {
      row.setValue(field, value);
    }
  }

  /// Default text alignment based on data type if not explicitly configured.
  TextAlign get effectiveTextAlign {
    if (textAlign != null) return textAlign!;
    switch (dataType) {
      case AcDatagridColumnDataType.number:
        return TextAlign.right;
      case AcDatagridColumnDataType.boolean:
        return TextAlign.center;
      default:
        return TextAlign.left;
    }
  }
}

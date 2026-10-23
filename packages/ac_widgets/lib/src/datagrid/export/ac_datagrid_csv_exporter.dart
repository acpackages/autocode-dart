import '../ac_datagrid_column.dart';
import '../../data_manager/ac_data_manager.dart';

/// Exports current filtered/sorted rows from [AcDataManager] into CSV format.
class AcDatagridCsvExporter {
  /// Converts visible datagrid columns and displayed rows to a CSV string.
  static String exportToString({
    required AcDataManager dataManager,
    required List<AcDatagridColumn> columns,
    String delimiter = ',',
  }) {
    final visibleCols = columns.where((c) => c.visible).toList();
    final buffer = StringBuffer();

    // Header row
    final headerTitles = visibleCols.map((c) => _escapeCsv(c.title, delimiter)).join(delimiter);
    buffer.writeln(headerTitles);

    // Data rows
    for (final row in dataManager.displayedRows) {
      final values = visibleCols.map((c) {
        final val = c.getValue(row);
        return _escapeCsv(val?.toString() ?? '', delimiter);
      }).join(delimiter);
      buffer.writeln(values);
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value, String delimiter) {
    if (value.contains(delimiter) || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}

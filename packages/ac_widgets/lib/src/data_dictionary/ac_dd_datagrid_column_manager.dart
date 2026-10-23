import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import '../datagrid/ac_datagrid_column.dart';

/// Translates [AcDataDictionary] table definitions into [AcDatagridColumn] configurations.
class AcDDDatagridColumnManager {
  /// Generates a list of [AcDatagridColumn]s for [tableName].
  static List<AcDatagridColumn> getTableColumns({
    required String tableName,
    String dataDictionaryName = 'default',
    List<String>? includeColumns,
    List<String>? excludeColumns,
    List<String>? hiddenColumns,
    List<String>? visibleColumns,
    Map<String, AcDatagridColumn>? columnOverrides,
  }) {
    final ddTable = AcDataDictionary.getTable(
      tableName: tableName,
      dataDictionaryName: dataDictionaryName,
    );

    if (ddTable == null) return [];

    return getColumnsFromTable(
      table: ddTable,
      includeColumns: includeColumns,
      excludeColumns: excludeColumns,
      hiddenColumns: hiddenColumns,
      visibleColumns: visibleColumns,
      columnOverrides: columnOverrides,
    );
  }

  /// Generates columns directly from an [AcDDTable] instance.
  static List<AcDatagridColumn> getColumnsFromTable({
    required AcDDTable table,
    List<String>? includeColumns,
    List<String>? excludeColumns,
    List<String>? hiddenColumns,
    List<String>? visibleColumns,
    Map<String, AcDatagridColumn>? columnOverrides,
  }) {
    final List<AcDatagridColumn> result = [];

    for (final col in table.tableColumns.values) {
      final name = col.columnName;

      if (excludeColumns != null && excludeColumns.contains(name)) continue;
      if (includeColumns != null && !includeColumns.contains(name)) continue;

      if (columnOverrides != null && columnOverrides.containsKey(name)) {
        result.add(columnOverrides[name]!);
        continue;
      }

      final dataType = _mapColumnType(col.columnType);
      final bool isHiddenDefault = col.columnType == AcEnumDDColumnType.password ||
          col.columnType == AcEnumDDColumnType.blob ||
          col.columnType == AcEnumDDColumnType.json;

      bool isVisible = !isHiddenDefault;
      if (visibleColumns != null && visibleColumns.contains(name)) isVisible = true;
      if (hiddenColumns != null && hiddenColumns.contains(name)) isVisible = false;

      result.add(
        AcDatagridColumn(
          field: name,
          title: col.getColumnTitle(),
          dataType: dataType,
          visible: isVisible,
          allowSort: !isHiddenDefault,
          allowFilter: !isHiddenDefault,
        ),
      );
    }

    return result;
  }

  static AcDatagridColumnDataType _mapColumnType(AcEnumDDColumnType type) {
    switch (type) {
      case AcEnumDDColumnType.integer:
      case AcEnumDDColumnType.double_:
      case AcEnumDDColumnType.autoIncrement:
      case AcEnumDDColumnType.autoNumber:
      case AcEnumDDColumnType.autoIndex:
        return AcDatagridColumnDataType.number;

      case AcEnumDDColumnType.date:
        return AcDatagridColumnDataType.date;

      case AcEnumDDColumnType.datetime:
      case AcEnumDDColumnType.timestamp:
        return AcDatagridColumnDataType.datetime;

      case AcEnumDDColumnType.yesNo:
        return AcDatagridColumnDataType.boolean;

      default:
        return AcDatagridColumnDataType.string;
    }
  }
}

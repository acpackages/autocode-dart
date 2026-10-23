import 'package:flutter/material.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import '../data_manager/ac_data_manager.dart';
import '../data_manager/ac_data_row.dart';
import '../datagrid/ac_datagrid.dart';
import '../datagrid/ac_datagrid_column.dart';
import 'ac_dd_datagrid_column_manager.dart';

/// A schema-driven [AcDatagrid] that automatically derives its column definitions
/// from an [AcDataDictionary] table schema.
class AcDDDatagrid extends StatelessWidget {
  final AcDataManager dataManager;
  final String tableName;
  final String dataDictionaryName;
  final AcDDTable? table;
  final List<String>? includeColumns;
  final List<String>? excludeColumns;
  final List<String>? hiddenColumns;
  final List<String>? visibleColumns;
  final Map<String, AcDatagridColumn>? columnOverrides;
  final bool showPagination;
  final bool showSelectionCheckbox;
  final ValueChanged<AcDataRow>? onRowTap;

  const AcDDDatagrid({
    super.key,
    required this.dataManager,
    required this.tableName,
    this.dataDictionaryName = 'default',
    this.table,
    this.includeColumns,
    this.excludeColumns,
    this.hiddenColumns,
    this.visibleColumns,
    this.columnOverrides,
    this.showPagination = true,
    this.showSelectionCheckbox = false,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<AcDatagridColumn> columns;

    if (table != null) {
      columns = AcDDDatagridColumnManager.getColumnsFromTable(
        table: table!,
        includeColumns: includeColumns,
        excludeColumns: excludeColumns,
        hiddenColumns: hiddenColumns,
        visibleColumns: visibleColumns,
        columnOverrides: columnOverrides,
      );
    } else {
      columns = AcDDDatagridColumnManager.getTableColumns(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
        includeColumns: includeColumns,
        excludeColumns: excludeColumns,
        hiddenColumns: hiddenColumns,
        visibleColumns: visibleColumns,
        columnOverrides: columnOverrides,
      );
    }

    return AcDatagrid(
      dataManager: dataManager,
      columns: columns,
      showPagination: showPagination,
      showSelectionCheckbox: showSelectionCheckbox,
      onRowTap: onRowTap,
    );
  }
}

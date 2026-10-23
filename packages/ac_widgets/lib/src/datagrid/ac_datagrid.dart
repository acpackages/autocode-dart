import 'package:flutter/material.dart';
import 'package:autocode/autocode.dart';
import '../data_manager/ac_data_manager.dart';
import '../data_manager/ac_data_row.dart';
import '../pagination/ac_pagination.dart';
import '../popups/filter/ac_data_filter_popup.dart';
import '../popups/filter/ac_filter_field.dart';
import 'ac_datagrid_column.dart';
import 'export/ac_datagrid_csv_exporter.dart';

/// Callback when a cell value is committed in inline editing mode.
typedef AcCellEditCommitCallback = void Function(
  AcDataRow row,
  AcDatagridColumn column,
  dynamic newValue,
);

/// A feature-complete, virtualized data grid widget.
///
/// Features include sticky header, resizable columns, interactive sorting,
/// column-specific filter popups, inline editing, tree hierarchy indentation,
/// selection checkboxes, zebra striping, pagination, and CSV export.
class AcDatagrid extends StatefulWidget {
  final AcDataManager dataManager;
  final List<AcDatagridColumn> columns;

  /// Height of the sticky header row.
  final double headerHeight;

  /// Default height of each data row.
  final double rowHeight;

  /// Whether to display a row selection checkbox column.
  final bool showSelectionCheckbox;

  /// Width of the selection checkbox column.
  final double selectionColumnWidth;

  /// Whether to show the bottom pagination bar.
  final bool showPagination;

  /// Whether to apply alternating background colors to rows.
  final bool zebraStriping;

  /// Callback when a row is tapped.
  final ValueChanged<AcDataRow>? onRowTap;

  /// Callback when an inline edit is committed.
  final AcCellEditCommitCallback? onCellEditCommit;

  const AcDatagrid({
    super.key,
    required this.dataManager,
    required this.columns,
    this.headerHeight = 44.0,
    this.rowHeight = 42.0,
    this.showSelectionCheckbox = false,
    this.selectionColumnWidth = 46.0,
    this.showPagination = true,
    this.zebraStriping = true,
    this.onRowTap,
    this.onCellEditCommit,
  });

  /// Exports current data to CSV.
  String exportToCsv({String delimiter = ','}) {
    return AcDatagridCsvExporter.exportToString(
      dataManager: dataManager,
      columns: columns,
      delimiter: delimiter,
    );
  }

  @override
  State<AcDatagrid> createState() => _AcDatagridState();
}

class _EditingCellKey {
  final String rowId;
  final String field;
  const _EditingCellKey(this.rowId, this.field);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EditingCellKey && runtimeType == other.runtimeType && rowId == other.rowId && field == other.field;

  @override
  int get hashCode => rowId.hashCode ^ field.hashCode;
}

class _AcDatagridState extends State<AcDatagrid> {
  final ScrollController _headerHorizontalScrollController = ScrollController();
  final ScrollController _bodyHorizontalScrollController = ScrollController();
  bool _isSyncingScroll = false;

  _EditingCellKey? _activeEditCell;
  dynamic _editValue;

  @override
  void initState() {
    super.initState();
    _bodyHorizontalScrollController.addListener(_onBodyHorizontalScroll);
    _headerHorizontalScrollController.addListener(_onHeaderHorizontalScroll);
  }

  @override
  void dispose() {
    _bodyHorizontalScrollController.removeListener(_onBodyHorizontalScroll);
    _headerHorizontalScrollController.removeListener(_onHeaderHorizontalScroll);
    _headerHorizontalScrollController.dispose();
    _bodyHorizontalScrollController.dispose();
    super.dispose();
  }

  void _onBodyHorizontalScroll() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    if (_headerHorizontalScrollController.hasClients) {
      _headerHorizontalScrollController.jumpTo(_bodyHorizontalScrollController.offset);
    }
    _isSyncingScroll = false;
  }

  void _onHeaderHorizontalScroll() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    if (_bodyHorizontalScrollController.hasClients) {
      _bodyHorizontalScrollController.jumpTo(_headerHorizontalScrollController.offset);
    }
    _isSyncingScroll = false;
  }

  double get _totalGridWidth {
    double w = widget.showSelectionCheckbox ? widget.selectionColumnWidth : 0.0;
    for (final col in widget.columns) {
      if (col.visible) w += col.width;
    }
    return w;
  }

  void _onHeaderSortTap(AcDatagridColumn col) {
    if (!col.allowSort) return;
    final currentSort = widget.dataManager.sortOrders.sortOrders.where((s) => s.key == col.field).toList();
    AcEnumSortOrder nextOrder;
    if (currentSort.isEmpty) {
      nextOrder = AcEnumSortOrder.ascending;
    } else if (currentSort.first.order == AcEnumSortOrder.ascending) {
      nextOrder = AcEnumSortOrder.descending;
    } else {
      nextOrder = AcEnumSortOrder.none;
    }

    if (nextOrder == AcEnumSortOrder.none) {
      widget.dataManager.clearSort(col.field);
    } else {
      widget.dataManager.setSort(key: col.field, order: nextOrder, clearExisting: true);
    }
  }

  void _openHeaderFilter(BuildContext context, AcDatagridColumn col) {
    final filterField = AcFilterField(
      key: col.field,
      label: col.title,
      type: col.dataType.name,
      allowFilter: col.allowFilter,
    );

    AcDataFilterPopup.show(
      context: context,
      dataManager: widget.dataManager,
      fields: [filterField],
      targetField: filterField,
    );
  }

  void _startEditing(AcDataRow row, AcDatagridColumn col) {
    setState(() {
      _activeEditCell = _EditingCellKey(row.id, col.field);
      _editValue = col.getValue(row);
    });
  }

  void _commitEditing(AcDataRow row, AcDatagridColumn col) {
    if (_activeEditCell != null) {
      col.setValue(row, _editValue);
      widget.onCellEditCommit?.call(row, col, _editValue);
      setState(() {
        _activeEditCell = null;
      });
      widget.dataManager.refresh();
    }
  }

  void _cancelEditing() {
    setState(() {
      _activeEditCell = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataManager,
      builder: (context, _) {
        return Column(
          children: [
            // Sticky Header
            _buildHeader(context),

            // Virtualized Body
            Expanded(child: _buildBody(context)),

            // Footer
            if (widget.showPagination)
              AcPagination(dataManager: widget.dataManager),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final visibleCols = widget.columns.where((c) => c.visible).toList();

    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1.5)),
      ),
      child: SingleChildScrollView(
        controller: _headerHorizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _totalGridWidth,
          child: Row(
            children: [
              if (widget.showSelectionCheckbox) ...[
                SizedBox(
                  width: widget.selectionColumnWidth,
                  child: Center(
                    child: Checkbox(
                      isError: false,
                      value: widget.dataManager.displayedRows.isNotEmpty &&
                          widget.dataManager.displayedRows.every((r) => r.isSelected),
                      onChanged: (val) {
                        if (val == true) {
                          widget.dataManager.selectAll();
                        } else {
                          widget.dataManager.clearSelection();
                        }
                      },
                    ),
                  ),
                ),
              ],
              for (final col in visibleCols) _buildHeaderCell(context, col),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, AcDatagridColumn col) {
    final theme = Theme.of(context);
    final currentSort = widget.dataManager.sortOrders.sortOrders.where((s) => s.key == col.field).toList();
    final hasSort = currentSort.isNotEmpty && currentSort.first.order != AcEnumSortOrder.none;
    final isAsc = hasSort && currentSort.first.order == AcEnumSortOrder.ascending;

    final hasFilter = widget.dataManager.filterGroup.filters.any((f) => f.key == col.field);

    return SizedBox(
      width: col.width,
      height: widget.headerHeight,
      child: Stack(
        children: [
          // Header content
          InkWell(
            onTap: col.allowSort ? () => _onHeaderSortTap(col) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      col.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      textAlign: col.effectiveTextAlign,
                    ),
                  ),
                  if (hasSort) ...[
                    const SizedBox(width: 2),
                    Icon(
                      isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                  if (col.allowFilter && col.width >= 70) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.filter_alt,
                        size: 14,
                        color: hasFilter ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.6),
                      ),
                      onPressed: () => _openHeaderFilter(context, col),
                      splashRadius: 12,
                      tooltip: 'Filter ${col.title}',
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Column resize handle
          if (col.allowResize)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    setState(() {
                      col.width = (col.width + details.delta.dx).clamp(col.minWidth, col.maxWidth);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.dataManager.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rows = widget.dataManager.displayedRows;
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('No records to display', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    final visibleCols = widget.columns.where((c) => c.visible).toList();

    return SingleChildScrollView(
      controller: _bodyHorizontalScrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _totalGridWidth,
        child: ListView.builder(
          itemCount: rows.length,
          itemExtent: widget.rowHeight,
          itemBuilder: (context, i) {
            final row = rows[i];
            return _buildRow(context, row, i, visibleCols);
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, AcDataRow row, int index, List<AcDatagridColumn> visibleCols) {
    final theme = Theme.of(context);
    final isEven = index % 2 == 0;
    final bg = widget.zebraStriping && !isEven
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.12)
        : Colors.transparent;

    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: row.isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : bg,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          // Selection checkbox
          if (widget.showSelectionCheckbox) ...[
            SizedBox(
              width: widget.selectionColumnWidth,
              child: Center(
                child: Checkbox(
                  value: row.isSelected,
                  onChanged: (val) => widget.dataManager.toggleRowSelection(row),
                ),
              ),
            ),
          ],

          // Data cells
          for (int c = 0; c < visibleCols.length; c++)
            _buildCell(context, row, visibleCols[c], isFirstColumn: c == 0),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, AcDataRow row, AcDatagridColumn col, {bool isFirstColumn = false}) {
    final isEditing = _activeEditCell == _EditingCellKey(row.id, col.field);

    if (isEditing) {
      return _buildCellEditor(context, row, col);
    }

    final dynamic val = col.getValue(row);

    Widget content;
    if (col.cellRenderer != null) {
      content = col.cellRenderer!(context, row, val);
    } else if (col.dataType == AcDatagridColumnDataType.boolean) {
      content = Center(
        child: Icon(
          val == true ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: val == true ? Colors.green : Colors.grey,
        ),
      );
    } else {
      content = Text(
        val?.toString() ?? '',
        textAlign: col.effectiveTextAlign,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Add tree hierarchy indentation to first column if applicable
    if (isFirstColumn && (row.level > 0 || row.hasChildren)) {
      content = Row(
        children: [
          SizedBox(width: row.level * 20.0),
          if (row.hasChildren)
            InkWell(
              onTap: () => widget.dataManager.toggleRowExpansion(row),
              child: Icon(
                row.isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 4),
          Expanded(child: content),
        ],
      );
    }

    return InkWell(
      onTap: widget.onRowTap != null ? () => widget.onRowTap!(row) : null,
      onDoubleTap: () => _startEditing(row, col),
      child: Container(
        width: col.width,
        height: widget.rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.centerLeft,
        child: content,
      ),
    );
  }

  Widget _buildCellEditor(BuildContext context, AcDataRow row, AcDatagridColumn col) {
    if (col.cellEditor != null) {
      return SizedBox(
        width: col.width,
        child: col.cellEditor!(context, row, _editValue, (newVal) {
          _editValue = newVal;
          _commitEditing(row, col);
        }),
      );
    }

    // Default inline editor
    return Container(
      width: col.width,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _editValue?.toString() ?? '',
              autofocus: true,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(6)),
              onChanged: (v) => _editValue = v,
              onFieldSubmitted: (_) => _commitEditing(row, col),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 16, color: Colors.green),
            onPressed: () => _commitEditing(row, col),
            splashRadius: 12,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            onPressed: _cancelEditing,
            splashRadius: 12,
          ),
        ],
      ),
    );
  }
}

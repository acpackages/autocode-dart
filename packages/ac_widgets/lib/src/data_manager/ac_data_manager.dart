import 'package:flutter/foundation.dart';
import 'package:autocode/autocode.dart';
import 'ac_data_row.dart';
import 'ac_on_demand_args.dart';
import 'evaluators/ac_filter_evaluator.dart';
import 'evaluators/ac_search_evaluator.dart';
import 'evaluators/ac_sort_comparator.dart';

/// Callback signature for fetching data on demand from a remote service.
typedef AcOnDemandFetchCallback = Future<AcOnDemandResponseArgs> Function(
  AcOnDemandRequestArgs args,
);

/// The central data engine powering [AcDatagrid], [AcRepeater], and [AcPagination].
///
/// Manages in-memory and on-demand data transformation, multi-column sorting,
/// nested filter groups, text searching, pagination, tree hierarchies, and row selection.
class AcDataManager extends ChangeNotifier {
  /// Field in the data item that uniquely identifies a row. Defaults to 'id'.
  String idField;

  /// Field in the data item pointing to a parent row's ID for tree structures.
  String? parentIdField;

  /// Raw list of data items.
  List<dynamic> _rawData = [];

  /// All processed rows.
  List<AcDataRow> _rows = [];

  /// Processed rows currently matching search, filter, and sort.
  List<AcDataRow> _filteredRows = [];

  /// Final rows currently displayed (factoring in pagination and tree expansion).
  List<AcDataRow> _displayedRows = [];

  /// Active filter group containing compound filter rules.
  AcFilterGroup _filterGroup = AcFilterGroup();

  /// Active multi-column sort rules.
  AcSortOrder _sortOrders = AcSortOrder();

  /// Current search query string.
  String? _searchQuery;

  /// Specific keys to restrict search evaluation to.
  List<String>? _searchKeys;

  /// Whether pagination is enabled.
  bool _usePagination = false;

  /// 1-based active page index.
  int _activePage = 1;

  /// Number of rows per page.
  int _pageSize = 50;

  /// Total count of rows (reflects remote count in on-demand mode, or local count).
  int _totalRows = 0;

  /// Optional remote on-demand fetch callback.
  AcOnDemandFetchCallback? onDemandFetch;

  /// Whether an on-demand remote fetch is currently executing.
  bool _isLoading = false;

  AcDataManager({
    List<dynamic>? data,
    this.idField = 'id',
    this.parentIdField,
    bool usePagination = false,
    int pageSize = 50,
    this.onDemandFetch,
  })  : _usePagination = usePagination,
        _pageSize = pageSize {
    if (data != null && data.isNotEmpty) {
      setData(data);
    }
  }

  // --- Getters ---

  List<dynamic> get data => _rawData;
  List<AcDataRow> get rows => _rows;
  List<AcDataRow> get displayedRows => _displayedRows;
  AcFilterGroup get filterGroup => _filterGroup;
  AcSortOrder get sortOrders => _sortOrders;
  String? get searchQuery => _searchQuery;
  List<String>? get searchKeys => _searchKeys;
  bool get usePagination => _usePagination;
  int get activePage => _activePage;
  int get pageSize => _pageSize;
  int get totalRows => _totalRows;
  bool get isLoading => _isLoading;

  /// Selected rows.
  List<AcDataRow> get selectedRows =>
      _rows.where((r) => r.isSelected).toList();

  /// Total number of pages.
  int get totalPages {
    if (_pageSize <= 0) return 1;
    final total = onDemandFetch != null ? _totalRows : _filteredRows.length;
    final pages = (total / _pageSize).ceil();
    return pages > 0 ? pages : 1;
  }

  /// 1-based start row index for the current page.
  int get startRow {
    if (_totalRows == 0 && _filteredRows.isEmpty) return 0;
    return ((_activePage - 1) * _pageSize) + 1;
  }

  /// 1-based end row index for the current page.
  int get endRow {
    final total = onDemandFetch != null ? _totalRows : _filteredRows.length;
    final calculated = _activePage * _pageSize;
    return calculated > total ? total : calculated;
  }

  // --- Setters / Modifiers ---

  /// Replaces the raw data items and refreshes the view.
  void setData(List<dynamic> items) {
    _rawData = List.from(items);
    _buildRows();
    refresh();
  }

  /// Appends new data items to the existing dataset.
  void addData(List<dynamic> items) {
    _rawData.addAll(items);
    _buildRows();
    refresh();
  }

  /// Updates or sets the active [AcFilterGroup].
  void setFilterGroup(AcFilterGroup? group) {
    _filterGroup = group ?? AcFilterGroup();
    _activePage = 1;
    refresh();
  }

  /// Updates or sets the active [AcSortOrder].
  void setSortOrders(AcSortOrder? sorts) {
    _sortOrders = sorts ?? AcSortOrder();
    refresh();
  }

  /// Adds or updates a sort rule for [key].
  void setSort({
    required String key,
    required AcEnumSortOrder order,
    bool clearExisting = false,
  }) {
    if (clearExisting) {
      _sortOrders.sortOrders.clear();
    }
    _sortOrders.addSort(key: key, order: order, removeIfExist: true);
    refresh();
  }

  /// Clears sort for [key].
  void clearSort(String key) {
    _sortOrders.removeSort(key: key);
    refresh();
  }

  /// Clears all sort rules.
  void clearAllSorts() {
    _sortOrders.sortOrders.clear();
    refresh();
  }

  /// Updates the text search query and search keys.
  void setSearchQuery(String? query, {List<String>? searchKeys}) {
    _searchQuery = query;
    if (searchKeys != null) _searchKeys = searchKeys;
    _activePage = 1;
    refresh();
  }

  /// Enables or disables pagination.
  void setUsePagination(bool value) {
    if (_usePagination != value) {
      _usePagination = value;
      refresh();
    }
  }

  /// Changes the active page index (1-based).
  void setActivePage(int page) {
    final clamped = page.clamp(1, totalPages);
    if (_activePage != clamped) {
      _activePage = clamped;
      refresh();
    }
  }

  /// Changes the page size.
  void setPageSize(int size) {
    if (size > 0 && _pageSize != size) {
      _pageSize = size;
      _activePage = 1;
      refresh();
    }
  }

  // --- Selection ---

  /// Toggles selection of [row].
  void toggleRowSelection(AcDataRow row) {
    row.isSelected = !row.isSelected;
    notifyListeners();
  }

  /// Sets selection state of [row].
  void setRowSelection(AcDataRow row, bool isSelected) {
    if (row.isSelected != isSelected) {
      row.isSelected = isSelected;
      notifyListeners();
    }
  }

  /// Selects all displayed or filtered rows.
  void selectAll() {
    for (final r in _displayedRows) {
      r.isSelected = true;
    }
    notifyListeners();
  }

  /// Clears selection on all rows.
  void clearSelection() {
    for (final r in _rows) {
      r.isSelected = false;
    }
    notifyListeners();
  }

  // --- Hierarchy / Tree Operations ---

  /// Toggles expansion of a hierarchical [row].
  void toggleRowExpansion(AcDataRow row) {
    if (!row.hasChildren) return;
    row.isExpanded = !row.isExpanded;
    _rebuildDisplayedRows();
    notifyListeners();
  }

  /// Expands all hierarchical rows.
  void expandAll() {
    for (final r in _rows) {
      if (r.hasChildren) r.isExpanded = true;
    }
    _rebuildDisplayedRows();
    notifyListeners();
  }

  /// Collapses all hierarchical rows.
  void collapseAll() {
    for (final r in _rows) {
      r.isExpanded = false;
    }
    _rebuildDisplayedRows();
    notifyListeners();
  }

  // --- Core Processing Engine ---

  /// Re-evaluates filters, sorting, search, and pagination.
  Future<void> refresh() async {
    if (onDemandFetch != null) {
      await _fetchOnDemand();
      return;
    }

    _applyFilterAndSearch();
    _applySort();
    _rebuildDisplayedRows();
    notifyListeners();
  }

  void _buildRows() {
    _rows = [];
    final Map<String, AcDataRow> rowMap = {};

    for (int i = 0; i < _rawData.length; i++) {
      final item = _rawData[i];
      final String id = _extractId(item, i);
      final String? parentId = parentIdField != null ? _extractParentId(item) : null;

      final row = AcDataRow(
        data: item,
        id: id,
        index: i,
        parentId: parentId,
      );
      _rows.add(row);
      rowMap[id] = row;
    }

    // Build tree parent-child links if parentIdField is configured
    if (parentIdField != null) {
      for (final row in _rows) {
        if (row.parentId != null && rowMap.containsKey(row.parentId)) {
          final parent = rowMap[row.parentId]!;
          parent.children.add(row);
          row.level = parent.level + 1;
        }
      }
    }
  }

  String _extractId(dynamic item, int fallbackIndex) {
    if (item is Map && item.containsKey(idField)) {
      return item[idField].toString();
    }
    try {
      final val = (item as dynamic)[idField];
      if (val != null) return val.toString();
    } catch (_) {}
    return fallbackIndex.toString();
  }

  String? _extractParentId(dynamic item) {
    if (parentIdField == null) return null;
    if (item is Map && item.containsKey(parentIdField)) {
      final val = item[parentIdField];
      return val?.toString();
    }
    try {
      final val = (item as dynamic)[parentIdField];
      return val?.toString();
    } catch (_) {}
    return null;
  }

  void _applyFilterAndSearch() {
    _filteredRows = _rows.where((row) {
      // 1. Evaluate filter group
      if (_filterGroup.filters.isNotEmpty || _filterGroup.filterGroups.isNotEmpty) {
        if (!AcFilterEvaluator.evaluateGroup(group: _filterGroup, data: row.data)) {
          return false;
        }
      }

      // 2. Evaluate search query
      if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
        if (!AcSearchEvaluator.evaluateSearch(
          searchQuery: _searchQuery,
          data: row.data,
          searchKeys: _searchKeys,
        )) {
          return false;
        }
      }

      return true;
    }).toList();

    _totalRows = _filteredRows.length;
  }

  void _applySort() {
    if (_sortOrders.sortOrders.isNotEmpty) {
      _filteredRows.sort((a, b) => AcSortComparator.compare(a, b, _sortOrders));
    }
  }

  void _rebuildDisplayedRows() {
    List<AcDataRow> sourceRows = _filteredRows;

    // Handle tree hierarchy visibility (if parent is collapsed, children are hidden)
    if (parentIdField != null) {
      final List<AcDataRow> treeVisibleRows = [];
      final Set<String> visibleParentIds = {};

      // Root rows (no parent or parent not in dataset)
      for (final row in sourceRows) {
        if (row.parentId == null || row.parentId!.isEmpty) {
          treeVisibleRows.add(row);
          if (row.isExpanded) visibleParentIds.add(row.id);
        } else if (visibleParentIds.contains(row.parentId)) {
          treeVisibleRows.add(row);
          if (row.isExpanded) visibleParentIds.add(row.id);
        }
      }
      sourceRows = treeVisibleRows;
    }

    // Apply pagination slicing
    if (_usePagination && _pageSize > 0) {
      final start = (_activePage - 1) * _pageSize;
      if (start >= sourceRows.length) {
        _displayedRows = [];
      } else {
        final end = (start + _pageSize).clamp(0, sourceRows.length);
        _displayedRows = sourceRows.sublist(start, end);
      }
    } else {
      _displayedRows = sourceRows;
    }
  }

  Future<void> _fetchOnDemand() async {
    if (onDemandFetch == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final start = (_activePage - 1) * _pageSize;
      final end = start + _pageSize;

      final args = AcOnDemandRequestArgs(
        startRow: start,
        endRow: end,
        pageSize: _pageSize,
        page: _activePage,
        sortOrders: _sortOrders,
        filterGroup: _filterGroup,
        searchQuery: _searchQuery,
      );

      final response = await onDemandFetch!(args);
      _rawData = response.rows;
      _totalRows = response.totalRows;
      _buildRows();
      _displayedRows = List.from(_rows);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

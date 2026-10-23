import 'package:flutter/material.dart';
import '../data_manager/ac_data_manager.dart';

/// Highly customizable pagination bar with page navigation, page size selector,
/// page number pills, entry counter, and optional add button.
class AcPagination extends StatelessWidget {
  /// The [AcDataManager] driving this pagination control.
  final AcDataManager? dataManager;

  /// Standalone 1-based active page index (used when [dataManager] is null).
  final int activePage;

  /// Standalone rows per page (used when [dataManager] is null).
  final int pageSize;

  /// Standalone total rows count (used when [dataManager] is null).
  final int totalRows;

  /// Available page size options in the dropdown.
  final List<int> pageSizeOptions;

  /// Whether to display the page size selector dropdown.
  final bool showPageSizeSelector;

  /// Whether to display numeric page pill buttons.
  final bool showPageNumbers;

  /// Whether to display the entry range counter label.
  final bool showEntrySummary;

  /// Whether to display an add button.
  final bool showAddButton;

  /// Callback when add button is clicked.
  final VoidCallback? onAdd;

  /// Callback when the page changes in standalone mode.
  final ValueChanged<int>? onPageChange;

  /// Callback when the page size changes in standalone mode.
  final ValueChanged<int>? onPageSizeChange;

  const AcPagination({
    super.key,
    this.dataManager,
    this.activePage = 1,
    this.pageSize = 50,
    this.totalRows = 0,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.showPageSizeSelector = true,
    this.showPageNumbers = true,
    this.showEntrySummary = true,
    this.showAddButton = false,
    this.onAdd,
    this.onPageChange,
    this.onPageSizeChange,
  });

  int get _currentPage => dataManager?.activePage ?? activePage;
  int get _currentPageSize => dataManager?.pageSize ?? pageSize;
  int get _currentTotalRows => dataManager?.totalRows ?? totalRows;
  int get _currentTotalPages => dataManager?.totalPages ?? ((_currentTotalRows / _currentPageSize).ceil().clamp(1, 999999));
  int get _currentStartRow => dataManager?.startRow ?? (((_currentPage - 1) * _currentPageSize) + 1);
  int get _currentEndRow => dataManager?.endRow ?? (_currentPage * _currentPageSize).clamp(0, _currentTotalRows);

  void _changePage(int page) {
    if (page < 1 || page > _currentTotalPages || page == _currentPage) return;
    if (dataManager != null) {
      dataManager!.setActivePage(page);
    } else {
      onPageChange?.call(page);
    }
  }

  void _changePageSize(int size) {
    if (size == _currentPageSize) return;
    if (dataManager != null) {
      dataManager!.setPageSize(size);
    } else {
      onPageSizeChange?.call(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataManager != null) {
      return ListenableBuilder(
        listenable: dataManager!,
        builder: (context, _) => _buildBar(context),
      );
    }
    return _buildBar(context);
  }

  Widget _buildBar(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = _currentPage <= 1;
    final isLast = _currentPage >= _currentTotalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          // Left section: Add button + Entry Summary
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAddButton) ...[
                IconButton.filledTonal(
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: 'Add Row',
                  onPressed: onAdd,
                ),
                const SizedBox(width: 8),
              ],
              if (showEntrySummary)
                Text(
                  _currentTotalRows == 0
                      ? 'No entries'
                      : 'Showing $_currentStartRow to $_currentEndRow of $_currentTotalRows entries',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
            ],
          ),

          // Right section: Page size dropdown + Navigation buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showPageSizeSelector) ...[
                  Text('Rows per page:', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 6),
                  DropdownButton<int>(
                    value: pageSizeOptions.contains(_currentPageSize)
                        ? _currentPageSize
                        : pageSizeOptions.first,
                    isDense: true,
                    underline: const SizedBox(),
                    items: pageSizeOptions.map((s) => DropdownMenuItem(value: s, child: Text(s.toString()))).toList(),
                    onChanged: (val) {
                      if (val != null) _changePageSize(val);
                    },
                  ),
                  const SizedBox(width: 12),
                ],

                // First page
                IconButton(
                  icon: const Icon(Icons.first_page, size: 20),
                  tooltip: 'First Page',
                  onPressed: isFirst ? null : () => _changePage(1),
                  splashRadius: 18,
                ),

                // Previous page
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  tooltip: 'Previous Page',
                  onPressed: isFirst ? null : () => _changePage(_currentPage - 1),
                  splashRadius: 18,
                ),

                // Numbered pills
                if (showPageNumbers) ..._buildPagePills(context),

                // Next page
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  tooltip: 'Next Page',
                  onPressed: isLast ? null : () => _changePage(_currentPage + 1),
                  splashRadius: 18,
                ),

                // Last page
                IconButton(
                  icon: const Icon(Icons.last_page, size: 20),
                  tooltip: 'Last Page',
                  onPressed: isLast ? null : () => _changePage(_currentTotalPages),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPagePills(BuildContext context) {
    final List<Widget> pills = [];
    final total = _currentTotalPages;
    final current = _currentPage;

    if (total <= 1) return pills;

    const int maxVisible = 5;
    int start = (current - (maxVisible ~/ 2)).clamp(1, total);
    int end = (start + maxVisible - 1).clamp(1, total);
    if (end - start < maxVisible - 1) {
      start = (end - maxVisible + 1).clamp(1, total);
    }

    if (start > 1) {
      pills.add(_buildPill(context, 1));
      if (start > 2) {
        pills.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...'),
        ));
      }
    }

    for (int p = start; p <= end; p++) {
      pills.add(_buildPill(context, p));
    }

    if (end < total) {
      if (end < total - 1) {
        pills.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...'),
        ));
      }
      pills.add(_buildPill(context, total));
    }

    return pills;
  }

  Widget _buildPill(BuildContext context, int page) {
    final theme = Theme.of(context);
    final isSelected = page == _currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _changePage(page),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

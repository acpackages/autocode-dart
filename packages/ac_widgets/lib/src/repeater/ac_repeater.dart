import 'dart:async';
import 'package:flutter/material.dart';
import '../data_manager/ac_data_manager.dart';
import '../data_manager/ac_data_row.dart';
import '../pagination/ac_pagination.dart';
import '../popups/filter/ac_data_filter_button.dart';
import '../popups/filter/ac_filter_field.dart';
import '../popups/sort/ac_data_sort_button.dart';
import '../popups/sort/ac_sort_field.dart';

/// Builder signature for individual repeater rows.
typedef AcRepeaterRowBuilder = Widget Function(
  BuildContext context,
  AcDataRow row,
  int index,
);

/// A reactive data list widget powered by [AcDataManager] featuring integrated
/// search, filter popup, multi-sort popup, zebra striping, empty state, and pagination.
class AcRepeater extends StatefulWidget {
  final AcDataManager dataManager;
  final AcRepeaterRowBuilder itemBuilder;

  /// Fields enabled for filtering in the header filter popup.
  final List<AcFilterField>? filterFields;

  /// Fields enabled for sorting in the header sort popup.
  final List<AcSortField>? sortFields;

  /// Whether to display the integrated search/filter/sort header bar.
  final bool showHeader;

  /// Whether to display the search box in the header.
  final bool showSearch;

  /// Custom action widgets to display on the trailing side of the header.
  final List<Widget>? headerActions;

  /// Whether to display [AcPagination] at the bottom of the repeater.
  final bool showPagination;

  /// Whether to apply alternating background colors to rows.
  final bool zebraStriping;

  /// Custom empty state builder when no rows match.
  final WidgetBuilder? emptyBuilder;

  /// Custom loading indicator builder during on-demand fetches.
  final WidgetBuilder? loadingBuilder;

  /// Callback when a row is tapped.
  final ValueChanged<AcDataRow>? onRowTap;

  /// Whether the internal list should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Custom scroll physics.
  final ScrollPhysics? physics;

  const AcRepeater({
    super.key,
    required this.dataManager,
    required this.itemBuilder,
    this.filterFields,
    this.sortFields,
    this.showHeader = true,
    this.showSearch = true,
    this.headerActions,
    this.showPagination = true,
    this.zebraStriping = true,
    this.emptyBuilder,
    this.loadingBuilder,
    this.onRowTap,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<AcRepeater> createState() => _AcRepeaterState();
}

class _AcRepeaterState extends State<AcRepeater> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.dataManager.searchQuery ?? '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.dataManager.setSearchQuery(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    widget.dataManager.setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dataManager,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showHeader) _buildHeader(context),
            Expanded(
              flex: widget.shrinkWrap ? 0 : 1,
              child: _buildBody(context),
            ),
            if (widget.showPagination)
              AcPagination(dataManager: widget.dataManager),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final filterFields = widget.filterFields ?? [];
    final sortFields = widget.sortFields ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // Search input
          if (widget.showSearch)
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: _clearSearch,
                            splashRadius: 14,
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Filter Button
          if (filterFields.isNotEmpty)
            AcDataFilterButton(
              dataManager: widget.dataManager,
              fields: filterFields,
            ),

          // Sort Button
          if (sortFields.isNotEmpty)
            AcDataSortButton(
              dataManager: widget.dataManager,
              fields: sortFields,
            ),

          // Additional actions
          if (widget.headerActions != null) ...widget.headerActions!,
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.dataManager.isLoading) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    final rows = widget.dataManager.displayedRows;

    if (rows.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? _defaultEmptyWidget(context);
    }

    final theme = Theme.of(context);

    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        final isEven = i % 2 == 0;
        final bg = widget.zebraStriping && !isEven
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
            : Colors.transparent;

        return Material(
          color: row.isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : bg,
          child: InkWell(
            onTap: widget.onRowTap != null ? () => widget.onRowTap!(row) : null,
            child: widget.itemBuilder(context, row, i),
          ),
        );
      },
    );
  }

  Widget _defaultEmptyWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('No records found', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
          ],
        ),
      ),
    );
  }
}

import 'package:autocode/autocode.dart';

/// Request parameters passed when fetching a page of data from a remote source on-demand.
class AcOnDemandRequestArgs {
  final int startRow;
  final int endRow;
  final int pageSize;
  final int page;
  final AcSortOrder? sortOrders;
  final AcFilterGroup? filterGroup;
  final String? searchQuery;

  const AcOnDemandRequestArgs({
    required this.startRow,
    required this.endRow,
    required this.pageSize,
    required this.page,
    this.sortOrders,
    this.filterGroup,
    this.searchQuery,
  });
}

/// Response returned from an on-demand remote data fetch.
class AcOnDemandResponseArgs {
  final List<dynamic> rows;
  final int totalRows;

  const AcOnDemandResponseArgs({
    required this.rows,
    required this.totalRows,
  });
}

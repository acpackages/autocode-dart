import 'package:autocode/autocode.dart';
import '../ac_data_row.dart';

/// Compares [AcDataRow] items according to a list of [AcSort] criteria.
class AcSortComparator {
  /// Compares [rowA] and [rowB] given [sortOrder].
  static int compare(AcDataRow rowA, AcDataRow rowB, AcSortOrder sortOrder) {
    if (sortOrder.sortOrders.isEmpty) return 0;

    for (final sort in sortOrder.sortOrders) {
      if (sort.order == AcEnumSortOrder.none) continue;

      final valA = rowA.getValue(sort.key);
      final valB = rowB.getValue(sort.key);

      final result = _compareValues(valA, valB);
      if (result != 0) {
        return sort.order == AcEnumSortOrder.ascending ? result : -result;
      }
    }
    return 0;
  }

  static int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    final numA = num.tryParse(a.toString());
    final numB = num.tryParse(b.toString());
    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }

    final dateA = DateTime.tryParse(a.toString());
    final dateB = DateTime.tryParse(b.toString());
    if (dateA != null && dateB != null) {
      return dateA.compareTo(dateB);
    }

    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }
}

/// Evaluates quick search queries across fields of data items.
class AcSearchEvaluator {
  /// Returns `true` if any field in [data] contains [searchQuery] case-insensitively.
  /// If [searchKeys] is provided, only those keys are inspected.
  static bool evaluateSearch({
    required String? searchQuery,
    required dynamic data,
    List<String>? searchKeys,
  }) {
    if (searchQuery == null || searchQuery.trim().isEmpty) return true;
    if (data == null) return false;

    final query = searchQuery.trim().toLowerCase();

    if (data is Map) {
      final keys = searchKeys ?? data.keys.map((k) => k.toString()).toList();
      for (final key in keys) {
        final val = data[key];
        if (val != null && val.toString().toLowerCase().contains(query)) {
          return true;
        }
      }
      return false;
    }

    // Fallback: check string representation
    return data.toString().toLowerCase().contains(query);
  }
}

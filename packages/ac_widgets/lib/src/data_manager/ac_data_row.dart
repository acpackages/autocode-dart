/// Represents a single managed row in [AcDataManager].
class AcDataRow {
  /// The underlying raw data item (typically a Map<String, dynamic> or object).
  dynamic data;

  /// The unique identifier of this row.
  final String id;

  /// The index of this row within the dataset.
  int index;

  /// The ID of the parent row, if this row belongs to a hierarchical tree.
  String? parentId;

  /// The nesting depth level in tree mode (0 = root).
  int level;

  /// Whether children are expanded in tree mode.
  bool isExpanded;

  /// Whether this row is currently selected.
  bool isSelected;

  /// Child rows when hierarchical tree mode is active.
  final List<AcDataRow> children;

  AcDataRow({
    required this.data,
    required this.id,
    this.index = 0,
    this.parentId,
    this.level = 0,
    this.isExpanded = false,
    this.isSelected = false,
    List<AcDataRow>? children,
  }) : children = children ?? [];

  /// Whether this row has any child rows.
  bool get hasChildren => children.isNotEmpty;

  /// Retrieves a value for [key] from [data].
  dynamic getValue(String key) {
    if (data == null) return null;
    if (data is Map) {
      return (data as Map)[key];
    }
    // Try dynamic property access if possible or toString
    try {
      return (data as dynamic)[key];
    } catch (_) {
      return null;
    }
  }

  /// Sets a value for [key] on [data].
  void setValue(String key, dynamic value) {
    if (data == null) return;
    if (data is Map) {
      (data as Map)[key] = value;
      return;
    }
    try {
      (data as dynamic)[key] = value;
    } catch (_) {}
  }
}

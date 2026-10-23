/// Defines a field available for sorting in [AcDataSortPopup].
class AcSortField {
  /// The key/field name in the dataset.
  final String key;

  /// Human-readable label displayed in UI.
  final String label;

  /// Whether sorting is allowed on this field.
  final bool allowSort;

  const AcSortField({
    required this.key,
    required this.label,
    this.allowSort = true,
  });
}

/// Defines a field available for filtering in [AcDataFilterPopup].
class AcFilterField {
  /// The key/field name in the dataset.
  final String key;

  /// Human-readable label displayed in UI.
  final String label;

  /// Data type: 'string', 'number', 'date', 'datetime', 'boolean'.
  final String type;

  /// Whether filtering is allowed on this field.
  final bool allowFilter;

  const AcFilterField({
    required this.key,
    required this.label,
    this.type = 'string',
    this.allowFilter = true,
  });
}

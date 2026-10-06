enum AcEnumPatchType {
  dartApplication('dart_application'),
  asset('asset'),
  hybrid('hybrid');

  final String value;
  const AcEnumPatchType(this.value);

  static AcEnumPatchType? fromValue(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase().trim();
    for (final t in values) {
      if (t.value == lower || t.name.toLowerCase() == lower) return t;
    }
    return null;
  }
}

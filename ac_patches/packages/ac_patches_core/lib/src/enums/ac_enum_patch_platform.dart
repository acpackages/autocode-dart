enum AcEnumPatchPlatform {
  android('android'),
  windows('windows'),
  linux('linux'),
  macos('macos'),
  ios('ios');

  final String value;
  const AcEnumPatchPlatform(this.value);

  static AcEnumPatchPlatform? fromValue(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase().trim();
    for (final p in values) {
      if (p.value == lower) return p;
    }
    return null;
  }
}

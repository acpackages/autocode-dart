enum AcEnumPatchArchitecture {
  arm64_v8a('arm64-v8a'),
  armeabi_v7a('armeabi-v7a'),
  x86_64('x86_64');

  final String value;
  const AcEnumPatchArchitecture(this.value);

  static AcEnumPatchArchitecture? fromValue(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase().trim();
    for (final a in values) {
      if (a.value == lower || a.name == lower) return a;
    }
    if (lower == 'arm64' || lower == 'aarch64') return arm64_v8a;
    if (lower == 'arm' || lower == 'armeabi') return armeabi_v7a;
    if (lower == 'x64' || lower == 'amd64') return x86_64;
    return null;
  }
}

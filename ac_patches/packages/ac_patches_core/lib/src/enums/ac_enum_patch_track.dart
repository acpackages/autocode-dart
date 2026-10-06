enum AcEnumPatchTrack {
  development('development'),
  staging('staging'),
  beta('beta'),
  stable('stable');

  final String value;
  const AcEnumPatchTrack(this.value);

  static AcEnumPatchTrack? fromValue(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase().trim();
    for (final t in values) {
      if (t.value == lower || t.name.toLowerCase() == lower) return t;
    }
    return null;
  }
}

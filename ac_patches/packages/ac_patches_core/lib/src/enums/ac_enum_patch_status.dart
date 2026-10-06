enum AcEnumPatchStatus {
  created('created'),
  uploaded('uploaded'),
  validated('validated'),
  published('published'),
  active('active'),
  paused('paused'),
  rolledBack('rolled_back'),
  disabled('disabled');

  final String value;
  const AcEnumPatchStatus(this.value);

  static AcEnumPatchStatus? fromValue(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase().trim();
    for (final s in values) {
      if (s.value == lower || s.name.toLowerCase() == lower) return s;
    }
    return null;
  }
}

enum AcEnumClientPatchState {
  none('none'),
  checking('checking'),
  available('available'),
  downloading('downloading'),
  downloaded('downloaded'),
  pending('pending'),
  activating('activating'),
  active('active'),
  healthy('healthy'),
  failed('failed'),
  rolledBack('rolled_back');

  final String value;
  const AcEnumClientPatchState(this.value);

  static AcEnumClientPatchState? fromValue(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase().trim();
    for (final s in values) {
      if (s.value == lower || s.name.toLowerCase() == lower) return s;
    }
    return null;
  }
}

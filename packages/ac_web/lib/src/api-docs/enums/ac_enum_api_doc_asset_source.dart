enum AcEnumApiDocAssetSource {
  cdn('cdn'),
  directory('directory'),
  injectedMap('injected_map');

  final String value;
  const AcEnumApiDocAssetSource(this.value);

  static AcEnumApiDocAssetSource fromValue(String value) {
    return AcEnumApiDocAssetSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AcEnumApiDocAssetSource.cdn,
    );
  }
}

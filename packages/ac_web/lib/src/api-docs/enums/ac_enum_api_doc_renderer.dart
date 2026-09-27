enum AcEnumApiDocRenderer {
  scalar('scalar'),
  swaggerUi('swagger_ui'),
  redoc('redoc'),
  rapidoc('rapidoc'),
  elements('elements');

  final String value;
  const AcEnumApiDocRenderer(this.value);

  static AcEnumApiDocRenderer fromValue(String value) {
    return AcEnumApiDocRenderer.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AcEnumApiDocRenderer.scalar,
    );
  }
}

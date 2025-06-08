class AcWebRouteMeta {
  final String? summary;
  final String? description;
  final List<dynamic> parameters;
  final List<dynamic> tags;

  const AcWebRouteMeta({
    this.summary = '',
    this.description = '',
    this.parameters = const [],
    this.tags = const [],
  });
}

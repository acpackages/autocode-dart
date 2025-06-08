
import 'dart:core';

class AcWebRouteMetaParameter {
  final String description;
  final String name;
  final String required;
  final String explode;
  final List<dynamic> schema;

  const AcWebRouteMetaParameter({
  this.description = '',
  this.name = '',
  this.required = '',
  this.explode = '',
  this.schema = const [],
});
}
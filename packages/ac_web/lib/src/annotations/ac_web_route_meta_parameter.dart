import 'dart:core';
import 'package:ac_mirrors/ac_mirrors.dart';
@AcReflectable()
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
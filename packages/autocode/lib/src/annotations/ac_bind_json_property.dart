import 'package:ac_mirrors/ac_mirrors.dart';

class AcBindJsonProperty {
  final String? key;
  final Type? arrayType;
  final bool? skipInFromJson;
  final bool? skipInToJson;

  const AcBindJsonProperty({
    this.key,
    this.arrayType,
    this.skipInFromJson,
    this.skipInToJson,
  });
}

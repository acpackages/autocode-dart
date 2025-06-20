import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
@AcReflectable()
class AcApiDocComponents {
  static const String KEY_SCHEMAS = 'schemas';

  Map<String, AcApiDocSchema> schemas = {};

  static AcApiDocComponents instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocComponents();
    return instance.fromJson(jsonData: jsonData);
  }

  AcApiDocComponents fromJson({Map<String, dynamic> jsonData = const {}}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_SCHEMAS)) {
      final schemaData = json[KEY_SCHEMAS];
      if (schemaData is Map<String, dynamic>) {
        for (var entry in schemaData.entries) {
          schemas[entry.key] = AcApiDocSchema.instanceFromJson(
            jsonData: entry.value,
          );
        }
      }
      json.remove(KEY_SCHEMAS);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (schemas.isNotEmpty) {
      final schemaJson = <String, dynamic>{};
      for (var entry in schemas.entries) {
        final json = entry.value.toJson();
        if (json.isNotEmpty) {
          schemaJson[entry.key] = json;
        }
      }
      if (schemaJson.isNotEmpty) {
        result[KEY_SCHEMAS] = schemaJson;
      }
    }

    return result;
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}

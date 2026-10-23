import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/// Represents a single filter condition (e.g., "age > 18")
@AcReflectable()
class AcFilter {
  static const String keyKey = "key";
  static const String keyOperator = "operator";
  static const String keyValue = "value";

  String key = '';
  AcEnumConditionOperator operator = AcEnumConditionOperator.unknown;
  dynamic value;

  AcFilter();

  factory AcFilter.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcFilter();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  factory AcFilter.instanceWithValues({
    required String key,
    required AcEnumConditionOperator operator,
    required dynamic value,
  }) {
    final result = AcFilter()
      ..key = key
      ..operator = operator
      ..value = value;
    return result;
  }

  AcFilter clone() {
    return AcFilter.instanceFromJson(jsonData: toJson());
  }

  AcFilter fromJson({required Map<String, dynamic> jsonData}) {
    key = AcJsonUtils.deserializeValue<String>(
      jsonData[keyKey] ?? jsonData['key'],
      defaultValue: key,
    )!;
    operator = AcJsonUtils.deserializeValue<AcEnumConditionOperator>(
      jsonData[keyOperator] ?? jsonData['operator'],
      enumValues: AcEnumConditionOperator.values,
      defaultValue: operator,
    )!;
    if (jsonData.containsKey(keyValue) || jsonData.containsKey('value')) {
      value = jsonData[keyValue] ?? jsonData['value'];
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      keyKey: key,
      keyOperator: AcJsonUtils.serializeValue(operator),
      keyValue: AcJsonUtils.serializeValue(value),
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}